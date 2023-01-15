class PBAI
  attr_reader :battle
  attr_reader :sides
  #If this is true, the AI will know your moves, held items, and abilities
  #before they are revealed.
  OMNISCIENT_AI = false
  AI_KNOWS_ABILITY = true

  def initialize(battle, wild_battle)
    @battle = battle
    @sides = [Side.new(self, 0), Side.new(self, 1, wild_battle)]
    $d_switch = 0
    $doubles_switch = nil
    PBAI.log("AI initialized")
  end

  def self.battler_to_proj_index(battlerIndex)
    if battlerIndex % 2 == 0 # Player side: 0, 2, 4 -> 0, 1, 2
      return battlerIndex / 2
    else # Opponent side: 1, 3, 5 -> 0, 1, 2
      return (battlerIndex - 1) / 2
    end
  end

  def self.weighted_rand(weights)
    num = rand(weights.sum)
    for i in 0...weights.size
      if num < weights[i]
        return i
      else
        num -= weights[i]
      end
    end
    return nil
  end

  def self.get_weights(factor, weights)
    avg = weights.sum / weights.size.to_f
    newweights = weights.map do |e|
      diff = e - avg
      next [0, ((e - diff * factor) * 100).round].max
    end
    return newweights
  end

  def self.weighted_factored_rand(factor, weights)
    avg = weights.sum / weights.size.to_f
    test = 0
    lower_test = 0
    weights.each do |w|
      test += 1 if w > weights.sum/2
    end
    weights.each do |x|
      lower_test += 1 if x>=weights.sum*0.3
    end
    newweights = weights.map do |e|
      e = 0 if e < weights.sum/2 && test > 0
      e = 0 if e < weights.sum*0.3 && lower_test > 0
      diff = e - avg
      next [0, ((e - diff * factor) * 100).round].max
    end
    return weighted_rand(newweights)
  end

  def self.log(msg)
    echoln msg
  end

  def battler_to_projection(battler)
    @sides.each do |side|
      side.battlers.each do |projection|
        if projection && projection.pokemon == battler.pokemon
          return projection
        end
      end
      side.party.each do |projection|
        if projection && projection.pokemon == battler.pokemon
          return projection
        end
      end
    end
    return nil
  end

  def pokemon_to_projection(pokemon)
    @sides.each do |side|
      side.battlers.each do |projection|
        if projection && projection.pokemon == pokemon
          return projection
        end
      end
      side.party.each do |projection|
        if projection && projection.pokemon == pokemon
          return projection
        end
      end
    end
    return nil
  end

  def register_damage(move, user, target, damage)
    user = battler_to_projection(user)
    target = battler_to_projection(target)
    user.register_damage_dealt(move, target, damage)
    target.register_damage_taken(move, user, damage)
  end

  def faint_battler(battler)
    # Remove the battler from the AI's list of the active battlers
    @sides.each do |side|
      side.battlers.each_with_index do |proj, index|
        if proj && proj.battler == battler
          # Decouple the projection from the battler
          side.recall(battler.index)
          side.battlers[index] = nil
          break
        end
      end
    end
  end

  def end_of_round
    @sides.each { |side| side.end_of_round }
  end

  def reveal_ability(battler)
    @sides.each do |side|
      side.battlers.each do |proj|
        if proj && proj.battler == battler && !proj.shown_ability
          proj.shown_ability = true
          PBAI.log("#{proj.pokemon.name}'s ability was revealed.")
          break
        end
      end
    end
  end

  def reveal_item(battler)
    @sides.each do |side|
      side.battlers.each do |proj|
        if proj.battler == battler && !proj.shown_item
          proj.shown_item = true
          PBAI.log("#{proj.pokemon.name}'s item was revealed.")
          break
        end
      end
    end
  end

  def pbAIRandom(x)
    return rand(x)
  end

  def pbDefaultChooseEnemyCommand(idxBattler)
    sideIndex = idxBattler % 2
    index = PBAI.battler_to_proj_index(idxBattler)
    side = @sides[sideIndex]
    projection = side.battlers[index]
    # Choose move
    data = projection.choose_move
    if data.nil?
      # Struggle
      data[0] = :USE_MOVE
      @battle.pbAutoChooseMove(idxBattler)
    elsif data[0] == :SWITCH
      # [:SWITCH, pokemon_index]
      @battle.pbRegisterSwitch(idxBattler, data[1])
    elsif data[0] == :FLEE
      pbSEPlay("Battle flee")
      @battle.pbDisplay(_INTL("{1} fled from battle!",projection.pbThis))
      @battle.decision = 3
      @battle.scene.clearMessageWindow
      @battle.scene.pbEndBattle(@battle.decision)
    else
      # [move_index, move_target]
      if data[0] == :ITEM
        data[0] = rand(projection.moves.length)
      end
      move_index, move_target = data
      # Mega evolve if we determine that we should
      @battle.pbRegisterMegaEvolution(idxBattler) if projection.should_mega_evolve?(idxBattler)
      # Register our move
      @battle.pbRegisterMove(idxBattler, move_index, false)
      # Register the move's target
      @battle.pbRegisterTarget(idxBattler, move_target)
    end
  end


  #=============================================================================
  # Choose a replacement Pokémon
  #=============================================================================
  def pbDefaultChooseNewEnemy(idxBattler, party)
    proj = self.battler_to_projection(@battle.battlers[idxBattler])
    scores = proj.get_optimal_switch_choice
    scores.each do |_, _, proj|
      pkmn = proj.pokemon
      index = @battle.pbParty(idxBattler).index(pkmn)
      if @battle.pbCanSwitchLax?(idxBattler, index)
        return index
      end
    end
    return -1
  end

  class Battler_AI_Learning
    attr_accessor :battler
    attr_accessor :used_moves
    attr_accessor :shown_item
    attr_accessor :shown_ability
    attr_accessor :ai_index
    attr_reader :side
    attr_reader :pokemon
    attr_reader :flags

    def initialize(side, pokemon, wild_pokemon = false)
      @side = side
      @pokemon = pokemon
      @battler = nil
      @ai = @side.ai
      @battle = @ai.battle
      @damage_taken = []
      @damage_dealt = []
      @ai_index = nil
      @used_moves = []
      @shown_ability = false
      @shown_item = false
      @skill = wild_pokemon ? 50 : 200
      @flags = {}
    end

    alias original_missing method_missing
    def method_missing(name, *args, &block)
      if @battler.respond_to?(name)
        PBAI.log("WARNING: Deferring method `#{name}` to @battler.")
        return @battler.send(name, *args, &block)
      else
        return original_missing(name, *args, &block)
      end
    end
    def opposing_side
      return @side.opposing_side
    end

    def index
      return @side.index == 0 ? @ai_index * 2 : @ai_index * 2 + 1
    end

    def hp
      return @battler.hp
    end

    def fainted?
      return @pokemon.fainted?
    end

    def role
      return @battler.role
    end

    def defensive?
      return true if [:SCREENS,:DEFENSIVEPIVOT,:OFFENSIVEPIVOT,:PHYSICALWALL,:SPECIALWALL,:TOXICSTALLER,:STALLBREAKER,:TRICKROOMSETTER,:TARGETALLY,:REDIRECTION,:CLERIC,:HAZARDLEAD,:SKILLSWAPALLY].include?(@battler.role.id)
      return false
    end

    def setup?
      return true if [:SETUPSWEEPER,:WINCON].include?(@battler.role.id)
      return false
    end

    def totalhp
      return @battler.totalhp
    end

    def status
      return @battler.status
    end

    def statusCount
      return @battler.statusCount
    end

    def burned?
      return @battler.burned?
    end

    def poisoned?
      return @battler.poisoned?
    end

    def paralyzed?
      return @battler.paralyzed?
    end

    def frozen?
      return @battler.frozen?
    end

    def asleep?
      return @battler.asleep?
    end

    def confused?
      return @battler.effects[PBEffects::Confusion] > 0
    end

    def level
      return @battler.level
    end

    def active?
      return !@battler.nil?
    end

    def effective_attack
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @battler.stages[:ATTACK] + 6
      return (@battler.attack.to_f * stageMul[stage] / stageDiv[stage]).floor
    end

    def effective_defense
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @battler.stages[:DEFENSE] + 6
      return (@battler.defense.to_f * stageMul[stage] / stageDiv[stage]).floor
    end

    def effective_spatk
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @battler.stages[:SPECIAL_ATTACK] + 6
      return (@battler.spatk.to_f * stageMul[stage] / stageDiv[stage]).floor
    end

    def effective_spdef
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @battler.stages[:SPECIAL_DEFENSE] + 6
      return (@battler.spdef.to_f * stageMul[stage] / stageDiv[stage]).floor
    end

    def effective_speed
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = @battler.stages[:SPEED] + 6
      return (@battler.speed.to_f * stageMul[stage] / stageDiv[stage]).floor
    end

    def faster_than?(target)
      return self.effective_speed >= target.effective_speed
    end
    def has_non_volatile_status?
      return burned? || poisoned? || paralyzed? || frozen? || asleep?
    end

    # If this is true, this Pokémon will be treated as being a physical attacker.
    # This means that the Pokémon will be more likely to try to use attack-boosting and
    # defense-lowering status moves, and will be even more likely to use strong physical moves
    # if any of these status boosts are active.
    def is_physical_attacker?
      stats = [effective_attack, effective_spatk]
      avg = stats.sum / stats.size.to_f
      min = (avg + (stats.max - avg) / 4 * 3).floor
      avg = avg.floor
      # min is the value the base attack must be above (3/4th avg) in order to for
      # attack to be seen as a "high" value.
      # Count the number of physical moves
      physcount = 0
      attackBoosters = 0
      @battler.moves.each do |move|
        next if move.pp == 0
        physcount += 1 if move.physicalMove?
        if move.statUp
          for i in 0...move.statUp.size / 2
            attackBoosters += move.statUp[i * 2 + 1] if move.statUp[i * 2] == :ATTACK
          end
        end
      end
      # If the user doesn't have any physical moves, the Pokémon can never be
      # a physical attacker.
      return false if physcount == 0
      if effective_attack >= min
        # Has high attack stat
        # All physical moves would be a solid bet since we have a high attack stat.
        return true
      elsif effective_attack >= avg
        # Attack stat is not high, but still above average
        # If this Pokémon has any attack-boosting moves, or more than 1 physical move,
        # we consider this Pokémon capable of being a physical attacker.
        return true if physcount > 1
        return true if attackBoosters >= 1
        return true if self.role.id == :PHYSICALBREAKER
      end
      return false
    end

    # If this is true, this Pokémon will be treated as being a special attacker.
    # This means that the Pokémon will be more likely to try to use spatk-boosting and
    # spdef-lowering status moves, and will be even more likely to use strong special moves
    # if any of these status boosts are active.
    def is_special_attacker?
      stats = [effective_attack, effective_spatk]
      avg = stats.sum / stats.size.to_f
      min = (avg + (stats.max - avg) / 4 * 3).floor
      avg = avg.floor
      # min is the value the base attack must be above (3/4th avg) in order to for
      # attack to be seen as a "high" value.
      # Count the number of physical moves
      speccount = 0
      spatkBoosters = 0
      @battler.moves.each do |move|
        next if move.pp == 0
        speccount += 1 if move.specialMove?
        if move.statUp
          for i in 0...move.statUp.size / 2
            spatkBoosters += move.statUp[i * 2 + 1] if move.statUp[i * 2] == :SPECIAL_ATTACK
          end
        end
      end
      # If the user doesn't have any physical moves, the Pokémon can never be
      # a physical attacker.
      return false if speccount == 0
      if effective_spatk >= min
        # Has high spatk stat
        # All special moves would be a solid bet since we have a high spatk stat.
        return true
      elsif effective_spatk >= avg
        # Spatk stat is not high, but still above average
        # If this Pokémon has any spatk-boosting moves, or more than 1 special move,
        # we consider this Pokémon capable of being a special attacker.
        return true if speccount > 1
        return true if spatkBoosters >= 1
        return true if self.role.id == :SPECIALBREAKER
      end
      return false
    end

    # Whether the pokemon should mega-evolve
    def should_mega_evolve?(idx)
      # Always mega evolve if the pokemon is able to
      return @battle.pbCanMegaEvolve?(@battler.index)
    end

    def choose_move
      # An array of scores in the format of [move_index, score, target]
      scores = []

      # Calculates whether to use an item
      item_score = get_item_score
      # Yields [score, item, target&]
      scores << [:ITEM, *item_score]

      # Calculates whether to switch
      switch_score = get_switch_score
      # Yields [score, pokemon_index]
      scores << [:SWITCH, *switch_score]
      if @battle.rules["alwaysflee"] == true && !self.trapped?
        flee_score = 100000
      else
        flee_score = 0
      end
      scores << [:FLEE, *flee_score]

      PBAI.log("=" * 10 + " Turn #{@battle.turnCount + 1} " + "=" * 10)
      # Gets the battler projections of the opposing side
      # Calculate a score for each possible target

      targets = opposing_side.battlers.clone
      @side.battlers.each do |proj|
        next if proj == self || proj.nil?
        targets << proj
      end
      targets.each do |target|
        next if target.nil?
        PBAI.log("Moves for #{@battler.pokemon.name} against #{target.pokemon.name}")
        # Calculate a score for all the user's moves
        for i in 0..3
          move = @battler.moves[i]
          if !move.nil?
            next if move.pp <= 0
            target_type = move.pbTarget(@battler)
            target_index = target.index
            if [:None,:User,:FoeSide,:BothSides,:UserSide].include?(GameData::Target.get(target_type).id)
              # If move has no targets, affects the user, a side or the whole field
              target_index = -1
            else
              next if !@battle.pbMoveCanTarget?(@battler.index, target.index, target_type)
            end
            # Get the move score given a user and a target
            score = get_move_score(target, move)
            next if score.nil?
            score = 1 if score < 1
            scores << [i, score.round, target_index, target.pokemon.name]
          end
        end
      end

      # If absolutely no good options exist
      if scores.size == 0
        # Then just try to use the very first move with pp
        healing = false
        protect = false
        for i in 0...4
          move = @battler.moves[i]
          next if move.nil?
          if move.pp > 0
            next if @battler.effects[PBEffects::DisableMove] == move.id
            scores << [i, 1, 0, "internal"]
          end
          healing = true if move.healingMove?
        end
        user.flags[:should_heal] = true if healing == true
        user.flags[:should_protect] = true if healing == false
      end

      # Map the numeric skill factor to a -4..1 range (not hard bounds)
      skill = @skill / -50.0 + 1
      # Generate a random choice based on the skill factor and the score weights
      idx = PBAI.weighted_factored_rand(skill, scores.map { |e| e[1] })
      str = "=" * 30
      str += "\nSkill: #{@skill}"
      weights = PBAI.get_weights(skill, scores.map { |e| e[1] })
      total = weights.sum
      scores.each_with_index do |e, i|
        finalPerc = total == 0 ? 0 : (weights[i] / total.to_f * 100).round
        if i == 0
          # Item
          next if item_score == [0,0]
          name = GameData::Item.get(e[2]).name
          score = e[1]
          if score > 0
            str += "\nITEM #{name}: #{score} => #{finalPerc}" + " percent"
            str += " << CHOSEN" if idx == 0
            str += "\n"
          end
        elsif i == 1
          # Switch
          name = @battle.pbParty(@battler.index)[e[2]].name
          score = e[1]
          if score > 0
            str += "\nSWITCH #{name}: #{score} => #{finalPerc}" + " percent"
            str += " << CHOSEN" if idx == 1
            str += "\n"
          end
        elsif i == 2
          #Flee
          score = e[1]
          if score > 0
            str += "\nFLEE: #{score} => #{finalPerc}" + " percent"
            str += " << CHOSEN" if idx == 1
            str += "\n"
          end

        #elsif i == -1
        #  str += "STRUGGLE: 100%"
        else
          move_index, score, target, target_name = e
          name = @battler.moves[move_index].name
          str += "\nMOVE(#{target_name}) #{name}: #{score} => #{finalPerc}" + " percent"
          str += " << CHOSEN" if i == idx
          str += "\n"
        end
      end
      str += "=" * 30
      PBAI.log(str)
      if idx == 0
        # Index 0 means an item was chosen
        ret = [:ITEM, scores[0][2]]
        ret << scores[0][3] if scores[0][3] # Optional target
        # TODO: Set to-be-healed flag so Heal Pulse doesn't also heal after healing by item
        healing_item = scores[0][4]
        if healing_item
          self.flags[:will_be_healed]
        end
        return ret
      elsif idx == 1
        # Index 1 means switching was chosen
        return [:SWITCH, scores[1][2]]
      elsif idx == 2
        return [:FLEE, flee_score]
      end
      # Return [move_index, move_target]
      if idx
        choice = scores[idx]
        move = @battler.moves[choice[0]]
        target = opposing_side.battlers[choice[2]]
        if ["15B", "0D5", "0D6", "0D7", "0D8", "0D9"].include?(move.function)
          self.flags[:will_be_healed] = true
        elsif move.function == "0DF"
          target.flags[:will_be_healed] = true
        elsif move.function == "0A1"
          @side.flags[:will_luckychant] = true
        elsif move.function == "0A2"
          @side.flags[:will_reflect] = true
        elsif move.function == "0A3"
          @side.flags[:will_lightscreen] = true
        elsif move.function == "051"
          @side.flags[:will_haze] = true
        elsif move.function == "167"
          @side.flags[:will_auroraveil] = true
        elsif move.function == "0BA"
          target.flags[:will_be_taunted] = true
        elsif move.function == "0B9"
          target.flags[:will_be_disabled] = true
        elsif move.function == "0BC"
          target.flags[:will_be_encored] = true
        end
        return [choice[0], choice[2]]
      end
      # No choice could be made
      # Caller will make sure Struggle is used
    end
    def get_item_score
      # Yields [score, item, optional_target, healing_item]
      items = @battle.pbGetOwnerItems(@battler.index)
      # Item categories
      hpItems = {
          :POTION       => 20,
          :SUPERPOTION  => 50,
          :HYPERPOTION  => 200,
          :MAXPOTION    => -1,
          :BERRYJUICE   => 20,
          :SWEETHEART   => 20,
          :FRESHWATER   => 50,
          :SODAPOP      => 60,
          :LEMONADE     => 80,
          :MOOMOOMILK   => 100,
          :ORANBERRY    => 10,
          :SITRUSBERRY  => self.totalhp / 4,
          :ENERGYPOWDER => 50,
          :ENERGYROOT   => 200,
          :FULLRESTORE  => -1,
      }
      hpItems[:RAGECANDYBAR] = 20 if Settings::MECHANICS_GENERATION < 7
      singleStatusCuringItems = {
          :AWAKENING    => :SLEEP,
          :CHESTOBERRY  => :SLEEP,
          :BLUEFLUTE    => :SLEEP,
          :ANTIDOTE     => :POISON,
          :PECHABERRY   => :POISON,
          :BURNHEAL     => :BURN,
          :RAWSTBERRY   => :BURN,
          :PARALYZEHEAL => :PARALYSIS,
          :CHERIBERRY   => :PARALYSIS,
          :ICEHEAL      => :FROZEN,
          :ASPEARBERRY  => :FROZEN
      }
      allStatusCuringItems = [
          :FULLRESTORE,
          :FULLHEAL,
          :LAVACOOKIE,
          :OLDGATEAU,
          :CASTELIACONE,
          :LUMIOSEGALETTE,
          :SHALOURSABLE,
          :BIGMALASADA,
          :LUMBERRY,
          :HEALPOWDER
      ]
      xItems = {
          :XATTACK    => [:ATTACK, (Settings::MECHANICS_GENERATION >= 7) ? 2 : 1],
          :XATTACK2   => [:ATTACK, 2],
          :XATTACK3   => [:ATTACK, 3],
          :XATTACK6   => [:ATTACK, 6],
          :XDEFENSE   => [:DEFENSE, (Settings::MECHANICS_GENERATION >= 7) ? 2 : 1],
          :XDEFENSE2  => [:DEFENSE, 2],
          :XDEFENSE3  => [:DEFENSE, 3],
          :XDEFENSE6  => [:DEFENSE, 6],
          :XSPATK     => [:SPECIAL_ATTACK, (Settings::MECHANICS_GENERATION >= 7) ? 2 : 1],
          :XSPATK2    => [:SPECIAL_ATTACK, 2],
          :XSPATK3    => [:SPECIAL_ATTACK, 3],
          :XSPATK6    => [:SPECIAL_ATTACK, 6],
          :XSPDEF     => [:SPECIAL_DEFENSE, (Settings::MECHANICS_GENERATION >= 7) ? 2 : 1],
          :XSPDEF2    => [:SPECIAL_DEFENSE, 2],
          :XSPDEF3    => [:SPECIAL_DEFENSE, 3],
          :XSPDEF6    => [:SPECIAL_DEFENSE, 6],
          :XSPEED     => [:SPEED, (Settings::MECHANICS_GENERATION >= 7) ? 2 : 1],
          :XSPEED2    => [:SPEED, 2],
          :XSPEED3    => [:SPEED, 3],
          :XSPEED6    => [:SPEED, 6],
          :XACCURACY  => [:ACCURACY, (Settings::MECHANICS_GENERATION >= 7) ? 2 : 1],
          :XACCURACY2 => [:ACCURACY, 2],
          :XACCURACY3 => [:ACCURACY, 3],
          :XACCURACY6 => [:ACCURACY, 6]
      }
      scores = items.map do |item|
        if item != :REVIVE && item != :MAXREVIVE
          # Don't try to use the item if we can't use it on this Pokémon (e.g. due to Embargo)
          next [0, item] if !@battle.pbCanUseItemOnPokemon?(item, @battler.pokemon, @battler, nil, false)
          # Don't try to use the item if it doesn't have any effect, or some other condition that is not met
          next [0, item] if !ItemHandlers.triggerCanUseInBattle(item, @battler.pokemon, @battler, nil, false, @battle, nil, false)
        end

        score = 0
        # The item is a healing item
        if hpToGain = hpItems[item]
          hpLost = self.totalhp - self.hp
          hpToGain = hpLost if hpToGain == -1 || hpToGain > hpLost
          hpFraction = hpToGain / self.totalhp.to_f
          # If hpFraction is high, then this item will heal almost all our HP.
          # If it is low, then this item will heal very little of our total HP.
          # We now factor the effectiveness of using this item into this fraction.
          # Because using HP items at full health should not be an option, whereas
          # using it at 1 HP should always be preferred.
          itemEff = hpToGain / hpLost.to_f
          itemEff = 0 if hpLost == 0
          delayEff = 1.0
          if !may_die_next_round?
            # If we are likely to survive another hit of the last-used move,
            # then we should discourage using healing items this turn because
            # we can heal more if we use it later.
            delayEff = 0.3
          else
            # If we are likely to die next round, we have a choice to make.
            # It can occur that the target is also a one-shot from this point,
            # which will make move scores skyrocket which can mean we won't use our item.
            # So, if we are slower than our opponent, we will likely die first without using
            # our item and without using our move. So if this is the case, we dramatically increase
            # the score of using our item.
            last_dmg = last_damage_taken
            if last_dmg && !self.faster_than?(last_dmg[0])
              delayEff = 2.5
            end
          end
          finalFrac = hpFraction * itemEff * delayEff
          score = (finalFrac * 200).round
        end

        # Single-status-curing items
        if statusToCure = singleStatusCuringItems[item]
          if self.status == statusToCure
            factor = 1.0
            factor = 0.5 if statusToCure == :PARALYSIS # Paralysis is not that serious
            factor = 1.5 if statusToCure == :BURN && self.is_physical_attacker? # Burned while physical attacking
            factor = 2.0 if statusToCure == :POISON && self.statusCount > 0 # Toxic
            score += (140 * factor).round
          end
        end

        # All-status-curing items
        if allStatusCuringItems.include?(item)
          if self.status != :NONE
            factor = 1.0
            factor = 0.5 if self.status == :PARALYSIS # Paralysis is not that serious
            factor = 1.5 if self.status == :BURN && self.is_physical_attacker? # Burned while physical attacking
            factor = 2.0 if self.status == :POISON && self.statusCount > 0 # Toxic
            score += (120 * factor).round
          end
        end

        # X-Items
        if xStatus = xItems[item]
          stat, increase = xStatus
          # Only use X-Items on the battler's first turn
          if @battler.turnCount == 0
            factor = 1.0
            factor = 2.0 if stat == :ATTACK && self.is_physical_attacker? ||
                            stat == :SPECIAL_ATTACK && self.is_special_attacker?
            score = (80 * factor * increase).round
          end
        end

        # Revive
        if item == :REVIVE || item == :MAXREVIVE
          party = @battle.pbParty(@battler.index)
          candidate = nil
          party.each do |pkmn|
            if pkmn.fainted?
              if candidate
                if pkmn.level > candidate.level
                  candidate = pkmn
                end
              else
                candidate = pkmn
              end
            end
          end
          if candidate
            if items.include?(:MAXREVIVE) && item == :REVIVE
              score = 200
            else
              score = 400
            end
            index = party.index(candidate)
            next [score, item, index]
          end
        end

        next [score, item]
      end
      max_score = 0
      chosen_item = 0
      chosen_target = nil
      scores.each do |score, item, target|
        if score >= max_score
          max_score = score
          chosen_item = item
          chosen_target = target
        end
      end
      if chosen_item != 0
        return [max_score, chosen_item, chosen_target, !hpItems[chosen_item].nil?] if chosen_target
        return [max_score, chosen_item, nil, !hpItems[chosen_item].nil?]
      end
      return [0, 0]
    end
    def choice_locked?
      return true if self.effects[PBEffects::ChoiceBand] != nil
      return false
    end
    def can_switch?
      party = @ai.battle.pbParty(self.battler.index)
      fainted = 0
      for i in party
        fainted += 1
      end
      return false if fainted == party.length - 1
      return true
    end
    def set_up_score
      boosts = 0
      GameData::Stat.each_battle { |s| boosts += self.battler.stages[s] if self.battler.stages[s] != nil}
      return boosts
    end
    def get_switch_score
      # Yields [score, pokemon_index]
      switch = false
      # Used to render Future Sight useless
      switch_to_dark_type = false
      # The AI's party
      party = @battle.pbParty(@battler.index)

      $d_switch = 0
      $d_switch = 1 if $doubles_switch != nil

      # If the pokemon is struggling
      if !@battle.pbCanChooseAnyMove?(@battler.index)
        switch = true
      end
      # If the pokemon is perish songed and will die next turn
      if self.effects[PBEffects::PerishSong] == 1
        switch = true
      end
      if self.choice_locked?
        choiced_move_name = GameData::Move.get(self.effects[PBEffects::ChoiceBand])
        factor = 0
        opposing_side.battlers.each do |pkmn|
          factor += pkmn.calculate_move_matchup(choiced_move_name)
        end
        if factor < 2
          switch = true
        end
      end
      if self.set_up_score > 0
        switch = self.set_up_score <= rand(2)
      end
      # Encored into bad move
      if self.effects[PBEffects::Encore] > 0
        encored_move_index = @battler.pbEncoredMoveIndex
        if encored_move_index >= 0
          encored_move = @battler.moves[encored_move_index]
          if encored_move.statusMove?
            switch = true
          else
            dmgs = @damage_dealt.select { |e| e[1] == encored_move.id }
            if dmgs.size > 0
              last_dmg = dmgs[-1]
              # Bad move if it did less than 25% damage
              if last_dmg[3] < 0.25
                switch = true
              end
            else
              # No record of dealing damage with this move,
              # which probably means the target is immune somehow,
              # or the user happened to miss. Don't risk being stuck in
              # a bad move in any case, and switch.
              switch = true
            end
          end
        end
      end
      pos = @battle.positions[@battler.index]
      # If Future Sight will hit at the end of the round
      if pos.effects[PBEffects::FutureSightCounter] == 1
        # And if we have a dark type in our party
        if party.any? { |pkmn| pkmn.types.include?(:DARK) }
          # We should switch to a dark type,
          # but not if we're already close to dying anyway.
          if !self.may_die_next_round?
            switch = true
            switch_to_dark_type = true
          end
        end
      end
      if self.trapped?
        switch = false
      end
      # Get the optimal switch choice by type
      scores = get_optimal_switch_choice
      # If we should switch due to effects in battle
      if switch
        availscores = scores.select { |e| !e[2].fainted?}
        # Switch to a dark type instead of the best type matchup
        if switch_to_dark_type
          availscores = availscores.select { |e| e[2].pokemon.types.include?(:DARK) }
        end
        while availscores.size > 0
          hi_off_score, hi_def_score, proj = availscores[0]
          eligible = true
          eligible = false if proj.battler != nil # Already active
          eligible = false if proj.pokemon.egg? # Egg
          eligible = false if proj == $doubles_switch && $d_switch == 1
          if eligible
            score = (75 * hi_off_score * (switch_to_dark_type ? 2.0 : 1.0)).round
            score += 50 if [:PHYSICALWALL,:SPECIALWALL,:CLERIC].include?(proj.pokemon.role)
            score += 30 if [:DEFENSIVEPIVOT,:STALLBREAKER].include?(proj.pokemon.role)
            index = party.index(proj.pokemon)
            return [score, index]
          end
          availscores.delete_at(0)
        end
      end

      curr_score = scores.find { |e| e[2] == self }[0]
      # If the current battler is not very effective offensively in any of its types,
      # then we see if there is a battler that is super effective in at least one of its types.
      if curr_score < 1.0 && !self.trapped?
        availscores = scores.select { |e|!e[2].fainted?}
        while availscores.size > 0
          hi_off_score, hi_def_score, proj = availscores[0]
          $doubles_switch = proj if $d_switch == 0
          eligible = true
          eligible = false if proj.battler != nil # Already active
          eligible = false if proj.pokemon.egg? # Egg
          eligible = false if proj == $doubles_switch && $d_switch == 1
          if eligible && hi_off_score >= 1.0
            # Better choice than the current battler, so let's switch to this pokemon
            score = (100 * hi_off_score).round
            score += 30 if [:PHYSICALWALL,:SPECIALWALL,:CLERIC].include?(proj.pokemon.role)
            score += 15 if [:OFFENSIVEPIVOT,:STALLBREAKER].include?(proj.pokemon.role)
            index = party.index(proj.pokemon)
            return [score, index]
          end
          availscores.delete_at(0)
        end
      end
      return [0, 0]
    end

    def get_optimal_switch_choice
      party = @battle.pbParty(self.index)
      scores = party.map do |pkmn|
        proj = @ai.pokemon_to_projection(pkmn)
        if !proj
          raise "No projection found for party member #{pkmn.name}"
        end
        offensive_score = 1.0
        defensive_score = 1.0
        self.opposing_side.battlers.each do |target|
          next if target.nil?
          offensive_score *= proj.get_offense_score(target)
          defensive_score *= target.get_offense_score(proj)
        end
        next [offensive_score, defensive_score, proj]
      end
      scores.sort! do |a,b|
        ret = (b[0] <=> a[0])
        next ret if ret != 0
        # Tie-breaker for pokemon with identical offensive effectiveness
        # Prefer the one with the best defense against the targets
        # Lower is better, so a <=> b instead of b <=> a to get ascending order
        ret = (a[1] <=> b[1])
        next ret if ret != 0
        # Tie-breaker for pokemon with identical defensive effectiveness
        next b[2].pokemon.level <=> a[2].pokemon.level
      end
      #PBAI.log(scores.map { |e| e[2].pokemon.name + ": (#{e[0]}, #{e[1]})" }.join("\n"))
      return scores
    end
    # Calculates the score of the move against a specific target
    def get_move_score(target, move)
      # The target variable is a projection of a battler. We know its species and HP,
      # but its item, ability, moves and other properties are not known unless they are
      # explicitly shown or mentioned. Knowing these properties can change what our AI
      # chooses; if we know the item of our target projection, and it's an Air Balloon,
      # we won't choose a Ground move, for instance.
      if target.side == @side
        # The target is an ally
        return nil if move.function != "0DF" # Heal Pulse
        # Move score calculation will only continue if the target is not an ally,
        # or if it is an ally, then the move must be Heal Pulse (0DF).
      end
      if move.statusMove?
        # Start status moves off with a score of 30.
        # Since this makes status moves unlikely to be chosen when the other moves
        # have a high base power, all status moves should ideally be addressed individually
        # in this method, and used in the optimal scenario for each individual move.
        score = (self.defensive? || self.setup?) ? 100 : 30
        PBAI.log("Test move #{move.name} (#{score})...")
        # Trigger general score modifier code
        score = PBAI::ScoreHandler.trigger_general(score, @ai, self, target, move)
        # Trigger status-move score modifier code
        score = PBAI::ScoreHandler.trigger_status_moves(score, @ai, self, target, move)
      else
        # Set the move score to the base power of the move
        score = get_move_base_damage(move, target)
        PBAI.log("Test move #{move.name} (#{score})...")
        # Trigger general score modifier code
        score = PBAI::ScoreHandler.trigger_general(score, @ai, self, target, move)
        # Trigger damaging-move score modifier code
        score = PBAI::ScoreHandler.trigger_damaging_moves(score, @ai, self, target, move)
      end
      # Trigger move-specific score modifier code
      score = PBAI::ScoreHandler.trigger_move(move, score, @ai, self, target)
      # Prefer a different move if this move would also hit the user's ally and it is super effective against the ally
      # The target is not an ally to begin with (to exclude Heal Pulse and any other good ally-targeting moves)
      if target.side != @side
        # If the move is a status move, we can assume it has a positive effect and thus would be good for our ally too.
        if !move.statusMove?
          target_type = move.pbTarget(self)
          # If the move also targets our ally
          if [:AllNearOthers,:AllBattlers,:BothSides].include?(target_type)
            # See if we have an ally
            if ally = @side.battlers.find { |proj| proj && proj != self && !proj.fainted? }
              matchup = ally.calculate_move_matchup(move.id)
              # The move would be super effective on our ally
              if matchup > 1
                decr = (matchup / 2.0 * 100.0).round
                score -= decr
                PBAI.log("- #{decr} for super effectiveness on ally battler")
              end
            end
          end
        end
      end
      # Take 10% of the final score if the target is immune to this move.
      if !move.statusMove? && target_is_immune?(move, target) && !self.choice_locked?
        score = 0
        PBAI.log("* 0 for the target being immune")
      end
      if self.choice_locked? && target_is_immune?(move, target) && self.can_switch?
        score = 0
        PBAI.log("* 0 for the target being immune")
      end
      # Take 10% of the final score if the move is disabled and thus unusable
      if @battler.effects[PBEffects::DisableMove] == move.id
        score *= 0
        PBAI.log("* 0 for the move being disabled")
      end
      PBAI.log("= #{score}")
      return score
    end
    # Calculates adjusted base power of a move.
    # Used as a starting point for a particular move's score against a target.
    # Copied from Essentials.
    def get_move_base_damage(move, target)
      baseDmg = move.baseDamage
      baseDmg = 60 if baseDmg==1
      # Covers all function codes which have their own def pbBaseDamage
      case move.function
      when "010"   # Stomp
        baseDmg *= 2 if target.effects[PBEffects::Minimize]
      # Sonic Boom, Dragon Rage, Super Fang, Night Shade, Endeavor
      when "06A", "06B", "06C", "06D", "06E"
        baseDmg = move.pbFixedDamage(self,target)
      when "06F"   # Psywave
        baseDmg = self.level
      when "070"   # OHKO
        baseDmg = 200
      when "071", "072", "073"   # Counter, Mirror Coat, Metal Burst
        baseDmg = 60
      when "075", "076", "0D0", "12D"   # Surf, Earthquake, Whirlpool, Shadow Storm
        baseDmg = move.pbModifyDamage(baseDmg,@battler,target)
      # Gust, Twister, Venoshock, Smelling Salts, Wake-Up Slap, Facade, Hex, Brine,
      # Retaliate, Weather Ball, Return, Frustration, Eruption, Crush Grip,
      # Stored Power, Punishment, Hidden Power, Fury Cutter, Echoed Voice,
      # Trump Card, Flail, Electro Ball, Low Kick, Fling, Spit Up
      when "077", "078", "07B", "07C", "07D", "07E", "07F", "080", "085", "087",
           "089", "08A", "08B", "08C", "08E", "08F", "090", "091", "092", "097",
           "098", "099", "09A", "0F7", "113"
        baseDmg = move.pbBaseDamage(baseDmg,@battler,target)
      when "086"   # Acrobatics
        baseDmg *= 2 if !self.item || self.hasActiveItem?(:FLYINGGEM)
      when "08D"   # Gyro Ball
        targetSpeed = target.effective_speed
        userSpeed = self.effective_speed
        baseDmg = [[(25*targetSpeed/userSpeed).floor,150].min,1].max
      when "094"   # Present
        baseDmg = 50
      when "095"   # Magnitude
        baseDmg = 71
        baseDmg *= 2 if target.inTwoTurnAttack?("0CA")   # Dig
      when "096"   # Natural Gift
        baseDmg = move.pbNaturalGiftBaseDamage(@battler.item)
      when "09B"   # Heavy Slam
        baseDmg = move.pbBaseDamage(baseDmg,@battler,target)
        baseDmg *= 2 if Settings::MECHANICS_GENERATION >= 7 && target.effects[PBEffects::Minimize]
      when "0A0", "0BD", "0BE"   # Frost Breath, Double Kick, Twineedle
        baseDmg *= 2
      when "0BF"   # Triple Kick
        baseDmg *= 6   # Hits do x1, x2, x3 baseDmg in turn, for x6 in total
      when "0C0"   # Fury Attack
        if self.hasActiveAbility?(:SKILLLINK)
          baseDmg *= 5
        else
          baseDmg = (baseDmg * 31 / 10).floor    # Average damage dealt
        end
      when "0C1"   # Beat Up
        mult = 0
        @battle.eachInTeamFromBattlerIndex(@battler.index) do |pkmn,_i|
          mult += 1 if pkmn && pkmn.able? && pkmn.status == :NONE
        end
        baseDmg *= mult
      when "0C4"   # Solar Beam
        baseDmg = move.pbBaseDamageMultiplier(baseDmg,@battler,target)
      when "0D3"   # Rollout
        baseDmg *= 2 if @battler.effects[PBEffects::DefenseCurl]
      when "0D4"   # Bide
        baseDmg = 40
      when "0E1"   # Final Gambit
        baseDmg = @battler.hp
      when "144"   # Flying Press
        if GameData::Type.exists?(:FLYING)
          targetTypes = target.pbTypes(true)
          mult = Effectiveness.calculate(:FLYING,
             targetTypes[0],targetTypes[1],targetTypes[2])
          baseDmg = (baseDmg.to_f*mult/Effectiveness::NORMAL_EFFECTIVE).round
        end
        baseDmg *= 2 if target.effects[PBEffects::Minimize]
      when "166"   # Stomping Tantrum
        baseDmg *= 2 if @battler.lastRoundMoveFailed
      when "175"   # Double Iron Bash
        baseDmg *= 2
        baseDmg *= 2 if target.effects[PBEffects::Minimize]
      end
      return baseDmg
    end

    # Determines if the target is immune to a move.
    # Copied from Essentials.
    def target_is_immune?(move, target)
      type = move.pbCalcType(@battler)
      typeMod = move.pbCalcTypeMod(type, @battler, target)
      # Type effectiveness
      return true if (move.damagingMove? && Effectiveness.ineffective?(typeMod))
      # Immunity due to ability/item/other effects
      if @skill >= PBTrainerAI.mediumSkill
        case type
        when :GROUND
          return true if target.airborne? && !move.hitsFlyingTargets?
          return true if target.hasActiveAbility?(:EARTHEATER)
          return true if target.hasActiveItem?([:EARTHEATERORB,:LEVITATEORB])
        when :FIRE
          return true if target.hasActiveAbility?([:FLASHFIRE, :STEAMENGINE])
          return true if target.hasActiveItem?(:FLASHFIREORB)
        when :WATER
          return true if target.hasActiveAbility?([:DRYSKIN, :STORMDRAIN, :WATERABSORB, :IRRIGATION, :STEAMENGINE, :WATERCOMPACTION])
          return true if target.hasActiveItem?(:WATERABSORBORB)
        when :GRASS
          return true if target.hasActiveAbility?(:SAPSIPPER)
          return true if target.hasActiveItem?(:SAPSIPPERORB)
        when :ELECTRIC
          return true if target.hasActiveAbility?([:LIGHTNINGROD, :MOTORDRIVE, :VOLTABSORB])
          return true if target.hasActiveItem?(:LIGHTNINGRODORB)
        when :DRAGON
          return true if target.hasActiveAbility?(:LEGENDARMOR)
        when :DARK
          return true if target.hasActiveAbility?(:UNTAINTED)
        when :COSMIC
          return true if target.hasActiveAbility?(:DIMENSIONBLOCK)
          return true if target.hasActiveItem?(:DIMENSIONBLOCKORB)
        when :SOUND
          return true if target.hasActiveAbility?(:SOUNDPROOF)
        end
        return true if move.damagingMove? && Effectiveness.not_very_effective?(typeMod) &&
                       target.hasActiveAbility?(:WONDERGUARD)
        return true if move.damagingMove? && @battler.index != target.index && !target.opposes?(@battler) &&
                       target.hasActiveAbility?(:TELEPATHY)
        return true if move.statusMove? && move.canMagicCoat? && target.hasActiveAbility?(:MAGICBOUNCE) &&
                       target.opposes?(@battler)
        return true if move.soundMove? && target.hasActiveAbility?(:SOUNDPROOF)
        return true if move.bombMove? && target.hasActiveAbility?(:BULLETPROOF)
        if move.powderMove?
          return true if target.pbHasType?(:GRASS)
          return true if target.hasActiveAbility?(:OVERCOAT)
          return true if target.hasActiveItem?(:SAFETYGOGGLES)
        end
        return true if move.statusMove? && target.effects[PBEffects::Substitute] > 0 &&
                       !move.ignoresSubstitute?(@battler) && @battler.index != target.index
        return true if move.statusMove? && Settings::MECHANICS_GENERATION >= 7 &&
                       @battler.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK) &&
                       target.opposes?(@battler)
        return true if move.priority > 0 && @battle.field.terrain == :Psychic &&
                       target.affectedByTerrain? && target.opposes?(@battler)
      end
      return false
    end

    def get_move_accuracy(move, target)
      return 100 if target.effects[PBEffects::Minimize] && move.tramplesMinimize?(1)
      return 100 if target.effects[PBEffects::Telekinesis] > 0
      baseAcc = move.pbBaseAccuracy(@battler, target)
      return 100 if baseAcc == 0
      return baseAcc
    end

    def types(type3 = true)
      return @battler.pbTypes(type3) if @battler
      return @pokemon.types
    end
    alias pbTypes types

    def effects
      return @battler.effects
    end

    def stages
      return @battler.stages
    end

    def is_species?(species)
      return @battler.isSpecies?(species)
    end
    alias isSpecies? is_species?

    def has_type?(type)
      return @battler.pbHasType?(type)
    end
    alias pbHasType? has_type?

    def ability
      return @battler.ability
    end

    def has_ability?(ability)
      return @battler.hasActiveAbility?(ability) && (AI_KNOWS_ABILITY || @revealed_ability)
    end
    alias hasActiveAbility? has_ability?

    def has_item?(item)
      return @battler.hasActiveItem?(item) && (OMNISCIENT_AI || @revealed_item)
    end
    alias hasActiveItem? has_item?

    def moves
      if @battler.nil?
        return @pokemon.moves
      elsif OMNISCIENT_AI || @side.index == 0
        return @battler.moves
      else
        return @used_moves
      end
    end

    def opposes?(projection)
      if projection.is_a?(Battler_AI_Learning)
        return @side.index != projection.side.move_index
      else
        return @battler.index % 2 != projection.index % 2
      end
    end

    def own_side
      return @side
    end
    alias pbOwnSide own_side

    def affected_by_terrain?
      return @battler.affectedByTerrain?
    end
    alias affectedByTerrain? affected_by_terrain?

    def airborne?
      return @battler.airborne?
    end

    def semi_invulnerable?
      return @battler.semiInvulnerable?
    end
    alias semiInvulnerable? semi_invulnerable?

    def in_two_turn_attack?(*args)
      return @battler.inTwoTurnAttack?(*args)
    end
    alias inTwoTurnAttack? in_two_turn_attack?

    def can_attract?(target)
      return @battler.pbCanAttract?(target)
    end
    alias pbCanAttract? can_attract?

    def takes_indirect_damage?
      return @battler.takesIndirectDamage?
    end
    alias takesIndirectDamage? takes_indirect_damage?

    def weight
      return @battler.pbWeight
    end
    alias pbWeight weight

    def can_sleep?(inflictor, move, ignore_status = false)
      return @battler.pbCanSleep?(inflictor, false, move, ignore_status)
    end

    def can_poison?(inflictor, move)
      return @battler.pbCanPoison?(inflictor, false, move)
    end

    def can_burn?(inflictor, move)
      return @battler.pbCanBurn?(inflictor, false, move)
    end

    def can_paralyze?(inflictor, move)
      return @battler.pbCanParalyze?(inflictor, false, move)
    end

    def can_freeze?(inflictor, move)
      return @battler.pbCanFreeze?(inflictor, false, move)
    end

    def register_damage_dealt(move, target, damage)
      move = move.id if move.is_a?(GameData::Move)
      @damage_dealt << [target, move, damage, damage / target.totalhp.to_f]
    end

    def register_damage_taken(move, user, damage)
      user.used_moves << move if !user.used_moves.any? { |m| m.id == move.id }
      move = move.id
      @damage_taken << [user, move, damage, damage / @battler.totalhp.to_f]
    end

    def get_damage_by_user(user)
      return @damage_taken.select { |e| e[0] == user }
    end

    def get_damage_by_user_and_move(user, move)
      move = move.id if move.is_a?(GameData::Move)
      return @damage_taken.select { |e| e[0] == user && e[1] == move }
    end

    def get_damage_by_move(move)
      move = move.id if move.is_a?(GameData::Move)
      return @damage_taken.select { |e| e[1] == move }
    end

    def last_damage_taken
      return @damage_taken[-1]
    end

    def last_damage_dealt
      return @damage_dealt[-1]
    end

    # Estimates how much HP the battler will lose from end-of-round effects,
    # such as status conditions or trapping moves
    def estimate_hp_difference_at_end_of_round
      lost = 0
      # Future Sight
      @battle.positions.each_with_index do |pos, idxPos|
        next if !pos
        # Ignore unless future sight hits at the end of the round
        next if pos.effects[PBEffects::FutureSightCounter] != 1
        # And only if its target is this battler
        next if @battle.battlers[idxPos] != @battler
        # Find the user of the move
        moveUser = nil
        @battle.eachBattler do |b|
          next if b.opposes?(pos.effects[PBEffects::FutureSightUserIndex])
          next if b.pokemonIndex != pos.effects[PBEffects::FutureSightUserPartyIndex]
          moveUser = b
          break
        end
        if !moveUser # User isn't in battle, get it from the party
          party = @battle.pbParty(pos.effects[PBEffects::FutureSightUserIndex])
          pkmn = party[pos.effects[PBEffects::FutureSightUserPartyIndex]]
          if pkmn && pkmn.able?
            moveUser = PokeBattle_Battler.new(@battle, pos.effects[PBEffects::FutureSightUserIndex])
            moveUser.pbInitDummyPokemon(pkmn, pos.effects[PBEffects::FutureSightUserPartyIndex])
          end
        end
        if moveUser && moveUser.pokemon != @battler.pokemon
          # We have our move user, and it's not targeting itself
          move_id = pos.effects[PBEffects::FutureSightMove]
          move = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(move_id))
          # Calculate how much damage a Future Sight hit will do
          calcType = move.pbCalcType(moveUser)
          @battler.damageState.typeMod = move.pbCalcTypeMod(calcType, moveUser, @battler)
          move.pbCalcDamage(moveUser, @battler)
          dmg = @battler.damageState.calcDamage
          lost += dmg
        end
      end
      if takes_indirect_damage?
        # Sea of Fire (Fire Pledge + Grass Pledge)
        weather = @battle.pbWeather
        if side.effects[PBEffects::SeaOfFire] != 0
          unless weather == :Rain || weather == :HeavyRain ||
                 has_type?(:FIRE)
            lost += @battler.totalhp / 8.0
          end
        end
        # Leech Seed
        if self.effects[PBEffects::LeechSeed] >= 0
          lost += @battler.totalhp / 8.0
        end
        if self.effects[PBEffects::StarSap] >= 0
          lost += @battler.totalhp / 8.0
        end
        # Poison
        if poisoned? && !has_ability?(:POISONHEAL)
          dmg = statusCount == 0 ? @battler.totalhp / 8.0 : @battler.totalhp * self.effects[PBEffects::Toxic] / 16.0
          lost += dmg
        end
        # Burn
        if burned?
          lost += (Settings::MECHANICS_GENERATION >= 7 ? @battler.totalhp / 16.0 : @battler.totalhp / 8.0)
        end
        if frozen?
          lost += (Settings::MECHANICS_GENERATION >= 7 ? @battler.totalhp / 16.0 : @battler.totalhp / 8.0)
        end
        # Sleep + Nightmare
        if asleep? && self.effects[PBEffects::Nightmare]
          lost += @battler.totalhp / 4.0
        end
        # Curse
        if self.effects[PBEffects::Curse]
          lost += @battler.totalhp / 4.0
        end
        # Trapping Effects
        if self.effects[PBEffects::Trapping] != 0
          dmg = (Settings::MECHANICS_GENERATION >= 7 ? @battler.totalhp / 8.0 : @battler.totalhp / 16.0)
          if @battle.battlers[self.effects[PBEffects::TrappingUser]].hasActiveItem?(:BINDINGBAND)
            dmg = (Settings::MECHANICS_GENERATION >= 7 ? @battler.totalhp / 6.0 : @battler.totalhp / 8.0)
          end
          lost += dmg
        end
      end
      return lost
    end

    def may_die_next_round?
      dmg = last_damage_taken
      return false if dmg.nil?
      # Returns true if the damage from the last move is more than the remaining hp
      # This is used in determining if there is a point in using healing moves or items
      hplost = dmg[2]
      # We will also lose damage from status conditions and end-of-round effects like wrap,
      # so we make a rough estimate with those included.
      hplost += estimate_hp_difference_at_end_of_round
      return hplost >= self.hp
    end

    def took_more_than_x_damage?(x)
      dmg = last_damage_taken
      return false if dmg.nil?
      # Returns true if the damage from the last move did more than (x*100)% of the total hp damage
      return dmg[3] >= x
    end

    # If the battler can survive another hit from the same move the target used last,
    # but the battler will die if it does not heal, then healing is considered necessary.
    def is_healing_necessary?(x)
      return may_die_next_round? && !took_more_than_x_damage?(x)
    end

    # Healing is pointless if the target did more damage last round than we can heal
    def is_healing_pointless?(x)
      return took_more_than_x_damage?(x)
    end

    def should_switch?(target)
      return true if target.bad_against?(self)
      return false if self.bad_against?(target)
      kill = false
      for t in target.used_moves
        kill = true if target.get_move_damage(self,t) >= self.hp
      end
      if kill == true && target.faster_than?(self)
        return false
      end
      for i in self.moves
        return true if self.get_move_damage(target,i) >= target.hp
        return true if i.priority > 0 && i.damagingMove? && self.get_move_damage(target,i) >= target.hp
      end
      return true if target.bad_against?(self) && self.faster_than?(target)
      return false
    end

    def can_switch?
      party = @battle.pbParty(battler.index)
      fainted = 0
      for i in party
        fainted += 1 if i.fainted?
      end
      return false if fainted == party.length - 1
      return false if self.trapped?
      return true
    end

    def trapped?
      return self.trappedInBattle?
    end

    def discourage_making_contact_with?(target)
      return false if has_ability?(:LONGREACH)
      bad_abilities = [:WEAKARMOR, :STAMINA, :IRONBARBS, :ROUGHSKIN, :PERISHBODY]
      return true if bad_abilities.any? { |a| target.has_ability?(a) }
      return true if target.has_ability?(:CUTECHARM) && target.can_attract?(self)
      return true if (target.has_ability?(:GOOEY) || target.has_ability?(:TANGLINGHAIR)) && faster_than?(target)
      return true if target.has_item?(:ROCKYHELMET)
      return true if target.has_ability?(:EFFECTSPORE) && !has_type?(:GRASS) && !has_ability?(:OVERCOAT)
      return true if (target.has_ability?(:STATIC) || target.has_ability?(:POISONPOINT) || target.has_ability?(:FLAMEBODY)) && !has_non_volatile_status?
    end

    def get_move_damage(target, move)
      calcType = move.pbCalcType(@battler)
      target.battler.damageState.typeMod = move.pbCalcTypeMod(calcType, @battler, target.battler)
      move.pbCalcDamage(@battler, target.battler)
      return target.battler.damageState.calcDamage
    end

    # Calculates the combined type effectiveness of all user and target types
    def calculate_type_matchup(target)
      user_types = self.pbTypes(true)
      target_types = target.pbTypes(true) if target != nil
      mod = 1.0
      user_types.each do |user_type|
        target_types.each do |target_type|
          user_eff = GameData::Type.get(target_type).effectiveness(user_type)
          mod *= user_eff / 2.0
          target_eff = GameData::Type.get(user_type).effectiveness(target_type)
          mod *= 2.0 / target_eff
        end
      end
      return mod
    end

    # Calculates the type effectiveness of a particular move against this user
    def calculate_move_matchup(move_id)
      move = PokeBattle_Move.from_pokemon_move(@ai.battle, Pokemon::Move.new(move_id))
      # Calculate the type this move would be if used by us
      types = move.pbCalcType(@battler)
      types = [types] if !types.is_a?(Array)
      user_types = types
      target_types = self.pbTypes(true)
      mod = 1.0
      user_types.each do |user_type|
        target_types.each do |target_type|
          user_eff = GameData::Type.get(target_type).effectiveness(user_type)
          mod *= user_eff / 2.0
        end
      end
      return mod
    end

    # Whether the type matchup between the user and target is favorable
    def bad_against?(target)
      return calculate_type_matchup(target) < 1.0
    end

    # Whether the user would be considered an underdog to the target.
    # Considers type matchup and level
    def underdog?(target)
      return true if bad_against?(target)
      return true if target.level >= self.level + 3
      return false
    end

    def has_usable_move_type?(type)
      return self.moves.any? { |m| m.type == type && m.pp > 0 }
    end

    def get_offense_score(target)
      # Note: self does not have a @battler value as it is a party member, i.e. only a Battle::Pokemon object
      # Return 1.0+ value if self is good against the target
      user_types = self.pbTypes(true)
      target_types = target.pbTypes(true)
      max = 0
      user_types.each do |user_type|
        next unless self.has_usable_move_type?(user_type)
        mod = 1.0
        target_types.each do |target_type|
          eff = GameData::Type.get(target_type).effectiveness(user_type) / 2.0
          if eff >= 2.0
            mod *= eff
          else
            mod *= eff
          end
        end
        max = mod if mod > max
      end
      return max
    end

    def end_of_round
      @flags = {}
      $doubles_switch = nil
      $d_switch = 0
      $test_trigger = false
    end
  end
  class Side
    attr_reader :ai
    attr_reader :index
    attr_reader :battlers
    attr_reader :party
    attr_reader :trainers
    attr_reader :flags
    def initialize(ai, index, wild_pokemon = false)
      @ai = ai
      @index = index
      @battle = @ai.battle
      @wild_pokemon = wild_pokemon
      @battlers = []
      @party = []
      @flags = {}
    end
    def effects
      return @battle.sides[@index].effects
    end

    def set_party(party)
      @party = party.map { |pokemon| Battler_AI_Learning.new(self, pokemon, @wild_pokemon) }
    end

    def set_trainers(trainers)
      @trainers = trainers
    end

    def opposing_side
      return @ai.sides[1 - @index]
    end
    def recall(battlerIndex)
      index = PBAI.battler_to_proj_index(battlerIndex)
      proj = @battlers[index]
      if proj.nil?
        raise "Battler to be recalled was not found in the active battlers list."
      end
      if !proj.active?
        raise "Battler to be recalled was not active."
      end
      @battlers[index] = nil
      proj.battler = nil
    end

    def send_out(battlerIndex, battler)
      proj = @party.find { |proj| proj && proj.pokemon == battler.pokemon }
      if proj.nil?
        raise "Battler to be sent-out was not found in the party list."
      end
      if proj.active?
        raise "Battler to be sent-out was already sent out before."
      end
      index = PBAI.battler_to_proj_index(battlerIndex)
      @battlers[index] = proj
      proj.ai_index = index
      proj.battler = battler
    end
    def end_of_round
      @battlers.each { |proj| proj.end_of_round if proj }
      @flags = {}
    end
  end
