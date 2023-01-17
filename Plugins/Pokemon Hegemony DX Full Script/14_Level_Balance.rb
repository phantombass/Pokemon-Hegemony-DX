################################################################################
# Advanced Pokemon Level Balancing
# By Joltik
#Inspired by Umbreon's code
#Tweaked by Phantombass for use in Pokémon Promenade
################################################################################
################################################################################


module LvlCap
  Switch = 111               #Switch that turns on Trainer Difficulty Control
  LevelCap = 106             #Variable for the Level Cap
  Gym = 86                   #Switch for Gym Battles
  Rival = 87                 #Switch for Rival Battles
  LvlTrainer = 88
  Trainers = 72              #Switch for Trainers
  Boss = 908                  #Switch for Ace Trainer Battles
  Hard = 900
  Expert = 903
  Ironmon = 905
  Kaizo = 906
  Randomizer = 907
  NoChange   = 908
end

class Level_Scaling
  attr_accessor :boss
  attr_accessor :gym
  attr_accessor :rival
  attr_accessor :active

  def initialize
    @active = $game_switches[LvlCap::Trainers]
    @boss = $game_switches[LvlCap::Boss]
    @gym = $game_switches[LvlCap::Gym]
    @rival = $game_switches[LvlCap::Rival]
  end

  def self.boss?
    return @boss
  end

  def self.gym?
    return @gym
  end

  def self.rival?
    return @rival
  end

  def self.active?
    return @active
  end

  def self.activate
    $game_switches[LvlCap::Trainers] = true
    $game_switches[LvlCap::Switch] = true
  end

  def self.prevent_changes?
    return true if (($game_switches[LvlCap::Kaizo] || $game_switches[LvlCap::Randomizer]) && (self.boss? == false && self.rival? == false && self.gym? == false)) || $game_switches[LvlCap::NoChange]
    return false
  end

  def self.evolve(pokemon,level,levelcap)
    species = pokemon.species
    newspecies = GameData::Species.get(species).get_baby_species # revert to the first evolution
    $newspecies = newspecies
      evoflag=0 #used to track multiple evos not done by lvl
      endevo=false
      loop do #beginning of loop to evolve species
        level = 0
        level = levelcap if level > levelcap
        cevo = GameData::Species.get($newspecies).evolutions
        evo = GameData::Species.get($newspecies).get_evolutions
        if evo
          evo = evo[rand(evo.length - 1)]
          # here we evolve things that don't evolve through level
          # that's what we check with evo[0]!=4
          #notice that such species have cevo==-1 and wouldn't pass the last check
          #to avoid it we set evoflag to 1 (with some randomness) so that
          #pokemon may have its second evolution (Raichu, for example)
          if evo && cevo[0][1] != :Level
            if evo[0] != 4
            newspecies = evo[2]
               if evoflag == 0
                 evoflag=1
               else
                 evoflag=0
               end
             end
          else
          endevo=true
          end
        end
        if evoflag==0 || endevo
          if  cevo[1] == nil
            # Breaks if there no more evolutions or randomnly
            # Randomness applies only if the level is under 50
            break
          else
            newspecies = evo[2]
          end
        end
      end #end of loop do
    #fixing some things such as Bellossom would turn into Vileplume
    #check if original species could evolve (Bellosom couldn't)
    couldevo=GameData::Species.get(species).get_evolutions
    #check if current species can evolve
    evo = GameData::Species.get($newspecies).get_evolutions
      if evo.length<1 && couldevo.length<1
        return species
      else
        return $newspecies
      end #end of evolving script 
  end
end

Events.onTrainerPartyLoad+=proc {| sender, trainer |
   if trainer # Trainer data should exist to be loaded, but may not exist somehow
     party = trainer[0].party   # An array of the trainer's Pokémon
    if $game_switches && $game_switches[LvlCap::Switch] && $Trainer && $game_switches[Settings::LEVEL_CAP_SWITCH]
       levelcap = LEVEL_CAP[$game_system.level_cap]
       badges = $Trainer.badge_count
       mlv = $Trainer.party.map { |e| e.level  }.max
      for i in 0...party.length
        level = 0
        level=1 if level<1
        if mlv<=levelcap && mlv <= party[i].level && $game_switches[LvlCap::Gym] == true && $game_switches[LvlCap::Trainers] == true
          if $game_switches[LvlCap::Hard] == true && $game_switches[LvlCap::Expert] == false
            level = levelcap + rand(2)
          elsif $game_switches[LvlCap::Hard] == true && $game_switches[LvlCap::Expert] == true
            level = levelcap + rand(2) +1
          else
            level = levelcap
          end
        elsif $game_switches[LvlCap::LvlTrainer] == true
          level = levelcap - 5
        elsif $game_switches[LvlCap::Trainers] == true && $game_switches[LvlCap::Gym] == false && $game_switches[LvlCap::Rival] == false
          level = (mlv-1) - rand(1)
          if $game_switches[LvlCap::Hard]
            level += 1
          elsif $game_switches[LvlCap::Expert]
            level += 2
          end
        elsif $game_switches[LvlCap::Rival] == true && $game_switches[LvlCap::Hard] == false
          level = party[i].level - rand(2)
        elsif $game_switches[LvlCap::Hard] == true && $game_switches[LvlCap::Expert] == false && $game_switches[LvlCap::Rival] == true
          level = party[i].level
        elsif $game_switches[LvlCap::Hard] == true && $game_switches[LvlCap::Expert] == true && $game_switches[LvlCap::Rival] == true
          level = party[i].level + 2
        else
          level = levelcap
        end
        party[i].level = level
        #now we evolve the pokémon, if applicable
        #unused
        party[i].calc_stats
        if Level_Scaling.prevent_changes? == false
          party[i].species = Level_Scaling.evolve(party[i],level,levelcap)
          party[i].item = nil if $Trainer.badge_count < 3
          party[i].ability_index = rand(2) if $Trainer.badge_count < 3
          party[i].reset_moves
        end
      end #end of for
     end
   end
}
