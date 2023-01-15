#===============
# Weather
#===============
begin
  module PBFieldWeather
    None        = 0   # None must be 0 (preset RMXP weather)
    Rain        = 1   # Rain must be 1 (preset RMXP weather)
    Storm       = 2   # Storm must be 2 (preset RMXP weather)
    Snow        = 3   # Snow must be 3 (preset RMXP weather)
    Blizzard    = 4
    Sandstorm   = 5
    HeavyRain   = 6
    Sun = Sunny = 7 #8 is ShadowSky so we leave that blank
    ShadowSky   = 8
    Starstorm   = 9
    Overcast    = 10
    Sleet       = 11
    Fog         = 12
    Eclipse     = 13
    StrongWinds = 14
    Windy       = 15
    Thunder     = 16 # Thunderstorm
    AcidRain    = 17
    Humid       = 18
    Supercell   = 19
    HeatLight   = 20 # Heat Lightning
    Rainbow     = 21
    DustDevil   = 22
    DClear      = 23 # Distortion World - Clear
    DWind       = 24 # Distortion World - Windy
    DAshfall    = 25 # Distortion World - Ashfall
    DRain       = 26 # Distortion World - Rain
    VolcanicAsh = 27
    Borealis    = 28 # Northern Lights
    TimeWarp    = 29
    Reverb      = 30
    HarshSun    = 31

    def PBFieldWeather.maxValue; return 31; end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end

#===================
#Overworld Weather
#===================

GameData::Weather.register({
  :id               => :AcidRain,
  :id_number        => 17,
  :category         => :AcidRain,
  :graphics         => [["acidrain_1", "acidrain_2", "acidrain_3", "acidrain_4"]],   # Last is splash
  :particle_delta_x => -300,
  :particle_delta_y => 1200,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 4, -strength * 3 / 4, -strength * 3 / 4, 10)
  }
})
GameData::Weather.register({
  :id               => :VolcanicAsh,
  :id_number        => 27,
  :category         => :VolcanicAsh,
  :graphics         => [["volc_1", "volc_2", "volc_3"]],
  :particle_delta_x => -120,
  :particle_delta_y => 120,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 4, -strength * 3 / 4, -strength * 3 / 4, 20)
  }
})
GameData::Weather.register({
  :id               => :DAshfall,
  :id_number        => 25,
  :category         => :DAshfall,
  :graphics         => [["volc_1", "volc_2", "volc_3"]],
  :particle_delta_x => -2400,
  :particle_delta_y => -480,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 6 / 4, -strength * 6 / 4, -strength * 6 / 4, 20)
  }
})
GameData::Weather.register({
  :id               => :Starstorm,
  :id_number        => 9,
  :category         => :Starstorm,
  :graphics         => [["hail_1", "hail_2", "hail_3"]],
  :particle_delta_x => -240,
  :particle_delta_y => 10,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 2, -strength * 3 / 2, -strength * 3 / 2, 20)
  }
})
GameData::Weather.register({
  :id               => :HarshSun,
  :id_number        => 31,
  :category         => :HarshSun,
  :tone_proc        => proc { |strength|
    next Tone.new(172, 64, 32, 0)
  }
})
GameData::Weather.register({
  :id               => :Overcast,
  :id_number        => 8,
  :category         => :Overcast,
  :tone_proc        => proc{ |strength|
    next Tone.new(-strength * 6 / 4, -strength * 6 / 4, -strength * 6 / 4, 20)
  }
})
GameData::Weather.register({
  :id               => :Eclipse,
  :id_number        => 13,
  :category         => :Eclipse,
  :tone_proc        => proc{ |strength|
    next Tone.new(-strength * 9 / 4, -strength * 9 / 4, -strength * 9 / 4, 20)
  }
})
GameData::Weather.register({
  :id               => :Windy,
  :id_number        => 15,   # Must be 1 (preset RMXP weather)
  :category         => :Windy,
  :graphics         => [["windy_1", "windy_2", "windy_3"]],   # Last is splash
  :particle_delta_x => -120,
  :particle_delta_y => 10,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 4, -strength * 3 / 4, -strength * 3 / 4, 20)
  }
})
GameData::Weather.register({
  :id               => :Humid,
  :id_number        => 18,
  :category         => :Humid,
  :graphics         => [["hail_1", "hail_2", "hail_3"]],
  :particle_delta_x => -10,
  :particle_delta_y => 10,
  :tone_proc        => proc { |strength|
    next Tone.new(0,128,45,0)
  }
})
GameData::Weather.register({
  :id               => :Sleet,
  :id_number        => 11,
  :category         => :Sleet,
  :graphics         => [["blizzard_1", "blizzard_2", "blizzard_3", "blizzard_4"], ["blizzard_tile"]],
  :particle_delta_x => -960,
  :particle_delta_y => 240,
  :tile_delta_x     => -1440,
  :tile_delta_y     => 0,
  :tone_proc        => proc { |strength|
    next Tone.new(strength * 3 / 4, strength * 3 / 4, strength * 3 / 4, 0)
  }
})
GameData::Weather.register({
  :id               => :Storm,
  :id_number        => 2,   # Must be 2 (preset RMXP weather)
  :category         => :Storm,
  :graphics         => [["storm_1", "storm_2", "storm_3", "storm_4"]],   # Last is splash
  :particle_delta_x => -4800,
  :particle_delta_y => 4800,
  :tone_proc        => proc { |strength|
    next Tone.new(-strength * 3 / 2, -strength * 3 / 2, -strength * 3 / 2, 20)
  }
})
GameData::Weather.register({
  :id               => :DustDevil,
  :id_number        => 22,
  :category         => :DustDevil,
  :graphics         => [["sandstorm_1", "sandstorm_2", "sandstorm_3", "sandstorm_4"], ["sandstorm_tile"]],
  :particle_delta_x => -150,
  :particle_delta_y => -15,
  :tile_delta_x     => -320,
  :tile_delta_y     => 0,
  :tone_proc        => proc { |strength|
    next Tone.new(strength / 2, 0, -strength / 2, 0)
  }
})
GameData::Weather.register({
  :id               => :StrongWinds,
  :id_number        => 15,   # Must be 1 (preset RMXP weather)
  :category         => :StrongWinds,
  :graphics         => [["windy_1", "windy_2", "windy_3"]],   # Last is splash
  :particle_delta_x => -650,
  :particle_delta_y => 20,
  :tone_proc        => proc { |strength|
    next Tone.new(0,76,36,15)
  }
})
GameData::Weather.register({
  :id               => :Fog,
  :category         => :Fog,
  :id_number        => 12,
  :tile_delta_x     => -32,
  :tile_delta_y     => 0,
  :graphics         => [nil, ["fog_tile"]]
})
GameData::Weather.register({
  :id               => :Rainbow,
  :category         => :Rainbow,
  :id_number        => 21,
  :tile_delta_x     => 0,
  :tile_delta_y     => 0,
  :graphics         => [nil, ["rainbow_tile"]]
})
GameData::Weather.register({
  :id               => :HeatLight,
  :id_number        => 20,   # Must be 2 (preset RMXP weather)
  :category         => :HeatLight,
  :tone_proc        => proc { |strength|
    next Tone.new(255,0,0,100)
  }
})
GameData::Weather.register({
  :id               => :Borealis,
  :id_number        => 28,
  :category         => :Borealis,
  :graphics         => [["hail_1", "hail_2", "hail_3"]],
  :particle_delta_x => -10,
  :particle_delta_y => 10,
  :tone_proc        => proc { |strength|
    next Tone.new(64,0,255,15)
  }
})
GameData::Weather.register({
  :id               => :TimeWarp,
  :id_number        => 29,
  :category         => :TimeWarp,
  :tone_proc        => proc { |strength|
    next Tone.new(20,-74,-60,0)
  }
})
GameData::Weather.register({
  :id               => :Reverb,
  :id_number        => 30,
  :category         => :Reverb,
  :tone_proc        => proc { |strength|
    next Tone.new(20,44,80,0)
  }
})

