#===================================
# Level Cap Scripts
#===================================
module Settings
  LEVEL_CAP_SWITCH = 904
  FISHING_AUTO_HOOK     = true
  GAME_VERSION = "0.1"
end

def write_version
  File.open("version.txt", "wb") { |f|
    version = Settings::GAME_VERSION
    f.write("#{version}")
  }
end
def reset_custom_variables
  $gym_gimmick = false
  $gym_weather = false
  $appliance = nil
  $currentDexSearch = nil
  $repel_toggle = false
  #$mega_flag = 0
end
class Game_System
  attr_accessor :level_cap
  alias initialize_cap initialize
  def initialize
    initialize_cap
    @level_cap          = 0
  end
  def level_cap
    return @level_cap
  end
end

module RandBoss
  Var = 990
end

def randomizer_boss
  if $game_switches[907]
    EliteBattle.toggle_randomizer if $game_switches[RandBoss::Var] == false
    $game_switches[RandBoss::Var] = true
  end
end

def randomizer_on
  if $game_switches[907]
    EliteBattle.toggle_randomizer if $game_switches[RandBoss::Var]
    $game_switches[RandBoss::Var] = false
  end
end

LEVEL_CAP = [11,15,19,22,27,29,37,40,43,48,55,59,65,68,71,72,76,79,80,83,85,88,90,93,95,98,100]

