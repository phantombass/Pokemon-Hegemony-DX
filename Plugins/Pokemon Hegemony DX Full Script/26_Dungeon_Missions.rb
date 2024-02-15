module DungeonMissions
  Sign = 209
  Locations = 210
  Name = 211
  Rand = 212
  Target = 213
  Stars = 214
  Data = 215
  Reward = 216
  Steps = 217
  Floor = 218
  Floor_Target = 219
  Specific_Target = 220
  Missions = 221
  Target_Location = 222

  Mon_Switch = 926
  Item_Switch = 927
  Floor_Switch = 928
end

class Dungeon_Missions
  attr_accessor :locations
  attr_accessor :name
  attr_accessor :target
  attr_accessor :stars
  attr_accessor :mission_data
  attr_accessor :missions
  attr_accessor :dungeon_reward
  attr_accessor :steps

  def initialize
    @locations = []
    @name = []
    @target = []
    @stars = []
    @mission_data = {}
    @missions = {}
    @dungeon_reward = []
    @steps = 0
  end

  def self.stars
    return @stars
  end
  def self.locations
    return @locations
  end
  def self.target
    return @target
  end
  def self.name
    return @name
  end
  def self.mission_data
    return @mission_data
  end
  def self.missions
    return @missions
  end
  def self.dungeon_reward
    return @dungeon_reward
  end
  def self.steps
    return @steps
  end

  def setup
    @locations = $game_variables[DungeonMissions::Locations]
    @name = $game_variables[DungeonMissions::Name]
    @target = $game_variables[DungeonMissions::Target]
    @stars = $game_variables[DungeonMissions::Stars]
    @mission_data = $game_variables[DungeonMissions::Data]
    @dungeon_reward = $game_variables[DungeonMissions::Reward]
    @steps = $game_variables[DungeonMissions::Steps]
    @missions = $game_variables[DungeonMissions::Missions]
  end

  def clear_dungeon_data
    @locations = []
    @name = []
    @target = []
    @stars = []
    @dungeon_reward = []
    @steps = 1024
  end

  def gym_open?(location)
    return false
  end

  def randomize_rewards
    rewards = []
    loc = -1
    for i in @locations
      loc += 1
      case @name[loc]
      when "Dungeon of Experiments"
        list = []
        del = []
        case @stars[loc]
        when 1
          common = [:FINNEON2,:REMORAID2,:SPEAROW2,:DRIFLOON2,:ARON2,:IMPIDIMP2,:BIDOOF2,:COTTONEE2]
          rare = [:BULBASAUR2,:CHARMANDER2,:SQUIRTLE2,:TURTWIG2,:CHIMCHAR2,:PIPLUP2]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 2
          common = [:BLITZLE2,:GIBLE2,:DREEPY2,:GROWLITHE2,:BOUFFALANT2,:TAUROS2,:MILTANK2,:CHARCADET2]
          rare = [:TREECKO2,:TORCHIC2,:MUDKIP2,:GROOKEY2,:SCORBUNNY2,:SOBBLE2]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 3
          common = [:SKIDDO2,:SPOINK2,:TRAPINCH2,:BONSLY2,:VULPIX2,:TINKATINK2,:SNORUNT2,:TOGEDEMARU2]
          rare = [:CHIKORITA2,:CYNDAQUIL2,:TOTODILE2,:ROWLET2,:LITTEN2,:POPPLIO2]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 4
          common = [:CHINGLING2,:QWILFISH2,:SWABLU2,:LARVITAR2,:PORYGON1,:MANKEY2,:FERROSEED2,:MAGNEMITE2,:SPIRITOMB2,:PIKACHU2]
          rare = [:SNIVY2,:TEPIG2,:OSHAWOTT2,:CHESPIN2,:FENNEKIN2,:FROAKIE2]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 5
          common = [:DEINO2,:LARVESTA2,:PETILIL2,:DUNSPARCE2,:SNEASEL2,:TEDDIURSA2,:RUFFLET2,:BASCULIN2,:STANTLER2]
          rare = [:SPRIGATITO2,:FUECOCO2,:QUAXLY2,:SCYTHER2,:PAWNIARD2,:GIRAFARIG2]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        end
        pbEachPokemon { |poke,_box|
          mon = poke.species
          evo = GameData::Species.get(mon).get_baby_species
          evos = GameData::Species.get(evo).get_family_evolutions
          del.push(evos)
        }
        del.flatten!
        del.uniq!
        del.each do |e|
          if list.include?(e)
            list.delete(e)
          end
        end
        rewards.push(list[rand(list.length)])
      when "Dungeon of Learning"
        list = []
        del = []
        case @stars[loc]
        when 1
          common = [:TM27,:TM97,:TM119,:TM48,:TM50,:TM118]
          rare = [:TM115,:TM80]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 2
          common = [:TM76,:TM106,:TM14,:TM130,:TM141,:TM75]
          rare = [:TM125,:TM25]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 3
          common = [:TM133,:TM142,:TM69,:TM96,:TM292,:TM296]
          rare = [:TM03,:TM04,:TM05]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 4
          common = [:TM126,:TM135,:TM136,:TM137,:TM138,:TM139,:TM140,:TM143,:TM144,:TM145,:TM146,:TM120]
          rare = [:TM109,:TM250,:TM38]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 5
          common = [:TM257,:TM275,:TM208,:TM205,:TM202,:TM274,:TM211,:TM123,:TM39,:TM265,:TM284,:TM121]
          rare = [:TM253,:TM147,:TM134]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        end
        rewards.push(list[rand(list.length)])
      when "Dungeon of Support"
        list = []
        del = []
        case @stars[loc]
        when 1
          common = [:ABSORBBULB,:LUMINOUSMOSS,:CELLBATTERY,:BERRYJUICE,:WISEGLASSES,:MUSCLEBAND]
          rare = [:ADRENALINEORB,:NORMALGEM,:ELECTRICSEED,:ILLUMINATEORB]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 2
          common = [:METALCOAT,:SOFTSAND,:HARDSTONE,:STARDUST,:SPELLTAG,:BLACKBELT,:EXPERTBELT,:ALLOYSTONE,:DRACOSTONE]
          rare = [:INTIMIDATEORB,:FLYINGGEM,:LEFTOVERS,:MISTYSEED]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 3
          common = [:CHOICEBAND,:CHOICESPECS,:ELECTRICSEED,:MISTYSEED,:PSYCHICSEED,:GRASSYSEED,:TOXICSEED,:LIFEORB]
          rare = [:LEVITATEORB,:FILTERORB]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 4
          common = [:HEAVYDUTYBOOTS,:CHOICESCARF,:AIRBALLOON,:COVERTCLOAK,:CLEARAMULET,:LOADEDDICE,:PUNCHINGGLOVE,:PROTECTIVEPADS,:LEFTOVERS,:BLACKSLUDGE]
          rare = [:WATERABSORBORB,:FLASHFIREORB]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 5
          common = []
          GameData::Item.each do |item| 
            common.push(item) if item.is_mega_stone? && ![:DIANCITE,:LATIOSITE,:LATIASITE,:ETERNATITE,:MELMETALITE,:ULTRANECROZIUMZ,:CASTFORMITE].include?(GameData::Item.get(item).id)
          end
          rare = [:LIGHTNINGRODORB,:SAPSIPPERORB,:MEDUSOIDORB]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        end
        rewards.push(list[rand(list.length)])
      when "Dungeon of Life"
        list = []
        del = []
        case @stars[loc]
        when 1
          common = [:SCRAGGY,:SKORUPI,:VOLTORB,:MAGNEMITE,:HOUNDOUR,:EXEGGCUTE,:FLABEBE,:PUMPKABOO,:PHANTUMP,:BUNNELBY,:SANDILE,:SNUBBULL]
          rare = [:ELEKID,:MAGBY,:SMOOCHUM,:RIOLU,:ABRA,:GASTLY]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 2
          common = [:TEDDIURSA,:GIRAFARIG,:MANKEY,:DUNSPARCE,:PETILIL_1,:MIMEJR_1,:YAMASK_1,:BERGMITE_1,:RUFFLET_1,:FARFETCHD_1,:GROWLITHE_1,:BASCULIN_2]
          rare = [:GIMMIGHOUL,:SCYTHER,:PAWNIARD,:MUNCHLAX,:SNEASEL_1,:STANTLER]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 3
          common = [:HATTREM,:MORGREM,:CHINGLING,:CHATOT,:CARKOL,:CUFANT,:KIRLIA,:FURFROU,:TRUBBISH,:KRABBY,:INKAY,:SIZZLIPEDE]
          rare = [:MELTAN,:WYNAUT,:FEEBAS,:TOXEL,:DURALUDON,:VIBRAVA]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 4
          common = [:GIGALITH,:SIGILYPH,:NIDOQUEEN,:LANTURN,:TORKOAL,:VULPIX_1,:EXCADRILL,:BRAVIARY_1,:NIDOKING,:LUDICOLO,:SCOVILLAIN,:BEARTIC]
          rare = [:DRACOVISH,:DRACOZOLT,:ARCTOVISH,:ARCTOZOLT,:AURORUS,:TYRANTRUM]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        when 5
          common = [:DRAGONITE,:TYRANITAR,:METAGROSS,:SALAMENCE,:GARCHOMP,:HYDREIGON,:GOODRA,:KOMMOO,:DRAGAPULT,:BAXCALIBUR,:GOODRA_1,:CALYREX]
          rare = [:PHIONE,:POIPOLE,:KUBFU,:COSMOG]
          rarerand = rand(rare.length)
          for i in common
            list.push(i)
          end
          list.push(rare[rarerand])
        end
        rewards.push(list[rand(list.length)])
      else
        rewards.push(nil)
      end
    end
    return rewards
  end

  def dungeon_reward(location)
    loc = 0
    for i in reward_locations
      break if i == location
      loc += 1
    end
    return @dungeon_reward[loc]
  end


  def valid_locations
    loc = [81,85,321,328,352]
    return loc
  end

  def location_names
    loc = [80,83,317,311,351]
    return loc
  end

  def reward_locations
    loc = [382,404,388,394,378]
    return loc
  end

  def randomize_stars
    rep = ($game_system.reputation/30).floor
    rep = 1 if $game_system.reputation < 30
    rep = 5 if $game_system.reputation >= 150
    star = rand(rep) + 1
    return star
  end

  def stars(location)
    loc = 0
    for i in @locations
      break if i == location
      loc += 1
    end
    return @stars[loc]
  end

  def reward_stars(location)
    loc = 0
    for i in reward_locations
      break if i == location
      loc += 1
    end
    return @stars[loc]
  end

  def add_reputation(star)
    rep = $game_system.reputation
    part1 = ((15/(rep*0.02))*1.75).floor
    part2 = (0.4)*(2/star)
    add = (part1*part2).floor
    add = 0 if (add < 2 && rep >= 150)
    $game_system.reputation += add
    update_level_cap
  end

  def add_reputation_manual(add)
    $game_system.reputation += add
    update_level_cap
  end

  def lose_reputation(star)
    rep = $game_system.reputation
    star = 1 if star == 0
    part1 = ((15/(rep*0.02))*1.75).floor
    part2 = (0.4)*(2/star)
    part3 = star*star
    add = (part1*part2*part3).floor
    add = 1 if add < 1
    $game_system.reputation -= add
    $game_system.reputation = 30 if $game_system.reputation < 30
  end

  def lose_reputation_manual(lose)
    $game_system.reputation -= lose
  end

  def update_level_cap
    level_cap_increment = $game_system.level_cap
    if $game_system.reputation > 59 && $game_system.reputation < 90 && level_cap_increment == 0
      Game.level_cap_update
    elsif $game_system.reputation >= 90 && $game_system.reputation < 120 && level_cap_increment == 1
      Game.level_cap_update
    elsif $game_system.reputation >= 120 && $game_system.reputation < 150 && level_cap_increment == 2
      Game.level_cap_update
    elsif $game_system.reputation >= 150 && $game_system.reputation < 180 && level_cap_increment == 3
      Game.level_cap_update
    elsif $game_system.reputation >= 180 && $game_system.reputation < 210 && level_cap_increment == 4
      Game.level_cap_update
    elsif $game_system.reputation >= 210 && $game_system.reputation < 240 && level_cap_increment == 5
      Game.level_cap_update
    elsif $game_system.reputation >= 240 && $game_system.reputation < 270 && level_cap_increment == 6
      Game.level_cap_update
    elsif $game_system.reputation >= 270 && $game_system.reputation < 300 && level_cap_increment == 7
      Game.level_cap_update
    elsif $game_system.reputation >= 300 && $game_system.reputation < 400 && level_cap_increment == 8
      Game.level_cap_update
    elsif $game_system.reputation >= 400 && $game_system.reputation < 500 && level_cap_increment == 9
      Game.level_cap_update
    end
  end

  def sign(location)
    loc = 0
    for i in @locations
      break if i == location
      loc += 1
    end
    if (@locations.nil? || @name[loc] == nil) || @mission_data == ({} || 0 || nil) || !@mission_data.has_key?(location) || mission_complete?(@mission_data[location][:id])
      text = "Dungeon Closed"
      $game_switches[DungeonMissions::Mon_Switch] = false
      $game_switches[DungeonMissions::Item_Switch] = false
    else
      name = @name[loc].nil? ? @mission_data[location][:name] : @name[loc]
      star = @stars[loc].nil? ? @mission_data[location][:stars] : @stars[loc]
      stars = "Stars: #{star}"
      text = "#{name}\n#{stars}"
      case name
      when "Dungeon of Experiments", "Dungeon of Life"
        $game_switches[DungeonMissions::Mon_Switch] = true
        $game_switches[DungeonMissions::Item_Switch] = false
      when "Dungeon of Support", "Dungeon of Learning"
        $game_switches[DungeonMissions::Mon_Switch] = false
        $game_switches[DungeonMissions::Item_Switch] = true
      end
    end
    return text
  end

  def reward_is_item?(location)
    loc = 0
    for i in @locations
        break if i == location
        loc += 1
      end
    return true if @name[loc] == ("Dungeon of Support" || "Dungeon of Learning")
    return false
  end

  def reward_is_pokemon?(location)
    loc = 0
    for i in @locations
        break if i == location
        loc += 1
      end
    return true if @name[loc] == ("Dungeon of Life" || "Dungeon of Experiments")
    return false
  end

  def target_floor(stars)
    case stars
    when 1
      ret = rand(3) + 1
    when 2
      ret = rand(5) + 1
    when 3
      ret = rand(8) + 1
    when 4
      ret = rand(11) + 1
    when 5
      ret = rand(15) + 1
    else
      ret = 0
    end
    return ret
  end

  def star_floor(location)
    loc = -1
    for i in @locations
      loc += 1
      if i == location
        stars = loc == -1 ? @mission_data[location][:stars] : @stars[loc]
      end
    end
    case stars
    when 1
      ret = 3
    when 2
      ret = 5
    when 3
      ret = 8
    when 4
      ret = 11
    when 5
      ret = 15
    else
      ret = 0
    end
    return ret
  end

  def target(location)
    loc = 0
    for i in @locations
      break if i == location
      loc += 1
    end
    return @target[loc]
  end

  def randomize_all_dungeons
    clear_dungeon_data
    for location in valid_locations
      @locations.push(location)
      if rand(100) > 30
        name = dungeon_randomizer
        @name.push(name)
        stars = randomize_stars
        @stars.push(stars)
      else
        name = nil
        stars = 0
        @name.push(name)
        @stars.push(stars)
      end
    end
    @dungeon_reward = randomize_rewards
    $game_variables[DungeonMissions::Locations] = @locations
    $game_variables[DungeonMissions::Name] = @name
    $game_variables[DungeonMissions::Stars] = @stars
    $game_variables[DungeonMissions::Reward] = @dungeon_reward
    $game_variables[DungeonMissions::Steps] = @steps
    PBAI.log("Dungeons randomized...")
  end

  def refresh_sprite
    target = $game_variables[DungeonMissions::Specific_Target]
    if target == 0
      first_pkmn = GameData::Species.get(dungeon_reward($game_map.map_id))
      pkmn = Pokemon.new(first_pkmn,1)
      change_sprite([pkmn.species, pkmn.form,
            pkmn.gender, pkmn.shiny?,
            pkmn.shadowPokemon?])
    elsif target.is_a?(Symbol)
      first_pkmn = GameData::Species.get(target)
      pkmn = Pokemon.new(first_pkmn,1)
      change_sprite([pkmn.species, pkmn.form,
            pkmn.gender, pkmn.shiny?,
            pkmn.shadowPokemon?])
    else
      $game_map.events.each_with_index do |event, i|
        next if event[1].name != "MissionTarget"
        fname = target[0]
        fname.gsub!("Graphics/Characters/","")
        event[1].character_name = fname
      end
    end
  end

  def change_sprite(params)
    $game_map.events.each_with_index do |event,i|
      next if event[1].name != "DungeonReward"
      fname = GameData::Species.ow_sprite_filename(params[0], params[1],
                                                   params[2], params[3],
                                                   params[4])
      fname.gsub!("Graphics/Characters/","")
      event[1].character_name = fname
    end
  end

  def entrance(location)
    if $game_switches[68]
      $game_switches[926] = reward_is_pokemon?($game_map.map_id)
      $game_switches[927] = reward_is_item?($game_map.map_id)
      $game_variables[74] = stars(location)
      $game_variables[DungeonMissions::Floor] = star_floor(location)
      if @mission_data.has_key?(location)
        $game_variables[DungeonMissions::Floor_Target] = @mission_data[location][:floor]
        $game_variables[DungeonMissions::Specific_Target] = @mission_data[location][:target]
        $game_variables[DungeonMissions::Target_Location] = location
      end
    end
  end

  def close(location)
    temp = []
    $game_self_switches[[location,2,"A"]] = false
    $game_self_switches[[location,4,"A"]] = false
    loc = 0
    for loc in reward_locations
      break if loc == location
      loc += 1
    end
    $game_variables[74] = 3
    $game_variables[DungeonMissions::Floor] = 0
    $game_variables[DungeonMissions::Floor_Target] = 0
    if @mission_data[pbGet(222)][:complete] == false
      lose_reputation(@mission_data[pbGet(222)][:stars])
      @mission_data.each_key do |key|
        next if @mission_data[key][:id] == @mission_data[pbGet(222)][:id]
        temp[key] = @mission_data[key]
      end
      @mission_data = temp
    end
    @name[loc] = nil
  end
