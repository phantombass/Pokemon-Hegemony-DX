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
end

class Dungeon_Missions
  attr_accessor :locations
  attr_accessor :name
  attr_accessor :target
  attr_accessor :stars
  attr_accessor :mission_data
  attr_accessor :dungeon_reward
  attr_accessor :steps

  def initialize
    @locations = []
    @name = []
    @target = []
    @stars = []
    @mission_data = []
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
  end

  def randomize(location)
    @locations.push(location)
    dungeon = rand(100)
    rep_wartime = $game_system.reputation > 300 ? 10 : 5
    rep_learning = rep_wartime + 10
    rep_support = rep_learning + 10
    if dungeon < rep_wartime
      name = "Dungeon of Experiments"
    elsif dungeon >= rep_wartime && dungeon < rep_learning
      name = "Dungeon of Learning"
    elsif dungeon >= rep_learning && dungeon < rep_support
      name = "Dungeon of Support"
    elsif dungeon >= rep_support
      name = "Dungeon of Life"
    end
    target = randomize_target
    stars = randomize_stars
    @target.push(target)
    @stars.push(stars)
    @name.push(name)
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
      end
    end
    return rewards
  end

  def dungeon_reward(location)
    loc = 0
    new_loc = []
    reward = [388,394,378]
    for i in reward
      break if i == location
      loc += 1
    end
    return @dungeon_reward[loc]
  end


  def valid_locations
    loc = [321,328,352]
    return loc
  end

  def location_names
    loc = [317,311,351]
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
    new_loc = []
    reward = [388,394,378]
    for i in reward
      break if i == location
      loc += 1
    end
    return @stars[loc]
  end

  def add_reputation(star)
    rep = $game_system.reputation
    add = ((((15/((rep/45)*1.75))).floor)*((0.4)*(2/star))).floor
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
    add = (((((15/((rep/45)*1.75))).floor)*((0.4)*(2/star)))*(star^2)).round
    add = 1 if add < 1
    $game_system.reputation -= add
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
    if @locations.nil? || !@locations.include?(location)
      text = "Dungeon Closed"
    else
      for i in @locations
        break if i == location
        loc += 1
      end
      name = @name[loc]
      stars = "Stars: #{@stars[loc]}"
      text = "#{name}\n#{stars}"
    end
    return text
  end

  def start
    data = []
    location = rand(self.valid_locations.length)
    location_name = location_names[location]
    self.randomize(location)
    map = pbLoadMapInfos
    map_name = map[location_name].name
    stars = self.stars(location)
    target = self.target(location)
    target_name = $game_variables[212] != 0 ? target[1] : GameData::Species.get(target).name
    reward = ((stars * 1000) * ($game_system.reputation/30)).floor
    data.push(target_name)
    data.push(map_name)
    data.push(reward)
    @mission_data.push(data)
    $game_variables[DungeonMissions::Data] = @mission_data
  end

  def randomize_target
    target = nil
    mons = [:MILCERY,:SKITTY,:GULPIN,:FLABEBE,:AZURILL,:MAREANIE,:SNEASEL,:TEDDIURSA,:TOXEL,:CUBONE,:DARUMAKA,:MIMEJR,:MEOWTH,:PONYTA,:CORSOLA,:FARFETCHD,:GEODUDE,:ROLYCOLY,:SKIDDO,:KLINK,:STANTLER,:PICHU,:MAGBY,:ELEKID,:SMOOCHUM,:HAPPINY,:MUNCHLAX,:POIPOLE,:COSMOG,:PHIONE,:KUBFU,:LARVESTA,:SIZZLIPEDE,:SILICOBRA,:MAGNEMITE,:CARBINK,:AUDINO,:RALTS,:ABRA,:GASTLY,:DROWZEE,:ELGYEM,:BRONZOR,:MUNNA,:IMPIDIMP,:INDEEDEE,:PINCURCHIN,:PYUKUMUKU,:WYNAUT,:SCRAGGY,:SEEL,:HORSEA,:JIGGLYPUFF,:MANKEY,:SEVIPER,
  :ZANGOOSE,:SNUBBULL,:MAREEP,:GIRAFARIG,:DUNSPARCE,:CHINGLING,:SNORUNT,:SPHEAL,:BUIZEL,:FINNEON,:ARROKUDA,:MORELULL,:FOMANTIS,:INKAY,:COTTONEE,:MISDREAVUS,:MURKROW,:FEEBAS,:GOTHITA,:SOLOSIS,:STUNFISK,:PIKIPEK,:EMOLGA,:PLUSLE,:MINUN,:TOGEDEMARU,:MORPEKO,:VOLBEAT,:ILLUMISE,:ODDISH,:BELLSPROUT,:IGGLYBUFF,:CLEFFA,:PICHU,:STARYU,:GRIMER,:KOFFING,:LAPRAS,:ZUBAT,:NATU,:BONSLY,:WEEDLE,:CATERPIE,:WAILMER,:SHELMET,:KARRABLAST,:SCYTHER,:BARBOACH,:LUVDISC,:DEDENNE,:MINIOR,:CLOBBOPUS,:CRABRAWLER,:KRABBY,
  :SKORUPI,:FOMANTIS,:DEWPIDER,:BUNEARY,:TYNAMO,:DELIBIRD,:REMORAID,:WOOLOO,:NICKIT,:SKWOVET,:DHELMISE,:EKANS,:CRYOGONAL,:CUBCHOO,:WISHIWASHI,:DEINO,:TRAPINCH,:BELDUM,:BAGON,:LARVITAR,:DRATINI,:EEVEE,:GIBLE,:NOIBAT,:JANGMOO,:DREEPY,:RIOLU,:TYROGUE,:CROAGUNK,:GLIGAR,:HATENNA,:ZIGZAGOON,:ROOKIDEE,:JOLTIK,:WOOPER,
  :TAROUNTULA,:LECHONK,:FIDOUGH,:GIMMIGHOUL,:TAUROS,:MILTANK,:BOUFFALANT,:FRIGIBAX,:FLITTLE,:TOEDSCOOL,:WIGLETT,:DONDOZO,:TATSUGIRI,:VELUZA,:TADBULB,:PAWMI,:FLAMIGO,:MASCHIFF,:GREAVARD,:PAWNIARD,:SMOLIV,:NYMBLE,:BOMBIRDIER,:KLAWF,:ORTHWORM,:CAPSAKID,:GLIMMET,:VAROOM,:BRAMBLIN,:WATTREL,:SHROODLE,:CYCLIZAR,:TINKATINK,:TANDEMAUS,:RELLOR,:FINIZEN,:NACLI,:CETODDLE]
    people = [["trainer_BUGCATCHER","Bug Catcher"],["trainer_GAMBLER","Grandpa"],["trainer_SAILOR","Sailor"],["trainer_SCIENTIST","Scientist"],["trainer_TUBER_F","little girl"],["trainer_TUBER_M","little boy"]]
    item = ["lost item","Lost Item"]
    r = rand(3)
    randMon = rand(mons.length)
    randPeople = rand(people.length)
    case r
    when 0; target = mons[randMon]
    when 1; target = people[randPeople]
    when 2; target = item
    end
    $game_variables[212] = r
    return target
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
    for location in valid_locations
      if rand(100) > 30
        @locations.push(location)
        dungeon = rand(100)
        rep_wartime = $game_system.reputation > 300 ? 10 : 5
        rep_learning = rep_wartime + 10
        rep_support = rep_learning + 10
        if dungeon < rep_wartime
          name = "Dungeon of Experiments"
        elsif dungeon >= rep_wartime && dungeon < rep_learning
          name = "Dungeon of Learning"
        elsif dungeon >= rep_learning && dungeon < rep_support
          name = "Dungeon of Support"
        elsif dungeon >= rep_support
          name = "Dungeon of Life"
        end
        @name.push(name)
        stars = randomize_stars
        @stars.push(stars)
      end
    end
    target = randomize_target
    @target.push(target)
    @dungeon_reward = randomize_rewards
    @steps = 256
    $game_variables[DungeonMissions::Locations] = @locations
    $game_variables[DungeonMissions::Name] = @name
    $game_variables[DungeonMissions::Target] = @target
    $game_variables[DungeonMissions::Stars] = @stars
    $game_variables[DungeonMissions::Data] = @mission_data
    $game_variables[DungeonMissions::Reward] = @dungeon_reward
    $game_variables[DungeonMissions::Steps] = @steps
    PBAI.log("Dungeons randomized...")
  end

  def refresh_sprite
    first_pkmn = target($game_map.map_id) == nil ? GameData::Species.get(dungeon_reward($game_map.map_id)) : GameData::Species.get(target($game_map.map_id))
    pkmn = Pokemon.new(first_pkmn,1)
    change_sprite([pkmn.species, pkmn.form,
          pkmn.gender, pkmn.shiny?,
          pkmn.shadowPokemon?])
  end

  def change_sprite(params)
    $game_map.events.each_with_index do |event,i|
      next if event[1].name != ("DungeonReward" || "MissionTarget")
      fname = GameData::Species.ow_sprite_filename(params[0], params[1],
                                                   params[2], params[3],
                                                   params[4])
      fname.gsub!("Graphics/Characters/","")
      event[i].character_name = fname
    end
  end
end


def dungeon_randomizer(location)
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
  loc = 0
  reward = [388,394,378]
  for i in reward
    break if i == location
    loc += 1
  end
  pbSetField(:EchoChamber)
  level = $dungeon.reward_stars(location) * 10
  return pbWildBattle($dungeon.dungeon_reward(location),level)
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