module Game
  def self.level_cap_update
    if $game_switches[LEVEL_CAP_SWITCH]
      $game_system.level_cap += 1
      $game_system.level_cap = LEVEL_CAP.size-1 if $game_system.level_cap >= LEVEL_CAP.size
      $game_variables[106] = LEVEL_CAP[$game_system.level_cap]
    end
  end
  def self.start_new
    pbMessage(_INTL("Welcome to Pokémon Hegemony DX, a complete, non-profit fan game made by Phantombass."))
    pbMessage(_INTL("If you paid for this, contact the person who sent it to you for a refund immediately."))
    pbMessage(_INTL("The current version is #{Settings::GAME_VERSION}."))
    pbMessage(_INTL("I hope you enjoy your journey!"))
    if $game_map && $game_map.events
      $game_map.events.each_value { |event| event.clear_starting }
    end
    $game_temp.common_event_id = 0 if $game_temp
    $PokemonTemp.begunNewGame = true
    $game_system.initialize
    $mobile_mystery_gifts = []
    reset_custom_variables
    $scene = Scene_Map.new
    SaveData.load_new_game_values
    $MapFactory = PokemonMapFactory.new($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    $game_map.autoplay
    $game_map.update
  end
  def write_version
    File.open("version.txt", "wb") { |f|
      version = Settings::GAME_VERSION
      f.write("#{version}")
    }
  end
  def self.set_up_system
    SaveData.move_old_windows_save if System.platform[/Windows/]
    save_data = (SaveData.exists?) ? SaveData.read_from_file(SaveData::FILE_PATH) : {}
    if save_data.empty?
      SaveData.initialize_bootup_values
    else
      SaveData.load_bootup_values(save_data)
    end
    # Set resize factor
    pbSetResizeFactor([$PokemonSystem.screensize, 4].min)
    # Set language (and choose language if there is no save file)
    if Settings::LANGUAGES.length >= 2
      $PokemonSystem.language = pbChooseLanguage if save_data.empty?
      pbLoadMessages('Data/' + Settings::LANGUAGES[$PokemonSystem.language][1])
    end
    reset_custom_variables
    write_version
  end
end

module DailyE4
  Variable = 70
  TimeNow = 71
  LastTime = 72
end

Events.onMapChange += proc {| sender, e |
    # E4 Setting
    time = pbGetTimeNow
    $game_variables[DailyE4::LastTime] = time.day
    if $game_variables[DailyE4::TimeNow] > $game_variables[DailyE4::LastTime] || $game_variables[DailyE4::TimeNow]<$game_variables[DailyE4::LastTime]
      $game_variables[DailyE4::Variable] = 1+rand(100)
      $game_variables[DailyE4::TimeNow] = $game_variables[DailyE4::LastTime]
    end
    pbResetAllRoamers
    scene = Mission_Overlay.new
    scene.pbEndScene if scene != nil
}

Events.onStepTaken += proc {
  if $mission_steps != 0
    $mission_steps -= 1
    $viewport_mission.dispose if $mission_steps == 0
  end
}

def PokemonLoadScreen
  def pbStartLoadScreen
    commands = []
    cmd_continue     = -1
    cmd_new_game     = -1
    cmd_options      = -1
    cmd_language     = -1
    cmd_mystery_gift = -1
    cmd_debug        = -1
    cmd_quit         = -1
    show_continue = !@save_data.empty?
    if show_continue
      commands[cmd_continue = commands.length] = _INTL('Continue')
      if @save_data[:player].mystery_gift_unlocked
        commands[cmd_mystery_gift = commands.length] = _INTL('Mystery Gift')
      end
    end
    commands[cmd_new_game = commands.length]  = _INTL('New Game')
    commands[cmd_options = commands.length]   = _INTL('Options')
    commands[cmd_language = commands.length]  = _INTL('Language') if Settings::LANGUAGES.length >= 2
    commands[cmd_debug = commands.length]     = _INTL('Debug') if $DEBUG
    commands[cmd_quit = commands.length]      = _INTL('Quit Game')
    map_id = show_continue ? @save_data[:map_factory].map.map_id : 0
    @scene.pbStartScene(commands, show_continue, @save_data[:player],
                        @save_data[:frame_count] || 0, map_id)
    @scene.pbSetParty(@save_data[:player]) if show_continue
    @scene.pbStartScene2
    loop do
      command = @scene.pbChoose(commands)
      pbPlayDecisionSE if command != cmd_quit
      case command
      when cmd_continue
        @scene.pbEndScene
        write_version
        Game.load(@save_data)
        reset_custom_variables
        $repel_toggle = true
        return
      when cmd_new_game
        @scene.pbEndScene
        write_version
        Game.start_new
        reset_custom_variables
        repel_toggle = true
        return
      when cmd_mystery_gift
        pbFadeOutIn { pbDownloadMysteryGift(@save_data[:player]) }
      when cmd_options
        pbFadeOutIn do
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen(true)
        end
      when cmd_language
        @scene.pbEndScene
        $PokemonSystem.language = pbChooseLanguage
        pbLoadMessages('Data/' + Settings::LANGUAGES[$PokemonSystem.language][1])
        if show_continue
          @save_data[:pokemon_system] = $PokemonSystem
          File.open(SaveData::FILE_PATH, 'wb') { |file| Marshal.dump(@save_data, file) }
        end
        $scene = pbCallTitle
        return
      when cmd_debug
        pbFadeOutIn { pbDebugMenu(false) }
      when cmd_quit
        pbPlayCloseMenuSE
        @scene.pbEndScene
        $scene = nil
        return
      else
        pbPlayBuzzerSE
      end
    end
  end
end

EliteBattle::TRAINER_SPRITE_SCALE = 1
EliteBattle::CUSTOM_MOVE_ANIM = true

def poisonAllPokemon(event=nil)
    for pkmn in $Trainer.able_party
       next if pkmn.can_poison == false
       pkmn.status = :POISON
       pkmn.statusCount = 1
     end
end

def paralyzeAllPokemon(event=nil)
    for pkmn in $Trainer.able_party
       next if pkmn.hasType?(:ELECTRIC) ||
          pkmn.hasAbility?(:COMATOSE)  || pkmn.hasAbility?(:SHIELDSDOWN) || pkmn.hasAbility?(:LIMBER)
          pkmn.status!=0
       pkmn.status = :PARALYSIS
     end
end

def burnAllPokemon(event=nil)
    for pkmn in $Trainer.able_party
      next if pkmn.can_burn == false
      pkmn.status = :BURN
    end
end
module EnvironmentEBDX
  TEMPLE = {
    "backdrop" => "Sapphire",
    "vacuum" => "dark006",
    "img001" => {
      :scrolling => true, :vertical => true, :speed => 1,
      :bitmap => "decor003a",
      :oy => 180, :y => 90, :flat => true
    }, "img002" => {
      :bitmap => "shade",
      :oy => 100, :y => 98, :flat => false
    }, "img003" => {
      :scrolling => true, :speed => 16,
      :bitmap => "decor005",
      :oy => 0, :y => 4, :z => 4, :flat => true
    }, "img004" => {
      :scrolling => true, :speed => 16, :direction => -1,
      :bitmap => "decor006",
      :oy => 0, :z => 4, :flat => true
    }, "img005" => {
      :scrolling => true, :speed => 0.5,
      :bitmap => "base001a",
      :oy => 0, :y => 122, :z => 1, :flat => true
    }, "img006" => {
      :bitmap => "pillars",
      :oy => 100, :x => 96, :y => 98, :flat => false, :zoom => 0.5
    }
  }
  DESERT = { #{}"base" => "Dirt",
              "backdrop" => "Sand"
              }
  ELECTRIC = { #{}"base" => "Dirt",
              "backdrop" => "Electric"
              }
  GRASSY = { #{}"base" => "Dirt",
              "backdrop" => "Grassy"
              }
  MISTY = { #{}"base" => "Dirt",
              "backdrop" => "Misty"
              }
  PSYCHIC = { #{}"base" => "Dirt",
              "backdrop" => "Psychic"
              }
  POISON = { #{}"base" => "Dirt",
              "backdrop" => "Poison"
              }
end

class PokeBattle_Battle
  def pbHegemonyClauses
    self.rules["sleepclause"] = true
    self.rules["evasionclause"] = true
    if $game_switches[902] || $game_switches[903]
      self.rules["batonpassclause"] = true
    end
  end
  def pbCanSwitch?(idxBattler,idxParty=-1,partyScene=nil)
    # Check whether party Pokémon can switch in
    return false if !pbCanSwitchLax?(idxBattler,idxParty,partyScene)
    # Make sure another battler isn't already choosing to switch to the party
    # Pokémon
    eachSameSideBattler(idxBattler) do |b|
      next if choices[b.index][0]!=:SwitchOut || choices[b.index][1]!=idxParty
      partyScene.pbDisplay(_INTL("{1} has already been selected.",
         pbParty(idxBattler)[idxParty].name)) if partyScene
      return false
    end
    # Check whether battler can switch out
    battler = @battlers[idxBattler]
    return true if battler.fainted?
    # Ability/item effects that allow switching no matter what
    if battler.abilityActive?
      if BattleHandlers.triggerCertainSwitchingUserAbility(battler.ability,battler,self)
        return true
      end
    end
    if battler.itemActive?
      if BattleHandlers.triggerCertainSwitchingUserItem(battler.item,battler,self)
        return true
      end
    end
    # Other certain switching effects
    return true if Settings::MORE_TYPE_EFFECTS && battler.pbHasType?(:GHOST)
    # Other certain trapping effects
    if battler.effects[PBEffects::Octolock]==0 || battler.effects[PBEffects::Octolock]==1
      partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
      return false
    end
    if battler.effects[PBEffects::JawLock]
      @battlers.each do |b|
        if (battler.effects[PBEffects::JawLockUser] == b.index) && !b.fainted?
          partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
          return false
        end
      end
    end
    if battler.effects[PBEffects::Trapping]>0 ||
       battler.effects[PBEffects::MeanLook]>=0 ||
       battler.effects[PBEffects::Ingrain] ||
       battler.effects[PBEffects::NoRetreat] ||
       @field.effects[PBEffects::FairyLock]>0
      partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
      return false
    end
    # Trapping abilities/items
    eachOtherSideBattler(idxBattler) do |b|
      next if !b.abilityActive?
      if BattleHandlers.triggerTrappingTargetAbility(b.ability,battler,b,self)
        partyScene.pbDisplay(_INTL("{1}'s {2} prevents switching!",
           b.pbThis,b.abilityName)) if partyScene
        return false
      end
    end
    eachOtherSideBattler(idxBattler) do |b|
      next if !b.itemActive?
      if BattleHandlers.triggerTrappingTargetItem(b.item,battler,b,self)
        partyScene.pbDisplay(_INTL("{1}'s {2} prevents switching!",
           b.pbThis,b.itemName)) if partyScene
        return false
      end
    end
    return true
  end
  def removeAllHazards
    if @battlers[0].pbOwnSide.effects[PBEffects::StealthRock] || @battlers[0].pbOpposingSide.effects[PBEffects::StealthRock]
      @battlers[0].pbOwnSide.effects[PBEffects::StealthRock]      = false
      @battlers[0].pbOpposingSide.effects[PBEffects::StealthRock] = false
    end
    if @battlers[0].pbOwnSide.effects[PBEffects::Spikes]>0 || @battlers[0].pbOpposingSide.effects[PBEffects::Spikes]>0
      @battlers[0].pbOwnSide.effects[PBEffects::Spikes]      = 0
      @battlers[0].pbOpposingSide.effects[PBEffects::Spikes] = 0
    end
    if @battlers[0].pbOwnSide.effects[PBEffects::ToxicSpikes]>0 || @battlers[0].pbOpposingSide.effects[PBEffects::ToxicSpikes]>0
      @battlers[0].pbOwnSide.effects[PBEffects::ToxicSpikes]      = 0
      @battlers[0].pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0
    end
    if @battlers[0].pbOwnSide.effects[PBEffects::StickyWeb] || @battlers[0].pbOpposingSide.effects[PBEffects::StickyWeb]
      @battlers[0].pbOwnSide.effects[PBEffects::StickyWeb]      = false
      @battlers[0].pbOpposingSide.effects[PBEffects::StickyWeb] = false
    end
    if @battlers[0].pbOwnSide.effects[PBEffects::CometShards] || @battlers[0].pbOpposingSide.effects[PBEffects::CometShards]
      @battlers[0].pbOwnSide.effects[PBEffects::CometShards]      = false
      @battlers[0].pbOpposingSide.effects[PBEffects::CometShards] = false
    end
  end
  def poisonAllPokemon
      for pkmn in $Trainer.able_party
         next if pkmn.hasType?(:POISON)  || pkmn.hasType?(:STEEL) || pkmn.hasAbility?(:COMATOSE)  || pkmn.hasAbility?(:SHIELDSDOWN) || pkmn.hasAbility?(:IMMUNITY) || pkmn.status!=0
         pkmn.status = :POISON
         pkmn.statusCount = 1
       end
  end

  def paralyzeAllPokemon
      for pkmn in $Trainer.able_party
         next if pkmn.hasType?(:ELECTRIC) ||
            pkmn.hasAbility?(:COMATOSE)  || pkmn.hasAbility?(:SHIELDSDOWN) || pkmn.hasAbility?(:LIMBER)
            pkmn.status!=0
         pkmn.status = :PARALYSIS
       end
  end

  def burnAllPokemon
      for pkmn in $Trainer.able_party
         next if pkmn.can_burn == false
         pkmn.status = :BURN
       end
  end
end

class PokeBattle_Battler
  def can_burn
    if self.type1 == :FIRE || self.type2 == :FIRE || hasActiveAbility?(:COMATOSE)  || hasActiveAbility?(:SHIELDSDOWN) || hasActiveAbility?(:WATERBUBBLE) || hasActiveAbility?(:WATERVEIL) || self.status != :NONE
      return false
    else
      return true
    end
  end
  def can_poison
    if self.type1 == :POISON || self.type2 == :POISON || self.type1 == :STEEL || self.type2 == :POISON || hasActiveAbility?(:COMATOSE)  || hasActiveAbility?(:SHIELDSDOWN) || hasActiveAbility?(:IMMUNITY) || self.status != :NONE
      return false
    else
      return true
    end
  end
  def can_paralyze
    if pbHasType?(:ELECTRIC) || hasAbility?(:COMATOSE)  || hasAbility?(:SHIELDSDOWN) || hasAbility?(:LIMBER) || @status!=0
      return false
    else
      return true
    end
  end
  def can_sleep
    if hasAbility?(:COMATOSE)  || hasAbility?(:SHIELDSDOWN) || hasAbility?(:VITALSPIRIT) || hasAbility?(:CACOPHONY) || @effects[PBEffects::Uproar] != 0 || @status!=0
      return false
    else
      return true
    end
  end
  def can_freeze
    if pbHasType?(:ICE) || hasAbility?(:COMATOSE)  || hasAbility?(:SHIELDSDOWN) || hasAbility?(:MAGMAARMOR) || hasAbility?(:FLAMEBODY) || @status!=0
      return false
    else
      return true
    end
  end
  def unlosableItem?(check_item)
    return false if !check_item
    return true if GameData::Item.get(check_item).is_mail?
    return false if @effects[PBEffects::Transform]
    #return true if itemCorroded?
    # Items that change a Pokémon's form
    if mega?   # Check if item was needed for this Mega Evolution
      return true if @pokemon.species_data.mega_stone == check_item
    else   # Check if item could cause a Mega Evolution
      GameData::Species.each do |data|
        next if data.species != @species || data.unmega_form != @form
        return true if data.mega_stone == check_item
      end
    end
    if check_item == :ROTOMMULTITOOL || check_item == :WSHARPEDONITE || check_item == :WBLAZIKENITE || check_item == :WGARCHOMPITE || check_item == :WSCEPTILITE || check_item == :WSWAMPERTITE || check_item == :WCHIMECHONITE || check_item == :CHATOTITE || check_item == :CORVITE || check_item == :EMPOLEONITE || check_item == :TORTERRANITE || check_item == :INFERNITE || check_item == :CHIMECHONITE || check_item == :BEHEEYEMITE || check_item == :CASTFORMITE
      return true
    end
    # Other unlosable items
    return GameData::Item.get(check_item).unlosable?(@species, self.ability)
  end
end

class Pokemon
  def can_burn
    if self.type1 == :FIRE || self.type2 == :FIRE || self.ability == :COMATOSE || self.ability == :SHIELDSDOWN || self.ability == :WATERBUBBLE || self.ability == :WATERVEIL || self.status != :NONE
      return false
    else
      return true
    end
  end
  def can_poison
    if self.type1 == :POISON || self.type2 == :POISON || self.type1 == :STEEL || self.type2 == :STEEL || self.ability == :COMATOSE || self.ability == :SHIELDSDOWN || self.ability == :IMMUNITY || self.status != :NONE
      return false
    else
      return true
    end
  end
  def can_paralyze
    if pbHasType?(:ELECTRIC) || hasAbility?(:COMATOSE)  || hasAbility?(:SHIELDSDOWN) || hasAbility?(:LIMBER) || @status!=0
      return false
    else
      return true
    end
  end
  def can_sleep
    if hasAbility?(:COMATOSE)  || hasAbility?(:SHIELDSDOWN) || hasAbility?(:VITALSPIRIT) || hasAbility?(:CACOPHONY) || @effects[PBEffects::Uproar] != 0 || @status!=0
      return false
    else
      return true
    end
  end
  def can_freeze
    if pbHasType?(:ICE) || hasAbility?(:COMATOSE)  || hasAbility?(:SHIELDSDOWN) || hasAbility?(:MAGMAARMOR) || hasAbility?(:FLAMEBODY) || @status!=0
      return false
    else
      return true
    end
  end
  def poisonAllPokemon
      for pkmn in $Trainer.able_party
        next if !pkmn.can_poison
        pkmn.status = :POISON
        pkmn.statusCount = 1
      end
  end

  def paralyzeAllPokemon
      for pkmn in $Trainer.able_party
         next if pkmn.hasType?(:ELECTRIC) ||
            pkmn.hasAbility?(:COMATOSE)  || pkmn.hasAbility?(:SHIELDSDOWN) || pkmn.hasAbility?(:LIMBER)
            pkmn.status!=0
         pkmn.status = :PARALYSIS
       end
  end

  def burnAllPokemon
      for pkmn in $Trainer.able_party
         next if pkmn.can_burn == false
         pkmn.status = :BURN
       end
  end
  def shiny_locked?
    blacklist = []
    for i in 899..950
      blacklist.push(i)
    end
    for j in 958..992
      blacklist.push(j)
    end
    for k in 994..1012
      blacklist.push(k)
    end
    pkmn = GameData::Species.get(self.species).id_number
    return blacklist.include?(pkmn)
  end
end

def encounters_randomized?
  if $game_switches[LvlCap::Randomizer] || $game_switches[LvlCap::Kaizo]
    return true
  end
  return false
end

Events.onWildPokemonCreate+=proc {|sender,e|
  pokemon = e[0]
  levelcap = LEVEL_CAP[$game_system.level_cap]
  abilRand = rand(100)
  if abilRand > 80 && $game_map.map_id == 91 && $currentDexSearch == nil
    pokemon.ability_index = 2
  end
  if $game_map.map_id == 78 || $game_map.map_id == 223 || $game_map.map_id == 226
    pokemon.form = 1
    if abilRand > 80
      pokemon.ability_index = 2
    end
  end
  if $game_map.map_id == 110
    formRand = rand(29)
    pokemon.form = formRand
  end
  if pokemon.shiny_locked?
    pokemon.shiny = false
  end
  mlv = $Trainer.party.map { |e| e.level  }.max
  level = mlv - 1 -rand(2)
  pokemon.species = Level_Scaling.evolve(pokemon,level,levelcap) if encounters_randomized? == false
  pokemon.level = level <= 0 ? 1 : level
  if pokemon.level > LEVEL_CAP[$game_system.level_cap]
    $game_switches[89] = true
  end
  pokemon.calc_stats
  pokemon.reset_moves
  $viewport_mission.dispose if $viewport_mission != nil
}

Events.onEndBattle += proc { |_sender,e|
  $game_switches[89] = false
  $CanToggle = true
  $repel_toggle = true
  if $game_switches[LvlCap::Ironmon] || $game_switches[902] == true
    for i in 0...$Trainer.party.length
      k = $Trainer.party.length - 1 - i
      if $Trainer.party[k].hp <= 0
        $PokemonBag.pbStoreItem($Trainer.party[k].item, 1) if $Trainer.party[k].item
        $Trainer.remove_pokemon_at_index(k)
      end
    end
  end
  $viewport.dispose
}

def pbStartOver(gameover=false)
  if pbInBugContest?
    pbBugContestStartOver
    return
  end
  $Trainer.heal_party
  if $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId>=0
    if $game_switches[902] || $game_switches[LvlCap::Ironmon]
      gameover = true
    end
    if gameover
      pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, you scurry back to a Pokémon Center."))
      pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]Pokémon Hegemony will now close..."))
      SaveData.delete_file
      raise SystemExit.new
    else
      if $game_switches[73] == true
        pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After losing the Nuzlocke, you scurry back to a Pokémon Center, protecting your exhausted Pokémon from any further harm..."))
        pbCancelVehicles
        pbRemoveDependencies
        $game_switches[Settings::STARTING_OVER_SWITCH] = true
        if $PokemonGlobal.pokemonSelectionOriginalParty!=nil
          PokemonSelection.restore
        end
        $CanToggle = true
        $gym_gimmick = false
        $game_temp.player_new_map_id    = $PokemonGlobal.pokecenterMapId
        $game_temp.player_new_x         = $PokemonGlobal.pokecenterX
        $game_temp.player_new_y         = $PokemonGlobal.pokecenterY
        $game_temp.player_new_direction = $PokemonGlobal.pokecenterDirection
        $scene.transfer_player if $scene.is_a?(Scene_Map)
        $game_map.refresh
        $game_switches[119] = false
      else
        pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You scurry back to a Pokémon Center, protecting your exhausted Pokémon from any further harm..."))
        pbCancelVehicles
        pbRemoveDependencies
        $game_switches[Settings::STARTING_OVER_SWITCH] = true
        if $PokemonGlobal.pokemonSelectionOriginalParty!=nil
          PokemonSelection.restore
        end
        $CanToggle = true
        $gym_gimmick = false
        $game_temp.player_new_map_id    = $PokemonGlobal.pokecenterMapId
        $game_temp.player_new_x         = $PokemonGlobal.pokecenterX
        $game_temp.player_new_y         = $PokemonGlobal.pokecenterY
        $game_temp.player_new_direction = $PokemonGlobal.pokecenterDirection
        $scene.transfer_player if $scene.is_a?(Scene_Map)
        $game_map.refresh
        $game_switches[119] = false
        randomizer_on
      end
    end
  else
    homedata = GameData::Metadata.get.home
    if homedata && !pbRgssExists?(sprintf("Data/Map%03d.rxdata",homedata[0]))
      if $DEBUG
        pbMessage(_ISPRINTF("Can't find the map 'Map{1:03d}' in the Data folder. The game will resume at the player's position.",homedata[0]))
      end
      $Trainer.heal_party
      return
    end
    if gameover
      pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, you scurry back home."))
    else
      if $game_switches[73] == true
        pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After losing the Nuzlocke, you scurry back home, protecting your exhausted Pokémon from any further harm..."))
      else
        pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You scurry back home, protecting your exhausted Pokémon from any further harm..."))
      end
    end
    if homedata
      pbCancelVehicles
      pbRemoveDependencies
      $game_switches[Settings::STARTING_OVER_SWITCH] = true
      $game_switches[73] = false
      $CanToggle = true
      $gym_gimmick = false
      if $PokemonGlobal.pokemonSelectionOriginalParty!=nil
        PokemonSelection.restore
      end
      if $game_switches[60]
        homedata[0] = 356
      end
      $game_temp.player_new_map_id    = homedata[0]
      $game_temp.player_new_x         = homedata[1]
      $game_temp.player_new_y         = homedata[2]
      $game_temp.player_new_direction = homedata[3]
      $scene.transfer_player if $scene.is_a?(Scene_Map)
      $game_map.refresh
      $game_switches[119] = false
      randomizer_on
    else
      $Trainer.heal_party
    end
  end
  pbEraseEscapePoint
