class PBAI
  class ScoreHandler
    @@GeneralCode = []
    @@MoveCode = {}
    @@StatusCode = []
    @@DamagingCode = []

    def self.add_status(&code)
      @@StatusCode << code
    end

    def self.add_damaging(&code)
      @@DamagingCode << code
    end

    def self.add(*moves, &code)
      if moves.size == 0
        @@GeneralCode << code
      else
        moves.each do |move|
          if move.is_a?(Symbol) # Specific move
            id = GameData::Move.get(move).id
            raise "Invalid move #{move}" if id.nil? || id == 0
            @@MoveCode[id] = code
          elsif move.is_a?(String) # Function code
            @@MoveCode[move] = code
          end
        end
      end
    end

    def self.trigger(list, score, ai, user, target, move)
      return score if list.nil?
      list = [list] if !list.is_a?(Array)
      list.each do |code|
        next if code.nil?
        newscore = code.call(score, ai, user, target, move)
        score = newscore if newscore.is_a?(Numeric)
      end
      return score
    end

    def self.trigger_general(score, ai, user, target, move)
      return self.trigger(@@GeneralCode, score, ai, user, target, move)
    end

    def self.trigger_status_moves(score, ai, user, target, move)
      return self.trigger(@@StatusCode, score, ai, user, target, move)
    end

    def self.trigger_damaging_moves(score, ai, user, target, move)
      return self.trigger(@@DamagingCode, score, ai, user, target, move)
    end

    def self.trigger_move(move, score, ai, user, target)
      id = move.id
      id = move.function if !@@MoveCode[id]
      return self.trigger(@@MoveCode[id], score, ai, user, target, move)
    end
  end
end

#=============================================================================#
#                                                                             #
# Multipliers                                                                 #
#                                                                             #
#=============================================================================#


# Effectiveness modifier
# For this to have a more dramatic effect, this block could be moved lower down
# so that it factors in more score modifications before multiplying.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  # Effectiveness doesn't add anything for fixed-damage moves.
  next if move.is_a?(PokeBattle_FixedDamageMove) || move.statusMove?
  # Add half the score times the effectiveness modifiers. Means super effective
  # will be a 50% increase in score.
  target_types = target.types
  mod = move.pbCalcTypeMod(move.type, user, target) / Effectiveness::NORMAL_EFFECTIVE.to_f
  # If mod is 0, i.e. the target is immune to the move (based on type, at least),
  # we do not multiply the score to 0, because immunity is handled as a final multiplier elsewhere.
  if mod != 0 && mod != 1
    score *= mod
    PBAI.log("* #{mod} for effectiveness")
  end
  next score
end



#=============================================================================#
#                                                                             #
# All Moves                                                                   #
#                                                                             #
#=============================================================================#


# Accuracy modifier to favor high-accuracy moves
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if user.battler == target.battler
  accuracy = user.get_move_accuracy(move, target)
  missing = 100 - accuracy
  # (High) Jump Kick, a move that damages you when you miss
  if move.function == "10B"
    # Decrease the score more drastically if it has lower accuracy
    missing *= 2.0
  end
  missing = 0 if user.hasActiveAbility?(:NOGUARD)
  if missing > 0
    score -= missing
    PBAI.log("- #{missing} for accuracy")
  end
  next score
end

#Prefer sound moves if a substitute is up or if holding Throat Spray
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.soundMove?
  roles = []
    for i in user.roles
      roles.push(i)
    end
  dmg = user.get_move_damage(target, move)
  if target.effects[PBEffects::Substitute] > 0 && dmg >= target.hp
    score += 100
    PBAI.log("+ 100 for being able to kill behind a Substitute")
  end
  if user.hasActiveItem?(:THROATSPRAY)
    score += 100
    PBAI.log("+ 100 for activating Throat Spray")
    if user.has_role?([:SETUPSWEEPER,:WINCON,:SPECIALBREAKER])#.include?(roles)
      score += 50
      PBAI.log("+ 50 ")
    end
  end
  next score
end

#Prefer moves boosted by the field
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  fe = FIELD_EFFECTS[ai.battle.field.field_effects]
  next if move.statusMove?
  for key in fe[:move_damage_boost].keys
    if key > 1.0 && fe[:move_damage_boost][key].include?(move.id)
      score += 100
      PBAI.log("+ 100 for Field boost")
    end
  end
  for key2 in fe[:type_damage_change].keys
    if key2 > 1.0 && fe[:type_damage_change][key2].include?(move.type)
      score += 100
      PBAI.log("+ 100 for Field boost")
    end
  end
  next score
end

#Prefer slicing moves if you have Sharpness
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.slicingMove?
  if user.hasActiveAbility?(:SHARPNESS)
    score += 100
    PBAI.log("+ 100 for Sharpness boost")
  end
  next score
end

#Prefer Beam moves if you have Tight Focus
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.beamMove?
  if user.hasActiveAbility?(:TIGHTFOCUS)
    score += 100
    PBAI.log("+ 100 for Tight Focus boost")
  end
  next score
end

#Prefer Biting moves if you have Strong Jaw
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.bitingMove?
  if user.hasActiveAbility?(:STRONGJAW)
    score += 100
    PBAI.log("+ 100 for Strong Jaw boost")
  end
  next score
end

#Prefer Punching moves if you have Iron Fist
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.punchingMove?
  if user.hasActiveAbility?(:IRONFIST)
    score += 100
    PBAI.log("+ 100 for Iron Fist boost")
  end
  next score
end

#Prefer Bomb moves if you have Ballistic
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.bombMove?
  if user.hasActiveAbility?(:BALLISTIC)
    score += 100
    PBAI.log("+ 100 for Ballistic boost")
  end
  next score
end

#Prefer Pulse moves if you have Mega Launcher
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.pulseMove?
  if user.hasActiveAbility?(:MEGALAUNCHER)
    score += 100
    PBAI.log("+ 100 for Mega Launcher boost")
  end
  next score
end

#Prefer Sound moves if you have Punk Rock
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.soundMove?
  if user.hasActiveAbility?(:PUNKROCK)
    score += 100
    PBAI.log("+ 100 for Punk Rock boost")
  end
  next score
end

#Prefer weaker Sound moves if you have Subwoofer
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.soundMove?
  if user.hasActiveAbility?(:SUBWOOFER) && move.baseDamage > 70
    score += 100
    PBAI.log("+ 100 for Subwoofer boost")
  end
  next score
end

#Discount Status Moves if Taunted
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.statusMove? && user.effects[PBEffects::Taunt] > 0
      score -= 1000
      PBAI.log("- 1000 to prevent failing")
  end
  if $spam_block_triggered && move.statusMove? && target.faster_than?(user) && $spam_block_flags[:choice].is_a?(PokeBattle_Move) && $spam_block_flags[:choice].function == "0BA"
    score -= 1000
    PBAI.log("- 1000 because target is going for Taunt")
  end
  next score
end

#Properly choose moves if Tormented
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if move == user.lastRegularMoveUsed && user.effects[PBEffects::Torment]
      score -= 100000
      PBAI.log("- 100000 to prevent failing")
  end
  next score
end


# Increase/decrease score for each positive/negative stat boost the move gives the user
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.is_a?(PokeBattle_MultiStatUpMove) && !move.is_a?(PokeBattle_StatUpMove) &&
          !move.is_a?(PokeBattle_StatDownMove)
  next if move.damagingMove? && user.hasActiveAbility?(:SHEERFORCE)
  boosts = 0
  atkBoosts = 0
  spAtkBoosts = 0
  evBoosts = 0
  stats = []
  if move.statUp
    for i in 0...move.statUp.size / 2
      stat = move.statUp[i * 2]
      incr = move.statUp[i * 2 + 1]
      boosts += incr
      atkBoosts += incr if stat == :ATTACK
      spAtkBoosts += incr if stat == :SPECIAL_ATTACK
      evBoosts += incr if stat == :EVASION
      stats << stat
    end
  end
  if move.statDown
    for i in 0...move.statDown.size / 2
      stat = move.statDown[i * 2]
      decr = move.statDown[i * 2 + 1]
      boosts -= decr if
      atkBoosts -= decr if stat == :ATTACK
      spAtkBoosts -= decr if stat == :SPECIAL_ATTACK
      stats << stat if !stats.include?(stat)
    end
  end
  # Increase score by 10 * (net stage differences)
  # If attack is boosted and the user is a physical attacker,
  # these stage increases are multiplied by 20 instead of 10.
  if atkBoosts > 0 && user.is_physical_attacker?
    atkIncr = (atkBoosts * 30 * (2 - (user.stages[:ATTACK] + 6) / 6.0)).round
    if atkIncr > 0
      score += atkIncr
      PBAI.log("+ #{atkIncr} for attack boost and being a physical attacker")
      boosts -= atkBoosts
    end
  end
  # If spatk is boosted and the user is a special attacker,
  # these stage increases are multiplied by 20 instead of 10.
  if spAtkBoosts > 0 && user.is_special_attacker?
    spatkIncr = (spAtkBoosts * 30 * (2 - (user.stages[:SPECIAL_ATTACK] + 6) / 6.0)).round
    if spatkIncr > 0
      score += spatkIncr
      PBAI.log("+ #{spatkIncr} for spatk boost and being a special attacker")
      boosts -= spAtkBoosts
    end
  end
  # Boost to evasion
  if evBoosts != 0
    evIncr = (evBoosts * 50 * (2 - (user.stages[:EVASION] + 6) / 6.0)).round
    if evIncr > 0
      score += evIncr
      PBAI.log("+ #{evIncr} for evasion boost")
      boosts -= evBoosts
    end
  end
  # All remaining stat increases (or decreases) are multiplied by 25 and added to the score.
  if boosts != 0
    total = 6 * stats.size
    eff = total
    user.stages.each_with_index do |value, stage|
      if stats.include?(stage)
        eff -= value
      end
    end
    fact = 1.0
    fact = eff / total.to_f if total != 0
    incr = (boosts * 25 * fact).round
    if incr > 0
      score += incr
      PBAI.log("+ #{incr} for general user buffs (#{eff}/#{total} effectiveness)")
    end
  end
  next score
end


# Increase/decrease score for each positive/negative stat boost the move gives the target
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.is_a?(PokeBattle_TargetStatDownMove) && !move.is_a?(PokeBattle_TargetMultiStatDownMove)
  debuffs = 0
  accDecreases = 0
  stats = []
  if move.statDown
    for i in 0...move.statDown.size / 2
      stat = move.statDown[i * 2]
      decr = move.statDown[i * 2 + 1]
      debuffs += decr
      accDecreases += decr if stat == :ACCURACY
      stats << stat if stat != :EVASION && stat != :ACCURACY
    end
  end
  if accDecreases != 0 && target.stages[:ACCURACY] != -6
    accIncr = (accDecreases * 50 * (target.stages[:ACCURACY] + 6) / 6.0).round
    score += accIncr
    debuffs -= accIncr
    PBAI.log("+ #{accIncr} for target accuracy debuff")
  end
  # All remaining stat decrases are multiplied by 10 and added to the score.
  if debuffs > 0 && !target.hasActiveAbility?([:CLEARBODY,:WHITESMOKE,:FULLMETALBODY,:CONTRARY])
    total = 6 * stats.size
    eff = total
    target.stages.each_with_index do |value, stage|
      if stats.include?(stage)
        eff += value
      end
    end
    fact = 1.0
    fact = eff / total.to_f if total != 0
    incr = (debuffs * 25 * fact).round
    score += incr
    PBAI.log("+ #{incr} for general target debuffs (#{eff}/#{total} effectiveness)")
  end
  next score
end


# Prefer priority moves that deal enough damage to knock the target out.
# Use previous damage dealt to determine if it deals enough damage now,
# or make a rough estimate.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  # Apply this logic only for priority moves
  next if move.priority <= 0 || move.function == "0D4" || move.statusMove? || target.hasActiveAbility?([:ARMORTAIL,:QUEENLYMAJESTY,:DAZZLING]) || (ai.battle.field.terrain == :Psychic && target.affectedByTerrain?)
  next if move.statusMove? && user.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK)
  # Calculate the damage this priority move will do.
  # The AI kind of cheats here, because this takes all items, berries, abilities, etc. into account.
  # It is worth for the effect though; the AI using a priority move to prevent
  # you from using one last move before you faint.
  dmg = user.get_move_damage(target, move)
  if dmg >= target.battler.hp
    PBAI.log("+ 250 for priority move with predicted damage (#{dmg}) >= target hp (#{target.battler.hp})")
    score += 250
  end
  if target.hp <= target.totalhp/4
    score += 100
    PBAI.log("+ 100 for attempting to kill the target with priority")
    if $spam_block_flags[:no_priority_flag].include?(target)
      score += 100
      PBAI.log("+ 100 for knowing target has no priority of its own")
    end
  end
  if user.hp <= user.totalhp/4 && target.faster_than?(user)
    score += 100
    PBAI.log("+ 100 for attempting to do last minute damage to the target with priority")
    if $spam_block_flags[:no_priority_flag].include?(target)
      score += 100
      PBAI.log("+ 100 for knowing target has no priority of its own")
    end
  end
  if user.turnCount > 0 && move.function == "012"
    score = -1000
    PBAI.log("* 0 to prevent Fake Out failing")
  end
  next score
end


# Encourage using fixed-damage moves if the fixed damage is more than the target has HP
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if !move.is_a?(PokeBattle_FixedDamageMove) || move.function == "070" || move.function == "0D4"
  dmg = move.pbFixedDamage(user, target)
  dmg = 0 if dmg == nil
  if dmg >= target.hp
    score += 175
    PBAI.log("+ 175 for this move's fixed damage being enough to knock out the target")
  end
  next score
end


# See if any moves used in the past did enough damage to now kill the target,
# and if so, give that move slightly more preference.
# There can be more powerful moves that might also take out the user,
# but if this move will also take the user out, this is a safer option.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if move.function == "0D4" # Bide
  # Get all times this move was used on the target
  ary = target.get_damage_by_user_and_move(user, move)
  # If this move has been used before, and the move is not a two-turn move
  if ary != 0 && ary.size > 0 && !move.chargingTurnMove? && move.function != "0C2" # Hyper Beam
    # Calculate the average damage of every time this move was used on the target
    avg = ary.map { |e| e[2] }.sum / ary.size.to_f
    # If the average damage this move dealt is enough to kill the target, increase likelihood of choosing this move
    if avg >= target.hp
      score += 100
      PBAI.log("+ 100 for this move being likely to take out the target")
    end
  end
  next score
