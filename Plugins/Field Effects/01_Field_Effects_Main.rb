#To set your field effects, do one of these:
#Set it to be set as a move or ability
#In a parallel process event on the map, use setBattleRule("defaultField",:FieldEffect)

module GameData
  class FieldEffects
    attr_reader :id
    attr_reader :real_name

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id        = hash[:id]
      @real_name = hash[:name] || "Unnamed"
    end

    # @return [String] the translated name of this field effect
    def name
      return _INTL(@real_name)
    end
  end
end

#Define all your Field Effects here

GameData::FieldEffects.register({
  :id   => :None,
  :name => _INTL("None")
})

GameData::FieldEffects.register({
  :id   => :Forest,
  :name => _INTL("Forest")
})

GameData::FieldEffects.register({
  :id   => :Cave,
  :name => _INTL("Cave")
})

#Define Environments to match your Field Effects here

GameData::Environment.register({
  :id          => :None,
  :name        => _INTL("None"),
  :battle_base => "grass_night"
})

module Fields
  sound = []
  pulse = []
  moves = load_data("Data/moves.dat")
  for move in moves
    next if move[0].is_a?(Integer)
    mv = move[1]
    sound.push(GameData::Move.get(mv).id) if mv.flags[/k/]
  end
  SOUND_MOVES = sound
  WIND_MOVES = [:AIRCUTTER,:HURRICANE,:AIRSLASH,:OMINOUSWIND,:HEATWAVE,:SILVERWIND,:AEROBLAST,:ICYWIND]
  IGNITE_MOVES = [:FLAMEBURST,:INCINERATE,:LAVAPLUME,:FLAMETHROWER,:MAGMATREK,:FLAREBLITZ,:FLAMEWHEEL,:ERUPTION]
  #These are examples of arrays you can make for moves that will affect or be affected by a field effect
end