end

class Trainer
  def heal_party
    if $game_switches[73] == true
      pbEachPokemon { |poke,_box| poke.heal if !poke.fainted?}
    else
      pbEachPokemon { |poke,_box| poke.heal}
    end
  end
end
class PokemonTemp
  def pbPrepareBattle(battle)
    battleRules = $PokemonTemp.battleRules
    # The size of the battle, i.e. how many Pokémon on each side (default: "single")
    battle.setBattleMode(battleRules["size"]) if !battleRules["size"].nil?
    # Whether the game won't black out even if the player loses (default: false)
    battle.canLose = battleRules["canLose"] if !battleRules["canLose"].nil?
    # Whether the player can choose to run from the battle (default: true)
    battle.canRun = battleRules["canRun"] if !battleRules["canRun"].nil?
    # Whether wild Pokémon always try to run from battle (default: nil)
    battle.rules["alwaysflee"] = battleRules["roamerFlees"]
    # Whether Pokémon gain Exp/EVs from defeating/catching a Pokémon (default: true)
    battle.expGain = battleRules["expGain"] if !battleRules["expGain"].nil?
    # Whether the player gains/loses money at the end of the battle (default: true)
    battle.moneyGain = battleRules["moneyGain"] if !battleRules["moneyGain"].nil?
    # Whether the player is able to switch when an opponent's Pokémon faints
    battle.switchStyle = ($PokemonSystem.battlestyle==0)
    battle.switchStyle = battleRules["switchStyle"] if !battleRules["switchStyle"].nil?
    # Whether battle animations are shown
    battle.showAnims = ($PokemonSystem.battlescene==0)
    battle.showAnims = battleRules["battleAnims"] if !battleRules["battleAnims"].nil?
    # Terrain
    battle.defaultTerrain = battleRules["defaultTerrain"] if !battleRules["defaultTerrain"].nil?
    # Weather
    if battleRules["defaultWeather"].nil?
      battle.defaultWeather = $game_screen.weather_type
    else
      battle.defaultWeather = battleRules["defaultWeather"]
    end
    # Environment
    if battleRules["environment"].nil?
      battle.environment = pbGetEnvironment
    else
      battle.environment = battleRules["environment"]
    end
    # Backdrop graphic filename
    if !battleRules["backdrop"].nil?
      backdrop = battleRules["backdrop"]
    elsif $PokemonGlobal.nextBattleBack
      backdrop = $PokemonGlobal.nextBattleBack
    elsif $PokemonGlobal.surfing
      backdrop = "water"   # This applies wherever you are, including in caves
    elsif GameData::MapMetadata.exists?($game_map.map_id)
      back = GameData::MapMetadata.get($game_map.map_id).battle_background
      backdrop = back if back && back != ""
    end
    backdrop = "indoor1" if !backdrop
    battle.backdrop = backdrop
    # Choose a name for bases depending on environment
    if battleRules["base"].nil?
      environment_data = GameData::Environment.try_get(battle.environment)
      base = environment_data.battle_base if environment_data
    else
      base = battleRules["base"]
    end
    battle.backdropBase = base if base
    # Time of day
    if GameData::MapMetadata.exists?($game_map.map_id) &&
       GameData::MapMetadata.get($game_map.map_id).battle_environment == :Cave
      battle.time = 2   # This makes Dusk Balls work properly in caves
    elsif Settings::TIME_SHADING
      timeNow = pbGetTimeNow
      if PBDayNight.isNight?(timeNow);      battle.time = 2
      elsif PBDayNight.isEvening?(timeNow); battle.time = 1
      else;                                 battle.time = 0
      end
    end
  end