end


# Prefer moves that are usable while the user is asleep
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  # If the move is usable while asleep, and if the user won't wake up this turn
  # Kind of cheating, but insignificant. This way the user can choose a more powerful move instead
  if move.usableWhenAsleep?
    if user.asleep? && user.statusCount > 1
      score += 200
      PBAI.log("+ 200 for being able to use this move while asleep")
    else
      score -= 50
      PBAI.log("- 50 for this move will have no effect")
    end
  end
  next score
end

# Prevent moves that fail in Primal Weather
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if (ai.battle.pbWeather == :HarshSun && move.type == :WATER) || (ai.battle.pbWeather == :HeavyRain && move.type == :FIRE)
    score -= 1000
    PBAI.log("* 0 because the weather will make the move unusable")
  end
  next score
end

#Weather Weakened
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  case ai.battle.pbWeather
  when :Rain
    if move.type == :FIRE
      score *= 0.5
    elsif move.type == :WATER
      score *= 1.5
    end
  when :Sun
    if move.type == :WATER
      score *= 0.5
    elsif move.type == :FIRE
      score *= 1.5
    end
  when :Sleet
    if move.type == :FIRE
      score *= 0.5
    end
  when :Eclipse
    case move.type
    when :FAIRY,:PSYCHIC
      score *= 0.5
    when :DARK,:GHOST
      score *= 1.5
    end
  when :Windy
    case move.type
    when :ROCK,:ICE
      score *= 0.5
    end
  when :StrongWinds
    case move.type
    when :DRAGON,:ICE,:FAIRY,:COSMIC,:ROCK,:ELECTRIC
      score *= 0.5
    end
  when :AcidRain
    if move.type == :POISON
      score *= 1.5
    end
  end
  next score
end


# Prefer moves that can thaw the user if the user is frozen
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  # If the user is frozen and the move thaws the user
  if user.frozen? && move.thawsUser?
    score += 80
    PBAI.log("+ 80 for being able to thaw the user")
  end
  next score
end

# Discourage using OHKO moves if the target is higher level or it has sturdy
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.function == "070" # OHKO Move
    if target.has_ability?(:STURDY)
      score -= 100
      PBAI.log("- 100 for the target has Sturdy")
    end
    if target.level > user.level
      score -= 80
      PBAI.log("- 80 for the move will fail due to level difference")
    end
    score -= 50
    PBAI.log("- 50 for OHKO moves are generally considered bad")
  end
  next score
end


# Encourage using trapping moves, since they're generally weak
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.function == "0CF" # Trapping Move
    if target.effects[PBEffects::Trapping] == 0 # The target is not yet trapped
      score += 60
      PBAI.log("+ 60 for initiating a multi-turn trap")
    end
  end
  next score
end


# Encourage using flinching moves if the user is faster
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.flinchingMove? && (user.faster_than?(target) || move.priority > 0)
    score += 50
    PBAI.log("+ 50 for being able to flinch the target")
    if user.turnCount == 0 && move.function == "012"
      score += 500
      PBAI.log("+ 500 for using Fake Out turn 1")
      if ai.battle.pbSideSize(0) == 2
        score += 200
        PBAI.log("+ 200 for being in a Double battle")
      end
    elsif user.turnCount != 0 && move.function == "012"
      score = -1000
      PBAI.log("* 0 to stop Fake Out beyond turn 1")
    end
  end
  next score
end


# Discourage using a multi-hit physical move if the target has an item or ability
# that will damage the user on each contact.
# Also slightly discourages physical moves if the target has a bad ability in general.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.pbContactMove?(user)
    if user.discourage_making_contact_with?(target)
      if move.multiHitMove?
        score -= 60
        PBAI.log("- 60 for the target has an item or ability that activates on each contact")
      else
        score -= 30
        PBAI.log("- 30 for the target has an item or ability that activates on contact")
      end
    end
  end
  next score
end


# Encourage using moves that can cause a burn.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.is_a?(PokeBattle_BurnMove) && !target.burned? && target.can_burn?(user, move)
    chance = move.pbAdditionalEffectChance(user, target)
    chance = 100 if chance == 0
    if chance > 0 && chance <= 100
      if target.is_physical_attacker?
        add = 30 + chance * 2
        score += add
        PBAI.log("+ #{add} for being able to burn the physical-attacking target")
      else
        score += chance
        PBAI.log("+ #{chance} for being able to burn the target")
      end
    end
    if move.statusMove? && (user.pbHasMove?(:HEX) || user.pbHasMove?(:BITTERMALICE)|| user.pbHasMove?(:BARBBARRAGE)|| user.pbHasMove?(:INFERNALPARADE)) && target.can_burn?(user,move)
      score += 200
      PBAI.log("+ 200 to set up for Hex-style spam")
    end
    if move.statusMove? && (target.hasActiveAbility?([:WATERVEIL,:COMATOSE,:WATERBUBBLE,:FAIRYBUBBLE,:WELLBAKEDBODY,:STEAMENGINE,:FLASHFIRE,:PURIFYINGSALT,:GOODASGOLD]) || !target.can_burn?(user, move))
      score -= 1000
      PBAI.log("- 1000 for not being able to status")
    end
  end
  next score
end

#Remove a move as a possible choice if not the one Choice locked into
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if user.effects[PBEffects::ChoiceBand]
    choiced_move = user.effects[PBEffects::ChoiceBand]
    if choiced_move == move.id
      score += 500
      PBAI.log("+ 500 for being Choice locked")
      if !user.can_switch?
        score += 1000
        PBAI.log("+ 1000 for being Choice locked and unable to switch")
      end
      if user.can_switch? && user.get_move_damage(target, move) < target.totalhp/4
        score = 0
        PBAI.log("* 0 to encourage switching when Choice Locked into something bad")
      end
    else
      score = -1000
      PBAI.log("- 1000 for being Choice locked")
    end
  end
  next score
end


# Encourage using moves that can cause freezing.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.is_a?(PokeBattle_FreezeMove) && !target.frozen? && target.can_freeze?(user, move)
    chance = move.pbAdditionalEffectChance(user, target)
    chance = 100 if chance == 0
    if chance > 0 && chance <= 100
      if target.is_special_attacker?
        add = 30 + chance * 2
        score += add
        PBAI.log("+ #{add} for being able to frostbite the special-attacking target")
      else
        score += chance
        PBAI.log("+ #{chance} for being able to frostbite the target")
      end
    end
    if move.statusMove? && (target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD]) || !target.can_freeze?(user, move) || user.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK)) || target.hasActiveAbility?([:MAGMAARMOR,:COMATOSE,:PURIFYINGSALT,:GOODASGOLD])
      score -= 1000
      PBAI.log("- 1000 for not being able to status")
    end
  end
  next score
end


# Encourage using moves that can cause paralysis.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  next if target.hasActiveAbility?([:LIMBER,:COMATOSE,:PURIFYINGSALT,:GOODASGOLD,:FAIRYBUBBLE]) && move.statusMove?
  if move.is_a?(PokeBattle_ParalysisMove) && !target.paralyzed? && target.can_paralyze?(user, move)
    chance = move.pbAdditionalEffectChance(user, target)
    chance = 100 if chance == 0
    if chance > 0 && chance <= 100
      score += chance
      PBAI.log("+ #{chance} for being able to paralyze the target")
    end
    if move.statusMove? && (target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD]) || !target.can_paralyze?(user, move) || user.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK)) || target.hasActiveAbility?([:LIMBER,:COMATOSE,:PURIFYINGSALT,:FAIRYBUBBLE,:GOODASGOLD])
      score -= 1000
      PBAI.log("- 1000 for not being able to status")
    end
    if move.statusMove? && (user.target_is_immune?(move,target) || target.paralyzed?)
      score -= 1000
      PBAI.log("- 1000 for being immune")
    end
  end
  next score
end


# Encourage using moves that can cause sleep.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.is_a?(PokeBattle_SleepMove) && !target.asleep? && target.can_sleep?(user, move)
    chance = move.pbAdditionalEffectChance(user, target)
    chance = 100 if chance == 0
    if chance > 0 && chance <= 100
      score += chance
      PBAI.log("+ #{chance} for being able to put the target to sleep")
    end
    if move.statusMove? && (target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD]) || !target.can_sleep?(user, move) || user.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK)) || target.hasActiveAbility?([:COMATOSE,:INSOMNIA,:VITALSPIRIT,:CACOPHONY,:PURIFYINGSALT,:GOODASGOLD])
      score -= 1000
      PBAI.log("- 1000 for not being able to status")
    end
  end
  next score
end


# Encourage using moves that can cause poison.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.is_a?(PokeBattle_PoisonMove) && !target.poisoned? && target.can_poison?(user, move)
    chance = move.pbAdditionalEffectChance(user, target)
    chance = 100 if chance == 0
    if chance > 0 && chance <= 100
      if move.toxic
        add = chance * 1.4 * move.pbNumHits(user, [target])
        score += add
        PBAI.log("+ #{add} for being able to badly poison the target")
        if move.statusMove? && ((target.pbHasType?(:POISON) || target.pbHasType?(:STEEL) && !user.hasActiveAbility?([:NITRIC,:CORROSION])) || target.hasActiveAbility?([:POISONHEAL,:IMMUNITY,:TOXICBOOST,:GUTS,:MARVELSCALE,:MAGICBOUNCE]) || target.status != :NONE || ai.battle.field.terrain == :Misty) 
          score -= 1000
          PBAI.log("- 1000 because the target cannot be poisoned")
        else
          if user.has_role?(:TOXICSTALLER)
            score += 50
            PBAI.log("+ 50 for being a Toxic Staller")
          end
        end
      else
        add = chance * move.pbNumHits(user, [target])
        score += add
        PBAI.log("+ #{add} for being able to poison the target")
      end
    end
    if move.statusMove? && (target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD]) || !target.can_poison?(user, move) || user.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK)) || target.hasActiveAbility?([:IMMUNITY,:TOXICBOOST,:COMATOSE,:PURIFYINGSALT,:GOODASGOLD])
      score -= 1000
      PBAI.log("- 1000 for not being able to status")
    end
  end
  next score
end


# Encourage using moves that can cause confusion.
PBAI::ScoreHandler.add do |score, ai, user, target, move|
  if move.is_a?(PokeBattle_ConfuseMove) && !target.confused?
    chance = move.pbAdditionalEffectChance(user, target)
    chance = 100 if chance == 0
    if chance > 0 && chance <= 100
      add = chance * move.pbNumHits(user, [target])
      # The higher the target's attack stats, the more beneficial it is to confuse the target.
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = target.stages[:ATTACK] + 6
      factor = stageMul[stage] / stageDiv[stage].to_f
      add *= factor
      score += add
      PBAI.log("+ #{add} for being able to confuse the target")
    end
    if move.statusMove? && (target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD,:OWNTEMPO]) || target.confused?)
      score -= 1000
      PBAI.log("- 1000 because it can't confuse")
    end
  end
  next score
end



#=============================================================================#
#                                                                             #
# Damaging Moves                                                              #
#                                                                             #
#=============================================================================#


# STAB modifier
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  # STAB doesn't add anything for fixed-damage moves.
  next if move.is_a?(PokeBattle_FixedDamageMove)
  calcType = move.pbCalcType(user.battler)
  if calcType != nil && user.has_type?(calcType)
    if user.has_ability?(:ADAPTABILITY)
      PBAI.log("+ 90 for STAB with Adaptability")
      score += 90
    else
      PBAI.log("+ 50 for STAB")
      score += 50
    end
  end
  next score
end


# Stat stages and physical/special attacker label
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  # Stat boosts don't add anything for fixed-damage moves.
  next if move.is_a?(PokeBattle_FixedDamageMove)
  # If the move is physical
  if move.physicalMove?
    # Increase the score by 25 per stage increase/decrease
    if user.stages[:ATTACK] != 0
      add = user.stages[:ATTACK] * 25
      score += add
      PBAI.log("#{add < 0 ? "-" : "+"} #{add.abs} for attack stages")
    end
    # Make the move more likely to be chosen if this user is also considered a physical attacker.
    if user.is_physical_attacker?
      score += 30
      PBAI.log("+ 30 for being a physical attacker")
    end
  end

  # If the move is special
  if move.specialMove?
    # Increase the score by 25 per stage increase/decrease
    if user.stages[:SPECIAL_ATTACK] != 0
      add = user.stages[:SPECIAL_ATTACK] * 25
      score += add
      PBAI.log("#{add < 0 ? "-" : "+"} #{add.abs} for attack stages")
    end
    # Make the move more likely to be chosen if this user is also considered a special attacker.
    if user.is_special_attacker?
      score += 30
      PBAI.log("+ 30 for being a special attacker")
    end
  end
  next score
end


# Discourage using damaging moves if the target is semi-invulnerable and slower,
# and encourage using damaging moves if they can break through the semi-invulnerability
# (e.g. prefer earthquake when target is underground)
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  # Target is semi-invulnerable
  if target.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0
    encourage = false
    discourage = false
    # User will hit first while target is still semi-invulnerable.
    # If this move will do extra damage because the target is semi-invulnerable,
    # encourage using this move. If not, discourage using it.
    if user.faster_than?(target)
      if target.in_two_turn_attack?("0C9", "0CC", "0CE") # Fly, Bounce, Sky Drop
        encourage = move.hitsFlyingTargets?
        discourage = !encourage
      elsif target.in_two_turn_attack?("0CA") # Dig
        # Do not encourage using Fissure, even though it can hit digging targets, because it's an OHKO move
        encourage = move.hitsDiggingTargets? && move.function != "070"
        discourage = !encourage
      elsif target.in_two_turn_attack?("0CB") # Dive
        encourage = move.hitsDivingTargets?
        discourage = !encourage
      else
        discourage = true
      end
    end
    # If the user has No Guard
    if user.has_ability?(:NOGUARD)
      # Then any move would be able to hit the target, meaning this move wouldn't be anything special.
      encourage = false
      discourage = false
    end
    if encourage
      score += 100
      PBAI.log("+ 100 for being able to hit through a semi-invulnerable state")
    elsif discourage
      score -= 150
      PBAI.log("- 150 for not being able to hit target because of semi-invulnerability")
    end
  end
  next score
end


