def grass_starter_eggs
  egg_list = [:BULBASAUR,:CHIKORITA,:TREECKO,:TURTWIG,:SNIVY,:CHESPIN,:ROWLET,:GROOKEY,:SPRIGATITO]
  eggs = []
  pbEachPokemon { |poke,_box|
    mon = poke.species
    evo = GameData::Species.get(mon).get_baby_species
    evos = GameData::Species.get(evo).get_family_evolutions
    eggs.push(evos)
  }
  eggs.flatten!
  eggs.uniq!
  eggs.each do |e|
    if egg_list.include?(e)
      egg_list.delete(e)
    end
  end
  return egg_list
end

def fire_starter_eggs
  egg_list = [:CHARMANDER,:CYNDAQUIL,:TORCHIC,:CHIMCHAR,:TEPIG,:FENNEKIN,:LITTEN,:SCORBUNNY,:FUECOCO]
  eggs = []
  pbEachPokemon { |poke,_box|
    mon = poke.species
    evo = GameData::Species.get(mon).get_baby_species
    evos = GameData::Species.get(evo).get_family_evolutions
    eggs.push(evos)
  }
  eggs.flatten!
  eggs.uniq!
  eggs.each do |e|
    if egg_list.include?(e)
      egg_list.delete(e)
    end
  end
  return egg_list
end

def water_starter_eggs
  egg_list = [:SQUIRTLE,:TOTODILE,:MUDKIP,:PIPLUP,:OSHAWOTT,:FROAKIE,:POPPLIO,:SOBBLE,:QUAXLY]
  eggs = []
  pbEachPokemon { |poke,_box|
    mon = poke.species
    evo = GameData::Species.get(mon).get_baby_species
    evos = GameData::Species.get(evo).get_family_evolutions
    eggs.push(evos)
  }
  eggs.flatten!
  eggs.uniq!
  eggs.each do |e|
    if egg_list.include?(e)
      egg_list.delete(e)
    end
  end
  return egg_list
end

def grass_starter_egg_vendor
  egg_list = [:BULBASAUR,:CHIKORITA,:TREECKO,:TURTWIG,:SNIVY,:CHESPIN,:ROWLET,:GROOKEY,:SPRIGATITO]
  return egg_list
end

def fire_starter_egg_vendor
  egg_list = [:CHARMANDER,:CYNDAQUIL,:TORCHIC,:CHIMCHAR,:TEPIG,:FENNEKIN,:LITTEN,:SCORBUNNY,:FUECOCO]
  return egg_list
end

def water_starter_egg_vendor
  egg_list = [:SQUIRTLE,:TOTODILE,:MUDKIP,:PIPLUP,:OSHAWOTT,:FROAKIE,:POPPLIO,:SOBBLE,:QUAXLY]
  return egg_list
end

def hisui_eggs
  egg_list = [:CYNDAQUIL,:ROWLET,:OSHAWOTT,:QWILFISH,:SNEASEL,:GOOMY,:BERGMITE,:PETILIL,:ZORUA,:GROWLITHE,:VOLTORB,:RUFFLET,:BASCULIN]
  eggs = []
  pbEachPokemon { |poke,_box|
    mon = poke.species
    evo = GameData::Species.get(mon).get_baby_species
    evos = GameData::Species.get(evo).get_family_evolutions
    eggs.push(evos)
  }
  eggs.flatten!
  eggs.uniq!
  eggs.each do |e|
    if egg_list.include?(e)
      egg_list.delete(e)
    end
  end
  if egg_list == []
    egg_list = [:CYNDAQUIL,:ROWLET,:OSHAWOTT,:QWILFISH,:SNEASEL,:GOOMY,:BERGMITE,:PETILIL,:ZORUA,:GROWLITHE,:VOLTORB,:RUFFLET,:BASCULIN]
  end
  return egg_list
end