end

class PokeBattle_Battle
  attr_reader :battleAI

  alias ai_initialize initialize
  def initialize(*args)
    ai_initialize(*args)
    @battleAI = PBAI.new(self, self.wildBattle?)
    @battleAI.sides[0].set_party(@party1)
    @battleAI.sides[0].set_trainers(@player)
    @battleAI.sides[1].set_party(@party2)
    @battleAI.sides[1].set_trainers(@opponent)
  end

  def pbRecallAndReplace(idxBattler, idxParty, batonPass = false)
    if @battlers[idxBattler].fainted?
      $doubles_switch = nil
      $d_switch = 0
    end
    if !@battlers[idxBattler].fainted?
      @scene.pbRecall(idxBattler)
      @battleAI.sides[idxBattler % 2].recall(idxBattler)
    end
    @battlers[idxBattler].pbAbilitiesOnSwitchOut   # Inc. primordial weather check
    @scene.pbShowPartyLineup(idxBattler & 1) if pbSideSize(idxBattler) == 1
    pbMessagesOnReplace(idxBattler, idxParty)
    pbReplace(idxBattler, idxParty, batonPass)
  end

  # Bug fix (used b instead of battler)
  def pbMessageOnRecall(battler)
    if battler.pbOwnedByPlayer?
      if battler.hp<=battler.totalhp/4
        pbDisplayBrief(_INTL("Good job, {1}! Come back!",battler.name))
      elsif battler.hp<=battler.totalhp/2
        pbDisplayBrief(_INTL("OK, {1}! Come back!",battler.name))
      elsif battler.turnCount>=5
        pbDisplayBrief(_INTL("{1}, that’s enough! Come back!",battler.name))
      elsif battler.turnCount>=2
        pbDisplayBrief(_INTL("{1}, come back!",battler.name))
      else
        pbDisplayBrief(_INTL("{1}, switch out! Come back!",battler.name))
      end
    else
      owner = pbGetOwnerName(battler.index)
      pbDisplayBrief(_INTL("{1} withdrew {2}!",owner,battler.name))
    end
  end

  alias ai_pbEndOfRoundPhase pbEndOfRoundPhase
  def pbEndOfRoundPhase
    ai_pbEndOfRoundPhase
    @battleAI.end_of_round
  end

  alias ai_pbShowAbilitySplash pbShowAbilitySplash
  def pbShowAbilitySplash(battler,delay=false,logTrigger=true,ability=nil)
    ai_pbShowAbilitySplash(battler,delay,logTrigger,ability)
    @battleAI.reveal_ability(battler) if PBAI::AI_KNOWS_ABILITY == false
  end
