module GameData
  class SpeciesMetrics
    attr_reader   :id
    attr_reader   :species
    attr_reader   :form
    attr_accessor :back_sprite
    attr_accessor :front_sprite
    attr_accessor :front_sprite_altitude
    attr_accessor :shadow_x
    attr_accessor :shadow_size
    attr_accessor :front_sprite_scale
    attr_accessor :back_sprite_scale

    DATA = {}
    DATA_FILENAME = "species_metrics.dat"
    PBS_BASE_FILENAME = "pokemon_metrics"

    SCHEMA = {
      "BackSprite"          => [0, "ii"],
      "FrontSprite"         => [0, "ii"],
      "FrontSpriteAltitude" => [0, "i"],
      "ShadowX"             => [0, "i"],
      "ShadowSize"          => [0, "u"],
      "FrontSpriteScale"  => [0, "i"],
      "BackSpriteScale"   => [0, "i"],
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    # @param species [Symbol, String]
    # @param form [Integer]
    # @return [self, nil]
    def self.get_species_form(species, form)
      return nil if !species || !form
      validate species => [Symbol, String]
      validate form => Integer
      raise _INTL("Undefined species {1}.", species) if !GameData::Species.exists?(species)
      species = species.to_sym if species.is_a?(String)
      if form > 0
        trial = sprintf("%s_%d", species, form).to_sym
        if !DATA.has_key?(trial)
          self.register({ :id => species }) if !DATA[species]
          self.register({
            :id                    => trial,
            :species               => species,
            :form                  => form,
            :back_sprite           => DATA[species].back_sprite.clone,
            :front_sprite          => DATA[species].front_sprite.clone,
            :front_sprite_altitude => DATA[species].front_sprite_altitude,
            :shadow_x              => DATA[species].shadow_x,
            :shadow_size           => DATA[species].shadow_size,
            :front_sprite_scale    => DATA[species].front_sprite_scale,
            :back_sprite_scale     => DATA[species].back_sprite_scale
          })
        end
        return DATA[trial]
      end
      self.register({ :id => species }) if !DATA[species]
      return DATA[species]
    end

    def initialize(hash)
      @id                    = hash[:id]
      @species               = hash[:species]               || @id
      @form                  = hash[:form]                  || 0
      @back_sprite           = hash[:back_sprite]           || [0, 0]
      @front_sprite          = hash[:front_sprite]          || [0, 0]
      @front_sprite_altitude = hash[:front_sprite_altitude] || 0
      @shadow_x              = hash[:shadow_x]              || 0
      @shadow_size           = hash[:shadow_size]           || 2
      @front_sprite_scale = hash[:front_sprite_scale] || Settings::FRONT_BATTLER_SPRITE_SCALE
      @back_sprite_scale  = hash[:back_sprite_scale]  || Settings::BACK_BATTLER_SPRITE_SCALE
    end

    def apply_metrics_to_sprite(sprite, index, shadow = false)
      if shadow
        if (index & 1) == 1    # Foe Pokémon
          sprite.x += @shadow_x * 2
        end
      elsif (index & 1) == 0   # Player's Pokémon
        sprite.x += @back_sprite[0] * 2
        sprite.y += @back_sprite[1] * 2
      else                     # Foe Pokémon
        sprite.x += @front_sprite[0] * 2
        sprite.y += @front_sprite[1] * 2
        sprite.y -= @front_sprite_altitude * 2
      end
    end

    def shows_shadow?
      return true
#      return @front_sprite_altitude > 0
    end
  end
end