def random_eggs
  egg_list = [:MILCERY,:SKITTY,:GULPIN,:FLABEBE,:AZURILL,:MAREANIE,:SNEASEL,:TEDDIURSA,:TOXEL,:CUBONE,:DARUMAKA,:MIMEJR,:MEOWTH,:PONYTA,:CORSOLA,:FARFETCHD,:GEODUDE,:ROLYCOLY,:SKIDDO,:KLINK,:STANTLER,:PICHU,:MAGBY,:ELEKID,:SMOOCHUM,:HAPPINY,:MUNCHLAX,:POIPOLE,:COSMOG,:PHIONE,:KUBFU,:LARVESTA,:SIZZLIPEDE,:SILICOBRA,:MAGNEMITE,:CARBINK,:AUDINO,:RALTS,:ABRA,:GASTLY,:DROWZEE,:ELGYEM,:BRONZOR,:MUNNA,:IMPIDIMP,:INDEEDEE,:PINCURCHIN,:PYUKUMUKU,:WYNAUT,:SCRAGGY,:SEEL,:HORSEA,:JIGGLYPUFF,:MANKEY,:SEVIPER,
  :ZANGOOSE,:SNUBBULL,:MAREEP,:GIRAFARIG,:DUNSPARCE,:CHINGLING,:SNORUNT,:SPHEAL,:BUIZEL,:FINNEON,:ARROKUDA,:MORELULL,:FOMANTIS,:INKAY,:COTTONEE,:MISDREAVUS,:MURKROW,:FEEBAS,:GOTHITA,:SOLOSIS,:STUNFISK,:PIKIPEK,:EMOLGA,:PLUSLE,:MINUN,:TOGEDEMARU,:MORPEKO,:VOLBEAT,:ILLUMISE,:ODDISH,:BELLSPROUT,:IGGLYBUFF,:CLEFFA,:PICHU,:STARYU,:GRIMER,:KOFFING,:LAPRAS,:ZUBAT,:NATU,:BONSLY,:WEEDLE,:CATERPIE,:WAILMER,:SHELMET,:KARRABLAST,:SCYTHER,:BARBOACH,:LUVDISC,:DEDENNE,:MINIOR,:CLOBBOPUS,:CRABRAWLER,:KRABBY,
  :SKORUPI,:FOMANTIS,:DEWPIDER,:BUNEARY,:TYNAMO,:DELIBIRD,:REMORAID,:WOOLOO,:NICKIT,:SKWOVET,:DHELMISE,:EKANS,:CRYOGONAL,:CUBCHOO,:WISHIWASHI,:DEINO,:TRAPINCH,:BELDUM,:BAGON,:LARVITAR,:DRATINI,:EEVEE,:GIBLE,:NOIBAT,:JANGMOO,:DREEPY,:RIOLU,:TYROGUE,:CROAGUNK,:GLIGAR,:HATENNA,:ZIGZAGOON,:ROOKIDEE,:JOLTIK,:WOOPER,
  :TAROUNTULA,:LECHONK,:FIDOUGH,:GIMMIGHOUL,:TAUROS,:MILTANK,:BOUFFALANT,:FRIGIBAX,:FLITTLE,:TOEDSCOOL,:WIGLETT,:DONDOZO,:TATSUGIRI,:VELUZA,:TADBULB,:PAWMI,:FLAMIGO,:MASCHIFF,:GREAVARD,:PAWNIARD,:SMOLIV,:NYMBLE,:BOMBIRDIER,:KLAWF,:ORTHWORM,:CAPSAKID,:GLIMMET,:VAROOM,:BRAMBLIN,:WATTREL,:SHROODLE,:CYCLIZAR,:TINKATINK,:TANDEMAUS,:RELLOR,:FINIZEN,:NACLI,:CETODDLE]
  eggs = []
  pbEachPokemon { |poke,_box|
    mon = poke.species
    evo = GameData::Species.get(mon).get_baby_species
    evos = GameData::Species.get(evo).get_family_evolutions
    eggs.push(evos)
  }
  eggs.flatten!
  eggs.uniq!
  eggs.each do |e|
    if egg_list.include?(e)
      egg_list.delete(e)
    end
  end
  return egg_list
end

def wartime_eggs
  egg_list = [
    :GROWLITHE2,
    :DRIFLOON2,
    :DREEPY2,
    :GIBLE2,
    :CARVANHA2,
    :TREECKO2,
    :TORCHIC2,
    :MUDKIP2,
    :FINNEON2
  ]
  eggs = []
  pbEachPokemon { |poke,_box|
    mon = poke.species
    evo = GameData::Species.get(mon).get_baby_species
    evos = GameData::Species.get(evo).get_family_evolutions
    eggs.push(evos)
  }
  eggs.flatten!
  eggs.uniq!
  eggs.each do |e|
    if egg_list.include?(e)
      egg_list.delete(e)
    end
  end
  if egg_list == []
    egg_list = [
      :GROWLITHE2,
      :DRIFLOON2,
      :DREEPY2,
      :GIBLE2,
      :CARVANHA2,
      :TREECKO2,
      :TORCHIC2,
      :MUDKIP2,
      :FINNEON2
    ]
  end
  return egg_list
end

