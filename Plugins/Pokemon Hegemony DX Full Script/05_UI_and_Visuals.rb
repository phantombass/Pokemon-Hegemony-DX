
class PokemonSave_Scene
  def pbStartScreen
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    mapname=$game_map.name
    textColor = ["7FE00000","463F0000","7FE00000"][$Trainer.gender]
    locationColor = "90F090,000000"   # green
    loctext=_INTL("<ac><c3={1}>{2}</c3></ac>",locationColor,mapname)
    loctext+=_INTL("Player<r><c2={1}>{2}</c2><br>",textColor,$Trainer.name)
    if hour>0
      loctext+=_INTL("Time<r><c2={1}>{2}h {3}m</c2><br>",textColor,hour,min)
    else
      loctext+=_INTL("Time<r><c2={1}>{2}m</c2><br>",textColor,min)
    end
    loctext+=_INTL("Badges<r><c2={1}>{2}</c2><br>",textColor,$Trainer.badge_count)
    if $Trainer.has_pokedex
      loctext+=_INTL("Pokédex<r><c2={1}>{2}/{3}</c2><br>",textColor,$Trainer.pokedex.owned_count,$Trainer.pokedex.seen_count)
    end
    @sprites["locwindow"]=Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport=@viewport
    @sprites["locwindow"].x=0
    @sprites["locwindow"].y=0
    @sprites["locwindow"].width=228 if @sprites["locwindow"].width<228
    @sprites["locwindow"].visible=true
  end
end

class PokemonPauseMenu_Scene
  def pbStartScene
    if $game_switches[350] == false
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      capColor = "90F090,000000"
      levelCap = LEVEL_CAP[$game_system.level_cap]
      quest_stage = $PokemonGlobal.quests.active_quests[0].stage
      quest_info = $quest_data.getStageDescription(:Quest1,quest_stage)
      @sprites = {}
      @sprites["cmdwindow"] = Window_CommandPokemon.new([])
      @sprites["cmdwindow"].visible = false
      @sprites["cmdwindow"].viewport = @viewport
      @sprites["infowindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
      @sprites["infowindow"].visible = false
      @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
      @sprites["helpwindow"].visible = false
      if $game_switches[Settings::LEVEL_CAP_SWITCH] == true
        @sprites["levelcapwindow"] =Window_UnformattedTextPokemon.newWithSize("Level Cap: #{levelCap}",0,64,208,64,@viewport)
        @sprites["levelcapwindow"].visible = true
      end
      @sprites["questwindow"] = Window_UnformattedTextPokemon.newWithSize("#{quest_info}",0,208,306,222,@viewport)
      pbSetSmallFont(@sprites["questwindow"].contents)
      @sprites["questwindow"].resizeToFit("#{quest_info}",306)
      @sprites["questwindow"].visible = true
      @infostate = false
      @helpstate = false
      $close_dexnav = 0
      $viewport4 = @viewport
      pbSEPlay("GUI menu open")
    else
      $viewport1.dispose
      $currentDexSearch = nil
      $close_dexnav = 1
      $game_switches[350] = false
      pbSEPlay("GUI menu close")
      return
    end
  end

  def pbShowInfo(text)
    @sprites["infowindow"].resizeToFit(text,Graphics.height)
    @sprites["infowindow"].text    = text
    @sprites["infowindow"].visible = true
    @infostate = true
  end

  def pbShowHelp(text)
    @sprites["helpwindow"].resizeToFit(text,Graphics.height)
    @sprites["helpwindow"].text    = text
    @sprites["helpwindow"].visible = true
    pbBottomLeft(@sprites["helpwindow"])
    @helpstate = true
  end

  def pbShowMenu
    @sprites["cmdwindow"].visible = true
    @sprites["infowindow"].visible = @infostate
    @sprites["helpwindow"].visible = @helpstate
  end

  def pbHideMenu
    @sprites["cmdwindow"].visible = false
    @sprites["infowindow"].visible = false
    @sprites["helpwindow"].visible = false
  end

  def pbShowLevelCap
    @sprites["levelcapwindow"].visible = true
    @sprites["questwindow"].visible = true
  end

  def pbHideLevelCap
    @sprites["levelcapwindow"].visible = false if $game_switches[Settings::LEVEL_CAP_SWITCH] == true
    @sprites["questwindow"].visible = false
  end

  def pbShowCommands(commands)
    if $game_switches[350] == false && $close_dexnav < 1
      ret = -1
      cmdwindow = @sprites["cmdwindow"]
      cmdwindow.commands = commands
      cmdwindow.index    = $PokemonTemp.menuLastChoice
      cmdwindow.resizeToFit(commands)
      cmdwindow.x        = Graphics.width-cmdwindow.width
      cmdwindow.y        = 0
      cmdwindow.visible  = true
      loop do
        cmdwindow.update
        Graphics.update
        Input.update
        pbUpdateSceneMap
        if Input.trigger?(Input::BACK)
          ret = -1
          break
        elsif Input.trigger?(Input::USE)
          ret = cmdwindow.index
          $PokemonTemp.menuLastChoice = ret
          break
        end
      end
    else
      ret = -1
    end
    $close_dexnav -= 1
    return ret
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbRefresh; end
end

class PokemonStorageScreen
  def pbStore(selected,heldpoke)
    box = selected[0]
    index = selected[1]
    if box!=-1
      raise _INTL("Can't deposit from box...")
    end
    if pbAbleCount<=1 && pbAble?(@storage[box,index]) && !heldpoke
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
    elsif heldpoke && heldpoke.mail
      pbDisplay(_INTL("Please remove the Mail."))
    elsif !heldpoke && @storage[box,index].mail
      pbDisplay(_INTL("Please remove the Mail."))
    else
      loop do
        destbox = @scene.pbChooseBox(_INTL("Deposit in which Box?"))
        if destbox>=0
          firstfree = @storage.pbFirstFreePos(destbox)
          if firstfree<0
            pbDisplay(_INTL("The Box is full."))
            next
          end
          if heldpoke || selected[0]==-1
            p = (heldpoke) ? heldpoke : @storage[-1,index]
            p.time_form_set = nil
            p.form          = 0 if p.isSpecies?(:SHAYMIN)
            p.heal if $game_switches[73] == false
          end
          @scene.pbStore(selected,heldpoke,destbox,firstfree)
          if heldpoke
            @storage.pbMoveCaughtToBox(heldpoke,destbox)
            @heldpkmn = nil
          else
            @storage.pbMove(destbox,-1,-1,index)
          end
        end
        break
      end
      @scene.pbRefresh
    end
  end

  def pbHold(selected)
    box = selected[0]
    index = selected[1]
    if box==-1 && pbAble?(@storage[box,index]) && pbAbleCount<=1
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return
    end
    @scene.pbHold(selected)
    @heldpkmn = @storage[box,index]
    @storage.pbDelete(box,index)
    @scene.pbRefresh
  end

  def pbPlace(selected)
    box = selected[0]
    index = selected[1]
    if @storage[box,index]
      raise _INTL("Position {1},{2} is not empty...",box,index)
    end
    if box!=-1 && index>=@storage.maxPokemon(box)
      pbDisplay("Can't place that there.")
      return
    end
    if box!=-1 && @heldpkmn.mail
      pbDisplay("Please remove the mail.")
      return
    end
    if box>=0
      @heldpkmn.time_form_set = nil
      @heldpkmn.form          = 0 if @heldpkmn.isSpecies?(:SHAYMIN)
      @heldpkmn.heal if $game_switches[73] == false
    end
    @scene.pbPlace(selected,@heldpkmn)
    @storage[box,index] = @heldpkmn
    if box==-1
      @storage.party.compact!
    end
    @scene.pbRefresh
    @heldpkmn = nil
  end

  def pbSwap(selected)
    box = selected[0]
    index = selected[1]
    if !@storage[box,index]
      raise _INTL("Position {1},{2} is empty...",box,index)
    end
    if box==-1 && pbAble?(@storage[box,index]) && pbAbleCount<=1 && !pbAble?(@heldpkmn)
      pbPlayBuzzerSE
      pbDisplay(_INTL("That's your last Pokémon!"))
      return false
    end
    if box!=-1 && @heldpkmn.mail
      pbDisplay("Please remove the mail.")
      return false
    end
    if box>=0
      @heldpkmn.time_form_set = nil
      @heldpkmn.form          = 0 if @heldpkmn.isSpecies?(:SHAYMIN)
      @heldpkmn.heal if $game_switches[73] == false
    end
    @scene.pbSwap(selected,@heldpkmn)
    tmp = @storage[box,index]
    @storage[box,index] = @heldpkmn
    @heldpkmn = tmp
    @scene.pbRefresh
    return true
  end
end

class PokemonPauseMenu
  def initialize(scene)
    @scene = scene
  end

  def pbShowMenu
    @scene.pbRefresh
    @scene.pbShowMenu
    @scene.pbShowLevelCap if $game_switches[Settings::LEVEL_CAP_SWITCH] == true
  end

  def pbStartPokemonMenu
    if !$Trainer
      if $DEBUG
        pbMessage(_INTL("The player trainer was not defined, so the pause menu can't be displayed."))
        pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
      end
      return
    end
    @scene.pbStartScene
    endscene = true
    commands = []
    cmdPokedex  = -1
    cmdPokemon  = -1
    cmdBag      = -1
    cmdQuest    = -1
    cmdTrainer  = -1
    cmdSave     = -1
    cmdOption   = -1
    cmdPokegear = -1
    cmdPC = -1
    cmdDexnav = -1
    cmdDebug    = -1
    cmdQuit     = -1
    cmdEndGame  = -1
    if $Trainer.has_pokedex && $Trainer.pokedex.accessible_dexes.length > 0
      commands[cmdPokedex = commands.length] = _INTL("Pokédex")
    end
    commands[cmdPokemon = commands.length]   = _INTL("Pokémon") if $Trainer.party_count > 0
    commands[cmdBag = commands.length]       = _INTL("Bag") if !pbInBugContest?
    commands[cmdPokegear = commands.length]  = _INTL("Pokégear") if $Trainer.has_pokegear
    commands[cmdDexnav = commands.length]  = _INTL("DexNav") if $game_switches[401]
    commands[cmdPC = commands.length]  = _INTL("PC Box Link") if $Trainer.party_count > 0 && $game_switches[LvlCap::Ironmon] == false
    commands[cmdQuest = commands.length] = _INTL("Quest Log")
    commands[cmdTrainer = commands.length]   = $Trainer.name
    if pbInSafari?
      if Settings::SAFARI_STEPS <= 0
        @scene.pbShowInfo(_INTL("Balls: {1}",pbSafariState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Steps: {1}/{2}\nBalls: {3}",
           pbSafariState.steps, Settings::SAFARI_STEPS, pbSafariState.ballcount))
      end
      commands[cmdQuit = commands.length]    = _INTL("Quit")
    elsif pbInBugContest?
      if pbBugContestState.lastPokemon
        @scene.pbShowInfo(_INTL("Caught: {1}\nLevel: {2}\nBalls: {3}",
           pbBugContestState.lastPokemon.speciesName,
           pbBugContestState.lastPokemon.level,
           pbBugContestState.ballcount))
      else
        @scene.pbShowInfo(_INTL("Caught: None\nBalls: {1}",pbBugContestState.ballcount))
      end
      commands[cmdQuit = commands.length]    = _INTL("Quit Contest")
    else
      commands[cmdSave = commands.length]    = _INTL("Save") if $game_system && !$game_system.save_disabled
    end
    commands[cmdOption = commands.length]    = _INTL("Options")
    commands[cmdDebug = commands.length]     = _INTL("Debug") if $DEBUG
    commands[cmdEndGame = commands.length]   = _INTL("Quit Game")
    loop do
      if !$currentDexSearch
        command = @scene.pbShowCommands(commands)
      else
        command = -1
      end
      if cmdPokedex>=0 && command==cmdPokedex
        pbPlayDecisionSE
        if Settings::USE_CURRENT_REGION_DEX
          pbFadeOutIn {
            scene = PokemonPokedex_Scene.new
            screen = PokemonPokedexScreen.new(scene)
            screen.pbStartScreen
            @scene.pbRefresh
          }
        else
          if $Trainer.pokedex.accessible_dexes.length == 1
            $PokemonGlobal.pokedexDex = $Trainer.pokedex.accessible_dexes[0]
            pbFadeOutIn {
              scene = PokemonPokedex_Scene.new
              screen = PokemonPokedexScreen.new(scene)
              screen.pbStartScreen
              @scene.pbRefresh
            }
          else
            pbFadeOutIn {
              scene = PokemonPokedexMenu_Scene.new
              screen = PokemonPokedexMenuScreen.new(scene)
              screen.pbStartScreen
              @scene.pbRefresh
            }
          end
        end
      elsif cmdPokemon>=0 && command==cmdPokemon
        pbPlayDecisionSE
        hiddenmove = nil
        pbFadeOutIn {
          sscene = PokemonParty_Scene.new
          sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
          hiddenmove = sscreen.pbPokemonScreen
          (hiddenmove) ? @scene.pbEndScene : @scene.pbRefresh
        }
        if hiddenmove
          $game_temp.in_menu = false
          pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
          return
        end
      elsif cmdBag>=0 && command==cmdBag
        pbPlayDecisionSE
        item = nil
        pbFadeOutIn {
          scene = PokemonBag_Scene.new
          screen = PokemonBagScreen.new(scene,$PokemonBag)
          item = screen.pbStartScreen
          (item) ? @scene.pbEndScene : @scene.pbRefresh
        }
        if item
          $game_temp.in_menu = false
          pbUseKeyItemInField(item)
          return
        end
      elsif cmdPokegear>=0 && command==cmdPokegear
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonPokegear_Scene.new
          screen = PokemonPokegearScreen.new(scene)
          screen.pbStartScreen
          @scene.pbRefresh
        }
      elsif cmdPC>=0 && command==cmdPC
        pbPlayDecisionSE
        @scene.pbHideMenu
        @scene.pbHideLevelCap
        pbMessage("Which would you like to do?\\ch[34,4,Access PC,Heal,Cancel]")
        if $game_variables[34] == 0
         if $game_switches[209] == true
           pbMessage(_INTL("You cannot access the PC in here."))
           pbShowMenu
         else
          pbFadeOutIn {
            scene = PokemonStorageScene.new
            screen = PokemonStorageScreen.new(scene,$PokemonStorage)
            screen.pbStartScreen(0)
            pbShowMenu
          }
         end
        elsif $game_variables[34] == 1
          if ($game_switches[209] == true && $game_switches[902] == true) || ($game_switches[209] == true && $game_switches[197] == true)
            pbMessage(_INTL("You cannot use this in here."))
            pbShowMenu
          else
            $Trainer.heal_party
            pbMessage(_INTL("Your party was healed!"))
            pbShowMenu
          end
        else
          pbShowMenu
        end
      elsif cmdDexnav>=0 && command==cmdDexnav
        pbPlayDecisionSE
        $viewport4.dispose
        pbFadeOutIn {
          if $currentDexSearch != nil && $currentDexSearch.is_a?(Array)
            pbMessage(_INTL("<c2=7FE00000>You are already searching!</c2>"))
            pbMessage(_INTL("<c2=7FE00000>Leave the route and return to search again!</c2>"))
            pbShowMenu
          else
            @scene = NewDexNav.new
          end
          return
        }
      elsif cmdQuest>=0 && command==cmdQuest
        pbPlayDecisionSE
        pbFadeOutIn {
          pbViewQuests
          @scene.pbRefresh
        }
      elsif cmdTrainer>=0 && command==cmdTrainer
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonTrainerCard_Scene.new
          screen = PokemonTrainerCardScreen.new(scene)
          screen.pbStartScreen
          @scene.pbRefresh
        }
      elsif cmdQuit>=0 && command==cmdQuit
        @scene.pbHideMenu
        if pbInSafari?
          if pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
            @scene.pbEndScene
            pbSafariState.decision = 1
            pbSafariState.pbGoToStart
            return
          else
            pbShowMenu
          end
        else
          if pbConfirmMessage(_INTL("Would you like to end the Contest now?"))
            @scene.pbEndScene
            pbBugContestState.pbStartJudging
            return
          else
            pbShowMenu
          end
        end
      elsif cmdSave>=0 && command==cmdSave
        @scene.pbHideMenu
        @scene.pbHideLevelCap
        scene = PokemonSave_Scene.new
        screen = PokemonSaveScreen.new(scene)
        if screen.pbSaveScreen
          @scene.pbEndScene
          endscene = false
          break
        else
          pbShowMenu
          @scene.pbShowLevelCap if $game_switches[Settings::LEVEL_CAP_SWITCH] == true
        end
      elsif cmdOption>=0 && command==cmdOption
        pbPlayDecisionSE
        pbFadeOutIn {
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
          pbUpdateSceneMap
          @scene.pbRefresh
        }
      elsif cmdDebug>=0 && command==cmdDebug
        pbPlayDecisionSE
        pbFadeOutIn {
          pbDebugMenu
          @scene.pbRefresh
        }
      elsif cmdEndGame>=0 && command==cmdEndGame
        @scene.pbHideMenu
        if pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
          scene = PokemonSave_Scene.new
          screen = PokemonSaveScreen.new(scene)
          if screen.pbSaveScreen
            @scene.pbEndScene
          end
          @scene.pbEndScene
          $scene = nil
          return
        else
          pbShowMenu
        end
      else
        pbPlayCloseMenuSE
        break
      end
    end
    if $close_dexnav != 0
      @scene.pbEndScene if endscene
    end
  end