# Lower the score of multi-turn moves, because they likely have quite high power and thus score.
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  if !user.hasActiveItem?(:POWERHERB) && (move.chargingTurnMove? || move.function == "0C2") # Hyper Beam
    score -= 70
    PBAI.log("- 70 for requiring a charging turn")
  end
  next score
end


# Prefer using damaging moves based on the level difference between the user and target,
# because if the user will get one-shot, then there's no point in using set-up moves.
# Furthermore, if the target is more than 5 levels higher than the user, priority
# get an additional boost to ensure the user can get a hit in before being potentially one-shot.
# TODO: Make "underdog" method, also for use by moves like perish song or explode and such
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  # Start counting factor this when there's a level difference of greater than 5
  if user.underdog?(target)
    add = 5 * (target.level - user.level - 5)
    if add > 0
      score += add
      PBAI.log("+ #{5 * (target.level - user.level - 5)} for preferring damaging moves due to being a low level")
    end
    if move.priority > 0 && move.function != "012"
      score += 30
      PBAI.log("+ 30 for being a priority move and being and underdog")
    end
  end
  next score
end

PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  # Start counting factor this when there's a level difference of greater than 5
  dmg = user.get_move_damage(target, move)
  if move.priority > 0 && dmg >= target.battler.hp
    score += 90
    PBAI.log("+ 90 for being a priority move and being able to KO the opponent")
  end
  next score
end
# Discourage using physical moves when the user is burned
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  if user.burned?
    if user.hasActiveAbility?(:GUTS) && move.physicalMove?
      score += 100
      PBAI.log("+ 100 for taking advantage of Guts")
    elsif !user.hasActiveAbility?(:GUTS) && move.physicalMove? && move.function != "07E"
      score -= 50
      PBAI.log("- 50 for being a physical move and being burned")
    end
  end
  if user.frozen?
    if move.specialMove?
      score -= 50
      PBAI.log("- 50 for being a special move and being frostbitten")
    end
  end
  next score
end


# Encourage high-critical hit rate moves, or damaging moves in general
# if Laser Focus or Focus Energy has been used
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  next if !move.pbCouldBeCritical?(user.battler, target.battler)
  if move.highCriticalRate? || user.effects[PBEffects::LaserFocus] > 0 ||
     user.effects[PBEffects::FocusEnergy] > 0
    score += 30
    PBAI.log("+ 30 for having a high critical-hit rate")
  end
  next score
end


# Discourage recoil moves if they would knock the user out
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  if move.is_a?(PokeBattle_RecoilMove)
    dmg = move.pbRecoilDamage(user.battler, target.battler)
    if dmg >= user.hp
      score -= 50
      PBAI.log("- 50 for the recoil will knock the user out")
    end
  end
  next score
end

# Encourage using spread moves if in double battles
PBAI::ScoreHandler.add_damaging do |score, ai, user, target, move|
  next score if !ai.battle.doublebattle
  target_type = move.pbTarget(user)
  ally = user.side.battlers.find {|proj| proj && proj != self && !proj.fainted?}
  if ai.battle.doublebattle && [:AllNearFoes].include?(target_type)
    score += 100
    PBAI.log("+ 100 for being able to hit both targets")
    for targ in user.opposing_side.battlers
      targ_moves = $game_switches[LvlCap::Expert] ? targ.moves : targ.used_moves
      if !targ_moves.nil?
        spread = targ_moves.find {|mov| mov.function == "0AC"}
      end
      if spread
        score -= 1000
        PBAI.log("- 1000 to predict Wide Guard")
      end
    end
  elsif ai.battle.doublebattle && [:AllNearOthers,:AllBattlers,:BothSides].include?(target_type)
    if target_is_immune?(move,ally)
      score += 100
      PBAI.log("+ 100 for spread move that ally is immune to")
    else
      type = move.pbCalcType(user)
      matchup = move.pbCalcTypeMod(type, user, ally)
      dmg = user.get_move_damage(ally, move)
      if Effectiveness.super_effective?(matchup)
        score -= 150
        PBAI.log("- 150 to prevent super effective damage on our ally")
      elsif Effectiveness.not_very_effective?(matchup) && dmg < ally.totalhp / 3
        score += 75
        PBAI.log("+ 75 for a spread move that the ally cannot be 2HKO'd by")
      else
        diff = 100 - ((dmg/ally.totalhp)*100)
        change = diff == 0 ? -50 : diff
        score += change
        change > 0 ? PBAI.log("+ #{change}") : PBAI.log("#{change}")
      end
    end
    for targ in user.opposing_side.battlers
      targ_moves = $game_switches[LvlCap::Expert] ? targ.moves : targ.used_moves
      if !targ_moves.nil?
        spread = targ_moves.find {|mov| mov.function == "0AC"}
      end
      if spread
        score -= 1000
        PBAI.log("- 1000 to predict Wide Guard")
      end
    end
  end
  next score
end


#=============================================================================#
#                                                                             #
# Move-specific                                                               #
#                                                                             #
#=============================================================================#


# Facade
PBAI::ScoreHandler.add("07E") do |score, ai, user, target, move|
  if user.burned? || user.poisoned? || user.paralyzed? || user.frozen?
    score += 50
    PBAI.log("+ 50 for doing more damage with a status condition")
  end
  next score
end


# Aromatherapy, Heal Bell
PBAI::ScoreHandler.add("019") do |score, ai, user, target, move|
  count = 0
  user.side.battlers.each do |proj|
    next if proj.nil?
    # + 80 for each active battler with a status condition
    count += 2.0 if proj.has_non_volatile_status?
  end
  user.side.party.each do |proj|
    next if proj.battler # Skip battlers
    # Inactive party members do not have a battler attached,
    # so we can't use has_non_volatile_status?
    count += 1.0 if proj.pokemon.status > 0
    # + 40 for each inactive pokemon with a status condition in the party
  end
  if count != 0
    add = count * 40.0
    score += add
    PBAI.log("+ #{add} for curing status condition(s)")
  else
    score -= 30
    PBAI.log("- 30 for not curing any status conditions")
  end
  next score
end


# Psycho Shift
PBAI::ScoreHandler.add("01B") do |score, ai, user, target, move|
  if user.has_non_volatile_status?
    # And the target doesn't have any status conditions
    if !target.has_non_volatile_status?
      # Then we can transfer our status condition
      transferrable = true
      transferrable = false if user.burned? && !target.can_burn?(user, move)
      transferrable = false if user.poisoned? && !target.can_poison?(user, move)
      transferrable = false if user.paralyzed? && !target.can_paralyze?(user, move)
      transferrable = false if user.asleep? && !target.can_sleep?(user, move)
      transferrable = false if user.frozen? && !target.can_freeze?(user, move)
      if transferrable
        score += 120
        PBAI.log("+ 120 for being able to pass on our status condition")
        if user.burned? && target.is_physical_attacker?
          score += 50
          PBAI.log("+ 50 for being able to burn the physical-attacking target")
        end
        if user.frozen? && target.is_special_attacker?
          score += 50
          PBAI.log("+ 50 for being able to frostbite the special-attacking target")
        end
      end
    end
  else
    score -= 30
    PBAI.log("- 30 for not having a transferrable status condition")
  end
  next score
end


# Purify
PBAI::ScoreHandler.add("15B") do |score, ai, user, target, move|
  if target.has_non_volatile_status?
    factor = 1 - user.hp / user.totalhp.to_f
    # At full hp, factor is 0 (thus not encouraging this move)
    # At half hp, factor is 0.5 (thus slightly encouraging this move)
    # At 1 hp, factor is about 1.0 (thus encouraging this move)
    if user.flags[:will_be_healed] && ai.battle.pbSideSize(0) == 2
      score -= 30
      PBAI.log("- 30 for the user will already be healed by something")
    elsif factor != 0
      if user.is_healing_pointless?(0.5)
        score -= 10
        PBAI.log("- 10 for we will take more damage than we can heal if the target repeats their move")
      elsif user.is_healing_necessary?(0.5)
        add = (factor * 250).round
        score += add
        PBAI.log("+ #{add} for we will likely die without healing")
      else
        add = (factor * 125).round
        score += add
        PBAI.log("+ #{add} for we have lost some hp")
      end
    end
  else
    score -= 30
    PBAI.log("- 30 for the move will fail since the target has no status condition")
  end
  next score
end


# Refresh
PBAI::ScoreHandler.add("018") do |score, ai, user, target, move|
  if user.burned? || user.poisoned? || user.paralyzed?
    score += 70
    PBAI.log("+ 70 for being able to cure our status condition")
  end
  next score
end

# Glare/Thunder Wave
PBAI::ScoreHandler.add("007") do |score, ai, user, target, move|
  if move.statusMove? && !user.target_is_immune?(move,target) && !target.types.include?(:ELECTRIC) && !target.hasActiveAbility?([:LIMBER,:COMATOSE,:GOODASGOLD,:PURIFYINGSALT]) && user.has_role?(:SPEEDCONTROL)
    score += 100
    PBAI.log("+ 100 for being able to paralyze and having the Speed Control role")
  end
  if target.paralyzed?
    score -= 1000
    PBAI.log("- 1000 because the target is already paralyzed")
  end
  next score
end


# Rest
PBAI::ScoreHandler.add("0D9") do |score, ai, user, target, move|
  factor = 1 - user.hp / user.totalhp.to_f
  if user.flags[:will_be_healed] && ai.battle.pbSideSize(0) == 2
    score -= 30
    PBAI.log("- 30 for the user will already be healed by something")
  elsif factor != 0
    # Not at full hp
    if user.can_sleep?(user, move, true)
      add = (factor * 100).round
      score += add
      PBAI.log("+ #{add} for we have lost some hp")
    else
      score -= 10
      PBAI.log("- 10 for the move will fail")
    end
  end
  next score
end


# Smelling Salts
PBAI::ScoreHandler.add("07C") do |score, ai, user, target, move|
  if target.paralyzed?
    score += 50
    PBAI.log("+ 50 for doing double damage")
  end
  next score
end


# Wake-Up Slap
PBAI::ScoreHandler.add("07D") do |score, ai, user, target, move|
  if target.asleep?
    score += 50
    PBAI.log("+ 50 for doing double damage")
  end
  next score
end


# Fire Fang, Flare Blitz
PBAI::ScoreHandler.add("00B", "0FE") do |score, ai, user, target, move|
  if !target.burned? && target.can_burn?(user, move)
    if target.is_physical_attacker?
      score += 40
      PBAI.log("+ 40 for being able to burn the physical-attacking target")
    else
      score += 10
      PBAI.log("+ 10 for being able to burn the target")
    end
  end
  next score
end


# Ice Fang
PBAI::ScoreHandler.add("00E") do |score, ai, user, target, move|
  if !target.frozen? && target.can_freeze?(user, move)
    if target.is_special_attacker?
      score += 40
      PBAI.log("+ 40 for being able to frostbite the special-attacking target")
    else
      score += 10
      PBAI.log("+ 10 for being able to frostbite the target")
    end
  end
  next score
end


# Thunder Fang
PBAI::ScoreHandler.add("009") do |score, ai, user, target, move|
  if !target.paralyzed? && target.can_paralyze?(user, move)
    score += 10
    PBAI.log("+ 10 for being able to paralyze the target")
  end
  next score
end


# Ice Burn
PBAI::ScoreHandler.add("0C6") do |score, ai, user, target, move|
  if !target.burned? && target.can_burn?(user, move)
    if target.is_physical_attacker?
      score += 80
      PBAI.log("+ 80 for being able to burn the physical-attacking target")
    else
      score += 30
      PBAI.log("+ 30 for being able to burn the target")
    end
  end
  next score
end


# Secret Power
PBAI::ScoreHandler.add("0A4") do |score, ai, user, target, move|
  score += 40
  PBAI.log("+ 40 for its potential side effects")
  next score
end

# Wide Guard
PBAI::ScoreHandler.add("0AC") do |score, ai, user, target, move|
  wide = 0
  if ai.battle.doublebattle
    target_moves = target.moves
    if target_moves != nil
      for i in target_moves
        wide += 40 if [:AllNearFoes,:AllNearOthers,:AllBattlers,:BothSides].include?(i.pbTarget(user)) && i.damagingMove?
      end
    end
    if wide > 0
      score += wide
      PBAI.log("+ #{wide} for dodging spread moves")
      if user.has_role?(:SUPPORT)
        score += 40
        PBAI.log("+ 40 for being a Support role.")
      end
    end
  end
  next score
end

# Power Trick
PBAI::ScoreHandler.add("057") do |score, ai, user, target, move|
  if user.turnCount == 0
    score += 400
    PBAI.log("+ 400 for setting up Power Trick")
  else
    score -= 1000
    PBAI.log("- 1000 for not reversing Power Trick")
  end
  next score
end

# Tri Attack
PBAI::ScoreHandler.add("017") do |score, ai, user, target, move|
  if !target.has_non_volatile_status?
    score += 50
    PBAI.log("+ 50 for being able to cause a status condition")
  end
  next score
end


# Freeze Shock, Bounce
PBAI::ScoreHandler.add("0C5", "0CC") do |score, ai, user, target, move|
  if !target.paralyzed? && target.can_paralyze?(user, move)
    score += 30
    PBAI.log("+ 30 for being able to paralyze the target")
  end
  next score
end


# Volt Tackle
PBAI::ScoreHandler.add("0FD") do |score, ai, user, target, move|
  if !target.paralyzed? && target.can_paralyze?(user, move)
    score += 10
    PBAI.log("+ 10 for being able to paralyze the target")
  end
  next score
end


# Toxic Thread
PBAI::ScoreHandler.add("159") do |score, ai, user, target, move|
  if !target.poisoned? && target.can_poison?(user, move)
    score += 50
    PBAI.log("+ 50 for being able to poison the target")
  end
  if target.battler.pbCanLowerStatStage?(:SPEED, user, move) &&
     target.faster_than?(user)
    score += 30
    PBAI.log("+ 30 for being able to lower target speed")
  end
  if target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD])
    score -= 1000
    PBAI.log("- 1000 because Toxic Thread will fail")
  end
  next score
end


# Dark Void
PBAI::ScoreHandler.add("003") do |score, ai, user, target, move|
  if move.name == "Dark Void"
    if user.is_species?(:DARKRAI)
      if !target.asleep? && target.can_sleep?(user, move)
        score += 120
        PBAI.log("+ 120 for damaging the target with Nightmare if it is asleep")
      end
    else
      score -= 100
      PBAI.log("- 100 for this move will fail")
    end
  end
  next score
