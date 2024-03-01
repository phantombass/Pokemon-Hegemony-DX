module GameData
  class Encounter
    attr_accessor :id
    attr_accessor :map
    attr_accessor :version
    attr_reader :step_chances
    attr_reader :types
    attr_reader :random_encounters

    DATA = {}
    DATA_FILENAME = "encounters.dat"
    PBS_BASE_FILENAME = "encounters"

    extend ClassMethodsSymbols
    include InstanceMethods

    # @param map_id [Integer]
    # @param map_version [Integer, nil]
    # @return [Boolean] whether there is encounter data for the given map ID/version
    def self.exists?(map_id, map_version = 0)
      randEnc = pbGet(972)
      validate map_id => [Integer]
      validate map_version => [Integer]
      key = sprintf("%s_%d", map_id, map_version).to_sym
      return randEnc == 0 ? !self::DATA[key].nil? : !randEnc[key].nil?
    end

    # @param map_id [Integer]
    # @param map_version [Integer, nil]
    # @return [self, nil]
    def self.get(map_id, map_version = 0)
      validate map_id => Integer
      validate map_version => Integer
      trial_key = sprintf("%s_%d", map_id, map_version).to_sym
      key = (self::DATA.has_key?(trial_key)) ? trial_key : sprintf("%s_0", map_id).to_sym
      return self::DATA[key]
    end

    # Yields all encounter data in order of their map and version numbers.
    def self.each
      randEnc = pbGet(972)
      if randEnc == 0
        keys = self::DATA.keys.sort do |a, b|
          if self::DATA[a].map == self::DATA[b].map
            self::DATA[a].version <=> self::DATA[b].version
          else
            self::DATA[a].map <=> self::DATA[b].map
          end
        end
        keys.each { |key| yield self::DATA[key] }
      else
        keys = randEnc.keys.sort do |a, b|
          if randEnc[a].map == randEnc[b].map
            randEnc[a].version <=> randEnc[b].version
          else
            randEnc[a].map <=> randEnc[b].map
          end
        end
        keys.each { |key| yield randEnc[key] }
      end
    end

    # Yields all encounter data for the given version. Also yields encounter
    # data for version 0 of a map if that map doesn't have encounter data for
    # the given version.
    def self.each_of_version(version = 0)
      randEnc = pbGet(972)
      self.each do |data|
        yield data if data.version == version
        if version > 0
          if randEnc == 0
            yield data if data.version == 0 && !self::DATA.has_key?([data.map, version])
          else
            yield data if data.version == 0 && !randEnc.has_key?([data.map, version])
          end
        end
      end
    end

    def initialize(hash)
      @id           = hash[:id]
      @map          = hash[:map]
      @version      = hash[:version]      || 0
      @step_chances = hash[:step_chances]
      @types        = hash[:types]        || {}
      @random_encounters = pbGet(975)
    end
  end
end

#===============================================================================
# Deprecated methods
#===============================================================================
# @deprecated This alias is slated to be removed in v20.
def pbLoadEncountersData
  Deprecation.warn_method('pbLoadEncountersData', 'v20', 'GameData::Encounter.get(map_id, version)')
  return nil
end
