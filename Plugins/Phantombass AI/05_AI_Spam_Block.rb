class PBAI
	def self.log_spam(msg)
		echoln "[AI Spam Block] " + msg
	end
  class SpamHandler
    @@GeneralCode = []
    @@SecondCode = []

	  def self.add(&code)
	   	@@GeneralCode << code
	 	end

	 	def self.add_secondary(&code)
	 		@@SecondCode << code
	 	end

	 	def self.set(list,flag,ai,battler,target)
	 		return flag if list.nil?
	 		list = [list] if !list.is_a?(Array)
			list.each do |code|
	  	next if code.nil?
	  		add_flag = code.call(flag,ai,battler,target)
	  		flag = add_flag
	  	end
		  return flag
		end

		def self.set_second(list,score,ai,battler,target)
	 		return score if list.nil?
			list = [list] if !list.is_a?(Array)
			list.each do |code|
	  	next if code.nil?
	  		newscore = code.call(score,ai,battler,target)
	  		score = newscore if newscore.is_a?(Numeric)
	  	end
		  return score
		end

		def self.trigger(flag,ai,battler,target)
			return self.set(@@GeneralCode,flag,ai,battler,target)
		end

		def self.trigger_secondary(score,ai,battler,target)
			return self.set_second(@@SecondCode,score,ai,battler,target)
		end
  end
end

#Triple Switch
PBAI::SpamHandler.add do |flag,ai,battler,target|
	next flag if $spam_block_triggered
	triple_switch = $spam_block_flags[:triple_switch]
	next flag if triple_switch.length < 3
	check = 0
	for i in triple_switch
		check += 1 if !i.nil?
		check = 0 if i.nil?
		$spam_block_flags[:triple_switch].clear if check == 0
		$spam_block_flags[:choice] = nil if check == 0
	end
	if check == 3
		flag = true
		$spam_block_triggered = true
		$spam_block_flags[:triple_switch].clear
	end
	next flag
end

#Double Initiative
PBAI::SpamHandler.add do |flag,ai,battler,target|
	next flag if $spam_block_triggered
	initiative = ["0EE","529","538","0ED","0EA","151"]
	same_move = $spam_block_flags[:initiative_flag]
	next flag if same_move.length < 2
	check = 0
	for i in same_move
		check += 1 if initiative.include?(i.function)
		check = 0 if !initiative.include?(i.function)
		$spam_block_flags[:initiative_flag].clear if check == 0
		$spam_block_flags[:choice] = nil if check == 0
	end
	if check == 2
		flag = true
		$spam_block_triggered = true
		$spam_block_flags[:initiative_flag].clear
	end
	next flag
end

#Double Recover
PBAI::SpamHandler.add do |flag,ai,battler,target|
	next flag if $spam_block_triggered
	recover = ["0D6","0D5","0D8","1D6","0D9"]
	same_move = $spam_block_flags[:double_recover]
	next flag if same_move.length < 3
	check = 0
	for i in same_move
		check += 1 if recover.include?(i.function)
		check = 0 if !recover.include?(i.function)
		$spam_block_flags[:double_recover].clear if check == 0
		$spam_block_flags[:choice] = nil if check == 0
	end
	if check == 3
		flag = true
		$spam_block_triggered = true
		$spam_block_flags[:double_recover].clear
	end
	next flag
end

#Same Move
PBAI::SpamHandler.add do |flag,ai,battler,target|
	next flag if $spam_block_triggered
	next flag if $spam_block_flags[:choiced_flag].include?(target)
	same_move = $spam_block_flags[:same_move]
	next flag if same_move.length < 5
	check = 0
	for i in 1...same_move.length
		check += 1 if same_move[i] == same_move[i-1]
		check = 0 if same_move[i] != same_move[i-1]
		$spam_block_flags[:same_move].clear if check == 0
		$spam_block_flags[:choice] = nil if check == 0
	end
	if check == 4
		flag = true
		$spam_block_triggered = true
		$spam_block_flags[:same_move].clear
	end
	next flag
end

#Double Stat Drop
PBAI::SpamHandler.add do |flag,ai,battler,target|
	next flag if $spam_block_triggered
	double_stat = $spam_block_flags[:double_intimidate]
	next flag if double_stat.length < 2
	check = 0
	for i in double_stat
		check += 1 if [:INTIMIDATE,:MEDUSOID,:MINDGAMES].include?(i)
		check = 0 if ![:INTIMIDATE,:MEDUSOID,:MINDGAMES].include?(i)
		$spam_block_flags[:double_intimidate].clear if check == 0
		$spam_block_flags[:choice] = nil if check == 0
	end
	if check == 2
		flag = true
		$spam_block_triggered = true
		$spam_block_flags[:double_intimidate].clear
	end
	next flag
end

#Protect into Switch
PBAI::SpamHandler.add do |flag,ai,battler,target|
	next flag if $spam_block_triggered
	protect_switch = $spam_block_flags[:protect_switch]
	next flag if protect_switch.length < 2
	for i in 1...protect_switch.length
		if (protect_switch[i] == :Switch && protect_switch[i-1].is_a?(PokeBattle_ProtectMove))
			$spam_block_flags[:protect_switch_add] += 1
			$spam_block_flags[:protect_switch].clear
		end
	end
	flag = true if $spam_block_flags[:protect_switch_add] >= 3
	$spam_block_triggered = flag
	next flag
