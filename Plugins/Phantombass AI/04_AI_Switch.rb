class PBAI
  class SwitchHandler
    @@GeneralCode = []
    @@TypeCode = []
    @@SwitchOutCode = []

	  def self.add(&code)
	   	@@GeneralCode << code
	 	end

	  def self.add_type(*type,&code)
			@@TypeCode << code
	  end

	  def self.add_out(&code)
	  	@@SwitchOutCode << code
	  end

		def self.trigger(list,score,ai,battler,proj,target)
			return score if list.nil?
			list = [list] if !list.is_a?(Array)
			list.each do |code|
	  	next if code.nil?
	  		newscore = code.call(score,ai,battler,proj,target)
	  		score = newscore if newscore.is_a?(Numeric)
	  	end
		  return score
		end

		def self.out_trigger(list,switch,ai,battler,target)
			return switch if list.nil?
			list = [list] if !list.is_a?(Array)
			list.each do |code|
	  	next if code.nil?
	  		newswitch = code.call(switch,ai,battler,target)
	  		switch = newswitch if !newswitch.nil?
	  	end
		  return switch
		end

		def self.trigger_general(score,ai,battler,proj,target)
		  return self.trigger(@@GeneralCode,score,ai,battler,proj,target)
		end

		def self.trigger_out(switch,ai,battler,target)
		  return self.out_trigger(@@SwitchOutCode,switch,ai,battler,target)
		end

		def self.trigger_type(type,score,ai,battler,proj,target)
		  return self.trigger(@@TypeCode,score,ai,battler,proj,target)
		end
  end
end

#=======================
#Type Immunity Modifiers
#=======================

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	target_moves = target.moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :FIRE && i.damagingMove? && battler.calculate_move_matchup(i.id) > 1
	end
	if has_move
			switch = true
		end
	$switch_flags[:fire] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	target_moves = target.moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :WATER && i.damagingMove? && battler.calculate_move_matchup(i.id) > 1
	end
	if has_move
			switch = true
		end
	$switch_flags[:water] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	target_moves = target.moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :GRASS && i.damagingMove? && battler.calculate_move_matchup(i.id) > 1
	end
	if has_move
			switch = true
		end
	$switch_flags[:grass] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	target_moves = target.moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :ELECTRIC && i.damagingMove? && battler.calculate_move_matchup(i.id) > 1
	end
	if has_move
			switch = true
		end
	$switch_flags[:electric] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	target_moves = target.moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :POISON && i.damagingMove? && battler.calculate_move_matchup(i.id) > 1
	end
	if has_move
			switch = true
		end
	$switch_flags[:poison] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	target_moves = target.moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :GROUND && i.damagingMove? && battler.calculate_move_matchup(i.id) > 1
	end
	if has_move
			switch = true
		end
	if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground")
		switch = true
		$switch_flags[:digging] = true
	end
	$switch_flags[:ground] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	target_moves = target.moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :ROCK && i.damagingMove? && battler.calculate_move_matchup(i.id) > 1
	end
	if has_move
			switch = true
		end
	$switch_flags[:rock] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	target_moves = target.moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :DARK && i.damagingMove? && battler.calculate_move_matchup(i.id) > 1
	end
	if has_move
			switch = true
		end
	$switch_flags[:dark] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	target_moves = target.moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :COSMIC && i.damagingMove? && battler.calculate_move_matchup(i.id) > 1
	end
	if has_move
			switch = true
		end
	$switch_flags[:cosmic] = true if switch
	next switch
end

#=======================
# Switch Out Modifiers
#=======================
PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	best = battler.get_optimal_switch_choice
	move = 0
	target_moves = target.moves
	calc = 0
	damage = 0
	pivot = nil
	if target.bad_against?(battler)
		battler.opposing_side.battlers.each do |target|
		  next if ai.battle.wildBattle?
			for i in target_moves
				next if target_moves == nil
			  dmg = target.get_move_damage(battler, i)
			  calc += 1 if (dmg >= battler.hp/2)
			end
		end
		battler.opposing_side.battlers.each do |target|
		  next if ai.battle.wildBattle?
		  for i in battler.moves
		    dmg = battler.get_move_damage(target, i)
		    damage += 1 if (dmg >= target.hp/2)
		  end
		end
		if battler.faster_than?(target) && damage > 0 && calc == 0
			switch = false
		end
		if battler.faster_than?(target) && damage == 0 && calc > 0
			switch = true
		end
		if target.faster_than?(battler) && damage > 0 && calc == 0
			switch = false
		end
		if target.faster_than?(battler) && calc > 0
			switch = true
		end
		for i in battler.moves
			move += 1 if target.calculate_move_matchup(i.id) > 1
		end	
		if move > 0 && battler.faster_than?(target)
			switch = false
		elsif move == 0
			switch = true
		end
	elsif target.bad_against?(battler) && target_moves == nil
		switch = false
	end
	if ((best[0][1] == battler)  && (best[0][0] == best[1][0]) || (best[1][1] == battler)  && (best[0][0] == best[1][0]))
		switch = false
	end
	next switch
