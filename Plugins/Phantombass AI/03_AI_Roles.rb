module GameData
  class Role
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name

    DATA = {}

    extend ClassMethods
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id           = hash[:id]
      @id_number    = hash[:id_number]    || -1
      @real_name    = hash[:name]         || "Unnamed"
    end

    # @return [String] the translated name of this Role
    def name
      return _INTL(@real_name)
    end
  end
end

GameData::Role.register({
  :id           => :PHYSICALWALL,
  :id_number    => 0,
  :name         => _INTL("Physical Wall")
})

GameData::Role.register({
  :id           => :SPECIALWALL,
  :id_number    => 1,
  :name         => _INTL("Special Wall")
})

GameData::Role.register({
  :id           => :STALLBREAKER,
  :id_number    => 2,
  :name         => _INTL("Stallbreaker")
})

GameData::Role.register({
  :id           => :PHYSICALBREAKER,
  :id_number    => 3,
  :name         => _INTL("Physical Breaker")
})

GameData::Role.register({
  :id           => :SPECIALBREAKER,
  :id_number    => 4,
  :name         => _INTL("Special Breaker")
})

GameData::Role.register({
  :id           => :TANK,
  :id_number    => 5,
  :name         => _INTL("Tank")
})

GameData::Role.register({
  :id           => :LEAD,
  :id_number    => 5,
  :name         => _INTL("Lead")
})

GameData::Role.register({
  :id           => :CLERIC,
  :id_number    => 7,
  :name         => _INTL("Cleric")
})

GameData::Role.register({
  :id           => :REVENGEKILLER,
  :id_number    => 8,
  :name         => _INTL("Revenge Killer")
})

GameData::Role.register({
  :id           => :WINCON,
  :id_number    => 9,
  :name         => _INTL("Win Condition")
})

GameData::Role.register({
  :id           => :TOXICSTALLER,
  :id_number    => 10,
  :name         => _INTL("Toxic Staller")
})

GameData::Role.register({
  :id           => :SETUPSWEEPER,
  :id_number    => 11,
  :name         => _INTL("Setup Sweeper")
})

GameData::Role.register({
  :id           => :HAZARDREMOVAL,
  :id_number    => 12,
  :name         => _INTL("Hazard Removal")
})

GameData::Role.register({
  :id           => :DEFENSIVEPIVOT,
  :id_number    => 13,
  :name         => _INTL("Defensive Pivot")
})

GameData::Role.register({
  :id           => :SPEEDCONTROL,
  :id_number    => 14,
  :name         => _INTL("Speed Control")
})

GameData::Role.register({
  :id           => :SCREENS,
  :id_number    => 15,
  :name         => _INTL("Screens")
})

GameData::Role.register({
  :id           => :NONE,
  :id_number    => 16,
  :name         => _INTL("None")
})

GameData::Role.register({
  :id           => :TARGETALLY,
  :id_number    => 17,
  :name         => _INTL("Target Ally")
})

GameData::Role.register({
  :id           => :REDIRECTION,
  :id_number    => 18,
  :name         => _INTL("Redirection")
})

GameData::Role.register({
  :id           => :TRICKROOMSETTER,
  :id_number    => 19,
  :name         => _INTL("Trick Room Setter")
})

GameData::Role.register({
  :id           => :OFFENSIVEPIVOT,
  :id_number    => 20,
  :name         => _INTL("Offensive Pivot")
})

GameData::Role.register({
  :id           => :STATUSABSORBER,
  :id_number    => 21,
  :name         => _INTL("Status Absorber")
})

GameData::Role.register({
  :id           => :WEATHERTERRAIN,
  :id_number    => 22,
  :name         => _INTL("Weather/Terrain Setter")
})

GameData::Role.register({
  :id           => :TRAPPER,
  :id_number    => 23,
  :name         => _INTL("Trapper")
})

GameData::Role.register({
  :id           => :PHAZER,
  :id_number    => 24,
  :name         => _INTL("Phazer")
})

GameData::Role.register({
  :id           => :SUPPORT,
  :id_number    => 25,
  :name         => _INTL("Support")
})

GameData::Role.register({
  :id           => :WEATHERTERRAINABUSER,
  :id_number    => 26,
  :name         => _INTL("Weather/Terrain Abuser")
})

class Pokemon
  def assign_roles
    roles = []
    setup = [:SWORDSDANCE,:WORKUP,:NASTYPLOT,:GROWTH,:HOWL,:BULKUP,:CALMMIND,:TAILGLOW,:AGILITY,:ROCKPOLISH,:AUTOTOMIZE,
      :SHELLSMASH,:SHIFTGEAR,:QUIVERDANCE,:VICTORYDANCE,:CLANGOROUSSOUL,:CHARGE,:COIL,:HONECLAWS,:IRONDEFENSE,:COSMICPOWER,:AMNESIA,
      :POWERUPPUNCH,:FLAMECHARGE,:TRAILBLAZE]
    for move in @moves
      m = GameData::Move.get(move.id).id
      roles.push(:SETUPSWEEPER) if setup.include?(m)
      roles.push(:CLERIC) if [:WISH,:HEALBELL,:AROMATHERAPY].include?(m)
      roles.push(:OFFENSIVEPIVOT) if [:UTURN,:VOLTSWITCH,:FLIPTURN].include?(m)
      roles.push(:DEFENSIVEPIVOT) if [:PARTINGSHOT,:CHILLYRECEPTION,:TELEPORT].include?(m)
      roles.push(:SPEEDCONTROL) if [:ICYWIND,:THUNDERWAVE,:GLARE,:BULLDOZE,:DOLDRUMS,:ROCKTOMB,:POUNCE,:NUZZLE,:ELECTROWEB,:LOWSWEEP].include?(m)
      roles.push(:STALLBREAKER) if m == :TAUNT
      roles.push(:REDIRECTION) if [:FOLLOWME,:ALLYSWITCH,:RAGEPOWDER].include?(m)
      roles.push(:SUPPORT) if m == :HELPINGHAND
      roles.push(:HAZARDREMOVAL) if [:RAPIDSPIN,:MORTALSPIN,:TIDYUP,:DEFOG].include?(m)
      roles.push(:SCREENS) if [:LIGHTSCREEN,:REFLECT,:AURORAVEIL].include?(m)
      roles.push(:TOXICSTALLER) if m == :TOXIC
      roles.push(:LEAD) if [:STEALTHROCK,:SPIKES,:TOXICSPIKES,:STICKYWEB,:COMETSHARDS].include?(m)
      roles.push(:TRICKROOMSETTER) if m == :TRICKROOM
    end
    roles.push(:NONE) if roles == []
    return roles
  end
end