end

class PokeBattle_Move
  attr_reader :statUp
  attr_reader :statDown

  alias ai_pbReduceDamage pbReduceDamage
  def pbReduceDamage(user, target)
    ai_pbReduceDamage(user, target)
    @battle.battleAI.register_damage(self, user, target, target.damageState.hpLost)
  end

  def pbCouldBeCritical?(user, target)
    return false if target.pbOwnSide.effects[PBEffects::LuckyChant] > 0
    # Set up the critical hit ratios
    ratios = (Settings::MECHANICS_GENERATION >= 7) ? [24,8,2,1] : [16,8,4,3,2]
    c = 0
    # Ability effects that alter critical hit rate
    if c >= 0 && user.abilityActive?
      c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability, user, target, c)
    end
    if c >= 0 && target.abilityActive? && !@battle.moldBreaker
      c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability, user, target, c)
    end
    # Item effects that alter critical hit rate
    if c >= 0 && user.itemActive?
      c = BattleHandlers.triggerCriticalCalcUserItem(user.item, user, target, c)
    end
    if c >= 0 && target.itemActive?
      c = BattleHandlers.triggerCriticalCalcTargetItem(target.item, user, target, c)
    end
    return false if c < 0
    # Move-specific "always/never a critical hit" effects
    return false if pbCritialOverride(user,target) == -1
    return true
  end
