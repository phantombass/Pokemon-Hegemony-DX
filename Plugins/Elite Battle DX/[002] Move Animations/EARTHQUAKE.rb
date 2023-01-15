#-------------------------------------------------------------------------------
#  Earthquake
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:EARTHQUAKE) do
  # set up animation
  fp = {}; randx = []; randy = []; speed = []; angle = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.black)
  fp["bg"].opacity = 0
  @battle.battlers.each_with_index do |b, m|
    next if !b
    randx.push([]); randy.push([]); speed.push([]); angle.push([])
    targetsprite = @sprites["pokemon_#{m}"]
    next if !targetsprite || targetsprite.disposed? || targetsprite.fainted || !targetsprite.visible
    next if m == @userIndex
    for j in 0...32
      fp["#{j}#{m}"] = Sprite.new(@viewport)
      fp["#{j}#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb223")
      fp["#{j}#{m}"].ox = fp["#{j}#{m}"].bitmap.width/2
      fp["#{j}#{m}"].oy = fp["#{j}#{m}"].bitmap.height/2
      fp["#{j}#{m}"].z = 50
      z = [0.5,0.4,0.3,0.7][rand(4)]
      fp["#{j}#{m}"].zoom_x = z
      fp["#{j}#{m}"].zoom_y = z
      fp["#{j}#{m}"].visible = false
      randx[m].push(rand(82)+(rand(2)==0 ? 82 : 0))
      randy[m].push(rand(32)+32)
      speed[m].push(4)
      angle[m].push((rand(8)+1)*(rand(2)==0 ? -1 : 1))
    end
  end
  @vector.set(EliteBattle.get_vector(:DUAL))
  @sprites["battlebg"].defocus
  16.times do
    fp["bg"].opacity += 8
    @scene.wait(1,true)
  end
  factor = @userSprite.zoom_x
  k = -1
  pbSEPlay("Anim/Earth4")
  for i in 0...92
    @battle.battlers.each_with_index do |b, m|
      next if !b
      targetsprite = @sprites["pokemon_#{m}"]
      next if !targetsprite || targetsprite.disposed? || targetsprite.fainted || !targetsprite.visible
      next if m == @userIndex
      cx, cy = targetsprite.getCenter(true)
      for j in 0...32
        next if j>(i/2)
        if !fp["#{j}#{m}"].visible
          fp["#{j}#{m}"].visible = true
          fp["#{j}#{m}"].x = cx - 82*targetsprite.zoom_x + randx[m][j]*targetsprite.zoom_x
          fp["#{j}#{m}"].y = targetsprite.y
          fp["#{j}#{m}"].zoom_x *= targetsprite.zoom_x
          fp["#{j}#{m}"].zoom_y *= targetsprite.zoom_y
        end
        fp["#{j}#{m}"].y -= speed[m][j]*2*targetsprite.zoom_y
        speed[m][j] *= -1 if (fp["#{j}#{m}"].y <= targetsprite.y - randy[m][j]*targetsprite.zoom_y) || (fp["#{j}#{m}"].y >= targetsprite.y)
        fp["#{j}#{m}"].opacity -= 35 if speed[m][j] < 0
        fp["#{j}#{m}"].angle += angle[m][j]
      end
    end
    @userSprite.zoom_x -= 0.2/6 if @userSprite.zoom_x > factor
    @userSprite.zoom_y += 0.2/6 if @userSprite.zoom_y < factor
    @scene.moveEntireScene(k*8, 0, true, true)
    k *= -1 if i%3==0
    if i%32==0
      pbSEPlay("Anim/Earth4",60)
      @userSprite.zoom_x = factor*1.2
      @userSprite.zoom_y = factor*0.8
    end
    fp["bg"].opacity -= 12 if i >= 72
    @scene.wait(1,false)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
