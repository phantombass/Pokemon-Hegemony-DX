module Randomizer_Info
	Trainers = 951
	Encounters = 952
	Items = 953 #Switch
	Static = 954 
	Gift = 955 
	Base_Stats = 956
	Abilities = 957
	Movesets = 958
	Choices = 959
	RandomizerOn = 960 #Switch
end

class Randomizer
	attr_accessor :randomized
	attr_accessor :choices
	attr_accessor :trainers
	attr_accessor :encounters
	attr_accessor :items
	attr_accessor :static
	attr_accessor :gift
	attr_accessor :base_stats
	attr_accessor :abilities
	attr_accessor :movesets

	def self.activated?
		return @randomized.nil? ? $game_switches[Randomizer_Info::RandomizerOn] : @randomized
	end

	def self.trainers
		return @trainers
	end

	def self.encounters
		return @encounters
	end

	def self.base_stats
		return @base_stats
	end

	def self.abilities
		return @abilities
	end

	def self.movesets
		return @movesets
	end

	def self.all_species
    	keys = []
   		GameData::Species.each { |species| keys.push(species.id) if species.form == 0 }
    	return keys
  	end

  	def self.active?(type)
  	    return false if @choices.nil?
  	    return false if @choices == 0
  		return @choices.include?(type)
  	end

  	def self.setup
  		PBAI.log("Setting up randomizer...")
  		@randomized = $game_switches[Randomizer_Info::RandomizerOn]
  		@choices = $game_variables[Randomizer_Info::Choices]
		@trainers = $game_variables[Randomizer_Info::Trainers]
		@encounters = $game_variables[Randomizer_Info::Encounters]
		@items = $game_switches[Randomizer_Info::Items]
		@static = $game_variables[Randomizer_Info::Static]
		@gift = $game_variables[Randomizer_Info::Gift]
		@base_stats = $game_variables[Randomizer_Info::Base_Stats]
		@abilities = $game_variables[Randomizer_Info::Abilities]
		@movesets = $game_variables[Randomizer_Info::Movesets]
	end

	def self.clear
		PBAI.log("Clearing randomizer options...")
		$game_switches[Randomizer_Info::RandomizerOn] = false
  		$game_variables[Randomizer_Info::Choices] = 0
		$game_variables[Randomizer_Info::Trainers] = 0
		$game_variables[Randomizer_Info::Encounters] = 0
		$game_switches[Randomizer_Info::Items] = false
		$game_variables[Randomizer_Info::Static] = 0
		$game_variables[Randomizer_Info::Gift] = 0
		$game_variables[Randomizer_Info::Base_Stats] = 0
		$game_variables[Randomizer_Info::Abilities] = 0
		$game_variables[Randomizer_Info::Movesets] = 0
	end

	def self.choose_options
		@randomized = false
		@choices = []
		@trainers = nil
		@encounters = nil
		@items = false
		@static = nil
		@gift = nil
		@base_stats = nil
		@abilities = nil
		@movesets = nil
		# list of all possible rules
	    modifiers = [:TRAINERS, :ENCOUNTERS, :STATIC, :GIFTS, :ITEMS, :ABILITIES, :STATS, :MOVES]
	    # list of rule descriptions
	    desc = [
	      _INTL("Randomize Trainer parties"),
	      _INTL("Randomize Wild encounters"),
	      _INTL("Randomize Static encounters"),
	      _INTL("Randomize Gifted Pokémon"),
	      _INTL("Randomize Items"),
	      _INTL("Randomize Abilities"),
	      _INTL("Randomize Base Stats"),
	      _INTL("Randomize Level-Up Moves")
	    ]
	    # default
	    added = []; cmd = 0
	    # creates help text message window
	    msgwindow = pbCreateMessageWindow(nil, "choice 1")
	    msgwindow.text = _INTL("Select the Randomizer Modes you wish to apply.")
	    # main loop
	    loop do
	      # generates all commands
	      commands = []
	      for i in 0...modifiers.length
	        commands.push(_INTL("{1} {2}", (added.include?(modifiers[i])) ? "[X]" : "[  ]", desc[i]))
	      end
	      commands.push(_INTL("Done"))
	      # goes to command window
	      cmd = self.commandWindow(commands, cmd, msgwindow)
	      # processes return
	      if cmd < 0
	        clear = pbConfirmMessage("Do you wish to cancel the Randomizer selection?")
	        added.clear if clear
	        next unless clear
	      end
	      break if cmd < 0 || cmd >= (commands.length - 1)
	      if cmd >= 0 && cmd < (commands.length - 1)
	        if added.include?(modifiers[cmd])
	          added.delete(modifiers[cmd])
	        else
	          added.push(modifiers[cmd])
	        end
	      end
	    end
	    # disposes of message window
	    pbDisposeMessageWindow(msgwindow)
	    # adds randomizer rules
	    Randomizer.add_data(added)
	    Input.update
	    return (added.length > 0), cmd
	end

	def self.add_data(data)
		if data.is_a?(Array)
			for i in data
				@choices.push(i)
			end
		end
	end

	def self.ironmonKaizo
	    # list of all possible rules
	    modifiers = [:TRAINERS, :ENCOUNTERS, :STATIC, :GIFTS, :ITEMS, :ABILITIES, :STATS, :MOVES]
	    # list of rule descriptions
	    # default
	    added = []
	    for i in 0..modifiers.length
	      added.push(modifiers[i])
	    end
	    # adds randomizer rules
	    $PokemonGlobal.randomizerRules = added
	    Randomizer.add_data(added)
	    Input.update
	    return (added.length > 0)
	  end
	  #-----------------------------------------------------------------------------
	  #  randomizes compiled trainer data
	  #-----------------------------------------------------------------------------
	  def self.randomizeTrainers
	  	return if !self.active?(:TRAINERS)
	    # loads compiled data and creates new array
	    data = load_data("Data/trainers.dat")
	    trainer_exclusions = $game_switches[906] ? nil : [:RIVAL,:RIVAL2,:LEADER_Brock,:LEADER_Misty,:LEADER_Surge,:LEADER_Erika,:LEADER_Sabrina,:LEADER_Blaine,:LEADER_Winslow,:LEADER_Jackson,:OFFCORP,:DEFCORP,:PSYCORP,:ROCKETBOSS,:CHAMPION,:ARMYBOSS,:NAVYBOSS,:AIRFORCEBOSS,:GUARDBOSS,:CHANCELLOR,:DOJO_Luna,:DOJO_Apollo,:DOJO_Jasper,:DOJO_Maloki,:DOJO_Juliet,:DOJO_Adam,:DOJO_Wendy,:LEAGUE_Astrid,:LEAGUE_Winslow,:LEAGUE_Eugene,:LEAGUE_Armand,:LEAGUE_Winston,:LEAGUE_Vincent]
	    species_exclusions = $game_switches[906] ? nil : [:SPINDA,:SUNKERN,:SUNFLORA]
	    $new_trainers = {
	      :trainer => [],
	      :pokemon => {
	        :species => [],
	        :level => []
	      }
	    }
	    return if !data.is_a?(Hash) # failsafe
	    # iterate through each trainer
	    for key in data.keys
	      # skip numeric trainers
	      next if !$new_trainers[:trainer] != nil && key.is_a?(Array)
	      $new_trainers[:trainer].push(data[key].id)
	      # iterate through party
	      pkmn = []
	      lvl = []
	      for i in 0...data[key].pokemon.length
	        next if !species_exclusions.nil? && species_exclusions.include?(data[key].pokemon[i][:species])
	        data[key].pokemon[i][:species] = Randomizer.all_species.sample
	        pkmn.push(data[key].pokemon[i][:species])
	        lvl.push(data[key].pokemon[i][:level])
	        $new_trainers[:pokemon][:species][key] = pkmn
	        $new_trainers[:pokemon][:level][key] = lvl
	        #data[key].pokemon[i].delete(:moves) if data[key].pokemon[i].key?(:moves)
	        #data[key].pokemon[i].delete(:ability) if data[key].pokemon[i].key?(:ability)
	        #data[key].pokemon[i].delete(:role) if data[key].pokemon[i].key?(:role)
	        #data[key].pokemon[i].delete(:ability_index) if data[key].pokemon[i].key?(:ability_index)
	        #data[key].pokemon[i].delete(:ev) if data[key].pokemon[i].key?(:ev)
	        #data[key].pokemon[i].delete(:iv) if data[key].pokemon[i].key?(:iv)
	        #data[key].pokemon[i].delete(:nature) if data[key].pokemon[i].key?(:nature)
	      end
	    end
	    @trainers = $new_trainers
	    $game_variables[Randomizer_Info::Trainers] = @trainers
	    return @trainers
	  end
	  #-----------------------------------------------------------------------------
	  #  randomizes abilities per pokemon
	  #-----------------------------------------------------------------------------
	  def self.randomizeAbilities
	  	return if !self.active?(:ABILITIES)
	    pkmn = load_data("Data/species.dat")
	    ability = load_data("Data/abilities.dat")
	    trainer = load_data("Data/trainers.dat")
	    abilities = []
	    for i in 0...ability.keys.length
	      abilities.push(ability.keys[i]) if i.odd?
	    end
	    ability_blacklist = [
	      :BATTLEBOND,
	      :DISGUISE,
	      :FLOWERGIFT,                                        # This can be stopped
	      :FORECAST,
	      :MULTITYPE,
	      :POWERCONSTRUCT,
	      :WONDERGUARD,
	      :SCHOOLING,
	      :SHIELDSDOWN,
	      :STANCECHANGE,
	      :ZENMODE,
	      :DUAT,
	      :ACCLIMATE,
	      :WORMHOLE,
	      :PINDROP,
	      :BOREALIS,
	      :BAROMETRIC,
	      :DESERTSTORM,
	      :ASHCOVER,
	      :ASHRUSH,
	      :MUGGYAIR,
	      :FIGHTERSWRATH,
	      :ELECTROSTATIC,
	      :BAILOUT,
	      :IMPATIENT,
	      :TIMEWARP,
	      :HYPERSPACE,
	      :APPLIANCE,
	      :MENTALBLOCK,
	      :CORRUPTION,
	      :CLOUDCOVER,
	      :MULTITOOL,
	      :SHROUD,
	      :ZEROTOHERO,
	      # Abilities intended to be inherent properties of a certain species
	      :COMATOSE,
	      :RKSSYSTEM
	    ]
	    return if !pkmn.is_a?(Hash)
	    return if !ability.is_a?(Hash)
	    return if !trainer.is_a?(Hash)
	    for key in trainer.keys
	      # skip numeric trainers
	      # iterate through party
	      for i in 0...trainer[key].pokemon.length
	        trainer[key].pokemon[i].delete(:ability) if trainer[key].pokemon[i].key?(:ability)
	      end
	    end
	    $new_ability = {
	      :pokemon => [],
	      :abilities => []
	    }
	    for key in pkmn.keys
	      abil = []
	      habil = []
	      if !key.is_a?(Symbol)
	        $new_ability[:pokemon].push(pkmn[key].id)
	        $new_ability[:pokemon].uniq!
	        for i in 0...pkmn[key].abilities.length
	          loop do
	            pkmn[key].abilities[i] = abilities.sample
	            break if !ability_blacklist.include?(pkmn[key].abilities[i])
	          end
	          abil.push([pkmn[key].abilities[i]])
	        end
	        for i in 0...pkmn[key].hidden_abilities.length
	          loop do
	            pkmn[key].hidden_abilities[i] = abilities.sample
	            break if !ability_blacklist.include?(pkmn[key].hidden_abilities[i])
	          end
	          habil.push([pkmn[key].hidden_abilities[i]])
	        end
	        $new_ability[:abilities][key] = abil[0],(abil[1] == nil ? abil[0] : abil[1]),habil
	        $new_ability[:abilities][key].flatten!
	        $new_ability[:abilities].delete_at(key-1) if $new_ability[:abilities][key-1] == nil
	      end
	    end
	    @abilities = $new_ability
	    $game_variables[Randomizer_Info::Abilities] = @abilities
	    return @abilities
	  end
	  #-----------------------------------------------------------------------------
	  #  randomizes compiled pokemon base stats
	  #-----------------------------------------------------------------------------
	  def self.randomizeStats
	  	return if !self.active?(:STATS)
	    data = load_data("Data/species.dat")
	    $new_stats = {
	      :pokemon => [],
	      :stats => {
	        :HP => [],
	        :ATTACK => [],
	        :DEFENSE => [],
	        :SPECIAL_ATTACK => [],
	        :SPECIAL_DEFENSE => [],
	        :SPEED => []
	      }
	    }
	    randStat = 0
	    return if !data.is_a?(Hash)
	    for key in data.keys
	      bst = 0
	      rem_stat = 0
	      species = data[key].id
	      next if $new_stats[:pokemon].include?(species)
	      for i in data[key].base_stats.keys
	        bst += data[key].base_stats[i]
	      end
	      for stat in data[key].base_stats.keys
	        if data[key].base_stats[stat] == 1
	          data[key].base_stats[stat] = 1
	          bst -= 1
	          rem_stat += 1
	          next
	        end
	        if [:MIMIKYU,:ROTOM].include?(data[key].id) && stat == :HP
	          data[key].base_stats[stat] = data[key].base_stats[stat]
	          bst -= data[key].base_stats[stat]
	          rem_stat += data[key].base_stats[stat]
	        end
	        loop do
	          randStat = rand(bst-rem_stat)
	          if bst-rem_stat <= 5
	            randStat = 5
	          end
	          break if (randStat>4 && randStat<201)
	        end
	        data[key].base_stats[stat] = randStat
	        if stat == :SPEED
	          data[key].base_stats[stat] = bst-rem_stat < 5 ? 5 : bst-rem_stat
	          if data[key].base_stats[stat] > 200
	            diff = data[key].base_stats[stat] - 200
	            data[key].base_stats[stat] = 200
	            rand2 = rand(5)
	            stats = [:HP,:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE]
	            data[key].base_stats[stats[rand]] += diff
	          end
	        end
	        rem_stat += data[key].base_stats[stat]
	        $new_stats[:stats][stat].push(data[key].base_stats[stat])
	      end
	      $new_stats[:pokemon].push(data[key].id)
	    end
	    @base_stats = $new_stats
	    $game_variables[Randomizer_Info::Base_Stats] = @base_stats
	    return @base_stats
	  end

	    #-----------------------------------------------------------------------------
	  #  randomizes compiled pokemon level up moves
	  #-----------------------------------------------------------------------------

	  def self.randomizeMoves
	  	return if !self.active?(:MOVES)
	    data = load_data("Data/species.dat")
	    move_data = load_data("Data/moves.dat")
	    move_list = []
	    $new_moves = {
	      :pokemon => [],
	      :moves => []
	      }
	    randStat = 0
	    return if !data.is_a?(Hash) || !move_data.is_a?(Hash)
	    for move in move_data.keys
	      move_list.push(move) if !move.is_a?(Integer)
	    end
	    for key in data.keys
	      moveset = []
	      species = data[key].id
	      next if $new_moves[:pokemon].include?(species)
	      ind = -1
	      for i in data[key].moves
	        moves = []
	        ind += 1
	        i[1] = move_list[rand(move_list.length)]
	        moves.push(i[0])
	        moves.push(i[1])
	        moveset.push(moves)
	      end
	      $new_moves[:moves].push(moveset)
	      $new_moves[:pokemon].push(data[key].id)
	    end
	    @movesets = $new_moves
	    $game_variables[Randomizer_Info::Movesets] = @movesets
	    return @movesets
	  end
	  #-----------------------------------------------------------------------------
	  #  randomizes map encounters
	  #-----------------------------------------------------------------------------
	  def self.randomizeEncounters
	  	return if !self.active?(:ENCOUNTERS)
	    # loads map encounters
	    data = load_data("Data/encounters.dat")
	    species_exclusions = $game_switches[906] ? nil : [:SPINDA,:SUNKERN,:SUNFLORA]
	    return if !data.is_a?(Hash) # failsafe
	    # iterates through each map point
	    for key in data.keys
	      # go through each encounter type
	      for type in data[key].types.keys
	        # cycle each definition
	        for i in 0...data[key].types[type].length
	          # set randomized species
	          next if !species_exclusions.nil? && species_exclusions.include?(data[key].types[type][i][1])
	          data[key].types[type][i][1] = Randomizer.all_species.sample
	        end
	      end
	    end
	    @encounters = data
	    $game_variables[Randomizer_Info::Encounters] = @encounters
	    return @encounters
	  end
	  #-----------------------------------------------------------------------------
	  #  randomizes static battles called through events
	  #-----------------------------------------------------------------------------
	  def self.randomizeStatic
	  	new = {}
	    array = Randomizer.all_species
	    # shuffles up species indexes to load a different one
	    for org in Randomizer.all_species
	      i = rand(array.length)
	      new[org] = array[i]
	      array.delete_at(i)
	    end
	    @static = new
	    $game_variables[Randomizer_Info::Static] = @static
	    return @static
	  end

	  def self.randomizeGift
	  	new = {}
	    array = Randomizer.all_species
	    # shuffles up species indexes to load a different one
	    for org in Randomizer.all_species
	      i = rand(array.length)
	      new[org] = array[i]
	      array.delete_at(i)
	    end
	    @gift = new
	  	$game_variables[Randomizer_Info::Gift] = @gift
	  	return @gift
	  end
	  #-----------------------------------------------------------------------------
	  #  randomizes items received through events
	  #-----------------------------------------------------------------------------
	  def self.randomizeItems
	  	@items = true
	  	$game_switches[Randomizer_Info::Items] = true
	    return @items
	  end

	  def self.random_species(species)
	  	return Randomizer.all_species.sample
	  end

	  def self.gift(species)
	  	return species if !self.active?(:GIFTS)
	  	pokemon = nil
		  if species.is_a?(Pokemon)
		    pokemon = species.clone
		    level = pokemon.level
		    species = pokemon.species
		  end
		  # if defined as an exclusion rule, species will not be randomized
		    excl = $game_switches[906] ? nil : [:SPINDA,:SUNKERN,:SUNFLORA]
	  	for mon in @gift.keys
	  		next if mon != species
	  		next if excl.include?(mon)
	  		species = @gift[mon]
	  	end
	    if !pokemon.nil?
	      pokemon.species = species
	      pokemon.level = level
	      pokemon.calc_stats
	      pokemon.reset_moves
	    end
	    return pokemon.nil? ? species : pokemon
	  end

	  def self.random_wild(species)
	  	return species if !self.active?(:ENCOUNTERS)
	  	pokemon = nil
		  if species.is_a?(Pokemon)
		    pokemon = species.clone
		    species = pokemon.species
		  end
		# if defined as an exclusion rule, species will not be randomized
		excl = $game_switches[906] ? nil : [:SPINDA,:SUNKERN,:SUNFLORA]
	    if !pokemon.nil?
	      pokemon.species = species
	      pokemon.calc_stats
	      pokemon.reset_moves
	    end
	    return pokemon.nil? ? species : pokemon
	  end
	  def self.static(species)
	  	return species if !self.active?(:STATIC)
	  	pokemon = nil
		  if species.is_a?(Pokemon)
		    pokemon = species.clone
		    species = pokemon.species
		  end
		  # if defined as an exclusion rule, species will not be randomized
		    excl = $game_switches[906] ? nil : [:SPINDA,:SUNKERN,:SUNFLORA]
	  	for mon in @gift.keys
	  		next if mon != species
	  		species = @gift[mon]
	  	end
	    if !pokemon.nil?
	      pokemon.species = species
	      pokemon.calc_stats
	      pokemon.reset_moves
	    end
	    return pokemon.nil? ? species : pokemon
	  end

	  def self.random_item(item)
	  	return item if GameData::Item.get(item).is_key_item?
	  	excl = [:HM01,:HM02,:HM03,:HM04,:HM05,:HM06,:ESCAPEROPE,:REPEL,:SUPERREPEL,:MAXREPEL,:TORCH,:WINGSUIT,:HMCATALOGUE,:FULCRUM,:HIKINGGEAR,:AQUAROCKET,:SCUBATANK,:HAMMER,:HOVERCRAFT,:ROTOMITE,:CELEBINITE,:FALKMUNRITE,:LUMINOUSORB,:DEVIANTORB,:FARFETCHDITE,:MILOTITE,:FLYGONITEX,:FLYGONITEY,:DRAPIONITE,:VESPINITE,:WHISCASHITE,:LUXRAYITE,:MUSHARNITE,:DODRIONITE,:LANTURNITE,:HEATMORITE,:DURANTITE,:DUNSPARCINITE,:TROPIUSITE,:JYNXITE,:BRONZITE,:MEGANIUMITE,:ARBOKINITE,:BEARTINITE,:ALLOYSTONE,:DRACOSTONE,:FORMETEONITE,:TEMPESTSTONE,:ARCHAICSTONE,:TOMBSEAL,:ANCIENTTOTEM,:APOPHITE,:NEFLORITE,:SATURABTITE,:PHIRENIXITE,:TIMESTONE,:SOUNDSTONE]
		  if !excl.nil? && excl.is_a?(Array)
		    for ent in excl
		      return item if item == ent
		    end
		  end
		itm = item
	  	if GameData::Item.get(item).is_machine?
	  		loop do
	        	itm = GameData::Item.values.sample
	        	break if !GameData::Item.get(itm).is_key_item? && GameData::Item.get(itm).is_machine? && !excl.include?(itm)
	      	end
	    elsif GameData::Item.get(item).is_mega_stone?
	    	loop do
	        	itm = GameData::Item.values.sample
	        	break if !GameData::Item.get(itm).is_key_item? && GameData::Item.get(itm).is_mega_stone? && !excl.include?(itm)
	      	end
	  	else
		  	loop do
	        	itm = GameData::Item.values.sample
	        	break if !GameData::Item.get(itm).is_key_item? && !GameData::Item.get(itm).is_machine? && !GameData::Item.get(itm).is_mega_stone? && !excl.include?(itm)
	      	end
	    end
	  	return !self.active?(:ITEMS) ? item : itm
	  end
	  #-----------------------------------------------------------------------------
	  #  begins the process of randomizing all data
	  #-----------------------------------------------------------------------------
	  def self.randomizeData
	    data = {}
	    # compiles hashtable with randomized values
	    randomized = {
	      :TRAINERS => proc{ next Randomizer.randomizeTrainers },
	      :ENCOUNTERS => proc{ next Randomizer.randomizeEncounters },
	      :STATIC => proc{ next Randomizer.randomizeStatic },
	      :GIFTS => proc{ next Randomizer.randomizeGift },
	      :ITEMS => proc{ next Randomizer.randomizeItems },
	      :ABILITIES => proc{ next Randomizer.randomizeAbilities },
	      :STATS => proc { next Randomizer.randomizeStats },
	      :MOVES => proc { next Randomizer.randomizeMoves }
	    }
	    # applies randomized data for specified rule sets
	    for key in @choices
	      data[key] = randomized[key].call if randomized.has_key?(key)
	    end
	    # return randomized data
	    return data
	  end

	  def self.start(skip = false)
	    ret = $PokemonGlobal && $PokemonGlobal.isRandomizer
	    ret, cmd = self.ironmonKaizo if skip
	    ret, cmd = self.choose_options unless skip
	    @randomized = true
	    $game_switches[Randomizer_Info::RandomizerOn] = @randomized
	    # randomize data and cache it
	    $PokemonGlobal.randomizedData = self.randomizeData if $PokemonGlobal.randomizedData.nil?
	    # refresh encounter tables
	    $PokemonEncounters.setup($game_map.map_id) if $PokemonEncounters
	    # display confirmation message
	    return if skip
	    added = @choices
	    $game_variables[Randomizer_Info::Choices] = @choices
	    msg = _INTL("Your selected Randomizer rules have been applied.")
	    msg = _INTL("No Randomizer rules have been applied.") if added.length < 1
	    msg = _INTL("Your selection has been cancelled.") if cmd < 0
	    pbMessage(msg)
	  end


	# basic commandWindow override
	def self.commandWindow(commands, index = 0, msgwindow = nil)
	    ret = -1
	    # creates command window
	    cmdwindow = Window_CommandPokemonColor.new(commands)
	    cmdwindow.index = index
	    cmdwindow.x = Graphics.width - cmdwindow.width
	    cmdwindow.z = 99999
	    # main loop
	    loop do
	      # updates graphics, input and OW
	      Graphics.update
	      Input.update
	      pbUpdateSceneMap
	      # updates the two windows
	      cmdwindow.update
	      msgwindow.update if !msgwindow.nil?
	      # updates command output
	      if Input.trigger?(Input::B)
	        pbPlayCancelSE
	        ret = -1
	        break
	      elsif Input.trigger?(Input::C)
	        pbPlayDecisionSE
	        ret = cmdwindow.index
	        break
	      end
	    end
	    # returns command output
	    cmdwindow.dispose
	    return ret
	  end