end


PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	switch = false if battler.effects[PBEffects::PowerTrick]
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	switch = false if battler.effects[PBEffects::Substitute] > 0
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	next switch if !ai.battle.doublebattle
	ally = battler.side.battlers.find {|proj| proj && proj != battler && !proj.fainted?}
	next switch if ally.nil?
	for move in ally.moves
		if ally.target_is_immune?(move,battler) && [:AllNearOthers,:AllBattlers,:BothSides].include?(move.pbTarget(battler))
			switch = false
		end
	end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	if battler.choice_locked?
    choiced_move_name = GameData::Move.get(battler.effects[PBEffects::ChoiceBand])
    factor = 0
    battler.opposing_side.battlers.each do |pkmn|
      factor += pkmn.calculate_move_matchup(choiced_move_name)
    end
    if (factor < 1 && ai.battle.pbSideSize(0) == 1) || (factor < 2 && ai.battle.pbSideSize(0) == 2)
      switch = true
      $choiced_switch = true
    end
    move = PokeBattle_Move.from_pokemon_move(ai.battle,Pokemon::Move.new(choiced_move_name))
    if target.target_is_immune?(move,battler)
    	switch = true
    	$choiced_switch = true
    end
  end
	next switch
end

#Switch determined by whether you're set up
PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	if battler.set_up_score > 0
		switch = false
	elsif battler.set_up_score < 0
		if battler.stages[:SPEED] < 0 && ai.battle.field.effects[PBEffects::TrickRoom] != 0
			switch = false
		else
			switch = true
		end
	end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	if battler.effects[PBEffects::Toxic] > 1
    switch = true
  end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	party = ai.battle.pbParty(battler.index)
	if battler.status != :NONE
		if party.any? {|pkmn| [:CLERIC].include?(pkmn.roles) && !battler.has_role(:CLERIC)}
    	switch = true
    	$switch_flags[:need_cleric] = true
    end
    if battler.hasActiveAbility?(:NATURALCURE)
    	switch = true
    end
    if battler.hasActiveAbility?(:GUTS)
    	switch = false
    	
    end
  end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	target_moves = target.moves
	calc = 0
	damage = 0
	flag1 = false
	flag2 = false
	battler.opposing_side.battlers.each do |target|
	  next if ai.battle.wildBattle?
	  next if target_moves == nil
		for i in target_moves
		  calc += 1 if i.damagingMove?
		end
		if calc <= 0
			flag1 = true
		end
		for i in battler.moves
	    dmg = battler.get_move_damage(target, i)
	    damage += 1 if dmg >= target.totalhp/2
	  end
	  if damage == 0
	  	flag2 = true
	  end
	  if flag1 == true && flag2 == true
	  	$learned_flags[:setup_fodder].push(target)
	  	switch = battler.setup? ? false : true
	  end
	end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	pos = ai.battle.positions[battler.index]
	party = ai.battle.pbParty(battler.index)
	tspikes = battler.own_side.effects[PBEffects::ToxicSpikes] == nil ? 0 : battler.own_side.effects[PBEffects::ToxicSpikes]
	comet = battler.own_side.effects[PBEffects::CometShards] == false ? 0 : 1
	if tspikes > 0
	  if party.any? { |pkmn| pkmn.types.include?(:POISON) && !pkmn.grounded? && !target.moves.any? {|move| Effectiveness.super_effective_type?(move.type,pkmn.types[0],pkmn.types[1])}}
	    switch = true
	    $switch_flags[:poison] = true
	  end
	end
	if comet > 0
	  if party.any? { |pkmn| pkmn.types.include?(:COSMIC) && !target.moves.any? {|move| Effectiveness.super_effective_type?(move.type,pkmn.types[0],pkmn.types[1])}}
	    switch = true
	    $switch_flags[:cosmic] = true
	  end
	end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	pos = ai.battle.positions[battler.index]
	party = ai.battle.pbParty(battler.index)
  # If Future Sight will hit at the end of the round
  if pos.effects[PBEffects::FutureSightCounter] == 1
    # And if we have a dark type in our party
    if party.any? { |pkmn| pkmn.types.include?(:DARK) && !target.moves.any? {|move| Effectiveness.super_effective_type?(move.type,pkmn.types[0],pkmn.types[1])} }
      # We should switch to a dark type,
      # but not if we're already close to dying anyway.
      if !battler.may_die_next_round?
        switch = true
        $switch_flags[:dark] = true
      end
    end
  end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	calc = 0
	battler.opposing_side.battlers.each do |target|
	  next if ai.battle.wildBattle?
	  for i in battler.moves
	    dmg = battler.get_move_damage(target, i)
	    calc += 1 if dmg >= target.totalhp/3
	  end
	end
	if calc == 0
	  switch = true
	end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	if !ai.battle.pbCanChooseAnyMove?(battler.index)
    switch = true
  end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	if battler.effects[PBEffects::PerishSong] == 1
    switch = true
  end
	next switch
