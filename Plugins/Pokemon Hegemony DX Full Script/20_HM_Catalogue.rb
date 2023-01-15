module HMCatalogue
  Choice = 34
  Cut = 76
  RockSmash = 77
  Strength = 78
  Flash = 79
  Surf = 80
  Fly = 81
  Dive = 82
  RockClimb = 83
  Waterfall = 84
end

def pbRefresh
end

def useHMCatalogue
  pbFadeOutIn {
    scene = HM_Scene.new
    screen = HMScreen.new(scene)
    screen.pbStartScreen
    @scene.pbRefresh
  }
end

class HM_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def dispose
    pbFadeOutAndHide(@sprites) {pbUpdate}
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @viewport2.dispose
    @viewport3.dispose
  end

  def pbStartScene(commands)
    @commands = commands
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg")
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
       _INTL("HM Catalogue"),2,-18,256,64,@viewport)
    @sprites["header"].baseColor   = Color.new(248,248,248)
    @sprites["header"].shadowColor = Color.new(0,0,0)
    @sprites["header"].windowskin  = nil
    @sprites["commands"] = Window_CommandPokemon.newWithSize(@commands,
       14,92,324,224,@viewport)
    @sprites["commands"].baseColor   = Color.new(248,248,248)
    @sprites["commands"].shadowColor = Color.new(0,0,0)
    @sprites["commands"].windowskin = nil
    pbFadeInAndShow(@sprites) { pbUpdate }
  end


  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        break
      elsif Input.trigger?(Input::C)
        ret = @sprites["commands"].index
        break
      end
    end
    return ret
  end

  def pbSetCommands(newcommands,newindex)
    @sprites["commands"].commands = (!newcommands) ? @commands : newcommands
    @sprites["commands"].index    = newindex
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class HMScreen

  def initialize(scene)
    @scene = scene
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def dispose
    pbFadeOutAndHide(@sprites) {pbUpdate}
    pbDisposeSpriteHash(@sprites)
  end

  def pbStartScreen
    commands = []
    cmdCut    = -1
    cmdRockSmash   = -1
    cmdStrength    = -1
    cmdFlash    = -1
    cmdSurf    = -1
    cmdFly    = -1
    cmdDive   = -1
    cmdRockClimb    = -1
    cmdWaterfall    = -1
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @viewport3 = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport3.z = 999999
    @sprites = {}
    commands[cmdFly = commands.length]   = _INTL("Fly") if $game_switches[HMCatalogue::Fly]
    commands[cmdCut = commands.length]   = _INTL("Cut") if $game_switches[HMCatalogue::Cut]
    commands[cmdRockSmash = commands.length]   = _INTL("Rock Smash") if $game_switches[HMCatalogue::RockSmash]
    commands[cmdStrength = commands.length]   = _INTL("Strength") if $game_switches[HMCatalogue::Strength]
    commands[cmdFlash = commands.length]   = _INTL("Flash") if $game_switches[HMCatalogue::Flash]
    commands[cmdSurf = commands.length]   = _INTL("Surf") if $game_switches[HMCatalogue::Surf]
    commands[cmdDive = commands.length]   = _INTL("Dive") if $game_switches[HMCatalogue::Dive]
    commands[cmdRockClimb = commands.length]   = _INTL("Rock Climb") if $game_switches[HMCatalogue::RockClimb]
    commands[cmdWaterfall = commands.length]   = _INTL("Waterfall") if $game_switches[HMCatalogue::Waterfall]
    commands[commands.length]              = _INTL("Exit")
    @scene.pbStartScene(commands)
    loop do
      cmd = @scene.pbScene
        if cmd<0
        pbPlayCloseMenuSE
          break
        elsif cmdFly>=0 && cmd==cmdFly
          pbPlayDecisionSE
          dispose
          if !canUseMoveFly?
            pbMessage(_INTL("You cannot use that here."))
          else
            ret = nil
              pbFadeOutIn{
              scene = PokemonRegionMap_Scene.new(-1,false)
              screen = PokemonRegionMapScreen.new(scene)
              ret = screen.pbStartFlyScreen
              next 0 if !ret
            if ret
              $PokemonTemp.flydata = ret
              $game_temp.in_menu = false
              useMoveFly
              dispose
              @scene.pbEndScene
            end
          }
          break
          end
        elsif cmdCut>=0 && cmd==cmdCut
          pbPlayDecisionSE
          dispose
          if !canUseMoveCut?
          else
            useMoveCut
            break
          end
        elsif cmdRockSmash>=0 && cmd==cmdRockSmash
          pbPlayDecisionSE
          dispose
          if !canUseMoveRockSmash?
          else
            useMoveRockSmash
            break
          end
        elsif cmdStrength>=0 && cmd==cmdStrength
          pbPlayDecisionSE
          dispose
          if !canUseMoveStrength?
          else
            useMoveStrength
            break
          end
        elsif cmdFlash>=0 && cmd==cmdFlash
          pbPlayDecisionSE
          dispose
          if !canUseMoveFlash?
          else
            useMoveFlash
            break
          end
        elsif cmdSurf>=0 && cmd==cmdSurf
          pbPlayDecisionSE
          dispose
          if !canUseMoveSurf?
          else
            useMoveSurf
            break
          end
        elsif cmdDive>=0 && cmd==cmdDive
          pbPlayDecisionSE
          dispose
          if !canUseMoveDive?
          else
            useMoveDive
            break
          end
        elsif cmdRockClimb>=0 && cmd==cmdRockClimb
          pbPlayDecisionSE
          dispose
          if !canUseMoveRockClimb?
          else
            useMoveRockClimb
            break
          end
        elsif cmdWaterfall>=0 && cmd==cmdWaterfall
          pbPlayDecisionSE
          dispose
          if !canUseMoveWaterfall?
          else
            useMoveWaterfall
            break
          end
        else# Exit
        pbPlayCloseMenuSE
        break
      end
    end
    @scene.pbEndScene
  end
end
