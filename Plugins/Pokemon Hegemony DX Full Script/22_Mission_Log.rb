module Mission
  Main = 504
end

class Mission_Overlay
  def initialize
    $mission_steps = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 100000
    $viewport_mission = @viewport
    @sprites = {}

    skin = MessageConfig.pbGetSystemFrame

     @sprites["background"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, Graphics.width, 0, @viewport)
     @sprites["background"].z = @viewport.z - 1
     @sprites["background"].visible = false
     @sprites["background"].setSkin(skin)
     pbSetSmallFont(@sprites["background"].contents)

    colors = getDefaultTextColors(@sprites["background"].windowskin)

    @sprites["descwindow"] = Window_AdvancedTextPokemon.newWithSize("", 64, 0, Graphics.width - 64, 64, @viewport)
    @sprites["descwindow"].windowskin = nil
    @sprites["descwindow"].z = @viewport.z
    @sprites["descwindow"].visible = false
    @sprites["descwindow"].baseColor = colors[0]
    @sprites["descwindow"].shadowColor = colors[1]

    pbSetSmallFont(@sprites["descwindow"].contents)
    @sprites["descwindow"].lineHeight(30)
  end
  def pbShow
    quest_stage = $PokemonGlobal.quests.active_quests[0].stage
    quest_info = $quest_data.getStageDescription(:Quest1,quest_stage)

    descwindow = @sprites["descwindow"]
    descwindow.resizeToFit(quest_info, Graphics.width - 64)
    descwindow.text = quest_info
    descwindow.x = ((Graphics.width-64)/2)-(descwindow.width/2)
    descwindow.y = 0
    descwindow.visible = true

    background = @sprites["background"]
    background.height = descwindow.height
    background.y = 0
    background.visible = true
    $mission_steps = 10
  end
  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

def pbMissionUpdate(num)
  scene = Mission_Overlay.new
  case num
  when 1
    if $game_variables[Mission::Main] < 9
      $game_variables[Mission::Main] += 2
    elsif $game_variables[Mission::Main] == 9
      $game_variables[Mission::Main] += 2
    else
      $game_variables[Mission::Main] += 1
    end
    $PokemonGlobal.quests.advanceQuestToStage(:Quest1,$game_variables[Mission::Main],"463F0000",false)
    scene.pbShow
  when 5
    $PokemonGlobal.quests.advanceQuestToStage(:Quest5,2,"463F0000",false)
  when 7
    $PokemonGlobal.quests.advanceQuestToStage(:Quest7,2,"463F0000",false)
  end
end

def pbNewMission(num)
  scene = Mission_Overlay.new
  case num
  when 1
    if $game_switches[60]
      $game_variables[Mission::Main] = 2
      $PokemonGlobal.quests.activateQuest(:Quest1,"56946F5A",false)
      $PokemonGlobal.quests.advanceQuestToStage(:Quest1,$game_variables[Mission::Main],"463F0000",false)
    else
      $game_variables[Mission::Main] = 1
      $PokemonGlobal.quests.activateQuest(:Quest1,"56946F5A",false)
    end
    scene.pbShow
  when 2
    $PokemonGlobal.quests.activateQuest(:Quest2,"56946F5A",false)
  when 3
    $PokemonGlobal.quests.activateQuest(:Quest3,"56946F5A",false)
  when 4
    $PokemonGlobal.quests.activateQuest(:Quest4,"56946F5A",false)
  when 5
    $PokemonGlobal.quests.activateQuest(:Quest5,"56946F5A",false)
  when 6
    $PokemonGlobal.quests.activateQuest(:Quest6,"56946F5A",false)
  when 7
    $PokemonGlobal.quests.activateQuest(:Quest7,"56946F5A",false)
  end
end

def pbCompleteMission(num)
  case num
  when 1
    $PokemonGlobal.quests.completeQuest(:Quest1,"56946F5A",false)
  when 2
    $PokemonGlobal.quests.completeQuest(:Quest2,"56946F5A",false)
  when 3
    $PokemonGlobal.quests.completeQuest(:Quest3,"56946F5A",false)
  when 4
    $PokemonGlobal.quests.completeQuest(:Quest4,"56946F5A",false)
  when 5
    $PokemonGlobal.quests.completeQuest(:Quest5,"56946F5A",false)
  when 6
    $PokemonGlobal.quests.completeQuest(:Quest6,"56946F5A",false)
  when 7
    $PokemonGlobal.quests.completeQuest(:Quest7,"56946F5A",false)
  end
end