#=========================
#Battle Weather
#=========================

GameData::BattleWeather.register({
  :id        => :Starstorm,
  :name      => _INTL("Starstorm"),
  :animation => "ShadowSky"
})
GameData::BattleWeather.register({
  :id        => :Overcast,
  :name      => _INTL("Overcast"),
})
GameData::BattleWeather.register({
  :id        => :Sleet,
  :name      => _INTL("Sleet"),
  :animation => "Hail"
})
GameData::BattleWeather.register({
  :id        => :Fog,
  :name      => _INTL("Fog"),
  :animation => "Fog"
})
GameData::BattleWeather.register({
  :id        => :Eclipse,
  :name      => _INTL("Eclipse"),
  :animation => "ShadowSky"
})
GameData::BattleWeather.register({
  :id        => :Windy,
  :name      => _INTL("Windy"),
})
GameData::BattleWeather.register({
  :id        => :Storm,
  :name      => _INTL("Storm"),
  :animation => "HeavyRain"
})
GameData::BattleWeather.register({
  :id        => :AcidRain,
  :name      => _INTL("Acid Rain"),
  :animation => "Rain"
})
GameData::BattleWeather.register({
  :id        => :Humid,
  :name      => _INTL("Humid"),
})
GameData::BattleWeather.register({
  :id        => :HeatLight,
  :name      => _INTL("Heat Lightning"),
})
GameData::BattleWeather.register({
  :id        => :Rainbow,
  :name      => _INTL("Rainbow"),
})
GameData::BattleWeather.register({
  :id        => :DustDevil,
  :name      => _INTL("Dust Devil"),
  :animation => "Sandstorm"
})
GameData::BattleWeather.register({
  :id        => :DAshfall,
  :name      => _INTL("Distorted Ashfall")
})
GameData::BattleWeather.register({
  :id        => :VolcanicAsh,
  :name      => _INTL("Volcanic Ash"),
})
GameData::BattleWeather.register({
  :id        => :Borealis,
  :name      => _INTL("Northern Lights"),
})
GameData::BattleWeather.register({
  :id        => :TimeWarp,
  :name      => _INTL("Temporal Rift"),
})
GameData::BattleWeather.register({
  :id        => :Reverb,
  :name      => _INTL("Echo Chamber"),
})

#====================
#Battle Terrain
#====================

GameData::BattleTerrain.register({
  :id        => :Poison,
  :name      => _INTL("Poison"),
  :animation => "PsychicTerrain"
})