end


# Yawn
PBAI::ScoreHandler.add("004") do |score, ai, user, target, move|
  if !target.has_non_volatile_status? && target.effects[PBEffects::Yawn] == 0
    score += 60
    PBAI.log("+ 60 for putting the target to sleep")
  end
  sleep = false
  if $game_switches[899]
    for i in ai.battle.pbParty(0)
      sleep = true if i.status == :SLEEP
    end
  end
  if sleep == true
    score = 0
    PBAI.log("*0 because Sleep Clause is in effect")
  else
    if target.set_up_score > 0
      score += 100
      PBAI.log("+ 100 for sleeping a setup mon")
    end
  end
  if target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD])
    score -= 1000
    PBAI.log("- 1000 because Yawn will fail")
  end
  next score
end

# Rage
PBAI::ScoreHandler.add("093") do |score, ai, user, target, move|
  dmg = user.get_move_damage(target, move)
  perc = dmg / target.totalhp.to_f
  perc /= 1.5 if user.discourage_making_contact_with?(target)
  score += perc * 150
  next score
end


# Uproar, Thrash, Petal Dance, Outrage, Ice Ball, Rollout
PBAI::ScoreHandler.add("0D1", "0D2", "0D3") do |score, ai, user, target, move|
  dmg = user.get_move_damage(target, move)
  perc = dmg / target.totalhp.to_f
  perc /= 1.5 if user.discourage_making_contact_with?(target) && move.pbContactMove?(user)
  if perc != 0
    add = perc * 80
    score += add
    PBAI.log("+ #{add} for dealing about #{(perc * 100).round} percent dmg")
  end
  next score
end


# Stealth Rock, Spikes, Toxic Spikes, Sticky Web, Comet Shards
PBAI::ScoreHandler.add("103", "104", "105", "153", "500") do |score, ai, user, target, move|
  if move.function == "103" && user.opposing_side.effects[PBEffects::Spikes] >= 3 ||
     move.function == "104" && user.opposing_side.effects[PBEffects::ToxicSpikes] >= 2 ||
     move.function == "105" && user.opposing_side.effects[PBEffects::StealthRock] ||
     move.function == "153" && user.opposing_side.effects[PBEffects::StickyWeb] ||
     move.function == "500" && user.opposing_side.effects[PBEffects::CometShards]
    score = 0
    PBAI.log("* 0 for the opposing side already has max #{move.name}")
  else
    fnt = 0
    user.side.party.each do |pkmn|
      fnt +=1 if pkmn.fainted?
    end
    inactive = user.opposing_side.party.size - fnt
    add = inactive * 30
    add *= (3 - user.opposing_side.effects[PBEffects::Spikes]) / 3.0 if move.function == "103"
    add *= 0.5 if user.opposing_side.effects[PBEffects::ToxicSpikes] == 1 && move.function == "104"
    score += add
    PBAI.log("+ #{add} for there are #{inactive} pokemon to be sent out at some point")
    if user.has_role?(:LEAD)
      score += 200
      PBAI.log("+ 200 ")
    end
    if user.has_role?(:SPEEDCONTROL) && move.function == "153" && !user.opposing_side.effects[PBEffects::StickyWeb]
      score += 50
      PBAI.log("+ 50  role")
    end
    if ai.battle.field.weather == :Windy
      score -= 1000
      PBAI.log("- 1000 because Windy weather prevents hazards")
    end
    if target.hasActiveAbility?(:MAGICBOUNCE)
      score -= 1000
      PBAI.log("- 1000 because hazards will be set on our side")
    end
    for i in target.moves
      if ["035","02A","032","10D","02B","02C","14E","032","024","026","518"].include?(i.function) && !user.hasActiveAbility?(:UNAWARE)
        setup = true
      end
    end
    if setup == true
      score -= 1000
      PBAI.log("- 1000 to counter setup leads vs hazard leads")
    end
    if !target.can_switch? || !user.can_switch?
      score -= 1000
      PBAI.log("- 1000 hazards are useless, best to attack")
    end
  end
  next score
end


# Disable
PBAI::ScoreHandler.add("0B9") do |score, ai, user, target, move|
  # Already disabled one of the target's moves
  if target.effects[PBEffects::Disable] > 1
    score -= 30
    PBAI.log("- 30 for the target is already disabled")
  elsif target.flags[:will_be_disabled] == true && ai.battle.pbSideSize(0) == 2
    score -= 30
    PBAI.log("- 30 for the target is being disabled by another battler")
  else
    # Get previous damage done by the target
    prevDmg = target.get_damage_by_user(user)
    if prevDmg.size > 0 && prevDmg != 0
      lastDmg = prevDmg[-1]
      # If the last move did more than 50% damage and the target was faster,
      # we can't disable the move in time thus using Disable is pointless.
      if user.is_healing_pointless?(0.5) && target.faster_than?(user)
        score -= 30
        PBAI.log("- 30 for the target move is too strong and the target is faster")
      else
        add = (lastDmg[3] * 150).round
        score += add
        PBAI.log("+ #{add} for we disable a strong move")
      end
    else
      # Target hasn't used a damaging move yet
      score -= 30
      PBAI.log("- 30 for the target hasn't used a damaging move yet.")
    end
  end
  if target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD])
    score -= 1000
    PBAI.log("- 1000 because Disable will fail")
  end
  next score
end


# Counter
PBAI::ScoreHandler.add("071") do |score, ai, user, target, move|
  expect = false
  expect = true if target.is_physical_attacker? && !target.is_healing_necessary?(0.5)
  prevDmg = user.get_damage_by_user(target)
  if prevDmg.size > 0 && prevDmg != 0
    lastDmg = prevDmg[-1]
    lastMove = PokeBattle_Move.from_pokemon_move(ai.battle,Pokemon::Move.new(lastDmg[1]))
    expect = true if lastMove.physicalMove?
  end
  # If we can reasonably expect the target to use a physical move
  if expect
    score += 60
    PBAI.log("+ 60 for we can reasonably expect the target to use a physical move")
  end
  next score
end

# Mirror Coat
PBAI::ScoreHandler.add("072") do |score, ai, user, target, move|
  expect = false
  expect = true if target.is_special_attacker? && !target.is_healing_necessary?(0.5)
  prevDmg = user.get_damage_by_user(target)
  if prevDmg.size > 0 && prevDmg != 0
    lastDmg = prevDmg[-1]
    lastMove = PokeBattle_Move.from_pokemon_move(ai.battle,Pokemon::Move.new(lastDmg[1]))
    expect = true if lastMove.specialMove?
  end
  # If we can reasonably expect the target to use a special move
  if expect
    score += 60
    PBAI.log("+ 60 for we can reasonably expect the target to use a special move")
  end
  next score
end

# Leech Seed
PBAI::ScoreHandler.add("0DC") do |score, ai, user, target, move|
  roles = []
    for i in user.roles
      roles.push(i)
    end
  if !user.underdog?(target) && !target.has_type?(:GRASS) && target.effects[PBEffects::LeechSeed] == 0
    score += 60
    PBAI.log("+ 60 for sapping hp from the target")
    score += 30 if user.has_role?([:PHYSICALWALL,:SPECIALWALL,:DEFENSIVEPIVOT,:OFFENSIVEPIVOT])#.include?(roles)
    PBAI.log("+ 30 ") if user.has_role?([:PHYSICALWALL,:SPECIALWALL,:DEFENSIVEPIVOT,:OFFENSIVEPIVOT])#.include?(roles)
  end
  if target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD])
    score -= 1000
    PBAI.log("- 1000 because Leech Seed will fail")
  end
  next score
end


# Leech Life, Parabolic Charge, Drain Punch, Giga Drain, Horn Leech, Mega Drain, Absorb
PBAI::ScoreHandler.add("0DD") do |score, ai, user, target, move|
  dmg = user.get_move_damage(target, move)
  add = dmg / 2
  score += add
  PBAI.log("+ #{add} for hp gained")
  if user.hasActiveAbility?(:VAMPIRIC)
    score += 50
    PBAI.log("+ 50 for having a beneficial ability")
  end
  next score
end


# Dream Eater
PBAI::ScoreHandler.add("0DE") do |score, ai, user, target, move|
  if target.asleep?
    dmg = user.get_move_damage(target, move)
    add = dmg / 2
    score += add
    PBAI.log("+ #{add} for hp gained")
  else
    score -= 30
    PBAI.log("- 30 for the move will fail")
  end
  next score
end


# Heal Pulse
PBAI::ScoreHandler.add("0DF") do |score, ai, user, target, move|
  # If the target is an ally
  ally = false
  target.battler.eachAlly do |battler|
    ally = true if battler == user.battler
  end
  if ally# && !target.will_already_be_healed?
    factor = 1 - target.hp / target.totalhp.to_f
    # At full hp, factor is 0 (thus not encouraging this move)
    # At half hp, factor is 0.5 (thus slightly encouraging this move)
    # At 1 hp, factor is about 1.0 (thus encouraging this move)
    if target.will_already_be_healed?
      score -= 30
      PBAI.log("- 30 for the target will already be healed by something")
    elsif factor != 0
      if target.is_healing_pointless?(0.5)
        score -= 10
        PBAI.log("- 10 for the target will take more damage than we can heal if the opponent repeats their move")
      elsif target.is_healing_necessary?(0.5)
        add = (factor * 250).round
        score += add
        PBAI.log("+ #{add} for the target will likely die without healing")
      else
        add = (factor * 125).round
        score += add
        PBAI.log("+ #{add} for the target has lost some hp")
      end
    else
      score -= 30
      PBAI.log("- 30 for the target is at full hp")
    end
  else
    score -= 30
    PBAI.log("- 30 for the target is not an ally")
  end
  next score
end


# Whirlwind, Roar, Circle Throw, Dragon Tail, U-Turn, Volt Switch
PBAI::ScoreHandler.add("0EB", "0EC", "0EE", "151", "529") do |score, ai, user, target, move|
  if user.bad_against?(target) && user.level >= target.level &&
     !target.has_ability?(:SUCTIONCUPS) && !target.effects[PBEffects::Ingrain] && !["0EE","151","529"].include?(move.function)
    score += 100
    PBAI.log("+ 100 for forcing our target to switch and we're bad against our target")
    o_boost = 0
    faint = 0
    GameData::Stat.each_battle { |s| o_boost += target.stages[s] if target.stages[s] != nil}
    target.side.party.each do |pkmn|
      faint +=1 if pkmn.fainted?
    end
    if o_boost > 0 && faint > 1
      score += 300
      PBAI.log("+ 300 for forcing out a set up mon")
    end
    if user.has_role?(:PHAZER)
      score += 200
      PBAI.log("+ 200 for being a Phazer")
    end
  elsif ["0EE","151","529"].include?(move.function)
    roles = []
    for i in user.roles
      roles.push(i)
    end
    if user.has_role?([:DEFENSIVEPIVOT,:OFFENSIVEPIVOT,:LEAD]) && user.can_switch?
      score += 60 
      PBAI.log("+ 60 ")
    end
    boosts = 0
    o_boost = 0
    GameData::Stat.each_battle { |s| boosts += user.stages[s] if user.stages[s] != nil}
    boosts *= -50
    score += boosts
    GameData::Stat.each_battle { |s| o_boost += target.stages[s] if target.stages[s] != nil}
    if boosts > 0
      PBAI.log("+ #{boosts} for switching to reset lowered stats")
    elsif boosts < 0
      PBAI.log("#{boosts} for not wasting boosted stats")
    end
    if o_boost > 0  
      score += 200
      PBAI.log("+ 200 to switch on setup")
    end
    if user.trapped? && user.can_switch?
      score += 100
      PBAI.log("+ 100 for escaping a trap")
    end
    if target.faster_than?(user) && !user.bad_against?(target)
      score += 20
      PBAI.log("+ 20 for making a more favorable matchup")
    end
    if user.bad_against?(target) && target.faster_than?(user)
      score += 40
      PBAI.log("+ 40 for gaining switch initiative against a bad matchup")
    end
    if user.bad_against?(target) && user.faster_than?(target)
      score += 100
      PBAI.log("+ 100 for switching against a bad matchup")
    end
    if user.effects[PBEffects::Substitute] > 0 && move.function == "538"
      score - 1000
      PBAI.log("- 1000 because we already have a Substitute")
    end
    kill = 0
    for i in user.moves
      kill += 1 if user.get_move_damage(target,i) >= target.hp
    end
    fnt = 0
    user.side.party.each do |pkmn|
      fnt +=1 if pkmn.fainted?
    end
    diff = user.side.party.length - fnt
    if user.predict_switch?(target) && kill == 0 && diff > 1 && !$spam_block_triggered
      score += 100
      PBAI.log("+ 100 for predicting the target to switch, being unable to kill, and having something to switch to")
    end
    if diff == 1
      score -= 100
      PBAI.log("- 100 to prefer stronger offensive moves if all other party members are fainted")
    end
  end
  if target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD]) && move.statusMove?
    score -= 1000
    PBAI.log("- 1000 because move will fail")
  end
  next score
end

# Shed Tail
PBAI::ScoreHandler.add("538") do |score, ai, user, target, move|
  roles = []
    for i in user.roles
      roles.push(i)
    end
    if user.has_role?([:DEFENSIVEPIVOT,:OFFENSIVEPIVOT,:LEAD])#.include?(roles)
      score += 40
      PBAI.log("+ 40 ")
    end
    if user.trapped? && user.can_switch?
      score += 100
      PBAI.log("+ 100 for escaping a trap")
    end
    if target.faster_than?(user) && !user.bad_against?(target)
      score += 20
      PBAI.log("+ 20 for making a more favorable matchup")
    end
    if user.bad_against?(target) && target.faster_than?(user)
      score += 40
      PBAI.log("+ 40 for gaining switch initiative against a bad matchup")
    end
    if user.bad_against?(target) && user.faster_than?(target)
      score += 40
      PBAI.log("+ 40 for switching against a bad matchup")
    end
    if user.effects[PBEffects::Substitute] > 0 || user.hp < user.totalhp/2
      score - 1000
      PBAI.log("- 1000 because we cannot make a Substitute")
    end
    if !user.can_switch?
      score -= 1000
      PBAI.log("- 1000 because we cannot pass a Substitute")
    end
    kill = 0
    for i in user.moves
      kill += 1 if user.get_move_damage(target,i) >= target.hp
    end
    fnt = 0
    user.side.party.each do |pkmn|
      fnt +=1 if pkmn.fainted?
    end
    diff = user.side.party.length - fnt
    if user.predict_switch?(target) && kill == 0 && diff > 1
      score += 100
      PBAI.log("+ 100 for predicting the target to switch, being unable to kill, and having something to switch to")
    end
    boosts = 0
    GameData::Stat.each_battle { |s| boosts += user.stages[s] if user.stages[s] != nil}
    boosts *= -10
    score += boosts
    if boosts > 0
      PBAI.log("+ #{boosts} for switching to reset lowered stats")
    elsif boosts < 0
      PBAI.log("#{boosts} for not wasting boosted stats")
    end
  next score
