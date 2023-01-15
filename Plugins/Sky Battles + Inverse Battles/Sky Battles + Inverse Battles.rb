#-------------------------------------------------------------------------------
# Sky Battles + Inverse Battles
# Credit: mej71 (original), bo4p5687 (update)
#
#   If you want to set inverse battles, call: setBattleRule("inverseBattle")
#   If you want to set sky battles, call: setBattleRule("skyBattle")
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
module SkyBattle
  # Store pokemon can't battle (sky mode)
  # Pokemon aren't allowed to participate even though they are flying or have levitate
  # Add new pokemon: ':NAME'
  SkyPokemon = [
		:PIDGEY, :SPEAROW, :FARFETCHD, :DODUO, :DODRIO, :GENGAR, :HOOTHOOT, :NATU,
		:MURKROW, :DELIBIRD, :TAILLOW, :STARLY, :CHATOT, :SHAYMIN, :PIDOVE, :ARCHEN,
		:DUCKLETT, :RUFFLET, :VULLABY, :FLETCHLING, :HAWLUCHA
  ]
  
	# Store pokemon can battle (sky mode)
	# Pokemon are allowed to participate even though they aren't flying or haven't levitate
	# Add new pokemon: ':NAME'
	CanBattle = [
		# Example: :BULBASAUR
		# Add below this: 
		:RATTATA, :EKANS
	]

  def self.checkPkmnSky?(pkmn)
    list = []
    SkyPokemon.each { |species| list <<  GameData::Species.get(species).id }
    return true if list.include?(pkmn.species)
    return false
  end
  
	def self.checkExceptPkmn?(pkmn)
    list = []
    CanBattle.each { |species| list <<  GameData::Species.get(species).id }
    return true if list.include?(pkmn.species)
    return false
  end

  # Check pokemon in sky battle
	def self.canSkyBattle?(pkmn)
    checktype    = pkmn.hasType?(:FLYING)
    checkability = pkmn.hasAbility?(:LEVITATE)
    checkpkmn    = SkyBattle.checkPkmnSky?(pkmn)
    except       = SkyBattle.checkExceptPkmn?(pkmn)
    return ( (checktype || checkability) && !checkpkmn ) || except
  end
  
  # Store move pokemon can't use (sky mode)
  # Add new move: ':MOVE'
  SkyMove = [
		:BODYSLAM, :BULLDOZE, :DIG, :DIVE, :EARTHPOWER, :EARTHQUAKE, :ELECTRICTERRAIN,
		:FISSURE, :FIREPLEDGE, :FLYINGPRESS, :FRENZYPLANT, :GEOMANCY, :GRASSKNOT,
		:GRASSPLEDGE, :GRASSYTERRAIN, :GRAVITY, :HEATCRASH, :HEAVYSLAM, :INGRAIN, 
		:LANDSWRATH, :MAGNITUDE, :MATBLOCK, :MISTYTERRAIN, :MUDSPORT, :MUDDYWATER,
		:ROTOTILLER, :SEISMICTOSS, :SLAM, :SMACKDOWN, :SPIKES, :STOMP, :SUBSTITUTE,
		:SURF, :TOXICSPIKES, :WATERPLEDGE, :WATERSPORT
  ]
  
  def self.checkMoveSky?(id)
    list = []
    SkyMove.each { |moves| list << GameData::Move.get(moves).id }
    return true if list.include?(id)
    return false
  end
end
#-------------------------------------------------------------------------------
# Set rules
#-------------------------------------------------------------------------------
class PokemonTemp
  alias sky_inverse_battle_rule recordBattleRule
  def recordBattleRule(rule,var=nil)
    rules = self.battleRules
    case rule.to_s.downcase
    when "skybattle";     rules["skyBattle"] = true
    when "inversebattle"; rules["inverseBattle"] = true
    else; sky_inverse_battle_rule(rule,var)
    end
  end
