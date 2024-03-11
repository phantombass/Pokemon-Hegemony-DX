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

module Fields
  sound = []
  pulse = []
  wind = []
  slicing = []
  punching = []
  kicking = []
  water = []
  weakwater = []
  swamp = []
  electric = []
  hurricane = []
  special_steel = []
  moves = load_data("Data/moves.dat")
  for move in moves
    next if move[0].is_a?(Integer)
    mv = move[1]
    sound.push(GameData::Move.get(mv).id) if mv.flags[/k/]
    pulse.push(GameData::Move.get(mv).id) if mv.flags[/m/]
    wind.push(GameData::Move.get(mv).id) if mv.flags[/r/]
    slicing.push(GameData::Move.get(mv).id) if mv.flags[/q/]
    punching.push(GameData::Move.get(mv).id) if mv.flags[/j/]
    kicking.push(GameData::Move.get(mv).id) if mv.flags[/t/]
    hurricane.push(GameData::Move.get(mv).id) if (mv.flags[/r/] && mv.base_damage >= 70)
    water.push(GameData::Move.get(mv).id) if (mv.type == :WATER && mv.category != 2 && mv.base_damage >= 65)
    electric.push(GameData::Move.get(mv).id) if (mv.type == :ELECTRIC && mv.category != 2)
    weakwater.push(GameData::Move.get(mv).id) if (mv.type == :WATER && mv.category != 2 && mv.base_damage < 65)
    swamp.push(GameData::Move.get(mv).id) if (mv.type == :ROCK && mv.base_damage >= 80)
    special_steel.push(GameData::Move.get(mv).id) if (mv.type == :STEEL && mv.category == 1)
  end
  SOUND_MOVES = sound
  PULSE_MOVES = pulse
  WIND_MOVES = wind
  PUNCHING_MOVES = punching
  KICKING_MOVES = kicking
  SLICING_MOVES = slicing
  ECHO_MOVES = slicing + kicking + sound + punching
  IGNITE_MOVES = [:FLAMEBURST,:INCINERATE,:LAVAPLUME,:FLAMETHROWER,:MAGMATREK,:FLAREBLITZ,:FLAMEWHEEL,:ERUPTION]
  QUAKE_MOVES = [:EARTHQUAKE,:BULLDOZE,:STOMPINGTANTRUM,:FISSURE,:STEAMROLLER,:STEELROLLER,:ICESPINNER]
  DOUSERS = [:RAINDANCE,:DRIZZLE,:PRIMORDIALSEA] + water
  OUTAGE_MOVES = electric
  RECHARGE_MOVES = [:RECHARGE,:CHARGE] + electric
  SHORT_MOVES = [:DISCHARGE,:OVERCHARGE,:ZAPCANNON,:OVERDRIVE,:SUPERCELLSLAM]
  WEAK_WATER = weakwater
  REMOVAL = [:DEFOG,:TIDYUP,:GALEFORCE,:TAILWIND] + wind
  SWAMP_REMOVAL = swamp
  LAVA_REMOVAL = [:ICEBEAM,:BLIZZARD,:GLACIALLANCE,:SHEERCOLD,:ICESPINNER,:ICICLECRASH,:ICEHAMMER] + water
  HURRICANE_MOVES = hurricane
  UNDERWATER_MOVES = [:DIVE]
  MAGNET_REMOVAL = swamp + [:GRAVITY,:POLARITYPULSE]
  RICOCHET_MOVES = [:DAZZLINGGLEAM,:MIRRORSHOT,:MIRRORRUSH,:LIGHTOFRUIN,:MAKEITRAIN,:FLASH,:FLASHCANNON,:AURORABEAM,:MOONBLAST,:STARBEAM,
    :PHOTONGEYSER,:ICEBEAM,:LUSTERPURGE,:MISTBALL,:SNIPESHOT,:BUBBLEBEAM,:PSYBEAM,:AURASPHERE,:CHARGEBEAM,:THUNDERBOLT]
  LIGHT_MOVES = [:DAZZLINGGLEAM,:FLASH,:PHOTONGEYSER,:LUSTERPURGE,:AURORABEAM,:DISCHARGE]
  FAIRY_LIGHTS_MOVES = [:PHOTONGEYSER,:LUSTERPURGE,:AURORABEAM,:DISCHARGE,:MISTBALL]
  FAIRY_LIGHTS_REMOVAL = [:ROCKSLIDE,:MUDSHOT,:MUDBOMB,:MUDSLAP,:MUDBOMB,:MUDSPORT,:OCTOZOOKA,:MUDDYWATER]
  SPECIAL_STEEL = special_steel
  WIND_TUNNEL_MOVES = wind + kicking
  #These are examples of arrays you can make for moves that will affect or be affected by a field effect
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
  :id   => :Garden,
  :name => _INTL("Garden")
})

GameData::FieldEffects.register({
  :id   => :Graveyard,
  :name => _INTL("Graveyard")
})

GameData::FieldEffects.register({
  :id   => :Grassy,
  :name => _INTL("Grassy Terrain")
})

GameData::FieldEffects.register({
  :id   => :Electric,
  :name => _INTL("Electric Terrain")
})

GameData::FieldEffects.register({
  :id   => :EchoChamber,
  :name => _INTL("Cave")
})

GameData::FieldEffects.register({
  :id   => :Wildfire,
  :name => _INTL("Wildfire")
})

GameData::FieldEffects.register({
  :id   => :Psychic,
  :name => _INTL("Psychic Terrain")
})

GameData::FieldEffects.register({
  :id   => :Misty,
  :name => _INTL("Misty Terrain")
})

GameData::FieldEffects.register({
  :id   => :Poison,
  :name => _INTL("Poison Terrain")
})

GameData::FieldEffects.register({
  :id   => :Desert,
  :name => _INTL("Desert")
})

GameData::FieldEffects.register({
  :id   => :Swamp,
  :name => _INTL("Swamp")
})

GameData::FieldEffects.register({
  :id   => :Lava,
  :name => _INTL("Lava")
})

GameData::FieldEffects.register({
  :id   => :Ruins,
  :name => _INTL("Ruins")
})

GameData::FieldEffects.register({
  :id   => :City,
  :name => _INTL("City")
})

GameData::FieldEffects.register({
  :id   => :Outage,
  :name => _INTL("Outage")
})

GameData::FieldEffects.register({
  :id   => :Mountainside,
  :name => _INTL("Mountainside")
})

GameData::FieldEffects.register({
  :id   => :Icy,
  :name => _INTL("Icy")
})

GameData::FieldEffects.register({
  :id   => :SnowyMountainside,
  :name => _INTL("Snowy Mountainside")
})

GameData::FieldEffects.register({
  :id   => :Water,
  :name => _INTL("Water")
})

GameData::FieldEffects.register({
  :id   => :Underwater,
  :name => _INTL("Underwater")
})

GameData::FieldEffects.register({
  :id   => :Dream,
  :name => _INTL("Dream")
})

GameData::FieldEffects.register({
  :id   => :Magnetic,
  :name => _INTL("Magnetic")
})