end

class PokemonSummary_Scene
  def change_Stats
    @sprites["nav"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    @sprites["nav"].x = 200
    @sprites["nav"].y = 74
    @sprites["nav"].visible
    @sprites["nav"].play
    commands = []
    cmdHP = -1
    cmdAtk = -1
    cmdDef = -1
    cmdSpA = -1
    cmdSpD = -1
    cmdSpe = -1
    stat_choice = 0
    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      if Input.trigger?(Input::DOWN)
        if stat_choice == 0
          @sprites["nav"].y += 47
          stat_choice += 1
        elsif stat_choice > 0 && stat_choice < 5
          stat_choice += 1
          @sprites["nav"].y += 32
        elsif stat_choice == 5
          stat_choice -= 5
          @sprites["nav"].y -= 175
        end
      elsif Input.trigger?(Input::UP)
        if stat_choice == 0
          @sprites["nav"].y += 175
          stat_choice += 5
        elsif stat_choice > 1 && stat_choice != 0
          stat_choice -= 1
          @sprites["nav"].y -= 32
        elsif stat_choice == 1
          stat_choice -= 1
          @sprites["nav"].y -= 47
        end
      elsif Input.trigger?(Input::C)
        @scene.pbMessage(_INTL("Change which?\\ch[34,3,EVs,IVs,Cancel]"))
        stat = $game_variables[34]
        stats = [:HP,:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
        pkmn = @pokemon
        if stat == -1 || stat == 3 || stat == 2
          @sprites["nav"].visible = false
          pbPlayCloseMenuSE
          break
        end
        if stat == 0
          @scene.pbMessage(_INTL("How?\\ch[34,4,Max EVs,Clear EVs,Change EVs...,Cancel]"))
          stat_ev = $game_variables[34]
          if stat_ev == -1 || stat_ev == 4 || stat_ev == 3
            @sprites["nav"].visible = false
            pbPlayCloseMenuSE
            break
          end
          if stat_ev == 0
            upperLimit = 0
            GameData::Stat.each_main { |s| upperLimit += pkmn.ev[s.id] if s.id != stats[stat_choice] }
            upperLimit = Pokemon::EV_LIMIT - upperLimit
            upperLimit = [upperLimit, Pokemon::EV_STAT_LIMIT].min
            pkmn.ev[stats[stat_choice]] = upperLimit
            pkmn.calc_stats
            dorefresh = true
          elsif stat_ev == 1
            pkmn.ev[stats[stat_choice]] = 0
            pkmn.calc_stats
            dorefresh = true
          elsif stat_ev == 2
            params = ChooseNumberParams.new
            upperLimit = 0
            GameData::Stat.each_main { |s| upperLimit += pkmn.ev[s.id] if s.id != stats[stat_choice] }
            upperLimit = Pokemon::EV_LIMIT - upperLimit
            upperLimit = [upperLimit, Pokemon::EV_STAT_LIMIT].min
            thisValue = [pkmn.ev[stats[stat_choice]], upperLimit].min
            params.setRange(0, upperLimit)
            params.setDefaultValue(thisValue)
            params.setCancelValue(pkmn.ev[stats[stat_choice]])
            f = pbMessageChooseNumber(_INTL("Set the EV for {1} (max. {2}).",
               GameData::Stat.get(stats[stat_choice]).name, upperLimit), params) { pbUpdate }
            if f != pkmn.ev[stats[stat_choice]]
              pkmn.ev[stats[stat_choice]] = f
              pkmn.calc_stats
              dorefresh = true
            end
          end
        end
        if stat == 1
          @scene.pbMessage(_INTL("How?\\ch[34,4,Max IVs,Min IVs,Cancel]"))
          stat_iv = $game_variables[34]
          if stat_iv == -1 || stat_iv == 3 || stat_iv == 2
            @sprites["nav"].visible = false
            pbPlayCloseMenuSE
            break
          end
          if stat_iv == 0
            pkmn.iv[stats[stat_choice]] = 31
            pkmn.calc_stats
            dorefresh = true
          elsif stat_iv == 1
            pkmn.iv[stats[stat_choice]] = 0
            pkmn.calc_stats
            dorefresh = true
          else
            break
          end
        end
      elsif Input.trigger?(Input::B)
        @sprites["nav"].visible = false
        pbPlayCloseMenuSE
        break
      end
      if dorefresh
        drawPage(@page)
      end
    end
  end

  def change_Nature
    commands = []
    ids = []
    pkmn = @pokemon
    GameData::Nature.each do |nature|
      if nature.stat_changes.length == 0
        commands.push(_INTL("{1} (---)", nature.real_name))
      else
        plus_text = ""
        minus_text = ""
        nature.stat_changes.each do |change|
          if change[1] > 0
            plus_text += "/" if !plus_text.empty?
            plus_text += GameData::Stat.get(change[0]).name_brief
          elsif change[1] < 0
            minus_text += "/" if !minus_text.empty?
            minus_text += GameData::Stat.get(change[0]).name_brief
          end
        end
        commands.push(_INTL("{1} (+{2}, -{3})", nature.real_name, plus_text, minus_text))
      end
      ids.push(nature.id)
    end
    cmd = ids.index(pkmn.nature_id || ids[0])
    loop do
      msg = _INTL("Nature is {1}.", pkmn.nature.name)
      cmd = pbShowCommands(commands, cmd)
      break if cmd < 0
      if cmd >= 0 && cmd < commands.length - 1   # Set nature
        pkmn.nature = ids[cmd]
        dorefresh = true
      end
      if dorefresh
        drawPage(@page)
        break
      end
    end
  end

  def change_Ability
    commands = []
    ids = []
    pkmn = @pokemon
    if EliteBattle.get(:randomizer)
      spec_num = GameData::Species.get(pkmn.species).id_number
      array = $game_variables[969]
      ability = array[:abilities][spec_num - 1]
      habil = ability[2]
    end
    loop do
      abils = pkmn.getAbilityList
      ability_commands = []
      abil_cmd = 0
      for i in abils
        ability_commands.push(((i[1] < 2) ? "" : "(H) ") + GameData::Ability.get(i[0]).name)
        abil_cmd = ability_commands.length - 1 if pkmn.ability_id == i[0]
      end
      abil_cmd = pbShowCommands(ability_commands, abil_cmd)
      next if abil_cmd < 0
      pkmn.ability_index = abils[abil_cmd][1]
      pkmn.ability = nil
      dorefresh = true
      if dorefresh
        drawPage(@page)
        break
      end
    end
  end

  def change_Level
    pkmn = @pokemon
    if pkmn.egg?
      pbMessage(_INTL("{1} is an egg.", pkmn.name))
    elsif pkmn.fainted?
      pbMessage(_INTL("This Pokémon can no longer be used in the Nuzlocke."))
    else
      @scene.pbMessage(_INTL("How would you like to Level Up?\\ch[34,5,To Level Cap,Change Level...,Cancel]"))
      lvl = $game_variables[34]
      if lvl == -1 || lvl == 2 || lvl == 3
        pbPlayCloseMenuSE
        dorefresh = true
      end
      case lvl
      when 0
        pkmn.level = LEVEL_CAP[$game_system.level_cap]
        pkmn.calc_stats
        dorefresh = true
      when 1
        params = ChooseNumberParams.new
        params.setRange(1, LEVEL_CAP[$game_system.level_cap])
        params.setDefaultValue(pkmn.level)
        level = pbMessageChooseNumber(
           _INTL("Set the Pokémon's level (max. {1}).", params.maxNumber), params) { pbUpdate }
        if level != pkmn.level
          pkmn.level = level
          pkmn.calc_stats
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
  end

  def drawPage(page)
    if @pokemon.egg?
      drawPageOneEgg
      return
    end
    @sprites["itemicon"].item = @pokemon.item_id
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_#{page}")
    imagepos=[]
    # Show the Poké Ball containing the Pokémon
    ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%s", @pokemon.poke_ball)
    if !pbResolveBitmap(ballimage)
      ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%02d", pbGetBallType(@pokemon.poke_ball))
    end
    imagepos.push([ballimage,14,60])
    # Show status/fainted/Pokérus infected icon
    status = 0
    if @pokemon.fainted?
      status = GameData::Status::DATA.keys.length / 2
    elsif @pokemon.status != :NONE
      status = GameData::Status.get(@pokemon.status).id_number
    elsif @pokemon.pokerusStage == 1
      status = GameData::Status::DATA.keys.length / 2 + 1
    end
    status -= 1
    if status >= 0
      imagepos.push(["Graphics/Pictures/statuses",124,100,0,16*status,44,16])
    end
    # Show Pokérus cured icon
    if @pokemon.pokerusStage==2
      imagepos.push([sprintf("Graphics/Pictures/Summary/icon_pokerus"),176,100])
    end
    # Show shininess star
    if @pokemon.shiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,134])
    end
    # Draw all images
    pbDrawImagePositions(overlay,imagepos)
    # Write various bits of text
    pagename = [_INTL("INFO"),
                _INTL("TRAINER MEMO"),
                _INTL("SKILLS"),
                _INTL("EVs/IVs"),
                _INTL("MOVES")][page-1]
    textpos = [
       [pagename,26,10,0,base,shadow],
       [@pokemon.name,46,56,0,base,shadow],
       [@pokemon.level.to_s,46,86,0,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Item"),66,312,0,base,shadow]
    ]
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([@pokemon.item.name,16,346,0,Color.new(64,64,64),Color.new(176,176,176)])
    else
      textpos.push([_INTL("None"),16,346,0,Color.new(192,200,208),Color.new(208,216,224)])
    end
    # Write the gender symbol
    if @pokemon.male?
      textpos.push([_INTL("♂"),178,56,0,Color.new(24,112,216),Color.new(136,168,208)])
    elsif @pokemon.female?
      textpos.push([_INTL("♀"),178,56,0,Color.new(248,56,32),Color.new(224,152,144)])
    end
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    # Draw the Pokémon's markings
    drawMarkings(overlay,84,292)
    # Draw page-specific information
    case page
    when 1 then drawPageOne
    when 2 then drawPageTwo
    when 3 then drawPageThree
    when 4 then drawPageFour
    when 5 then drawPageFive
    end
  end

  def drawPageFour
   overlay = @sprites["overlay"].bitmap
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    statshadows = {}
    GameData::Stat.each_main { |s| statshadows[s.id] = shadow }
    if !@pokemon.shadowPokemon? || @pokemon.heartStage > 3
      @pokemon.nature_for_stats.stat_changes.each do |change|
        statshadows[change[0]] = Color.new(136,96,72) if change[1] > 0
        statshadows[change[0]] = Color.new(64,120,152) if change[1] < 0
      end
    end
    evtable = Marshal.load(Marshal.dump(@pokemon.ev))
    ivtable = Marshal.load(Marshal.dump(@pokemon.iv))
    evHP = evtable[@pokemon.ev.keys[0]]
    ivHP = ivtable[@pokemon.iv.keys[0]]
    evAt = evtable[@pokemon.ev.keys[1]]
    ivAt = ivtable[@pokemon.iv.keys[1]]
    evDf = evtable[@pokemon.ev.keys[2]]
    ivDf = ivtable[@pokemon.iv.keys[2]]
    evSa = evtable[@pokemon.ev.keys[3]]
    ivSa = ivtable[@pokemon.iv.keys[3]]
    evSd = evtable[@pokemon.ev.keys[4]]
    ivSd = ivtable[@pokemon.iv.keys[4]]
    evSp = evtable[@pokemon.ev.keys[5]]
    ivSp = ivtable[@pokemon.iv.keys[5]]
    textpos = [
       [_INTL("HP"),292,70,2,base,statshadows[:HP]],
       [sprintf("%d/%d",evHP,ivHP),462,70,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Attack"),248,114,0,base,statshadows[:ATTACK]],
       [sprintf("%d/%d",evAt,ivAt),456,114,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Defense"),248,146,0,base,statshadows[:DEFENSE]],
       [sprintf("%d/%d",evDf,ivDf),456,146,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Sp. Atk"),248,178,0,base,statshadows[:SPECIAL_ATTACK]],
       [sprintf("%d/%d",evSa,ivSa),456,178,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Sp. Def"),248,210,0,base,statshadows[:SPECIAL_DEFENSE]],
       [sprintf("%d/%d",evSd,ivSd),456,210,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Speed"),248,242,0,base,statshadows[:SPEED]],
       [sprintf("%d/%d",evSp,ivSp),456,242,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Ability"),224,278,0,base,shadow]
    ]
    ability = @pokemon.ability
    if ability
      textpos.push([ability.name,362,278,0,Color.new(64,64,64),Color.new(176,176,176)])
      drawTextEx(overlay,224,320,282,2,ability.description,Color.new(64,64,64),Color.new(176,176,176))
    end
    pbDrawTextPositions(overlay,textpos)
  end

  def drawPageFive
    overlay = @sprites["overlay"].bitmap
    moveBase   = Color.new(64,64,64)
    moveShadow = Color.new(176,176,176)
    ppBase   = [moveBase,                # More than 1/2 of total PP
                Color.new(248,192,0),    # 1/2 of total PP or less
                Color.new(248,136,32),   # 1/4 of total PP or less
                Color.new(248,72,72)]    # Zero PP
    ppShadow = [moveShadow,             # More than 1/2 of total PP
                Color.new(144,104,0),   # 1/2 of total PP or less
                Color.new(144,72,24),   # 1/4 of total PP or less
                Color.new(136,48,48)]   # Zero PP
    @sprites["pokemon"].visible  = true
    @sprites["pokeicon"].visible = false
    @sprites["itemicon"].visible = true
    textpos  = []
    imagepos = []
    # Write move names, types and PP amounts for each known move
    yPos = 92
    for i in 0...Pokemon::MAX_MOVES
      move=@pokemon.moves[i]
      if move
        type_number = GameData::Type.get(move.type).id_number
        imagepos.push(["Graphics/Pictures/types", 248, yPos + 8, 0, type_number * 28, 64, 28])
        textpos.push([move.name,316,yPos,0,moveBase,moveShadow])
        if move.total_pp>0
          textpos.push([_INTL("PP"),342,yPos+32,0,moveBase,moveShadow])
          ppfraction = 0
          if move.pp==0;                  ppfraction = 3
          elsif move.pp*4<=move.total_pp; ppfraction = 2
          elsif move.pp*2<=move.total_pp; ppfraction = 1
          end
          textpos.push([sprintf("%d/%d",move.pp,move.total_pp),460,yPos+32,1,ppBase[ppfraction],ppShadow[ppfraction]])
        end
      else
        textpos.push(["-",316,yPos,0,moveBase,moveShadow])
        textpos.push(["--",442,yPos+32,1,moveBase,moveShadow])
      end
      yPos += 64
    end
    # Draw all text and images
    pbDrawTextPositions(overlay,textpos)
    pbDrawImagePositions(overlay,imagepos)
  end
  def drawPageFiveSelecting(move_to_learn)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    moveBase   = Color.new(64,64,64)
    moveShadow = Color.new(176,176,176)
    ppBase   = [moveBase,                # More than 1/2 of total PP
                Color.new(248,192,0),    # 1/2 of total PP or less
                Color.new(248,136,32),   # 1/4 of total PP or less
                Color.new(248,72,72)]    # Zero PP
    ppShadow = [moveShadow,             # More than 1/2 of total PP
                Color.new(144,104,0),   # 1/2 of total PP or less
                Color.new(144,72,24),   # 1/4 of total PP or less
                Color.new(136,48,48)]   # Zero PP
    # Set background image
    if move_to_learn
      @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_learnmove")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_movedetail")
    end
    # Write various bits of text
    textpos = [
       [_INTL("MOVES"),26,10,0,base,shadow],
       [_INTL("CATEGORY"),20,116,0,base,shadow],
       [_INTL("POWER"),20,148,0,base,shadow],
       [_INTL("ACCURACY"),20,180,0,base,shadow]
    ]
    imagepos = []
    # Write move names, types and PP amounts for each known move
    yPos = 92
    yPos -= 76 if move_to_learn
    limit = (move_to_learn) ? Pokemon::MAX_MOVES + 1 : Pokemon::MAX_MOVES
    for i in 0...limit
      move = @pokemon.moves[i]
      if i==Pokemon::MAX_MOVES
        move = move_to_learn
        yPos += 20
      end
      if move
        type_number = GameData::Type.get(move.type).id_number
        imagepos.push(["Graphics/Pictures/types", 248, yPos + 8, 0, type_number * 28, 64, 28])
        textpos.push([move.name,316,yPos,0,moveBase,moveShadow])
        if move.total_pp>0
          textpos.push([_INTL("PP"),342,yPos+32,0,moveBase,moveShadow])
          ppfraction = 0
          if move.pp==0;                  ppfraction = 3
          elsif move.pp*4<=move.total_pp; ppfraction = 2
          elsif move.pp*2<=move.total_pp; ppfraction = 1
          end
          textpos.push([sprintf("%d/%d",move.pp,move.total_pp),460,yPos+32,1,ppBase[ppfraction],ppShadow[ppfraction]])
        end
      else
        textpos.push(["-",316,yPos,0,moveBase,moveShadow])
        textpos.push(["--",442,yPos+32,1,moveBase,moveShadow])
      end
      yPos += 64
    end
    # Draw all text and images
    pbDrawTextPositions(overlay,textpos)
    pbDrawImagePositions(overlay,imagepos)
    # Draw Pokémon's type icon(s)
    type1_number = GameData::Type.get(@pokemon.type1).id_number
    type2_number = GameData::Type.get(@pokemon.type2).id_number
    type1rect = Rect.new(0, type1_number * 28, 64, 28)
    type2rect = Rect.new(0, type2_number * 28, 64, 28)
    if @pokemon.type1==@pokemon.type2
      overlay.blt(130,78,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(96,78,@typebitmap.bitmap,type1rect)
      overlay.blt(166,78,@typebitmap.bitmap,type2rect)
    end
  end
  def drawSelectedMove(move_to_learn, selected_move)
    # Draw all of page four, except selected move's details
    drawPageFiveSelecting(move_to_learn)
    # Set various values
    overlay = @sprites["overlay"].bitmap
    base = Color.new(64, 64, 64)
    shadow = Color.new(176, 176, 176)
    @sprites["pokemon"].visible = false if @sprites["pokemon"]
    @sprites["pokeicon"].pokemon = @pokemon
    @sprites["pokeicon"].visible = true
    @sprites["itemicon"].visible = false if @sprites["itemicon"]
    textpos = []
    # Write power and accuracy values for selected move
    case selected_move.base_damage
    when 0 then textpos.push(["---", 216, 148, 1, base, shadow])   # Status move
    when 1 then textpos.push(["???", 216, 148, 1, base, shadow])   # Variable power move
    else        textpos.push([selected_move.base_damage.to_s, 216, 148, 1, base, shadow])
    end
    if selected_move.accuracy == 0
      textpos.push(["---", 216, 180, 1, base, shadow])
    else
      textpos.push(["#{selected_move.accuracy}%", 216 + overlay.text_size("%").width, 180, 1, base, shadow])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw selected move's damage category icon
    imagepos = [["Graphics/Pictures/category", 166, 124, 0, selected_move.category * 28, 64, 28]]
    pbDrawImagePositions(overlay, imagepos)
    # Draw selected move's description
    drawTextEx(overlay, 4, 222, 230, 5, selected_move.description, base, shadow)
  end
  def pbScene
    GameData::Species.play_cry_from_pokemon(@pokemon)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        pbSEStop
        GameData::Species.play_cry_from_pokemon(@pokemon)
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        if @page==5
          pbPlayDecisionSE
          pbMoveSelection
          dorefresh = true
        elsif !@inbattle
          pbPlayDecisionSE
          dorefresh = pbOptions
        end
      elsif Input.trigger?(Input::UP) && @partyindex>0
        oldindex = @partyindex
        pbGoToPrevious
        if @partyindex!=oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN) && @partyindex<@party.length-1
        oldindex = @partyindex
        pbGoToNext
        if @partyindex!=oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
        oldpage = @page
        @page -= 1
        @page = 5 if @page<1
        @page = 1 if @page>5
        if @page!=oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
        oldpage = @page
        @page += 1
        @page = 5 if @page<1
        @page = 1 if @page>5
        if @page!=oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @partyindex
  end
  def pbOptions
    dorefresh = false
    commands   = []
    cmdGiveItem = -1
    cmdTakeItem = -1
    cmdPokedex  = -1
    cmdMinGrind = -1
    cmdMark     = -1
    if !@pokemon.egg?
      commands[cmdGiveItem = commands.length] = _INTL("Give item")
      commands[cmdTakeItem = commands.length] = _INTL("Take item") if @pokemon.hasItem?
      commands[cmdPokedex = commands.length]  = _INTL("View Pokédex") if $Trainer.has_pokedex
      if $game_switches[75]
        commands[cmdMinGrind = commands.length] = _INTL("Minimal Grinding Options...") if @page == 2 || @page == 3 || @page == 4
      end
    end
    commands[cmdMark = commands.length]       = _INTL("Mark")
    commands[commands.length]                 = _INTL("Cancel")
    command = pbShowCommands(commands)
    if cmdGiveItem>=0 && command==cmdGiveItem
      item = nil
      pbFadeOutIn {
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene,$PokemonBag)
        item = screen.pbChooseItemScreen(Proc.new { |itm| GameData::Item.get(itm).can_hold? })
      }
      if item
        dorefresh = pbGiveItemToPokemon(item,@pokemon,self,@partyindex)
      end
    elsif cmdTakeItem>=0 && command==cmdTakeItem
      dorefresh = pbTakeItemFromPokemon(@pokemon,self)
    elsif cmdPokedex>=0 && command==cmdPokedex
      $Trainer.pokedex.register_last_seen(@pokemon)
      pbFadeOutIn {
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbStartSceneSingle(@pokemon.species)
      }
      dorefresh = true
    elsif cmdMinGrind>=0 && command==cmdMinGrind
      min_grind_commands = []
      cmdLevel = -1
      cmdNature = -1
      cmdStatChange = -1
      cmdAbility = -1
      min_grind_commands[cmdLevel = min_grind_commands.length] = _INTL("Set Level") if (@page == 2 || @page == 3 || @page == 4)
      min_grind_commands[cmdNature = min_grind_commands.length] = _INTL("Change Nature") if @page == 2 || @page == 3 || @page == 4
      min_grind_commands[cmdStatChange = min_grind_commands.length] = _INTL("Change EVs/IVs") if @page == 3 || @page == 4
      min_grind_commands[cmdAbility = min_grind_commands.length] = _INTL("Change Ability") if @page == 2 || @page == 3 || @page == 4
      min_command = pbShowCommands(min_grind_commands)
      if cmdLevel>=0 && min_command==cmdLevel
        change_Level
      elsif cmdNature>=0 && min_command==cmdNature
        change_Nature
      elsif cmdStatChange>=0 && min_command==cmdStatChange
        change_Stats
      elsif cmdAbility>=0 && min_command==cmdAbility
        change_Ability
      end
    elsif cmdMark>=0 && command==cmdMark
      dorefresh = pbMarking(@pokemon)
    end
    return dorefresh
  end
end
class BattleSceneRoom
  alias initialize_ter initialize
  def initialize(viewport, scene, data)
    $viewport = viewport
    return initialize_ter(viewport, scene, data)
  end
  def refresh(*args)
    unless args[0].is_a?(Hash)
      @sprites[args[0]] = args[1] if args[0].is_a?(String) && args.length > 1
      return
    end
    @fpIndex = 0
    # disposes sprites if they exist
    pbDisposeSpriteHash(@sprites)
    sx, sy = @scene.vector.spoof(@defaultvector)
    # void sprite
    @sprites["void"] = Sprite.new(@viewport)
    @sprites["void"].z = -10
    @sprites["void"].bitmap = Bitmap.new(@viewport.width, @viewport.height)
    # draws backdrop
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].z = 0
    # draws base
    @baseBmp = nil
    # draws elements from data block (prority added to predefined modules)
    for key in ["backdrop", "base", "water", "spinningLights", "outdoor", "sky", "trees", "tallGrass", "spinLights",
               "lightsA", "lightsB", "lightsC", "vacuum", "bubbles"] # to sort the order
      next if !@data.has_key?(key)
      case key
      when "backdrop" # adds custom background image
        path = pbResolveBitmap(@data["backdrop"]) ? @data["backdrop"] : "Graphics/EBDX/Battlebacks/battlebg/" + @data["backdrop"]
        $initPath = path
        tbmp = pbBitmap(path)
        @sprites["bg"].bitmap = Bitmap.new(tbmp.width, tbmp.height)
        @sprites["bg"].bitmap.blt(0, 0, tbmp, tbmp.rect)
        tbmp.dispose
      when "base" # blt base onto backdrop
        str = pbResolveBitmap(@data["base"]) ? @data["base"] : "Graphics/EBDX/Battlebacks/base/" + @data["base"]
        @baseBmp = pbBitmap(str) if str
      when "sky" # adds dynamic sky to scene
        self.drawSky
      when "trees" # adds array of trees to scene
        self.drawTrees
      when "tallGrass" # adds array of tall grass to scene
        self.drawGrass
      when "spinLights" # adds PWT styled spinning base lights
        self.drawSpinLights
      when "lightsA" # adds PWT styled stage lights
        self.drawLightsA
      when "lightsB" # adds disco styled stage lights
        self.drawLightsB
      when "lightsC" # adds ambiental scene lights
        self.drawLightsC
      when "water" # adds water animation effect
        self.drawWater
      when "vacuum"
        self.vacuumWaves(@data[key]) # draws vacuum waves
      when "bubbles"
        self.bubbleStream(@data[key]) # draws bubble particles
      end
    end
    # draws additional modules where sequencing is disregarded
    for key in @data.keys
      if key.include?("img")
        self.drawImg(key)
      end
    end
    # applies backdrop positioning
    if @sprites["bg"].bitmap
      @sprites["bg"].center!
      @sprites["bg"].ox = sx/1.5 - 16
      @sprites["bg"].oy = sy/1.5 + 16
      if @baseBmp
        @sprites["bg"].bitmap.blt(0, @sprites["bg"].bitmap.height - @baseBmp.height, @baseBmp, @baseBmp.rect)
      end
      c1 = @sprites["bg"].bitmap.get_pixel(0, 0)
      c2 = @sprites["bg"].bitmap.get_pixel(0, @sprites["bg"].bitmap.height-1)
      @sprites["void"].bitmap.fill_rect(0, 0, @viewport.width, @viewport.height/2, c1)
      @sprites["void"].bitmap.fill_rect(0, @viewport.height/2, @viewport.width, @viewport.height/2, c2)
    end
    # battler sprite positioning
    self.adjustMetrics
    # applies daylight tinting
    self.daylightTint
  end
  def update
    return if self.disposed?
    # updates to the spatial warping with respect to the scene vector
    @sprites["bg"].x = @scene.vector.x2
    @sprites["bg"].y = @scene.vector.y2
    sx, sy = @scene.vector.spoof(@defaultvector)
    @sprites["bg"].zoom_x = @scale*((@scene.vector.x2 - @scene.vector.x)*1.0/(sx - @defaultvector[0])*1.0)**0.6
    @sprites["bg"].zoom_y = @scale*((@scene.vector.y2 - @scene.vector.y)*1.0/(sy - @defaultvector[1])*1.0)**0.6
    # updates the vacuum waves
    for j in 0...3
      next if j > @fpIndex/50 || !@sprites["ec#{j}"]
      if @sprites["ec#{j}"].param <= 0
        @sprites["ec#{j}"].param = 1.5
        @sprites["ec#{j}"].opacity = 0
        @sprites["ec#{j}"].ex = 234
      end
      @sprites["ec#{j}"].opacity += (@sprites["ec#{j}"].param < 0.75 ? -4 : 4)/self.delta
      @sprites["ec#{j}"].ex += [1, 2/self.delta].max if (@fpIndex*self.delta)%4 == 0 && @sprites["ec#{j}"].ex < 284
      @sprites["ec#{j}"].ey -= [1, 2/self.delta].min if (@fpIndex*self.delta)%4 == 0 && @sprites["ec#{j}"].ey > 108
      @sprites["ec#{j}"].param -= 0.01/self.delta
    end
    # updates bubble particles
    for j in 0...18
      next if !@sprites["bubble#{j}"]
      if @sprites["bubble#{j}"].ey <= -32
        r = rand(5) + 2
        @sprites["bubble#{j}"].param = 0.16 + 0.01*rand(32)
        @sprites["bubble#{j}"].ey = @sprites["bg"].bitmap.height*0.25 + rand(@sprites["bg"].bitmap.height*0.75)
        @sprites["bubble#{j}"].ex = 32 + rand(@sprites["bg"].bitmap.width - 64)
        @sprites["bubble#{j}"].end_y = 64 + rand(72)
        @sprites["bubble#{j}"].end_x = @sprites["bubble#{j}"].ex
        @sprites["bubble#{j}"].toggle = rand(2) == 0 ? 1 : -1
        @sprites["bubble#{j}"].speed = 1 + 2/((r + 1)*0.4)
        @sprites["bubble#{j}"].z = [2,15,25][rand(3)] + rand(6) - (@focused ? 0 : 100)
        @sprites["bubble#{j}"].opacity = 0
      end
      min = @sprites["bg"].bitmap.height/4
      max = @sprites["bg"].bitmap.height/2
      scale = (2*Math::PI)/((@sprites["bubble#{j}"].bitmap.width/64.0)*(max - min) + min)
      @sprites["bubble#{j}"].opacity += 4 if @sprites["bubble#{j}"].opacity < @sprites["bubble#{j}"].end_y
      @sprites["bubble#{j}"].ey -= [1, @sprites["bubble#{j}"].speed/self.delta].max
      @sprites["bubble#{j}"].ex = @sprites["bubble#{j}"].end_x + @sprites["bubble#{j}"].bitmap.width*0.25*Math.sin(@sprites["bubble#{j}"].ey*scale)*@sprites["bubble#{j}"].toggle
    end
    # update weather particles
    self.updateWeather
    self.updateTerrain
    # positions all elements according to the battle backdrop
    self.position
    # updates skyline
    self.updateSky
    # turn off shadows if appropriate
    if @data.has_key?("noshadow") && @data["noshadow"] == true
      # for battler sprites
      @battle.battlers.each_with_index do |b, i|
        next if !b || !@scene.sprites["pokemon_#{i}"]
        @scene.sprites["pokemon_#{i}"].noshadow = true
      end
      # for trainer sprites
      if @battle.opponent
        for t in 0...@battle.opponent.length
          next if !@scene.sprites["trainer_#{t}"]
          @scene.sprites["trainer_#{t}"].noshadow = true
        end
      end
    end
    # adjusts for wind affected elements
    if @strongwind
      @wind -= @toggle*2
      @toggle *= -1 if @wind < 65 || (@wind >= 70 && @toggle < 0)
    else
      @wWait += 1
      if @wWait > Graphics.frame_rate*5
        mod = @toggle*(2 + (@wind >= 88 && @wind <= 92 ? 2 : 0))
        @wind -= mod
        @toggle *= -1 if @wind <= 80 || @wind >= 100
        @wWait = 0 if @wWait > Graphics.frame_rate*5 + 33
      end
    end
    # additional metrics
    @fpIndex += 1
    @fpIndex = 150 if @fpIndex > 255*self.delta
  end

  def setWeather
    # loop once
    for wth in [["Rain", [:Rain, :HeavyRain, :Storm, :AcidRain,]],["Snow", [:Hail, :Sleet, :Snow]], ["StrongWind", [:StrongWinds]],["Windy", [:Windy]], ["Sunny", [:Sun, :HarshSun]], ["Sandstorm", [:Sandstorm, :DustDevil]],["Overcast", [:Overcast]],["Eclipse", [:Eclipse]],["Starstorm", [:Starstorm]],["VolcanicAsh", [:VolcanicAsh, :DAshfall]]]
      proceed = false
      for cond in (wth[1].is_a?(Array) ? wth[1] : [wth[1]])
        proceed = true if @battle.pbWeather == cond
      end
      eval("delete" + wth[0]) unless proceed
      eval("draw"  + wth[0]) if proceed
    end
  end

  def setTerrain
    for ter in [["Electric",[:Electric]],["Grassy",[:Grassy]],["Misty",[:Misty]],["Psychic",[:Psychic]],["Poison",[:Poison]]]
      proceed = false
      for cond in (ter[1].is_a?(Array) ? ter[1] : [ter[1]])
        proceed = true if @battle.field.terrain == cond
      end
      eval("delete" + ter[0]) unless proceed
      eval("draw"  + ter[0]) if proceed
    end
  end

  def updateTerrain
    self.setTerrain
    for j in 0...2
      next if !@sprites["t_gr#{j}"]
      @sprites["t_gr#{j}"].update
    end
    for j in 0...2
      next if !@sprites["t_misty#{j}"]
      @sprites["t_misty#{j}"].update
    end
    for j in 0...2
      next if !@sprites["t_tox#{j}"]
      @sprites["t_tox#{j}"].update
    end
    for j in 0...2
      next if !@sprites["t_ele#{j}"]
      @sprites["t_ele#{j}"].update
    end
    for j in 0...2
      next if !@sprites["t_psy#{j}"]
      @sprites["t_psy#{j}"].update
    end
  end

  def drawElectric
    for j in 0...2
      next if @sprites["t_ele#{j}"]
      @sprites["t_ele#{j}"] = ScrollingSprite.new(@viewport)
      @sprites["t_ele#{j}"].default!
      @sprites["t_ele#{j}"].z = 150
      @sprites["t_ele#{j}"].y = 200
      @sprites["t_ele#{j}"].setBitmap("Graphics/EBDX/Animations/Weather/electricTerrain")
      @sprites["t_ele#{j}"].speed = 1
      @sprites["t_ele#{j}"].direction = j == 0 ? 1 : -1
    end
  end
  def drawGrassy
    for j in 0...2
      next if @sprites["t_gr#{j}"]
      @sprites["t_gr#{j}"] = ScrollingSprite.new(@viewport)
      @sprites["t_gr#{j}"].default!
      @sprites["t_gr#{j}"].z = 150
      @sprites["t_gr#{j}"].y = 200
      @sprites["t_gr#{j}"].setBitmap("Graphics/EBDX/Animations/Weather/Grassy")
      @sprites["t_gr#{j}"].speed = 1
      @sprites["t_gr#{j}"].direction = j == 0 ? 1 : -1
    end
  end
  def drawMisty
    for j in 0...2
      next if @sprites["t_misty#{j}"]
      @sprites["t_misty#{j}"] = ScrollingSprite.new(@viewport)
      @sprites["t_misty#{j}"].default!
      @sprites["t_misty#{j}"].z = 150
      @sprites["t_misty#{j}"].y = 200
      @sprites["t_misty#{j}"].setBitmap("Graphics/EBDX/Animations/Weather/forestShade")
      @sprites["t_misty#{j}"].speed = 1
      @sprites["t_misty#{j}"].opacity = 64
      @sprites["t_misty#{j}"].direction = j == 0 ? 1 : -1
    end
  end
  def drawPsychic
    for j in 0...2
      next if @sprites["t_psy#{j}"]
      @sprites["t_psy#{j}"] = ScrollingSprite.new(@viewport)
      @sprites["t_psy#{j}"].default!
      @sprites["t_psy#{j}"].z = 150
      @sprites["t_psy#{j}"].y = 200
      @sprites["t_psy#{j}"].setBitmap("Graphics/EBDX/Animations/Weather/Psychic")
      @sprites["t_psy#{j}"].speed = 1
      @sprites["t_psy#{j}"].direction = j == 0 ? 1 : -1
    end
  end
  def drawPoison
    for j in 0...2
      next if @sprites["t_tox#{j}"]
      @sprites["t_tox#{j}"] = ScrollingSprite.new(@viewport)
      @sprites["t_tox#{j}"].default!
      @sprites["t_tox#{j}"].z = 150
      @sprites["t_tox#{j}"].y = 200
      @sprites["t_tox#{j}"].opacity = 50
      @sprites["t_tox#{j}"].setBitmap("Graphics/EBDX/Battlebacks/elements/poisonTerrain")
      @sprites["t_tox#{j}"].speed = 1
      @sprites["t_tox#{j}"].direction = j == 0 ? 1 : -1
    end
  end
  def deleteElectric
    for j in 0...2
      next if !@sprites["t_ele#{j}"]
      @sprites["t_ele#{j}"].dispose
      @sprites.delete("t_ele#{j}")
    end
  end
  def deleteGrassy
    for j in 0...2
      next if !@sprites["t_gr#{j}"]
      @sprites["t_gr#{j}"].dispose
      @sprites.delete("t_gr#{j}")
    end
  end
  def deleteMisty
    for j in 0...2
      next if !@sprites["t_misty#{j}"]
      @sprites["t_misty#{j}"].dispose
      @sprites.delete("t_misty#{j}")
    end
  end
  def deletePsychic
    for j in 0...2
      next if !@sprites["t_psy#{j}"]
      @sprites["t_psy#{j}"].dispose
      @sprites.delete("t_psy#{j}")
    end
  end
  def deletePoison
    for j in 0...2
      next if !@sprites["t_tox#{j}"]
      @sprites["t_tox#{j}"].dispose
      @sprites.delete("t_tox#{j}")
    end
  end
  #-----------------------------------------------------------------------------
  # frame update for the weather particles
  #-----------------------------------------------------------------------------
  def updateWeather
    self.setWeather
    harsh = [:HEAVYRAIN, :HARSHSUN].include?(@battle.pbWeather)
    # snow particles
    for j in 0...72
      next if !@sprites["w_snow#{j}"]
      if @sprites["w_snow#{j}"].opacity <= 0
        z = rand(32)
        @sprites["w_snow#{j}"].param = 0.24 + 0.01*rand(z/2)
        @sprites["w_snow#{j}"].ey = -rand(64)
        @sprites["w_snow#{j}"].ex = 32 + rand(@sprites["bg"].bitmap.width - 64)
        @sprites["w_snow#{j}"].end_x = @sprites["w_snow#{j}"].ex
        @sprites["w_snow#{j}"].toggle = rand(2) == 0 ? 1 : -1
        @sprites["w_snow#{j}"].speed = 1 + 2/((rand(5) + 1)*0.4)
        @sprites["w_snow#{j}"].z = z - (@focused ? 0 : 100)
        @sprites["w_snow#{j}"].opacity = 255
      end
      min = @sprites["bg"].bitmap.height/4
      max = @sprites["bg"].bitmap.height/2
      scale = (2*Math::PI)/((@sprites["w_snow#{j}"].bitmap.width/64.0)*(max - min) + min)
      @sprites["w_snow#{j}"].opacity -= @sprites["w_snow#{j}"].speed
      @sprites["w_snow#{j}"].ey += @sprites["w_snow#{j}"].speed
      @sprites["w_snow#{j}"].ex = @sprites["w_snow#{j}"].end_x + @sprites["w_snow#{j}"].bitmap.width*0.25*Math.sin(@sprites["w_snow#{j}"].ey*scale)*@sprites["w_snow#{j}"].toggle
    end
    # rain particles
    for j in 0...72
      next if !@sprites["w_rain#{j}"]
      if @sprites["w_rain#{j}"].opacity <= 0
        z = rand(32)
        @sprites["w_rain#{j}"].param = 0.24 + 0.01*rand(z/2)
        @sprites["w_rain#{j}"].ox = 0
        @sprites["w_rain#{j}"].ey = -rand(64)
        @sprites["w_rain#{j}"].ex = 32 + rand(@sprites["bg"].bitmap.width - 64)
        @sprites["w_rain#{j}"].speed = 3 + 2/((rand(5) + 1)*0.4)
        @sprites["w_rain#{j}"].z = z - (@focused ? 0 : 100)
        @sprites["w_rain#{j}"].opacity = 255
      end
      @sprites["w_rain#{j}"].opacity -= @sprites["w_rain#{j}"].speed*(harsh ? 3 : 2)
      @sprites["w_rain#{j}"].ox += @sprites["w_rain#{j}"].speed*(harsh ? 8 : 6)
    end
    # starstorm particles
    for j in 0...72
      next if !@sprites["w_starstorm#{j}"]
      if @sprites["w_starstorm#{j}"].opacity <= 0
        z = rand(32)
        @sprites["w_starstorm#{j}"].param = 0.24 + 0.01*rand(z/2)
        @sprites["w_starstorm#{j}"].ox = 32 + rand(@sprites["bg"].bitmap.width - 64)
        @sprites["w_starstorm#{j}"].ey = 0
        @sprites["w_starstorm#{j}"].ex = 0
        @sprites["w_starstorm#{j}"].speed = 3 + 2/((rand(5) + 1)*0.4)
        @sprites["w_starstorm#{j}"].z = z - (@focused ? 0 : 100)
        @sprites["w_starstorm#{j}"].opacity = 255
      end
      @sprites["w_starstorm#{j}"].opacity -= @sprites["w_starstorm#{j}"].speed
      @sprites["w_starstorm#{j}"].ex += @sprites["w_starstorm#{j}"].speed*2
    end
    # volcanic ash particles
    for j in 0...72
      next if !@sprites["w_volc#{j}"]
      if @sprites["w_volc#{j}"].opacity <= 0
        z = rand(32)
        @sprites["w_volc#{j}"].param = 0.24 + 0.01*rand(z/2)
        @sprites["w_volc#{j}"].ox = 0
        @sprites["w_volc#{j}"].ey = -rand(64)
        @sprites["w_volc#{j}"].ex = 32 + rand(@sprites["bg"].bitmap.width - 64)
        @sprites["w_volc#{j}"].speed = 3 + 1/((rand(8) + 1)*0.4)
        @sprites["w_volc#{j}"].z = z - (@focused ? 0 : 100)
        @sprites["w_volc#{j}"].opacity = 255
      end
      @sprites["w_volc#{j}"].opacity -= @sprites["w_volc#{j}"].speed
      @sprites["w_volc#{j}"].ox += @sprites["w_volc#{j}"].speed*2
    end
    # sun particles
    for j in 0...3
      next if !@sprites["w_sunny#{j}"]
      #next if j > @shine["count"]/6
      @sprites["w_sunny#{j}"].zoom_x += 0.04*[0.5, 0.8, 0.7][j]
      @sprites["w_sunny#{j}"].zoom_y += 0.03*[0.5, 0.8, 0.7][j]
      @sprites["w_sunny#{j}"].opacity += @sprites["w_sunny#{j}"].zoom_x < 1 ? 8 : -12
      if @sprites["w_sunny#{j}"].opacity <= 0
        @sprites["w_sunny#{j}"].zoom_x = 0
        @sprites["w_sunny#{j}"].zoom_y = 0
        @sprites["w_sunny#{j}"].opacity = 0
      end
    end
    # sandstorm particles
    for j in 0...2
      next if !@sprites["w_sand#{j}"]
      @sprites["w_sand#{j}"].update
    end
    # windy particles
    for j in 0...2
      next if !@sprites["w_windy#{j}"]
      @sprites["w_windy#{j}"].update
    end
    #eclipse particles
    for j in 0...2
      next if !@sprites["eclipse#{j}"]
      @sprites["eclipse#{j}"].update
    end
  end
  #-----------------------------------------------------------------------------
  # sunny weather handlers
  #-----------------------------------------------------------------------------
  def drawSunny
    @sunny = true
    # refresh daylight tinting
    if @weather != @battle.pbWeather
      @weather = @battle.pbWeather
      self.daylightTint
    end
    # apply sky tone
    if @sprites["sky"]
      @sprites["sky"].tone.all += 16 if @sprites["sky"].tone.all < 96
      for i in 0..1
        @sprites["cloud#{i}"].tone.all += 16 if @sprites["cloud#{i}"].tone.all < 96
      end
    end
    # draw particles
    for i in 0...3
      next if @sprites["w_sunny#{i}"]
      @sprites["w_sunny#{i}"] = Sprite.new(@viewport)
      @sprites["w_sunny#{i}"].z = 100
      @sprites["w_sunny#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Weather/ray001")
      @sprites["w_sunny#{i}"].oy = @sprites["w_sunny#{i}"].bitmap.height/2
      @sprites["w_sunny#{i}"].angle = 290 + [-10, 32, 10][i]
      @sprites["w_sunny#{i}"].zoom_x = 0
      @sprites["w_sunny#{i}"].zoom_y = 0
      @sprites["w_sunny#{i}"].opacity = 0
      @sprites["w_sunny#{i}"].x = [-2, 20, 10][i]
      @sprites["w_sunny#{i}"].y = [-4, -24, -2][i]
    end
  end
  def deleteSunny
    @sunny = false
    # refresh daylight tinting
    if @weather != @battle.pbWeather
      @weather = @battle.pbWeather
      self.daylightTint
    end
    # apply sky tone
    if @sprites["sky"] && !weatherTint?
      @sprites["sky"].tone.all -= 4 if @sprites["sky"].tone.all > 0
      for i in 0..1
        @sprites["cloud#{i}"].tone.all -= 4 if @sprites["cloud#{i}"].tone.all > 0
      end
    end
    for j in 0...3
      next if !@sprites["w_sunny#{j}"]
      @sprites["w_sunny#{j}"].dispose
      @sprites.delete("w_sunny#{j}")
    end
  end
  #-----------------------------------------------------------------------------
  # sandstorm weather handlers
  #-----------------------------------------------------------------------------
  def drawSandstorm
    for j in 0...2
      next if @sprites["w_sand#{j}"]
      @sprites["w_sand#{j}"] = ScrollingSprite.new(@viewport)
      @sprites["w_sand#{j}"].default!
      @sprites["w_sand#{j}"].z = 100
      @sprites["w_sand#{j}"].setBitmap("Graphics/EBDX/Animations/Weather/Sandstorm#{j}")
      @sprites["w_sand#{j}"].speed = 32
      @sprites["w_sand#{j}"].direction = j == 0 ? 1 : -1
    end
  end
  def deleteSandstorm
    for j in 0...2
      next if !@sprites["w_sand#{j}"]
      @sprites["w_sand#{j}"].dispose
      @sprites.delete("w_sand#{j}")
    end
  end
  #-----------------------------------------------------------------------------
  # snow weather handlers
  #-----------------------------------------------------------------------------
  def drawSnow
    for j in 0...72
      next if @sprites["w_snow#{j}"]
      @sprites["w_snow#{j}"] = Sprite.new(@viewport)
      @sprites["w_snow#{j}"].bitmap = pbBitmap("Graphics/EBDX/Battlebacks/elements/snow")
      @sprites["w_snow#{j}"].center!
      @sprites["w_snow#{j}"].default!
      @sprites["w_snow#{j}"].opacity = 0
    end
  end
  def deleteSnow
    for j in 0...72
      next if !@sprites["w_snow#{j}"]
      @sprites["w_snow#{j}"].dispose
      @sprites.delete("w_snow#{j}")
    end
  end
  #-----------------------------------------------------------------------------
  # rain weather handlers
  #-----------------------------------------------------------------------------
  def drawRain
    harsh = @battle.pbWeather == :HEAVYRAIN
    # apply sky tone
    if @sprites["sky"]
      @sprites["sky"].tone.all -= 2 if @sprites["sky"].tone.all > -16
      @sprites["sky"].tone.gray += 16 if @sprites["sky"].tone.gray < 128
      for i in 0..1
        @sprites["cloud#{i}"].tone.all -= 2 if @sprites["cloud#{i}"].tone.all > -16
        @sprites["cloud#{i}"].tone.gray += 16 if @sprites["cloud#{i}"].tone.gray < 128
      end
    end
    for j in 0...72
      next if @sprites["w_rain#{j}"]
      @sprites["w_rain#{j}"] = Sprite.new(@viewport)
      if @battle.pbWeather == :AcidRain
        @sprites["w_rain#{j}"].create_rect(24, 3, Color.blue)
      else
        @sprites["w_rain#{j}"].create_rect(harsh ? 28 : 24, 3, Color.white)
      end
      @sprites["w_rain#{j}"].default!
      @sprites["w_rain#{j}"].angle = 80
      @sprites["w_rain#{j}"].oy = 2
      @sprites["w_rain#{j}"].opacity = 0
    end
  end
  def deleteRain
    # apply sky tone
    if @sprites["sky"]
      @sprites["sky"].tone.all += 2 if @sprites["sky"].tone.all < 0
      @sprites["sky"].tone.gray -= 16 if @sprites["sky"].tone.gray > 0
      for i in 0..1
        @sprites["cloud#{i}"].tone.all += 2 if @sprites["cloud#{i}"].tone.all < 0
        @sprites["cloud#{i}"].tone.gray -= 16 if @sprites["cloud#{i}"].tone.gray > 0
      end
    end
    for j in 0...72
      next if !@sprites["w_rain#{j}"]
      @sprites["w_rain#{j}"].dispose
      @sprites.delete("w_rain#{j}")
    end
  end
  #-----------------------------------------------------------------------------
  # strong wind weather handlers
  #-----------------------------------------------------------------------------
  def drawStrongWind; @strongwind = true; end
  def deleteStrongWind; @strongwind = false; end
  #-----------------------------------------------------------------------------
  # overcast weather handlers
  #-----------------------------------------------------------------------------
  def drawOvercast
    if @sprites["sky"]
      @sprites["sky"].tone.all -= 10 if @sprites["sky"].tone.all > -100
      @sprites["sky"].tone.gray += 16 if @sprites["sky"].tone.gray < 172
      for i in 0..1
        @sprites["cloud#{i}"].tone.all -= 10 if @sprites["cloud#{i}"].tone.all > -100
        @sprites["cloud#{i}"].tone.gray += 16 if @sprites["cloud#{i}"].tone.gray < 172
      end
    end
  end

  def deleteOvercast
    if @sprites["sky"]
      @sprites["sky"].tone.all += 10 if @sprites["sky"].tone.all < 0
      @sprites["sky"].tone.gray -= 16 if @sprites["sky"].tone.gray > 0
      for i in 0..1
        @sprites["cloud#{i}"].tone.all += 10 if @sprites["cloud#{i}"].tone.all < 0
        @sprites["cloud#{i}"].tone.gray -= 16 if @sprites["cloud#{i}"].tone.gray > 0
      end
    end
  end
  #-----------------------------------------------------------------------------
  # starstorm weather handlers
  #-----------------------------------------------------------------------------
  def drawStarstorm
    # apply sky tone
    if @sprites["sky"]
      @sprites["sky"].tone.all -= 10 if @sprites["sky"].tone.all > -120
      @sprites["sky"].tone.gray += 16 if @sprites["sky"].tone.gray < 128
      for i in 0..1
        @sprites["cloud#{i}"].tone.all -= 10 if @sprites["cloud#{i}"].tone.all > -120
        @sprites["cloud#{i}"].tone.gray += 16 if @sprites["cloud#{i}"].tone.gray < 128
      end
    end
    for j in 0...72
      next if @sprites["w_starstorm#{j}"]
      @sprites["w_starstorm#{j}"] = Sprite.new(@viewport)
      @sprites["w_starstorm#{j}"].create_rect(7, 7, Color.white)
      @sprites["w_starstorm#{j}"].default!
      @sprites["w_starstorm#{j}"].angle = 90
      @sprites["w_starstorm#{j}"].oy = -rand(64)
      @sprites["w_starstorm#{j}"].opacity = 0
    end
  end
  def deleteStarstorm
    # apply sky tone
    if @sprites["sky"]
      @sprites["sky"].tone.all += 2 if @sprites["sky"].tone.all < 0
      @sprites["sky"].tone.gray -= 16 if @sprites["sky"].tone.gray > 0
      for i in 0..1
        @sprites["cloud#{i}"].tone.all += 2 if @sprites["cloud#{i}"].tone.all < 0
        @sprites["cloud#{i}"].tone.gray -= 16 if @sprites["cloud#{i}"].tone.gray > 0
      end
    end
    for j in 0...72
      next if !@sprites["w_starstorm#{j}"]
      @sprites["w_starstorm#{j}"].dispose
      @sprites.delete("w_starstorm#{j}")
    end
  end
  #-----------------------------------------------------------------------------
  # eclipse weather handlers
  #-----------------------------------------------------------------------------

  def drawEclipse
    if @sprites["sky"]
      @sprites["sky"].tone.all -= 10 if @sprites["sky"].tone.all > -100
      @sprites["sky"].tone.gray += 16 if @sprites["sky"].tone.gray < 172
      for i in 0..1
        @sprites["cloud#{i}"].tone.all -= 10 if @sprites["cloud#{i}"].tone.all > -100
        @sprites["cloud#{i}"].tone.gray += 16 if @sprites["cloud#{i}"].tone.gray < 172
      end
    end
    for j in 0...2
      next if @sprites["eclipse#{j}"]
      @sprites["eclipse#{j}"] = ScrollingSprite.new(@viewport)
      @sprites["eclipse#{j}"].default!
      @sprites["eclipse#{j}"].z = 150
      @sprites["eclipse#{j}"].y = 200
      @sprites["eclipse#{j}"].setBitmap("Graphics/EBDX/Animations/Weather/eclipse")
      @sprites["eclipse#{j}"].speed = 1
      @sprites["eclipse#{j}"].opacity = 64
      @sprites["eclipse#{j}"].direction = j == 0 ? 1 : -1
    end
  end
  def deleteEclipse
    if @sprites["sky"]
      @sprites["sky"].tone.all += 10 if @sprites["sky"].tone.all < 0
      @sprites["sky"].tone.gray -= 16 if @sprites["sky"].tone.gray > 0
      for i in 0..1
        @sprites["cloud#{i}"].tone.all += 10 if @sprites["cloud#{i}"].tone.all < 0
        @sprites["cloud#{i}"].tone.gray -= 16 if @sprites["cloud#{i}"].tone.gray > 0
      end
    end
    for j in 0...2
      next if !@sprites["eclipse#{j}"]
      @sprites["eclipse#{j}"].dispose
      @sprites.delete("eclipse#{j}")
    end
  end
  #-----------------------------------------------------------------------------
  # windy weather handlers
  #-----------------------------------------------------------------------------
  def drawWindy
    @strongwind = true
    for j in 0...2
      next if @sprites["w_windy#{j}"]
      @sprites["w_windy#{j}"] = ScrollingSprite.new(@viewport)
      @sprites["w_windy#{j}"].default!
      @sprites["w_windy#{j}"].z = 100
      @sprites["w_windy#{j}"].setBitmap("Graphics/EBDX/Animations/Weather/windy#{j}")
      @sprites["w_windy#{j}"].speed = 32
      @sprites["w_windy#{j}"].direction = -1
    end
  end
  def deleteWindy
    @strongwind = false
    for j in 0...2
      next if !@sprites["w_windy#{j}"]
      @sprites["w_windy#{j}"].dispose
      @sprites.delete("w_windy#{j}")
    end
  end
  #-----------------------------------------------------------------------------
  # volcanic ash weather handlers
  #-----------------------------------------------------------------------------
  def drawVolcanicAsh
    # apply sky tone
    if @sprites["sky"]
      @sprites["sky"].tone.all -= 4 if @sprites["sky"].tone.all > -100
      @sprites["sky"].tone.gray += 16 if @sprites["sky"].tone.gray < 128
      for i in 0..1
        @sprites["cloud#{i}"].tone.all -= 4 if @sprites["cloud#{i}"].tone.all > -100
        @sprites["cloud#{i}"].tone.gray += 16 if @sprites["cloud#{i}"].tone.gray < 128
      end
    end
    for j in 0...72
      next if @sprites["w_volc#{j}"]
      @sprites["w_volc#{j}"] = Sprite.new(@viewport)
      @sprites["w_volc#{j}"].create_rect(5, 5, Color.black)
      @sprites["w_volc#{j}"].default!
      @sprites["w_volc#{j}"].angle = 90
      @sprites["w_volc#{j}"].oy = 2
      @sprites["w_volc#{j}"].opacity = 0
    end
  end
  def deleteVolcanicAsh
    # apply sky tone
    if @sprites["sky"]
      @sprites["sky"].tone.all += 2 if @sprites["sky"].tone.all < 0
      @sprites["sky"].tone.gray -= 16 if @sprites["sky"].tone.gray > 0
      for i in 0..1
        @sprites["cloud#{i}"].tone.all += 2 if @sprites["cloud#{i}"].tone.all < 0
        @sprites["cloud#{i}"].tone.gray -= 16 if @sprites["cloud#{i}"].tone.gray > 0
      end
    end
    for j in 0...72
      next if !@sprites["w_volc#{j}"]
      @sprites["w_volc#{j}"].dispose
      @sprites.delete("w_volc#{j}")
    end
  end
end

class PokemonOption_Scene
  def pbStartScene(inloadscreen=false)
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
       _INTL("Options"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].text           = _INTL("Speech frame {1}.",1+$PokemonSystem.textskin)
    @sprites["textbox"].letterbyletter = false
    pbSetSystemFont(@sprites["textbox"].contents)
    # These are the different options in the game. To add an option, define a
    # setter and a getter for that option. To delete an option, comment it out
    # or delete it. The game's options may be placed in any order.
    @PokemonOptions = [
       SliderOption.new(_INTL("Music Volume"),0,100,5,
         proc { $PokemonSystem.bgmvolume },
         proc { |value|
           if $PokemonSystem.bgmvolume!=value
             $PokemonSystem.bgmvolume = value
             if $game_system.playing_bgm!=nil && !inloadscreen
               playingBGM = $game_system.getPlayingBGM
               $game_system.bgm_pause
               $game_system.bgm_resume(playingBGM)
             end
           end
         }
       ),
       SliderOption.new(_INTL("SE Volume"),0,100,5,
         proc { $PokemonSystem.sevolume },
         proc { |value|
           if $PokemonSystem.sevolume!=value
             $PokemonSystem.sevolume = value
             if $game_system.playing_bgs!=nil
               $game_system.playing_bgs.volume = value
               playingBGS = $game_system.getPlayingBGS
               $game_system.bgs_pause
               $game_system.bgs_resume(playingBGS)
             end
             pbPlayCursorSE
           end
         }
       ),
       EnumOption.new(_INTL("Text Speed"),[_INTL("Slow"),_INTL("Normal"),_INTL("Fast")],
         proc { $PokemonSystem.textspeed },
         proc { |value|
           $PokemonSystem.textspeed = value
           MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
         }
       ),
       EnumOption.new(_INTL("Battle Effects"),[_INTL("On"),_INTL("Off")],
         proc { $PokemonSystem.battlescene },
         proc { |value| $PokemonSystem.battlescene = value }
       ),
       EnumOption.new(_INTL("Default Movement"),[_INTL("Walking"),_INTL("Running")],
         proc { $PokemonSystem.runstyle },
         proc { |value| $PokemonSystem.runstyle = value }
       ),
       EnumOption.new(_INTL("Text Entry"),[_INTL("Cursor"),_INTL("Keyboard")],
         proc { $PokemonSystem.textinput },
         proc { |value| $PokemonSystem.textinput = value }
       ),
       EnumOption.new(_INTL("Screen Size"),[_INTL("S"),_INTL("M"),_INTL("L"),_INTL("XL"),_INTL("Full")],
         proc { [$PokemonSystem.screensize, 4].min },
         proc { |value|
           if $PokemonSystem.screensize != value
             $PokemonSystem.screensize = value
             pbSetResizeFactor($PokemonSystem.screensize)
           end
         }
       )
    ]
    @PokemonOptions = pbAddOnOptions(@PokemonOptions)
    @sprites["option"] = Window_PokemonOption.new(@PokemonOptions,0,
       @sprites["title"].height,Graphics.width,
       Graphics.height-@sprites["title"].height-@sprites["textbox"].height)
    @sprites["option"].viewport = @viewport
    @sprites["option"].visible  = true
    # Get the values of each option
    for i in 0...@PokemonOptions.length
      @sprites["option"].setValueNoRefresh(i,(@PokemonOptions[i].get || 0))
    end
    @sprites["option"].refresh
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end

#===============================================================================
# Scene class for handling appearance of the screen
#===============================================================================
class EggRelearner_Scene
  VISIBLEMOVES = 4

  def pbDisplay(msg,brief=false)
    UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"],msg) { pbUpdate }
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(pokemon,moves)
    @pokemon=pokemon
    @moves=moves
    moveCommands=[]
    moves.each { |m| moveCommands.push(GameData::Move.get(m).name) }
    # Create sprite hash
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    addBackgroundPlane(@sprites,"bg","reminderbg",@viewport)
    @sprites["pokeicon"]=PokemonIconSprite.new(@pokemon,@viewport)
    @sprites["pokeicon"].setOffset(PictureOrigin::Center)
    @sprites["pokeicon"].x=320
    @sprites["pokeicon"].y=84
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/reminderSel")
    @sprites["background"].y=78
    @sprites["background"].src_rect=Rect.new(0,72,258,72)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["commands"]=Window_CommandPokemon.new(moveCommands,32)
    @sprites["commands"].height=32*(VISIBLEMOVES+1)
    @sprites["commands"].visible=false
    @sprites["msgwindow"]=Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible=false
    @sprites["msgwindow"].viewport=@viewport
    @typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    pbDrawMoveList
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbDrawMoveList
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    type1_number = GameData::Type.get(@pokemon.type1).id_number
    type2_number = GameData::Type.get(@pokemon.type2).id_number
    type1rect=Rect.new(0, type1_number * 28, 64, 28)
    type2rect=Rect.new(0, type2_number * 28, 64, 28)
    if @pokemon.type1==@pokemon.type2
      overlay.blt(400,70,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(366,70,@typebitmap.bitmap,type1rect)
      overlay.blt(436,70,@typebitmap.bitmap,type2rect)
    end
    textpos=[
       [_INTL("Teach which move?"),16,2,0,Color.new(88,88,80),Color.new(168,184,184)]
    ]
    imagepos=[]
    yPos=76
    for i in 0...VISIBLEMOVES
      moveobject=@moves[@sprites["commands"].top_item+i]
      if moveobject
        moveData=GameData::Move.get(moveobject)
        type_number = GameData::Type.get(moveData.type).id_number
        imagepos.push(["Graphics/Pictures/types", 12, yPos + 8, 0, type_number * 28, 64, 28])
        textpos.push([moveData.name,80,yPos,0,Color.new(248,248,248),Color.new(0,0,0)])
        if moveData.total_pp>0
          textpos.push([_INTL("PP"),112,yPos+32,0,Color.new(64,64,64),Color.new(176,176,176)])
          textpos.push([_INTL("{1}/{1}",moveData.total_pp),230,yPos+32,1,
             Color.new(64,64,64),Color.new(176,176,176)])
        else
          textpos.push(["-",80,yPos,0,Color.new(64,64,64),Color.new(176,176,176)])
          textpos.push(["--",228,yPos+32,1,Color.new(64,64,64),Color.new(176,176,176)])
        end
      end
      yPos+=64
    end
    imagepos.push(["Graphics/Pictures/reminderSel",
       0,78+(@sprites["commands"].index-@sprites["commands"].top_item)*64,
       0,0,258,72])
    selMoveData=GameData::Move.get(@moves[@sprites["commands"].index])
    basedamage=selMoveData.base_damage
    category=selMoveData.category
    accuracy=selMoveData.accuracy
    textpos.push([_INTL("CATEGORY"),272,108,0,Color.new(248,248,248),Color.new(0,0,0)])
    textpos.push([_INTL("POWER"),272,140,0,Color.new(248,248,248),Color.new(0,0,0)])
    textpos.push([basedamage<=1 ? basedamage==1 ? "???" : "---" : sprintf("%d",basedamage),
          468,140,2,Color.new(64,64,64),Color.new(176,176,176)])
    textpos.push([_INTL("ACCURACY"),272,172,0,Color.new(248,248,248),Color.new(0,0,0)])
    textpos.push([accuracy==0 ? "---" : "#{accuracy}%",
          468,172,2,Color.new(64,64,64),Color.new(176,176,176)])
    pbDrawTextPositions(overlay,textpos)
    imagepos.push(["Graphics/Pictures/category",436,116,0,category*28,64,28])
    if @sprites["commands"].index<@moves.length-1
      imagepos.push(["Graphics/Pictures/reminderButtons",48,350,0,0,76,32])
    end
    if @sprites["commands"].index>0
      imagepos.push(["Graphics/Pictures/reminderButtons",134,350,76,0,76,32])
    end
    pbDrawImagePositions(overlay,imagepos)
    drawTextEx(overlay,272,214,230,5,selMoveData.description,
       Color.new(64,64,64),Color.new(176,176,176))
  end

  # Processes the scene
  def pbChooseMove
    oldcmd=-1
    pbActivateWindow(@sprites,"commands") {
      loop do
        oldcmd=@sprites["commands"].index
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["commands"].index!=oldcmd
          @sprites["background"].x=0
          @sprites["background"].y=78+(@sprites["commands"].index-@sprites["commands"].top_item)*64
          pbDrawMoveList
        end
        if Input.trigger?(Input::BACK)
          return nil
        elsif Input.trigger?(Input::USE)
          return @moves[@sprites["commands"].index]
        end
      end
    }
  end

  # End the scene here
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @viewport.dispose
  end
end

#===============================================================================
# Screen class for handling game logic
#===============================================================================
class EggRelearnerScreen
  def initialize(scene)
    @scene = scene
  end

  def pbGetEggMoves(pkmn)
    return [] if !pkmn || pkmn.egg? || pkmn.shadowPokemon?
    moves = []
    pkmn.getEggMovesList.each do |m|
      next if pkmn.hasMove?(m)
      moves.push(m) if !moves.include?(m)
    end
    egg = moves
    return egg | []  # remove duplicates
  end

  def pbStartScreen(pkmn)
    moves = pbGetEggMoves(pkmn)
    @scene.pbStartScene(pkmn, moves)
    loop do
      move = @scene.pbChooseMove
      if move
        if @scene.pbConfirm(_INTL("Teach {1}?", GameData::Move.get(move).name))
          if pbLearnMove(pkmn, move)
            @scene.pbEndScene
            return true
          end
        end
      elsif @scene.pbConfirm(_INTL("Give up trying to teach a new move to {1}?", pkmn.name))
        @scene.pbEndScene
        return false
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbEggMoveScreen(pkmn)
  retval = true
  pbFadeOutIn {
    scene = EggRelearner_Scene.new
    screen = EggRelearnerScreen.new(scene)
    retval = screen.pbStartScreen(pkmn)
  }
  return retval
end

class PokemonPartyScreen
  def pbPokemonScreen
    @scene.pbStartScene(@party,
       (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),nil)
    loop do
      @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid = @scene.pbChoosePokemon(false,-1,1)
      break if (pkmnid.is_a?(Numeric) && pkmnid<0) || (pkmnid.is_a?(Array) && pkmnid[1]<0)
      if pkmnid.is_a?(Array) && pkmnid[0]==1   # Switch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid[1]
        pkmnid = @scene.pbChoosePokemon(true,-1,2)
        if pkmnid>=0 && pkmnid!=oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
        end
        next
      end
      pkmn = @party[pkmnid]
      commands   = []
      cmdSummary = -1
      cmdStats   = -1
      cmdDebug   = -1
      cmdMoves   = [-1] * pkmn.numMoves
      cmdSwitch  = -1
      cmdEvolve  = -1
      cmdRelearn = -1
      cmdName    = -1
      cmdMail    = -1
      cmdItem    = -1
      # Build the commands
      commands[cmdSummary = commands.length]      = _INTL("Summary")
      commands[cmdDebug = commands.length]        = _INTL("Debug") if $DEBUG
      commands[cmdStats = commands.length]      = _INTL("Base Stats")
      if !pkmn.egg?
        # Check for hidden moves and add any that were found
        pkmn.moves.each_with_index do |m, i|
          if [:MILKDRINK, :SOFTBOILED].include?(m.id)
            commands[cmdMoves[i] = commands.length] = [m.name, 1]
          end
        end
      end
      commands[cmdSwitch = commands.length]       = _INTL("Switch") if @party.length>1
      if !pkmn.egg?
        if pkmn.mail
          commands[cmdMail = commands.length]     = _INTL("Mail")
          commands[cmdRelearn = commands.length]   = _INTL("Relearn Moves") if $game_switches[197] == false
          commands[cmdEvolve = commands.length]   = _INTL("Evolve")
          commands[cmdName = commands.length]     = _INTL("Nickname")
        else
          commands[cmdItem = commands.length]     = _INTL("Item")
          commands[cmdRelearn = commands.length]   = _INTL("Relearn Moves") if $game_switches[197] == false
          commands[cmdEvolve = commands.length]   = _INTL("Evolve")
          commands[cmdName = commands.length]     = _INTL("Nickname")
        end
      end
      commands[commands.length]                   = _INTL("Cancel")
      $viewport_stats.dispose if $viewport_stats != nil
      command = @scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands)
      havecommand = false
      cmdMoves.each_with_index do |cmd, i|
        next if cmd < 0 || cmd != command
        havecommand = true
        if [:MILKDRINK, :SOFTBOILED].include?(pkmn.moves[i].id)
          amt = [(pkmn.totalhp/5).floor,1].max
          if pkmn.hp<=amt
            pbDisplay(_INTL("Not enough HP..."))
            break
          end
          @scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
          oldpkmnid = pkmnid
          loop do
            @scene.pbPreSelect(oldpkmnid)
            pkmnid = @scene.pbChoosePokemon(true,pkmnid)
            break if pkmnid<0
            newpkmn = @party[pkmnid]
            movename = pkmn.moves[i].name
            if pkmnid==oldpkmnid
              pbDisplay(_INTL("{1} can't use {2} on itself!",pkmn.name,movename))
            elsif newpkmn.egg?
              pbDisplay(_INTL("{1} can't be used on an Egg!",movename))
            elsif newpkmn.hp==0 || newpkmn.hp==newpkmn.totalhp
              pbDisplay(_INTL("{1} can't be used on that Pokémon.",movename))
            else
              pkmn.hp -= amt
              hpgain = pbItemRestoreHP(newpkmn,amt)
              @scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",newpkmn.name,hpgain))
              pbRefresh
            end
            break if pkmn.hp<=amt
          end
          @scene.pbSelect(oldpkmnid)
          pbRefresh
          break
        end
      end
      next if havecommand
      if cmdSummary>=0 && command==cmdSummary
        $viewport_stats.dispose if $viewport_stats != nil
        @scene.pbSummary(pkmnid) {
          @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
        }
      elsif cmdDebug>=0 && command==cmdDebug
        $viewport_stats.dispose if $viewport_stats != nil
        pbPokemonDebug(pkmn,pkmnid)
      elsif cmdStats>=0 && command==cmdStats
        $viewport_stats.dispose if $viewport_stats != nil
        @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport1.z = 99999
        $viewport_stats = @viewport1
        pkmn = @party[pkmnid]
        @sprites = {}
        pkmn_info = "HP: #{pkmn.baseStats[:HP]}\nAttack: #{pkmn.baseStats[:ATTACK]}\nDefense: #{pkmn.baseStats[:DEFENSE]}\nSpecial Attack: #{pkmn.baseStats[:SPECIAL_ATTACK]}\nSpecial Defense: #{pkmn.baseStats[:SPECIAL_DEFENSE]}\nSpeed: #{pkmn.baseStats[:SPEED]}"
        $pkmn_data = pkmn_info
        @sprites["scene"] = Window_AdvancedTextPokemon.newWithSize($pkmn_data,250,5,300,220,@viewport1)
        pbSetSmallFont(@sprites["scene"].contents)
        @sprites["scene"].resizeToFit2($pkmn_data,300,220)
        @sprites["scene"].visible = true
        $pkmn_info = @sprites["scene"]
      elsif cmdSwitch>=0 && command==cmdSwitch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid
        pkmnid = @scene.pbChoosePokemon(true)
        if pkmnid>=0 && pkmnid!=oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
        end
      elsif cmdRelearn>=0 && command==cmdRelearn
        if pkmn.can_relearn_move?
          pbRelearnMoveScreen(pkmn)
        else
          pbDisplay(_INTL("This Pokémon cannot relearn any moves."))
        end
      elsif cmdEvolve>=0 && command==cmdEvolve
        evoreqs = {}
        GameData::Species.get_species_form(pkmn.species,pkmn.form).get_evolutions(true).each do |evo|   # [new_species, method, parameter, boolean]
          if evo[1].to_s.start_with?('Item')
            evoreqs[evo[0]] = evo[2] if $PokemonBag.pbHasItem?(evo[2]) && pkmn.check_evolution_on_use_item(evo[2])
          elsif evo[1].to_s.start_with?('Location')
            evoreqs[evo[0]] = nil if $game_map.map_id == evo[2]
          elsif evo[1].to_s.start_with?('Trade')
            evoreqs[evo[0]] = evo[2] if $Trainer.has_species?(evo[2]) || pkmn.check_evolution_on_trade(evo[2])
          elsif evo[1].to_s.start_with?('Happiness')
            evoreqs[evo[0]] = nil
          elsif pkmn.check_evolution_on_level_up
            evoreqs[evo[0]] = nil
          end
        end
        case evoreqs.length
        when 0
          pbDisplay(_INTL("This Pokémon can't evolve."))
          next
        when 1
          newspecies = evoreqs.keys[0]
        else
          newspecies = evoreqs.keys[@scene.pbShowCommands(
            _INTL("Which species would you like to evolve into?"),
            evoreqs.keys.map { |id| _INTL(GameData::Species.get(id).real_name) }
          )]
        end
        if evoreqs[newspecies] # requires an item
          next unless @scene.pbConfirmMessage(_INTL(
            "This will consume a {1}. Do you want to continue?",
            GameData::Item.get(evoreqs[newspecies]).name
          ))
          $PokemonBag.pbDeleteItem(evoreqs[newspecies])
        end
        pbFadeOutInWithMusic {
          evo = PokemonEvolutionScene.new
          evo.pbStartScreen(pkmn,newspecies)
          evo.pbEvolution
          evo.pbEndScreen
          scene.pbRefresh
        }
      elsif cmdName>=0 && command==cmdName
        speciesname = pkmn.speciesName
        nickname = pbEnterPokemonName(_INTL("{1}'s nickname?", speciesname),
                                      0, Pokemon::MAX_NAME_SIZE, "", pkmn)
        pkmn.name = nickname
      elsif cmdMail>=0 && command==cmdMail
        command = @scene.pbShowCommands(_INTL("Do what with the mail?"),
           [_INTL("Read"),_INTL("Take"),_INTL("Cancel")])
        case command
        when 0   # Read
          pbFadeOutIn {
            pbDisplayMail(pkmn.mail,pkmn)
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
        when 1   # Take
          if pbTakeItemFromPokemon(pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        end
      elsif cmdItem>=0 && command==cmdItem
        itemcommands = []
        cmdUseItem   = -1
        cmdGiveItem  = -1
        cmdTakeItem  = -1
        cmdMoveItem  = -1
        # Build the commands
        itemcommands[cmdUseItem=itemcommands.length]  = _INTL("Use")
        itemcommands[cmdGiveItem=itemcommands.length] = _INTL("Give")
        itemcommands[cmdTakeItem=itemcommands.length] = _INTL("Take") if pkmn.hasItem?
        itemcommands[cmdMoveItem=itemcommands.length] = _INTL("Move") if pkmn.hasItem? &&
                                                                         !GameData::Item.get(pkmn.item).is_mail?
        itemcommands[itemcommands.length]             = _INTL("Cancel")
        command = @scene.pbShowCommands(_INTL("Do what with an item?"),itemcommands)
        if cmdUseItem>=0 && command==cmdUseItem   # Use
          item = @scene.pbUseItem($PokemonBag,pkmn) {
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
          if item
            pbUseItemOnPokemon(item,pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdGiveItem>=0 && command==cmdGiveItem   # Give
          item = @scene.pbChooseItem($PokemonBag) {
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
          if item
            if pbGiveItemToPokemon(item,pkmn,self,pkmnid)
              pbRefreshSingle(pkmnid)
            end
          end
        elsif cmdTakeItem>=0 && command==cmdTakeItem   # Take
          if pbTakeItemFromPokemon(pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdMoveItem>=0 && command==cmdMoveItem   # Move
          item = pkmn.item
          itemname = item.name
          @scene.pbSetHelpText(_INTL("Move {1} to where?",itemname))
          oldpkmnid = pkmnid
          loop do
            @scene.pbPreSelect(oldpkmnid)
            pkmnid = @scene.pbChoosePokemon(true,pkmnid)
            break if pkmnid<0
            newpkmn = @party[pkmnid]
            break if pkmnid==oldpkmnid
            if newpkmn.egg?
              pbDisplay(_INTL("Eggs can't hold items."))
            elsif !newpkmn.hasItem?
              newpkmn.item = item
              pkmn.item = nil
              @scene.pbClearSwitching
              pbRefresh
              pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
              break
            elsif GameData::Item.get(newpkmn.item).is_mail?
              pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.",newpkmn.name))
            else
              newitem = newpkmn.item
              newitemname = newitem.name
              if newitem == :LEFTOVERS
                pbDisplay(_INTL("{1} is already holding some {2}.\1",newpkmn.name,newitemname))
              elsif newitemname.starts_with_vowel?
                pbDisplay(_INTL("{1} is already holding an {2}.\1",newpkmn.name,newitemname))
              else
                pbDisplay(_INTL("{1} is already holding a {2}.\1",newpkmn.name,newitemname))
              end
              if pbConfirm(_INTL("Would you like to switch the two items?"))
                newpkmn.item = item
                pkmn.item = newitem
                @scene.pbClearSwitching
                pbRefresh
                pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
                pbDisplay(_INTL("{1} was given the {2} to hold.",pkmn.name,newitemname))
                break
              end
            end
          end
        end
      end
    end
    @scene.pbEndScene
    return nil
  end
end

class HallOfFame_Scene
  def writeWelcome
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    grind = (!$game_switches[900] && $game_switches[75]) ? "Min Grinding " : ""
    inverse = $game_switches[909] ? "Inverse " : ""
    nuzlocke = $game_switches[73] ? " Nuzlocke" : ""
    kaizo = $game_switches[LvlCap::Kaizo] ? " Kaizo" : ""
    ironmon = $game_switches[LvlCap::Ironmon] ? " Ironmon" : ""
    if $game_switches[900] && !$game_switches[903]
      mode = " Hard Mode"
    elsif $game_switches[900] && $game_switches[903]
      mode = " Expert Mode"
    else
      mode = " Normal Mode"
    end
    post = $game_switches[300] ? "Post-Game " : ""
    pbDrawTextPositions(overlay,[[_INTL("Welcome to the Hall of Fame!"),
       Graphics.width/2,Graphics.height-80,2,BASECOLOR,SHADOWCOLOR]])
       pbDrawTextPositions(overlay,[[_INTL("{1}{2}{3}{4}{5}{6}",post,grind,inverse,mode,kaizo,ironmon,nuzlocke),
          Graphics.width/2,Graphics.height-56,2,BASECOLOR,SHADOWCOLOR]])
  end
end

class Scene_Credits
  CREDIT = <<_END_

  Scripting: Phantombass

  Some resources from the Pokémon Reborn team.

  Updated Move Animations:
  StCooler
  DarryBD99
  WolfPP
  ardicoozer
  riddlemeree

  Regional Variant Sprites:
  Phantombass

  Rotom Dex Front Sprite:
  Profkrd on Deviantart

  Rotom Dex Icon:
  ZekzyBwoy on Reddit

  Bill Sprite:
  theboyzz0111 on Reddit

  Legends Arceus Sprites:
  KingOfThe-X-Roads on Deviantart
  Anarlaurendil on Deviantart
  @_zerudez on nitter.net

  Gen 9 Sprites:
  The-King-Of-Roads-X
  Mak
  leParagon
  Caruban
  Azria
  Mashirosakura
  aR0y2810
  Katten
  Jinxed

  Perfect Kyurem Sprite:
  Caleb

  Astreon Sprites:
  Bl00dy (concept art)
  Saebbi (sprite art)

  Tilesets:
  Ekat
  Idilio
  lichenprincess

  Mapping: Phantombass

  Eventing: Phantombass

  Playtesting:

  TylertheTyrantrum
  Bl00dy

  Dedicated to:

  Megan and Sophia

  Also thanks to:

  Tilly and Zoe...for walking all over my keyboard
  many times during development.

  My Discord server:
  You guys have been super patient as I ironed out bugs.
  You guys rock!

{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE}

"Pokémon Essentials" was created by:
Flameguru
Poccil (Peter O.)
Maruno

With contributions from:
AvatarMonkeyKirby<s>Marin
Boushy<s>MiDas Mike
Brother1440<s>Near Fantastica
FL.<s>PinkMan
Genzai Kawakami<s>Popper
Golisopod User<s>Rataime
help-14<s>Savordez
IceGod64<s>SoundSpawn
Jacob O. Wobbrock<s>the__end
KitsuneKouta<s>Venom12
Lisa Anthony<s>Wachunga
Luka S.J.<s>
and everyone else who helped out

"mkxp-z" by:
Roza
Based on MKXP by Ancurio et al.

"RPG Maker XP" by:
Enterbrain

Pokémon is owned by:
The Pokémon Company
Nintendo
Affiliated with Game Freak



This is a non-profit fan-made game.
No copyright infringements intended.
Please support the official games!

_END_
end