end

# Switch if target has a super effective move
PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	target_moves = target.moves
	for move in target_moves
		switch = true if battler.calculate_move_matchup(move.id) > 1
		$switch_flags[:move] = move if switch == true
	end
  next switch
end


PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	if battler.trapped?
    switch = false
  end
	next switch
end


#Battler Yawned
PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	if battler.effects[PBEffects::Yawn] == 1
		switch = true
	end
	next switch
end

#Battler Salt Cured
PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	if battler.effects[PBEffects::SaltCure]
		switch = true
	end
	next switch
end

#Battler set up Focus Energy
PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	if battler.effects[PBEffects::FocusEnergy] > 0 && battler.has_role?(:CRIT)
		switch = false
	end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	if battler.effects[PBEffects::Encore] > 0
    encored_move_index = battler.pbEncoredMoveIndex
    if encored_move_index >= 0
      encored_move = battler.moves[encored_move_index]
      if encored_move.statusMove?
        switch = true
      else
        dmg = battler.get_move_damage(target, encored_move)
        if dmg > target.totalhp/3
          switch = false
        else
          # No record of dealing damage with this move,
          # which probably means the target is immune somehow,
          # or the battler happened to miss. Don't risk being stuck in
          # a bad move in any case, and switch.
          switch = true
        end
      end
    end
  end
	next switch
end

# Don't switch turn 1 if you have a non-bad matchup
PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	weak = target.moves.any? {|move| target.get_move_damage(battler,move) >= battler.hp}
	switch = false if battler.turnCount == 0 && weak == false
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	next switch if !$spam_block_triggered
	next switch if !$spam_block_flags[:choice].is_a?(PokeBattle_Move)
	nextMove = $spam_block_flags[:choice]
	nextDmg = target.get_move_damage(battler,nextMove)
  if nextDmg < battler.hp/2 || nextDmg < battler.totalhp/3
  	switch = false
  end
  next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	next if $switch_flags[:switch] == nil
	switch = $switch_flags[:switch]
	next switch
end

#=======================
#Other Modifiers
#=======================

=begin
PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	next switch if !$spam_block_triggered
	next switch if !$spam_block_flags[:choice].is_a?(PokeBattle_Move)
	nextMove = $spam_block_flags[:choice]
	nextDmg = target.get_move_damage(battler,nextMove)
  if (nextDmg < battler.hp/2 || nextDmg < battler.totalhp/3) && nextMove.id == :UTURN
  	pkmn = false
  	battler.side.party.each do |mon|
  		next if mon.battler.species != :ANNIHILAPE
  		pkmn = true if mon.battler.species == :ANNIHILAPE
  	end
  	switch = false
  end
  next switch
end

PBAI::SwitchHandler.add do |score,ai,battler,proj,target|
	if $spam_block_triggered && $spam_block_flags[:choice].is_a?(PokeBattle_Move)
		nextMove = $spam_block_flags[:choice]
		nextDmg = target.get_move_damage(battler,nextMove)
		damage = 0
		if nextDmg >= battler.hp
			score -= 1000
			PBAI.log("- 1000 because the battler will faint switching in")
		else
			if nextMove.id == :UTURN && battler.battler.species == :ANNIHILAPE
				score += 1000
			end
		end
	end
  next score
end

#Weather Abusers
PBAI::SwitchHandler.add_out do |switch,ai,battler,target|
	weather = [:DROUGHT,:DRIZZLE,:SANDSTREAM,:SANDSPIT,:DESOLATELAND,:PRIMORDIALSEA,:DELTASTREAM,:NIGHTFALL,:EQUINOX,:URBANCLOUD,:GALEFORCE,:SNOWWARNING,:HAILSTORM]
	weather_move = [:RAINDANCE,:SANDSTORM,:SUNNYDAY,:SNOWSCAPE]
	abuser = battler.side.party.find {|mon|
	pkmn = ai.pbMakeFakeBattler(mon)
	pkmn.has_role?(:WEATHERTERRAINABUSER)}
	changer = battler.opposing_side.battlers.find {|pkmn| pkmn.hasActiveAbility?(weather) || pkmn.hasMove?(weather_move) }
	if battler.has_role?(:WEATHERTERRAIN) && !abuser.nil? && !changer.nil?
		switch = true
	end
	next switch
end
=end