class PokemonTemp
  def recordBattleRule(rule, var = nil)
    rules = self.battleRules
    case rule.to_s.downcase
    when "single", "1v1", "1v2", "2v1", "1v3", "3v1",
         "double", "2v2", "2v3", "3v2", "triple", "3v3"
      rules["size"] = rule.to_s.downcase
    when "canlose"                then rules["canLose"]             = true
    when "cannotlose"             then rules["canLose"]             = false
    when "canrun"                 then rules["canRun"]              = true
    when "cannotrun"              then rules["canRun"]              = false
    when "roamerflees"            then rules["roamerFlees"]         = true
    when "noexp"                  then rules["expGain"]             = false
    when "nomoney"                then rules["moneyGain"]           = false
    when "disablepokeballs"       then rules["disablePokeBalls"]    = true
    when "forcecatchintoparty"    then rules["forceCatchIntoParty"] = true
    when "switchstyle"            then rules["switchStyle"]         = true
    when "setstyle"               then rules["switchStyle"]         = false
    when "anims"                  then rules["battleAnims"]         = true
    when "noanims"                then rules["battleAnims"]         = false
    when "terrain"
      terrain_data = GameData::BattleTerrain.try_get(var)
      rules["defaultTerrain"] = (terrain_data) ? terrain_data.id : nil
    when "weather"
      weather_data = GameData::BattleWeather.try_get(var)
      rules["defaultWeather"] = (weather_data) ? weather_data.id : nil
    when "environment", "environ"
      environment_data = GameData::Environment.try_get(var)
      rules["environment"] = (environment_data) ? environment_data.id : nil
    when "field"
      field_data = GameData::FieldEffects.try_get(var)
      rules["defaultField"] = (field_data) ? field_data.id : nil
    when "backdrop", "battleback" then rules["backdrop"]            = var
    when "base"                   then rules["base"]                = var
    when "outcome", "outcomevar"  then rules["outcomeVar"]          = var
    when "nopartner"              then rules["noPartner"]           = true
    when "inversebattle"          then rules["inverseBattle"] = true
    else
      raise _INTL("Battle rule \"{1}\" does not exist.", rule)
    end
  	$game_screen.field_effects(rules["defaultfield"])
  	$PokemonGlobal.nextBattleBack = FIELD_EFFECTS[rules["defaultField"]][:field_gfx]
  end
  def pbPrepareBattle(battle)
    battleRules = $PokemonTemp.battleRules
    # The size of the battle, i.e. how many Pokémon on each side (default: "single")
    battle.setBattleMode(battleRules["size"]) if !battleRules["size"].nil?
    # Whether the game won't black out even if the player loses (default: false)
    battle.canLose = battleRules["canLose"] if !battleRules["canLose"].nil?
    # Whether the player can choose to run from the battle (default: true)
    battle.canRun = battleRules["canRun"] if !battleRules["canRun"].nil?
    # Whether wild Pokémon always try to run from battle (default: nil)
    battle.rules["alwaysflee"] = battleRules["roamerFlees"]
    # Whether Pokémon gain Exp/EVs from defeating/catching a Pokémon (default: true)
    battle.expGain = battleRules["expGain"] if !battleRules["expGain"].nil?
    # Whether the player gains/loses money at the end of the battle (default: true)
    battle.moneyGain = battleRules["moneyGain"] if !battleRules["moneyGain"].nil?
    # Whether the player is able to switch when an opponent's Pokémon faints
    battle.switchStyle = ($PokemonSystem.battlestyle == 0)
    battle.switchStyle = battleRules["switchStyle"] if !battleRules["switchStyle"].nil?
    # Whether battle animations are shown
    battle.showAnims = ($PokemonSystem.battlescene == 0)
    battle.showAnims = battleRules["battleAnims"] if !battleRules["battleAnims"].nil?
    # Terrain
    if battleRules["defaultTerrain"].nil?
      if Settings::SWSH_FOG_IN_BATTLES
        case $game_screen.weather_type
        when :Storm
          battle.defaultTerrain = :Electric
        when :Fog
          battle.defaultTerrain = :Misty
        end
      else
        battle.defaultTerrain = battleRules["defaultTerrain"]
      end
    end
    # Weather
    if battleRules["defaultWeather"].nil?
      case GameData::Weather.get($game_screen.weather_type).category
      when :Rain
        battle.defaultWeather = :Rain
      when :Hail
        battle.defaultWeather = :Hail
      when :Sandstorm
        battle.defaultWeather = :Sandstorm
      when :Sun
        battle.defaultWeather = :Sun
      when :Fog
        battle.defaultWeather = :Fog if !Settings::SWSH_FOG_IN_BATTLES
      end
    else
      battle.defaultWeather = battleRules["defaultWeather"]
    end
    if battleRules["defaultField"].nil?
      battle.defaultField = $game_screen.field_effects == nil ? :None : $game_screen.field_effects
    else
      battle.defaultField = battleRules["defaultField"]
    end
    # Environment
    if battleRules["environment"].nil?
      battle.environment = pbGetEnvironment
    else
      battle.environment = battleRules["environment"]
    end
    # Backdrop graphic filename
    if !battleRules["backdrop"].nil?
      backdrop = battleRules["backdrop"]
    elsif $PokemonGlobal.nextBattleBack
      backdrop = $PokemonGlobal.nextBattleBack
    elsif $PokemonGlobal.surfing
      backdrop = "water"   # This applies wherever you are, including in caves
    elsif GameData::MapMetadata.exists?($game_map.map_id)
      back = GameData::MapMetadata.get($game_map.map_id).battle_background
      backdrop = back if back && back != ""
    end
    backdrop = "indoor1" if !backdrop
    battle.backdrop = backdrop
    # Choose a name for bases depending on environment
    if battleRules["base"].nil?
      environment_data = GameData::Environment.try_get(battle.environment)
      base = environment_data.battle_base if environment_data
    else
      base = battleRules["base"]
    end
    battle.backdropBase = base if base
    # Time of day
    if GameData::MapMetadata.exists?($game_map.map_id) &&
       GameData::MapMetadata.get($game_map.map_id).battle_environment == :Cave
      battle.time = 2   # This makes Dusk Balls work properly in caves
    elsif Settings::TIME_SHADING
      timeNow = pbGetTimeNow
      if PBDayNight.isNight?(timeNow);      battle.time = 2
      elsif PBDayNight.isEvening?(timeNow); battle.time = 1
      else;                                 battle.time = 0
      end
    end
  end
end

def setBattleRule(*args)
  r = nil
  args.each do |arg|
    if r
      $game_temp.add_battle_rule(r, arg)
      r = nil
    else
      case arg.downcase
      when "terrain", "weather", "environment", "environ", "backdrop",
           "battleback", "base", "outcome", "outcomevar","field"
        r = arg
        next
      end
      $game_temp.add_battle_rule(arg)
    end
  end
  raise _INTL("Argument {1} expected a variable after it but didn't have one.", r) if r
end

class Game_Screen
  attr_reader   :field_effects
  alias initialize_field initialize
  def initialize
    initialize_field
    @field_effects = :None
  end
  def field_effect(type)
    @field_effects = GameData::FieldEffects.try_get(type).id
  end
end

class PokeBattle_ActiveField
  attr_accessor :defaultField
  attr_accessor :field_effects
  alias initialize_field initialize
  def initialize
    initialize_field
    @effects[PBEffects::EchoChamber] = 0
    default_field_effects = :None
    field_effects = :None
  end
end