GameData::FieldEffects.register({
  :id   => :Digital,
  :name => _INTL("Digital")
})

GameData::FieldEffects.register({
  :id   => :Mirror,
  :name => _INTL("Mirror")
})

GameData::FieldEffects.register({
  :id   => :Space,
  :name => _INTL("Space")
})

GameData::FieldEffects.register({
  :id   => :Dojo,
  :name => _INTL("Dojo")
})

GameData::FieldEffects.register({
  :id   => :Distortion,
  :name => _INTL("Distortion")
})

GameData::FieldEffects.register({
  :id   => :FairyLights,
  :name => _INTL("Fairy Lights")
})

GameData::FieldEffects.register({
  :id   => :DarkRoom,
  :name => _INTL("Dark Room")
})

GameData::FieldEffects.register({
  :id   => :Castle,
  :name => _INTL("Castle")
})

GameData::FieldEffects.register({
  :id   => :WindTunnel,
  :name => _INTL("Wind Tunnel")
})

GameData::FieldEffects.register({
  :id   => :DragonsDen,
  :name => _INTL("Dragon's Den")
})

#Define Environments to match your Field Effects here

GameData::Environment.register({
  :id          => :None,
  :name        => _INTL("None"),
  :battle_base => "grass_night"
})

GameData::Environment.register({
  :id          => :Garden,
  :name        => _INTL("Garden"),
  :battle_base => "field"
})

GameData::Environment.register({
  :id          => :Grassy,
  :name        => _INTL("Grassy"),
  :battle_base => "Grassy"
})

GameData::Environment.register({
  :id          => :Electric,
  :name        => _INTL("Electric"),
  :battle_base => "Electric"
})

GameData::Environment.register({
  :id          => :Misty,
  :name        => _INTL("Misty"),
  :battle_base => "Misty"
})

GameData::Environment.register({
  :id          => :Psychic,
  :name        => _INTL("Psychic"),
  :battle_base => "Psychic"
})

GameData::Environment.register({
  :id          => :Poison,
  :name        => _INTL("Poison"),
  :battle_base => "Poison"
})

GameData::Environment.register({
  :id          => :Wildfire,
  :name        => _INTL("Wildfire"),
  :battle_base => "wildfire"
})

GameData::Environment.register({
  :id          => :EchoChamber,
  :name        => _INTL("Cave"),
  :battle_base => "cave1"
})

GameData::Environment.register({
  :id          => :Desert,
  :name        => _INTL("Desert"),
  :battle_base => "sand"
})

GameData::Environment.register({
  :id          => :Swamp,
  :name        => _INTL("Swamp"),
  :battle_base => "field_night"
})

GameData::Environment.register({
  :id          => :Lava,
  :name        => _INTL("Lava"),
  :battle_base => "water_eve"
})

GameData::Environment.register({
  :id          => :Ruins,
  :name        => _INTL("Ruins"),
  :battle_base => "rocky_eve"
})

GameData::Environment.register({
  :id          => :City,
  :name        => _INTL("City"),
  :battle_base => "city"
})

GameData::Environment.register({
  :id          => :Outage,
  :name        => _INTL("Outage"),
  :battle_base => "city_night"
})

GameData::Environment.register({
  :id          => :Mountainside,
  :name        => _INTL("Mountainside"),
  :battle_base => "rocky"
})

GameData::Environment.register({
  :id          => :Icy,
  :name        => _INTL("Icy"),
  :battle_base => "ice"
})

GameData::Environment.register({
  :id          => :SnowyMountainside,
  :name        => _INTL("Snowy Mountainside"),
  :battle_base => "snow"
})

GameData::Environment.register({
  :id          => :Water,
  :name        => _INTL("Water"),
  :battle_base => "water"
})

GameData::Environment.register({
  :id          => :Underwater,
  :name        => _INTL("Underwater"),
  :battle_base => "underwater"
})

GameData::Environment.register({
  :id          => :Dream,
  :name        => _INTL("Dream"),
  :battle_base => "dream"
})

GameData::Environment.register({
  :id          => :Magnetic,
  :name        => _INTL("Magnetic"),
  :battle_base => "champion2"
})

GameData::Environment.register({
  :id          => :Digital,
  :name        => _INTL("Digital"),
  :battle_base => "champion2"
})

GameData::Environment.register({
  :id          => :Mirror,
  :name        => _INTL("Mirror"),
  :battle_base => "cave1_ice"
})

GameData::Environment.register({
  :id          => :Space,
  :name        => _INTL("Space"),
  :battle_base => "elite1"
})

GameData::Environment.register({
  :id          => :Dojo,
  :name        => _INTL("Dojo"),
  :battle_base => "elite6"
})

GameData::Environment.register({
  :id          => :Distortion,
  :name        => _INTL("Distortion"),
  :battle_base => "distortion"
})

GameData::Environment.register({
  :id          => :FairyLights,
  :name        => _INTL("Fairy Lights"),
  :battle_base => "snow_eve"
})

GameData::Environment.register({
  :id          => :DarkRoom,
  :name        => _INTL("Dark Room"),
  :battle_base => "elite3"
})

GameData::Environment.register({
  :id          => :Castle,
  :name        => _INTL("Castle"),
  :battle_base => "castle"
})

GameData::Environment.register({
  :id          => :WindTunnel,
  :name        => _INTL("Wind Tunnel"),
  :battle_base => "snow_night"
})