end
#-------------------------------------------------------------------------------
# Set type for 'inverse'
#-------------------------------------------------------------------------------
module GameData
	class Type
		alias inverse_effect effectiveness
		def effectiveness(other_type)
			return Effectiveness::NORMAL_EFFECTIVE_ONE if !other_type
			ret = inverse_effect(other_type)
			if $inverse
				case ret
				when 0, 1; ret = 4
				when 4;    ret = 1
				end
			end
			return ret
		end
	end
end
$inverse = false
# Set rule 'inverse'
Events.onStartBattle += proc { |_sender| $inverse = true if $PokemonTemp.battleRules["inverseBattle"] }
Events.onEndBattle += proc { |_sender,e| $inverse = false }
#-------------------------------------------------------------------------------
# Set value
$skybattle = false
class PokeBattle_Battle
  alias sky_choose_move pbCanChooseMove?
  def pbCanChooseMove?(idxBattler,idxMove,showMessages,sleepTalk=false)
    ret = sky_choose_move(idxBattler,idxMove,showMessages)
    battler = @battlers[idxBattler]
    move = battler.moves[idxMove]
    # Check move
    if ret && $skybattle && SkyBattle.checkMoveSky?(move.id)
      pbDisplayPaused(_INTL("{1} can't use in a sky battle!",move.name)) if showMessages
      return false
    end
    return ret
  end