class PokeBattle_Battle
	#Example method created to show a condition where a field change would fail
  def self.ignite?
    return false if @field.nil?
  	return false if [:Rain,:HeavyRain,:AcidRain].include?(@field.pbWeather)
  	return true
  end
  def pbSendOut(sendOuts, startBattle = false)
    sendOuts.each { |b| @peer.pbOnEnteringBattle(self, @battlers[b[0]], b[1]) }
    @scene.pbSendOutBattlers(sendOuts, startBattle)
    sendOuts.each do |b|
      @scene.pbResetMoveIndex(b[0])
      pbSetSeen(@battlers[b[0]])
      @usedInBattle[b[0] & 1][b[0] / 2] = true
  	  #case @field.field_effects
  	  #This is here in case you want a field effect gimmick to activate on battle start
  	  #end
    end
  end
  def pbEORTerrainHealing(battler)
    return if battler.fainted?
    # Grassy Terrain (healing)
    if @field.terrain == :Grassy && battler.affectedByTerrain? && battler.canHeal?
      PBDebug.log("[Lingering effect] Grassy Terrain heals #{battler.pbThis(true)}")
      battler.pbRecoverHP(battler.totalhp / 16)
      pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    end
	#Field Effects
    
  end
  def defaultField=(value)
    @field.defaultField  = value
    @field.field_effects         = value
  end
  def pbStartFieldEffect(user, newField)
    return if @field.field_effects == newField
    @field.field_effects = newField
    field_data = GameData::FieldEffects.try_get(@field.field_effects)
	  msg = FIELD_EFFECTS[newField][:intro_message]
  	bg = FIELD_EFFECTS[newField][:field_gfx]
    pbDisplay(_INTL(msg)) if msg != nil
  	$field_effect_bg = bg
	  pbHideAbilitySplash(user) if user
  	@scene.pbRefreshEverything
	  fe = FIELD_EFFECTS[newField]
    # Check for abilities/items that trigger upon the terrain changing
  end
  def pbEORField(battler)
    return if battler.fainted?
    amt = -1
	fe = FIELD_EFFECTS[@field.field_effects]
    #add damage done at the end of the field by field effects
    return if amt < 0
    @scene.pbDamageAnimation(battler)
    battler.pbReduceHP(amt, false)
    battler.pbItemHPHealCheck
    battler.pbFaint if battler.fainted?
  end
end

class PokeBattle_Battler
 #Save this class here in case you want to use these for modifying certain methods for the field
end

