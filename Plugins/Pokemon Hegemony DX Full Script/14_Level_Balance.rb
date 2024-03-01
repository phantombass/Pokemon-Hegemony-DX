module LvlCap
  Switch = 111               #Switch that turns on Trainer Difficulty Control
  LevelCap = 106             #Variable for the Level Cap
  Gym = 86                   #Switch for Gym Battles
  Rival = 87                 #Switch for Rival Battles
  LvlTrainer = 88
  Trainers = 72              #Switch for Trainers
  Boss = 908                  #Switch for Ace Trainer Battles
  Hard = 900
  Insane = 902
  Expert = 903
  Ironmon = 905
  Kaizo = 906
  Randomizer = 907
  NoChange   = 908
end

class Level_Scaling

  def self.boss?
    return $game_switches[LvlCap::Boss]
  end

  def self.gym?
    return $game_switches[LvlCap::Gym]
  end

  def self.rival?
    return $game_switches[LvlCap::Rival]
  end

  def self.active?
    return $game_switches[LvlCap::Trainers]
  end

  def self.activate
    $game_switches[LvlCap::Trainers] = true
    $game_switches[LvlCap::Switch] = true
  end

  def self.gym_battle
    $game_switches[LvlCap::Gym] = true
  end

  def self.boss_battle
    $game_switches[LvlCap::Boss] = true
  end

  def self.end_battle
    $game_switches[LvlCap::Gym] = false
    $game_switches[LvlCap::Boss] = false
    $game_switches[LvlCap::Rival] = false
    $game_switches[LvlCap::LvlTrainer] = false
  end

  def self.prevent_changes?
    return true if $game_switches[LvlCap::Kaizo] || $game_switches[LvlCap::Randomizer]
    return true if (self.boss? == true || self.rival? == true || self.gym? == true) 
    return true if $game_switches[LvlCap::NoChange]
    return true if self.level_cap > 45
    return false
  end

  def self.level_cap
    return $game_switches[LvlCap::Insane] ? INSANE_LEVEL_CAP[$game_system.level_cap] : LEVEL_CAP[$game_system.level_cap]
  end

  def self.evolve(pokemon,level,levelcap,wild=false)
    #maps = [32,77,80,83,88,97,98,106,124,147,160,161,174,184,187,218,264,265,271,284,289,300,307,310,]
    PBAI.log("Now attempting to evolve...")
    species = pokemon.species
    newspecies = GameData::Species.get(species).get_baby_species # revert to the first evolution
    PBAI.log("Reverting to baby species: #{newspecies}")
    species_blacklist = [:EEVEE,:TYROGUE,:NINCADA,:WURMPLE,:SCYTHER,:APPLIN,:RALTS,:KIRLIA]
    if species_blacklist.include?(newspecies) && wild || levelcap == 15
      PBAI.log("Staying baby species due to level cap or being blacklisted")
    end
    return newspecies if species_blacklist.include?(newspecies) && wild
    return newspecies if levelcap == 15
    $newspecies = newspecies
      evoflag=0 #used to track multiple evos not done by lvl
      endevo=false
      loop_check = 0
      loop do #beginning of loop to evolve species
        loop_check += 1
        level = levelcap if level > levelcap
        evol = GameData::Species.get($newspecies).get_evolutions
        if evol
          evo = evol[0]
          # here we evolve things that don't evolve through level
          # that's what we check with evo[0]!=4
          #notice that such species have cevo==-1 and wouldn't pass the last check
          #to avoid it we set evoflag to 1 (with some randomness) so that
          #pokemon may have its second evolution (Raichu, for example)
          PBAI.log("Checking evo methods...")
          if evo != nil
            if [:Level,:Silcoon,:Cascoon,:Ninjask].include?(evo[1])
              if evo[2] <= level
                evoflag = 1
                $newspecies = evo[0]
                PBAI.log("Evolve by level up...")
              end
            elsif evo[1].to_s.start_with?('Happiness') && rand(100) < 50*($Trainer.badge_count+1)
              PBAI.log("Evolve by happiness...")
              $newspecies = evo[0]
              evoflag = 1
            elsif evo[1].to_s.start_with?('Trade') && rand(100) < 25*$Trainer.badge_count
              PBAI.log("Evolve by trade...")
              $newspecies = evo[0]
              evoflag = 1
            elsif evo[1].to_s.start_with?('Item') && rand(100) < 25*$Trainer.badge_count
              PBAI.log("Evolve by item...")
             $newspecies = evo[0]
             evoflag = 1
            else
              PBAI.log("No evolution...")
              evoflag = 0
              endevo = true
            end
          else
            PBAI.log("No evolution...")
            evoflag = 0
            endevo = true
          end
          if evoflag==0
            break if endevo
            if evo == nil
              # Breaks if there no more evolutions or randomnly
              # Randomness applies only if the level is under 50
              PBAI.log("Finish evolving")
              break
            end
          end
          break if loop_check >= 5
        end #end of loop do
      end
    #fixing some things such as Bellossom would turn into Vileplume
    #check if original species could evolve (Bellosom couldn't)
    couldevo=GameData::Species.get(species).get_evolutions
    #check if current species can evolve
    evo = GameData::Species.get($newspecies).get_evolutions
      if evo.length<1 && couldevo.length<1
        PBAI.log("Now returning evolved species")
        return species
      else
        PBAI.log("Now returning base species")
        return $newspecies
      end #end of evolving script 
  end
  def self.trainer_max_level
    return $Trainer.party.map { |e| e.level  }.max
  end
end

Events.onTrainerPartyLoad+=proc {| sender, trainer |
   if trainer # Trainer data should exist to be loaded, but may not exist somehow
     party = trainer[0].party   # An array of the trainer's Pokémon
    if $game_switches && $game_switches[LvlCap::Switch] && $Trainer && $game_switches[Settings::LEVEL_CAP_SWITCH]
       levelcap = Level_Scaling.level_cap
       badges = $Trainer.badge_count
       mlv = Level_Scaling.trainer_max_level
      for i in 0...party.length
        level = 0
        level=1 if level<1
        if mlv<=levelcap && mlv <= party[i].level && $game_switches[LvlCap::Gym] == true && $game_switches[LvlCap::Trainers] == true
          level = levelcap
        elsif $game_switches[LvlCap::LvlTrainer] == true
          level = levelcap - 5
        else
          level = party[i].level
        end
        party[i].level = level
        #now we evolve the pokémon, if applicable
        #unused
        party[i].calc_stats
      end #end of for
     end
   end
}

Events.onWildPokemonCreate+=proc {|sender,e|
  next if $dungeon.reward_locations.include?($game_map.map_id)
  pokemon = e[0]
  mlv = Level_Scaling.trainer_max_level
  levelcap = Level_Scaling.level_cap
  level = mlv - 4 - rand(3)
  level = 1 if level <= 0
  pokemon.level = level
  loop do
    species = Randomizer.all_trainer_species.sample
    bst = 0
    GameData::Species.get(species).base_stats.each_key {|stat| bst += GameData::Species.get(species).base_stats[stat]}
    threshold = [350,400,450,500,550,600,600,600,600,600,600,600]
    $species = species
    break if bst <= threshold[$game_system.level_cap]
  end
  pokemon.species = $species
  pokemon.species = Level_Scaling.evolve(pokemon,level,levelcap,true)
  pokemon.ability_index = rand(3)
  pokemon.reset_moves
  pokemon.calc_stats
}
