#===================================
# Terrain Tags and Encounters
#===================================
class PokemonEncounters
  def has_sandy_encounters?
    GameData::EncounterType.each do |enc_type|
      return true if enc_type.type == :sand && has_encounter_type?(enc_type.id)
    end
    return false
  end
  def has_graveyard_encounters?
    GameData::EncounterType.each do |enc_type|
      return true if enc_type.type == :graveyard && has_encounter_type?(enc_type.id)
    end
    return false
  end
  def has_snow_encounters?
    GameData::EncounterType.each do |enc_type|
      return true if enc_type.type == :snow && has_encounter_type?(enc_type.id)
    end
    return false
  end
  def has_high_bridge_encounters?
    GameData::EncounterType.each do |enc_type|
      return true if enc_type.type == :highbridge && has_encounter_type?(enc_type.id)
    end
    return false
  end
  def has_distortion_encounters?
    GameData::EncounterType.each do |enc_type|
      return true if enc_type.type == :distortion && has_encounter_type?(enc_type.id)
    end
    return false
  end
  def encounter_possible_here?
    return true if $PokemonGlobal.surfing
    terrain_tag = $game_map.terrain_tag($game_player.x, $game_player.y)
    return false if terrain_tag.ice
    return true if has_cave_encounters?   # i.e. this map is a cave
    return true if has_land_encounters? && terrain_tag.land_wild_encounters
    return true if has_sandy_encounters? && terrain_tag.sand_wild_encounters
    return true if has_graveyard_encounters? && terrain_tag.graveyard_wild_encounters
    return true if has_snow_encounters? && terrain_tag.snow_wild_encounters
    return true if has_high_bridge_encounters? && terrain_tag.high_bridge_wild_encounters
    return true if has_distortion_encounters? && terrain_tag.distortion_wild_encounters
    return false
  end
  def encounter_type
    time = pbGetTimeNow
    ret = nil
    if $PokemonGlobal.surfing
      ret = find_valid_encounter_type_for_time(:Water, time)
    else   # Land/Cave (can have both in the same map)
      if has_land_encounters? && $game_map.terrain_tag($game_player.x, $game_player.y).land_wild_encounters
        ret = :BugContest if pbInBugContest? && has_encounter_type?(:BugContest)
        ret = find_valid_encounter_type_for_time(:Land, time) if !ret
      end
      if has_sandy_encounters? && $game_map.terrain_tag($game_player.x, $game_player.y).sand_wild_encounters
        ret = find_valid_encounter_type_for_time(:Sandy, time) if !ret
      end
      if has_graveyard_encounters? && $game_map.terrain_tag($game_player.x, $game_player.y).graveyard_wild_encounters
        ret = find_valid_encounter_type_for_time(:Graveyard, time) if !ret
      end
      if has_high_bridge_encounters? && $game_map.terrain_tag($game_player.x, $game_player.y).high_bridge_wild_encounters
        ret = find_valid_encounter_type_for_time(:HighBridge, time) if !ret
      end
      if has_snow_encounters? && $game_map.terrain_tag($game_player.x, $game_player.y).snow_wild_encounters
        ret = find_valid_encounter_type_for_time(:Snow, time) if !ret
      end
      if has_distortion_encounters? && $game_map.terrain_tag($game_player.x, $game_player.y).distortion_wild_encounters
        ret = find_valid_encounter_type_for_time(:Distortion, time) if !ret
      end
      if !ret && has_cave_encounters?
        ret = find_valid_encounter_type_for_time(:Cave, time)
      end
    end
    return ret
  end
end
module GameData
  class TerrainTag
    attr_reader :rock_climb
    attr_reader :sand_wild_encounters
    attr_reader :snow_wild_encounters
    attr_reader :distortion_wild_encounters
    attr_reader :high_bridge_wild_encounters
    attr_reader :graveyard_wild_encounters
    def initialize(hash)
      @id                     = hash[:id]
      @id_number              = hash[:id_number]
      @real_name              = hash[:id].to_s                || "Unnamed"
      @can_surf               = hash[:can_surf]               || false
      @waterfall              = hash[:waterfall]              || false
      @rock_climb             = hash[:rock_climb]             || false
      @waterfall_crest        = hash[:waterfall_crest]        || false
      @can_fish               = hash[:can_fish]               || false
      @can_dive               = hash[:can_dive]               || false
      @deep_bush              = hash[:deep_bush]              || false
      @shows_grass_rustle     = hash[:shows_grass_rustle]     || false
      @land_wild_encounters   = hash[:land_wild_encounters]   || false
      @sand_wild_encounters   = hash[:sand_wild_encounters]   || false
      @snow_wild_encounters   = hash[:snow_wild_encounters]   || false
      @distortion_wild_encounters   = hash[:distortion_wild_encounters]   || false
      @high_bridge_wild_encounters   = hash[:high_bridge_wild_encounters]   || false
      @graveyard_wild_encounters   = hash[:graveyard_wild_encounters]   || false
      @double_wild_encounters = hash[:double_wild_encounters] || false
      @battle_environment     = hash[:battle_environment]
      @ledge                  = hash[:ledge]                  || false
      @ice                    = hash[:ice]                    || false
      @bridge                 = hash[:bridge]                 || false
      @shows_reflections      = hash[:shows_reflections]      || false
      @must_walk              = hash[:must_walk]              || false
      @ignore_passability     = hash[:ignore_passability]     || false
    end
  end
end

GameData::TerrainTag.register({
  :id                     => :Distortion,
  :id_number              => 17,
  :distortion_wild_encounters   => true,
  :battle_environment     => :Distortion
})

GameData::TerrainTag.register({
  :id                     => :HighBridge,
  :id_number              => 18,
  :high_bridge_wild_encounters   => true
})

GameData::TerrainTag.register({
  :id                     => :RockClimb,
  :id_number              => 19,
  :rock_climb             => true
})

GameData::TerrainTag.register({
  :id                     => :Sandy,
  :id_number              => 20,
  :sand_wild_encounters   => true,
  :battle_environment     => :Sand
})

GameData::TerrainTag.register({
  :id                     => :Graveyard,
  :id_number              => 21,
  :graveyard_wild_encounters   => true,
  :battle_environment     => :Graveyard
})

GameData::TerrainTag.register({
  :id                     => :Snow,
  :id_number              => 22,
  :snow_wild_encounters   => true,
  :battle_environment     => :Ice
})

GameData::EncounterType.register({
  :id             => :Distortion,
  :type           => :distortion,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :HighBridge,
  :type           => :highbridge,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :Graveyard,
  :type           => :graveyard,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :Snow,
  :type           => :snow,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :Sandy,
  :type           => :sand,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})