end

class PokeBattle_Battle
  def pbStartBattleCore
    # Set up the battlers on each side
    if $game_switches[899] && $game_switches[900]
      pbHegemonyClauses
    end
    sendOuts = pbSetUpSides
    olditems = []
    pbParty(0).each_with_index do |pkmn,i|
      item = pkmn.item_id
      olditems.push(item)
    end
    $olditems = olditems
    # Create all the sprites and play the battle intro animation
    @field.weather = $game_screen.weather_type
    @scene.pbStartBattle(self)
    # Show trainers on both sides sending out Pokémon
    pbStartBattleSendOut(sendOuts)
    # Weather announcement
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if weather_data
    case @field.weather
    when :Sun         then pbDisplay(_INTL("The sunlight is strong."))
    when :Rain        then pbDisplay(_INTL("It is raining."))
    when :Sandstorm   then pbDisplay(_INTL("A sandstorm is raging."))
    when :Hail        then pbDisplay(_INTL("Snow is falling."))
    when :HarshSun    then pbDisplay(_INTL("The sunlight is extremely harsh."))
    when :HeavyRain   then pbDisplay(_INTL("It is raining heavily."))
    when :StrongWinds then pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky   then pbDisplay(_INTL("The sky is shadowy."))
    when :Starstorm  then pbDisplay(_INTL("Stars fill the sky."))
    when :Thunder    then pbDisplay(_INTL("Lightning flashes in the sky."))
    when :Storm      then pbDisplay(_INTL("A thunderstorm rages. The ground became electrified!"))
    when :Humid      then pbDisplay(_INTL("The air is humid."))
    #when :Overcast   then pbDisplay(_INTL("The sky is overcast."))
    when :Eclipse    then pbDisplay(_INTL("The sky is dark."))
    when :Fog        then pbDisplay(_INTL("The fog is deep."))
    when :AcidRain   then pbDisplay(_INTL("Acid rain is falling."))
    when :VolcanicAsh then pbDisplay(_INTL("Volcanic Ash sprinkles down."))
    when :Rainbow    then pbDisplay(_INTL("A rainbow crosses the sky."))
    when :Borealis   then pbDisplay(_INTL("The sky is ablaze with color."))
    when :TimeWarp   then pbDisplay(_INTL("Time has stopped."))
    when :Reverb     then pbDisplay(_INTL("A dull echo hums."))
    when :DClear     then pbDisplay(_INTL("The sky is distorted."))
    when :DRain      then pbDisplay(_INTL("Rain is falling upward."))
    when :DWind      then pbDisplay(_INTL("The wind is haunting."))
    when :DAshfall   then pbDisplay(_INTL("Ash floats in midair."))
    when :Sleet      then pbDisplay(_INTL("Sleet began to fall."))
    when :Windy      then pbDisplay(_INTL("There is a slight breeze."))
    when :HeatLight  then pbDisplay(_INTL("Static fills the air."))
    when :DustDevil  then pbDisplay(_INTL("A dust devil approaches."))
    end
    # Terrain announcement
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    case @field.terrain
    when :Electric
      pbDisplay(_INTL("An electric current runs across the battlefield!"))
    when :Grassy
      pbDisplay(_INTL("Grass is covering the battlefield!"))
    when :Misty
      pbDisplay(_INTL("Mist swirls about the battlefield!"))
    when :Psychic
      pbDisplay(_INTL("The battlefield is weird!"))
    when :Poison
      pbDisplay(_INTL("Toxic waste covers the ground!"))
    end
    # Abilities upon entering battle
    pbOnActiveAll
    # Main battle loop
    pbBattleLoop
  end

  def pbEndOfBattle
    #$mega_flag = 0
    oldDecision = @decision
    @decision = 4 if @decision==1 && wildBattle? && @caughtPokemon.length>0
    case oldDecision
    ##### WIN #####
    when 1
      PBDebug.log("")
      PBDebug.log("***Player won***")
      if trainerBattle?
        @scene.pbTrainerBattleSuccess
        case @opponent.length
        when 1
          pbDisplayPaused(_INTL("You defeated {1}!",@opponent[0].full_name))
        when 2
          pbDisplayPaused(_INTL("You defeated {1} and {2}!",@opponent[0].full_name,
             @opponent[1].full_name))
        when 3
          pbDisplayPaused(_INTL("You defeated {1}, {2} and {3}!",@opponent[0].full_name,
             @opponent[1].full_name,@opponent[2].full_name))
        end
        @opponent.each_with_index do |_t,i|
          @scene.pbShowOpponent(i)
          msg = (@endSpeeches[i] && @endSpeeches[i]!="") ? @endSpeeches[i] : "..."
          pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name))
        end
      end
      # Gain money from winning a trainer battle, and from Pay Day
      pbGainMoney if @decision!=4
      # Hide remaining trainer
      @scene.pbShowOpponent(@opponent.length) if trainerBattle? && @caughtPokemon.length>0
    ##### LOSE, DRAW #####
    when 2, 5
      PBDebug.log("")
      PBDebug.log("***Player lost***") if @decision==2
      PBDebug.log("***Player drew with opponent***") if @decision==5
      if @internalBattle
        pbDisplayPaused(_INTL("You have no more Pokémon that can fight!"))
        if trainerBattle?
          case @opponent.length
          when 1
            pbDisplayPaused(_INTL("You lost against {1}!",@opponent[0].full_name))
          when 2
            pbDisplayPaused(_INTL("You lost against {1} and {2}!",
               @opponent[0].full_name,@opponent[1].full_name))
          when 3
            pbDisplayPaused(_INTL("You lost against {1}, {2} and {3}!",
               @opponent[0].full_name,@opponent[1].full_name,@opponent[2].full_name))
          end
        end
        # Lose money from losing a battle
        pbLoseMoney
        pbDisplayPaused(_INTL("You blacked out!")) if !@canLose
      elsif @decision==2
        if @opponent
          @opponent.each_with_index do |_t,i|
            @scene.pbShowOpponent(i)
            msg = (@endSpeechesWin[i] && @endSpeechesWin[i]!="") ? @endSpeechesWin[i] : "..."
            pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name))
          end
        end
      end
    ##### CAUGHT WILD POKÉMON #####
    when 4
      @scene.pbWildBattleSuccess if !Settings::GAIN_EXP_FOR_CAPTURE
    end
    # Register captured Pokémon in the Pokédex, and store them
    pbRecordAndStoreCaughtPokemon
    # Collect Pay Day money in a wild battle that ended in a capture
    pbGainMoney if @decision==4
    # Pass on Pokérus within the party
    if @internalBattle
      infected = []
      $Trainer.party.each_with_index do |pkmn,i|
        infected.push(i) if pkmn.pokerusStage==1
      end
      infected.each do |idxParty|
        strain = $Trainer.party[idxParty].pokerusStrain
        if idxParty>0 && $Trainer.party[idxParty-1].pokerusStage==0
          $Trainer.party[idxParty-1].givePokerus(strain) if rand(3)==0   # 33%
        end
        if idxParty<$Trainer.party.length-1 && $Trainer.party[idxParty+1].pokerusStage==0
          $Trainer.party[idxParty+1].givePokerus(strain) if rand(3)==0   # 33%
        end
      end
    end
    # Clean up battle stuff
    @scene.pbEndBattle(@decision)
    @battlers.each do |b|
      next if !b
      pbCancelChoice(b.index)   # Restore unused items to Bag
      BattleHandlers.triggerAbilityOnSwitchOut(b.ability,b,true) if b.abilityActive?
    end
    pbParty(0).each_with_index do |pkmn,i|
      next if !pkmn
      @peer.pbOnLeavingBattle(self,pkmn,@usedInBattle[0][i],true)   # Reset form
      if pkmn.fainted? && $game_switches[902]
        $PokemonBag.pbStoreItem(pkmn.item, 1) if pkmn.item
        $Trainer.party.delete_at(pkmn.index)
        $PokemonTemp.evolutionLevels.delete_at(pkmn.index)
      end
      if @opponent
        pkmn.item = $olditems[i]
      else
        pkmn.item = @initialItems[0][i]
      end
    end
    @scene.pbTrainerBattleSpeech("loss") if @decision == 2
    # reset all the EBDX queues
    EliteBattle.reset(:nextBattleScript, :wildSpecies, :wildLevel, :wildForm, :nextBattleBack, :nextUI, :nextBattleData,
                     :wildSpecies, :wildLevel, :wildForm, :setBoss, :cachedBattler, :tviewport)
    EliteBattle.set(:setBoss, false)
    EliteBattle.set(:colorAlpha, 0)
    EliteBattle.set(:smAnim, false)
    $game_switches[89] = false
    # return final output
    return @decision
  end

  def pbGainExpOne(idxParty,defeatedBattler,numPartic,expShare,expAll,showMessages=true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining EVs from defeatedBattler
    growth_rate = pkmn.growth_rate
    # Don't bother calculating if gainer is already at max Exp
    if pkmn.exp>=growth_rate.maximum_exp
      pkmn.calc_stats   # To ensure new EVs still have an effect
      return
    end
    isPartic    = defeatedBattler.participants.include?(idxParty)
    hasExpShare = expShare.include?(idxParty)
    level = defeatedBattler.level
    level_cap = $game_switches[Settings::LEVEL_CAP_SWITCH] ? LEVEL_CAP[$game_system.level_cap] : Settings::MAXIMUM_LEVEL
    if $game_switches[Settings::LEVEL_CAP_SWITCH]
      level_cap_gap = growth_rate.exp_values[level_cap] - pkmn.exp
    end
    # Main Exp calculation
    exp = 0
    a = level*defeatedBattler.pokemon.base_exp
    if expShare.length>0 && (isPartic || hasExpShare)
      if numPartic==0   # No participants, all Exp goes to Exp Share holders
        exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? expShare.length : 1)
      elsif Settings::SPLIT_EXP_BETWEEN_GAINERS   # Gain from participating and/or Exp Share
        exp = a/(2*numPartic) if isPartic
        exp += a/(2*expShare.length) if hasExpShare
      else   # Gain from participating and/or Exp Share (Exp not split)
        exp = (isPartic) ? a : a/2
      end
    elsif isPartic   # Participated in battle, no Exp Shares held by anyone
      exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? numPartic : 1)
    elsif expAll   # Didn't participate in battle, gaining Exp due to Exp All
      # NOTE: Exp All works like the Exp Share from Gen 6+, not like the Exp All
      #       from Gen 1, i.e. Exp isn't split between all Pokémon gaining it.
      exp = a/2
    end
    return if exp<=0
    # Pokémon gain more Exp from trainer battles
    exp = (exp*1.5).floor if trainerBattle?
    # Scale the gained Exp based on the gainer's level (or not)
    if Settings::SCALED_EXP_FORMULA
      exp /= 5
      levelAdjust = (2*level+10.0)/(pkmn.level+level+10.0)
      levelAdjust = levelAdjust**5
      levelAdjust = Math.sqrt(levelAdjust)
      exp *= levelAdjust
      exp = exp.floor
      exp += 1 if isPartic || hasExpShare
      if pkmn.level >= level_cap
        exp /= 250
      end
      if $game_switches[Settings::LEVEL_CAP_SWITCH]
        if exp >= level_cap_gap
          exp = level_cap_gap + 1
        end
      end
    else
      if $game_switches[Settings::LEVEL_CAP_SWITCH]
        if a <= level_cap_gap
          exp = a
        else
          exp /= 7
        end
      end
    end
    # Foreign Pokémon gain more Exp
    isOutsider = (pkmn.owner.id != pbPlayer.id ||
                 (pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language))
    if isOutsider
      if pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language
        exp = (exp*1.7).floor
      else
        exp = (exp*1.5).floor
      end
    end
    # Modify Exp gain based on pkmn's held item
    i = BattleHandlers.triggerExpGainModifierItem(pkmn.item,pkmn,exp)
    if i<0
      i = BattleHandlers.triggerExpGainModifierItem(@initialItems[0][idxParty],pkmn,exp)
    end
    exp = i if i>=0
    # Make sure Exp doesn't exceed the maximum
    expFinal = growth_rate.add_exp(pkmn.exp, exp)
    expGained = expFinal-pkmn.exp
    return if expGained<=0
    # "Exp gained" message
    if showMessages
      if isOutsider
        pbDisplayPaused(_INTL("{1} got a boosted {2} Exp. Points!",pkmn.name,expGained))
      else
        pbDisplayPaused(_INTL("{1} got {2} Exp. Points!",pkmn.name,expGained))
      end
    end
    curLevel = pkmn.level
    newLevel = growth_rate.level_from_exp(expFinal)
    if newLevel<curLevel
      debugInfo = "Levels: #{curLevel}->#{newLevel} | Exp: #{pkmn.exp}->#{expFinal} | gain: #{expGained}"
      raise RuntimeError.new(
         _INTL("{1}'s new level is less than its\r\ncurrent level, which shouldn't happen.\r\n[Debug: {2}]",
         pkmn.name,debugInfo))
    end
    # Give Exp
    if pkmn.shadowPokemon?
      pkmn.exp += expGained
      return
    end
    tempExp1 = pkmn.exp
    battler = pbFindBattler(idxParty)
    loop do   # For each level gained in turn...
      # EXP Bar animation
      levelMinExp = growth_rate.minimum_exp_for_level(curLevel)
      levelMaxExp = growth_rate.minimum_exp_for_level(curLevel + 1)
      tempExp2 = (levelMaxExp<expFinal) ? levelMaxExp : expFinal
      pkmn.exp = tempExp2
      @scene.pbEXPBar(battler,levelMinExp,levelMaxExp,tempExp1,tempExp2)
      tempExp1 = tempExp2
      curLevel += 1
      if curLevel>newLevel
        # Gained all the Exp now, end the animation
        pkmn.calc_stats
        battler.pbUpdate(false) if battler
        @scene.pbRefreshOne(battler.index) if battler
        break
      end
      # Levelled up
      pbCommonAnimation("LevelUp",battler) if battler
      oldTotalHP = pkmn.totalhp
      oldAttack  = pkmn.attack
      oldDefense = pkmn.defense
      oldSpAtk   = pkmn.spatk
      oldSpDef   = pkmn.spdef
      oldSpeed   = pkmn.speed
      if battler && battler.pokemon
        battler.pokemon.changeHappiness("levelup")
      end
      pkmn.calc_stats
      battler.pbUpdate(false) if battler
      @scene.pbRefreshOne(battler.index) if battler
      pbDisplayPaused(_INTL("{1} grew to Lv. {2}!",pkmn.name,curLevel))
      @scene.pbLevelUp(pkmn,battler,oldTotalHP,oldAttack,oldDefense,
                                    oldSpAtk,oldSpDef,oldSpeed)
      # Learn all moves learned at this level
      moveList = pkmn.getMoveList
      moveList.each { |m| pbLearnMove(idxParty,m[1]) if m[0]==curLevel }
    end
  end

  def pbOnActiveOne(battler)
    return false if battler.fainted?
    # Introduce Shadow Pokémon
    if battler.opposes? && battler.shadowPokemon?
      pbCommonAnimation("Shadow",battler)
      pbDisplay(_INTL("Oh!\nA Shadow Pokémon!"))
    end
    # Record money-doubling effect of Amulet Coin/Luck Incense
    if !battler.opposes? && [:AMULETCOIN, :LUCKINCENSE].include?(battler.item_id)
      @field.effects[PBEffects::AmuletCoin] = true
    end
    # Update battlers' participants (who will gain Exp/EVs when a battler faints)
    eachBattler { |b| b.pbUpdateParticipants }
    # Healing Wish
    if @positions[battler.index].effects[PBEffects::HealingWish]
      pbCommonAnimation("HealingWish",battler)
      pbDisplay(_INTL("The healing wish came true for {1}!",battler.pbThis(true)))
      battler.pbRecoverHP(battler.totalhp)
      battler.pbCureStatus(false)
      @positions[battler.index].effects[PBEffects::HealingWish] = false
    end
    # Lunar Dance
    if @positions[battler.index].effects[PBEffects::LunarDance]
      pbCommonAnimation("LunarDance",battler)
      pbDisplay(_INTL("{1} became cloaked in mystical moonlight!",battler.pbThis))
      battler.pbRecoverHP(battler.totalhp)
      battler.pbCureStatus(false)
      battler.eachMove { |m| m.pp = m.total_pp }
      @positions[battler.index].effects[PBEffects::LunarDance] = false
    end
    # Entry hazards
    # Stealth Rock
    if battler.pbOwnSide.effects[PBEffects::StealthRock] && battler.takesIndirectDamage? &&
       GameData::Type.exists?(:ROCK) && battler.takesEntryHazardDamage? && !battler.hasActiveAbility?(:SCALER)
      bTypes = battler.pbTypes(true)
      eff = Effectiveness.calculate(:ROCK, bTypes[0], bTypes[1], bTypes[2])
      if !Effectiveness.ineffective?(eff)
        eff = eff.to_f / Effectiveness::NORMAL_EFFECTIVE
        oldHP = battler.hp
        battler.pbReduceHP(battler.totalhp*eff/8,false)
        pbDisplay(_INTL("Pointed stones dug into {1}!",battler.pbThis))
        battler.pbItemHPHealCheck
        if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
          return pbOnActiveOne(battler)   # For replacement battler
        end
      end
    end
    #Comet Shards
    if battler.pbOwnSide.effects[PBEffects::CometShards] && battler.takesIndirectDamage? &&
       GameData::Type.exists?(:COSMIC) && battler.takesEntryHazardDamage?
      bTypes = battler.pbTypes(true)
      eff = Effectiveness.calculate(:COSMIC, bTypes[0], bTypes[1], bTypes[2])
      if battler.pbHasType?(:COSMIC)
        battler.pbOwnSide.effects[PBEffects::CometShards] = false
        pbDisplay(_INTL("{1} absorbed the Comet Shards!",battler.pbThis))
      elsif !Effectiveness.ineffective?(eff)
        eff = eff.to_f / Effectiveness::NORMAL_EFFECTIVE
        oldHP = battler.hp
        battler.pbReduceHP(battler.totalhp*eff/8,false)
        pbDisplay(_INTL("Pointed stones dug into {1}!",battler.pbThis))
        battler.pbItemHPHealCheck
        if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
          return pbOnActiveOne(battler)   # For replacement battler
        end
      end
    end
    # Spikes
    if battler.pbOwnSide.effects[PBEffects::Spikes]>0 && battler.takesIndirectDamage? &&
       !battler.airborne? && battler.takesEntryHazardDamage?
      spikesDiv = [8,6,4][battler.pbOwnSide.effects[PBEffects::Spikes]-1]
      oldHP = battler.hp
      battler.pbReduceHP(battler.totalhp/spikesDiv,false)
      pbDisplay(_INTL("{1} is hurt by the spikes!",battler.pbThis))
      battler.pbItemHPHealCheck
      if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
        return pbOnActiveOne(battler)   # For replacement battler
      end
    end
    # Toxic Spikes
    if battler.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 && !battler.fainted? &&
       !battler.airborne?
      if battler.pbHasType?(:POISON)
        battler.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
        pbDisplay(_INTL("{1} absorbed the poison spikes!",battler.pbThis))
      elsif battler.pbCanPoison?(nil,false) && battler.takesEntryHazardDamage?
        if battler.pbOwnSide.effects[PBEffects::ToxicSpikes]==2
          battler.pbPoison(nil,_INTL("{1} was badly poisoned by the poison spikes!",battler.pbThis),true)
        else
          battler.pbPoison(nil,_INTL("{1} was poisoned by the poison spikes!",battler.pbThis))
        end
      end
    end
    # Sticky Web
    if battler.pbOwnSide.effects[PBEffects::StickyWeb] && !battler.fainted? &&
       !battler.airborne? && battler.takesEntryHazardDamage?
      pbDisplay(_INTL("{1} was caught in a sticky web!",battler.pbThis))
      if battler.pbCanLowerStatStage?(:SPEED)
        stickyuser = (battler.pbOwnSide.effects[PBEffects::StickyWebUser] > -1 ?
          battlers[battler.pbOwnSide.effects[PBEffects::StickyWebUser]] : nil)
        battler.pbLowerStatStage(:SPEED,1,stickyuser)
        battler.pbItemStatRestoreCheck
      end
    end
    # Battler faints if it is knocked out because of an entry hazard above
    if battler.fainted?
      battler.pbFaint
      pbGainExp
      pbJudge
      return false
    end
    battler.pbCheckForm
    return true
  end

  def pbEORWeather(priority)
    # NOTE: Primordial weather doesn't need to be checked here, because if it
    #       could wear off here, it will have worn off already.
    # Count down weather duration
    if @field.weather != $game_screen.weather_type
      @field.weatherDuration -= 1 if @field.weatherDuration>0
    else
      @field.weatherDuration = 1
    end
    # Weather wears off
    if @field.weatherDuration==0 && $gym_weather == false
      case @field.weather
      when :Sun       then pbDisplay(_INTL("The sunlight faded."))
      when :Rain      then pbDisplay(_INTL("The rain stopped."))
      when :Sandstorm then pbDisplay(_INTL("The sandstorm subsided."))
      when :Hail      then pbDisplay(_INTL("The snow stopped."))
      when :ShadowSky then pbDisplay(_INTL("The shadow sky faded."))
      when :Starstorm then pbDisplay(_INTL("The stars have faded."))
      when :Storm then pbDisplay(_INTL("The storm has calmed."))
      when :Humid then pbDisplay(_INTL("The humidity has lowered."))
      #when :Overcast then pbDisplay(_INTL("The clouds have cleared."))
      when :Eclipse then pbDisplay(_INTL("The sky brightened."))
      when :Fog then pbDisplay(_INTL("The fog has lifted."))
      when :AcidRain then pbDisplay(_INTL("The acid rain has stopped."))
      when :VolcanicAsh then pbDisplay(_INTL("The ash dissolved."))
      when :Rainbow then pbDisplay(_INTL("The rainbow disappeared."))
      when :Borealis then pbDisplay(_INTL("The sky has calmed."))
      when :DClear then pbDisplay(_INTL("The sky returned to normal."))
      when :DRain then pbDisplay(_INTL("The rain has stopped."))
      when :DWind then pbDisplay(_INTL("The wind has passed."))
      when :DAshfall then pbDisplay(_INTL("The ash disintegrated."))
      when :Sleet then pbDisplay(_INTL("The sleet lightened."))
      when :Windy then pbDisplay(_INTL("The wind died down."))
      when :HeatLight then pbDisplay(_INTL("The air has calmed."))
      when :TimeWarp then pbDisplay(_INTL("Time began to move again."))
      when :Reverb then pbDisplay(_INTL("Silence fell once more."))
      when :DustDevil then pbDisplay(_INTL("The dust devil dissipated."))
      end
      @field.weather = :None
      # Check for form changes caused by the weather changing
      eachBattler { |b| b.pbCheckFormOnWeatherChange }
      # Start up the default weather
      pbStartWeather(nil,$game_screen.weather_type) if $game_screen.weather_type != :None
      return if @field.weather == :None
    end
    # Weather continues
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if weather_data
    case @field.weather