GameData::Environment.register({
  :id          => :DragonsDen,
  :name        => _INTL("Dragon's Den"),
  :battle_base => "dragon"
})

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
      rules["defaultField"] = (field_data) ? field_data.id : :None
    when "backdrop", "battleback" then rules["backdrop"]            = var
    when "base"                   then rules["base"]                = var
    when "outcome", "outcomevar"  then rules["outcomeVar"]          = var
    when "nopartner"              then rules["noPartner"]           = true
    when "inversebattle"          then rules["inverseBattle"] = true
    else
      raise _INTL("Battle rule \"{1}\" does not exist.", rule)
    end
  	$game_screen.field_effect(rules["defaultfield"])
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
    battle.defaultField = :Water if $PokemonGlobal.surfing
    battle.defaultField = :Water if [:OldRod,:GoodRod,:SuperRod].include?($PokemonTemp.encounterType)
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
      $PokemonTemp.recordBattleRule(r, arg)
      r = nil
    else
      case arg.downcase
      when "terrain", "weather", "environment", "environ", "backdrop",
           "battleback", "base", "outcome", "outcomevar","field"
        r = arg
        next
      end
      $PokemonTemp.recordBattleRule(arg)
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
    @field_effects = type
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
  def self.douse?
    return false if @field.nil?
    return false if [:Sun,:HarshSun].include?(@field.pbWeather)
    return true
  end
  def self.melt?
    return false if @field.nil?
    return false if [:Hail,:Sleet].include?(@field.pbWeather)
    return true
  end
  def self.light?
    return false if @field.nil?
    return false if @field.pbWeather == :Eclipse
    return true
  end
  def pbStartBattleCore
    # Set up the battlers on each side
    pbHegemonyClauses
    sendOuts = pbSetUpSides
    olditems = []
    pbParty(0).each_with_index do |pkmn,i|
      item = pkmn.item_id
      olditems.push(item)
    end
    $olditems = olditems
    $PokemonTemp.battleRules["defaultField"] = :Water if $PokemonGlobal.surfing
    @field.field_effects = $PokemonTemp.battleRules["defaultField"]
    @field.defaultField = $PokemonTemp.battleRules["defaultField"]
    $field_effect_bg = nil
    # Create all the sprites and play the battle intro animation
    @field.weather = $game_screen.weather_type
    @scene.pbStartBattle(self)
    # Show trainers on both sides sending out Pokémon
    pbStartBattleSendOut(sendOuts)
    # Weather announcement
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if weather_data
    case @field.weather
    when :Sun         then pbDisplay(_INTL("The sunlight is strong."))
    when :Rain        then pbDisplay(_INTL("It is raining."))
    when :Sandstorm   then pbDisplay(_INTL("A sandstorm is raging."))
    when :Hail        then pbDisplay(_INTL("Snow is falling."))
    when :HarshSun    then pbDisplay(_INTL("The sunlight is extremely harsh."))
    when :HeavyRain   then pbDisplay(_INTL("It is raining heavily."))
    when :StrongWinds then pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky   then pbDisplay(_INTL("The sky is shadowy."))
    when :Starstorm  then pbDisplay(_INTL("Stars fill the sky."))
    when :Thunder    then pbDisplay(_INTL("Lightning flashes in the sky."))
    when :Storm      then pbDisplay(_INTL("A thunderstorm rages. The ground became electrified!"))
    when :Humid      then pbDisplay(_INTL("The air is humid."))
    #when :Overcast   then pbDisplay(_INTL("The sky is overcast."))
    when :Eclipse    then pbDisplay(_INTL("The sky is dark."))
    when :Fog        then pbDisplay(_INTL("The fog is deep."))
    when :AcidRain   then pbDisplay(_INTL("Acid rain is falling."))
    when :VolcanicAsh then pbDisplay(_INTL("Volcanic Ash sprinkles down."))
    when :Rainbow    then pbDisplay(_INTL("A rainbow crosses the sky."))
    when :Borealis   then pbDisplay(_INTL("The sky is ablaze with color."))
    when :TimeWarp   then pbDisplay(_INTL("Time has stopped."))
    when :Reverb     then pbDisplay(_INTL("A dull echo hums."))
    when :DClear     then pbDisplay(_INTL("The sky is distorted."))
    when :DRain      then pbDisplay(_INTL("Rain is falling upward."))
    when :DWind      then pbDisplay(_INTL("The wind is haunting."))
    when :DAshfall   then pbDisplay(_INTL("Ash floats in midair."))
    when :Sleet      then pbDisplay(_INTL("Sleet began to fall."))
    when :Windy      then pbDisplay(_INTL("There is a slight breeze."))
    when :HeatLight  then pbDisplay(_INTL("Static fills the air."))
    when :DustDevil  then pbDisplay(_INTL("A dust devil approaches."))
    end
    # Terrain announcement
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    case @field.terrain
    when :Electric
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
    when :Grassy
      pbDisplay(_INTL("Grass is covering the battlefield!"))
    when :Misty
      pbDisplay(_INTL("Mist swirls about the battlefield!"))
    when :Psychic
      pbDisplay(_INTL("The battlefield is weird!"))
    when :Poison
      pbDisplay(_INTL("Toxic waste covers the ground!"))
    end
    fe = @field.field_effects == :None ? nil : FIELD_EFFECTS[@field.field_effects]
    if fe[:intro_message] != nil
      pbDisplay(_INTL(fe[:intro_message]))
    end
    case fe[:intro_script]
    when "swamp"
      @battlers.each do |battler|
        if battler.affectedBySwamp? && battler.pbCanLowerStatStage?(:SPEED) && @field.field_effects == :Swamp
          battler.pbLowerStatStage(:SPEED,1,nil) 
          pbDisplay(_INTL("{1} was caught in the swamp!",battler.pbThis))
        end
      end
    when "magnet"
      @battlers.each do |battler|
        if battler.affectedByMagnet? && !battler.airborne?
          battler.effects[PBEffects::MagnetRise] = 1 
          pbDisplay(_INTL("{1} was lifted off the ground with electromagnetism!",battler.pbThis))
        end
      end
    when "distortion"
      pbDisplay(_INTL("The Distortion field inverts the type matchups!"))
      $inverse = true
    when "wind"
      pbDisplay(_INTL("The Wind Tunnel boosts the speed of airborne Pokémon!"))
    end
    # Abilities upon entering battle
    pbOnActiveAll
    # Main battle loop
    pbBattleLoop
  end

  def pbOnActiveOne(battler)
    return false if battler.fainted?
    # Introduce Shadow Pokémon
    if battler.opposes? && battler.shadowPokemon?
      pbCommonAnimation("Shadow",battler)
      pbDisplay(_INTL("Oh!\nA Shadow Pokémon!"))
    end
    if !battler.pbOwnedByPlayer? && !wildBattle?
      trainer_hash = $game_variables[RandTrainer::Temp]
      for mon in trainer_hash[:pokemon]
        if battler.species == mon[:species]
          battler.item = mon[:item]
        end
      end
    end
    # Record money-doubling effect of Amulet Coin/Luck Incense
    if !battler.opposes? && [:AMULETCOIN, :LUCKINCENSE].include?(battler.item_id)
      @field.effects[PBEffects::AmuletCoin] = true
    end
    # Update battlers' participants (who will gain Exp/EVs when a battler faints)
    eachBattler { |b| b.pbUpdateParticipants }
    # Healing Wish
    if @positions[battler.index].effects[PBEffects::HealingWish]
      pbCommonAnimation("HealingWish",battler)
      pbDisplay(_INTL("The healing wish came true for {1}!",battler.pbThis(true)))
      battler.pbRecoverHP(battler.totalhp)
      battler.pbCureStatus(false)
      @positions[battler.index].effects[PBEffects::HealingWish] = false
    end
    # Lunar Dance
    if @positions[battler.index].effects[PBEffects::LunarDance]
      pbCommonAnimation("LunarDance",battler)
      pbDisplay(_INTL("{1} became cloaked in mystical moonlight!",battler.pbThis))
      battler.pbRecoverHP(battler.totalhp)
      battler.pbCureStatus(false)
      battler.eachMove { |m| m.pp = m.total_pp }
      @positions[battler.index].effects[PBEffects::LunarDance] = false
    end
    # Entry hazards
    # Stealth Rock
    if battler.pbOwnSide.effects[PBEffects::StealthRock] && battler.takesIndirectDamage? &&
       GameData::Type.exists?(:ROCK) && battler.takesEntryHazardDamage? && !battler.hasActiveAbility?(:SCALER)
      bTypes = battler.pbTypes(true)
      eff = Effectiveness.calculate(:ROCK, bTypes[0], bTypes[1], bTypes[2])
      if !Effectiveness.ineffective?(eff)
        eff = eff.to_f / Effectiveness::NORMAL_EFFECTIVE
        oldHP = battler.hp
        battler.pbReduceHP(battler.totalhp*eff/8,false)
        pbDisplay(_INTL("Pointed stones dug into {1}!",battler.pbThis))
        battler.pbItemHPHealCheck
        if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
          return pbOnActiveOne(battler)   # For replacement battler
        end
      end
    end
    #Comet Shards
    if battler.pbOwnSide.effects[PBEffects::CometShards] && battler.takesIndirectDamage? &&
       GameData::Type.exists?(:COSMIC) && battler.takesEntryHazardDamage?
      bTypes = battler.pbTypes(true)
      eff = Effectiveness.calculate(:COSMIC, bTypes[0], bTypes[1], bTypes[2])
      if battler.pbHasType?(:COSMIC)
        battler.pbOwnSide.effects[PBEffects::CometShards] = false
        pbDisplay(_INTL("{1} absorbed the Comet Shards!",battler.pbThis))
      elsif !Effectiveness.ineffective?(eff)
        eff = eff.to_f / Effectiveness::NORMAL_EFFECTIVE
        oldHP = battler.hp
        battler.pbReduceHP(battler.totalhp*eff/8,false)
        pbDisplay(_INTL("Pointed stones dug into {1}!",battler.pbThis))
        battler.pbItemHPHealCheck
        if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
          return pbOnActiveOne(battler)   # For replacement battler
        end
      end
    end
    # Spikes
    if battler.pbOwnSide.effects[PBEffects::Spikes]>0 && battler.takesIndirectDamage? &&
       !battler.airborne? && battler.takesEntryHazardDamage?
      spikesDiv = [8,6,4][battler.pbOwnSide.effects[PBEffects::Spikes]-1]
      oldHP = battler.hp
      battler.pbReduceHP(battler.totalhp/spikesDiv,false)
      pbDisplay(_INTL("{1} is hurt by the spikes!",battler.pbThis))
      battler.pbItemHPHealCheck
      if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
        return pbOnActiveOne(battler)   # For replacement battler
      end
    end
    # Toxic Spikes
    if battler.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 && !battler.fainted? &&
       !battler.airborne?
      if battler.pbHasType?(:POISON)
        battler.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
        pbDisplay(_INTL("{1} absorbed the poison spikes!",battler.pbThis))
      elsif battler.pbCanPoison?(nil,false) && battler.takesEntryHazardDamage?
        if battler.pbOwnSide.effects[PBEffects::ToxicSpikes]==2
          battler.pbPoison(nil,_INTL("{1} was badly poisoned by the poison spikes!",battler.pbThis),true)
        else
          battler.pbPoison(nil,_INTL("{1} was poisoned by the poison spikes!",battler.pbThis))
        end
      end
    end
    # Sticky Web
    if battler.pbOwnSide.effects[PBEffects::StickyWeb] && !battler.fainted? &&
       !battler.airborne? && battler.takesEntryHazardDamage?
      pbDisplay(_INTL("{1} was caught in a sticky web!",battler.pbThis))
      if battler.pbCanLowerStatStage?(:SPEED)
        stickyuser = (battler.pbOwnSide.effects[PBEffects::StickyWebUser] > -1 ?
          battlers[battler.pbOwnSide.effects[PBEffects::StickyWebUser]] : nil)
        battler.pbLowerStatStage(:SPEED,1,stickyuser)
        battler.pbItemStatRestoreCheck
      end
    end
    # Battler faints if it is knocked out because of an entry hazard above
    if battler.fainted?
      battler.pbFaint
      pbGainExp
      pbJudge
      return false
    end
    battler.pbCheckForm
    fe = FIELD_EFFECTS[@field.field_effects]
    if fe[:ability_effects] != nil
      for key in fe[:ability_effects].keys
        if battler.hasActiveAbility?(key)
          pbShowAbilitySplash(battler)
          for i in fe[:ability_effects][key]
            battler.pbRaiseStatStage(i[0],i[1],battler)
          end
          pbHideAbilitySplash(battler)
        end
      end
    end
    if fe[:abilities] != nil
      if fe[:abilities].include?(battler.ability) && !fe[:ability_effects].keys.include?(battler.ability)
        BattleHandlers.triggerAbilityOnSwitchIn(battler.ability,battler,@battle)
      end
    end
    if battler.affectedBySwamp? && !battler.fainted? && @field.field_effects == :Swamp
      pbDisplay(_INTL("{1} was caught in the swamp!",battler.pbThis))
      battler.pbLowerStatStage(:SPEED,1,battler) if battler.pbCanLowerStatStage?(:SPEED)
      battler.pbItemStatRestoreCheck
    end
    if battler.affectedByMagnet? && !battler.fainted? && @field.field_effects == :Magnetic
      pbDisplay(_INTL("{1} was lifted off the ground with electromagnetism!",battler.pbThis))
      battler.effects[PBEffects::MagnetRise] = 1
    end
    return true
  end

  def pbEndOfBattle
    #$mega_flag = 0
    oldDecision = @decision
    @decision = 4 if @decision==1 && wildBattle? && @caughtPokemon.length>0
    case oldDecision
    ##### WIN #####
    when 1
      PBDebug.log("")
      PBDebug.log("***Player won***")
      if trainerBattle?
        @scene.pbTrainerBattleSuccess
        case @opponent.length
        when 1
          pbDisplayPaused(_INTL("You defeated {1}!",@opponent[0].full_name))
        when 2
          pbDisplayPaused(_INTL("You defeated {1} and {2}!",@opponent[0].full_name,
             @opponent[1].full_name))
        when 3
          pbDisplayPaused(_INTL("You defeated {1}, {2} and {3}!",@opponent[0].full_name,
             @opponent[1].full_name,@opponent[2].full_name))
        end
        @opponent.each_with_index do |_t,i|
          @scene.pbShowOpponent(i)
          msg = (@endSpeeches[i]!=0) ? @endSpeeches[i] : "..."
          pbDisplayPaused(msg)
        end
      end
      # Gain money from winning a trainer battle, and from Pay Day
      pbGainMoney if @decision!=4
      # Hide remaining trainer
      @scene.pbShowOpponent(@opponent.length) if trainerBattle? && @caughtPokemon.length>0
    ##### LOSE, DRAW #####
    when 2, 5
      PBDebug.log("")
      PBDebug.log("***Player lost***") if @decision==2
      PBDebug.log("***Player drew with opponent***") if @decision==5
      if @internalBattle
        pbDisplayPaused(_INTL("You have no more Pokémon that can fight!"))
        if trainerBattle?
          case @opponent.length
          when 1
            pbDisplayPaused(_INTL("You lost against {1}!",@opponent[0].full_name))
          when 2
            pbDisplayPaused(_INTL("You lost against {1} and {2}!",
               @opponent[0].full_name,@opponent[1].full_name))
          when 3
            pbDisplayPaused(_INTL("You lost against {1}, {2} and {3}!",
               @opponent[0].full_name,@opponent[1].full_name,@opponent[2].full_name))
          end
        end
        # Lose money from losing a battle
        pbLoseMoney
        pbDisplayPaused(_INTL("You blacked out!")) if !@canLose
      elsif @decision==2
        if @opponent
          @opponent.each_with_index do |_t,i|
            @scene.pbShowOpponent(i)
            msg = (@endSpeechesWin[i] && @endSpeechesWin[i]!="") ? @endSpeechesWin[i] : "..."
            pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name))
          end
        end
      end
    ##### CAUGHT WILD POKÉMON #####
    when 4
      @scene.pbWildBattleSuccess if !Settings::GAIN_EXP_FOR_CAPTURE
    end
    # Register captured Pokémon in the Pokédex, and store them
    pbRecordAndStoreCaughtPokemon
    # Collect Pay Day money in a wild battle that ended in a capture
    pbGainMoney if @decision==4
    # Pass on Pokérus within the party
    if @internalBattle
      infected = []
      $Trainer.party.each_with_index do |pkmn,i|
        infected.push(i) if pkmn.pokerusStage==1
      end
      infected.each do |idxParty|
        strain = $Trainer.party[idxParty].pokerusStrain
        if idxParty>0 && $Trainer.party[idxParty-1].pokerusStage==0
          $Trainer.party[idxParty-1].givePokerus(strain) if rand(3)==0   # 33%
        end
        if idxParty<$Trainer.party.length-1 && $Trainer.party[idxParty+1].pokerusStage==0
          $Trainer.party[idxParty+1].givePokerus(strain) if rand(3)==0   # 33%
        end
      end
    end
    # Clean up battle stuff
    @scene.pbEndBattle(@decision)
    @battlers.each do |b|
      next if !b
      pbCancelChoice(b.index)   # Restore unused items to Bag
      BattleHandlers.triggerAbilityOnSwitchOut(b.ability,b,true) if b.abilityActive?
    end
    pbParty(0).each_with_index do |pkmn,i|
      next if !pkmn
      @peer.pbOnLeavingBattle(self,pkmn,@usedInBattle[0][i],true)   # Reset form
      if pkmn.fainted? && $game_switches[LvlCap::Ironmon]
        $PokemonBag.pbStoreItem(pkmn.item, 1) if pkmn.item
        $Trainer.party.delete_at(pkmn.index)
        $PokemonTemp.evolutionLevels.delete_at(pkmn.index)
      end
      if @opponent
        pkmn.item = $olditems[i]
      else
        pkmn.item = @initialItems[0][i]
      end
    end
    $game_switches[89] = false
    # return final output
    return @decision
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
    duration = 5
    if duration>0 && user && user.itemActive?
      duration = BattleHandlers.triggerTerrainExtenderItem(user.item,
         newField,duration,user,self)
    end
    @field.terrainDuration = duration if [:Electric,:Grassy,:Misty,:Psychic,:Poison].include?(@field.field_effects)
	  msg = FIELD_EFFECTS[newField][:intro_message]
  	bg = FIELD_EFFECTS[newField][:field_gfx]
    pbDisplay(_INTL(msg)) if msg != nil
  	@scene.pbChangeField(newField)
	  pbHideAbilitySplash(user) if user
  	@scene.pbRefreshEverything
	  fe = FIELD_EFFECTS[newField]
    # Check for abilities/items that trigger upon the terrain changing
  end
  def pbEORField(battler)
    return if battler.fainted?
    amt = -1
	  fe = FIELD_EFFECTS[@field.field_effects]
    case @field.field_effects
    when :Electric,:Magnetic
      if battler.affectedByTerrain? && battler.canHeal? && battler.hasActiveAbility?(:VOLTABSORB)
        PBDebug.log("[Lingering effect] Electric Terrain heals #{battler.pbThis(true)}")
        battler.pbRecoverHP(battler.totalhp / 16)
        pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      end
    when :Grassy
      if battler.affectedByTerrain? && battler.canHeal?
        PBDebug.log("[Lingering effect] Grassy Terrain heals #{battler.pbThis(true)}")
        battler.pbRecoverHP(battler.totalhp / 16)
        pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      end
    when :Garden
      if battler.canHeal? && battler.affectedByGarden?
        PBDebug.log("[Lingering effect] Garden Field heals #{battler.pbThis(true)}")
        battler.pbRecoverHP(battler.totalhp / 16)
        pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      end
    when :Space, :Distortion
      if battler.affectedByTerrain? && battler.canHeal? && battler.hasActiveAbility?(:STARSALVE)
        PBDebug.log("[Lingering effect] Field heals #{battler.pbThis(true)}")
        battler.pbRecoverHP(battler.totalhp / 16)
        pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      end
    when :Swamp, :Poison
      if battler.affectedByTerrain? && battler.canHeal? && battler.hasActiveAbility?(:POISONHEAL)
        PBDebug.log("[Lingering effect] Swamp Field heals #{battler.pbThis(true)}")
        battler.pbRecoverHP(battler.totalhp / 16)
        pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      end
    when :Lava
      if battler.affectedByTerrain? && battler.canHeal? && battler.affectedByLava?
        if battler.hasActiveAbility?(:FLAMEBODY)
          PBDebug.log("[Lingering effect] Lava Field heals #{battler.pbThis(true)}")
          battler.pbRecoverHP(battler.totalhp / 16)
          pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
        end
      elsif battler.affectedByLava? && battler.takesIndirectDamage?
        PBDebug.log("[Lingering effect] Lava Field hurts #{battler.pbThis(true)}")
        battler.pbReduceHP(battler.totalhp / 16)
        pbDisplay(_INTL("{1}'s was scorched.", battler.pbThis))
      end
    when :SnowyMountainside
      if battler.affectedByTerrain? && battler.canHeal? && battler.hasActiveAbility?(:ICEBODY)
        PBDebug.log("[Lingering effect] Snowy Mountainside field heals #{battler.pbThis(true)}")
        battler.pbRecoverHP(battler.totalhp / 16)
        pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      end
    when :DragonsDen
      if battler.affectedByTerrain? && battler.canHeal? && battler.affectedByDragonsDen?
        PBDebug.log("[Lingering effect] Dragon's Den field heals #{battler.pbThis(true)}")
        battler.pbRecoverHP(battler.totalhp / 16)
        pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      end
      if battler.affectedByTerrain? && battler.canHeal? && battler.hasActiveAbility?(:LEGENDARMOR)
        PBDebug.log("[Lingering effect] Dragon's Den field heals #{battler.pbThis(true)}")
        battler.pbRecoverHP(battler.totalhp / 16)
        pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      end
    when :Water
      if battler.affectedByTerrain? && battler.canHeal? && battler.hasActiveAbility?([:DRYSKIN,:WATERABSORB])
        PBDebug.log("[Lingering effect] Water field heals #{battler.pbThis(true)}")
        battler.pbRecoverHP(battler.totalhp / 16)
        pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      end
      if battler.affectedByHurricane? && battler.takesIndirectDamage? && @field.effects[PBEffects::Hurricane] > 0
        PBDebug.log("[Lingering effect] Hurricane hurts #{battler.pbThis(true)}")
        battler.pbReduceHP(battler.totalhp / 16)
        pbDisplay(_INTL("{1}'s was thrown about by the hurricane.", battler.pbThis))
      end
    when :Underwater
      if battler.affectedByTerrain? && battler.canHeal? && battler.hasActiveAbility?([:DRYSKIN,:WATERABSORB])
        PBDebug.log("[Lingering effect] Underwater field heals #{battler.pbThis(true)}")
        battler.pbRecoverHP(battler.totalhp / 16)
        pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      elsif battler.affectedByUnderwater? && battler.takesIndirectDamage?
        PBDebug.log("[Lingering effect] Underwater Field hurts #{battler.pbThis(true)}")
        battler.pbReduceHP(battler.totalhp / 8)
        pbDisplay(_INTL("{1}'s was scorched.", battler.pbThis))
      end
    when :Graveyard
      if battler.affectedByGraveyard? && battler.takesIndirectDamage? && @field.effects[PBEffects::Hurricane] > 0
        PBDebug.log("[Lingering effect] Hurricane hurts #{battler.pbThis(true)}")
        battler.pbReduceHP(battler.totalhp / 16)
        pbDisplay(_INTL("{1}'s was thrown about by the hurricane.", battler.pbThis))
      end
    end
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
  def affectedByGarden?
    return pbHasType?([:BUG,:FAIRY,:GRASS])
  end
  def affectedBySwamp?
    return true if !pbHasType?([:BUG,:GRASS,:WATER,:POISON])
    return false if airborne?
  end
  def affectedByLava?
    return true if !pbHasType?([:FIRE,:DRAGON,:FLYING,:WATER,:GROUND])
    return false if airborne?
  end
  def affectedByCinders?
    return true if !pbHasType?([:FIRE,:DRAGON])
    return false if !takesIndirectDamage?
  end
  def affectedByDragonsDen?
    return pbHasType?([:FIRE,:DRAGON])
  end
  def affectedByHurricane?
    return !pbHasType?(:WATER)
  end
  def affectedByGraveyard?
    return !pbHasType?(:GHOST)
  end
  def affectedByUnderwater?
    return pbHasType?(:FIRE)
  end
  def affectedByMagnet?
    return pbHasType?([:ELECTRIC,:STEEL])
  end
  def activeField
    return @battle.field.field_effects
  end
