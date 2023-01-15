class DataBoxEBDX  <  SpriteWrapper
  alias setUp_StatOverlay setUp
  def setUp
    setUp_StatOverlay
    $overlay = true
    if @battle.singleBattle?
      @sprites["boost1"] = Sprite.new(@viewport)
      @sprites["boost1"].bitmap = nil
      @sprites["boost1"].z = 1
      @sprites["boost1"].ex = @playerpoke ? 186 : 20
      @sprites["boost1"].ey = @playerpoke ? -136 : 27
      @sprites["boost1"].visible = false

      @sprites["boost2"] = Sprite.new(@viewport)
      @sprites["boost2"].bitmap = nil
      @sprites["boost2"].z = 1
      @sprites["boost2"].ex = @playerpoke ? 186 : 20
      @sprites["boost2"].ey = @playerpoke ? -120 : 43
      @sprites["boost2"].visible = false

      @sprites["boost3"] = Sprite.new(@viewport)
      @sprites["boost3"].bitmap = nil
      @sprites["boost3"].z = 1
      @sprites["boost3"].ex = @playerpoke ? 186 : 20
      @sprites["boost3"].ey = @playerpoke ? -104 : 59
      @sprites["boost3"].visible = false

      @sprites["boost4"] = Sprite.new(@viewport)
      @sprites["boost4"].bitmap = nil
      @sprites["boost4"].z = 1
      @sprites["boost4"].ex = @playerpoke ? 186 : 20
      @sprites["boost4"].ey = @playerpoke ? -88 : 75
      @sprites["boost4"].visible = false

      @sprites["boost5"] = Sprite.new(@viewport)
      @sprites["boost5"].bitmap = nil
      @sprites["boost5"].z = 1
      @sprites["boost5"].ex = @playerpoke ? 186 : 20
      @sprites["boost5"].ey = @playerpoke ? -72 : 91
      @sprites["boost5"].visible = false

      @sprites["boost6"] = Sprite.new(@viewport)
      @sprites["boost6"].bitmap = nil
      @sprites["boost6"].z = 1
      @sprites["boost6"].ex = @playerpoke ? 186 : 20
      @sprites["boost6"].ey = @playerpoke ? -56 : 107
      @sprites["boost6"].visible = false

      @sprites["boost7"] = Sprite.new(@viewport)
      @sprites["boost7"].bitmap = nil
      @sprites["boost7"].z = 1
      @sprites["boost7"].ex = @playerpoke ? 186 : 20
      @sprites["boost7"].ey = @playerpoke ? -40 : 123
      @sprites["boost7"].visible = false
    else
      @sprites["boost1"] = Sprite.new(@viewport)
      @sprites["boost1"].bitmap = nil
      @sprites["boost1"].z = 1
      @sprites["boost1"].ex = @playerpoke ? -106 : 242
      @sprites["boost1"].ey = -32
      @sprites["boost1"].visible = false

      @sprites["boost2"] = Sprite.new(@viewport)
      @sprites["boost2"].bitmap = nil
      @sprites["boost2"].z = 1
      @sprites["boost2"].ex = @playerpoke ? -106 : 242
      @sprites["boost2"].ey = -16
      @sprites["boost2"].visible = false

      @sprites["boost3"] = Sprite.new(@viewport)
      @sprites["boost3"].bitmap = nil
      @sprites["boost3"].z = 1
      @sprites["boost3"].ex = @playerpoke ? -106 : 242
      @sprites["boost3"].ey =0
      @sprites["boost3"].visible = false

      @sprites["boost4"] = Sprite.new(@viewport)
      @sprites["boost4"].bitmap = nil
      @sprites["boost4"].z = 1
      @sprites["boost4"].ex = @playerpoke ? -106 : 282
      @sprites["boost4"].ey = -32
      @sprites["boost4"].visible = false

      @sprites["boost5"] = Sprite.new(@viewport)
      @sprites["boost5"].bitmap = nil
      @sprites["boost5"].z = 1
      @sprites["boost5"].ex = @playerpoke ? -66 : 282
      @sprites["boost5"].ey = -16
      @sprites["boost5"].visible = false

      @sprites["boost6"] = Sprite.new(@viewport)
      @sprites["boost6"].bitmap = nil
      @sprites["boost6"].z = 1
      @sprites["boost6"].ex = @playerpoke ? -66 : 282
      @sprites["boost6"].ey = 0
      @sprites["boost6"].visible = false

      @sprites["boost7"] = Sprite.new(@viewport)
      @sprites["boost7"].bitmap = nil
      @sprites["boost7"].z = 1
      @sprites["boost7"].ex = @playerpoke ? -66 : 322
      @sprites["boost7"].ey = -32
      @sprites["boost7"].visible = false
    end
  end
  alias update_StatOverlay update
  def update
    update_StatOverlay
    # shows stat boosts
    stat_boost = []
    $stat_boost = stat_boost
    i = @battler.stages[:ATTACK]
    j = @battler.stages[:DEFENSE]
    k = @battler.stages[:SPECIAL_ATTACK]
    l = @battler.stages[:SPECIAL_DEFENSE]
    m = @battler.stages[:SPEED]
    n = @battler.stages[:ACCURACY]
    o = @battler.stages[:EVASION]
    stat_boost.push(i)
    stat_boost.push(j)
    stat_boost.push(k)
    stat_boost.push(l)
    stat_boost.push(m)
    stat_boost.push(n)
    stat_boost.push(o)
    if !@safaribattle && $overlay == true
      @sprites["boost1"].bitmap = i != 0 ? pbBitmap(@path + "Atk#{i}") : nil
      @sprites["boost1"].visible = i != 0 ? true : false

      @sprites["boost2"].bitmap = j != 0 ? pbBitmap(@path + "Def#{j}") : nil
      @sprites["boost2"].visible = j != 0 ? true : false

      @sprites["boost3"].bitmap = k != 0 ? pbBitmap(@path + "SpAtk#{k}") : nil
      @sprites["boost3"].visible = k != 0 ? true : false

      @sprites["boost4"].bitmap = l != 0 ? pbBitmap(@path + "SpDef#{l}") : nil
      @sprites["boost4"].visible = l != 0 ? true : false

      @sprites["boost5"].bitmap = m != 0 ? pbBitmap(@path + "Spe#{m}") : nil
      @sprites["boost5"].visible = m != 0 ? true : false

      @sprites["boost6"].bitmap = n != 0 ? pbBitmap(@path + "Acc#{n}") : nil
      @sprites["boost6"].visible = n != 0 ? true : false

      @sprites["boost7"].bitmap = o != 0 ? pbBitmap(@path + "Eva#{o}") : nil
      @sprites["boost7"].visible = o != 0 ? true : false
    end
  end