end

#===============================================================================
#  randomize encounter data if possible
#===============================================================================
module GameData
  class Encounter
    #---------------------------------------------------------------------------
    #  override standard get function
    #---------------------------------------------------------------------------
    class << self
      alias randomizer_get get unless self.method_defined?(:get)
    end
    #---------------------------------------------------------------------------
    def self.get(map_id, map_version = 0)
      validate map_id => Integer
      validate map_version => Integer
      randEnc = Randomizer.encounters
      trial_key = sprintf("%s_%d", map_id, map_version).to_sym
      key = (randEnc.nil? || randEnc == 0) ? ((self::DATA.has_key?(trial_key)) ? trial_key : sprintf("%s_0", map_id).to_sym) : ((randEnc.has_key?(trial_key)) ? trial_key : sprintf("%s_0", map_id).to_sym)
      data = (randEnc.nil? || randEnc == 0) ? self::DATA[key] : randEnc[key]
      return data
    end
    #---------------------------------------------------------------------------
  end
end

def getRandAbilities(species, ability_index)
  array = Randomizer.abilities
  ability = array[:abilities]
  pokemon = array[:pokemon]
  idx = -1
  for i in pokemon
    idx += 1
    break if i == species
  end
  return ability[idx][ability_index]
end

def getRandStats(species)
  pkmn = GameData::Species.get(species).id
  array = Randomizer.base_stats
  stats = array[:stats]
  stt = [:HP,:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
  stat = {:HP => 0,
          :ATTACK => 0,
          :DEFENSE => 0,
          :SPECIAL_ATTACK => 0,
          :SPECIAL_DEFENSE => 0,
          :SPEED => 0
          }
  pokemon = array[:pokemon]
  idx = -1
  for i in pokemon
    idx += 1
    break if i == pkmn
  end
  for i in stt
    stat[i] = stats[i][idx]
  end
  return stat
end

def getRandMoves(species)
  pkmn = GameData::Species.get(species).id
  array = Randomizer.movesets
  moves = array[:moves]
  pokemon = array[:pokemon]
  idx = -1
  for i in pokemon
    idx += 1
    break if i == pkmn
  end
  return moves[idx]
end

def getEncounter(map_id,map_version)
  encounters = GameData::Encounter.get(map_id,map_version)
  return encounters
end

#===============================================================================
#  aliasing to return randomized battlers
#===============================================================================
alias pbBattleOnStepTaken_randomizer pbBattleOnStepTaken unless defined?(pbBattleOnStepTaken_randomizer)
def pbBattleOnStepTaken(*args)
  $nonStaticEncounter = true
  pbBattleOnStepTaken_randomizer(*args)
  $nonStaticEncounter = false
end
#===============================================================================
#  aliasing to randomize static battles
#===============================================================================
alias pbWildBattle_randomizer pbWildBattle unless defined?(pbWildBattle_randomizer)
def pbWildBattle(*args)
  # randomizer
  for i in [0]
    args[i] = Randomizer.static(args[i]) if !$nonStaticEncounter
  end
  # starts battle processing
  return pbWildBattle_randomizer(*args)
end

alias pbDoubleWildBattle_randomizer pbDoubleWildBattle unless defined?(pbDoubleWildBattle_randomizer)
def pbDoubleWildBattle(*args)
  # randomizer
  for i in [0, 2]
    args[i] = Randomizer.static(args[i]) if !$nonStaticEncounter
  end
  # starts battle processing
  return pbDoubleWildBattle_randomizer(*args)
end

alias pbTripleWildBattle_randomizer pbTripleWildBattle unless defined?(pbTripleWildBattle_randomizer)
def pbTripleWildBattle(*args)
  # randomizer
  for i in [0, 2, 4]
    args[i] = Randomizer.static(args[i]) if !$nonStaticEncounter
  end
  # starts battle processing
  return pbTripleWildBattle_randomizer(*args)
end
#===============================================================================
#  aliasing to randomize gifted Pokemon
#===============================================================================
alias pbAddPokemon_randomizer pbAddPokemon unless defined?(pbAddPokemon_randomizer)
def pbAddPokemon(*args)
  # randomizer
  args[0] = $game_switches[916] ? egglocke_generator : Randomizer.gift(args[0])
  # gives Pokemon
  return pbAddPokemon_randomizer(*args)
end

alias pbAddPokemonSilent_randomizer pbAddPokemonSilent unless defined?(pbAddPokemonSilent_randomizer)
def pbAddPokemonSilent(*args)
  # randomizer
  args[0] = $game_switches[916] ? egglocke_generator : Randomizer.gift(args[0])
  # gives Pokemon
  return pbAddPokemonSilent_randomizer(*args)
end
#===============================================================================
#  snipped of code used to alias the item receiving
#===============================================================================
#-----------------------------------------------------------------------------
#  item find
alias pbItemBall_randomizer pbItemBall unless defined?(pbItemBall_randomizer)
def pbItemBall(*args)
  args[0] = Randomizer.randomize_item(args[0])
  return pbItemBall_randomizer(*args)
end
#-----------------------------------------------------------------------------
#  item receive
=begin
alias pbReceiveItem_randomizer pbReceiveItem unless defined?(pbReceiveItem_randomizer)
def pbReceiveItem(*args)
  args[0] = Randomizer.randomize_item(randomizeItem(args[0]))
  return pbReceiveItem_randomizer(*args)
end
=end
#===============================================================================
#  additional entry to Global Metadata for randomized data storage
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :randomizedData
  attr_accessor :isRandomizer
  attr_accessor :randomizerRules
end
#===============================================================================
#  refresh cache on load
#===============================================================================

class PokemonLoadScreen
  alias pbStartLoadScreen_randomizer pbStartLoadScreen unless self.method_defined?(:pbStartLoadScreen_randomizer)
  def pbStartLoadScreen
    ret = pbStartLoadScreen_randomizer
    # refresh current cache
    Randomizer.setup if Randomizer.activated?
    Restrictions.setup if Restrictions.active?
    return ret
  end
end

#===============================================================================
#  randomize trainer data if possible
#===============================================================================
def pbLoadTrainer(tr_type, tr_name, tr_version = 0)
  # handle trainer type process
  trainer_exclusions = [:RIVAL1,:RIVAL2,:LEADER_Brock,:LEADER_Misty,:LEADER_Surge,:LEADER_Erika,:LEADER_Sabrina,:LEADER_Blaine,:LEADER_Winslow,:LEADER_Jackson,:OFFCORP,:DEFCORP,:PSYCORP,:ROCKETBOSS,:CHAMPION,:ARMYBOSS,:NAVYBOSS,:AIRFORCEBOSS,:GUARDBOSS,:CHANCELLOR,:DOJO_Luna,:DOJO_Apollo,:DOJO_Jasper,:DOJO_Maloki,:DOJO_Juliet,:DOJO_Adam,:DOJO_Wendy,:LEAGUE_Astrid,:LEAGUE_Winslow,:LEAGUE_Eugene,:LEAGUE_Armand,:LEAGUE_Winston,:LEAGUE_Vincent]
  tr_type_data = GameData::TrainerType.try_get(tr_type)
  raise _INTL("Trainer type {1} does not exist.", tr_type) if !tr_type_data
  tr_type = tr_type_data.id
  # handle actual trainer data
  trainer_data = GameData::Trainer.try_get(tr_type, tr_name, tr_version)
  idx = -1
  new_trainers = Randomizer.trainers
 # key = [tr_type.to_sym, tr_name, tr_version]
  # attempt to randomize
 # trainer_data = EliteBattle.getRandomizedData(trainer_data, :TRAINERS, key)
  return (trainer_data) ? trainer_data.to_trainer : nil
end

class Pokemon
  def baseStats
    this_base_stats = Randomizer.active?(:STATS) ? getRandStats(species_data) : species_data.base_stats
    ret = {}
    GameData::Stat.each_main { |s| ret[s.id] = this_base_stats[s.id] }
    return ret
  end

  def ability_id
    if !@ability
      sp_data = species_data
      abil_index = ability_index
      if Randomizer.active?(:ABILITIES)
      	abilities = Restrictions.active? ? Restrictions.abilities : Randomizer.abilities
      elsif !Randomizer.active?(:ABILITIES) && Restrictions.active?
      	abilities = Restrictions.abilities
      end
      if abil_index >= 2   # Hidden ability
        @ability = !Randomizer.active?(:ABILITIES) ? sp_data.hidden_abilities[abil_index - 2] : getRandAbilities(abilities[:pokemon][sp_data.id_number-1],2)
        @ability = getRestrictedAbility(abilities[:pokemon][sp_data.id_number-1],2) if Restrictions.active?
        abil_index = (@personalID & 1) if !@ability
      end
      if !@ability  # Natural ability or no hidden ability defined
        @ability = (!Randomizer.active?(:ABILITIES) || $game_switches[RandBoss::Var]) ? (sp_data.abilities[abil_index] || sp_data.abilities[0]) : (getRandAbilities(abilities[:pokemon][sp_data.id_number-1],abil_index) || getRandAbilities(abilities[:abilities][sp_data.id_number-1],0))
        @ability = (getRestrictedAbility(abilities[:pokemon][sp_data.id_number-1],abil_index) || getRestrictedAbility(abilities[:pokemon][sp_data.id_number-1],0)) if Restrictions.active?
      end
    end
    return @ability
  end

  def getMoveList
  	if Randomizer.active?(:MOVES)
  		return Restrictions.active? ? getRestrictedMoves(species_data.id) : getRandMoves(species_data.id)
  	elsif !Randomizer.active?(:MOVES) && Restrictions.active?
  		return getRestrictedMoves(species_data.id)
  	else
  		return species_data.moves
  	end
  end
end