end

def pbSetField(terrain)
  terrain = :EchoChamber if $dungeon.reward_locations.include?($game_map.map_id)
  setBattleRule("field",terrain)
  setBattleRule("environment",terrain)
  name = GameData::Environment.get(terrain).name
  $PokemonGlobal.nextBattleBack = name
end

#Field Changes due to Move Usage
class PokeBattle_Scene
  def pbChangeField(terrain)
    terrain = :EchoChamber if $dungeon.reward_locations.include?($game_map.map_id)
    name = FIELD_EFFECTS[@battle.field.field_effects][:field_gfx]
    @battle.field.field_effects = terrain
    back = name
    base = name
    return [back,base]
  end
  def pbCreateBackdropSprites
    case @battle.time
    when 1 then time = "eve"
    when 2 then time = "night"
    end
    # Put everything together into backdrop, bases and message bar filenames
    default = []
    2.times do
      default.push(GameData::Environment.get(@battle.field.defaultField).battle_base)
    end
    change = pbChangeField(@battle.field.field_effects)
    if @battle.field.field_effects != :None
      @battle.backdrop = change[0]
      @battle.backdropBase = change[1]
    else
      @battle.backdrop = default[0]
      @battle.backdropBase = default[1]
    end
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
      baseX, baseY = PokeBattle_SceneConstants.pbBattlerPosition(side)
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
    if fe[:type_accuracy_change] != nil
      for key in fe[:type_accuracy_change].keys
        if fe[:type_accuracy_change][key].is_a?(Array)
          modifiers[:base_accuracy] = key if fe[:type_accuracy_change][key].include?(self.type)
        else
          modifiers[:base_accuracy] = key if fe[:type_accuracy_change][key] == self.type
        end
      end
    end
    return true if modifiers[:base_accuracy] == 0
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
      fe = FIELD_EFFECTS[@battle.field.field_effects]
      #New Field Effect Modifier Method
  	if fe[:type_type_mod].keys != nil
  		for type_mod in fe[:type_type_mod].keys
  			if ret == type_mod
  				ret = GameData::Type.get(fe[:type_type_mod][type_mod]).id
  				for message in fe[:type_change_message].keys
  					if fe[:type_change_message][message].include?(type_mod)
  						msg = message
  					end
  				end
  				@battle.pbDisplay(_INTL("#{msg}")) if $test_trigger == false
  				@powerBoost = false
  			end
  		end
  	end
    return ret
  end

  def pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    # Global abilities
    if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
       (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY) ||
       (@battle.pbCheckGlobalAbility(:GAIAFORCE) && type == :GROUND) ||
       (@battle.pbCheckGlobalAbility(:FEVERPITCH) && type == :POISON)
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:base_damage_multiplier] *= 2 / 3.0
      else
        multipliers[:base_damage_multiplier] *= 4 / 3.0
      end
    end
    # Ability effects that alter damage
    if user.abilityActive?
      BattleHandlers.triggerDamageCalcUserAbility(user.ability,
         user,target,self,multipliers,baseDmg,type)
    end
    if !@battle.moldBreaker
      # NOTE: It's odd that the user's Mold Breaker prevents its partner's
      #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
      #       how it works.
      user.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
           user,target,self,multipliers,baseDmg,type)
      end
      if target.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
           user,target,self,multipliers,baseDmg,type) if !@battle.moldBreaker
        BattleHandlers.triggerDamageCalcTargetAbilityNonIgnorable(target.ability,
           user,target,self,multipliers,baseDmg,type)
      end
      target.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
           user,target,self,multipliers,baseDmg,type)
      end
    end
    # Item effects that alter damage
    if user.itemActive?
      BattleHandlers.triggerDamageCalcUserItem(user.item,
         user,target,self,multipliers,baseDmg,type)
    end
    if target.itemActive?
      BattleHandlers.triggerDamageCalcTargetItem(target.item,
         user,target,self,multipliers,baseDmg,type)
    end
    # Parental Bond's second attack
    if user.effects[PBEffects::ParentalBond]==1
      multipliers[:base_damage_multiplier] /= 4
    end
    if user.effects[PBEffects::Ambidextrous]==1
      multipliers[:base_damage_multiplier] /= 4
    end
    if user.effects[PBEffects::EchoChamber]==1
      multipliers[:base_damage_multiplier] /= 4
    end
    if user.effects[PBEffects::Ricochet]==1
      multipliers[:base_damage_multiplier] /= 4
    end
    # Other
    if user.effects[PBEffects::MeFirst]
      multipliers[:base_damage_multiplier] *= 1.5
    end
    if user.effects[PBEffects::HelpingHand] && !self.is_a?(PokeBattle_Confusion)
      multipliers[:base_damage_multiplier] *= 1.5
    end
    if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
      multipliers[:base_damage_multiplier] *= 2
    end
    # Mud Sport
    if type == :ELECTRIC
      @battle.eachBattler do |b|
        next if !b.effects[PBEffects::MudSport]
        multipliers[:base_damage_multiplier] /= 3
        break
      end
      if @battle.field.effects[PBEffects::MudSportField]>0
        multipliers[:base_damage_multiplier] /= 3
      end
    end
    # Water Sport
    if type == :FIRE
      @battle.eachBattler do |b|
        next if !b.effects[PBEffects::WaterSport]
        multipliers[:base_damage_multiplier] /= 3
        break
      end
      if @battle.field.effects[PBEffects::WaterSportField]>0
        multipliers[:base_damage_multiplier] /= 3
      end
    end
    # Terrain moves
    case @battle.field.field_effects
    when :Electric
      multipliers[:base_damage_multiplier] *= 1.5 if type == :ELECTRIC && user.affectedByTerrain?
    when :Grassy
      multipliers[:base_damage_multiplier] *= 1.5 if type == :GRASS && user.affectedByTerrain?
    when :Psychic
      multipliers[:base_damage_multiplier] *= 1.5 if type == :PSYCHIC && user.affectedByTerrain?
    when :Misty
      multipliers[:base_damage_multiplier] /= 2 if type == :DRAGON && target.affectedByTerrain?
    when :Poison
      multipliers[:base_damage_multiplier] *= 1.5 if type == :POISON && user.affectedByTerrain?
    end
    # Badge multipliers
    if @battle.internalBattle
      if user.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_ATTACK
          multipliers[:attack_multiplier] *= 1.1
        elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPATK
          multipliers[:attack_multiplier] *= 1.1
        end
      end
      if target.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
          multipliers[:defense_multiplier] *= 1.1
        elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
          multipliers[:defense_multiplier] *= 1.1
        end
      end
    end
    # Multi-targeting attacks
    if numTargets>1
      multipliers[:final_damage_multiplier] *= 0.75
    end
    # Weather
    case @battle.pbWeather
    when :Sun, :HarshSun
      if type == :FIRE
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :WATER && !target.hasActiveAbility?(:STEAMPOWERED)
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Rain, :HeavyRain
      if type == :FIRE && !target.hasActiveAbility?(:STEAMPOWERED)
        multipliers[:final_damage_multiplier] /= 2
      elsif type == :WATER
        multipliers[:final_damage_multiplier] *= 1.5
      end
    when :Hail
      if Settings::GEN_9_SNOW == true
        if target.pbHasType?(:ICE) && (physicalMove? || @function="122")
          multipliers[:defense_multiplier] *= 1.5
        end
     end
    when :Starstorm
     if type == :COSMIC
       multipliers[:final_damage_multiplier] *= 1.5
     elsif type == :STEEL
       multipliers[:final_damage_multiplier] /= 2
     elsif target.pbHasType?(:COSMIC) && (physicalMove? || @function="122")
       multipliers[:defense_multiplier] *= 1.5
     end
    when :Windy
      if type == :ROCK || type == :ICE
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Fog
      if type == :DRAGON
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Eclipse
      if type == :DARK
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :GHOST
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :FAIRY && !user.hasActiveAbility?(:NOCTEMBOOST)
        multipliers[:final_damage_multiplier] /= 2
      elsif type == :PSYCHIC
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Borealis
      if type == :PSYCHIC
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :DARK
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Rainbow
      if type == :GRASS
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :ICE
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Overcast
      if type == :DARK
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :GHOST
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :FAIRY
        multipliers[:final_damage_multiplier] /= 2
      elsif type == :PSYCHIC
        multipliers[:final_damage_multiplier] /= 2
      end
    when :VolcanicAsh
      if type == :STEEL
        multipliers[:final_damage_multiplier] *= 1.5
      end
    when :Storm
      if type == :FIRE && !target.hasActiveAbility?(:STEAMPOWERED)
        multipliers[:final_damage_multiplier] /= 2
      elsif type == :WATER
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :ELECTRIC
        multipliers[:final_damage_multiplier] *= 1.5
      end
    when :Humid
      if type == :BUG
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :FIRE
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Sleet
      if type == :FIRE
        multipliers[:final_damage_multiplier] /= 2
      end
    when :AcidRain
      if target.pbHasType?(:POISON) && (physicalMove? || @function="122")
        multipliers[:defense_multiplier] *= 1.5
      end
    when :Sandstorm
      if target.pbHasType?(:ROCK) && specialMove? && @function != "122"   # Psyshock
        multipliers[:defense_multiplier] *= 1.5
      end
    end
    # Critical hits
    if target.damageState.critical
      if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
        multipliers[:final_damage_multiplier] *= 1.5
      else
        multipliers[:final_damage_multiplier] *= 2
      end
    end
    # Random variance
    if !self.is_a?(PokeBattle_Confusion)
      random = 85+@battle.pbRandom(16)
      multipliers[:final_damage_multiplier] *= random / 100.0
    end
    # STAB
    if type && user.pbHasType?(type)
      if user.hasActiveAbility?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end
    # Type effectiveness
    multipliers[:final_damage_multiplier] *= target.damageState.typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
    # Burn
    if user.status == :BURN && physicalMove? && damageReducedByBurn? &&
       !user.hasActiveAbility?(:GUTS)
      multipliers[:final_damage_multiplier] /= 2
    end
    #Frostbite
    if user.status == :FROZEN && specialMove? && damageReducedByFreeze?
      multipliers[:final_damage_multiplier] /= 2
    end
    # Aurora Veil, Reflect, Light Screen
    if !ignoresReflect? && !target.damageState.critical &&
       !user.hasActiveAbility?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @battle.pbSideBattlerCount(target)>1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?
        if @battle.pbSideBattlerCount(target)>1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end
    # Minimize
    if target.effects[PBEffects::Minimize] && tramplesMinimize?(2)
      multipliers[:final_damage_multiplier] *= 2
    end
    # Glaive Rush
    multipliers[:final_damage_multiplier] *= 2 if target.effects[PBEffects::GlaiveRush] > 0
    # Move-specific base damage modifiers
    multipliers[:base_damage_multiplier] = pbBaseDamageMultiplier(multipliers[:base_damage_multiplier], user, target)
    # Move-specific final damage modifiers
    multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
    # Field Effects
    fe = FIELD_EFFECTS[@battle.field.field_effects]
     if fe[:field_changers] != nil
       priority = @battle.pbPriority(true)
       msg = nil
       for fc in fe[:field_changers].keys
        if @battle.field.field_effects != :None
          if fe[:field_changers][fc].include?(self.id) && fe[:field_change_conditions][fc] != nil && fe[:field_change_conditions][fc] == true
            for message in fe[:change_message].keys
              msg = message if fe[:change_message][message].include?(self.id)
            end
            @battle.pbDisplay(_INTL("#{msg}")) if msg != nil
            @battle.field.field_effects = fc
            fe = FIELD_EFFECTS[@battle.field.field_effects]
            @battle.scene.pbChangeField(@battle.field.field_effects)
            @battle.scene.pbRefreshEverything
            #@battle.field.weather == :None
            priority.each do |pkmn|
              if pkmn.hasActiveAbility?([fe[:abilities]])
                for key in fe[:ability_effects].keys
                  if pkmn.ability != fc
                    abil = nil
                  else
                    abil = fe[:ability_effects][pkmn.ability]
                  end
                  if pkmn.ability == fc && abil.is_a?(Array)
                    trigger = true
                  end
                end
                BattleHandlers.triggerAbilityOnSwitchIn(fc,pkmn,@battle) if trigger
                pkmn.pbRaiseStatStage(abil[0],abil[1],user) if abil != nil && !trigger
              end
            end
          end
        end
      end
    end
   #Field Effect Type Boosts
     trigger = false
     mesg = false
     if fe[:type_damage_change] != nil
       for key in fe[:type_damage_change].keys
         if @battle.field.field_effects != :None
          if fe[:type_damage_change][key].include?(type)
            multipliers[:final_damage_multiplier] *= key
            mesg = true
          end
          if mesg == true
            for mess in fe[:type_messages].keys
              msg1 = mess if fe[:type_messages][mess].include?(type)
            end
            @battle.pbDisplay(_INTL("#{msg1}")) if $test_trigger == false
          end
         end
       end
     end
     #Field Effect Specific Move Boost
     if fe[:move_damage_boost] != nil
       for dmg in fe[:move_damage_boost].keys
         if @battle.field.field_effects != :None
          if fe[:move_damage_boost][dmg].is_a?(Array)
            if fe[:move_damage_boost][dmg].any? {|d| d.include?(self.id)}
              multipliers[:final_damage_multiplier] *= dmg 
              mesg = true
            end
          elsif self.id == fe[:move_damage_boost][dmg]
            multipliers[:final_damage_multiplier] *= dmg
            mesg = true
          end
          if mesg == true
            for mess in fe[:move_messages].keys
              if fe[:move_messages][mess].is_a?(Array)
                msg2 = mess if fe[:move_messages][mess].any? {|m| m.include?(self.id)}
              else
                msg2 = mess if GameData::Move.get(fe[:move_messages][mess]).id == self.id
              end
            end
            @battle.pbDisplay(_INTL("#{msg2}")) if $test_trigger == false
          end
         end
       end
     end

    #Field Effect Defensive Modifiers
     if fe[:defensive_modifiers] != nil
      priority = @battle.pbPriority(true)
      msg = nil
      for d in fe[:defensive_modifiers].keys
        if fe[:defensive_modifiers][d][1] == "fullhp"
          multipliers[:final_damage_multiplier] /= d
        elsif fe[:defensive_modifiers][d][1] == "physical"
          multipliers[DEF_MULT] *= d if physicalMove?
        elsif fe[:defensive_modifiers][d][1] == "special"
          multipliers[DEF_MULT] *= d if specialMove?
        elsif fe[:defensive_modifiers][d][1] == nil
          multipliers[DEF_MULT] *= d
        end
      end
    end
    #Additional Effects of Field Effects
     if fe[:side_effects] != nil
      priority = @battle.pbPriority(true)
      msg = nil
      f = fe[:side_effects].keys
      for eff in fe[:side_effects].keys
        if (fe[:side_effects][eff].is_a?(Array) && fe[:side_effects][eff].include?(self.id)) || (!fe[:side_effects][eff].is_a?(Array) && type == GameData::Type.get(fe[:side_effects][eff]).id)
          case eff
          when "sand"
            pbStartWeather(nil,:Sandstorm)
          when "cinders"
            if target.affectedByCinders?
              target.effects[PBEffects::Cinders] = 3
              @battle.pbDisplay(_INTL("{1} had cinders blown into their eyes!",target.pbThis)) if $test_trigger == false
            end
          when "hurricane"
            @battle.pbDisplay(_INTL("The attack whipped up a hurricane!")) if $test_trigger == false
            @battle.field.effects[PBEffects::Hurricane] = 3
          when "spirits"
            @battle.pbDisplay(_INTL("The attack stirred up restless spirits!")) if $test_trigger == false
            @battle.field.effects[PBEffects::Spirits] = 3
          end
        end
      end
    end
  end


  def pbCalcTypeModSingle(moveType, defType, user, target)
    ret = Effectiveness.calculate_one(moveType, defType)
    if Effectiveness.ineffective_type?(moveType, defType)
      # Ring Target
      if target.hasActiveItem?(:RINGTARGET)
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      # Foresight
      if (user.hasActiveAbility?([:SCRAPPY,:MINDSEYE]) || target.effects[PBEffects::Foresight]) &&
         defType == :GHOST
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      if user.hasActiveAbility?(:NITRIC)
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :STEEL &&
                                                   Effectiveness.ineffective_type?(moveType, defType)
      end
      # Miracle Eye
      if target.effects[PBEffects::MiracleEye] && defType == :DARK
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      if user.activeField == :DragonsDen
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FAIRY && Effectiveness.ineffective_type?(moveType,defType)
      end
      if user.activeField == :Water
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :GROUND && Effectiveness.ineffective_type?(moveType,defType)
      end
      if user.activeField == :Underwater
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE if !Effectiveness.super_effective_type?(moveType,defType) && moveType == :ELECTRIC
      end
    elsif Effectiveness.super_effective_type?(moveType, defType)
      # Delta Stream's weather
      if @battle.pbWeather == :StrongWinds
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING &&
                                                   Effectiveness.super_effective_type?(moveType, defType)
    end
    if @battle.pbWeather == :StrongWinds
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :DRAGON &&
                                                   Effectiveness.super_effective_type?(moveType, defType)
    end
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne? && defType == :FLYING && moveType == :GROUND
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE
    end
  	fe = FIELD_EFFECTS[@battle.field.field_effects]
  	if fe[:type_type_mod] != nil
  		for key in fe[:type_type_mod].keys
  			if fe[:type_type_mod][key] == moveType
  				eff = Effectiveness.calculate_one(key,defType)
  				ret *= eff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
  				for mess in fe[:type_mod_message].keys
  					@battle.pbDisplay(_INTL("#{mess}")) if fe[:type_mod_message][mess] == moveType
  				end
  			end
  		end
  	end
  	if fe[:move_type_mod] != nil
  		for mv in fe[:move_type_mod].keys
  			if fe[:move_type_mod][mv].any? {|md| md.include?(self.id)}
  				eff = Effectiveness.calculate_one(mv,defType)
  				ret *= eff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
  				for msg in fe[:move_messages].keys
            for mo in fe[:move_damage_boost].keys
  					 @battle.pbDisplay(_INTL("#{msg}")) if fe[:move_messages][msg].any? {|m| m.include?(self.id)} && !fe[:move_damage_boost][mo].any? {|mm| mm.include?(self.id)}
            end
  				end
  			end
  		end
  	end
    return ret
  end
end