end
# Set when finish battle
Events.onEndBattle += proc { |_sender,e| $skybattle = false if $skybattle }
#-------------------------------------------------------------------------------
# Set wild battle
#-------------------------------------------------------------------------------
def pbWildBattleCore(*args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $Trainer.able_pokemon_count==0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $Trainer.pokemonCount>0
    pbSet(outcomeVar,1)   # Treat it as a win
    $PokemonTemp.clearBattleRules
    $PokemonGlobal.nextBattleBGM       = nil
    $PokemonGlobal.nextBattleME        = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack      = nil
		pbMEStop
    return 1   # Treat it as a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  Events.onStartBattle.trigger(nil)
  # Generate wild Pokémon based on the species and level
  foeParty = []
  sp = nil
  for arg in args
    if arg.is_a?(Pokemon)
      foeParty.push(arg)
    elsif arg.is_a?(Array)
      species = GameData::Species.get(arg[0]).id
      pkmn = pbGenerateWildPokemon(species,arg[1])
      foeParty.push(pkmn)
    elsif sp
      species = GameData::Species.get(sp).id
      pkmn = pbGenerateWildPokemon(species,arg)
      foeParty.push(pkmn)
      sp = nil
    else
      sp = arg
    end
  end
  raise _INTL("Expected a level after being given {1}, but one wasn't found.",sp) if sp
  # Sky battle
  if $PokemonTemp.battleRules["skyBattle"]
    count = 0
    foeParty.each { |p| count+=1 if SkyBattle.canSkyBattle?(p) }
    if count==0
      pbMessage(_INTL("There are pokemons who can't fight in a sky battle!"))
      pbSet(outcomeVar,1)   # Treat it as a win
      return 1 # Treat it as a win
    else
      fakeParty = foeParty
      foeParty = []
      fakeParty.each { |p| foeParty << p if p && SkyBattle.canSkyBattle?(p)}
    end
  end
  # Calculate who the trainers and their party are
  playerTrainers    = [$Trainer]
  playerParty       = $Trainer.party
  # Sky battle
  if $PokemonTemp.battleRules["skyBattle"]
    count = 0
    playerParty.each { |p| count+=1 if p && !p.egg? && !p.fainted? && SkyBattle.canSkyBattle?(p)}
    if count==0
      pbMessage(_INTL("You don't have any eligible pokemon for a sky battle"))
      pbSet(outcomeVar,1)   # Treat it as a win
      return 1 # Treat it as a win
    else
      fakeParty = playerParty
      playerParty = []
      fakeParty.each { |p| playerParty << p if p && !p.egg? && !p.fainted? && SkyBattle.canSkyBattle?(p) }
    end
  end
  playerPartyStarts = [0]
  room_for_partner = (foeParty.length > 1)
  if !room_for_partner && $PokemonTemp.battleRules["size"] &&
     !["single", "1v1", "1v2", "1v3"].include?($PokemonTemp.battleRules["size"])
    room_for_partner = true
  end
  if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && room_for_partner
    ally = NPCTrainer.new($PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    ally.id    = $PokemonGlobal.partner[2]
    ally.party = $PokemonGlobal.partner[3]
    # Sky battle
    if $PokemonTemp.battleRules["skyBattle"]
      count = 0
      ally.party.each { |p| count+=1 if p && !p.egg? && !p.fainted? && SkyBattle.canSkyBattle?(p) }
      if count==0
        pbMessage(_INTL("The partner don't have any eligible pokemon for a sky battle"))
        pbSet(outcomeVar,1)   # Treat it as a win
        return 1   # Treat it as a win
      else
        fakeParty = ally.party
        ally.party = []
        fakeParty.each { |p| ally.party << p if p && !p.egg? && !p.fainted? && SkyBattle.canSkyBattle?(p) }
      end
    end 
    playerTrainers.push(ally)
    playerParty = []
		if $PokemonTemp.battleRules["skyBattle"]
			$Trainer.party.each { |p| playerParty << p if p && !p.egg? && !p.fainted? && SkyBattle.canSkyBattle?(p) }
		else
			$Trainer.party.each { |pkmn| playerParty.push(pkmn) }
		end
    playerPartyStarts.push(playerParty.length)
    ally.party.each { |pkmn| playerParty.push(pkmn) }
    setBattleRule("double") if !$PokemonTemp.battleRules["size"]
  end
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = PokeBattle_Battle.new(scene,playerParty,foeParty,playerTrainers,nil)
  battle.party1starts = playerPartyStarts
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  # Sky battle
  # Set true for sky mode
  $skybattle = true if $PokemonTemp.battleRules["skyBattle"]
  $PokemonTemp.clearBattleRules
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(foeParty),(foeParty.length==1) ? 0 : 2,foeParty) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterBattle(decision,canLose)
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    4 - Wild Pokémon was caught
  #    5 - Draw
  pbSet(outcomeVar,decision)
  return decision
end
#-------------------------------------------------------------------------------
# Set trainer battle
#-------------------------------------------------------------------------------
def pbTrainerBattleCore(*args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $Trainer.able_pokemon_count==0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    pbMessage(_INTL("AFTER WINNING...")) if $DEBUG && $Trainer.able_pokemon_count>0
    pbSet(outcomeVar,($Trainer.able_pokemon_count==0) ? 0 : 1)   # Treat it as undecided/a win
    $PokemonTemp.clearBattleRules
    $PokemonGlobal.nextBattleBGM       = nil
    $PokemonGlobal.nextBattleME        = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack      = nil
		pbMEStop
    return ($Trainer.able_pokemon_count==0) ? 0 : 1   # Treat it as undecided/a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  Events.onStartBattle.trigger(nil)
  # Generate trainers and their parties based on the arguments given
  foeTrainers    = []
  foeItems       = []
  foeEndSpeeches = []
  foeParty       = []
  foePartyStarts = []
  for arg in args
    if arg.is_a?(NPCTrainer)
      foeTrainers.push(arg)
      foePartyStarts.push(foeParty.length)
      arg.party.each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(arg.lose_text)
      foeItems.push(arg.items)
    elsif arg.is_a?(Array)   # [trainer type, trainer name, ID, speech (optional)]
      trainer = pbLoadTrainer(arg[0],arg[1],arg[2])
      pbMissingTrainer(arg[0],arg[1],arg[2]) if !trainer
      return 0 if !trainer
      Events.onTrainerPartyLoad.trigger(nil,trainer)
      foeTrainers.push(trainer)
      foePartyStarts.push(foeParty.length)
      trainer.party.each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(arg[3] || trainer.lose_text)
      foeItems.push(trainer.items)
    else
      raise _INTL("Expected NPCTrainer or array of trainer data, got {1}.", arg)
    end
  end
  # Sky battle
  if $PokemonTemp.battleRules["skyBattle"]
    count = 0
    foeParty.each { |p| count+=1 if SkyBattle.canSkyBattle?(p) }
    if count==0
      pbMessage(_INTL("The opponents don't have any eligible pokemon for a sky battle"))
      pbSet(outcomeVar,1)   # Treat it as a win
      return 1   # Treat it as a win
    else
      fakeParty = foeParty
      foeParty = []
      fakeParty.each { |p| foeParty << p if p && SkyBattle.canSkyBattle?(p) }
    end
  end
  # Calculate who the player trainer(s) and their party are
  playerTrainers    = [$Trainer]
  playerParty       = $Trainer.party
  # Sky battle
  if $PokemonTemp.battleRules["skyBattle"]
    count = 0
    $Trainer.party.each { |p| count+=1 if p && !p.egg? && !p.fainted? && SkyBattle.canSkyBattle?(p)}
    if count==0
      pbMessage(_INTL("You don't have any eligible pokemon for a sky battle"))
      pbSet(outcomeVar,1)   # Treat it as a win
      return 1   # Treat it as a win
    else
      fakeParty = playerParty
      playerParty = []
      fakeParty.each { |p| playerParty << p if p && !p.egg? && !p.fainted? && SkyBattle.canSkyBattle?(p) }
    end
  end
  playerPartyStarts = [0]
  room_for_partner = (foeParty.length > 1)
  if !room_for_partner && $PokemonTemp.battleRules["size"] &&
     !["single", "1v1", "1v2", "1v3"].include?($PokemonTemp.battleRules["size"])
    room_for_partner = true
  end
  if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && room_for_partner
    ally = NPCTrainer.new($PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    ally.id    = $PokemonGlobal.partner[2]
    ally.party = $PokemonGlobal.partner[3]
    # Sky battle
    if $PokemonTemp.battleRules["skyBattle"]
      count = 0
      ally.party.each { |p| count+=1 if p && !p.egg? && !p.fainted? && SkyBattle.canSkyBattle?(p) }
      if count==0
        pbMessage(_INTL("The partner don't have any eligible pokemon for a sky battle"))
        pbSet(outcomeVar,1)   # Treat it as a win
        return 1   # Treat it as a win
      else
        fakeParty = ally.party
        ally.party = []
        fakeParty.each { |p| ally.party << p if p && !p.egg? && !p.fainted? && SkyBattle.canSkyBattle?(p) }
      end
    end
    playerTrainers.push(ally)
    playerParty = []
    if $PokemonTemp.battleRules["skyBattle"]
			$Trainer.party.each { |p| playerParty << p if p && !p.egg? && !p.fainted? && SkyBattle.canSkyBattle?(p) }
		else
			$Trainer.party.each { |pkmn| playerParty.push(pkmn) }
		end
    playerPartyStarts.push(playerParty.length)
    ally.party.each { |pkmn| playerParty.push(pkmn) }
    setBattleRule("double") if !$PokemonTemp.battleRules["size"]
  end
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = PokeBattle_Battle.new(scene,playerParty,foeParty,playerTrainers,foeTrainers)
  battle.party1starts = playerPartyStarts
  battle.party2starts = foePartyStarts
  battle.items        = foeItems
  battle.endSpeeches  = foeEndSpeeches
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  # Sky battle
  # Set true for sky mode
  $skybattle = true if $PokemonTemp.battleRules["skyBattle"]
  $PokemonTemp.clearBattleRules
  # End the trainer intro music
  Audio.me_stop
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetTrainerBattleBGM(foeTrainers),(battle.singleBattle?) ? 1 : 3,foeTrainers) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterBattle(decision,canLose)
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    5 - Draw
  pbSet(outcomeVar,decision)
  return decision
end