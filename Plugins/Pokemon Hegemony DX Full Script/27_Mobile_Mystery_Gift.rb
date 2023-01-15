module Mobile_MG
  Swablu = {
    :id => 1,
    :Type => "Pokemon",
    :Level => 5,
    :Stats => [:HP,:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED],
    :Item => :WALTARIANITE,
    :Nature => :TIMID,
    :Ability => rand(3),
    :Egg_Move => true,
    :Gift => :SWABLU2
  }
  Pikachu = {
    :id => 2,
    :Type => "Pokemon",
    :Level => 5,
    :Stats => [:HP,:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED],
    :Item => :LIGHTBALL,
    :Nature => :HASTY,
    :Ability => 0,
    :Egg_Move => true,
    :Gift => :PIKACHU2
  }
  DeepFreeze = {
    :id => 3,
    :Type => "Item",
    :Gift => :TM134
  }
  CosmicPower = {
    :id => 4,
    :Type => "Item",
    :Gift => :TM244
  }
  IronHead = {
    :id => 5,
    :Type => "Item",
    :Gift => :TM274
  }
  AllySwitch = {
    :id => 6,
    :Type => "Item",
    :Gift => :TM283
  }
  WillOWisp = {
    :id => 7,
    :Type => "Item",
    :Gift => :TM38
  }
end

def get_mobile_mystery_gift(gift)
  if !gift.is_a?(Symbol)
    raise _INTL("The 'gift' argument should be a symbol, e.g. ':Swablu'.")
  end
  id = Mobile_MG.const_get(gift)[:id]
  type = Mobile_MG.const_get(gift)[:Type]
  mg = Mobile_MG.const_get(gift)[:Gift]
  case type
  when "Pokemon"
    stats = Mobile_MG.const_get(gift)[:Stats]
    item = Mobile_MG.const_get(gift)[:Item]
    level = Mobile_MG.const_get(gift)[:Level]
    ability = Mobile_MG.const_get(gift)[:Ability]
    nature = Mobile_MG.const_get(gift)[:Nature]
    egg = Mobile_MG.const_get(gift)[:Egg_Move]
    stat_length = stats.length-1
    move = GameData::Species.get(mg).egg_moves
    pkmn = pbGenPkmn(mg,level)
    for i in 0..stat_length
      pkmn.iv[stats[i]] = 31
    end
    pkmn.nature = nature
    pkmn.item = item
    pkmn.ability_index = ability
    if egg == true
      pkmn.learn_move(move[rand(move.length)])
    end
    pbAddPokemon(pkmn)
  when "Item"
    pbReceiveItem(mg)
  end
end