end

class PokeBattle_Battler
  alias ai_pbInitialize pbInitialize
  def pbInitialize(pkmn, idxParty, batonPass = false)
    ai_pbInitialize(pkmn, idxParty, batonPass)
    ai = @battle.battleAI
    sideIndex = @index % 2
    ai.sides[sideIndex].send_out(@index, self)
  end

  alias ai_pbFaint pbFaint
  def pbFaint(*args)
    ai_pbFaint(*args)
    @battle.battleAI.faint_battler(self)
  end
end

class PokeBattle_PoisonMove
  attr_reader :toxic
end

class Array
  def sum
    n = 0
    self.each { |e| n += e }
    n
  end
end

# Overwrite Frisk to show the enemy held item
BattleHandlers::AbilityOnSwitchIn.add(:FRISK,
  proc { |ability,battler,battle|
    foes = []
    battle.eachOtherSideBattler(battler.index) do |b|
      foes.push(b) if b.item != nil
    end
    if foes.length > 0
      battle.pbShowAbilitySplash(battler)
      if Settings::MECHANICS_GENERATION >= 7
        foes.each do |b|
          battle.pbDisplay(_INTL("{1} frisked {2} and found its {3}!",
             battler.pbThis, b.pbThis(true), GameData::Item.get(b.item).name))
          battle.battleAI.reveal_item(b)
        end
      else
        foe = foes[battle.pbRandom(foes.length)]
        battle.pbDisplay(_INTL("{1} frisked the foe and found one {2}!",
           battler.pbThis, GameData::Item.get(foe.item).name))
        battle.battleAI.reveal_item(foe)
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)