end

class PokeBattle_Scene
  def pbThrowSuccess
    return if @battle.opponent
    @briefmessage = true
    # try to resolve the ME jingle
    me = "EBDX/Capture Success"
    try = @caughtBattler ? EliteBattle.get_data(@caughtBattler.species, :Species, :CAPTUREME) : nil
    me = try if !try.nil?
    # play ME
    pbMEPlay(me)
    # wait for audio frames to complete
    frames = (getPlayTime("Audio/ME/#{me}") * Graphics.frame_rate).ceil + 4
    self.wait(frames)
    pbMEStop
    for i in 1..7
      @sprites["boost#{i}"].visible = false if @sprites["boost#{i}"] != nil
      @sprites["boost#{i}"].dispose if @sprites["boost#{i}"] != nil
    end
    # return scene to normal
    5.times do
      @sprites["ballshadow"].opacity -= 16
      @sprites["captureball"].opacity -= 52
      self.wait
    end
    @sprites["ballshadow"].dispose
    @sprites["captureball"].dispose
    pbShowAllDataboxes(0)
    @vector.reset
  end
end

class EliteBattle_Pokedex
  def main
    # fade in scene
    $overlay = false
    16.times do
      self.update
      @viewport.color.alpha -= 16
      Graphics.update
    end
    # hide silhouette
    h = (@sprites["sil"].bitmap.height/32.0).ceil
    32.times do
      self.update
      @sprites["sil"].src_rect.height -= h
      Graphics.update
    end
    # play cry
    GameData::Species.cry_filename_from_pokemon(@pokemon)
    # begin loop
    loop do
      Graphics.update
      Input.update
      self.update
      break if Input.trigger?(Input::C)
    end
    # moves Pokemon sprite to middle of screen
    w = (@viewport.width/2 - @sprites["poke"].x)/32
    32.times do
      @sprites["contents"].color.alpha += 16
      @sprites["bg"].color.alpha += 16
      @sprites["highlight"].color.alpha += 16
      @sprites["poke"].x += w
      @sprites["color"].opacity += 8
      for i in 1..3
        @sprites["c#{i}"].opacity += 8
      end
      self.update
      Graphics.update
    end
    @sprites["poke"].x = @viewport.width/2
    for i in 1..7
      @sprites["boost#{i}"].visible = false if @sprites["boost#{i}"] != nil
      @sprites["boost#{i}"].dispose if @sprites["boost#{i}"] != nil
    end
    Graphics.update
  end
  def update
    return if self.disposed?
    @sprites["bg"].update
    @sprites["highlight"].opacity += @sprites["highlight"].toggle*8
    @sprites["highlight"].toggle *= -1 if @sprites["highlight"].opacity <= 0 || @sprites["highlight"].opacity >= 255
    for i in 1..3
      @sprites["c#{i}"].zoom_x -= @sprites["c#{i}"].speed * @sprites["c#{i}"].toggle
      @sprites["c#{i}"].zoom_y -= @sprites["c#{i}"].speed * @sprites["c#{i}"].toggle
      @sprites["c#{i}"].toggle *= -1 if @sprites["c#{i}"].zoom_x <= 0.96 || @sprites["c#{i}"].zoom_x >= 1.04
    end
    for i in 1..7
      @sprites["boost#{i}"].dispose if @sprites["boost#{i}"] != nil
    end
  end
end
