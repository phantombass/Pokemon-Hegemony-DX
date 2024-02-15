#To set up your Field Effects, first register your Field Effect in the Field Effects Main script.
#Then, fill in the information below for each of your field effects, and if your field effects have custom intro scripts
#you will need to define them in the pbStartBattleCore script in the Main file. Just search for these items in the script
#to add custom effects if you so wish.

FIELD_EFFECTS = {
		:None => {
			:field_name => "None",
			:intro_message => "Default message, change to nil when implementing", #message shown when field is active
			:field_gfx => "default image, change to nil if none", #image file name without the file extension
			:nature_power => :TRIATTACK,
			:mimicry => :NORMAL, #what type Camouflage/Mimicry will change you to
			:intro_script => nil, #a script that runs at the beginning of the battle
			#structure: "script name"
			:abilities => [], #abilities affected by this field
			:ability_effects => {}, #specific effects abilities trigger a stat boost that are not their normal effect.
			#ability effects data structure: Ability => [stat,amount boosted] example: :WATERVEIL -> [:EVASION,1]
			:move_damage_boost => {}, #if a move gets a power buff or nerf
			#structure: modifier => [move] i.e 1.2 => [:EARTHQUAKE]
			:move_messages => {}, #message the move getting the power change shows
			#structure: "message" => [move]
			:move_type_change => {}, #if a move changes type
			#structure: type => [move]
			:move_type_mod => {}, #if a move adds a type
			#structure: type => [move]
			:move_accuracy_change => {}, #if a move changes accuracy
			#structure = newAccuracy => [move]
			:defensive_modifiers => {}, #structure = modifier => [type,flag] where flag sets the kind of modifier.
			#flags are: physical, special, fullhp. fullhp flag cuts damage by the 1/modifier. other flags multiply def mods.
			#example: 2 => [:GHOST, "fullhp"] would make it so ghost types take 1/2 damage from full
			:type_damage_change => {}, #if a type gets a power buff or nerf
			#structure = modifier => [type] (i.e 1.2 => [:DRAGON] would boost dragon moves by 1.2 in this field)
			:type_messages => {}, #the message that shows when a type gets a buff or nerf
			#structure: "message" => [type]
			:type_type_mod => {}, #if a type gets added to a matchup based on the move type used due to the field
			#structure: addedType => [originalType]
			:type_mod_message => {}, #the message that shows if a type of move adds a type
			#structure: "message" => [oldType]
			:type_type_change => {}, #if a type changes due to the field
			#structure: newType => [oldType]
			:type_change_message => {}, #the message that shows if a type of move changes type
			#structure: "message" => [oldType]
			:type_accuracy_change => {},
			:side_effects => {}, #special effects activated when using certain moves or types, using flags as condition references
			#structure: "flag" => [move or type]
			:field_changers => {}, #moves or types that change the field
			#structure: newField => [type or move]
			:change_message => {}, #message that shows when the field changes
			#structure => "message" => [type or move]
			:field_change_conditions => {} #optional conditions that your field can change under
			#example would be if your field can only change in certain weather
			#structure: newField => condition
			#note: condition must be a method that can be run to check if the conditions are met
			#major note: all things in brackets MUST stay in brackets when used in these sections, or the script
			#will fail
		},
		:Forest => {
			:field_name => "Forest",
			:intro_message => "The forest is dark.",
			:field_gfx => "forest",
			:nature_power => :SILVERWIND,
			:mimicry => :BUG,
			:intro_script => nil,
			:abilities => [:SWARM],
			:ability_effects => {
			:SWARM => [[:ATTACK,1],[:SPECIAL_ATTACK,1]]
			},
			:move_damage_boost => {
			1.2 => [Fields::WIND_MOVES]
			},
			:move_messages => {"The forest bugs are riding the wind!" => [Fields::WIND_MOVES]},
			:move_type_change => {},
			:move_type_mod => {
				:BUG => [Fields::WIND_MOVES]
			},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {
			1.2 => [:BUG,:DARK]
			},
			:type_messages => {
				"The bugs of the forest joined in!" => [:BUG],
				"The darkness of the forest joined the attack!" => [:DARK]
			},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {},
			:type_change_message => {},
			:type_accuracy_change => {},
			:side_effects => {},
			:field_changers => {:None => [Fields::IGNITE_MOVES]},
			:change_message => {"The forest burned down!" => [Fields::IGNITE_MOVES]},
			:field_change_conditions => {:None => PokeBattle_Battle.ignite?} 
		},
		:Garden => {
			:field_name => "Garden",
			:intro_message => "What a pretty garden...",
			:field_gfx => "field",
			:nature_power => :ENERGYBALL,
			:mimicry => :GRASS,
			:intro_script => nil,
			:abilities => [:GRASSPELT,:FLOWERVEIL,:SAPSIPPER,:AROMAVEIL,:SWEETVEIL,:LEAFGUARD],
			:ability_effects => {
			:FLOWERVEIL => [[:DEFENSE,1]],
			:AROMAVEIL => [[:DEFENSE,1]],
			:SWEETVEIL => [[:SPECIAL_DEFENSE,1]],
			:LEAFGUARD => [[:DEFENSE,1],[:SPECIAL_DEFENSE,1]]
			},
			:move_damage_boost => {
			1.2 => [Fields::WIND_MOVES]
			},
			:move_messages => {"The wind blew through the grass." => [Fields::WIND_MOVES]},
			:move_type_change => {},
			:move_type_mod => {},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {
				1.3 => [:GRASS,:FAIRY,:BUG]
			},
			:type_messages => {"The field boosted the attack!" => [:GRASS,:BUG,:FAIRY]},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {},
			:type_change_message => {},
			:type_accuracy_change => {},
			:side_effects => {},
			:field_changers => {:None => [Fields::IGNITE_MOVES]},
			:change_message => {"The garden burned down!" => [Fields::IGNITE_MOVES]},
			:field_change_conditions => {:None => PokeBattle_Battle.ignite?} 
		},
		:Grassy => {
			:field_name => "Grassy",
			:intro_message => "Grass covers the field.",
			:field_gfx => "Grassy",
			:nature_power => :ENERGYBALL,
			:mimicry => :GRASS,
			:intro_script => nil,
			:abilities => [:GRASSPELT,:SAPSIPPER,:LEAFGUARD],
			:ability_effects => {
			:LEAFGUARD => [[:DEFENSE,1],[:SPECIAL_DEFENSE,1]]
			},
			:move_damage_boost => {
			1.2 => [Fields::WIND_MOVES]
			},
			:move_messages => {"The wind blew through the grass." => [Fields::WIND_MOVES]},
			:move_type_change => {},
			:move_type_mod => {},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {
				1.3 => [:GRASS]
			},
			:type_messages => {"The field boosted the attack!" => [:GRASS]},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {},
			:type_change_message => {},
			:type_accuracy_change => {},
			:side_effects => {},
			:field_changers => {
				:Wildfire => [Fields::IGNITE_MOVES],
				:None => [Fields::REMOVAL]
			},
			:change_message => {
				"The field caught fire!" => [Fields::IGNITE_MOVES],
				"The grass got blown away!" => [Fields::REMOVAL]
			},
			:field_change_conditions => {:Wildfire => PokeBattle_Battle.ignite?} 
		},
		:Electric => {
			:field_name => "Electric",
			:intro_message => "Electricity runs along the field.",
			:field_gfx => "Electric",
			:nature_power => :THUNDERBOLT,
			:mimicry => :ELECTRIC,
			:intro_script => nil,
			:abilities => [:VOLTABSORB,:LIGHTNINGROD,:MOTORDRIVE,:PROTOSYNTHESIS],
			:ability_effects => {},
			:move_damage_boost => {},
			:move_messages => {},
			:move_type_change => {},
			:move_type_mod => {},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {
				1.3 => [:ELECTRIC]
			},
			:type_messages => {"The field powered the attack!" => [:ELECTRIC]},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {},
			:type_change_message => {},
			:type_accuracy_change => {},
			:side_effects => {},
			:field_changers => {
				:None => [Fields::QUAKE_MOVES],
				:None => [Fields::REMOVAL]
			},
			:change_message => {
				"The field got stamped out!" => [Fields::QUAKE_MOVES],
				"The electricity got blown away!" => [Fields::REMOVAL]
			},
			:field_change_conditions => {} 
		},
		:Wildfire => {
			:field_name => "Wildfire",
			:intro_message => "The field is ablaze.",
			:field_gfx => "wildfire",
			:nature_power => :FLAMETHROWER,
			:mimicry => :FIRE,
			:intro_script => nil,
			:abilities => [:FLASHFIRE,:WELLBAKEDBODY,:THERMALEXCHANGE,:HEATPROOF,:MAGMAARMOR],
			:ability_effects => {
				:THERMALEXHCANGE => [[:ATTACK,1]],
				:HEATPROOF => [[:DEFENSE,1],[:SPECIAL_DEFENSE,1]],
				:MAGMAARMOR => [[:DEFENSE,1],[:SPECIAL_DEFENSE,1]]
			},
			:move_damage_boost => {
			1.2 => [Fields::WIND_MOVES]
			},
			:move_messages => {"The wind fueled the flames." => [Fields::WIND_MOVES]},
			:move_type_change => {},
			:move_type_mod => {},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {},
			:type_messages => {},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {
				:FIRE => [:GRASS]
			},
			:type_change_message => {
				"The grass caught fire!" => [:GRASS]
			},
			:type_accuracy_change => {},
			:side_effects => {"cinders" => Fields::WIND_MOVES},
			:field_changers => {:None => [Fields::DOUSERS]},
			:change_message => {"The wildfire was doused!" => [Fields::DOUSERS]},
			:field_change_conditions => {} 
		},
		:Misty => {
			:field_name => "Misty",
			:intro_message => "Mist swirled about the battlefield.",
			:field_gfx => "Misty",
			:nature_power => :MOONBLAST,
			:mimicry => :FAIRY,
			:intro_script => nil,
			:abilities => [:FAIRYBUBBLE,:ILLUSION,:CLOUDNINE],
			:ability_effects => {
				:FAIRYBUBBLE => [[:DEFENSE,1]],
				:ILLUSION => [[:DEFENSE,1],[:SPECIAL_DEFENSE,1]],
				:CLOUDNINE => [[:DEFENSE,1],[:SPECIAL_DEFENSE,1]]
			},
			:move_damage_boost => {},
			:move_messages => {},
			:move_type_change => {},
			:move_type_mod => {},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {
				0.5 => [:DRAGON]
			},
			:type_messages => {"The mist weakened the attack!" => [:DRAGON]},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {},
			:type_change_message => {},
			:type_accuracy_change => {},
			:side_effects => {},
			:field_changers => {:None => [Fields::REMOVAL]},
			:change_message => {"The mist got blown away!" => [Fields::REMOVAL]},
			:field_change_conditions => {} 
		},
		:Psychic => {
			:field_name => "Psychic",
			:intro_message => "The field got weird.",
			:field_gfx => "Psychic",
			:nature_power => :PSYCHIC,
			:mimicry => :PSYCHIC,
			:intro_script => nil,
			:abilities => [],
			:ability_effects => {},
			:move_damage_boost => {},
			:move_messages => {},
			:move_type_change => {},
			:move_type_mod => {},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {
				1.3 => [:PSYCHIC]
			},
			:type_messages => {"The terrain boosted the attack!" => [:PSYCHIC]},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {},
			:type_change_message => {},
			:type_accuracy_change => {},
			:side_effects => {},
			:field_changers => {:None => [Fields::REMOVAL]},
			:change_message => {"The weird terrain got blown away!" => [Fields::REMOVAL]},
			:field_change_conditions => {} 
		},
		:Poison => {
			:field_name => "Poison",
			:intro_message => "The field is covered with toxic waste.",
			:field_gfx => "Poison",
			:nature_power => :DEATHTOLL,
			:mimicry => :POISON,
			:intro_script => nil,
			:abilities => [:POISONPOINT,:POISONTOUCH,:FEVERPITCH,:CORROSION,:NITRIC],
			:ability_effects => {
				:POISONPOINT => [[:DEFENSE,1]],
				:POISONTOUCH => [[:ATTACK,1]],
				:FEVERPITCH => [[:SPECIAL_ATTACK,1],[:SPECIAL_DEFENSE,1]],
				:CORROSION => [[:SPECIAL_ATTACK,1]],
				:NITRIC => [[:ATTACK,1],[:SPECIAL_ATTACK,1]]
			},
			:move_damage_boost => {},
			:move_messages => {},
			:move_type_change => {},
			:move_type_mod => {},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {
				1.3 => [:POISON]
			},
			:type_messages => {"The toxic waste boosted the attack!" => [:POISON]},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {},
			:type_change_message => {},
			:type_accuracy_change => {},
			:side_effects => {},
			:field_changers => {
				:Wildfire => [Fields::IGNITE_MOVES],
				:None => [Fields::REMOVAL]},
			:change_message => {
				"The toxic waste caught fire!" => [Fields::IGNITE_MOVES],
				"The toxic waste got blown away!" => [Fields::REMOVAL]},
			:field_change_conditions => {:Wildfire => PokeBattle_Battle.ignite?} 
		},
		:EchoChamber => {
			:field_name => "Cave",
			:intro_message => "A dull echo hums...",
			:field_gfx => "cave1",
			:nature_power => :HYPERVOICE,
			:mimicry => :NORMAL,
			:intro_script => nil,
			:abilities => [:SOUNDPROOF,:CACOPHONY,:PUNKROCK,:LIQUIDVOICE],
			:ability_effects => {
				:SOUNDPROOF => [[:SPECIAL_DEFENSE,1]],
				:CACOPHONY => [[:DEFENSE,1],[:SPECIAL_DEFENSE,1]],
				:PUNKROCK => [[:SPECIAL_ATTACK,1]],
				:LIQUIDVOICE => [[:SPECIAL_ATTACK,1]]
			},
			:move_damage_boost => {
			1.3 => [Fields::ECHO_MOVES]
			},
			:move_messages => {"The cave echoed loudly!" => [Fields::ECHO_MOVES]},
			:move_type_change => {},
			:move_type_mod => {},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {
				1.2 => [:ROCK,:DARK,:GHOST],
				0.8 => [:FIRE,:GRASS]
			},
			:type_messages => {
				"The cave boosted the attack!" => [:ROCK],
				"The cave darkness boosted the attack!" => [:DARK,:GHOST],
				"The cave darkness weakened the attack!" => [:FIRE,:GRASS]
			},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {},
			:type_change_message => {},
			:type_accuracy_change => {},
			:side_effects => {},
			:field_changers => {},
			:change_message => {},
			:field_change_conditions => {} 
		},
		:Desert => {
			:field_name => "Desert",
			:intro_message => "The sand is everywhere...",
			:field_gfx => "sand",
			:nature_power => :EARTHPOWER,
			:mimicry => :GROUND,
			:intro_script => nil,
			:abilities => [:SANDRUSH,:SANDVEIL,:SANDFORCE],
			:ability_effects => {},
			:move_damage_boost => {
			1.2 => [Fields::WIND_MOVES]
			},
			:move_messages => {"The sand kicked up!" => [Fields::WIND_MOVES]},
			:move_type_change => {},
			:move_type_mod => {},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {
				1.2 => [:FIRE,:GROUND],
				0.8 => [:WATER,:GRASS]
			},
			:type_messages => {
				"The desert boosted the attack!" => [:GROUND,:FIRE],
				"The desert weakened the attack!" => [:WATER,:GRASS]
			},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {},
			:type_change_message => {},
			:type_accuracy_change => {},
			:side_effects => {"sand" => Fields::WIND_MOVES},
			:field_changers => {},
			:change_message => {},
			:field_change_conditions => {} 
		},
		:Ruins => {
			:field_name => "Ruins",
			:intro_message => "A mysterious presence surrounds you...",
			:field_gfx => "rocky_eve",
			:nature_power => :PSYCHIC,
			:mimicry => :PSYCHIC,
			:intro_script => nil,
			:abilities => [:SANDRUSH,:SANDVEIL,:SANDFORCE],
			:ability_effects => {},
			:move_damage_boost => {},
			:move_messages => {},
			:move_type_change => {},
			:move_type_mod => {},
			:move_accuracy_change => {},
			:defensive_modifiers => {
				2 => [:PSYCHIC,"fullhp"]
			},
			:type_damage_change => {
				1.2 => [:PSYCHIC,:FIRE,:GRASS,:WATER]
			},
			:type_messages => {
				"The ruins boosted the attack!" => [:PSYCHIC,:FIRE,:GRASS,:WATER]
			},
			:type_type_mod => {
				:ROCK => [:PSYCHIC]
			},
			:type_mod_message => {
				"The rubble joined the telekenetic strike!" => [:PSYCHIC]
			},
			:type_type_change => {},
			:type_change_message => {},
			:type_accuracy_change => {},
			:side_effects => {},
			:field_changers => {:None => [Fields::QUAKE_MOVES]},
			:change_message => {"The quake leveled the ruins!" => [Fields::QUAKE_MOVES]},
			:field_change_conditions => {} 
		},
		:Swamp => {
			:field_name => "Swamp",
			:intro_message => "The swamp feels unstable...",
			:field_gfx => "field_night",
			:nature_power => :SLUDGEWAVE,
			:mimicry => :POISON,
			:intro_script => "swamp",
			:abilities => [:POISONPOINT,:POISONTOUCH,:FEVERPITCH,:CORROSION,:NITRIC],
			:ability_effects => {
				:POISONPOINT => [[:DEFENSE,1]],
				:POISONTOUCH => [[:ATTACK,1]],
				:FEVERPITCH => [[:SPECIAL_ATTACK,1],[:SPECIAL_DEFENSE,1]],
				:CORROSION => [[:SPECIAL_ATTACK,1]],
				:NITRIC => [[:ATTACK,1],[:SPECIAL_ATTACK,1]]
			},
			:move_damage_boost => {},
			:move_messages => {},
			:move_type_change => {},
			:move_type_mod => {},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {
				1.2 => [:WATER,:GRASS,:POISON],
				0.8 => [:FIRE,:ROCK,:FIGHTING]
			},
			:type_messages => {
				"The swamp boosted the attack!" => [:WATER,:GRASS,:POISON],
				"The swamp weakened the attack!" => [:FIGHTING,:FIRE,:ROCK]
			},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {},
			:type_change_message => {},
			:type_accuracy_change => {
				0 => [:WATER,:POISON]
			},
			:side_effects => {},
			:field_changers => {:None => [Fields::SWAMP_REMOVAL]},
			:change_message => {"The rocks filled in the swamp!" => [Fields::SWAMP_REMOVAL]},
			:field_change_conditions => {} 
		},
		:Lava => {
			:field_name => "Lava",
			:intro_message => "Lava flows underfoot...",
			:field_gfx => "water_eve",
			:nature_power => :LAVAPLUME,
			:mimicry => :FIRE,
			:intro_script => nil,
			:abilities => [:FLASHFIRE,:WELLBAKEDBODY,:THERMALEXCHANGE,:HEATPROOF,:MAGMAARMOR,:STEAMENGINE,:SOLARPOWER,:PROTOSYNTHESIS],
			:ability_effects => {
				:THERMALEXHCANGE => [[:ATTACK,1]],
				:HEATPROOF => [[:DEFENSE,1],[:SPECIAL_DEFENSE,1]],
				:MAGMAARMOR => [[:DEFENSE,1],[:SPECIAL_DEFENSE,1]],
				:SOLARPOWER => [[:SPECIAL_ATTACK,1]]
			},
			:move_damage_boost => {
				0.0 => [Fields::WEAK_WATER]
			},
			:move_messages => {
				"The water fizzled out!" => [Fields::WEAK_WATER]
			},
			:move_type_change => {},
			:move_type_mod => {},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {
				1.2 => [:FIRE],
				0.8 => [:WATER,:ICE]
			},
			:type_messages => {
				"The lava boosted the heat!" => [:FIRE],
				"The ice melted!" => [:ICE]
			},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {
				:WATER => [:ICE]
			},
			:type_change_message => {
				"The heat weakened the water" => [:ICE]
			},
			:type_accuracy_change => {},
			:side_effects => {},
			:field_changers => {
				:Mountainside => [Fields::SWAMP_REMOVAL],
				:None => [Fields::LAVA_REMOVAL]
			},
			:change_message => {
				"The lava flow was stopped!" => [Fields::SWAMP_REMOVAL],
				"The lava was cooled by the water!" => [Fields::LAVA_REMOVAL]
			},
			:field_change_conditions => {:None => PokeBattle_Battle.douse?} 
		},
		:SnowyMountainside => {
			:field_name => "Snowy Mountainside",
			:intro_message => "A chilling wind blows by...",
			:field_gfx => "snow",
			:nature_power => :ICE,
			:mimicry => :BLIZZARD,
			:intro_script => nil,
			:abilities => [:SLUSHRUSH,:SNOWCLOAK,:ICEBODY],
			:ability_effects => {
				:SNOWCLOAK => [[:DEFENSE,1]]
			},
			:move_damage_boost => {
			1.2 => [Fields::WIND_MOVES]
			},
			:move_messages => {
				"The chilling winds kicked up!" => [Fields::WIND_MOVES],
				"The rocks picked up ice!" => [:ROCKSLIDE],
				"AVALANCHE!" => [Fields::ECHO_MOVES]
			},
			:move_type_change => {},
			:move_type_mod => {
				:ICE => [:ROCKSLIDE,Fields::ECHO_MOVES]
			},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {
				1.2 => [:ICE,:ROCK]},
			:type_messages => {
				"The frozen mountain boosted the attack!" => [:ICE]
			},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {},
			:type_change_message => {},
			:type_accuracy_change => {},
			:side_effects => {},
			:field_changers => {},
			:change_message => {},
			:field_change_conditions => {} 
		},
		:Mountainside => {
			:field_name => "Mountainside",
			:intro_message => "These rocks seem unsteady...",
			:field_gfx => "rocky",
			:nature_power => :ROCK,
			:mimicry => :ROCKSLIDE,
			:intro_script => nil,
			:abilities => [:SCALER,:SPLINTER,:SOLIDROCK,:ROCKHEAD],
			:ability_effects => {
				:SCALER => [[:DEFENSE,1]],
				:SPLINTER => [[:SPECIAL_DEFENSE,1]],
				:SOLIDROCK => [[:DEFENSE,1],[:SPECIAL_DEFENSE,1]],
				:ROCKHEAD => [[:ATTACK,1]]
			},
			:move_damage_boost => {
			1.2 => [Fields::QUAKE_MOVES]
			},
			:move_messages => {
				"LANDSLIDE!" => [Fields::QUAKE_MOVES]},
			:move_type_change => {},
			:move_type_mod => {
				:ROCK => [Fields::QUAKE_MOVES]
			},
			:move_accuracy_change => {},
			:defensive_modifiers => {},
			:type_damage_change => {
				1.2 => [:ROCK]},
			:type_messages => {
				"The mountain boosted the attack!" => [:ROCK]
			},
			:type_type_mod => {},
			:type_mod_message => {},
			:type_type_change => {},
			:type_change_message => {},
			:type_accuracy_change => {},
			:side_effects => {},
			:field_changers => {},
			:change_message => {},
			:field_change_conditions => {} 
		},
	}