end


# Anchor Shot, Block, Mean Look, Spider Web, Spirit Shackle, Thousand Waves
PBAI::ScoreHandler.add("0EF") do |score, ai, user, target, move|
  if target.bad_against?(user) && !target.has_type?(:GHOST)
    score += 100
    PBAI.log("+ 100 for locking our target in battle with us and they're bad against us")
  end
  next score
end

# Recover, Slack Off, Soft-Boiled, Heal Order, Milk Drink, Roost, Wish
PBAI::ScoreHandler.add("0D5", "0D6", "0D7") do |score, ai, user, target, move|
  factor = 1 - user.hp / user.totalhp.to_f
  # At full hp, factor is 0 (thus not encouraging this move)
  # At half hp, factor is 0.5 (thus slightly encouraging this move)
  # At 1 hp, factor is about 1.0 (thus encouraging this move)
  roles = []
    for i in user.roles
      roles.push(i)
    end
  if user.flags[:will_be_healed] && ai.battle.pbSideSize(0) == 2
    score = 0
    PBAI.log("* 0 for the user will already be healed by something")
  elsif factor != 0
    if user.is_healing_pointless?(0.50)
      score -= 10
      PBAI.log("- 10 for we will take more damage than we can heal if the target repeats their move")
    elsif user.is_healing_necessary?(0.65)
      add = (factor * 175).round
      score += add
      PBAI.log("+ #{add} for we will likely die without healing")
      if user.has_role?([:PHYSICALWALL,:SPECIALWALL,:TOXICSTALLER,:DEFENSIVEPIVOT,:OFFENSIVEPIVOT,:CLERIC])#.include?(roles)
        score += 40
        PBAI.log("+ 40 ")
      end
    else
      add = (factor * 100).round
      score += add
      PBAI.log("+ #{add} for we have lost some hp")
      if user.has_role?([:PHYSICALWALL,:SPECIALWALL,:TOXICSTALLER,:DEFENSIVEPIVOT,:OFFENSIVEPIVOT,:CLERIC])#.include?(roles)
        score += 40
        PBAI.log("+ 40 ")
      end
    end
  else
    score -= 30
    PBAI.log("- 30 for we are at full hp")
  end
  score += 40 if user.has_role?(:CLERIC) && move.function == "0D7"
  PBAI.log("+ 40  and potentially passing a Wish") if user.has_role?(:CLERIC) && move.function == "0D7"
  score += 50 if user.predict_switch?(target)
  PBAI.log("+ 50 for predicting the switch") if user.predict_switch?(target)
  score += 60 if user.flags[:should_heal] == true
  PBAI.log("+ 60 because there are no better moves") if user.flags[:should_heal] == true
  if move.function == "0D7" && ai.battle.positions[user.index].effects[PBEffects::Wish] > 0
    score = 0
    PBAI.log("* 0 because Wish this turn will fail")
  end
  next score
end


# Moonlight, Morning Sun, Synthesis
PBAI::ScoreHandler.add("0D8") do |score, ai, user, target, move|
  heal_factor = 0.5
  case ai.battle.pbWeather
  when :Sun, :HarshSun
    if move.type != :FAIRY
      heal_factor = 2.0 / 3.0
    else
      heal_factor = 0.25
    end
  when :Starstorm, :Eclipse
    if move.type == :FAIRY
      heal_factor = 2.0 / 3.0
    else
      heal_factor = 0.25
    end
  when :None, :StrongWinds
    heal_factor = 0.5
  else
    heal_factor = 0.25
  end
  effi_factor = 1.0
  effi_factor = 0.5 if heal_factor == 0.25
  factor = 1 - user.hp / user.totalhp.to_f
  # At full hp, factor is 0 (thus not encouraging this move)
  # At half hp, factor is 0.5 (thus slightly encouraging this move)
  # At 1 hp, factor is about 1.0 (thus encouraging this move)
  if user.flags[:will_be_healed] && ai.battle.pbSideSize(0) == 2
    score -= 30
    PBAI.log("- 30 for the user will already be healed by something")
  elsif factor != 0
    if user.is_healing_pointless?(heal_factor)
      score -= 10
      PBAI.log("- 10 for we will take more damage than we can heal if the target repeats their move")
    elsif user.is_healing_necessary?(heal_factor)
      add = (factor * 175 * effi_factor).round
      score += add
      PBAI.log("+ #{add} for we will likely die without healing")
    else
      add = (factor * 100 * effi_factor).round
      score += add
      PBAI.log("+ #{add} for we have lost some hp")
    end
  else
    score -= 30
    PBAI.log("- 30 for we are at full hp")
  end
  next score
end

# Shore Up
PBAI::ScoreHandler.add("16D") do |score, ai, user, target, move|
  heal_factor = 0.5
  if ai.battle.pbWeather == :Sandstorm
    heal_factor = 2.0 / 3.0
  end
  factor = 1 - user.hp / user.totalhp.to_f
  # At full hp, factor is 0 (thus not encouraging this move)
  # At half hp, factor is 0.5 (thus slightly encouraging this move)
  # At 1 hp, factor is about 1.0 (thus encouraging this move)
  if user.flags[:will_be_healed] && ai.battle.pbSideSize(0) == 2
    score -= 30
    PBAI.log("- 30 for the user will already be healed by something")
  elsif factor != 0
    if user.is_healing_pointless?(heal_factor)
      score -= 10
      PBAI.log("- 10 for we will take more damage than we can heal if the target repeats their move")
    elsif user.is_healing_necessary?(0.65)
      add = (factor * 200).round
      score += add
      PBAI.log("+ #{add} for we will likely die without healing")
    else
      add = (factor * 100).round
      score += add
      PBAI.log("+ #{add} for we have lost some hp")
    end
    score += 30 if ai.battle.pbWeather == :Sandstorm
    PBAI.log("+ 30 for extra healing in Sandstorm")
  else
    score -= 30
    PBAI.log("- 30 for we are at full hp")
  end
  next score
end

# Reflect
PBAI::ScoreHandler.add("0A2") do |score, ai, user, target, move|
  if user.side.effects[PBEffects::Reflect] > 0
    score -= 30
    PBAI.log("- 30 for reflect is already active")
  elsif user.side.flags[:will_reflect] && ai.battle.pbSideSize(0) == 2
    score -= 30
    PBAI.log("- 30 for another battler will already use reflect")
  else
    fnt = target.side.party.size
    physenemies = 0
    target.side.party.each do |pkmn|
      next if pkmn.battler == nil
      fnt -=1 if pkmn.fainted?
      physenemies += 1 if pkmn.is_physical_attacker?
    end
    add = fnt * 20 + physenemies * 30
    score += add
    PBAI.log("+ #{add} based on enemy and physical enemy count")
    if user.has_role?(:SCREENS)
      score += 40
      PBAI.log("+ 40")
    end
  end
  next score
end


# Light Screen
PBAI::ScoreHandler.add("0A3") do |score, ai, user, target, move|
  if user.side.effects[PBEffects::LightScreen] > 0
    score -= 30
    PBAI.log("- 30 for light screen is already active")
  elsif user.side.flags[:will_lightscreen] && ai.battle.pbSideSize(0) == 2
    score -= 30
    PBAI.log("- 30 for another battler will already use light screen")
  else
    fnt = target.side.party.size
    specenemies = 0
    target.side.party.each do |pkmn|
      next if pkmn.battler == nil
      fnt -=1 if pkmn.fainted?
      specenemies += 1 if pkmn.is_special_attacker?
    end
    add = fnt * 20 + specenemies * 30
    score += add
    PBAI.log("+ #{add} based on enemy and special enemy count")
    if user.has_role?(:SCREENS)
      score += 40
      PBAI.log("+ 40")
    end
  end
  next score
end

# Aurora Veil
PBAI::ScoreHandler.add("167") do |score, ai, user, target, move|
  if user.side.effects[PBEffects::AuroraVeil] > 0
    score -= 30
    PBAI.log("- 30 for Aurora Veil is already active")
  elsif user.side.flags[:will_auroraveil] && ai.battle.pbSideSize(0) == 2
    score -= 30
    PBAI.log("- 30 for another battler will already use Aurora Veil")
  elsif ![:Hail,:Sleet].include?(ai.battle.pbWeather)
    score -= 30
    PBAI.log("- 30 for Aurora Veil will fail without Hail or Sleet active")
  else
    fnt = target.side.party.size
    target.side.party.each do |pkmn|
      fnt -=1 if pkmn.fainted?
    end
    add = fnt * 30
    score += add
    PBAI.log("+ #{add} based on enemy count")
    if user.has_role?(:SCREENS)
      score += 40
      PBAI.log("+ 40")
    end
  end
  next score
end

#Taunt
PBAI::ScoreHandler.add("0BA") do |score, ai, user, target, move|
  if target.flags[:will_be_taunted] && ai.battle.pbSideSize(0) == 2
    score -= 30
    PBAI.log("- 30 for another battler will already use Taunt on this target")
  elsif target.effects[PBEffects::Taunt]>0
    score -= 30
    PBAI.log("- 30 for the target is already Taunted")
  else
    weight = 0
    target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
    target_moves.each do |proj|
      weight += 25 if proj.statusMove?
    end
    score += weight
    PBAI.log("+ #{weight} to Taunt potential stall or setup")
    if user.has_role?(:STALLBREAKER) && weight > 50
      score += 30
      PBAI.log("+ 30 ")
    end
    if $game_switches[LvlCap::Expert]
      for i in target.moves
        if ["035","02A","032","10D","02B","02C","14E","032","024","026","518"].include?(i.function)
          setup = true
        end
      end
      if setup == true
        score += 100
        PBAI.log("+ 100 to counter setup")
      end
    end
    if $learned_flags[:should_taunt].include?(target) || $spam_block_flags[:no_attacking_flag] == target
      score += 150
      PBAI.log("+ 150 for stallbreaking")
    end
    if $spam_block_triggered && $spam_block_flags[:choice].is_a?(PokeBattle_Move) && ["035","02A","032","10D","02B","02C","14E","032","024","026","518"].include?($spam_block_flags[:choice].function)
      buff = user.faster_than?(target) ? 300 : 150
      score += buff
      PBAI.log("+ #{buff} to prevent setup")
    end
  end
  if target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD])
    score -= 1000
    PBAI.log("- 1000 because Taunt will fail")
  end
  next score
end

# Haze
PBAI::ScoreHandler.add("051") do |score, ai, user, target, move|
  roles = []
    for i in user.roles
      roles.push(i)
    end
  if user.side.flags[:will_haze] && ai.battle.pbSideSize(0) == 2
    score -= 30
    PBAI.log("- 30 for another battler will already use haze")
  else
    net = 0
    # User buffs: net goes up
    # User debuffs: net goes down
    # Target buffs: net goes down
    # Target debuffs: net goes up
    # The lower net is, the better Haze is to choose.
    user.side.battlers.each do |proj|
      GameData::Stat.each_battle { |s| net -= proj.stages[s] if proj.stages[s] != nil }
    end
    target.side.battlers.each do |proj|
      GameData::Stat.each_battle { |s| net += proj.stages[s] if proj.stages[s] != nil }
    end
    # As long as the target's stat stages are more advantageous than ours (i.e. net < 0), Haze is a good choice
    if net < 0
      add = -net * 20
      score += add
      PBAI.log("+ #{add} to reset disadvantageous stat stages")
      if user.has_role?([:STALLBREAKER,:PHAZER])##.include?(roles)
        score += 30
        PBAI.log("+ 30 ")
      end
      score += 50 if target.include?($learned_flags[:has_setup])
      PBAI.log("+ 50 for preventing the target from setting up")
    else
      score -= 30
      PBAI.log("- 30 for our stat stages are advantageous")
    end
  end
  next score
end


# Bide
PBAI::ScoreHandler.add("0D4") do |score, ai, user, target, move|
  # If we've been hit at least once, use Bide if we could take two hits of the last attack and survive
  prevDmg = target.get_damage_by_user(user)
  if prevDmg.size > 0 && prevDmg != 0
    lastDmg = prevDmg[-1]
    predDmg = lastDmg[2] * 2
    # We would live if we took two hits of the last move
    if user.hp - predDmg > 0
      score += 120
      PBAI.log("+ 120 for we can survive two subsequent attacks")
    else
      score -= 10
      PBAI.log("- 10 for we would not survive two subsequent attacks")
    end
  else
    score -= 10
    PBAI.log("- 10 for we don't know whether we'd survive two subsequent attacks")
  end
  next score
end

# Shell Smash
PBAI::ScoreHandler.add("035") do |score, ai, user, target, move|
  count = 0
  t_count = 0
  if user.setup?
    if user.statStageAtMax?(:ATTACK) || user.statStageAtMax?(:SPECIAL_ATTACK)
      score = 0
      PBAI.log("* 0 for battler being max on Attack or Defense")
    else
      count = 0
      user.moves.each do |m|
        count += 1 if user.get_move_damage(target, m) > target.hp/2
      end
      t_count = 0
      $thief = 0
      if $game_switches[LvlCap::Expert] == true
        target.moves.each do |tmove|
          t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
          $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
        end
      else
        if target.used_moves != nil
          target.used_moves.each do |tmove|
            t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
            $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
          end
        end
      end
      add = user.turnCount == 0 ? 100 : 70
      score += add
      PBAI.log("+ #{add}")
      end
      if count == 0 && t_count == 0
        add = user.turnCount == 0 ? 80 : 60
        score += add
        PBAI.log("+ #{add} to boost to guarantee the kill")
        atk_boost = user.stages[:ATTACK]*20
        spa_boost = user.stages[:SPECIAL_ATTACK]*20
        spe_boost = user.stages[:SPEED]*20
        diff = atk_boost + spa_boost + spe_boost
        score -= diff
        PBAI.log("- #{diff} for boosted stats") if diff > 0
        PBAI.log("+ #{diff} for lowered stats") if diff < 0
        score += 20 if user.predict_switch?(target)
        PBAI.log("+ 20 for predicting the switch") if user.predict_switch?(target)
        score += 50 if $learned_flags[:setup_fodder].include?(target)
        PBAI.log("+ 50 for using the target as setup fodder") if $learned_flags[:setup_fodder].include?(target)
      elsif count > 0
        score -= 100
        PBAI.log("- 100 since the target can now be killed by an attack")
      end
      if t_count > 0 && !user.can_switch?
        score -= 1000
        PBAI.log("- 1000 because setup is pointless.")
      end