def postgame_wartime_eggs
  egg_list = [
    :MAGNEMITE2,
    :FERROSEED2,
    :IMPIDIMP2,
    :ARON2,
    :SNORUNT2,
    :TURTWIG2,
    :CHIMCHAR2,
    :PIPLUP2
  ]
  eggs = []
  pbEachPokemon { |poke,_box|
    mon = poke.species
    evo = GameData::Species.get(mon).get_baby_species
    evos = GameData::Species.get(evo).get_family_evolutions
    eggs.push(evos)
  }
  eggs.flatten!
  eggs.uniq!
  eggs.each do |e|
    if egg_list.include?(e)
      egg_list.delete(e)
    end
  end
  if egg_list == []
    egg_list = [
      :MAGNEMITE2,
      :DEINO2,
      :FERROSEED2,
      :IMPIDIMP2,
      :TURTWIG2,
      :CHIMCHAR2,
      :PIPLUP2
    ]
  end
  return egg_list
end

def generate_hisui_egg
  rand = rand(hisui_eggs.length)
  egg = hisui_eggs[rand]
  if pbGenerateEgg(egg,_I("Random Hiker"))
    pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
    egg = $Trainer.last_party
    species = egg.species
    move = GameData::Species.get(species).egg_moves
    egg.ability_index = 2
    egg.form = (species == :BASCULIN) ? 2 : 1
    egg.iv[:HP] = 31
    egg.iv[:DEFENSE] = 31
    egg.iv[:SPECIAL_DEFENSE] = 31
    egg.learn_move(move[rand(move.length)])
    egg.steps_to_hatch = 200
    egg.calc_stats
    vTSS(@event_id,"A")
  else
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
  end
end

def generate_wartime_egg
  rand = rand(wartime_eggs.length)
  egg = wartime_eggs[rand]
  if pbGenerateEgg(egg,_I("Random Hiker"))
    pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
    egg = $Trainer.last_party
    species = egg.species
    move = GameData::Species.get(species).egg_moves
    egg.ability_index = 2
    egg.iv[:HP] = 31
    egg.iv[:DEFENSE] = 31
    egg.iv[:SPECIAL_DEFENSE] = 31
    egg.learn_move(move[rand(move.length)])
    egg.steps_to_hatch = 200
    egg.calc_stats
    vTSS(@event_id,"A")
  else
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
  end
end

def generate_postgame_wartime_egg
  rand = rand(postgame_wartime_eggs.length)
  egg = postgame_wartime_eggs[rand]
  if pbGenerateEgg(egg,_I("Random Hiker"))
    pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
    egg = $Trainer.last_party
    species = egg.species
    move = GameData::Species.get(species).egg_moves
    egg.ability_index = 2
    egg.iv[:HP] = 31
    egg.iv[:DEFENSE] = 31
    egg.iv[:SPECIAL_DEFENSE] = 31
    egg.learn_move(move[rand(move.length)])
    egg.steps_to_hatch = 200
    egg.calc_stats
    vTSS(@event_id,"A")
  else
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
  end
end

def generate_random_egg
  rand = rand(random_eggs.length)
  regionals = [:CUBONE,:DARUMAKA,:MEOWTH,:PONYTA,:CORSOLA,:FARFETCHD,:GEODUDE,:STUNFISK,:GRIMER,:KOFFING,:ZIGZAGOON,:WOOPER,:TAUROS]
  reg_rand = rand(10)
  egg = random_eggs[rand]
  if pbGenerateEgg(egg,_I("Random Hiker"))
    pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
    egg = $Trainer.last_party
    species = egg.species
    move = GameData::Species.get(species).egg_moves
    egg.ability_index = 2
    egg.form = regionals.include?(species) ? (reg_rand > 4 ? 1 : 0) : 0
    egg.iv[:HP] = 31
    egg.iv[:DEFENSE] = 31
    egg.iv[:SPECIAL_DEFENSE] = 31
    egg.learn_move(move[rand(move.length)])
    egg.steps_to_hatch = 200
    egg.calc_stats
    vTSS(@event_id,"A")
  else
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
  end
end