#    when :Sun         then pbDisplay(_INTL("The sunlight is strong."))
#    when :Rain        then pbDisplay(_INTL("Rain continues to fall."))
    when :Sandstorm   then pbDisplay(_INTL("The sandstorm is raging."))
    when :Hail        then pbDisplay(_INTL("The snow is falling."))
#    when :HarshSun    then pbDisplay(_INTL("The sunlight is extremely harsh."))
#    when :HeavyRain   then pbDisplay(_INTL("It is raining heavily."))
#    when :StrongWinds then pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky   then pbDisplay(_INTL("The shadow sky continues."))
    end
    # Effects due to weather
    curWeather = pbWeather
    priority.each do |b|
      # Weather-related abilities
      if b.abilityActive?
        BattleHandlers.triggerEORWeatherAbility(b.ability,curWeather,b,self)
        b.pbFaint if b.fainted?
      end
      # Weather damage
      # NOTE:
      case curWeather
      when :Sandstorm
        next if !b.takesSandstormDamage?
        pbDisplay(_INTL("{1} is buffeted by the sandstorm!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Hail
        next if !b.takesHailDamage?
        pbDisplay(_INTL("{1} is buffeted by the hail!",b.pbThis)) if Settings::GEN_9_SNOW == false
        @scene.pbDamageAnimation(b) if Settings::GEN_9_SNOW == false
        b.pbReduceHP(b.totalhp/16,false) if Settings::GEN_9_SNOW == false
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :ShadowSky
        next if !b.takesShadowSkyDamage?
        pbDisplay(_INTL("{1} is hurt by the shadow sky!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Starstorm
        next if !b.takesStarstormDamage?
        pbDisplay(_INTL("{1} is hurt by the Starstorm!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :AcidRain
        next if !b.takesAcidRainDamage?
        pbDisplay(_INTL("{1} is scathed by Acid Rain!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :DWind
        next if !b.takesDWindDamage?
        pbDisplay(_INTL("{1} is whipped by the Distorted Wind!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :DustDevil
        next if !b.takesDustDevilDamage?
        pbDisplay(_INTL("{1} is buffeted by the Dust Devil!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Sleet
        next if !b.takesHailDamage?
        pbDisplay(_INTL("{1} is buffeted by the Sleet!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/8,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Windy
        next if !b.pbOwnSide.effects[PBEffects::StealthRock] && !b.pbOwnSide.effects[PBEffects::CometShards] && b.pbOwnSide.effects[PBEffects::Spikes] == 0 && !b.pbOwnSide.effects[PBEffects::StickyWeb] && b.pbOwnSide.effects[PBEffects::ToxicSpikes] == 0
        if b.pbOwnSide.effects[PBEffects::StealthRock] || b.pbOpposingSide.effects[PBEffects::StealthRock]
          b.pbOwnSide.effects[PBEffects::StealthRock]      = false
          b.pbOpposingSide.effects[PBEffects::StealthRock] = false
        end
        if b.pbOwnSide.effects[PBEffects::Spikes]>0 || b.pbOpposingSide.effects[PBEffects::Spikes]>0
          b.pbOwnSide.effects[PBEffects::Spikes]      = 0
          b.pbOpposingSide.effects[PBEffects::Spikes] = 0
        end
        if b.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 || b.pbOpposingSide.effects[PBEffects::ToxicSpikes]>0
          b.pbOwnSide.effects[PBEffects::ToxicSpikes]      = 0
          b.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0
        end
        if b.pbOwnSide.effects[PBEffects::StickyWeb] || b.pbOpposingSide.effects[PBEffects::StickyWeb]
          b.pbOwnSide.effects[PBEffects::StickyWeb]      = false
          b.pbOpposingSide.effects[PBEffects::StickyWeb] = false
        end
        if b.pbOwnSide.effects[PBEffects::CometShards] || b.pbOpposingSide.effects[PBEffects::CometShards]
          b.pbOwnSide.effects[PBEffects::CometShards]      = false
          b.pbOpposingSide.effects[PBEffects::CometShards] = false
        end
      end
    end
  end
end
class PokeBattle_Battler
  def pbFaint(showMessage=true)
    if !fainted?
      PBDebug.log("!!!***Can't faint with HP greater than 0")
      return
    end
    return if @fainted   # Has already fainted properly
    @battle.pbDisplayBrief(_INTL("{1} fainted!",pbThis)) if showMessage
    PBDebug.log("[Pokémon fainted] #{pbThis} (#{@index})") if !showMessage
    @battle.scene.pbFaintBattler(self)
    pbInitEffects(false)
    # Reset status
    self.status      = :NONE
    self.statusCount = 0
    # Lose happiness
    if @pokemon && @battle.internalBattle
      badLoss = false
      @battle.eachOtherSideBattler(@index) do |b|
        badLoss = true if b.level>=self.level+30
      end
      @pokemon.changeHappiness((badLoss) ? "faintbad" : "faint")
    end
    # Reset form
    @battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
    #$mega_flag = 1 if mega? && idxOwnSide == 1
    @pokemon.makeUnmega if mega?
    @pokemon.makeUnprimal if primal?
    self.damage_done = 0 # Yamask
    # Do other things
    @battle.pbClearChoice(@index)   # Reset choice
    pbOwnSide.effects[PBEffects::LastRoundFainted] = @battle.turnCount
    # Check other battlers' abilities that trigger upon a battler fainting
    pbAbilitiesOnFainting
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    @battle.pbSetBattled(self)
  end
  def canConsumeBerry?
    abil = []
    @battle.eachOtherSideBattler do |b|
      abil.push(b.ability)
    end
    return false if [:UNNERVE,:ASONEICE,:ASONEGHOST].include?(abil)
    return true
  end
  def takesEntryHazardDamage?
    if hasActiveItem?(:HEAVYDUTYBOOTS)
      return false
    else
      return true
    end
  end
  def pbCanChooseMove?(move,commandPhase,showMessages=true,specialUsage=false)
    # Disable
    if @effects[PBEffects::DisableMove]==move.id && !specialUsage
      if showMessages
        msg = _INTL("{1}'s {2} is disabled!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Stuff Cheeks
    if move.function=="183" && (self.item && !pbIsBerry?(self.item))
      if showMessages
        msg = _INTL("{1} can't use that move because it doesn't have any berry!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Heal Block
    if @effects[PBEffects::HealBlock]>0 && move.healingMove?
      if showMessages
        msg = _INTL("{1} can't use {2} because of Heal Block!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Gravity
    if @battle.field.effects[PBEffects::Gravity]>0 && move.unusableInGravity?
      if showMessages
        msg = _INTL("{1} can't use {2} because of gravity!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Throat Chop
    if @effects[PBEffects::ThroatChop]>0 && move.soundMove?
      if showMessages
        msg = _INTL("{1} can't use {2} because of Throat Chop!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Choice Band
    if @effects[PBEffects::ChoiceBand]
      if hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF]) &&
         pbHasMove?(@effects[PBEffects::ChoiceBand])
        if move.id!=@effects[PBEffects::ChoiceBand]
          if showMessages
            msg = _INTL("{1} allows the use of only {2}!",itemName,
               GameData::Move.get(@effects[PBEffects::ChoiceBand]).name)
            (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
          end
          return false
        end
      else
        @effects[PBEffects::ChoiceBand] = nil
      end
    end
    # Gorilla Tactics
    if @effects[PBEffects::GorillaTactics]
      if hasActiveAbility?(:GORILLATACTICS)
        if move.id!=@effects[PBEffects::GorillaTactics]
          if showMessages
            msg = _INTL("{1} allows the use of only {2} !",abilityName,GameData::Move.get(@effects[PBEffects::GorillaTactics]).name)
            (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
          end
          return false
        end
      else
        @effects[PBEffects::GorillaTactics] = nil
      end
    end
    # Taunt
    if @effects[PBEffects::Taunt]>0 && move.statusMove?
      if showMessages
        msg = _INTL("{1} can't use {2} after the taunt!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Torment
    if @effects[PBEffects::Torment] && !@effects[PBEffects::Instructed] &&
       @lastMoveUsed && move.id==@lastMoveUsed && move.id!=@battle.struggle.id
      if showMessages
        msg = _INTL("{1} can't use the same move twice in a row due to the torment!",pbThis)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Imprison
    @battle.eachOtherSideBattler(@index) do |b|
      next if !b.effects[PBEffects::Imprison] || !b.pbHasMove?(move.id)
      if showMessages
        msg = _INTL("{1} can't use its sealed {2}!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Assault Vest (prevents choosing status moves but doesn't prevent
    # executing them)
    if hasActiveItem?(:ASSAULTVEST) && move.statusMove? && commandPhase
      if showMessages
        msg = _INTL("The effects of the {1} prevent status moves from being used!",
           itemName)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Belch
    return false if !move.pbCanChooseMove?(self,commandPhase,showMessages)
    return true
  end
  def trappedInBattle?
    return true if @effects[PBEffects::Trapping] > 0
    return true if @effects[PBEffects::MeanLook] >= 0
    return true if @effects[PBEffects::JawLock] != -1
    @battle.eachBattler { |b| return true if b.effects[PBEffects::JawLock] == @index }
    return true if @effects[PBEffects::Octolock] >= 0
    return true if @effects[PBEffects::Ingrain]
    return true if @effects[PBEffects::NoRetreat]
    return true if @battle.field.effects[PBEffects::FairyLock] > 0
    return true if @effects[PBEffects::CommanderDondozo] >= 0
    return true if @effects[PBEffects::CommanderTatsugiri]
    return false
  end
  alias proto_pbCheckFormOnWeatherChange pbCheckFormOnWeatherChange
  def pbCheckFormOnWeatherChange(ability_changed = false)
    ret = proto_pbCheckFormOnWeatherChange(ability_changed)
    return ret if ret == false
    if hasActiveAbility?(:PROTOSYNTHESIS) && !@effects[PBEffects::BoosterEnergy] && @effects[PBEffects::ParadoxStat]
      if @item == :BOOSTERENERGY
        pbHeldItemTriggered(@item)
        @effects[PBEffects::BoosterEnergy] = true
        @battle.pbDisplay(_INTL("{1} used its Booster Energy to activate Protosynthesis!", pbThis))
      else
        @battle.pbDisplay(_INTL("The effects of {1}'s Protosynthesis wore off!", pbThis(true)))
        @effects[PBEffects::ParadoxStat] = nil
      end
    end
  end
end
class PokeBattle_Battle
  def pbCanMegaEvolve?(idxBattler)
    return false if $game_switches[Settings::NO_MEGA_EVOLUTION]
    return false if !@battlers[idxBattler].hasMega?
    return false if wildBattle? && opposes?(idxBattler)
    return true if $DEBUG && Input.press?(Input::CTRL)
    return false if @battlers[idxBattler].effects[PBEffects::SkyDrop]>=0
    return false if !pbHasMegaRing?(idxBattler)
    #return false if $mega_flag == 1
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @megaEvolution[side][owner]==-1
  end
  def pbRun(idxBattler,duringBattle=false)
    battler = @battlers[idxBattler]
    if battler.opposes?
      return 0 if trainerBattle?
      @choices[idxBattler][0] = :Run
      @choices[idxBattler][1] = 0
      @choices[idxBattler][2] = nil
      return -1
    end
    # Fleeing from trainer battles
    if trainerBattle?
      if $DEBUG && Input.press?(Input::CTRL)
        if pbDisplayConfirm(_INTL("Treat this battle as a win?"))
          @decision = 1
          return 1
        elsif pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
          @decision = 2
          return 1
        end
      elsif @internalBattle
        pbDisplayPaused(_INTL("No! There's no running from a Trainer battle!"))
      elsif pbDisplayConfirm(_INTL("Would you like to forfeit the match and quit now?"))
        pbSEPlay("Battle flee")
        pbDisplay(_INTL("{1} forfeited the match!",self.pbPlayer.name))
        @decision = 3
        return 1
      end
      return 0
    end
    # Fleeing from wild battles
    if $DEBUG && Input.press?(Input::CTRL)
      pbSEPlay("Battle flee")
      pbDisplayPaused(_INTL("You got away safely!"))
      @decision = 3
      return 1
    end
    if !@canRun
      pbDisplayPaused(_INTL("You can't escape!"))
      return 0
    end
    if !duringBattle
      if battler.pbHasType?(:GHOST) && Settings::MORE_TYPE_EFFECTS
        pbSEPlay("Battle flee")
        pbDisplayPaused(_INTL("You got away safely!"))
        @decision = 3
        return 1
      end
      # Abilities that guarantee escape
      if battler.abilityActive?
        if BattleHandlers.triggerRunFromBattleAbility(battler.ability,battler)
          pbShowAbilitySplash(battler,true)
          pbHideAbilitySplash(battler)
          pbSEPlay("Battle flee")
          pbDisplayPaused(_INTL("You got away safely!"))
          @decision = 3
          return 1
        end
      end
      # Held items that guarantee escape
      if battler.itemActive?
        if BattleHandlers.triggerRunFromBattleItem(battler.item,battler)
          pbSEPlay("Battle flee")
          pbDisplayPaused(_INTL("{1} fled using its {2}!",
             battler.pbThis,battler.itemName))
          @decision = 3
          return 1
        end
      end
      # Other certain trapping effects
      if battler.effects[PBEffects::Trapping]>0 ||
         battler.effects[PBEffects::MeanLook]>-1 ||
         battler.effects[PBEffects::Ingrain] ||
         battler.effects[PBEffects::Octolock]==0 ||
         battler.effects[PBEffects::Octolock]==1 ||
         battler.effects[PBEffects::NoRetreat] ||
         @field.effects[PBEffects::FairyLock]>0
        pbDisplayPaused(_INTL("You can't escape!"))
        return 0
      end
      # Trapping abilities/items
      eachOtherSideBattler(idxBattler) do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerTrappingTargetAbility(b.ability,battler,b,self)
          pbDisplayPaused(_INTL("{1} prevents escape with {2}!",b.pbThis,b.abilityName))
          return 0
        end
      end
      eachOtherSideBattler(idxBattler) do |b|
        next if !b.itemActive?
        if BattleHandlers.triggerTrappingTargetItem(b.item,battler,b,self)
          pbDisplayPaused(_INTL("{1} prevents escape with {2}!",b.pbThis,b.itemName))
          return 0
        end
      end
    end
    # Fleeing calculation
    # Get the speeds of the Pokémon fleeing and the fastest opponent
    # NOTE: Not pbSpeed, because using unmodified Speed.
    @runCommand += 1 if !duringBattle   # Make it easier to flee next time
    speedPlayer = @battlers[idxBattler].speed
    speedEnemy = 1
    eachOtherSideBattler(idxBattler) do |b|
      speed = b.speed
      speedEnemy = speed if speedEnemy<speed
    end
    # Compare speeds and perform fleeing calculation
    if speedPlayer>speedEnemy
      rate = 256
    else
      rate = (speedPlayer*128)/speedEnemy
      rate += @runCommand*30
    end
    if rate>=256 || @battleAI.pbAIRandom(256)<rate
      pbSEPlay("Battle flee")
      pbDisplayPaused(_INTL("You got away safely!"))
      @decision = 3
      return 1
    end
    pbDisplayPaused(_INTL("You couldn't get away!"))
    return -1
  end
end