#Field Changes due to Move Usage
class PokeBattle_Scene
  def pbCreateBackdropSprites
    case @battle.time
    when 1 then time = "eve"
    when 2 then time = "night"
    end
    # Put everything together into backdrop, bases and message bar filenames
    @battle.backdrop = $field_effect_bg if $field_effect_bg != nil
    @battle.backdropBase = $field_effect_bg if $field_effect_bg != nil
    backdropFilename = @battle.backdrop
    baseFilename = @battle.backdrop
    baseFilename = sprintf("%s_%s", baseFilename, @battle.backdropBase) if @battle.backdropBase
    messageFilename = @battle.backdrop
    if time
      trialName = sprintf("%s_%s", backdropFilename, time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_bg"))
        backdropFilename = trialName
      end
      trialName = sprintf("%s_%s", baseFilename, time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_base0"))
        baseFilename = trialName
      end
      trialName = sprintf("%s_%s", messageFilename, time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_message"))
        messageFilename = trialName
      end
    end
    if !pbResolveBitmap(sprintf("Graphics/Battlebacks/" + baseFilename + "_base0")) &&
       @battle.backdropBase
      baseFilename = @battle.backdropBase
      if time
        trialName = sprintf("%s_%s", baseFilename, time)
        if pbResolveBitmap(sprintf("Graphics/Battlebacks/" + trialName + "_base0"))
          baseFilename = trialName
        end
      end
    end
    # Finalise filenames
    battleBG   = "Graphics/Battlebacks/" + backdropFilename + "_bg"
    playerBase = "Graphics/Battlebacks/" + baseFilename + "_base0"
    enemyBase  = "Graphics/Battlebacks/" + baseFilename + "_base1"
    messageBG  = "Graphics/Battlebacks/" + messageFilename + "_message"
    # Apply graphics
    bg = pbAddSprite("battle_bg", 0, 0, battleBG, @viewport)
    bg.z = 0
    bg = pbAddSprite("battle_bg2", -Graphics.width, 0, battleBG, @viewport)
    bg.z      = 0
    bg.mirror = true
    2.times do |side|
      baseX, baseY = Battle::Scene.pbBattlerPosition(side)
      base = pbAddSprite("base_#{side}", baseX, baseY,
                         (side == 0) ? playerBase : enemyBase, @viewport)
      base.z = 1
      if base.bitmap
        base.ox = base.bitmap.width / 2
        base.oy = (side == 0) ? base.bitmap.height : base.bitmap.height / 2
      end
    end
    cmdBarBG = pbAddSprite("cmdBar_bg", 0, Graphics.height - 96, messageBG, @viewport)
    cmdBarBG.z = 180
  end
end

class PokeBattle_Move
#Move Accuracy Changes for Field Effects
  def pbAccuracyCheck(user, target)
    # "Always hit" effects and "always hit" accuracy
    return true if target.effects[PBEffects::Telekinesis] > 0
    return true if target.effects[PBEffects::Minimize] && tramplesMinimize? && Settings::MECHANICS_GENERATION >= 6
    baseAcc = pbBaseAccuracy(user, target)
    return true if baseAcc == 0
    # Calculate all multiplier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user, target, modifiers)
    # Check if move can't miss
    return true if modifiers[:base_accuracy] == 0
  	fe = FIELD_EFFECTS[@battle.field.field_effects]
  	if fe[:move_accuracy_change] != nil
  		for key in fe[:move_accuracy_change].keys
  			if fe[:move_accuracy_change][key].is_a?(Array)
  				modifiers[:base_accuracy] = key if fe[:move_accuracy_change][key].include?(self.id)
  			else
  				modifiers[:base_accuracy] = key if fe[:move_accuracy_change][key] == self.id
  			end
  		end
  	end
	# Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
    stageMul = [3, 3, 3, 3, 3, 3, 3, 4, 5, 6, 7, 8, 9]
    stageDiv = [9, 8, 7, 6, 5, 4, 3, 3, 3, 3, 3, 3, 3]
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
    evasion  = (evasion  * modifiers[:evasion_multiplier]).round
    evasion = 1 if evasion < 1
    threshold = modifiers[:base_accuracy] * accuracy / evasion
    # Calculation
    r = @battle.pbRandom(100)
    if Settings::AFFECTION_EFFECTS && @battle.internalBattle &&
       target.pbOwnedByPlayer? && target.affection_level == 5 && !target.mega?
      return true if r < threshold - 10
      target.damageState.affection_missed = true if r < threshold
      return false
    end
    return r < threshold
  end
  def pbCalcType(user)
      @powerBoost = false
      ret = pbBaseType(user)
      if ret && GameData::Type.exists?(:ELECTRIC)
        if @battle.field.effects[PBEffects::IonDeluge] && ret == :NORMAL
          ret = :ELECTRIC
          @powerBoost = false
        end
        if user.effects[PBEffects::Electrify]
          ret = :ELECTRIC
          @powerBoost = false
        end
      end
      #New Field Effect Modifier Method
  	if fe[:type_type_mod].keys != nil
  		for type_mod in fe[:type_type_mod].keys
  			if isConst?(ret,PBTypes,type_mod)
  				ret = GameData::Type.get(fe[:type_type_mod][type_mod]).id
  				for message in fe[:type_change_message].keys
  					if fe[:type_change_message][message].include?(type_mod)
  						msg = message
  					end
  				end
  				@battle.pbDisplay(_INTL(msg))
  				@powerBoost = false
  			end
  		end
  	end
    return ret
  end
  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = Effectiveness.calculate_one(moveType, defType)
    if Effectiveness.ineffective_type?(moveType, defType)
      # Ring Target
      if target.hasActiveItem?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Foresight
      if (user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]) &&
         defType == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Miracle Eye
      if target.effects[PBEffects::MiracleEye] && defType == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
    elsif Effectiveness.super_effective_type?(moveType, defType)
      # Delta Stream's weather
      if target.effectiveWeather == :StrongWinds && defType == :FLYING
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne? && defType == :FLYING && moveType == :GROUND
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE
    end
  	fe = FIELD_EFFECTS[@battle.field.field_effects]
  	if fe[:type_type_mod] != nil
  		for key in fe[:type_type_mod]
  			if fe[:type_type_mod][key] == moveType
  				eff = Effectiveness.calculate_one(key,defType)
  				ret *= eff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
  				for mess in fe[:type_mod_message].keys
  					pbDisplay(_INTL(mess)) if fe[:type_mod_message][mess] == moveType
  				end
  			end
  		end
  	end
  	if fe[:move_type_mod] != nil
  		for mv in fe[:move_type_mod]
  			if fe[:move_type_mod][mv].include?(self.id)
  				eff = Effectiveness.calculate_one(mv,defType)
  				ret *= eff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
  				for msg in fe[:type_mod_message].keys
  					pbDisplay(_INTL(msg)) if fe[:type_mod_message][msg].include?(self.id)
  				end
  			end
  		end
  	end
    return ret
  end
end