if $thief > 0
      score -= 1000
      PBAI.log("- 1000 to not give a mon free setup")
    end
    end
    if $spam_block_flags[:haze_flag].include?(target)
      score -= 1000
      PBAI.log("- 1000 because target has Haze")
    end
    if $spam_block_triggered && $spam_block_flags[:choice].is_a?(Pokemon) && user.set_up_score == 0
      score += 1000
      PBAI.log("+ 1000 to set up on the switch")
    end
    if user.set_up_score >= 2
      score -= 1000
      PBAI.log("- 1000 to encourage attacking")
    end
    
  next score
end

# Agility, Autotomize
PBAI::ScoreHandler.add("030","031") do |score, ai, user, target, move|
  count = 0
  t_count = 0
  if user.setup?
    if user.statStageAtMax?(:SPEED)
      score = 0
      PBAI.log("* 0 for battler being max on Speed")
    else
      count = 0
      if target.faster_than?(user)  
        add = user.turnCount == 0 ? 100 : 07
        score += add
        PBAI.log("+ #{add}")
        spe_boost = user.stages[:SPEED]*20
        diff = spe_boost
        score -= diff
        PBAI.log("- #{diff} for boosted stats") if diff > 0
        PBAI.log("+ #{diff} for lowered stats") if diff < 0
        score += 20 if user.predict_switch?(target)
        PBAI.log("+ 20 for predicting the switch") if user.predict_switch?(target)
        score += 50 if $learned_flags[:setup_fodder].include?(target)
        PBAI.log("+ 50 for using the target as setup fodder") if $learned_flags[:setup_fodder].include?(target)
      end
      if $spam_block_flags[:haze_flag].include?(target)
        score -= 1000
        PBAI.log("- 1000 because target has Haze")
      end
      if $spam_block_triggered && $spam_block_flags[:choice].is_a?(Pokemon) && user.set_up_score == 0
        score += 1000
        PBAI.log("+ 1000 to set up on the switch")
      end
      if user.set_up_score >= 2
        score -= 1000
        PBAI.log("- 1000 to encourage attacking")
      end
    end
  end
  next score
end

# Swords Dance, Power-up Punch, Static Surge
PBAI::ScoreHandler.add("02E","01C","511","028") do |score, ai, user, target, move|
  count = 0
  if user.setup?
    if user.statStageAtMax?(:ATTACK)
      score = 0
      PBAI.log("* 0 for battler being max Attack")
    else
      count = 0
      user.moves.each do |m|
        count += 1 if user.get_move_damage(target, m) > target.hp/2 && m.physicalMove?
      end
      t_count = 0
      $thief = 0
      if $game_switches[LvlCap::Expert] == true
        target.moves.each do |tmove|
          t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
          $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
        end
      else
        if target.used_moves != nil
          target.used_moves.each do |tmove|
            t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
            $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
          end
        end
      end
      # As long as the target's stat stages are more advantageous than ours (i.e. net < 0), Haze is a good choice
      if count == 0 && t_count == 0
        add = user.turnCount == 0 ? 80 : 50
        score += add
        PBAI.log("+ #{add} to boost to guarantee the kill")
        score += 40
        PBAI.log("+ 40 ")
        atk_boost = user.stages[:ATTACK]*20
        diff = atk_boost
        score -= diff
        PBAI.log("- #{diff} for boosted stats") if diff > 0
        PBAI.log("+ #{diff} for lowered stats") if diff < 0
        score += 20 if user.predict_switch?(target)
        PBAI.log("+ 20 for predicting the switch") if user.predict_switch?(target)
        score += 50 if $learned_flags[:setup_fodder].include?(target)
        PBAI.log("+ 50 for using the target as setup fodder") if $learned_flags[:setup_fodder].include?(target)
      elsif count > 0
        score -= 100
        PBAI.log("- 100 since the target can now be 2HKO'd by an attack")
      end
      if t_count > 0 && !user.can_switch?
        score -= 1000
        PBAI.log("- 1000 because setup is pointless.")
      end
      if $thief > 0
        score -= 1000
        PBAI.log("- 1000 to not give a mon free setup")
      end
    end
  end
  if $spam_block_flags[:haze_flag].include?(target)
      score -= 1000
      PBAI.log("- 1000 because target has Haze")
    end
    if $spam_block_triggered && $spam_block_flags[:choice].is_a?(Pokemon) && user.set_up_score == 0
      score += 1000
      PBAI.log("+ 1000 to set up on the switch")
    end
    if user.set_up_score >= 2
      score -= 1000
      PBAI.log("- 1000 to encourage attacking")
    end
  next score
end

# Bulk Up, Coil, Victory Dance, Dragon Dance
PBAI::ScoreHandler.add("024", "025", "518", "026") do |score, ai, user, target, move|
  count = 0
  if user.setup?
    if user.statStageAtMax?(:ATTACK) && user.statStageAtMax?(:DEFENSE)
      score = 0
      PBAI.log("* 0 for battler being max on Attack or Defense")
    else
      count = 0
      user.moves.each do |m|
        count += 1 if user.get_move_damage(target, m) > target.hp/2 && m.physicalMove?
      end
      t_count = 0
      $thief = 0
      if $game_switches[LvlCap::Expert] == true
        target.moves.each do |tmove|
          t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
          $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
        end
      else
        if target.used_moves != nil
          target.used_moves.each do |tmove|
            t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
            $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
          end
        end
      end
      add = user.turnCount == 0 ? 80 : 50
      score += add
      PBAI.log("+ #{add} ")
      end
      if count == 0 && t_count == 0
        add = user.turnCount == 0 ? 80 : 50
        score += add
        PBAI.log("+ #{add} to boost to guarantee the kill")
        atk_boost = user.stages[:ATTACK]*20
        def_boost = user.stages[:DEFENSE]*20
        diff = atk_boost + def_boost
        score -= diff
        PBAI.log("- #{diff} for boosted stats") if diff > 0
        PBAI.log("+ #{diff} for lowered stats") if diff < 0
        score += 20 if user.predict_switch?(target)
        PBAI.log("+ 20 for predicting the switch") if user.predict_switch?(target)
        score += 50 if $learned_flags[:setup_fodder].include?(target)
        PBAI.log("+ 50 for using the target as setup fodder") if $learned_flags[:setup_fodder].include?(target)
      elsif count == 0 && t_count == 0 && !user.faster_than?(target) && move.function != "024"
        add = user.turnCount == 0 ? 60 : 40
        score += add
        PBAI.log("+ #{add} to boost to guaranteed outspeed and kill")
        atk_boost = user.stages[:ATTACK]*20
        def_boost = user.stages[:DEFENSE]*20
        diff = atk_boost + def_boost
        score -= diff
        PBAI.log("- #{diff} for boosted stats") if diff > 0
        PBAI.log("+ #{diff} for lowered stats") if diff < 0
        score += 20 if user.predict_switch?(target)
        PBAI.log("+ 20 for predicting the switch") if user.predict_switch?(target)
        score += 50 if $learned_flags[:setup_fodder].include?(target)
        PBAI.log("+ 50 for using the target as setup fodder") if $learned_flags[:setup_fodder].include?(target)
      elsif count > 0 && user.faster_than?(target)
        score -= 1000
        PBAI.log("- 1000 since the target can now be outsped and killed")
      elsif count > 0 && t_count == 0
        score -= 500
        PBAI.log("- 500 since the target can now be killed and cannot kill back")
      end
      if t_count > 0 && !user.can_switch?
        score -= 1000
        PBAI.log("- 1000 because setup is pointless.")
      end
      if $thief > 0
        score -= 1000
        PBAI.log("- 1000 to not give a mon free setup")
      end
    end
    if $spam_block_flags[:haze_flag].include?(target)
      score -= 1000
      PBAI.log("- 1000 because target has Haze")
    end
    if $spam_block_triggered && $spam_block_flags[:choice].is_a?(Pokemon) && user.set_up_score == 0
      score += 1000
      PBAI.log("+ 1000 to set up on the switch")
    end
    if user.set_up_score >= 2
      score -= 1000
      PBAI.log("- 1000 to encourage attacking")
    end
    
  next score
end

# Curse
PBAI::ScoreHandler.add("10D") do |score, ai, user, target, move|
  count = 0
  if user.setup? && !user.pbHasType?(:GHOST)
    if user.statStageAtMax?(:ATTACK) && user.statStageAtMax?(:DEFENSE)
      score = 0
      PBAI.log("* 0 for battler being max on Attack or Defense")
    else
      count = 0
      user.moves.each do |m|
        count += 1 if user.get_move_damage(target, m) > target.hp/2 && m.physicalMove?
      end
      t_count = 0
      $thief = 0
      if $game_switches[LvlCap::Expert] == true
        target.moves.each do |tmove|
          t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
          $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
        end
      else
        if target.used_moves != nil
          target.used_moves.each do |tmove|
            t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
            $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
          end
        end
      end
      add = user.turnCount == 0 ? 80 : 50
      score += add
      PBAI.log("+ #{add} ")
      end
      if count == 0 && t_count == 0
        add = user.turnCount == 0 ? 80 : 50
        score += add
        PBAI.log("+ #{add} to boost to guarantee the kill")
        atk_boost = user.stages[:ATTACK]*20
        def_boost = user.stages[:DEFENSE]*20
        diff = atk_boost + def_boost
        score -= diff
        PBAI.log("- #{diff} for boosted stats") if diff > 0
        PBAI.log("+ #{diff} for lowered stats") if diff < 0
        score += 20 if user.predict_switch?(target)
        PBAI.log("+ 20 for predicting the switch") if user.predict_switch?(target)
        score += 50 if $learned_flags[:setup_fodder].include?(target)
        PBAI.log("+ 50 for using the target as setup fodder") if $learned_flags[:setup_fodder].include?(target)
      elsif count > 0
        score -= 100
        PBAI.log("- 100 since the target can now be killed by an attack")
      end
      if t_count > 0 && !user.can_switch?
        score -= 1000
        PBAI.log("- 1000 because setup is pointless.")
      end
      if $thief > 0
        score -= 1000
        PBAI.log("- 1000 to not give a mon free setup")
      end
    end
    if $spam_block_flags[:haze_flag].include?(target)
      score -= 1000
      PBAI.log("- 1000 because target has Haze")
    end
    if $spam_block_triggered && $spam_block_flags[:choice].is_a?(Pokemon) && user.set_up_score == 0
      score += 1000
      PBAI.log("+ 1000 to set up on the switch")
    end
    if user.set_up_score >= 2
      score -= 1000
      PBAI.log("- 1000 to encourage attacking")
    end
    
  next score
end

# Nasty Plot
PBAI::ScoreHandler.add("032") do |score, ai, user, target, move|
  count = 0
  if user.setup?
    if user.statStageAtMax?(:SPECIAL_ATTACK)
      score = 0
      PBAI.log("* 0 for battler being max Special Attack")
    else
      count = 0
      user.moves.each do |m|
        count += 1 if user.get_move_damage(target, m) > target.hp/2 && m.specialMove?
      end
      t_count = 0
      $thief = 0
      if $game_switches[LvlCap::Expert] == true
        target.moves.each do |tmove|
          t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
          $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
        end
      else
        if target.used_moves != nil
          target.used_moves.each do |tmove|
            t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
            $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
          end
        end
      end
      # As long as the target's stat stages are more advantageous than ours (i.e. net < 0), Haze is a good choice
      if count == 0 && t_count == 0
        add = user.turnCount == 0 ? 80 : 50
        score += add
        PBAI.log("+ #{add} to boost to guarantee the kill")
        score += 40
        PBAI.log("+ 40 ")
        atk_boost = user.stages[:SPECIAL_ATTACK]*20
        diff = atk_boost
        score -= diff
        PBAI.log("- #{diff} for boosted stats") if diff > 0
        PBAI.log("+ #{diff} for lowered stats") if diff < 0
        score += 20 if user.predict_switch?(target)
        PBAI.log("+ 20 for predicting the switch") if user.predict_switch?(target)
        score += 50 if $learned_flags[:setup_fodder].include?(target)
        PBAI.log("+ 50 for using the target as setup fodder") if $learned_flags[:setup_fodder].include?(target)
      elsif count > 0
        score -= 100
        PBAI.log("- 100 since the target can now be killed by an attack")
      end
      if t_count > 0 && !user.can_switch?
        score -= 1000
        PBAI.log("- 1000 because setup is pointless.")
      end
      if $thief > 0
        score -= 1000
        PBAI.log("- 1000 to not give a mon free setup")
      end
    end
  end
  if $spam_block_flags[:haze_flag].include?(target)
      score -= 1000
      PBAI.log("- 1000 because target has Haze")
    end
    if $spam_block_triggered && $spam_block_flags[:choice].is_a?(Pokemon) && user.set_up_score == 0
      score += 1000
      PBAI.log("+ 1000 to set up on the switch")
    end
    if user.set_up_score >= 2
      score -= 1000
      PBAI.log("- 1000 to encourage attacking")
    end
    
  next score
end