end

#Switch to Ghost on Fake Out
PBAI::SpamHandler.add do |flag,ai,battler,target|
	next flag if $spam_block_triggered
	protect_switch = $spam_block_flags[:fake_out_ghost_flag]
	next flag if protect_switch.length < 2
	flag = protect_switch.length == 2
	$spam_block_triggered = flag
	next flag
end

#Yawn into Protect
PBAI::SpamHandler.add do |flag,ai,battler,target|
	next flag if $spam_block_triggered
	protect_switch = $spam_block_flags[:yawn]
	next flag if protect_switch.length < 2
	for i in 1...protect_switch.length
		if (protect_switch[i].id == :YAWN && protect_switch[i-1].is_a?(PokeBattle_ProtectMove))
			$spam_block_flags[:yawn_add] += 1
			$spam_block_flags[:yawn].clear
		end
	end
	flag = true if $spam_block_flags[:yawn_add] >= 3
	$spam_block_triggered = flag
	next flag
end

#Boss Pokemon
PBAI::SpamHandler.add do |flag,ai,battler,target|
	next flag if $spam_block_triggered
	flag = true if $game_switches[908] && ai.battle.wildBattle?
	$spam_block_triggered = flag
	next flag
end

#===============================
# Spam Block Extenders
#===============================

#Yawn into Protect
PBAI::SpamHandler.add_secondary do |score,ai,battler,target|
	next score if !$spam_block_triggered
	protect_switch = $spam_block_flags[:yawn]
	next score if protect_switch.length < 2
	for i in 1...protect_switch.length
		if (protect_switch[i] == :YAWN && protect_switch[i-1].is_a?(PokeBattle_ProtectMove))
			$spam_block_flags[:yawn_add] += 1
			$spam_block_flags[:yawn] = []
		end
	end
	score += $spam_block_flags[:yawn_add] >= 3 ? 2 : 0
	next score
end

#Switch to Ghost on Fake Out
PBAI::SpamHandler.add_secondary do |score,ai,battler,target|
	if !$spam_block_triggered
		protect_switch = $spam_block_flags[:fake_out_ghost_flag]
		PBAI.log_spam("Switch to Fake Out Immune: #{protect_switch}")
		next score if protect_switch.length < 2
		score += protect_switch.length == 2 ? 1 : 0
	end
	next score
end

#Protect into Switch
PBAI::SpamHandler.add_secondary do |score,ai,battler,target|
	if $spam_block_triggered
		protect_switch = $spam_block_flags[:protect_switch]
		PBAI.log_spam("Protect into Switch: #{protect_switch}")
		next score if protect_switch.length < 2
		for i in 1...protect_switch.length
			if (protect_switch[i] == :Switch && protect_switch[i-1].is_a?(PokeBattle_ProtectMove))
				$spam_block_flags[:protect_switch_add] += 1
				$spam_block_flags[:protect_switch] = []
			end
		end
		score += ($spam_block_flags[:protect_switch_add] >= 3) ? 2 : 0
	end
	next score
end

#Double Stat Drop
PBAI::SpamHandler.add_secondary do |score,ai,battler,target|
	if $spam_block_triggered
		double_stat = $spam_block_flags[:double_intimidate]
		PBAI.log_spam("Double Intimidate: #{double_stat}")
		next score if double_stat.length < 2
		check = 0
		for i in double_stat
			check += 1 if [:INTIMIDATE,:MEDUSOID,:MINDGAMES].include?(i)
			check = 0 if ![:INTIMIDATE,:MEDUSOID,:MINDGAMES].include?(i)
			$spam_block_flags[:double_intimidate] = [] if check == 0
			$spam_block_flags[:choice] = nil if check == 0
		end
		if check == 2
			score += 1
			$spam_block_flags[:double_intimidate] = []
		end
	end
	next score
end

#Triple Switch
PBAI::SpamHandler.add_secondary do |score,ai,battler,target|
  if $spam_block_triggered
		triple_switch = $spam_block_flags[:triple_switch]
		PBAI.log_spam("Triple Switch: #{triple_switch}")
		next score if triple_switch.length < 3
		check = 0
		for i in triple_switch
			check += 1 if !i.nil?
			check = 0 if i.nil?
			$spam_block_flags[:triple_switch] = [] if check == 0
			$spam_block_flags[:choice] = nil if check == 0
		end
		if check == 3
			score += 1
			$spam_block_flags[:triple_switch] = []
		end
	end
	next score
end

#Same Move 3x
PBAI::SpamHandler.add_secondary do |score,ai,battler,target|
  if $spam_block_triggered
		next score if $spam_block_flags[:choiced_flag].include?(target)
		same_move = $spam_block_flags[:same_move]
		PBAI.log_spam("Triple Move: #{same_move}")
		next score if same_move.length < 3
		check = 0
		for i in 1...same_move.length
			check += 1 if same_move[i] == same_move[i-1]
			check = 0 if same_move[i] != same_move[i-1]
			$spam_block_flags[:same_move] = [] if check == 0
			$spam_block_flags[:choice] = nil if check == 0
		end
		if check == 2
			score += 3
			$spam_block_flags[:same_move] = []
		end
	end
	next score
end