end


def dungeon_randomizer
  dungeon = rand(100)
  rep_wartime = $game_system.reputation > 300 ? 10 : 5
  rep_learning = rep_wartime + 10
  rep_support = rep_learning + 10
  rep_norm = $game_system.reputation > 300 ? 70 : 75
  if dungeon < rep_wartime
    name = "Dungeon of Experiments"
  elsif dungeon >= rep_wartime && dungeon < rep_learning
    name = "Dungeon of Learning"
  elsif dungeon >= rep_learning && dungeon < rep_support
    name = "Dungeon of Support"
  elsif dungeon >= rep_support
    name = "Dungeon of Life"
  end
  return name
end

def dungeon_battle(location)
  pbSetField(:EchoChamber)
  level = $dungeon.reward_stars(location) * 10
  return pbWildBattle($dungeon.dungeon_reward(location),level)
end

def dungeon_item(location)
  return pbItemBall($dungeon.dungeon_reward(location),1)
end

$dungeon = Dungeon_Missions.mission_data == nil ? Dungeon_Missions.new : Dungeon_Missions.setup

module GameData
  class Species
    def self.ow_sprite_filename(species, form = 0, gender = 0, shiny = false, shadow = false)
      ret = self.check_graphic_file("Graphics/Characters/", species, form,
                                    gender, shiny, shadow, nil)
      ret = "Graphics/Characters/Followers/000" if nil_or_empty?(ret)
      return ret
    end
  end
end