# Calm Mind/Quiver Dance/Geomancy/Tail Glow
PBAI::ScoreHandler.add("02B", "02C", "14E", "039","028") do |score, ai, user, target, move|
  count = 0
  if user.setup?
    if user.statStageAtMax?(:SPECIAL_ATTACK)
      score = 0
      PBAI.log("* 0 for battler being max Special Attack")
    else
      count = 0
      user.moves.each do |m|
        count += 1 if user.get_move_damage(target, m) > target.hp/2 && m.specialMove?
      end
      t_count = 0
      $thief = 0
      if $game_switches[LvlCap::Expert] == true
        target.moves.each do |tmove|
          t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
          $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
        end
      else
        if target.used_moves != nil
          target.used_moves.each do |tmove|
            t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
            $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
          end
        end
      end
      add = user.turnCount == 0 ? 80 : 50
      score += add
      PBAI.log("+ #{add} ")
      if count == 0 && t_count == 0
        add = user.turnCount == 0 ? 80 : 50
        score += add
        PBAI.log("+ #{add} to boost to guarantee the kill")
        atk_boost = user.stages[:SPECIAL_ATTACK]*20
        def_boost = user.stages[:SPECIAL_DEFENSE]*20
        diff = atk_boost + def_boost
        score -= diff
        PBAI.log("- #{diff} for boosted stats") if diff > 0
        PBAI.log("+ #{diff} for lowered stats") if diff < 0
        score += 20 if user.predict_switch?(target)
        PBAI.log("+ 20 for predicting the switch") if user.predict_switch?(target)
        score += 50 if $learned_flags[:setup_fodder].include?(target)
        PBAI.log("+ 50 for using the target as setup fodder") if $learned_flags[:setup_fodder].include?(target)
      elsif count == 0 && t_count == 0 && !user.faster_than?(target) && move.function != "02C"
        add = user.turnCount == 0 ? 60 : 40
        score += add
        PBAI.log("+ #{add} to boost to guaranteed outspeed and kill")
        atk_boost = user.stages[:SPECIAL_ATTACK]*20
        def_boost = user.stages[:SPECIAL_DEFENSE]*20
        diff = atk_boost + def_boost
        score -= diff
        PBAI.log("- #{diff} for boosted stats") if diff > 0
        PBAI.log("+ #{diff} for lowered stats") if diff < 0
        score += 20 if user.predict_switch?(target)
        PBAI.log("+ 20 for predicting the switch") if user.predict_switch?(target)
        score += 50 if $learned_flags[:setup_fodder].include?(target)
        PBAI.log("+ 50 for using the target as setup fodder") if $learned_flags[:setup_fodder].include?(target)
      elsif count > 0 && user.faster_than?(target)
        score -= 1000
        PBAI.log("- 1000 since the target can now be outsped and killed")
      elsif count > 0 && t_count == 0
        score -= 500
        PBAI.log("- 500 since the target can now be killed and cannot kill back")
      end
      if t_count > 0 && !user.can_switch?
        score -= 1000
        PBAI.log("- 1000 because setup is pointless.")
      end
      if $thief > 0
        score -= 1000
        PBAI.log("- 1000 to not give a mon free setup")
      end
    end
  end
  if $spam_block_flags[:haze_flag].include?(target)
      score -= 1000
      PBAI.log("- 1000 because target has Haze")
    end
    if $spam_block_triggered && $spam_block_flags[:choice].is_a?(Pokemon) && user.set_up_score == 0
      score += 1000
      PBAI.log("+ 1000 to set up on the switch")
    end
    if user.set_up_score >= 2
      score -= 1000
      PBAI.log("- 1000 to encourage attacking")
    end
    
  next score
end

#Grassy Glide
PBAI::ScoreHandler.add("18C") do |score, ai, user, target, move|
  if ai.battle.field.terrain == :Grassy
    pri = 0
    if $game_switches[LvlCap::Expert] == true
      for i in target.moves
        pri += 1 if i.priority > 0 && i.damagingMove?
      end
    else
      for i in target.used_moves
        pri += 1 if i.priority > 0 && i.damagingMove?
      end
    end
    if target.faster_than?(user)
      score += 50
      PBAI.log("+ 50 for being a priority move to outspeed opponent")
      if user.get_move_damage(target, move) >= target.hp
        score += 20
        PBAI.log("+ 20 for being able to KO with priority")
      end
    end
    if pri > 0
      outspeed = user.faster_than?(target) ? 50 : -50
      score += outspeed
      PBAI.log("+ #{outspeed} for being a priority move to try to counter opponent's priority") if outspeed > 0
      PBAI.log("#{outspeed} for being a slower priority move to try to counter opponent's priority") if outspeed < 0
    end
  end
  score += 20
  field = "Grassy Terrain boost"
  PBAI.log("+ 20 for #{field}")
  next score
end

# Protect
PBAI::ScoreHandler.add("0AA") do |score, ai, user, target, move|
  if ai.battle.positions[user.index].effects[PBEffects::Wish] > 0
    score += 300
    PBAI.log("+ 300 for receiving an incoming Wish")
  end
  if ai.battle.pbSideSize(0) == 2 && user.effects[PBEffects::ProtectRate] == 1
    score += 50
    PBAI.log("+ 50 for encouraging use of Protect in Double battles")
  end
  if user.effects[PBEffects::Substitute] > 0 && user.effects[PBEffects::ProtectRate] == 1
    if user.hasActiveAbility?(:SPEEDBOOST) && target.faster_than?(user)
      score += 100
      PBAI.log("+ 100 for boosting speed to outspeed opponent")
    end
    if (user.hasActiveItem?(:LEFTOVERS) || (user.hasActiveAbility?(:POISONHEAL) && user.status == :POISON)) && user.hp < user.totalhp
      score += 50
      PBAI.log("+ 50 for recovering HP behind a Substitute")
    end
    if target.effects[PBEffects::LeechSeed] || target.effects[PBEffects::StarSap] || [:POISON,:BURN,:FROZEN].include?(target.status)
      score += 50
      PBAI.log("+ 50 for forcing opponent to take residual damage")
    end
  end
  if (user.hasActiveItem?(:FLAMEORB) && user.status == :NONE && user.hasActiveAbility?([:GUTS,:MARVELSCALE])) || ((user.hasActiveItem?(:TOXICORB) || ai.battle.field.terrain == :Poison) && user.hasActiveAbility?([:TOXICBOOST,:POISONHEAL,:GUTS]) && user.affectedByTerrain? && user.status == :NONE)
    score += 500
    PBAI.log("+ 500 for getting a status to benefit their ability")
  end
  if (target.status == :POISON || target.status == :BURN || target.status == :FROZEN)
    protect = 100 - user.effects[PBEffects::ProtectRate] * 40
    score += protect
    PBAI.log("+ #{protect} for stalling status damage")
    if user.has_role?(:TOXICSTALLER) && target.status == :POISON
      score += 30
      PBAI.log("+ 30 ")
    end
  end
  score -= 40 if user.predict_switch?(target)
  if user.predict_switch?(target)
    PBAI.log("- 40 for predicting the switch")
  end
  score += 60 if user.flags[:should_protect] == true
  PBAI.log("+ 60 because there are no better moves") if user.flags[:should_protect] == true
  if user.effects[PBEffects::ProtectRate] > 1
    protect = user.effects[PBEffects::ProtectRate] * 100
    score -= protect
    PBAI.log("- #{protect} to prevent potential Protect failure")
  else
    if user.turnCount == 0 && user.hasActiveAbility?(:SPEEDBOOST)
      score += 100
      PBAI.log("+ 100 for getting turn 1 Speed Boost")
    end
  end
  next score
end

# Teleport
PBAI::ScoreHandler.add("0EA") do |score, ai, user, target, move|
  roles = []
    for i in user.roles
      roles.push(i)
    end
  if user.effects[PBEffects::Trapping] > 0 && !user.predict_switch?(target)
    score += 300
    PBAI.log("+ 300 for escaping the trap")
  end
  if user.has_role?([:PHYSICALWALL,:SPECIALWALL,:DEFENSIVEPIVOT,:OFFENSIVEPIVOT,:TOXICSTALLER,:LEAD])
    score += 50
    PBAI.log("+ 50 ")
  end
  fnt = 0
  user.side.party.each do |pkmn|
    fnt +=1 if pkmn.fainted?
  end
  if user.hasActiveAbility?(:REGENERATOR) && fnt < user.side.party.length && user.hp < user.totalhp*0.67
    score += 50
    PBAI.log("+ 50 for being able to recover with Regenerator")
  end
  if fnt == user.side.party.length - 1
    score = 0
    PBAI.log("* 0 for being the last Pokémon in the party")
  end
  if !user.can_switch?
      score -= 1000
      PBAI.log("- 1000 because we cannot Teleport")
    end
  next score
end

#Beat Up for Doubles Mini Boss
PBAI::ScoreHandler.add("0C1") do |score, ai, user, target, move|
  if user.has_role?(:TARGETALLY) && move.id == :BEATUP2
    score += 200
    PBAI.log("+ 200 ")
  end
  next score
end

#Tempest Rage for Primal Castform
PBAI::ScoreHandler.add("087") do |score, ai, user, target, move|
  if user.battler.species == :CASTFORM && user.battler.form == 1 && move.id == :TEMPESTRAGE
    score += 50
    PBAI.log("+ 50 because the move changes type and weather to match well vs target")
  end
  next score
end

#Substitute
PBAI::ScoreHandler.add("10C") do |score, ai, user, target, move|
  dmg = 0
  sound = 0
  roles = []
    for i in user.roles
      roles.push(i)
    end
  if $game_switches[LvlCap::Expert]
    for i in target.moves
      dmg += 1 if target.get_move_damage(user,i) >= user.totalhp/4
      sound += 1 if i.soundMove? && i.damagingMove?
    end
  else
    for i in target.used_moves
      dmg += 1 if target.get_move_damage(user,i) >= user.totalhp/4
      sound += 1 if i.soundMove? && i.damagingMove?
    end
  end
  if user.effects[PBEffects::Substitute] == 0
    if user.turnCount == 0 && dmg == 0
      score += 100
      PBAI.log("+ 100 for Substituting on the first turn and being guaranteed to have a Sub stay up")
    end
    if user.has_role?([:TOXICSTALLER,:PHYSICALWALL,:SPECIALWALL,:STALLBREAKER,:DEFENSIVEPIVOT,:OFFENSIVEPIVOT,:SETUPSWEEPER,:WINCON])
      score += 50
      PBAI.log("+ 50")
    end
    if user.hp < user.totalhp/4
      score -= 10000
      PBAI.log("- 10000 for being unable to Substitute")
    end
    if sound > 0
      score -= 30
      PBAI.log("- 30 because the target has shown a damaging sound-based move")
    end
    if target.status == :POISON || target.status == :BURN || target.status == :FROZEN || target.effects[PBEffects::LeechSeed]>=0 || target.effects[PBEffects::StarSap]>=0
      score += 30
      PBAI.log("+ 30 for capitalizing on target's residual damage")
    end
    if user.predict_switch?(target)
      score += 30
      PBAI.log("+ 30 for capitalizing on target's predicted switch")
    end
  else
    score -= 1000
    PBAI.log("- 1000 for already having a Substitute")
  end
  next score
end

#Destiny Bond
PBAI::ScoreHandler.add("0E7") do |score, ai, user, target, move|
  dmg = 0
  if $game_switches[LvlCap::Expert]
    for i in target.moves
      dmg += 1 if target.get_move_damage(user,i) >= user.hp
    end
  else
    for i in target.used_moves
      dmg += 1 if target.get_move_damage(user,i) >= user.hp
    end
  end
  if dmg > 0
    dbond = 100*dmg
    score += dbond
    PBAI.log("+ #{dbond} for being able to take down the opponent with Destiny Bond")
    if user.hasActiveItem?(:CUSTAPBERRY) && user.hp <= user.totalhp/4
      score += 50
      PBAI.log("+ 50 for having Custap Berry's boosted priority on Destiny Bond")
    end
  end
  score -= 1000 if user.effects[PBEffects::DestinyBondPrevious] == true
  PBAI.log("- 1000 for having used Destiny Bond the previous turn")
  next score
end

#Overcharge
PBAI::ScoreHandler.add("501") do |score, ai, user, target, move|
  if target.pbHasType?(:GROUND)
    score += 50
    PBAI.log("+ 50 for being effective against Ground types")
  end
  if target.hasActiveAbility?([:LIGHTINGROD,:MOTORDRIVE,:VOLTABSORB]) && target.pbHasType?([:WATER,:FLYING])
    score += 50
    PBAI.log("+ 50 for move ignoring abilities and potentially being strong against target")
  end
  next score
end

#Draco Meteor, Astro Bomb, Psycho Boost, etc.
PBAI::ScoreHandler.add("03F","03C","03B","03E","15F","193","114") do |score, ai, user, target, move|
  if user.hasActiveAbility?(:CONTRARY) && !["114"].include?(move.function)
    score += 50
    PBAI.log("+ 50 for boosting")
  end
  if user.hasActiveAbility?(:UNSHAKEN)
    score += 50
    PBAI.log("+ 50 for stat drops being prevented")
  end
  next score
end

#Bonemerang
PBAI::ScoreHandler.add("520") do |score, ai, user, target, move|
  if target.pbHasType?(:FLYING)
    score += 50
    PBAI.log("+ 50 for being effective against Flying types")
  end
  if target.hasActiveAbility?(:LEVITATE) && target.pbHasType?([:FIRE,:ELECTRIC,:ROCK,:STEEL])
    score += 50
    PBAI.log("+ 50 for move ignoring abilities and potentially being strong against target")
  end
  next score
end

#Perfection Pulse
PBAI::ScoreHandler.add("504") do |score, ai, user, target, move|
  if target.pbHasType?(:FAIRY)
    score += 50
    PBAI.log("+ 50 for being effective against Fairy types")
  end
  next score
end

#Polarity Pulse
PBAI::ScoreHandler.add("505") do |score, ai, user, target, move|
  if target.pbHasType?(:ELECTRIC)
    score += 50
    PBAI.log("+ 50 for being super effective against Electric types")
  end
  next score
end

#Stone Axe
PBAI::ScoreHandler.add("512") do |score, ai, user, target, move|
  if user.opposing_side.effects[PBEffects::StealthRock] != true
    score += 50
    PBAI.log("+ 50 for being able to set Stealth Rocks")
  end
  next score
end

#Ceaseless Edge
PBAI::ScoreHandler.add("522") do |score, ai, user, target, move|
  if user.opposing_side.effects[PBEffects::Spikes] < 3
    score += 50
    PBAI.log("+ 50 for being able to set Spikes")
  end
  next score
end

#Trick Room
PBAI::ScoreHandler.add("11F") do |score, ai, user, target, move|
  if ai.battle.field.effects[PBEffects::TrickRoom] == 0 && target.faster_than?(user)
    score += 100
    PBAI.log("+ 100 for setting Trick Room to outspeed target")
    if user.has_role?(:TRICKROOMSETTER)
      score += 200
      PBAI.log("+ 200 ")
    end
  else
    score -= 1000
    PBAI.log("- 1000 to not undo Trick Room") if ai.battle.field.effects[PBEffects::TrickRoom] != 0
  end
  next score