def generate_starter_egg(type)
  case type
  when :GRASS
    rand = rand(grass_starter_eggs.length)
    hisui_rand = rand(10)
    egg = grass_starter_eggs[rand]
    if pbGenerateEgg(egg,_I("Random Hiker"))
      pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
      egg = $Trainer.last_party
      species = egg.species
      move = GameData::Species.get(species).egg_moves
      egg.ability_index = 2
      if species == :ROWLET
        egg.form = hisui_rand>4 ? 1 : 0
      else
        egg.form = 0
      end
      egg.iv[:HP] = 31
      egg.iv[:DEFENSE] = 31
      egg.iv[:SPECIAL_DEFENSE] = 31
      egg.learn_move(move[rand(move.length)])
      egg.steps_to_hatch = 200
      egg.calc_stats
      vTSS(@event_id,"A")
    else
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
    end
  when :FIRE
    rand = rand(fire_starter_eggs.length)
    hisui_rand = rand(10)
    egg = fire_starter_eggs[rand]
    if pbGenerateEgg(egg,_I("Random Hiker"))
      pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
      egg = $Trainer.last_party
      species = egg.species
      move = GameData::Species.get(species).egg_moves
      egg.ability_index = 2
      if species == :CYNDAQUIL
        egg.form = hisui_rand>4 ? 1 : 0
      else
        egg.form = 0
      end
      egg.iv[:HP] = 31
      egg.iv[:DEFENSE] = 31
      egg.iv[:SPECIAL_DEFENSE] = 31
      egg.learn_move(move[rand(move.length)])
      egg.steps_to_hatch = 200
      egg.calc_stats
      vTSS(@event_id,"A")
    else
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
    end
  when :WATER
    rand = rand(water_starter_eggs.length)
    hisui_rand = rand(10)
    egg = water_starter_eggs[rand]
    if pbGenerateEgg(egg,_I("Random Hiker"))
      pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
      egg = $Trainer.last_party
      species = egg.species
      move = GameData::Species.get(species).egg_moves
      egg.ability_index = 2
      if species == :OSHAWOTT
        egg.form = hisui_rand>4 ? 1 : 0
      else
        egg.form = 0
      end
      egg.iv[:HP] = 31
      egg.iv[:DEFENSE] = 31
      egg.iv[:SPECIAL_DEFENSE] = 31
      egg.learn_move(move[rand(move.length)])
      egg.steps_to_hatch = 200
      egg.calc_stats
      vTSS(@event_id,"A")
    else
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
    end
  end
end

def generate_starter_egg_vendor(type)
  case type
  when :GRASS
    rand = rand(grass_starter_egg_vendor.length)
    hisui_rand = rand(10)
    egg = grass_starter_egg_vendor[rand]
    if pbGenerateEgg(egg,_I("Random Hiker"))
      pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
      egg = $Trainer.last_party
      species = egg.species
      move = GameData::Species.get(species).egg_moves
      egg.ability_index = 2
      egg.form = species != :ROWLET ? 0 : (hisui_rand > 4 ? 1 : 0)
      egg.iv[:HP] = 31
      egg.iv[:DEFENSE] = 31
      egg.iv[:SPECIAL_DEFENSE] = 31
      egg.learn_move(move[rand(move.length)])
      egg.steps_to_hatch = 200
      egg.calc_stats
      vTSS(@event_id,"A")
    else
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
    end
  when :FIRE
    rand = rand(fire_starter_egg_vendor.length)
    hisui_rand = rand(10)
    egg = fire_starter_egg_vendor[rand]
    if pbGenerateEgg(egg,_I("Random Hiker"))
      pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
      egg = $Trainer.last_party
      species = egg.species
      move = GameData::Species.get(species).egg_moves
      egg.ability_index = 2
      egg.form = species != :CYNDAQUIL ? 0 : (hisui_rand > 4 ? 1 : 0)
      egg.iv[:HP] = 31
      egg.iv[:DEFENSE] = 31
      egg.iv[:SPECIAL_DEFENSE] = 31
      egg.learn_move(move[rand(move.length)])
      egg.steps_to_hatch = 200
      egg.calc_stats
      vTSS(@event_id,"A")
    else
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
    end
  when :WATER
    rand = rand(water_starter_egg_vendor.length)
    hisui_rand = rand(10)
    egg = water_starter_egg_vendor[rand]
    if pbGenerateEgg(egg,_I("Random Hiker"))
      pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
      egg = $Trainer.last_party
      species = egg.species
      move = GameData::Species.get(species).egg_moves
      egg.ability_index = 2
      egg.form = species != :OSHAWOTT ? 0 : (hisui_rand > 4 ? 1 : 0)
      egg.iv[:HP] = 31
      egg.iv[:DEFENSE] = 31
      egg.iv[:SPECIAL_DEFENSE] = 31
      egg.learn_move(move[rand(move.length)])
      egg.steps_to_hatch = 200
      egg.calc_stats
      vTSS(@event_id,"A")
    else
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
    end
  end
end