end

#Explosion
PBAI::ScoreHandler.add("0E7") do |score, ai, user, target, move|
  next if move.pbCalcType(user) == :NORMAL && target.pbHasType?(:GHOST)
  next if target.hasActiveAbility?(:DAMP)
  if user.get_move_damage(target, move) >= target.hp
    score += 20
    PBAI.log("+ 20 for being able to KO")
  end
  if !user.can_switch? && user.hasActiveItem?(:CUSTAPBERRY) && user.hp <= user.totalhp/4
    score += 1000
    PBAI.log("+ 1000 for being unable to switch and will likely outprioritize the target")
  end
  if user.hasActiveItem?(:CUSTAPBERRY) && user.hp <= user.totalhp/4
    score += 500
    PBAI.log("+ 500 for being unable to switch and will likely outprioritize the target")
  end
  protect = false
  if $game_switches[LvlCap::Expert]
    for i in target.moves
      protect = true if i.function == "0AA"
      break
    end
  else
    for i in target.used_moves
      protect = true if i.function == "0AA"
      break
    end
  end
  if protect == true
    pro = 50 * target.effects[PBEffects::ProtectRate]
    score += pro
    if pro > 0
      PBAI.log("+ #{pro} to predict around Protect")
    else
      score -= 1000
      PBAI.log("- 1000 because the target has Protect and can choose it")
    end
  end
  next score
end

#Expanding Force
PBAI::ScoreHandler.add("190") do |score, ai, user, target, move|
  if ai.battle.field.terrain == :Psychic
    score += 100
    PBAI.log("+ 100 for boosted damage in Psychic Terrain")
    if ai.battle.pbSideSize(0) == 2
      score += 50
      PBAI.log("+ 50 for being in a Double battle")
    end
  end
  next score
end


#Rage Powder/Ally Switch
PBAI::ScoreHandler.add("117","120") do |score, ai, user, target, move|
  if ai.battle.pbSideSize(0) == 2
    ally = false
    prio = false
    b = nil
    enemy = []
    user.battler.eachAlly do |battler|
      ally = true if battler != user.battler
    end
    if ally
      ai.battle.eachOtherSideBattler(user.index) do |opp|
        enemy.push(opp)
      end
      mon = user.side.battlers.find {|proj| proj && proj != self && !proj.fainted?}
      prio = (mon.has_role?(:TANK) && mon.has_role?(:REDIRECTION))
      if (mon.bad_against?(enemy[0]) || mon.bad_against?(enemy[1]))
        score += 200
        PBAI.log("+ 200 for redirecting an attack away from partner")
        if user.has_role?(:REDIRECTION)
          if prio
            score -= 1000
            PBAI.log("- 1000 because ally is more defensive")
          else
            score += 250
            PBAI.log("+ 250")
          end
        end
      end
      if user.has_role?(:REDIRECTION) && mon.setup?
          score += 150
          PBAI.log("+ 150")
        end
      if $chosen_move != nil
        if $chosen_move.id == :PROTECT
          score = 0
          PBAI.log("* 0 for not wasting a turn.")
        end
      end
    end
  else
    score -= 1000
    PBAI.log("- 1000 because move will fail")
  end
  if $team_flags[:will_redirect] == true
    score -= 1000
    PBAI.log("- 1000 to prevent double Follow Me")
  end
  next score
end

# Shift Gear
PBAI::ScoreHandler.add("036") do |score, ai, user, target, move|
  count = 0
  t_count = 0
  if user.setup?
    if user.statStageAtMax?(:ATTACK) || user.statStageAtMax?(:SPEED)
      score = 0
      PBAI.log("* 0 for battler being max on Attack or Defense")
    else
      user.moves.each do |m|
        count += 1 if user.get_move_damage(target, m) >= target.hp && m.physicalMove?
      end
      $thief = 0
      if $game_switches[LvlCap::Expert] == true
        target.moves.each do |tmove|
          t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
          $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
        end
      else
        if target.used_moves != nil
          target.used_moves.each do |tmove|
            t_count += 1 if target.get_move_damage(user, tmove) >= user.hp
            $thief += 1 if [:SPECTRALTHIEF,:PSYCHUP,:SNATCH].include?(tmove.id)
          end
        end
      end
      add = user.turnCount == 0 ? 80 : 50
      score += add
      PBAI.log("+ #{add} ")
      end
      if count == 0 && t_count == 0
        add = user.turnCount == 0 ? 70 : 40
        score += add
        PBAI.log("+ #{add} to boost to guarantee the kill")
      elsif count > 0
        score -= 100
        PBAI.log("- 100 since the target can now be killed by an attack")
      end
      atk_boost = user.stages[:ATTACK]*20
      spe_boost = user.stages[:SPEED]*20
      diff = atk_boost + spe_boost
      score -= diff
      PBAI.log("- #{diff} for boosted stats") if diff > 0
      PBAI.log("+ #{diff} for lowered stats") if diff < 0
      score += 20 if user.predict_switch?(target)
      PBAI.log("+ 20 for predicting the switch") if user.predict_switch?(target)
      if user.faster_than?(target) && user.is_special_attacker?
        score -= 1000
        PBAI.log("- 1000 because we outspeed and Special Attackers don't factor Attack")
      end
      if $thief > 0
        score -= 1000
        PBAI.log("- 1000 to not give a mon free setup")
      end
    end
    if $spam_block_flags[:haze_flag].include?(target)
      score -= 1000
      PBAI.log("- 1000 because target has Haze")
    end
    if $spam_block_triggered && $spam_block_flags[:choice].is_a?(Pokemon) && user.set_up_score == 0
      score += 1000
      PBAI.log("+ 1000 to set up on the switch")
    end
    if user.set_up_score >= 2
      score -= 1000
      PBAI.log("- 1000 to encourage attacking")
    end
    
  next score
end

#Rolling Fog
PBAI::ScoreHandler.add("521") do |score, ai, user, target, move|
  if ai.battle.field.terrain == :Misty
    score += 100
    PBAI.log("+ 100 for double power in Misty Terrain")
  end
  if ai.battle.pbSideSize(0) == 2
    score += 50
    PBAI.log("+ 50 for hitting both targets")
  end
  next score
end

#Clangourous Soul
PBAI::ScoreHandler.add("179") do |score, ai, user, target, move|
  if user.setup? && user.turnCount == 0 && user.hp > user.totalhp/3
    score += 100
    PBAI.log("+ 100 for gaining an omni-boost")
    if user.hasActiveItem?(:THROATSPRAY)
      score += 50
      PBAI.log("+ 50 for activating Throat Spray")
    end
    if user.predict_switch?(target)
      score += 50
      PBAI.log("+ 50 for predicting the switch")
    end
  end
  if $spam_block_flags[:haze_flag].include?(target)
      score -= 1000
      PBAI.log("- 1000 because target has Haze")
    end
    if $spam_block_triggered && $spam_block_flags[:choice].is_a?(Pokemon) && user.set_up_score == 0
      score += 1000
      PBAI.log("+ 1000 to set up on the switch")
    end
    if user.set_up_score >= 2
      score -= 1000
      PBAI.log("- 1000 to encourage attacking")
    end
  next score
end

#First Impression
PBAI::ScoreHandler.add("174") do |score, ai, user, target, move|
  if user.turnCount == 0 && ai.battle.field.terrain != :Psychic && !target.hasActiveAbility?([:ARMORTAIL,:DAZZLING,:QUEENLYMAJESTY])
    score += 200
    PBAI.log("+ 200 for getting priority damage")
  else
    score -= 1000
    PBAI.log("- 1000 to discourage use after turn 1")
  end
  next score
end

# Rapid Spin
PBAI::ScoreHandler.add("110") do |score, ai, user, target, move|
  hazard_score = 0
  rocks = user.own_side.effects[PBEffects::StealthRock] ? 1 : 0
  webs = user.own_side.effects[PBEffects::StickyWeb] ? 1 : 0
  spikes = user.own_side.effects[PBEffects::Spikes] > 0 ? user.own_side.effects[PBEffects::Spikes] : 0
  tspikes = user.own_side.effects[PBEffects::ToxicSpikes] > 0 ? user.own_side.effects[PBEffects::ToxicSpikes] : 0
  comet = user.own_side.effects[PBEffects::CometShards] ? 1 : 0
  hazard_score = (rocks*20) + (webs*20) + (spikes*10) + (tspikes*10) + (comet*20)
  score += hazard_score
  PBAI.log("+ #{hazard_score} for removing hazards")
  if user.has_role?(:HAZARDREMOVAL)
    score += 50
    PBAI.log("+ 50 ")
  end
  next score
end

# Defog
PBAI::ScoreHandler.add("049") do |score, ai, user, target, move|
  hazard_score = 0
  rocks = user.own_side.effects[PBEffects::StealthRock] ? 1 : 0
  webs = user.own_side.effects[PBEffects::StickyWeb] ? 1 : 0
  spikes = user.own_side.effects[PBEffects::Spikes] > 0 ? user.own_side.effects[PBEffects::Spikes] : 0
  tspikes = user.own_side.effects[PBEffects::ToxicSpikes] > 0 ? user.own_side.effects[PBEffects::ToxicSpikes] : 0
  comet = user.own_side.effects[PBEffects::CometShards] ? 1 : 0
  light = user.opposing_side.effects[PBEffects::LightScreen] > 0 ? user.opposing_side.effects[PBEffects::LightScreen] : 0
  reflect = user.opposing_side.effects[PBEffects::Reflect] > 0 ? user.opposing_side.effects[PBEffects::Reflect] : 0
  veil = user.opposing_side.effects[PBEffects::AuroraVeil] > 0 ? user.opposing_side.effects[PBEffects::AuroraVeil] : 0
  hazard_score = (rocks*20) + (webs*20) + (spikes*10) + (tspikes*10) + (comet*20) + (light*10) + (reflect*10) + (veil*20)

  orocks = user.opposing_side.effects[PBEffects::StealthRock] ? 1 : 0
  owebs = user.opposing_side.effects[PBEffects::StickyWeb] ? 1 : 0
  ospikes = user.opposing_side.effects[PBEffects::Spikes] > 0 ? user.opposing_side.effects[PBEffects::Spikes] : 0
  otspikes = user.opposing_side.effects[PBEffects::ToxicSpikes] > 0 ? user.opposing_side.effects[PBEffects::ToxicSpikes] : 0
  ocomet = user.opposing_side.effects[PBEffects::CometShards] ? 1 : 0
  slight = user.own_side.effects[PBEffects::LightScreen] > 0 ? user.own_side.effects[PBEffects::LightScreen] : 0
  sreflect = user.own_side.effects[PBEffects::Reflect] > 0 ? user.own_side.effects[PBEffects::Reflect] : 0
  sveil = user.own_side.effects[PBEffects::AuroraVeil] > 0 ? user.own_side.effects[PBEffects::AuroraVeil] : 0
  user_score = (orocks*20) + (owebs*20) + (ospikes*10) + (otspikes*10) + (ocomet*20) + (slight*10) + (sreflect*10) + (sveil*20)
  hazards = (hazard_score - user_score)
  score += hazards
  PBAI.log("+ #{hazards} for removing hazards and screens")
  if user.has_role?(:HAZARDREMOVAL) && hazards > 0
    score += 50
    PBAI.log("+ 50 ")
  end
  if target.hasActiveAbility?([:MAGICBOUNCE,:GOODASGOLD])
    score -= 1000
    PBAI.log("- 1000 because Defog will fail")
  end
  next score
end

#Rage Fist
PBAI::ScoreHandler.add("522") do |score, ai, user, target, move|
  hit = ai.battle.getBattlerHit(user) * 50
  if hit > 0
    score += hit
    PBAI.log("+ #{hit} for having a damage boost")
  end
  next score
end

#Tailwind
PBAI::ScoreHandler.add("05B") do |score, ai, user, target, move|
  if user.own_side.effects[PBEffects::Tailwind] <= 0
    score += 200
    PBAI.log("+ 200 for setting up to outspeed")
    if user.has_role?(:SPEEDCONTROL)
      score += 100
      PBAI.log("+ 100 ")
    end
  else
    score -= 1000
    PBAI.log("- 1000 because Tailwind is already up")
  end
  next score
end

# Pursuit
PBAI::ScoreHandler.add("088") do |score, ai, user, target, move|
  if user.predict_switch?(target)
    score += 200
    PBAI.log("+ 200 for predicting the switch")
  end
  next score
end

# Hex, Bitter Malice, Barb Barrage, Infernal Parade
PBAI::ScoreHandler.add("07F","519","515","517") do |score, ai, user, target, move|
  if target.status != :NONE
    score += 200
    PBAI.log("+ 200 for abusing target's status")
  end
  next score
end

# Bolt Beak, Fishious Rend
PBAI::ScoreHandler.add("178") do |score, ai, user, target, move|
  if (user.faster_than?(target) && !user.target_is_immune?(move,target)) || user.predict_switch?(target)
    score += 250
    PBAI.log("+ 250 for getting double damage")
  end
  next score
end

#Knock Off
PBAI::ScoreHandler.add("0F0") do |score, ai, user, target, move|
  item = target.item
  dmg = 0
  if $game_switches[LvlCap::Expert]
    for i in target.moves
      dmg += 1 if target.get_move_damage(user,i) >= user.hp
    end
  else
    if target.used_moves != nil
      for i in target.used_moves
        dmg += 1 if target.get_move_damage(user,i) >= user.hp
      end
    else
      dmg = 0
    end
  end
  next score if item.nil?
  if !user.unlosableItem?(item)
    score += 200
    PBAI.log("+ 200 for removing items")
  end
  if target.faster_than?(user) && dmg > 0
    score -= 1000
    PBAI.log("- 1000 to prioritize priority moves over removing items since we will die anyway")
  end
  next score
end

# Hydro Steam
PBAI::ScoreHandler.add("550") do |score, ai, user, target, move|
  if ai.battle.pbWeather == :Sun
    score += 200
    PBAI.log("+ 200 for abusing Sun")
  end
  next score
end

# PsyBlade
PBAI::ScoreHandler.add("551") do |score, ai, user, target, move|
  if ai.battle.field.terrain == :Electric
    score += 200
    PBAI.log("+ 200 for abusing Electric Terrain")
  end
  next score
end