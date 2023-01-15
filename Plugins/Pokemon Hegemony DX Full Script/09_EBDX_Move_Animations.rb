EliteBattle.defineMoveAnimation(:STELLARWIND) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb423")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = @targetSprite.z + 1
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  shake = 4
  # start animation
  @vector.set(vector2)
  pbSEPlay("Anim/Whirlwind")
  for i in 0...72
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x
      nexty = fp["#{j}"].y
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
  #    @targetSprite.x += 64*(@targetIsPlayer ? -1 : 1)
    elsif i >= 52
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @vector.set(vector) if i == 16
    @vector.inc = 0.1 if i == 16
    @scene.wait(1,i < 64)
  end
#  @targetSprite.visible = false
#  @targetSprite.hidden = true
#  @targetSprite.ox = @targetSprite.bitmap.width/2
  pbDisposeSpriteHash(fp)
  @vector.reset
  @vector.inc = 0.2
  @scene.wait(16,true)
end
EliteBattle.defineMoveAnimation(:ASTRALGALE) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/spectral_shriek_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb519_2")
    fp["#{i}s"].ox = fp["#{i}s"].bitmap.width/2
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height + 8*factor
    fp["#{i}s"].angle = rand(360)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  k = 0
  # start animation
  @vector.set(vector2)
  @sprites["battlebg"].defocus
  for i in 0...30
    if i < 10
      fp["bg"].opacity += 25.5
    elsif i < 20
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("EBDX/Anim/grass2") if i == 20
    fp["bg"].update
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/wind1",90)
  for i in 0...96
    pbSEPlay("EBDX/Anim/grass1",60) if i%3==0 && i < 64
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].oy +=6*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = @userSprite.getCenter
    end
    #pbSEPlay("Anim/Comet Punch") if i == 64
    fp["bg"].update
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  for i in 0...20
    @targetSprite.still
    if i < 10
      fp["bg"].color.alpha += 25.5
    else
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:TIMEWIND) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb423")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = @targetSprite.z + 1
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  shake = 4
  # start animation
  @vector.set(vector2)
  pbSEPlay("Anim/Whirlwind")
  for i in 0...72
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x
      nexty = fp["#{j}"].y
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
  #    @targetSprite.x += 64*(@targetIsPlayer ? -1 : 1)
    elsif i >= 52
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @vector.set(vector) if i == 16
    @vector.inc = 0.1 if i == 16
    @scene.wait(1,i < 64)
  end
#  @targetSprite.visible = false
#  @targetSprite.hidden = true
#  @targetSprite.ox = @targetSprite.bitmap.width/2
  pbDisposeSpriteHash(fp)
  @vector.reset
  @vector.inc = 0.2
  @scene.wait(16,true)
end
EliteBattle.defineMoveAnimation(:SWIFT) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = @targetSprite.z + 1
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  shake = 4
  # start animation
  @vector.set(vector2)
  pbSEPlay("EBDX/Anim/dragon2")
  for i in 0...72
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x
      nexty = fp["#{j}"].y
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
  #    @targetSprite.x += 64*(@targetIsPlayer ? -1 : 1)
    elsif i >= 52
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @vector.set(vector) if i == 16
    @vector.inc = 0.1 if i == 16
    @scene.wait(1,i < 64)
  end
#  @targetSprite.visible = false
#  @targetSprite.hidden = true
#  @targetSprite.ox = @targetSprite.bitmap.width/2
  pbDisposeSpriteHash(fp)
  @vector.reset
  @vector.inc = 0.2
  @scene.wait(16,true)
end
EliteBattle.defineMoveAnimation(:MUDSLAP) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_4")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = @targetSprite.z + 1
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  shake = 4
  # start animation
  @vector.set(vector2)
  pbSEPlay("EBDX/Anim/ground1")
  for i in 0...72
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x
      nexty = fp["#{j}"].y
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
  #    @targetSprite.x += 64*(@targetIsPlayer ? -1 : 1)
    elsif i >= 52
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @vector.set(vector) if i == 16
    @vector.inc = 0.1 if i == 16
    @scene.wait(1,i < 64)
  end
#  @targetSprite.visible = false
#  @targetSprite.hidden = true
#  @targetSprite.ox = @targetSprite.bitmap.width/2
  pbDisposeSpriteHash(fp)
  @vector.reset
  @vector.inc = 0.2
  @scene.wait(16,true)
end
EliteBattle.defineMoveAnimation(:BOOMBURST) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb093_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb519_5")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
    fp["#{i}s"].ox = fp["#{i}s"].bitmap.width/2
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height + 8*factor
    fp["#{i}s"].angle = rand(360)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  k = 0
  # start animation
  @vector.set(vector2)
  @sprites["battlebg"].defocus
  for i in 0...30
    if i < 10
      fp["bg"].opacity += 25.5
    elsif i < 20
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("EBDX/Anim/grass2") if i == 20
    fp["bg"].update
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/wind1",90)
  for i in 0...96
    pbSEPlay("EBDX/Anim/grass1",60) if i%3==0 && i < 64
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].oy +=6*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = @userSprite.getCenter
    end
    #pbSEPlay("Anim/Comet Punch") if i == 64
    fp["bg"].update
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  for i in 0...20
    @targetSprite.still
    if i < 10
      fp["bg"].color.alpha += 25.5
    else
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:HYPERVOICE) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536_2")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536_2")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
    fp["#{i}s"].ox = fp["#{i}s"].bitmap.width/2
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height + 8*factor
    fp["#{i}s"].angle = rand(360)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  k = 0
  # start animation
  @vector.set(vector2)
  @sprites["battlebg"].defocus
  for i in 0...30
    pbSEPlay("EBDX/Anim/grass2") if i == 20
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/wind1",90)
  for i in 0...96
    pbSEPlay("EBDX/Anim/grass1",60) if i%3==0 && i < 64
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].oy +=6*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = @userSprite.getCenter
    end
    #pbSEPlay("Anim/Comet Punch") if i == 64
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:CINDERRUSH) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  frame = []
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for j in 0...16
    fp["f#{j}"] = Sprite.new(@viewport)
    fp["f#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129")
    fp["f#{j}"].ox = fp["f#{j}"].bitmap.width/2
    fp["f#{j}"].oy = fp["f#{j}"].bitmap.height/2
    fp["f#{j}"].x = @userSprite.x - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
    fp["f#{j}"].y = @userSprite.y - 16*@userSprite.zoom_y + rand(32)*@userSprite.zoom_y
    fp["f#{j}"].visible = false
    z = [1,0.75,0.5,0.8][rand(4)]
    fp["f#{j}"].zoom_x = @userSprite.zoom_x*z
    fp["f#{j}"].zoom_y = @userSprite.zoom_y*z
    fp["f#{j}"].z = @userSprite.z + 1
    frame.push(0)
  end
  # animation start
  pbSEPlay("EBDX/Anim/fire2",60)
  pbSEPlay("EBDX/Anim/fire3",60)
  @sprites["battlebg"].defocus
  for i in 0...48
    for j in 0...16
      next if j>(i/2)
      fp["f#{j}"].visible = true
      fp["f#{j}"].y -= 8*@userSprite.zoom_y
      fp["f#{j}"].opacity -= 32 if frame[j] >= 8
      frame[j] += 1
    end
    fp["bg"].opacity += 8 if i >= 32
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/fire4",80)
  @vector.set(vector)
  @scene.wait(16,true)
  cx, cy = @targetSprite.getCenter
  fp["flare"] = Sprite.new(@viewport)
  fp["flare"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_2")
  fp["flare"].ox = fp["flare"].bitmap.width/2
  fp["flare"].oy = fp["flare"].bitmap.height/2
  fp["flare"].x = cx
  fp["flare"].y = cy
  fp["flare"].zoom_x = @targetSprite.zoom_x
  fp["flare"].zoom_y = @targetSprite.zoom_y
  fp["flare"].z = @targetSprite.z
  fp["flare"].opacity = 0
  for j in 0...3
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_3")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].x = cx - 32 + rand(64)
    fp["#{j}"].y = cy - 32 + rand(64)
    fp["#{j}"].z = @targetSprite.z + 1
    fp["#{j}"].visible = false
    fp["#{j}"].zoom_x = @targetSprite.zoom_x
    fp["#{j}"].zoom_y = @targetSprite.zoom_y
  end
  for m in 0...12
    fp["p#{m}"] = Sprite.new(@viewport)
    fp["p#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_4")
    fp["p#{m}"].ox = fp["p#{m}"].bitmap.width/2
    fp["p#{m}"].oy = fp["p#{m}"].bitmap.height/2
    fp["p#{m}"].x = cx - 48 + rand(96)
    fp["p#{m}"].y = cy - 48 + rand(96)
    fp["p#{m}"].z = @targetSprite.z + 2
    fp["p#{m}"].visible = false
    fp["p#{m}"].zoom_x = @targetSprite.zoom_x
    fp["p#{m}"].zoom_y = @targetSprite.zoom_y
  end
  @targetSprite.color = Color.new(0,0,0,0)
  for i in 0...64
    fp["bg"].opacity += 16 if fp["bg"].opacity < 255 && i < 32
    fp["bg"].color.alpha -= 32 if fp["bg"].color.alpha > 0
    fp["flare"].opacity += 32*(i < 8 ? 1 : -1)
    fp["flare"].angle += 32
    pbSEPlay("EBDX/Anim/fire1",80) if i == 8
    for j in 0...3
      next if i < 12
      next if j>(i-12)/4
      fp["#{j}"].visible = true
      fp["#{j}"].opacity -= 16
      fp["#{j}"].angle += 16
      fp["#{j}"].zoom_x += 0.1
      fp["#{j}"].zoom_y += 0.1
    end
    for m in 0...12
      next if i < 6
      next if m>(i-6)
      fp["p#{m}"].visible = true
      fp["p#{m}"].opacity -= 16
      fp["p#{m}"].y -= 8
    end
    if i >= 48
      fp["bg"].opacity -= 16
      @targetSprite.color.alpha -= 16
    else
      @targetSprite.color.alpha += 16 if @targetSprite.color.alpha < 192
    end
    @targetSprite.anim = true
    @scene.wait
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:SOLARWINGS) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  frame = []
  fp = {}
  for j in 0...16
    fp["f#{j}"] = Sprite.new(@viewport)
    fp["f#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129")
    fp["f#{j}"].ox = fp["f#{j}"].bitmap.width/2
    fp["f#{j}"].oy = fp["f#{j}"].bitmap.height/2
    fp["f#{j}"].x = @userSprite.x - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
    fp["f#{j}"].y = @userSprite.y - 16*@userSprite.zoom_y + rand(32)*@userSprite.zoom_y
    fp["f#{j}"].visible = false
    z = [1,0.75,0.5,0.8][rand(4)]
    fp["f#{j}"].zoom_x = @userSprite.zoom_x*z
    fp["f#{j}"].zoom_y = @userSprite.zoom_y*z
    fp["f#{j}"].z = @userSprite.z + 1
    frame.push(0)
  end
  # animation start
  pbSEPlay("EBDX/Anim/fire2",60)
  pbSEPlay("EBDX/Anim/fire3",60)
  @sprites["battlebg"].defocus
  for i in 0...48
    for j in 0...16
      next if j>(i/2)
      fp["f#{j}"].visible = true
      fp["f#{j}"].y -= 8*@userSprite.zoom_y
      fp["f#{j}"].opacity -= 32 if frame[j] >= 8
      frame[j] += 1
    end
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/fire4",80)
  @vector.set(vector)
  @scene.wait(16,true)
  cx, cy = @targetSprite.getCenter
  fp["flare"] = Sprite.new(@viewport)
  fp["flare"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_2")
  fp["flare"].ox = fp["flare"].bitmap.width/2
  fp["flare"].oy = fp["flare"].bitmap.height/2
  fp["flare"].x = cx
  fp["flare"].y = cy
  fp["flare"].zoom_x = @targetSprite.zoom_x
  fp["flare"].zoom_y = @targetSprite.zoom_y
  fp["flare"].z = @targetSprite.z
  fp["flare"].opacity = 0
  for j in 0...3
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_3")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].x = cx - 32 + rand(64)
    fp["#{j}"].y = cy - 32 + rand(64)
    fp["#{j}"].z = @targetSprite.z + 1
    fp["#{j}"].visible = false
    fp["#{j}"].zoom_x = @targetSprite.zoom_x
    fp["#{j}"].zoom_y = @targetSprite.zoom_y
  end
  for m in 0...12
    fp["p#{m}"] = Sprite.new(@viewport)
    fp["p#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_4")
    fp["p#{m}"].ox = fp["p#{m}"].bitmap.width/2
    fp["p#{m}"].oy = fp["p#{m}"].bitmap.height/2
    fp["p#{m}"].x = cx - 48 + rand(96)
    fp["p#{m}"].y = cy - 48 + rand(96)
    fp["p#{m}"].z = @targetSprite.z + 2
    fp["p#{m}"].visible = false
    fp["p#{m}"].zoom_x = @targetSprite.zoom_x
    fp["p#{m}"].zoom_y = @targetSprite.zoom_y
  end
  @targetSprite.color = Color.new(0,0,0,0)
  for i in 0...64
    fp["flare"].opacity += 32*(i < 8 ? 1 : -1)
    fp["flare"].angle += 32
    pbSEPlay("EBDX/Anim/fire1",80) if i == 8
    for j in 0...3
      next if i < 12
      next if j>(i-12)/4
      fp["#{j}"].visible = true
      fp["#{j}"].opacity -= 16
      fp["#{j}"].angle += 16
      fp["#{j}"].zoom_x += 0.1
      fp["#{j}"].zoom_y += 0.1
    end
    for m in 0...12
      next if i < 6
      next if m>(i-6)
      fp["p#{m}"].visible = true
      fp["p#{m}"].opacity -= 16
      fp["p#{m}"].y -= 8
    end
    if i >= 48
      @targetSprite.color.alpha -= 16
    else
      @targetSprite.color.alpha += 16 if @targetSprite.color.alpha < 192
    end
    @targetSprite.anim = true
    @scene.wait
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:STARBEAM) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  factor = @targetIsPlayer ? 2 : 1
  @viewport.color = Color.new(255,255,255,155)
  # set up animation
  fp = {}; rndx = []; rndy = []; crndx = []; crndy = []; dx = []; dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb027_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...16
    fp["c#{i}"] = Sprite.new(@viewport)
    fp["c#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["c#{i}"].ox = fp["c#{i}"].bitmap.width/2
    fp["c#{i}"].oy = fp["c#{i}"].bitmap.height/2
    fp["c#{i}"].opacity = 0
    fp["c#{i}"].z = 19
    crndx.push(rand(64))
    crndy.push(rand(64))
  end
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...16
    fp["c#{i}"] = Sprite.new(@viewport)
    fp["c#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["c#{i}"].ox = fp["c#{i}"].bitmap.width/2
    fp["c#{i}"].oy = fp["c#{i}"].bitmap.height/2
    fp["c#{i}"].opacity = 0
    fp["c#{i}"].z = 19
    crndx.push(rand(64))
    crndy.push(rand(64))
  end
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  @sprites["battlebg"].defocus
  # start animation
  for i in 0...96
    if i < 40
      fp["bg"].opacity += 25.5
    elsif i < 80
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("Anim/Ice8") if i == 12
    fp["bg"].update
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...72
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
      end
      next if j>(i)
      x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      x0 = dx[j]
      y0 = dy[j]
      fp["#{j}"].x += (x2 - x0)*0.05
      fp["#{j}"].y += (y2 - y0)*0.05
      fp["#{j}"].zoom_x = @targetIsPlayer ? @userSprite.zoom_x : @targetSprite.zoom_x
      fp["#{j}"].zoom_y = @targetIsPlayer ? @userSprite.zoom_y : @targetSprite.zoom_y
      fp["#{j}"].opacity += 32
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      nextx = fp["#{j}"].x + (x2 - x0)*0.05
      nexty = fp["#{j}"].y + (y2 - y0)*0.05
      if !@targetIsPlayer
        fp["#{j}"].z = @targetSprite.z - 1 if nextx > cx && nexty < cy
        fp["#{j}"].visible = false if nextx > cx && nexty < cy
      else
        fp["#{j}"].visible = false if nextx < cx && nexty > cy
      end
    end
    pbSEPlay("Anim/Ice1") if i>32 && (i-32)%4==0
    for j in 0...16
      if fp["c#{j}"].opacity == 0 && fp["c#{j}"].tone.gray == 0
        fp["c#{j}"].zoom_x = factor*@targetSprite.zoom_x
        fp["c#{j}"].zoom_y = factor*@targetSprite.zoom_x
        fp["c#{j}"].x = cx
        fp["c#{j}"].y = cy
      end
      next if j>((i-12)/4)
      next if i<12
      x2 = cx - 32*@targetSprite.zoom_x + crndx[j]*@targetSprite.zoom_x
      y2 = cy - 32*@targetSprite.zoom_y + crndy[j]*@targetSprite.zoom_y
      x0 = fp["c#{j}"].x
      y0 = fp["c#{j}"].y
      fp["c#{j}"].x += (x2 - x0)*0.2
      fp["c#{j}"].y += (y2 - y0)*0.2
      fp["c#{j}"].angle += 2
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["c#{j}"].opacity -= 24
        fp["c#{j}"].tone.gray += 8
        fp["c#{j}"].angle += 2
      else
        fp["c#{j}"].opacity += 35
      end
    end
    fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.5
    if i >= 32
      @targetSprite.tone.red += 5.4 if @targetSprite.tone.red < 108
      @targetSprite.tone.green += 6.4 if @targetSprite.tone.green < 128
      @targetSprite.tone.blue += 8 if @targetSprite.tone.blue < 160
      @targetSprite.still
    end
    @vector.set(vector) if i == 24
    @vector.inc = 0.1 if i == 24
    @viewport.color.alpha -= 5 if @viewport.color.alpha > 0
    @scene.wait(1,true)
  end
  20.times do
    @targetSprite.tone.red -= 5.4
    @targetSprite.tone.green -= 6.4
    @targetSprite.tone.blue -= 8
    @targetSprite.still
    fp["bg"].opacity -= 15
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @targetSprite.tone = Tone.new(0,0,0)
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:TUNGSTENTOMB) do
  factor = @targetSprite.zoom_x
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  factor = @targetSprite.zoom_x
  # set up animation
  fp = {}
  dx = []
  dy = []
  cx, cy = @targetSprite.getCenter(true)
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb027_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for j in 0..16
    fp["i#{j}"] = Sprite.new(@viewport)
    fp["i#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523")
    fp["i#{j}"].ox = fp["i#{j}"].bitmap.width/2
    fp["i#{j}"].oy = fp["i#{j}"].bitmap.height/2
    r = 72*factor
    fp["i#{j}"].x = cx - r + rand(r*2)
    fp["i#{j}"].y = cy - r*1.5 + rand(r*2)
    fp["i#{j}"].z = @targetSprite.z + (rand(2)==0 ? 1 : -1)
    fp["i#{j}"].zoom_x = factor
    fp["i#{j}"].zoom_y = factor
    fp["i#{j}"].opacity = 0
    dx.push(rand(2)==0 ? 1 : -1)
    dy.push(rand(2)==0 ? 1 : -1)
  end
  for m in 0...24
    fp["d#{m}"] = Sprite.new(@viewport)
    fp["d#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523_2")
    fp["d#{m}"].src_rect.set(0,0,80,78)
    fp["d#{m}"].ox = fp["d#{m}"].src_rect.width/2
    fp["d#{m}"].oy = fp["d#{m}"].src_rect.height/2
    r = 32*factor
    fp["d#{m}"].x = cx - r + rand(r*2)
    fp["d#{m}"].y = cy - r + rand(r*2)
    fp["d#{m}"].z = @targetSprite.z + 1
    fp["d#{m}"].opacity = 0
    fp["d#{m}"].angle = rand(360)
  end
  for m in 0...24
    fp["s#{m}"] = Sprite.new(@viewport)
    fp["s#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523_2")
    fp["s#{m}"].src_rect.set(80,0,80,78)
    fp["s#{m}"].ox = fp["s#{m}"].src_rect.width/2
    fp["s#{m}"].oy = fp["s#{m}"].src_rect.height/2
    r = 32*factor
    fp["s#{m}"].x = fp["d#{m}"].x
    fp["s#{m}"].y = fp["d#{m}"].y
    fp["s#{m}"].z = @targetSprite.z + 1
    fp["s#{m}"].opacity = 0
    fp["s#{m}"].angle = fp["d#{m}"].angle
  end
  for m in 0...24
    fp["d#{m}"] = Sprite.new(@viewport)
    fp["d#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523_2")
    fp["d#{m}"].src_rect.set(0,0,80,78)
    fp["d#{m}"].ox = fp["d#{m}"].src_rect.width/2
    fp["d#{m}"].oy = fp["d#{m}"].src_rect.height/2
    r = 32*factor
    fp["d#{m}"].x = cx - r + rand(r*2)
    fp["d#{m}"].y = cy - r + rand(r*2)
    fp["d#{m}"].z = @targetSprite.z + 1
    fp["d#{m}"].opacity = 0
    fp["d#{m}"].angle = rand(360)
  end
  for m in 0...24
    fp["s#{m}"] = Sprite.new(@viewport)
    fp["s#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523_2")
    fp["s#{m}"].src_rect.set(80,0,80,78)
    fp["s#{m}"].ox = fp["s#{m}"].src_rect.width/2
    fp["s#{m}"].oy = fp["s#{m}"].src_rect.height/2
    r = 32*factor
    fp["s#{m}"].x = fp["d#{m}"].x
    fp["s#{m}"].y = fp["d#{m}"].y
    fp["s#{m}"].z = @targetSprite.z + 1
    fp["s#{m}"].opacity = 0
    fp["s#{m}"].angle = fp["d#{m}"].angle
  end
  pbSEPlay("EBDX/Anim/iron4",100)
  for i in 0...48
    if i < 20
      fp["bg"].opacity += 25.5
    elsif i < 40
      fp["bg"].color.alpha -= 25.5
    end
    k = (i-16)/4
    pbSEPlay("EBDX/Anim/psychic4",80-20*k) if i >= 16 && i%4==0 && i < 28
    fp["bg"].update
    for j in 0...16
      next if j>(i/2)
      t = fp["i#{j}"].tone.red
      t += 32 if i%4==0
      t = 0 if t > 96
      fp["i#{j}"].tone = Tone.new(t,t,t)
      fp["i#{j}"].opacity += 16
      fp["i#{j}"].angle += dx[j]
    end
    @scene.wait
  end
  for i in 0...64
    pbSEPlay("EBDX/Anim/normal1",80) if i >= 2 && i%4==0 && i < 26
    for j in 0...16
      next if j>(i)
      fp["i#{j}"].x += (cx - fp["i#{j}"].x)*0.5
      fp["i#{j}"].y += (cy - fp["i#{j}"].y)*0.5
      fp["i#{j}"].angle += dx[j]
      fp["i#{j}"].visible = (cx - fp["i#{j}"].x)*0.5 >= 1
    end
    for m in 0...12
      next if i < 6
      next if m>(i-6)/2
      fp["d#{m}"].opacity += 32*(fp["d#{m}"].zoom_x < 1.5 ? 1 : -1)
      fp["d#{m}"].zoom_x += 0.05
      fp["d#{m}"].zoom_y += 0.05
      fp["d#{m}"].angle += 4
      fp["s#{m}"].opacity += 32*(fp["s#{m}"].zoom_x < 1.5 ? 1 : -1)
      fp["s#{m}"].zoom_x += 0.05
      fp["s#{m}"].zoom_y += 0.05
      fp["s#{m}"].angle += 4
    end
    @targetSprite.still
    @scene.wait
  end
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
EliteBattle.defineMoveAnimation(:RHYTHMICRUSH) do | args |
  kick = args[0]; kick = false if kick.nil?
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
  fp["bg"].opacity = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_3")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 50
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)/2
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)/2
    rndx.push(rand(144))
    rndy.push(rand(144))
  end
  fp["punch"] = Sprite.new(@viewport)
  fp["punch"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb#{kick ? 137 : 108}")
  fp["punch"].ox = fp["punch"].bitmap.width/2
  fp["punch"].oy = fp["punch"].bitmap.height/2
  fp["punch"].opacity = 0
  fp["punch"].z = 40
  fp["punch"].angle = 180
  fp["punch"].zoom_x = @targetIsPlayer ? 6 : 4
  fp["punch"].zoom_y = @targetIsPlayer ? 6 : 4
  fp["punch"].tone = Tone.new(48,16,6)
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  pbSEPlay("Anim/fog2", 75)
  @sprites["battlebg"].defocus
  for i in 0...36
    cx, cy = @targetSprite.getCenter(true)
    fp["punch"].x = cx
    fp["punch"].y = cy
    fp["punch"].angle -= 45 if i < 20
    fp["punch"].zoom_x -= @targetIsPlayer ? 0.2 : 0.15 if i < 20
    fp["punch"].zoom_y -= @targetIsPlayer ? 0.2 : 0.15 if i < 20
    fp["punch"].opacity += 8 if i < 20
    if i >= 20
      fp["punch"].tone = Tone.new(255,255,255) if i == 20
      fp["punch"].tone.all -= 25.5
      fp["punch"].opacity -= 25.5
    end
    pbSEPlay("Anim/Fire3") if i==20
    for j in 0...12
      next if i < 20
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 72*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 72*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].src_rect.x += 53 if i%2==0
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 16
        fp["#{j}"].tone.gray += 16
        fp["#{j}"].tone.red -= 4; fp["#{j}"].tone.green -= 4; fp["#{j}"].tone.blue -= 4
        fp["#{j}"].zoom_x -= 0.005
        fp["#{j}"].zoom_y += 0.01
      else
        fp["#{j}"].opacity += 45
      end
    end
    fp["bg"].opacity += 4 if  i < 20
    if i >= 20
      if i >= 28
        @targetSprite.tone.red -= 3*2
        @targetSprite.tone.green += 1.5*2
        @targetSprite.tone.blue += 3*2
        fp["bg"].opacity -= 10
      else
        @targetSprite.tone.red += 3*2 if @targetSprite.tone.red < 48*2
        @targetSprite.tone.green -= 1.5*2 if @targetSprite.tone.green > -24*2
        @targetSprite.tone.blue -= 3*2 if @targetSprite.tone.blue > -48*2
      end
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:ASTROPUNCH) do | args |
  kick = args[0]; kick = false if kick.nil?
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
  fp["bg"].opacity = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 50
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)/2
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)/2
    rndx.push(rand(144))
    rndy.push(rand(144))
  end
  fp["punch"] = Sprite.new(@viewport)
  fp["punch"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb#{kick ? 137 : 108}")
  fp["punch"].ox = fp["punch"].bitmap.width/2
  fp["punch"].oy = fp["punch"].bitmap.height/2
  fp["punch"].opacity = 0
  fp["punch"].z = 40
  fp["punch"].angle = 180
  fp["punch"].zoom_x = @targetIsPlayer ? 6 : 4
  fp["punch"].zoom_y = @targetIsPlayer ? 6 : 4
  fp["punch"].tone = Tone.new(48,16,6)
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  pbSEPlay("Anim/fog2", 75)
  @sprites["battlebg"].defocus
  for i in 0...36
    cx, cy = @targetSprite.getCenter(true)
    fp["punch"].x = cx
    fp["punch"].y = cy
    fp["punch"].angle -= 45 if i < 20
    fp["punch"].zoom_x -= @targetIsPlayer ? 0.2 : 0.15 if i < 20
    fp["punch"].zoom_y -= @targetIsPlayer ? 0.2 : 0.15 if i < 20
    fp["punch"].opacity += 8 if i < 20
    if i >= 20
      fp["punch"].tone = Tone.new(255,255,255) if i == 20
      fp["punch"].tone.all -= 25.5
      fp["punch"].opacity -= 25.5
    end
    pbSEPlay("Anim/Fire3") if i==20
    for j in 0...12
      next if i < 20
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 72*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 72*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].src_rect.x += 53 if i%2==0
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 16
        fp["#{j}"].tone.gray += 16
        fp["#{j}"].tone.red -= 4; fp["#{j}"].tone.green -= 4; fp["#{j}"].tone.blue -= 4
        fp["#{j}"].zoom_x -= 0.005
        fp["#{j}"].zoom_y += 0.01
      else
        fp["#{j}"].opacity += 45
      end
    end
    fp["bg"].opacity += 4 if  i < 20
    if i >= 20
      if i >= 28
        @targetSprite.tone.red -= 3*2
        @targetSprite.tone.green += 1.5*2
        @targetSprite.tone.blue += 3*2
        fp["bg"].opacity -= 10
      else
        @targetSprite.tone.red += 3*2 if @targetSprite.tone.red < 48*2
        @targetSprite.tone.green -= 1.5*2 if @targetSprite.tone.green > -24*2
        @targetSprite.tone.blue -= 3*2 if @targetSprite.tone.blue > -48*2
      end
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:MACHPULSE) do | args |
  kick = args[0]; kick = false if kick.nil?
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
  fp["bg"].opacity = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound1")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 50
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)/2
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)/2
    rndx.push(rand(144))
    rndy.push(rand(144))
  end
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 50
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)/2
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)/2
    rndx.push(rand(144))
    rndy.push(rand(144))
  end
  for i in 0...6
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound1")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 50
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)/2
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)/2
    rndx.push(rand(144))
    rndy.push(rand(144))
  end
  for i in 0...6
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 50
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)/2
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)/2
    rndx.push(rand(144))
    rndy.push(rand(144))
  end
  fp["punch"] = Sprite.new(@viewport)
  fp["punch"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebItem1")
  fp["punch"].ox = fp["punch"].bitmap.width/2
  fp["punch"].oy = fp["punch"].bitmap.height/2
  fp["punch"].opacity = 0
  fp["punch"].z = 40
  fp["punch"].angle = 180
  fp["punch"].zoom_x = @targetIsPlayer ? 6 : 4
  fp["punch"].zoom_y = @targetIsPlayer ? 6 : 4
  fp["punch"].tone = Tone.new(48,16,6)
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  pbSEPlay("Anim/fog2", 75)
  @sprites["battlebg"].defocus
  for i in 0...36
    cx, cy = @targetSprite.getCenter(true)
    fp["punch"].x = cx
    fp["punch"].y = cy
    fp["punch"].angle -= 45 if i < 20
    fp["punch"].zoom_x -= @targetIsPlayer ? 0.2 : 0.15 if i < 20
    fp["punch"].zoom_y -= @targetIsPlayer ? 0.2 : 0.15 if i < 20
    fp["punch"].opacity += 8 if i < 20
    if i >= 20
      fp["punch"].tone = Tone.new(255,255,255) if i == 20
      fp["punch"].tone.all -= 25.5
      fp["punch"].opacity -= 25.5
    end
    pbSEPlay("Anim/Fire3") if i==20
    for j in 0...12
      next if i < 20
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 72*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 72*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].src_rect.x += 53 if i%2==0
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 16
        fp["#{j}"].tone.gray += 16
        fp["#{j}"].tone.red -= 4; fp["#{j}"].tone.green -= 4; fp["#{j}"].tone.blue -= 4
        fp["#{j}"].zoom_x -= 0.005
        fp["#{j}"].zoom_y += 0.01
      else
        fp["#{j}"].opacity += 45
      end
    end
    fp["bg"].opacity += 4 if  i < 20
    if i >= 20
      if i >= 28
        @targetSprite.tone.red -= 3*2
        @targetSprite.tone.green += 1.5*2
        @targetSprite.tone.blue += 3*2
        fp["bg"].opacity -= 10
      else
        @targetSprite.tone.red += 3*2 if @targetSprite.tone.red < 48*2
        @targetSprite.tone.green -= 1.5*2 if @targetSprite.tone.green > -24*2
        @targetSprite.tone.blue -= 3*2 if @targetSprite.tone.blue > -48*2
      end
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:ECHORUSH) do | args |
  kick = args[0]; kick = false if kick.nil?
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
  fp["bg"].opacity = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound1")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 50
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)/2
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)/2
    rndx.push(rand(144))
    rndy.push(rand(144))
  end
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 50
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)/2
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)/2
    rndx.push(rand(144))
    rndy.push(rand(144))
  end
  for i in 0...6
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound1")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 50
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)/2
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)/2
    rndx.push(rand(144))
    rndy.push(rand(144))
  end
  for i in 0...6
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 50
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)/2
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)/2
    rndx.push(rand(144))
    rndy.push(rand(144))
  end
  fp["punch"] = Sprite.new(@viewport)
  fp["punch"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb108")
  fp["punch"].ox = fp["punch"].bitmap.width/2
  fp["punch"].oy = fp["punch"].bitmap.height/2
  fp["punch"].opacity = 0
  fp["punch"].z = 40
  fp["punch"].angle = 180
  fp["punch"].zoom_x = @targetIsPlayer ? 6 : 4
  fp["punch"].zoom_y = @targetIsPlayer ? 6 : 4
  fp["punch"].tone = Tone.new(48,16,6)
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  pbSEPlay("Anim/fog2", 75)
  @sprites["battlebg"].defocus
  for i in 0...36
    cx, cy = @targetSprite.getCenter(true)
    fp["punch"].x = cx
    fp["punch"].y = cy
    fp["punch"].angle -= 45 if i < 20
    fp["punch"].zoom_x -= @targetIsPlayer ? 0.2 : 0.15 if i < 20
    fp["punch"].zoom_y -= @targetIsPlayer ? 0.2 : 0.15 if i < 20
    fp["punch"].opacity += 8 if i < 20
    if i >= 20
      fp["punch"].tone = Tone.new(255,255,255) if i == 20
      fp["punch"].tone.all -= 25.5
      fp["punch"].opacity -= 25.5
    end
    pbSEPlay("Anim/Fire3") if i==20
    for j in 0...12
      next if i < 20
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 72*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 72*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].src_rect.x += 53 if i%2==0
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 16
        fp["#{j}"].tone.gray += 16
        fp["#{j}"].tone.red -= 4; fp["#{j}"].tone.green -= 4; fp["#{j}"].tone.blue -= 4
        fp["#{j}"].zoom_x -= 0.005
        fp["#{j}"].zoom_y += 0.01
      else
        fp["#{j}"].opacity += 45
      end
    end
    fp["bg"].opacity += 4 if  i < 20
    if i >= 20
      if i >= 28
        @targetSprite.tone.red -= 3*2
        @targetSprite.tone.green += 1.5*2
        @targetSprite.tone.blue += 3*2
        fp["bg"].opacity -= 10
      else
        @targetSprite.tone.red += 3*2 if @targetSprite.tone.red < 48*2
        @targetSprite.tone.green -= 1.5*2 if @targetSprite.tone.green > -24*2
        @targetSprite.tone.blue -= 3*2 if @targetSprite.tone.blue > -48*2
      end
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:SPACIALGROVE) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb027_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb191_2")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb191")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb191_3")
    fp["#{i}s"].ox = fp["#{i}s"].bitmap.width/2
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height + 8*factor
    fp["#{i}s"].angle = rand(360)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  k = 0
  # start animation
  @vector.set(vector2)
  @sprites["battlebg"].defocus
  for i in 0...30
    if i < 10
      fp["bg"].opacity += 25.5
    elsif i < 20
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("EBDX/Anim/grass2") if i == 20
    fp["bg"].update
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/wind1",90)
  for i in 0...96
    pbSEPlay("EBDX/Anim/grass1",60) if i%3==0 && i < 64
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].oy +=6*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = @userSprite.getCenter
    end
    #pbSEPlay("Anim/Comet Punch") if i == 64
    fp["bg"].update
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  for i in 0...20
    @targetSprite.still
    if i < 10
      fp["bg"].color.alpha += 25.5
    else
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:SIRENSSONG) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb536_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb191_3")
    fp["#{i}s"].ox = fp["#{i}s"].bitmap.width/2
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height + 8*factor
    fp["#{i}s"].angle = rand(360)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  k = 0
  # start animation
  @vector.set(vector2)
  @sprites["battlebg"].defocus
  for i in 0...30
    if i < 10
      fp["bg"].opacity += 25.5
    elsif i < 20
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("EBDX/Anim/grass2") if i == 20
    fp["bg"].update
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/wind1",90)
  for i in 0...96
    pbSEPlay("EBDX/Anim/grass1",60) if i%3==0 && i < 64
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].oy +=6*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = @userSprite.getCenter
    end
    #pbSEPlay("Anim/Comet Punch") if i == 64
    fp["bg"].update
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  for i in 0...20
    @targetSprite.still
    if i < 10
      fp["bg"].color.alpha += 25.5
    else
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:POWERGEM) do
  factor = @targetSprite.zoom_x
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  factor = @targetSprite.zoom_x
  # set up animation
  fp = {}
  dx = []
  dy = []
  cx, cy = @targetSprite.getCenter(true)
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb027_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for j in 0..16
    fp["i#{j}"] = Sprite.new(@viewport)
    fp["i#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb223")
    fp["i#{j}"].ox = fp["i#{j}"].bitmap.width/2
    fp["i#{j}"].oy = fp["i#{j}"].bitmap.height/2
    r = 72*factor
    fp["i#{j}"].x = cx - r + rand(r*2)
    fp["i#{j}"].y = cy - r*1.5 + rand(r*2)
    fp["i#{j}"].z = @targetSprite.z + (rand(2)==0 ? 1 : -1)
    fp["i#{j}"].zoom_x = factor
    fp["i#{j}"].zoom_y = factor
    fp["i#{j}"].opacity = 0
    dx.push(rand(2)==0 ? 1 : -1)
    dy.push(rand(2)==0 ? 1 : -1)
  end
  for m in 0...24
    fp["d#{m}"] = Sprite.new(@viewport)
    fp["d#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb223")
    fp["d#{m}"].src_rect.set(0,0,80,78)
    fp["d#{m}"].ox = fp["d#{m}"].src_rect.width/2
    fp["d#{m}"].oy = fp["d#{m}"].src_rect.height/2
    r = 32*factor
    fp["d#{m}"].x = cx - r + rand(r*2)
    fp["d#{m}"].y = cy - r + rand(r*2)
    fp["d#{m}"].z = @targetSprite.z + 1
    fp["d#{m}"].opacity = 0
    fp["d#{m}"].angle = rand(360)
  end
  for m in 0...24
    fp["s#{m}"] = Sprite.new(@viewport)
    fp["s#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb223")
    fp["s#{m}"].src_rect.set(80,0,80,78)
    fp["s#{m}"].ox = fp["s#{m}"].src_rect.width/2
    fp["s#{m}"].oy = fp["s#{m}"].src_rect.height/2
    r = 32*factor
    fp["s#{m}"].x = fp["d#{m}"].x
    fp["s#{m}"].y = fp["d#{m}"].y
    fp["s#{m}"].z = @targetSprite.z + 1
    fp["s#{m}"].opacity = 0
    fp["s#{m}"].angle = fp["d#{m}"].angle
  end
  pbSEPlay("EBDX/Anim/rock1",100)
  for i in 0...48
    if i < 20
      fp["bg"].opacity += 25.5
    elsif i < 40
      fp["bg"].color.alpha -= 25.5
    end
    k = (i-16)/4
    pbSEPlay("EBDX/Anim/psychic4",80-20*k) if i >= 16 && i%4==0 && i < 28
    fp["bg"].update
    for j in 0...16
      next if j>(i/2)
      t = fp["i#{j}"].tone.red
      t += 32 if i%4==0
      t = 0 if t > 96
      fp["i#{j}"].tone = Tone.new(t,t,t)
      fp["i#{j}"].opacity += 16
      fp["i#{j}"].angle += dx[j]
    end
    @scene.wait
  end
  for i in 0...64
    pbSEPlay("EBDX/Anim/rock2",80) if i >= 2 && i%4==0 && i < 26
    for j in 0...16
      next if j>(i)
      fp["i#{j}"].x += (cx - fp["i#{j}"].x)*0.5
      fp["i#{j}"].y += (cy - fp["i#{j}"].y)*0.5
      fp["i#{j}"].angle += dx[j]
      fp["i#{j}"].visible = (cx - fp["i#{j}"].x)*0.5 >= 1
    end
    for m in 0...12
      next if i < 6
      next if m>(i-6)/2
      fp["d#{m}"].opacity += 32*(fp["d#{m}"].zoom_x < 1.5 ? 1 : -1)
      fp["d#{m}"].zoom_x += 0.05
      fp["d#{m}"].zoom_y += 0.05
      fp["d#{m}"].angle += 4
      fp["s#{m}"].opacity += 32*(fp["s#{m}"].zoom_x < 1.5 ? 1 : -1)
      fp["s#{m}"].zoom_x += 0.05
      fp["s#{m}"].zoom_y += 0.05
      fp["s#{m}"].angle += 4
    end
    @targetSprite.still
    @scene.wait
  end
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
EliteBattle.defineMoveAnimation(:PALEOBEAM) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb504")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb191_3")
    fp["#{i}s"].ox = fp["#{i}s"].bitmap.width/2
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height + 8*factor
    fp["#{i}s"].angle = rand(360)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  k = 0
  # start animation
  @vector.set(vector2)
  @sprites["battlebg"].defocus
  for i in 0...30
    pbSEPlay("EBDX/Anim/rock1") if i == 20
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/wind1",90)
  for i in 0...96
    pbSEPlay("EBDX/Anim/rock2",60) if i%3==0 && i < 64
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].oy +=6*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = @userSprite.getCenter
    end
    #pbSEPlay("Anim/Comet Punch") if i == 64
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:PIXIEPUNCH) do
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  # set up animation
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  fp = {}
  dx = []
  dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb027_bg")
  fp["bg"].opacity = 0
  fp["bg"].z = 50
  for j in 0...12
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb59_3")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
    r = 128*factor
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    z = [1,0.75,0.5][rand(3)]
    fp["s#{j}"].zoom_x = z
    fp["s#{j}"].zoom_y = z
    fp["s#{j}"].x = cx
    fp["s#{j}"].y = cy
    fp["s#{j}"].z = @targetSprite.z + 1
    fp["s#{j}"].visible = false
    dx.push(x)
    dy.push(y)
  end
  fp["slash"] = Sprite.new(@viewport)
  fp["slash"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb430")
  fp["slash"].oy = fp["slash"].bitmap.height/2
  fp["slash"].y = cy
  fp["slash"].x = @viewport.width
  fp["slash"].opacity = 0
  fp["slash"].z = 50
  # play animation
  pbSEPlay("Anim/gust",90)
  for m in 0...2
    shake = 2
    for i in 0...(m < 1 ? 32 : 16)
      fp["bg"].opacity += 16 if m < 1
      fp["bg"].update
      if m < 1
        fp["slash"].x -= 64 if i >= 28
        fp["slash"].opacity += 64 if i >= 28
      else
        fp["slash"].x += 64 if i >= 12
        fp["slash"].opacity += 64 if i >= 12
      end
      @scene.wait(1,true)
    end
    pbSEPlay("Anim/hit")
    for i in 0...16
      fp["bg"].opacity -= 16
      for j in 0...12
        fp["s#{j}"].visible = true
        fp["s#{j}"].x -= (fp["s#{j}"].x - dx[j])*0.1
        fp["s#{j}"].y -= (fp["s#{j}"].y - dy[j])*0.1
        fp["s#{j}"].zoom_x -= 0.04
        fp["s#{j}"].zoom_y -= 0.04
        fp["s#{j}"].tone.gray += 16
        fp["s#{j}"].tone.red -= 8
        fp["s#{j}"].tone.green -= 8
        fp["s#{j}"].tone.blue -= 8
        fp["s#{j}"].opacity -= 16
      end
      if m < 1
        fp["slash"].x -= 64
      else
        fp["slash"].x += 64
      end
      fp["slash"].opacity -= 32
      @targetSprite.ox += shake
      shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
      @scene.wait
    end
    @targetSprite.ox = @targetSprite.bitmap.width/2
    dx.clear
    dy.clear
    fp["slash"].mirror = true
    fp["slash"].ox = fp["slash"].bitmap.width
    fp["slash"].opacity = 0
    fp["slash"].x = 0
    for j in 0...12
      fp["s#{j}"].x = cx
      fp["s#{j}"].y = cy
      fp["s#{j}"].tone = Tone.new(0,0,0,0)
      fp["s#{j}"].opacity = 255
      fp["s#{j}"].visible = false
      z = [1,0.75,0.5][rand(3)]
      fp["s#{j}"].zoom_x = z
      fp["s#{j}"].zoom_y = z
      r = 128*factor
      x, y = randCircleCord(r)
      x = cx - r + x
      y = cy - r + y
      dx.push(x)
      dy.push(y)
    end
  end
  @scene.wait(8)
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:RECHARGE) do | args |
  beam, strike = *args; beam = false if beam.nil?; strike = false if strike.nil?
  factor = 2
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].create_rect(@viewport.width,@viewport.height,Color.black)
  fp["bg"].opacity = 0
  @userSprite.color = Color.new(217,189,52,0) if strike
  rndx = []
  rndy = []
  for i in 0...8
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb081_2")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
  end
  for i in 0...16
    fp["c#{i}"] = Sprite.new(@viewport)
    fp["c#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb081")
    fp["c#{i}"].ox = fp["c#{i}"].bitmap.width/2
    fp["c#{i}"].oy = fp["c#{i}"].bitmap.height/2
    fp["c#{i}"].opacity = 0
    fp["c#{i}"].z = 51
    rndx.push(0)
    rndy.push(0)
  end
  m = 0
  fp["circle"] = Sprite.new(@viewport)
  fp["circle"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb081_3")
  fp["circle"].ox = fp["circle"].bitmap.width/4
  fp["circle"].oy = fp["circle"].bitmap.height/2
  fp["circle"].opacity = 0
  fp["circle"].src_rect.set(0,0,484,488)
  fp["circle"].z = 50
  fp["circle"].zoom_x = 0.5
  fp["circle"].zoom_y = 0.5
  # start animation
  @vector.set(@scene.getRealVector(@userIndex, @targetIsPlayer))
  @sprites["battlebg"].defocus
  for i in 0...112
    pbSEPlay("Anim/Flash3",90) if i == 32
    pbSEPlay("Anim/Saint8") if i == 64
    cx, cy = @userSprite.getCenter
    for j in 0...8
      if fp["#{j}"].opacity == 0
        r = rand(2)
        fp["#{j}"].zoom_x = factor*(r==0 ? 1 : 0.5)
        fp["#{j}"].zoom_y = factor*(r==0 ? 1 : 0.5)
        fp["#{j}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
        x, y = randCircleCord(96*factor)
        fp["#{j}"].x = cx - 96*factor*@userSprite.zoom_x + x*@userSprite.zoom_x
        fp["#{j}"].y = cy - 96*factor*@userSprite.zoom_y + y*@userSprite.zoom_y
      end
      next if j>(i/8)
      x2 = cx
      y2 = cy
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].zoom_x -= fp["#{j}"].zoom_x*0.1
      fp["#{j}"].zoom_y -= fp["#{j}"].zoom_y*0.1
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*(180.0/Math::PI)# + (rand{4}==0 ? 180 : 0)
      fp["#{j}"].mirror = !fp["#{j}"].mirror if i%2==0
      if i >= 96
        fp["#{j}"].opacity -= 35
      elsif (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
        fp["#{j}"].opacity = 0
      else
        fp["#{j}"].opacity += 35
      end
    end
    for k in 0...16
      if fp["c#{k}"].opacity == 0
        r = rand(2)
        fp["c#{k}"].zoom_x = (r==0 ? 1 : 0.5)
        fp["c#{k}"].zoom_y = (r==0 ? 1 : 0.5)
        fp["c#{k}"].tone = rand(2)==0 ? Tone.new(196,196,196) : Tone.new(0,0,0)
        x, y = randCircleCord(48*factor)
        rndx[k] = cx - 48*factor*@userSprite.zoom_x + x*@userSprite.zoom_x
        rndy[k] = cy - 48*factor*@userSprite.zoom_y + y*@userSprite.zoom_y
        fp["c#{k}"].x = cx
        fp["c#{k}"].y = cy
      end
      next if k>(i/4)
      x2 = rndx[k]
      y2 = rndy[k]
      x0 = fp["c#{k}"].x
      y0 = fp["c#{k}"].y
      fp["c#{k}"].x += (x2 - x0)*0.05
      fp["c#{k}"].y += (y2 - y0)*0.05
      fp["c#{k}"].opacity += 5
    end
    fp["circle"].x = cx
    fp["circle"].y = cy
    fp["circle"].opacity += 25.5
    if i < 124
      fp["circle"].zoom_x += 0.01
      fp["circle"].zoom_y += 0.01
    else
      fp["circle"].zoom_x += 0.05
      fp["circle"].zoom_y += 0.05
    end
    m = 1 if i%4==0
    fp["circle"].src_rect.x = 484*m
    m = 0 if i%2==0
    if i < 96
      if strike
        fp["bg"].opacity += 10 if fp["bg"].opacity < 255
      else
        fp["bg"].opacity += 5 if fp["bg"].opacity < 255*0.75
      end
    else
      fp["bg"].opacity -= 10 if !beam && !strike
    end
    if strike && i > 16
      @userSprite.color.alpha += 10 if @userSprite.color.alpha < 200
      fp["circle"].opacity -= 76.5 if i > 106
      for k in 0...16
        next if i < 96
        fp["c#{k}"].opacity -= 30.5
      end
      for j in 0...8
        next if i < 96
        fp["#{j}"].opacity -= 30.5
      end
    end
    @userSprite.still if !strike
    @userSprite.anim = true if strike
    @scene.wait(1,true)
  end
  if strike
    for i in 0...2
      8.times do
        @userSprite.x -= (@targetIsPlayer ? 12 : -6)*(i==0 ? 1 : -1)
        @userSprite.y += (@targetIsPlayer ? 4 : -2)*(i==0 ? 1 : -1)
        @userSprite.zoom_y -= (factor*0.04)*(i==0 ? 1 : -1)
        @userSprite.still
        @scene.wait
      end
    end
  end
  pbDisposeSpriteHash(fp)
  if !beam && !strike
    @sprites["battlebg"].focus
    @vector.reset if !@multiHit
    @viewport.color = Color.new(255,255,255,255)
    10.times do
      @viewport.color.alpha -= 25.5
      @scene.wait(1,true)
    end
  end
end
EliteBattle.defineMoveAnimation(:SONICFANGS) do
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(66,60,81))
  fp["bg"].opacity = 0
  for i in 0...10
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
    fp["#{i}"].ox = 6
    fp["#{i}"].oy = 5
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)
    rndx.push(rand(128))
    rndy.push(rand(128))
  end
  fp["fang1"] = Sprite.new(@viewport)
  fp["fang1"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang1"].ox = fp["fang1"].bitmap.width/2
  fp["fang1"].oy = fp["fang1"].bitmap.height - 20
  fp["fang1"].opacity = 0
  fp["fang1"].z = 41
  fp["fang2"] = Sprite.new(@viewport)
  fp["fang2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang2"].ox = fp["fang1"].bitmap.width/2
  fp["fang2"].oy = fp["fang1"].bitmap.height - 20
  fp["fang2"].opacity = 0
  fp["fang2"].z = 40
  fp["fang2"].angle = 180
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @sprites["battlebg"].defocus
  for i in 0...72
    cx, cy = @targetSprite.getCenter(true)
    fp["fang1"].x = cx; fp["fang1"].y = cy
    fp["fang1"].zoom_x = @targetSprite.zoom_x; fp["fang1"].zoom_y = @targetSprite.zoom_y
    fp["fang2"].x = cx; fp["fang2"].y = cy
    fp["fang2"].zoom_x = @targetSprite.zoom_x; fp["fang2"].zoom_y = @targetSprite.zoom_y
    if i.between?(20,29)
      fp["fang1"].opacity += 5
      fp["fang1"].oy += 2
      fp["fang2"].opacity += 5
      fp["fang2"].oy += 2
    elsif i.between?(30,40)
      fp["fang1"].opacity += 25.5
      fp["fang1"].oy -= 4
      fp["fang2"].opacity += 25.5
      fp["fang2"].oy -= 4
    else
      fp["fang1"].opacity -= 26
      fp["fang1"].oy += 2
      fp["fang2"].opacity -= 26
      fp["fang2"].oy += 2
    end
    if i==32
      pbSEPlay("Anim/Super Fang")
    end
    for j in 0...10
      next if i < 40
      if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 64*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 64*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].angle += 16
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].zoom_x += 0.001
      fp["#{j}"].zoom_y += 0.001
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].opacity += 45
        fp["#{j}"].angle += 16
      end
      fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
    end
    fp["bg"].opacity += 4 if  i < 40
    if i >= 40
      if i >= 56
        @targetSprite.tone.red -= 3*2
        @targetSprite.tone.green -= 3*2
        @targetSprite.tone.blue -= 3*2
        fp["bg"].opacity -= 10
      else
        @targetSprite.tone.red += 3*2 if @targetSprite.tone.red < 48*2
        @targetSprite.tone.green += 3*2 if @targetSprite.tone.green < 48*2
        @targetSprite.tone.blue += 3*2 if @targetSprite.tone.blue < 48*2
      end
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:COSMICFANGS) do
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(66,60,81))
  fp["bg"].opacity = 0
  for i in 0...10
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["#{i}"].ox = 6
    fp["#{i}"].oy = 5
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)
    rndx.push(rand(128))
    rndy.push(rand(128))
  end
  fp["fang1"] = Sprite.new(@viewport)
  fp["fang1"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang1"].ox = fp["fang1"].bitmap.width/2
  fp["fang1"].oy = fp["fang1"].bitmap.height - 20
  fp["fang1"].opacity = 0
  fp["fang1"].z = 41
  fp["fang2"] = Sprite.new(@viewport)
  fp["fang2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang2"].ox = fp["fang1"].bitmap.width/2
  fp["fang2"].oy = fp["fang1"].bitmap.height - 20
  fp["fang2"].opacity = 0
  fp["fang2"].z = 40
  fp["fang2"].angle = 180
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @sprites["battlebg"].defocus
  for i in 0...72
    cx, cy = @targetSprite.getCenter(true)
    fp["fang1"].x = cx; fp["fang1"].y = cy
    fp["fang1"].zoom_x = @targetSprite.zoom_x; fp["fang1"].zoom_y = @targetSprite.zoom_y
    fp["fang2"].x = cx; fp["fang2"].y = cy
    fp["fang2"].zoom_x = @targetSprite.zoom_x; fp["fang2"].zoom_y = @targetSprite.zoom_y
    if i.between?(20,29)
      fp["fang1"].opacity += 5
      fp["fang1"].oy += 2
      fp["fang2"].opacity += 5
      fp["fang2"].oy += 2
    elsif i.between?(30,40)
      fp["fang1"].opacity += 25.5
      fp["fang1"].oy -= 4
      fp["fang2"].opacity += 25.5
      fp["fang2"].oy -= 4
    else
      fp["fang1"].opacity -= 26
      fp["fang1"].oy += 2
      fp["fang2"].opacity -= 26
      fp["fang2"].oy += 2
    end
    if i==32
      pbSEPlay("Anim/Super Fang")
    end
    for j in 0...10
      next if i < 40
      if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 64*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 64*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].angle += 16
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].zoom_x += 0.001
      fp["#{j}"].zoom_y += 0.001
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].opacity += 45
        fp["#{j}"].angle += 16
      end
      fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
    end
    fp["bg"].opacity += 4 if  i < 40
    if i >= 40
      if i >= 56
        @targetSprite.tone.red -= 3*2
        @targetSprite.tone.green -= 3*2
        @targetSprite.tone.blue -= 3*2
        fp["bg"].opacity -= 10
      else
        @targetSprite.tone.red += 3*2 if @targetSprite.tone.red < 48*2
        @targetSprite.tone.green += 3*2 if @targetSprite.tone.green < 48*2
        @targetSprite.tone.blue += 3*2 if @targetSprite.tone.blue < 48*2
      end
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:IRONFANGS) do
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(66,60,81))
  fp["bg"].opacity = 0
  for i in 0...10
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb024")
    fp["#{i}"].ox = 6
    fp["#{i}"].oy = 5
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)
    rndx.push(rand(128))
    rndy.push(rand(128))
  end
  fp["fang1"] = Sprite.new(@viewport)
  fp["fang1"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang1"].ox = fp["fang1"].bitmap.width/2
  fp["fang1"].oy = fp["fang1"].bitmap.height - 20
  fp["fang1"].opacity = 0
  fp["fang1"].z = 41
  fp["fang2"] = Sprite.new(@viewport)
  fp["fang2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang2"].ox = fp["fang1"].bitmap.width/2
  fp["fang2"].oy = fp["fang1"].bitmap.height - 20
  fp["fang2"].opacity = 0
  fp["fang2"].z = 40
  fp["fang2"].angle = 180
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @sprites["battlebg"].defocus
  for i in 0...72
    cx, cy = @targetSprite.getCenter(true)
    fp["fang1"].x = cx; fp["fang1"].y = cy
    fp["fang1"].zoom_x = @targetSprite.zoom_x; fp["fang1"].zoom_y = @targetSprite.zoom_y
    fp["fang2"].x = cx; fp["fang2"].y = cy
    fp["fang2"].zoom_x = @targetSprite.zoom_x; fp["fang2"].zoom_y = @targetSprite.zoom_y
    if i.between?(20,29)
      fp["fang1"].opacity += 5
      fp["fang1"].oy += 2
      fp["fang2"].opacity += 5
      fp["fang2"].oy += 2
    elsif i.between?(30,40)
      fp["fang1"].opacity += 25.5
      fp["fang1"].oy -= 4
      fp["fang2"].opacity += 25.5
      fp["fang2"].oy -= 4
    else
      fp["fang1"].opacity -= 26
      fp["fang1"].oy += 2
      fp["fang2"].opacity -= 26
      fp["fang2"].oy += 2
    end
    if i==32
      pbSEPlay("EBDX/Anim/iron5")
    end
    for j in 0...10
      next if i < 40
      if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 64*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 64*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].angle += 16
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].zoom_x += 0.001
      fp["#{j}"].zoom_y += 0.001
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].opacity += 45
        fp["#{j}"].angle += 16
      end
      fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
    end
    fp["bg"].opacity += 4 if  i < 40
    if i >= 40
      if i >= 56
        @targetSprite.tone.red -= 3*2
        @targetSprite.tone.green -= 3*2
        @targetSprite.tone.blue -= 3*2
        fp["bg"].opacity -= 10
      else
        @targetSprite.tone.red += 3*2 if @targetSprite.tone.red < 48*2
        @targetSprite.tone.green += 3*2 if @targetSprite.tone.green < 48*2
        @targetSprite.tone.blue += 3*2 if @targetSprite.tone.blue < 48*2
      end
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:TOXOPLASM) do
  EliteBattle.playMoveAnimation(:POISONJAB, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
  EliteBattle.playMoveAnimation(:ABSORB, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
EliteBattle.defineMoveAnimation(:LEECHLIFE) do
  EliteBattle.playMoveAnimation(:BITE, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
  EliteBattle.playMoveAnimation(:ABSORB, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
EliteBattle.defineMoveAnimation(:DRACOFANGS) do
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(66,60,81))
  fp["bg"].opacity = 0
  for i in 0...10
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebEnergy")
    fp["#{i}"].ox = 6
    fp["#{i}"].oy = 5
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)
    rndx.push(rand(128))
    rndy.push(rand(128))
  end
  fp["fang1"] = Sprite.new(@viewport)
  fp["fang1"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang1"].ox = fp["fang1"].bitmap.width/2
  fp["fang1"].oy = fp["fang1"].bitmap.height - 20
  fp["fang1"].opacity = 0
  fp["fang1"].z = 41
  fp["fang2"] = Sprite.new(@viewport)
  fp["fang2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb028")
  fp["fang2"].ox = fp["fang1"].bitmap.width/2
  fp["fang2"].oy = fp["fang1"].bitmap.height - 20
  fp["fang2"].opacity = 0
  fp["fang2"].z = 40
  fp["fang2"].angle = 180
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @sprites["battlebg"].defocus
  for i in 0...72
    cx, cy = @targetSprite.getCenter(true)
    fp["fang1"].x = cx; fp["fang1"].y = cy
    fp["fang1"].zoom_x = @targetSprite.zoom_x; fp["fang1"].zoom_y = @targetSprite.zoom_y
    fp["fang2"].x = cx; fp["fang2"].y = cy
    fp["fang2"].zoom_x = @targetSprite.zoom_x; fp["fang2"].zoom_y = @targetSprite.zoom_y
    if i.between?(20,29)
      fp["fang1"].opacity += 5
      fp["fang1"].oy += 2
      fp["fang2"].opacity += 5
      fp["fang2"].oy += 2
    elsif i.between?(30,40)
      fp["fang1"].opacity += 25.5
      fp["fang1"].oy -= 4
      fp["fang2"].opacity += 25.5
      fp["fang2"].oy -= 4
    else
      fp["fang1"].opacity -= 26
      fp["fang1"].oy += 2
      fp["fang2"].opacity -= 26
      fp["fang2"].oy += 2
    end
    if i==32
      pbSEPlay("EBDX/Anim/dragon1")
    end
    for j in 0...10
      next if i < 40
      if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 64*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 64*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].angle += 16
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].zoom_x += 0.001
      fp["#{j}"].zoom_y += 0.001
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].opacity += 45
        fp["#{j}"].angle += 16
      end
      fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
    end
    fp["bg"].opacity += 4 if  i < 40
    if i >= 40
      if i >= 56
        @targetSprite.tone.red -= 3*2
        @targetSprite.tone.green -= 3*2
        @targetSprite.tone.blue -= 3*2
        fp["bg"].opacity -= 10
      else
        @targetSprite.tone.red += 3*2 if @targetSprite.tone.red < 48*2
        @targetSprite.tone.green += 3*2 if @targetSprite.tone.green < 48*2
        @targetSprite.tone.blue += 3*2 if @targetSprite.tone.blue < 48*2
      end
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:DOPPLERPUNCH) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  fp = {}
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb086_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  # animation start
  @sprites["battlebg"].defocus
  @vector.set(vector)
  for i in 0...16
    fp["bg"].opacity += 32 if i >= 8
    @scene.wait(1,true)
  end
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  for j in 0...12
    fp["f#{j}"] = Sprite.new(@viewport)
    fp["f#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb108")
    fp["f#{j}"].ox = fp["f#{j}"].bitmap.width/2
    fp["f#{j}"].oy = fp["f#{j}"].bitmap.height/2
    fp["f#{j}"].z = @targetSprite.z + 1
    r = 32*factor
    fp["f#{j}"].x = cx - r + rand(r*2)
    fp["f#{j}"].y = cy - r + rand(r*2)
    fp["f#{j}"].visible = false
    fp["f#{j}"].zoom_x = factor
    fp["f#{j}"].zoom_y = factor
    fp["f#{j}"].color = Color.new(180,53,2,0)
  end
  dx = []
  dy = []
  for j in 0...96
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
    fp["p#{j}"].ox = fp["p#{j}"].bitmap.width/2
    fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
    fp["p#{j}"].z = @targetSprite.z
    r = 148*factor + rand(32)*factor
    x, y = randCircleCord(r)
    fp["p#{j}"].x = cx
    fp["p#{j}"].y = cy
    fp["p#{j}"].visible = false
    fp["p#{j}"].zoom_x = factor
    fp["p#{j}"].zoom_y = factor
    fp["p#{j}"].color = Color.new(180,53,2,0)
    dx.push(cx - r + x)
    dy.push(cy - r + y)
  end
  k = -4
  for i in 0...72
    k *= - 1 if i%4==0
    fp["bg"].color.alpha -= 32 if fp["bg"].color.alpha > 0
    for j in 0...12
      next if j>(i/4)
      pbSEPlay("Anim/hit",80) if fp["f#{j}"].opacity == 255
      fp["f#{j}"].visible = true
      fp["f#{j}"].zoom_x -= 0.025
      fp["f#{j}"].zoom_y -= 0.025
      fp["f#{j}"].opacity -= 16
      fp["f#{j}"].color.alpha += 32
    end
    for j in 0...96
      next if j>(i*2)
      fp["p#{j}"].visible = true
      fp["p#{j}"].x -= (fp["p#{j}"].x - dx[j])*0.2
      fp["p#{j}"].y -= (fp["p#{j}"].y - dy[j])*0.2
      fp["p#{j}"].opacity -= 32 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 16
      fp["p#{j}"].color.alpha += 16 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 32
      fp["p#{j}"].zoom_x += 0.1
      fp["p#{j}"].zoom_y += 0.1
      fp["p#{j}"].angle = -Math.atan(1.0*(fp["p#{j}"].y-cy)/(fp["p#{j}"].x-cx))*(180.0/Math::PI)
    end
    fp["bg"].update
    @targetSprite.still
    @targetSprite.zoom_x -= factor*0.01*k if i < 56
    @targetSprite.zoom_y += factor*0.02*k if i < 56
    @scene.wait
  end
  @vector.reset if !@multiHit
  16.times do
    fp["bg"].color.alpha += 16
    fp["bg"].opacity -= 16
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:QUANTUMCRUSH) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  @vector.set(vector)
  @scene.wait(16,true)
  fp = {}
  for j in 0...16
    fp["i#{j}"] = Sprite.new(@viewport)
    fp["i#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb250")
    fp["i#{j}"].ox = fp["i#{j}"].bitmap.width/2
    fp["i#{j}"].oy = fp["i#{j}"].bitmap.height/2
    fp["i#{j}"].opacity = 0
    fp["i#{j}"].zoom_x = @targetSprite.zoom_x
    fp["i#{j}"].zoom_y = @targetSprite.zoom_y
    fp["i#{j}"].z = @targetIsPlayer ? 29 : 19
    fp["i#{j}"].x = @targetSprite.x + rand(32)*@targetSprite.zoom_x*(rand(2)==0 ? 1 : -1)
    fp["i#{j}"].y = @targetSprite.y - 8*@targetSprite.zoom_y + rand(16)*@targetSprite.zoom_y
  end
  for j in 0...5
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb504")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height
    fp["s#{j}"].opacity = 0
    fp["s#{j}"].zoom_x = @targetSprite.zoom_x
    fp["s#{j}"].zoom_y = @targetSprite.zoom_y
    fp["s#{j}"].z = @targetIsPlayer ? 29 : 19
    fp["s#{j}"].x = @targetSprite.x - 48*@targetSprite.zoom_x + rand(96)*@targetSprite.zoom_x
    fp["s#{j}"].y = @targetSprite.y - 192*@targetSprite.zoom_y
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263_3")
    fp["p#{j}"].ox = fp["p#{j}"].bitmap.width/2
    fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
    fp["p#{j}"].visible = false
    fp["p#{j}"].zoom_x = 2
    fp["p#{j}"].zoom_y = 2
    fp["p#{j}"].z = @targetIsPlayer ? 29 : 19
    fp["p#{j}"].x = fp["s#{j}"].x
    fp["p#{j}"].y = fp["s#{j}"].y + 192*@targetSprite.zoom_y
  end
  k = -2
  for i in 0...64
    k *= -1 if i%4==0 && i >= 8
    pbSEPlay("EBDX/Anim/rock1",70) if i%8==0 && i >0 && i < 48
    for j in 0...5
      next if j>(i/6)
      fp["s#{j}"].opacity += 64
      fp["s#{j}"].y += 24*@targetSprite.zoom_y if fp["s#{j}"].y < @targetSprite.y
      fp["s#{j}"].zoom_y -= 0.2*@targetSprite.zoom_y if fp["s#{j}"].y >= @targetSprite.y
      fp["s#{j}"].visible = false if fp["s#{j}"].zoom_y <= 0.4*@targetSprite.zoom_y
    end
    for j in 0...5
      next if i < 8
      next if j>(i-8)/8
      fp["p#{j}"].visible = true
      fp["p#{j}"].opacity -= 32
      fp["p#{j}"].zoom_x += 0.02
      fp["p#{j}"].zoom_y += 0.02
      fp["p#{j}"].angle += 8
    end
    for j in 0...16
      next if i < 8
      next if j>(i-8)/2
      fp["i#{j}"].opacity += 32*(fp["i#{j}"].zoom_x <= 0.5*@targetSprite.zoom_x ? -1 : 1)
      fp["i#{j}"].zoom_x -= 0.02*@targetSprite.zoom_x
      fp["i#{j}"].zoom_y -= 0.02*@targetSprite.zoom_y
      fp["i#{j}"].x += 2*@targetSprite.zoom_x*(fp["i#{j}"].x >= @targetSprite.x ? 1 : -1)
      fp["i#{j}"].angle += 4*(fp["i#{j}"].x >= @targetSprite.x ? 1 : -1)
    end
    @scene.moveEntireScene(0, k, true, true) if i >= 8 && i < 48
    @scene.wait
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:QUANTUMWAVE) do
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
  fp["bg"].opacity = 0
  fp["wave"] = AnimatedPlane.new(@viewport)
  fp["wave"].bitmap = Bitmap.new(1026,@viewport.height)
  fp["wave"].bitmap.stretch_blt(Rect.new(0,0,fp["wave"].bitmap.width,fp["wave"].bitmap.height),pbBitmap("Graphics/EBDX/Animations/Moves/eb027_bg"),Rect.new(0,0,1026,212))
  fp["wave"].opacity = 0
  fp["wave"].z = 50
  @vector.set(EliteBattle.get_vector(:DUAL))
  @vector.inc = 0.1
  pulse = 10
  shake = [4,4,4,4]
  # start animation
  for j in 0...64
    pbSEPlay("Anim/Wind8") if j == 24
    fp["wave"].ox += 48
    fp["wave"].opacity += pulse
    pulse = -5 if fp["wave"].opacity > 160
    pulse = +5 if fp["wave"].opacity < 100
    fp["bg"].opacity += 1 if fp["bg"].opacity < 255*0.35
    for i in 0...4
      next if !(@targetIsPlayer ? [0,2] : [1,3]).include?(i)
      next if !(@sprites["pokemon_#{i}"] && @sprites["pokemon_#{i}"].visible) || @sprites["pokemon_#{i}"].disposed?
      @sprites["pokemon_#{i}"].tone.all += 3 if j.between?(16,48)
      if j >= 32
        @sprites["pokemon_#{i}"].ox += shake[i]
        shake[i] = -4 if @sprites["pokemon_#{i}"].ox > @sprites["pokemon_#{i}"].bitmap.width/2 + 2
        shake[i] = 4 if @sprites["pokemon_#{i}"].ox < @sprites["pokemon_#{i}"].bitmap.width/2 - 2
      end
    end
    @sprites["pokemon_#{@userIndex}"].tone.all += 3 if j < 32
    @sprites["pokemon_#{@userIndex}"].still
    @scene.wait(1,true)
  end
  for i in 0...4
    next if !(@targetIsPlayer ? [0,2] : [1,3]).include?(i)
    next if !(@sprites["pokemon_#{i}"] && @sprites["pokemon_#{i}"].visible) || @sprites["pokemon_#{i}"].disposed?
    @sprites["pokemon_#{i}"].ox = @sprites["pokemon_#{i}"].bitmap.width/2
  end
  for j in 0...64
    fp["wave"].ox += 48
    if j < 32
      fp["wave"].opacity += pulse
      pulse = -5 if fp["wave"].opacity > 160
      pulse = +5 if fp["wave"].opacity < 100
    end
    fp["wave"].opacity -= 4 if j >= 32
    fp["bg"].opacity -= 4 if j >= 32
    for i in 0...4
      next if !(@targetIsPlayer ? [0,2] : [1,3]).include?(i)
      next if !(@sprites["pokemon_#{i}"] && @sprites["pokemon_#{i}"].visible)
      @sprites["pokemon_#{i}"].tone.all -= 3 if j >= 32
    end
    @sprites["pokemon_#{@userIndex}"].tone.all -= 3 if j >= 32
    @sprites["pokemon_#{@userIndex}"].still
    @scene.wait(1,true)
  end
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:SIMPLERAY) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}; rndx = []; rndy = []; dx = []; dy = []
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263_4")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...72
    fp["#{i}2"] = Sprite.new(@viewport)
    fp["#{i}2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263_3")
    fp["#{i}2"].ox = fp["#{i}2"].bitmap.width/2
    fp["#{i}2"].oy = fp["#{i}2"].bitmap.height/2
    fp["#{i}2"].opacity = 0
    fp["#{i}2"].z = 19
  end
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = 50
  fp["cir"].zoom_x = @targetIsPlayer ? 0.5 : 1
  fp["cir"].zoom_y = @targetIsPlayer ? 0.5 : 1
  fp["cir"].opacity = 0
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263_2")
    fp["#{i}s"].ox = -32 - rand(64)
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height/2
    fp["#{i}s"].angle = rand(270)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector2)
  for i in 0...20
    pbSEPlay("Anim/Harden") if i == 4
    @scene.wait(1,true)
  end
  @scene.wait(4,true)
  pbSEPlay("Anim/Psych Up")
  for i in 0...96
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...72
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
      next if j>(i)
      x0 = dx[j]
      y0 = dy[j]
      x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].opacity += 51
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].z = @targetSprite.z - 1 if nextx > cx && nexty < cy
      else
        fp["#{j}"].z = @targetSprite.z + 1 if nextx < cx && nexty > cy
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    pbSEPlay("Anim/Comet Punch") if i == 64
    fp["cir"].x, fp["cir"].y = ax, ay
    fp["cir"].angle += 32
    fp["cir"].opacity += (i>72) ? -51 : 255
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].zoom_x += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].zoom_y += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = ax, ay
    end
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  fp["cir"].opacity = 0
  for i in 0...20
    @targetSprite.still
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:MINERALCANNON) do
  # inital configuration
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}; dx = []; dy = []
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb504")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = @userSprite.z + 1
  fp["cir"].mirror = @userIsPlayer
  fp["cir"].zoom_x = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].zoom_y = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].opacity = 0
  shake = 4; k = 0
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...40
    if i < 8
    else
      fp["cir"].x, fp["cir"].y = @userSprite.getCenter
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity += 24
    end
    if i == 8
      @vector.set(vector2)
      pbSEPlay("EBDX/Anim/rock2",80)
    end
    @scene.wait(1,true)
  end
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb504")
    fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
    fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
    fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
    r = 128*@userSprite.zoom_x
    z = [0.5,0.25,1,0.75][rand(4)]
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{i}s"].x = cx
    fp["#{i}s"].y = cy
    fp["#{i}s"].zoom_x = z*@userSprite.zoom_x
    fp["#{i}s"].zoom_y = z*@userSprite.zoom_x
    fp["#{i}s"].visible = false
    fp["#{i}s"].z = @userSprite.z + 1
    dx.push(x); dy.push(y)
  end
  fp["shot"] = Sprite.new(@viewport)
  fp["shot"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb504")
  fp["shot"].ox = fp["shot"].bitmap.width/2
  fp["shot"].oy = fp["shot"].bitmap.height/2
  fp["shot"].z = @userSprite.z + 1
  fp["shot"].zoom_x = @userSprite.zoom_x
  fp["shot"].zoom_y = @userSprite.zoom_x
  fp["shot"].opacity = 0
  x = defaultvector[0]; y = defaultvector[1]
  x2, y2 = @vector.spoof(defaultvector)
  fp["shot"].x = cx
  fp["shot"].y = cy
  pbSEPlay("EBDX/Anim/rock1",80)
  k = -1
  for i in 0...20
    cx, cy = @userSprite.getCenter
    @vector.reset if i == 0
    if i > 0
      fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
      fp["shot"].opacity += 32
      fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
      fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
      for j in 0...8
        fp["#{j}s"].visible = true
        fp["#{j}s"].opacity -= 32
        fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
        fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
      end
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity -= 16
      fp["cir"].x = cx
      fp["cir"].y = cy
    end
    factor = @targetSprite.zoom_x if i == 12
    if i >= 12
      k *= -1 if i%4==0
      @targetSprite.zoom_x -= factor*0.01*k
      @targetSprite.zoom_y += factor*0.04*k
      @targetSprite.still
    end
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,i < 12)
  end
  shake = 2
  16.times do
    fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
    fp["shot"].opacity += 32
    fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
    fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
    fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
    fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 4
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 4
    @targetSprite.still
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:DEATHTOLL) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb427_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb460")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb427_2")
    fp["#{i}s"].ox = fp["#{i}s"].bitmap.width/2
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height + 8*factor
    fp["#{i}s"].angle = rand(360)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  k = 0
  # start animation
  @vector.set(vector2)
  @sprites["battlebg"].defocus
  for i in 0...30
    if i < 10
      fp["bg"].opacity += 25.5
    elsif i < 20
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("EBDX/Anim/poison1") if i == 20
    fp["bg"].update
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/wind1",90)
  for i in 0...96
    pbSEPlay("EBDX/Anim/poison1",60) if i%3==0 && i < 64
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].oy +=6*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = @userSprite.getCenter
    end
    #pbSEPlay("Anim/Comet Punch") if i == 64
    fp["bg"].update
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  for i in 0...20
    @targetSprite.still
    if i < 10
      fp["bg"].color.alpha += 25.5
    else
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:WICKEDWIND) do
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
  fp["bg"].opacity = 0
  fp["wave"] = AnimatedPlane.new(@viewport)
  fp["wave"].bitmap = Bitmap.new(1026,@viewport.height)
  fp["wave"].bitmap.stretch_blt(Rect.new(0,0,fp["wave"].bitmap.width,fp["wave"].bitmap.height),pbBitmap("Graphics/EBDX/Animations/Moves/wicked_wind"),Rect.new(0,0,1026,212))
  fp["wave"].opacity = 0
  fp["wave"].z = 50
  @vector.set(EliteBattle.get_vector(:DUAL))
  @vector.inc = 0.1
  pulse = 10
  shake = [4,4,4,4]
  # start animation
  for j in 0...64
    pbSEPlay("Anim/Wind8") if j == 24
    fp["wave"].ox += 48
    fp["wave"].opacity += pulse
    pulse = -5 if fp["wave"].opacity > 160
    pulse = +5 if fp["wave"].opacity < 100
    fp["bg"].opacity += 1 if fp["bg"].opacity < 255*0.35
    for i in 0...4
      next if !(@targetIsPlayer ? [0,2] : [1,3]).include?(i)
      next if !(@sprites["pokemon_#{i}"] && @sprites["pokemon_#{i}"].visible) || @sprites["pokemon_#{i}"].disposed?
      @sprites["pokemon_#{i}"].tone.all += 3 if j.between?(16,48)
      if j >= 32
        @sprites["pokemon_#{i}"].ox += shake[i]
        shake[i] = -4 if @sprites["pokemon_#{i}"].ox > @sprites["pokemon_#{i}"].bitmap.width/2 + 2
        shake[i] = 4 if @sprites["pokemon_#{i}"].ox < @sprites["pokemon_#{i}"].bitmap.width/2 - 2
      end
    end
    @sprites["pokemon_#{@userIndex}"].tone.all += 3 if j < 32
    @sprites["pokemon_#{@userIndex}"].still
    @scene.wait(1,true)
  end
  for i in 0...4
    next if !(@targetIsPlayer ? [0,2] : [1,3]).include?(i)
    next if !(@sprites["pokemon_#{i}"] && @sprites["pokemon_#{i}"].visible) || @sprites["pokemon_#{i}"].disposed?
    @sprites["pokemon_#{i}"].ox = @sprites["pokemon_#{i}"].bitmap.width/2
  end
  for j in 0...64
    fp["wave"].ox += 48
    if j < 32
      fp["wave"].opacity += pulse
      pulse = -5 if fp["wave"].opacity > 160
      pulse = +5 if fp["wave"].opacity < 100
    end
    fp["wave"].opacity -= 4 if j >= 32
    fp["bg"].opacity -= 4 if j >= 32
    for i in 0...4
      next if !(@targetIsPlayer ? [0,2] : [1,3]).include?(i)
      next if !(@sprites["pokemon_#{i}"] && @sprites["pokemon_#{i}"].visible)
      @sprites["pokemon_#{i}"].tone.all -= 3 if j >= 32
    end
    @sprites["pokemon_#{@userIndex}"].tone.all -= 3 if j >= 32
    @sprites["pokemon_#{@userIndex}"].still
    @scene.wait(1,true)
  end
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:SPECTRALSHRIEK) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}
  rndx = []; prndx = []
  rndy = []; prndy = []
  rangl = []
  dx = []
  dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/spectral_shriek_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...128
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/spectral_shriek")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].visible = false
    fp["#{i}"].z = 50
    rndx.push(rand(256)); prndx.push(rand(72))
    rndy.push(rand(256)); prndy.push(rand(72))
    rangl.push(rand(9))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb427_2")
    fp["#{i}s"].ox = fp["#{i}s"].bitmap.width/2
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height + 8*factor
    fp["#{i}s"].angle = rand(360)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.5 : 1)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  k = 0
  # start animation
  @vector.set(vector2)
  @sprites["battlebg"].defocus
  for i in 0...30
    if i < 10
      fp["bg"].opacity += 25.5
    elsif i < 20
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("EBDX/Anim/ghost1") if i == 20
    fp["bg"].update
    @scene.wait(1,true)
  end
  pbSEPlay("EBDX/Anim/wind1",90)
  for i in 0...96
    pbSEPlay("EBDX/Anim/ghost2",60) if i%3==0 && i < 64
    ax, ay = @userSprite.getCenter
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...128
      next if j>(i*2)
      if !fp["#{j}"].visible
        dx[j] = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
        fp["#{j}"].visible = true
      end
      x0 = ax - 46*@userSprite.zoom_x*0.5 + prndx[j]*@userSprite.zoom_x*0.5
      y0 = ay - 46*@userSprite.zoom_y*0.5 + prndy[j]*@userSprite.zoom_y*0.5
      x2 = cx - 128*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 128*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].angle += rangl[j]*2
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].opacity -= 51 if nextx > cx && nexty < cy
      else
        fp["#{j}"].opacity -= 51 if nextx < cx && nexty > cy
      end
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].oy +=6*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = @userSprite.getCenter
    end
    #pbSEPlay("Anim/Comet Punch") if i == 64
    fp["bg"].update
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  for i in 0...20
    @targetSprite.still
    if i < 10
      fp["bg"].color.alpha += 25.5
    else
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:STARSAP) do
  # inital configuration
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}; dx = []; dy = []
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = @userSprite.z + 1
  fp["cir"].mirror = @userIsPlayer
  fp["cir"].zoom_x = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].zoom_y = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].opacity = 0
  shake = 4; k = 0
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...40
    if i < 8
    else
      fp["cir"].x, fp["cir"].y = @userSprite.getCenter
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity += 24
    end
    if i == 8
      @vector.set(vector2)
      pbSEPlay("EBDX/Anim/shine1",80)
    end
    @scene.wait(1,true)
  end
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
    fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
    fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
    r = 128*@userSprite.zoom_x
    z = [0.5,0.25,1,0.75][rand(4)]
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{i}s"].x = cx
    fp["#{i}s"].y = cy
    fp["#{i}s"].zoom_x = z*@userSprite.zoom_x
    fp["#{i}s"].zoom_y = z*@userSprite.zoom_x
    fp["#{i}s"].visible = false
    fp["#{i}s"].z = @userSprite.z + 1
    dx.push(x); dy.push(y)
  end
  fp["shot"] = Sprite.new(@viewport)
  fp["shot"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
  fp["shot"].ox = fp["shot"].bitmap.width/2
  fp["shot"].oy = fp["shot"].bitmap.height/2
  fp["shot"].z = @userSprite.z + 1
  fp["shot"].zoom_x = @userSprite.zoom_x
  fp["shot"].zoom_y = @userSprite.zoom_x
  fp["shot"].opacity = 0
  x = defaultvector[0]; y = defaultvector[1]
  x2, y2 = @vector.spoof(defaultvector)
  fp["shot"].x = cx
  fp["shot"].y = cy
  pbSEPlay("EBDX/Anim/shine1",80)
  k = -1
  for i in 0...20
    cx, cy = @userSprite.getCenter
    @vector.reset if i == 0
    if i > 0
      fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
      fp["shot"].opacity += 32
      fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
      fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
      for j in 0...8
        fp["#{j}s"].visible = true
        fp["#{j}s"].opacity -= 32
        fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
        fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
      end
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity -= 16
      fp["cir"].x = cx
      fp["cir"].y = cy
    end
    factor = @targetSprite.zoom_x if i == 12
    if i >= 12
      k *= -1 if i%4==0
      @targetSprite.zoom_x -= factor*0.01*k
      @targetSprite.zoom_y += factor*0.04*k
      @targetSprite.still
    end
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,i < 12)
  end
  shake = 2
  16.times do
    fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
    fp["shot"].opacity += 32
    fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
    fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
    fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
    fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 4
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 4
    @targetSprite.still
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
  EliteBattle.playMoveAnimation(:ABSORB, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
EliteBattle.defineMoveAnimation(:SPIKECANNON) do
  # inital configuration
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}; dx = []; dy = []
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb093")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = @userSprite.z + 1
  fp["cir"].mirror = @userIsPlayer
  fp["cir"].zoom_x = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].zoom_y = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].opacity = 0
  shake = 4; k = 0
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...40
    if i < 8
    else
      fp["cir"].x, fp["cir"].y = @userSprite.getCenter
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity += 24
    end
    if i == 8
      @vector.set(vector2)
      pbSEPlay("EBDX/Anim/ebrock2",80)
    end
    @scene.wait(1,true)
  end
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb093_2")
    fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
    fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
    fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
    r = 128*@userSprite.zoom_x
    z = [0.5,0.25,1,0.75][rand(4)]
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{i}s"].x = cx
    fp["#{i}s"].y = cy
    fp["#{i}s"].zoom_x = z*@userSprite.zoom_x
    fp["#{i}s"].zoom_y = z*@userSprite.zoom_x
    fp["#{i}s"].visible = false
    fp["#{i}s"].z = @userSprite.z + 1
    dx.push(x); dy.push(y)
  end
  fp["shot"] = Sprite.new(@viewport)
  fp["shot"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb243")
  fp["shot"].ox = fp["shot"].bitmap.width/2
  fp["shot"].oy = fp["shot"].bitmap.height/2
  fp["shot"].z = @userSprite.z + 1
  fp["shot"].zoom_x = @userSprite.zoom_x
  fp["shot"].zoom_y = @userSprite.zoom_x
  fp["shot"].opacity = 0
  x = defaultvector[0]; y = defaultvector[1]
  x2, y2 = @vector.spoof(defaultvector)
  fp["shot"].x = cx
  fp["shot"].y = cy
  pbSEPlay("EBDX/Anim/iron5",80)
  k = -1
  for i in 0...20
    cx, cy = @userSprite.getCenter
    @vector.reset if i == 0
    if i > 0
      fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
      fp["shot"].opacity += 32
      fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
      fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
      for j in 0...8
        fp["#{j}s"].visible = true
        fp["#{j}s"].opacity -= 32
        fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
        fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
      end
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity -= 16
      fp["cir"].x = cx
      fp["cir"].y = cy
    end
    factor = @targetSprite.zoom_x if i == 12
    if i >= 12
      k *= -1 if i%4==0
      @targetSprite.zoom_x -= factor*0.01*k
      @targetSprite.zoom_y += factor*0.04*k
      @targetSprite.still
    end
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,i < 12)
  end
  shake = 2
  16.times do
    fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
    fp["shot"].opacity += 32
    fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
    fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
    fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
    fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 4
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 4
    @targetSprite.still
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:TEMPESTRAGE) do
  EliteBattle.playMoveAnimation(:SOLARBEAM_CHARGE, @scene, @userIndex, @targetIndex)
  EliteBattle.playMoveAnimation(:SIMPLERAY, @scene, @userIndex, @targetIndex)
end
EliteBattle.defineMoveAnimation(:BAROMETERBOMB) do
  EliteBattle.playMoveAnimation(:SOLARBEAM_CHARGE, @scene, @userIndex, @targetIndex)
  EliteBattle.playMoveAnimation(:HYPERBEAM, @scene, @userIndex, @targetIndex)
end
EliteBattle.defineMoveAnimation(:WEATHERBALL) do
  EliteBattle.playMoveAnimation(:SOLARBEAM_CHARGE, @scene, @userIndex, @targetIndex)
  # inital configuration
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}; dx = []; dy = []
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb093")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = @userSprite.z + 1
  fp["cir"].mirror = @userIsPlayer
  fp["cir"].zoom_x = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].zoom_y = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].opacity = 0
  shake = 4; k = 0
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...40
    if i < 8
    else
      fp["cir"].x, fp["cir"].y = @userSprite.getCenter
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity += 24
    end
    if i == 8
      @vector.set(vector2)
      pbSEPlay("EBDX/Anim/grass2",80)
    end
    @scene.wait(1,true)
  end
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb093_2")
    fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
    fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
    fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
    r = 128*@userSprite.zoom_x
    z = [0.5,0.25,1,0.75][rand(4)]
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{i}s"].x = cx
    fp["#{i}s"].y = cy
    fp["#{i}s"].zoom_x = z*@userSprite.zoom_x
    fp["#{i}s"].zoom_y = z*@userSprite.zoom_x
    fp["#{i}s"].visible = false
    fp["#{i}s"].z = @userSprite.z + 1
    dx.push(x); dy.push(y)
  end
  fp["shot"] = Sprite.new(@viewport)
  fp["shot"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb093_3")
  fp["shot"].ox = fp["shot"].bitmap.width/2
  fp["shot"].oy = fp["shot"].bitmap.height/2
  fp["shot"].z = @userSprite.z + 1
  fp["shot"].zoom_x = @userSprite.zoom_x
  fp["shot"].zoom_y = @userSprite.zoom_x
  fp["shot"].opacity = 0
  x = defaultvector[0]; y = defaultvector[1]
  x2, y2 = @vector.spoof(defaultvector)
  fp["shot"].x = cx
  fp["shot"].y = cy
  pbSEPlay("EBDX/Anim/normal5",80)
  k = -1
  for i in 0...20
    cx, cy = @userSprite.getCenter
    @vector.reset if i == 0
    if i > 0
      fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
      fp["shot"].opacity += 32
      fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
      fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
      for j in 0...8
        fp["#{j}s"].visible = true
        fp["#{j}s"].opacity -= 32
        fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
        fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
      end
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity -= 16
      fp["cir"].x = cx
      fp["cir"].y = cy
    end
    factor = @targetSprite.zoom_x if i == 12
    if i >= 12
      k *= -1 if i%4==0
      @targetSprite.zoom_x -= factor*0.01*k
      @targetSprite.zoom_y += factor*0.04*k
      @targetSprite.still
    end
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,i < 12)
  end
  shake = 2
  16.times do
    fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
    fp["shot"].opacity += 32
    fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
    fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
    fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
    fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 4
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 4
    @targetSprite.still
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:PLASMAFISTS) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  fp = {}
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb093_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  # animation start
  @sprites["battlebg"].defocus
  @vector.set(vector)
  for i in 0...16
    fp["bg"].opacity += 32 if i >= 8
    @scene.wait(1,true)
  end
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  for j in 0...12
    fp["f#{j}"] = Sprite.new(@viewport)
    fp["f#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb086")
    fp["f#{j}"].ox = fp["f#{j}"].bitmap.width/2
    fp["f#{j}"].oy = fp["f#{j}"].bitmap.height/2
    fp["f#{j}"].z = @targetSprite.z + 1
    r = 32*factor
    fp["f#{j}"].x = cx - r + rand(r*2)
    fp["f#{j}"].y = cy - r + rand(r*2)
    fp["f#{j}"].visible = false
    fp["f#{j}"].zoom_x = factor
    fp["f#{j}"].zoom_y = factor
    fp["f#{j}"].color = Color.new(180,53,2,0)
  end
  dx = []
  dy = []
  for j in 0...96
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb064_3")
    fp["p#{j}"].ox = fp["p#{j}"].bitmap.width/2
    fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
    fp["p#{j}"].z = @targetSprite.z
    r = 148*factor + rand(32)*factor
    x, y = randCircleCord(r)
    fp["p#{j}"].x = cx
    fp["p#{j}"].y = cy
    fp["p#{j}"].visible = false
    fp["p#{j}"].zoom_x = factor
    fp["p#{j}"].zoom_y = factor
    fp["p#{j}"].color = Color.new(180,53,2,0)
    dx.push(cx - r + x)
    dy.push(cy - r + y)
  end
  k = -4
  for i in 0...72
    k *= - 1 if i%4==0
    fp["bg"].color.alpha -= 32 if fp["bg"].color.alpha > 0
    for j in 0...12
      next if j>(i/4)
      pbSEPlay("Anim/hit",80) if fp["f#{j}"].opacity == 255
      fp["f#{j}"].visible = true
      fp["f#{j}"].zoom_x -= 0.025
      fp["f#{j}"].zoom_y -= 0.025
      fp["f#{j}"].opacity -= 16
      fp["f#{j}"].color.alpha += 32
    end
    for j in 0...96
      next if j>(i*2)
      fp["p#{j}"].visible = true
      fp["p#{j}"].x -= (fp["p#{j}"].x - dx[j])*0.2
      fp["p#{j}"].y -= (fp["p#{j}"].y - dy[j])*0.2
      fp["p#{j}"].opacity -= 32 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 16
      fp["p#{j}"].color.alpha += 16 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 32
      fp["p#{j}"].zoom_x += 0.1
      fp["p#{j}"].zoom_y += 0.1
      fp["p#{j}"].angle = -Math.atan(1.0*(fp["p#{j}"].y-cy)/(fp["p#{j}"].x-cx))*(180.0/Math::PI)
    end
    fp["bg"].update
    @targetSprite.still
    @targetSprite.zoom_x -= factor*0.01*k if i < 56
    @targetSprite.zoom_y += factor*0.02*k if i < 56
    @scene.wait
  end
  @vector.reset if !@multiHit
  16.times do
    fp["bg"].color.alpha += 16
    fp["bg"].opacity -= 16
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:COSMICFURY) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  fp = {}
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/spectral_shriek_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  # animation start
  @sprites["battlebg"].defocus
  @vector.set(vector)
  for i in 0...16
    fp["bg"].opacity += 32 if i >= 8
    @scene.wait(1,true)
  end
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  for j in 0...12
    fp["f#{j}"] = Sprite.new(@viewport)
    fp["f#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb108")
    fp["f#{j}"].ox = fp["f#{j}"].bitmap.width/2
    fp["f#{j}"].oy = fp["f#{j}"].bitmap.height/2
    fp["f#{j}"].z = @targetSprite.z + 1
    r = 32*factor
    fp["f#{j}"].x = cx - r + rand(r*2)
    fp["f#{j}"].y = cy - r + rand(r*2)
    fp["f#{j}"].visible = false
    fp["f#{j}"].zoom_x = factor
    fp["f#{j}"].zoom_y = factor
    fp["f#{j}"].color = Color.new(180,53,2,0)
  end
  dx = []
  dy = []
  for j in 0...96
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
    fp["p#{j}"].ox = fp["p#{j}"].bitmap.width/2
    fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
    fp["p#{j}"].z = @targetSprite.z
    r = 148*factor + rand(32)*factor
    x, y = randCircleCord(r)
    fp["p#{j}"].x = cx
    fp["p#{j}"].y = cy
    fp["p#{j}"].visible = false
    fp["p#{j}"].zoom_x = factor
    fp["p#{j}"].zoom_y = factor
    fp["p#{j}"].color = Color.new(180,53,2,0)
    dx.push(cx - r + x)
    dy.push(cy - r + y)
  end
  k = -4
  for i in 0...72
    k *= - 1 if i%4==0
    fp["bg"].color.alpha -= 32 if fp["bg"].color.alpha > 0
    for j in 0...12
      next if j>(i/4)
      pbSEPlay("Anim/hit",80) if fp["f#{j}"].opacity == 255
      fp["f#{j}"].visible = true
      fp["f#{j}"].zoom_x -= 0.025
      fp["f#{j}"].zoom_y -= 0.025
      fp["f#{j}"].opacity -= 16
      fp["f#{j}"].color.alpha += 32
    end
    for j in 0...96
      next if j>(i*2)
      fp["p#{j}"].visible = true
      fp["p#{j}"].x -= (fp["p#{j}"].x - dx[j])*0.2
      fp["p#{j}"].y -= (fp["p#{j}"].y - dy[j])*0.2
      fp["p#{j}"].opacity -= 32 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 16
      fp["p#{j}"].color.alpha += 16 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 32
      fp["p#{j}"].zoom_x += 0.1
      fp["p#{j}"].zoom_y += 0.1
      fp["p#{j}"].angle = -Math.atan(1.0*(fp["p#{j}"].y-cy)/(fp["p#{j}"].x-cx))*(180.0/Math::PI)
    end
    fp["bg"].update
    @targetSprite.still
    @targetSprite.zoom_x -= factor*0.01*k if i < 56
    @targetSprite.zoom_y += factor*0.02*k if i < 56
    @scene.wait
  end
  @vector.reset if !@multiHit
  16.times do
    fp["bg"].color.alpha += 16
    fp["bg"].opacity -= 16
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:CHILLINGCRY) do
  indexes = []
  max = @battle.pbSideSize(@targetIsPlayer ? 0 : 1)
  for i in 0...max
    i = (@targetIsPlayer ? i*2 : (i*2 + 1))
    indexes.push(i) if @sprites["pokemon_#{i}"] && @sprites["pokemon_#{i}"].actualBitmap
  end
  # set up animation
  fp = {}
  rndx = [[],[]]; rndy = [[],[]]
  irndx = [[],[]]; irndy = [[],[]]
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(100,128,142))
  fp["bg"].opacity = 0
  for m in 0...indexes.length
    @targetSprite = @sprites["pokemon_#{indexes[m]}"]
    for i in 0...16
      fp["#{m}#{i}"] = Sprite.new(@viewport)
      fp["#{m}#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536_2")
      fp["#{m}#{i}"].ox = fp["#{m}#{i}"].bitmap.width/2
      fp["#{m}#{i}"].oy = fp["#{m}#{i}"].bitmap.width/2
      fp["#{m}#{i}"].opacity = 0
      fp["#{m}#{i}"].z = (@targetIsPlayer ? 29 : 19)
      rndx[m].push(rand(64))
      rndy[m].push(rand(64))
    end
  end
  for m in 0...indexes.length
    @targetSprite = @sprites["pokemon_#{indexes[m]}"]
    next if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
    for i in 0...8
      fp["i#{m}#{i}"] = Sprite.new(@viewport)
      fp["i#{m}#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb248")
      fp["i#{m}#{i}"].src_rect.set(0,0,26,42)
      fp["i#{m}#{i}"].ox = 13
      fp["i#{m}#{i}"].oy = 21
      fp["i#{m}#{i}"].opacity = 0
      fp["i#{m}#{i}"].z = (@targetIsPlayer ? 29 : 19)
      fp["i#{m}#{i}"].zoom_x = (@targetSprite.zoom_x)/2
      fp["i#{m}#{i}"].zoom_y = (@targetSprite.zoom_y)/2
      irndx[m].push(rand(128))
      irndy[m].push(rand(128))
    end
  end
  shake = [2,2]
  @sprites["battlebg"].defocus
  # start animation
  for i in 0...152
    for m in 0...indexes.length
      @targetSprite = @sprites["pokemon_#{indexes[m]}"]
      next if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
      for j in 0...16
        if fp["#{m}#{j}"].opacity == 0 && fp["#{m}#{j}"].tone.gray == 0
          fp["#{m}#{j}"].zoom_x = @userSprite.zoom_x
          fp["#{m}#{j}"].zoom_y = @userSprite.zoom_y
          cx, cy = @userSprite.getAnchor
          fp["#{m}#{j}"].x = cx
          fp["#{m}#{j}"].y = cy
        end
        cx, cy = @targetSprite.getCenter(true)
        next if j>(i/4)
        x2 = cx - 32*@targetSprite.zoom_x + rndx[m][j]*@targetSprite.zoom_x
        y2 = cy - 32*@targetSprite.zoom_y + rndy[m][j]*@targetSprite.zoom_y
        x0 = fp["#{m}#{j}"].x
        y0 = fp["#{m}#{j}"].y
        fp["#{m}#{j}"].x += (x2 - x0)*0.1
        fp["#{m}#{j}"].y += (y2 - y0)*0.1
        fp["#{m}#{j}"].zoom_x -= (fp["#{m}#{j}"].zoom_x - @targetSprite.zoom_x)*0.1
        fp["#{m}#{j}"].zoom_y -= (fp["#{m}#{j}"].zoom_y - @targetSprite.zoom_y)*0.1
        fp["#{m}#{j}"].angle += 2
        if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
          fp["#{m}#{j}"].opacity -= 8
          fp["#{m}#{j}"].tone.gray += 8
          fp["#{m}#{j}"].angle += 2
        else
          fp["#{m}#{j}"].opacity += 12
        end
      end
    end
    if i >= 132
      fp["bg"].opacity -= 7
    else
      fp["bg"].opacity += 2 if fp["bg"].opacity < 255*0.5
    end
    pbSEPlay("EBDX/Anim/ghost2", 80) if i == 96
    pbSEPlay("EBDX/Anim/ghost2", 70) if i == 12
    if i >= 96
      for m in 0...indexes.length
        @targetSprite = @sprites["pokemon_#{indexes[m]}"]
        next if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
        cx, cy = @targetSprite.getCenter(true)
        if i >= 132
          @targetSprite.tone.red -= 4.8
          @targetSprite.tone.green -= 4.8
          @targetSprite.tone.blue -= 4.8
        else
          @targetSprite.tone.red += 4.8 if @targetSprite.tone.red < 96
          @targetSprite.tone.green += 4.8 if @targetSprite.tone.green < 96
          @targetSprite.tone.blue += 4.8 if @targetSprite.tone.blue < 96
        end
        @targetSprite.ox += shake[m]
        shake[m] = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
        shake[m] = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
        @targetSprite.still
        for k in 0...8
          if fp["i#{m}#{k}"].opacity == 0 && fp["i#{m}#{k}"].src_rect.x == 0
            fp["i#{m}#{k}"].x = cx - 64*@targetSprite.zoom_x + irndx[m][k]*@targetSprite.zoom_x
            fp["i#{m}#{k}"].y = cy - 64*@targetSprite.zoom_y + irndy[m][k]*@targetSprite.zoom_y
          end
          fp["i#{m}#{k}"].src_rect.x += 26 if i%4==0 && fp["i#{m}#{k}"].opacity >= 255
          fp["i#{m}#{k}"].src_rect.x = 78 if fp["i#{m}#{k}"].src_rect.x > 78
          if fp["i#{m}#{k}"].src_rect.x==78
            fp["i#{m}#{k}"].opacity -= 24
            fp["i#{m}#{k}"].zoom_x += 0.02
            fp["i#{m}#{k}"].zoom_y += 0.02
          elsif fp["i#{m}#{k}"].opacity >= 255
            fp["i#{m}#{k}"].opacity -= 24
            pbSEPlay("EBDX/Anim/ice1",50)
          else
            fp["i#{m}#{k}"].opacity += 45 if (i-96)/2 > k
          end
        end
      end
    end
    @vector.set(EliteBattle.get_vector(:DUAL)) if i == 24
    @vector.inc = 0.1 if i == 24
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  for m in 0...indexes.length
    @targetSprite = @sprites["pokemon_#{indexes[m]}"]
    next if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
    @targetSprite.ox = @targetSprite.bitmap.width/2
    @targetSprite.tone = Tone.new(0,0,0,0)
  end
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:POLLENPUFF) do
  # configure animation
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  @scene.wait(16,true)
  factor = @userSprite.zoom_x
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  fp = {}
  for j in 0...24
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb207")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    r = 64*factor
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{j}"].x = cx
    fp["#{j}"].y = cx
    fp["#{j}"].z = @userSprite.z
    fp["#{j}"].visible = false
    fp["#{j}"].angle = rand(360)
    z = [0.5,1,0.75][rand(3)]
    fp["#{j}"].zoom_x = z
    fp["#{j}"].zoom_y = z
    dx.push(x)
    dy.push(y)
  end
  # start animation
  pbSEPlay("EBDX/Anim/ground1",80)
  for i in 0...48
    for j in 0...24
      next if j>(i*2)
      fp["#{j}"].visible = true
      if ((fp["#{j}"].x - dx[j])*0.1).abs < 1
        fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].x -= (fp["#{j}"].x - dx[j])*0.1
        fp["#{j}"].y -= (fp["#{j}"].y - dy[j])*0.1
      end
    end
    @scene.wait
  end
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  for j in 0...12
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebHealing")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
    r = 32*factor
    fp["s#{j}"].x = cx - r + rand(r*2)
    fp["s#{j}"].y = cy - r + rand(r*2)
    fp["s#{j}"].z = @targetSprite.z + 1
    fp["s#{j}"].visible = false
    fp["s#{j}"].tone = Tone.new(255,255,255)
    fp["s#{j}"].angle = rand(360)
  end
  # anim2
  for i in 0...32
    for j in 0...12
      next if j>(i*2)
      fp["s#{j}"].visible = true
      fp["s#{j}"].opacity -= 32
      fp["s#{j}"].zoom_x += 0.02
      fp["s#{j}"].zoom_y += 0.02
      fp["s#{j}"].angle += 8
      fp["s#{j}"].tone.red -= 32
      fp["s#{j}"].tone.green -= 32
      fp["s#{j}"].tone.blue -= 32
    end
    @targetSprite.still
    pbSEPlay("EBDX/Anim/normal2",80) if i%4==0 && i < 16
    @scene.wait
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:DARKPULSE) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}; rndx = []; rndy = []; dx = []; dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/spectral_shriek_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb175_3")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...72
    fp["#{i}2"] = Sprite.new(@viewport)
    fp["#{i}2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb175")
    fp["#{i}2"].ox = fp["#{i}2"].bitmap.width/2
    fp["#{i}2"].oy = fp["#{i}2"].bitmap.height/2
    fp["#{i}2"].opacity = 0
    fp["#{i}2"].z = 19
  end
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb175_4")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = 50
  fp["cir"].zoom_x = @targetIsPlayer ? 0.5 : 1
  fp["cir"].zoom_y = @targetIsPlayer ? 0.5 : 1
  fp["cir"].opacity = 0
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb175_2")
    fp["#{i}s"].ox = -32 - rand(64)
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height/2
    fp["#{i}s"].angle = rand(270)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector2)
  for i in 0...20
    if i < 10
      fp["bg"].opacity += 25.5
    else
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("EBDX/Anim/ghost1") if i == 4
    fp["bg"].update
    @scene.wait(1,true)
  end
  @scene.wait(4,true)
  pbSEPlay("Anim/Psych Up")
  for i in 0...96
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...72
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
      next if j>(i)
      x0 = dx[j]
      y0 = dy[j]
      x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].opacity += 51
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].z = @targetSprite.z - 1 if nextx > cx && nexty < cy
      else
        fp["#{j}"].z = @targetSprite.z + 1 if nextx < cx && nexty > cy
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    pbSEPlay("EBDX/Anim/ghost2") if i == 64
    fp["cir"].x, fp["cir"].y = ax, ay
    fp["cir"].angle += 32
    fp["cir"].opacity += (i>72) ? -51 : 255
    fp["bg"].update
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].zoom_x += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].zoom_y += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = ax, ay
    end
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  fp["cir"].opacity = 0
  for i in 0...20
    @targetSprite.still
    if i < 10
      fp["bg"].color.alpha += 25.5
    else
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:BASSDROP) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}; rndx = []; rndy = []; dx = []; dy = []
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound1")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...72
    fp["#{i}2"] = Sprite.new(@viewport)
    fp["#{i}2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound1")
    fp["#{i}2"].ox = fp["#{i}2"].bitmap.width/2
    fp["#{i}2"].oy = fp["#{i}2"].bitmap.height/2
    fp["#{i}2"].opacity = 0
    fp["#{i}2"].z = 19
  end
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = 50
  fp["cir"].zoom_x = @targetIsPlayer ? 0.5 : 1
  fp["cir"].zoom_y = @targetIsPlayer ? 0.5 : 1
  fp["cir"].opacity = 0
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
    fp["#{i}s"].ox = -32 - rand(64)
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height/2
    fp["#{i}s"].angle = rand(270)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector2)
  for i in 0...20
    pbSEPlay("Anim/Harden") if i == 4
    @scene.wait(1,true)
  end
  @scene.wait(4,true)
  pbSEPlay("Anim/Psych Up")
  for i in 0...96
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...72
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
      next if j>(i)
      x0 = dx[j]
      y0 = dy[j]
      x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].opacity += 51
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].z = @targetSprite.z - 1 if nextx > cx && nexty < cy
      else
        fp["#{j}"].z = @targetSprite.z + 1 if nextx < cx && nexty > cy
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    pbSEPlay("Anim/Comet Punch") if i == 64
    fp["cir"].x, fp["cir"].y = ax, ay
    fp["cir"].angle += 32
    fp["cir"].opacity += (i>72) ? -51 : 255
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].zoom_x += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].zoom_y += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = ax, ay
    end
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  fp["cir"].opacity = 0
  for i in 0...20
    @targetSprite.still
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:DRAINPUNCH) do | args |
  kick = args[0]; kick = false if kick.nil?
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
  fp["bg"].opacity = 0
  fp["punch"] = Sprite.new(@viewport)
  fp["punch"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb#{kick ? 137 : 108}")
  fp["punch"].ox = fp["punch"].bitmap.width/2
  fp["punch"].oy = fp["punch"].bitmap.height/2
  fp["punch"].opacity = 0
  fp["punch"].z = 40
  fp["punch"].angle = 180
  fp["punch"].zoom_x = @targetIsPlayer ? 6 : 4
  fp["punch"].zoom_y = @targetIsPlayer ? 6 : 4
  fp["punch"].tone = Tone.new(48,16,6)
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  pbSEPlay("Anim/fog2", 75)
  @sprites["battlebg"].defocus
  for i in 0...36
    cx, cy = @targetSprite.getCenter(true)
    fp["punch"].x = cx
    fp["punch"].y = cy
    fp["punch"].angle -= 45 if i < 20
    fp["punch"].zoom_x -= @targetIsPlayer ? 0.2 : 0.15 if i < 20
    fp["punch"].zoom_y -= @targetIsPlayer ? 0.2 : 0.15 if i < 20
    fp["punch"].opacity += 8 if i < 20
    if i >= 20
      fp["punch"].tone = Tone.new(255,255,255) if i == 20
      fp["punch"].tone.all -= 25.5
      fp["punch"].opacity -= 25.5
    end
    pbSEPlay("Anim/Fire3") if i==20
    fp["bg"].opacity += 4 if  i < 20
    if i >= 20
      if i >= 28
        @targetSprite.tone.red -= 3*2
        @targetSprite.tone.green += 1.5*2
        @targetSprite.tone.blue += 3*2
        fp["bg"].opacity -= 10
      else
        @targetSprite.tone.red += 3*2 if @targetSprite.tone.red < 48*2
        @targetSprite.tone.green -= 1.5*2 if @targetSprite.tone.green > -24*2
        @targetSprite.tone.blue -= 3*2 if @targetSprite.tone.blue > -48*2
      end
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
  EliteBattle.playMoveAnimation(:ABSORB, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
EliteBattle.defineMoveAnimation(:SONICSTRIKE) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  speed = []
  for j in 0...32
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].z = @userIsPlayer ? 29 : 19
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound1")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].color = Color.new(255,255,255,255)
    z = [0.5,1.5,1,0.75,1.25][rand(5)]
    fp["#{j}"].zoom_x = z
    fp["#{j}"].zoom_y = z
    fp["#{j}"].opacity = 0
    speed.push((rand(8)+1)*4)
  end
  for j in 0...8
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].z = @userIsPlayer ? 29 : 19
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/sound2")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height
    #z = [0.5,1.5,1,0.75,1.25][rand(5)]
    fp["s#{j}"].color = Color.new(255,255,255,255)
    #fp["s#{j}"].zoom_y = z
    fp["s#{j}"].opacity = 0
  end
  @userSprite.color = Color.new(255,0,0,0)
  # start animation
  @vector.set(vector2)
  @vector.inc = 0.1
  oy = @userSprite.oy
  k = -1
  for i in 0...64
    k *= -1 if i%4==0
    pbSEPlay("EBDX/Anim/dragon2") if i == 12
    cx, cy = @userSprite.getCenter(true)
    for j in 0...32
      next if i < 8
      next if j>(i-8)
      if fp["#{j}"].opacity == 0 && fp["#{j}"].color.alpha == 255
        fp["#{j}"].y = @userSprite.y + 8*@userSprite.zoom_y - rand(24)*@userSprite.zoom_y
        fp["#{j}"].x = cx - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
      end
      if fp["#{j}"].color.alpha <= 96
        fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].opacity += 32
      end
      fp["#{j}"].color.alpha -= 16
      fp["#{j}"].y -= speed[j]
    end
    for j in 0...8
      next if i < 12
      next if j>(i-12)/2
      if fp["s#{j}"].opacity == 0 && fp["s#{j}"].color.alpha == 255
        fp["s#{j}"].y = @userSprite.y + 48*@userSprite.zoom_y - rand(16)*@userSprite.zoom_y
        fp["s#{j}"].x = cx - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
      end
      if fp["s#{j}"].color.alpha <= 96
        fp["s#{j}"].opacity -= 32
      else
        fp["s#{j}"].opacity += 32
      end
      fp["s#{j}"].color.alpha -= 16
      fp["s#{j}"].zoom_y += speed[j]*0.25*0.01
      fp["s#{j}"].y -= speed[j]
    end
    if i < 48
      @userSprite.color.alpha += 4
    else
      @userSprite.color.alpha -= 16
    end
    @userSprite.oy -= 2*k if i%2==0
    @userSprite.still
    @userSprite.anim = true
    @scene.wait(1,true)
  end
  @userSprite.oy = oy
  @vector.set(vector)
  @vector.inc = 0.2
  @scene.wait(16,true)
  cx, cy = @targetSprite.getCenter(true)
  fp["claw1"] = Sprite.new(@viewport)
  fp["claw1"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb057_3")
  fp["claw1"].src_rect.set(-82,0,82,174)
  fp["claw1"].ox = fp["claw1"].src_rect.width
  fp["claw1"].oy = fp["claw1"].src_rect.height/2
  fp["claw1"].x = cx - 32*@targetSprite.zoom_x
  fp["claw1"].y = cy
  fp["claw1"].z = @targetIsPlayer ? 29 : 19
  fp["claw2"] = Sprite.new(@viewport)
  fp["claw2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb057_3")
  fp["claw2"].src_rect.set(-82,0,82,174)
  fp["claw2"].ox = 0
  fp["claw2"].oy = fp["claw2"].src_rect.height/2
  fp["claw2"].x = cx + 32*@targetSprite.zoom_x
  fp["claw2"].y = cy
  fp["claw2"].z = @targetIsPlayer ? 29 : 19
  fp["claw2"].mirror = true
  shake = 4
  for i in 0...32
    @targetSprite.still
    pbSEPlay("Anim/Slash10") if i == 4 || i == 16
    for j in 1..2
      next if (j-1)>(i/12)
      fp["claw#{j}"].src_rect.x += 82 if fp["claw#{j}"].src_rect.x < 82*3 && i%2==0
    end
    fp["claw1"].visible = false if i == 16
    fp["claw2"].visible = false if i == 32
    if i.between?(4,12) || i.between?(20,28)
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
    end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:TEMPORALRAZE) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}
  speed = []
  for j in 0...32
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].z = @userIsPlayer ? 29 : 19
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb223")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].color = Color.new(255,255,255,255)
    z = [0.5,1.5,1,0.75,1.25][rand(5)]
    fp["#{j}"].zoom_x = z
    fp["#{j}"].zoom_y = z
    fp["#{j}"].opacity = 0
    speed.push((rand(8)+1)*4)
  end
  for j in 0...8
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].z = @userIsPlayer ? 29 : 19
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb504")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height
    #z = [0.5,1.5,1,0.75,1.25][rand(5)]
    fp["s#{j}"].color = Color.new(255,255,255,255)
    #fp["s#{j}"].zoom_y = z
    fp["s#{j}"].opacity = 0
  end
  @userSprite.color = Color.new(255,0,0,0)
  # start animation
  @vector.set(vector2)
  @vector.inc = 0.1
  oy = @userSprite.oy
  k = -1
  for i in 0...64
    k *= -1 if i%4==0
    pbSEPlay("EBDX/Anim/dragon2") if i == 12
    cx, cy = @userSprite.getCenter(true)
    for j in 0...32
      next if i < 8
      next if j>(i-8)
      if fp["#{j}"].opacity == 0 && fp["#{j}"].color.alpha == 255
        fp["#{j}"].y = @userSprite.y + 8*@userSprite.zoom_y - rand(24)*@userSprite.zoom_y
        fp["#{j}"].x = cx - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
      end
      if fp["#{j}"].color.alpha <= 96
        fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].opacity += 32
      end
      fp["#{j}"].color.alpha -= 16
      fp["#{j}"].y -= speed[j]
    end
    for j in 0...8
      next if i < 12
      next if j>(i-12)/2
      if fp["s#{j}"].opacity == 0 && fp["s#{j}"].color.alpha == 255
        fp["s#{j}"].y = @userSprite.y + 48*@userSprite.zoom_y - rand(16)*@userSprite.zoom_y
        fp["s#{j}"].x = cx - 64*@userSprite.zoom_x + rand(128)*@userSprite.zoom_x
      end
      if fp["s#{j}"].color.alpha <= 96
        fp["s#{j}"].opacity -= 32
      else
        fp["s#{j}"].opacity += 32
      end
      fp["s#{j}"].color.alpha -= 16
      fp["s#{j}"].zoom_y += speed[j]*0.25*0.01
      fp["s#{j}"].y -= speed[j]
    end
    if i < 48
      @userSprite.color.alpha += 4
    else
      @userSprite.color.alpha -= 16
    end
    @userSprite.oy -= 2*k if i%2==0
    @userSprite.still
    @userSprite.anim = true
    @scene.wait(1,true)
  end
  @userSprite.oy = oy
  @vector.set(vector)
  @vector.inc = 0.2
  @scene.wait(16,true)
  cx, cy = @targetSprite.getCenter(true)
  fp["claw1"] = Sprite.new(@viewport)
  fp["claw1"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb057_3")
  fp["claw1"].src_rect.set(-82,0,82,174)
  fp["claw1"].ox = fp["claw1"].src_rect.width
  fp["claw1"].oy = fp["claw1"].src_rect.height/2
  fp["claw1"].x = cx - 32*@targetSprite.zoom_x
  fp["claw1"].y = cy
  fp["claw1"].z = @targetIsPlayer ? 29 : 19
  fp["claw2"] = Sprite.new(@viewport)
  fp["claw2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb057_3")
  fp["claw2"].src_rect.set(-82,0,82,174)
  fp["claw2"].ox = 0
  fp["claw2"].oy = fp["claw2"].src_rect.height/2
  fp["claw2"].x = cx + 32*@targetSprite.zoom_x
  fp["claw2"].y = cy
  fp["claw2"].z = @targetIsPlayer ? 29 : 19
  fp["claw2"].mirror = true
  shake = 4
  for i in 0...32
    @targetSprite.still
    pbSEPlay("Anim/Slash10") if i == 4 || i == 16
    for j in 1..2
      next if (j-1)>(i/12)
      fp["claw#{j}"].src_rect.x += 82 if fp["claw#{j}"].src_rect.x < 82*3 && i%2==0
    end
    fp["claw1"].visible = false if i == 16
    fp["claw2"].visible = false if i == 32
    if i.between?(4,12) || i.between?(20,28)
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
    end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:SPIRITSAP) do
  EliteBattle.playMoveAnimation(:NIGHTSLASH, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
  EliteBattle.playMoveAnimation(:ABSORB, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
EliteBattle.defineMoveAnimation(:DRAGONPULSE) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}; rndx = []; rndy = []; dx = []; dy = []
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...72
    fp["#{i}2"] = Sprite.new(@viewport)
    fp["#{i}2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263_3")
    fp["#{i}2"].ox = fp["#{i}2"].bitmap.width/2
    fp["#{i}2"].oy = fp["#{i}2"].bitmap.height/2
    fp["#{i}2"].opacity = 0
    fp["#{i}2"].z = 19
  end
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = 50
  fp["cir"].zoom_x = @targetIsPlayer ? 0.5 : 1
  fp["cir"].zoom_y = @targetIsPlayer ? 0.5 : 1
  fp["cir"].opacity = 0
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536")
    fp["#{i}s"].ox = -32 - rand(64)
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height/2
    fp["#{i}s"].angle = rand(270)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector2)
  for i in 0...20
    pbSEPlay("Anim/Harden") if i == 4
    @scene.wait(1,true)
  end
  @scene.wait(4,true)
  pbSEPlay("EBDX/Anim/dragon2")
  for i in 0...96
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...72
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
      next if j>(i)
      x0 = dx[j]
      y0 = dy[j]
      x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].opacity += 51
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].z = @targetSprite.z - 1 if nextx > cx && nexty < cy
      else
        fp["#{j}"].z = @targetSprite.z + 1 if nextx < cx && nexty > cy
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    pbSEPlay("Anim/Comet Punch") if i == 64
    fp["cir"].x, fp["cir"].y = ax, ay
    fp["cir"].angle += 32
    fp["cir"].opacity += (i>72) ? -51 : 255
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].zoom_x += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].zoom_y += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = ax, ay
    end
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  fp["cir"].opacity = 0
  for i in 0...20
    @targetSprite.still
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:PERFECTIONPULSE) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}; rndx = []; rndy = []; dx = []; dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb086_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...72
    fp["#{i}2"] = Sprite.new(@viewport)
    fp["#{i}2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb263_3")
    fp["#{i}2"].ox = fp["#{i}2"].bitmap.width/2
    fp["#{i}2"].oy = fp["#{i}2"].bitmap.height/2
    fp["#{i}2"].opacity = 0
    fp["#{i}2"].z = 19
  end
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = 50
  fp["cir"].zoom_x = @targetIsPlayer ? 0.5 : 1
  fp["cir"].zoom_y = @targetIsPlayer ? 0.5 : 1
  fp["cir"].opacity = 0
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536")
    fp["#{i}s"].ox = -32 - rand(64)
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height/2
    fp["#{i}s"].angle = rand(270)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector2)
  for i in 0...20
    if i < 10
      fp["bg"].opacity += 25.5
    else
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("Anim/Harden") if i == 4
    fp["bg"].update
    @scene.wait(1,true)
  end
  @scene.wait(4,true)
  pbSEPlay("EBDX/Anim/dragon2")
  for i in 0...96
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...72
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
      next if j>(i)
      x0 = dx[j]
      y0 = dy[j]
      x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].opacity += 51
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].z = @targetSprite.z - 1 if nextx > cx && nexty < cy
      else
        fp["#{j}"].z = @targetSprite.z + 1 if nextx < cx && nexty > cy
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    pbSEPlay("Anim/Comet Punch") if i == 64
    fp["cir"].x, fp["cir"].y = ax, ay
    fp["cir"].angle += 32
    fp["cir"].opacity += (i>72) ? -51 : 255
    fp["bg"].update
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].zoom_x += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].zoom_y += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = ax, ay
    end
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  fp["cir"].opacity = 0
  for i in 0...20
    @targetSprite.still
    if i < 10
      fp["bg"].color.alpha += 25.5
    else
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:HEXCANNON) do
  # inital configuration
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}; dx = []; dy = []
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb175")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = @userSprite.z + 1
  fp["cir"].mirror = @userIsPlayer
  fp["cir"].zoom_x = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].zoom_y = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].opacity = 0
  shake = 4; k = 0
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...40
    if i < 8
    else
      fp["cir"].x, fp["cir"].y = @userSprite.getCenter
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity += 24
    end
    if i == 8
      @vector.set(vector2)
      pbSEPlay("Anim/Heal4",80)
    end
    @scene.wait(1,true)
  end
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb175_4")
    fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
    fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
    fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
    r = 128*@userSprite.zoom_x
    z = [0.5,0.25,1,0.75][rand(4)]
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{i}s"].x = cx
    fp["#{i}s"].y = cy
    fp["#{i}s"].zoom_x = z*@userSprite.zoom_x
    fp["#{i}s"].zoom_y = z*@userSprite.zoom_x
    fp["#{i}s"].visible = false
    fp["#{i}s"].z = @userSprite.z + 1
    dx.push(x); dy.push(y)
  end
  fp["shot"] = Sprite.new(@viewport)
  fp["shot"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb175_2")
  fp["shot"].ox = fp["shot"].bitmap.width/2
  fp["shot"].oy = fp["shot"].bitmap.height/2
  fp["shot"].z = @userSprite.z + 1
  fp["shot"].zoom_x = @userSprite.zoom_x
  fp["shot"].zoom_y = @userSprite.zoom_x
  fp["shot"].opacity = 0
  x = defaultvector[0]; y = defaultvector[1]
  x2, y2 = @vector.spoof(defaultvector)
  fp["shot"].x = cx
  fp["shot"].y = cy
  pbSEPlay("EBDX/Anim/ghost1",80)
  k = -1
  for i in 0...20
    cx, cy = @userSprite.getCenter
    @vector.reset if i == 0
    if i > 0
      fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
      fp["shot"].opacity += 32
      fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
      fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
      for j in 0...8
        fp["#{j}s"].visible = true
        fp["#{j}s"].opacity -= 32
        fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
        fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
      end
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity -= 16
      fp["cir"].x = cx
      fp["cir"].y = cy
    end
    factor = @targetSprite.zoom_x if i == 12
    if i >= 12
      k *= -1 if i%4==0
      @targetSprite.zoom_x -= factor*0.01*k
      @targetSprite.zoom_y += factor*0.04*k
      @targetSprite.still
    end
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,i < 12)
  end
  shake = 2
  16.times do
    fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
    fp["shot"].opacity += 32
    fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
    fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
    fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
    fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 4
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 4
    @targetSprite.still
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:AVALANCHE) do
  indexes = []
  max = @battle.pbSideSize(@targetIsPlayer ? 0 : 1)
  for i in 0...max
    i = (@targetIsPlayer ? i*2 : (i*2 + 1))
    indexes.push(i) if @sprites["pokemon_#{i}"] && @sprites["pokemon_#{i}"].actualBitmap
  end
  vector = @scene.battle.doublebattle? ? EliteBattle.get_vector(:BATTLER, @targetIsPlayer) : @scene.getRealVector(@targetIndex, @targetIsPlayer)
  @vector.set(vector)
  @scene.wait(16, true)
  # set up animation
  dy = @vector.y2/12
  fp = {}; da = []; factors = []
  for m in 0...indexes.length
    @targetSprite = @sprites["pokemon_#{indexes[m]}"]
    if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
      factors.push(1)
      next
    end
    factors.push(@targetSprite.zoom_x)
  end
  for m in 0...indexes.length
    @targetSprite = @sprites["pokemon_#{indexes[m]}"]
    next if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
    for j in 0...96
      fp["r#{m}#{j}"] = Sprite.new(@viewport)
      fp["r#{m}#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb519_2")
      fp["r#{m}#{j}"].ox = fp["r#{m}#{j}"].bitmap.width/2
      fp["r#{m}#{j}"].oy = fp["r#{m}#{j}"].bitmap.height/2
      r = 64*factors[m]
      z = [1,0.5,0.75,0.25][rand(4)]
      fp["r#{m}#{j}"].zoom_x = z
      fp["r#{m}#{j}"].zoom_y = z
      fp["r#{m}#{j}"].x = @targetSprite.x - r + rand(r*2)
      fp["r#{m}#{j}"].y = rand(32*factors[m])
      fp["r#{m}#{j}"].visible = false
      fp["r#{m}#{j}"].angle = rand(360)
      fp["r#{m}#{j}"].z = @targetSprite.z + 1
      da.push(rand(2)==0 ? 1 : -1)
    end
    width = @targetSprite.bitmap.width/2 - 16
    max = 16# + (width/16)
    for j in 0...max
      fp["d#{m}#{j}"] = Sprite.new(@viewport)
      fp["d#{m}#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebDustParticle")
      fp["d#{m}#{j}"].ox = fp["d#{m}#{j}"].bitmap.width/2
      fp["d#{m}#{j}"].oy = fp["d#{m}#{j}"].bitmap.height/2
      fp["d#{m}#{j}"].opacity = 0
      fp["d#{m}#{j}"].angle = rand(360)
      fp["d#{m}#{j}"].x = @targetSprite.x - width*factors[m] + rand(width*2*factors[m])
      fp["d#{m}#{j}"].y = @targetSprite.y - 16*factors[m] + rand(32*factors[m])
      fp["d#{m}#{j}"].z = @targetSprite.z + (fp["d#{m}#{j}"].y < @targetSprite.y ? -1 : 1)
      zoom = [1,0.8,0.9,0.7][rand(4)]
      fp["d#{m}#{j}"].zoom_x = zoom*factors[m]
      fp["d#{m}#{j}"].zoom_y = zoom*factors[m]
    end
  end
  k = [-1,-1]
  # start animation
  for i in 0...80
    pbSEPlay("EBDX/Anim/rock2",70) if i%8==0
    for m in 0...indexes.length
      @targetSprite = @sprites["pokemon_#{indexes[m]}"]
      next if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
      for j in 0...96
        next if j>(i*2)
        fp["r#{m}#{j}"].y += dy
        fp["r#{m}#{j}"].visible = fp["r#{m}#{j}"].y < @targetSprite.y - 16*factors[m]
        fp["r#{m}#{j}"].angle += 8*da[j]
      end
      for j in 0...max
        next if i < 8
        next if j>(i-8)/2
        fp["d#{m}#{j}"].opacity += 25.5 if i < 18+j*2
        fp["d#{m}#{j}"].opacity -= 25.5 if i >= 22+j*2
        if fp["d#{m}#{j}"].x >= @targetSprite.x
          fp["d#{m}#{j}"].angle += 4
          fp["d#{m}#{j}"].x += 2
        else
          fp["d#{m}#{j}"].angle -= 4
          fp["d#{m}#{j}"].x -= 2
        end
      end
      if i >= 8 && i < 64
        k[m] *= -1 if i%4==0
        @targetSprite.zoom_y -= 0.04*k[m]*factors[m]
        @targetSprite.zoom_x += 0.02*k[m]*factors[m]
        @targetSprite.still
      end
    end
    @scene.wait
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:LIQUIDATION) do
  EliteBattle.playMoveAnimation(:CRABHAMMER, @scene, @userIndex, @targetIndex, @hitNum, @multiHit, nil, true)
end
EliteBattle.defineMoveAnimation(:FISHIOUSREND) do
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  # set up animation
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  fp = {}
  for j in 0...32
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = Bitmap.new(8,8)
    fp["s#{j}"].bitmap.bmp_circle(Color.new(25,75,183))
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height
    fp["s#{j}"].x = cx
    fp["s#{j}"].y = cy
    fp["s#{j}"].z = @targetSprite.z
    fp["s#{j}"].angle = rand(360)
    fp["s#{j}"].visible = false
  end
  for j in 0...16
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/fishious_rend")
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].angle = rand(360)
    fp["#{j}"].ox = - 80*factor
    fp["#{j}"].x = cx
    fp["#{j}"].y = cy
    fp["#{j}"].z = @targetSprite.z + 1
    fp["#{j}"].opacity = 0
  end
  # play animation
  for i in 0...48
    for j in 0...16
      next if j>i
      fp["#{j}"].opacity += 32
      fp["#{j}"].ox += (80*factor/8).ceil
      fp["#{j}"].visible = false if fp["#{j}"].ox >= 0
    end
    for j in 0...32
      next if j>i*2
      fp["s#{j}"].visible = true
      fp["s#{j}"].opacity -= 32
      fp["s#{j}"].oy += 16
    end
    @targetSprite.zoom_y = factor + 0.32 if i%6 == 0 && i < 32
    @targetSprite.zoom_y -= 0.08 if @targetSprite.zoom_y > factor
    pbSEPlay("Anim/hit",80) if i%6==0 && i < 32
    pbSEPlay("EBDX/Anim/poison1",60) if i%4==0 && i < 32
    @scene.wait
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:TIMELOOP) do | args |
  kick = args[0]; kick = false if kick.nil?
  # set up animation
  fp = {}
  rndx = []
  rndy = []
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(130,52,42))
  fp["bg"].opacity = 0
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_3")
    fp["#{i}"].src_rect.set(0,101*rand(3),53,101)
    fp["#{i}"].ox = 26
    fp["#{i}"].oy = 50
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 50
    fp["#{i}"].zoom_x = (@targetSprite.zoom_x)/2
    fp["#{i}"].zoom_y = (@targetSprite.zoom_y)/2
    rndx.push(rand(144))
    rndy.push(rand(144))
  end
  fp["punch"] = Sprite.new(@viewport)
  fp["punch"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb519_7")
  fp["punch"].ox = fp["punch"].bitmap.width/2
  fp["punch"].oy = fp["punch"].bitmap.height/2
  fp["punch"].opacity = 0
  fp["punch"].z = 40
  fp["punch"].angle = 180
  fp["punch"].zoom_x = @targetIsPlayer ? 6 : 4
  fp["punch"].zoom_y = @targetIsPlayer ? 6 : 4
  fp["punch"].tone = Tone.new(48,16,6)
  shake = 4
  # start animation
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  pbSEPlay("Anim/fog2", 75)
  @sprites["battlebg"].defocus
  for i in 0...36
    cx, cy = @targetSprite.getCenter(true)
    fp["punch"].x = cx
    fp["punch"].y = cy
    fp["punch"].angle -= 45 if i < 20
    fp["punch"].zoom_x -= @targetIsPlayer ? 0.2 : 0.15 if i < 20
    fp["punch"].zoom_y -= @targetIsPlayer ? 0.2 : 0.15 if i < 20
    fp["punch"].opacity += 8 if i < 20
    if i >= 20
      fp["punch"].tone = Tone.new(255,255,255) if i == 20
      fp["punch"].tone.all -= 25.5
      fp["punch"].opacity -= 25.5
    end
    pbSEPlay("Anim/Fire3") if i==20
    for j in 0...12
      next if i < 20
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 72*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 72*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].src_rect.x += 53 if i%2==0
      fp["#{j}"].src_rect.x = 0 if fp["#{j}"].src_rect.x >= fp["#{j}"].bitmap.width
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 16
        fp["#{j}"].tone.gray += 16
        fp["#{j}"].tone.red -= 4; fp["#{j}"].tone.green -= 4; fp["#{j}"].tone.blue -= 4
        fp["#{j}"].zoom_x -= 0.005
        fp["#{j}"].zoom_y += 0.01
      else
        fp["#{j}"].opacity += 45
      end
    end
    fp["bg"].opacity += 4 if  i < 20
    if i >= 20
      if i >= 28
        @targetSprite.tone.red -= 3*2
        @targetSprite.tone.green += 1.5*2
        @targetSprite.tone.blue += 3*2
        fp["bg"].opacity -= 10
      else
        @targetSprite.tone.red += 3*2 if @targetSprite.tone.red < 48*2
        @targetSprite.tone.green -= 1.5*2 if @targetSprite.tone.green > -24*2
        @targetSprite.tone.blue -= 3*2 if @targetSprite.tone.blue > -48*2
      end
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:FLAMEWHEEL) do
  # configure animation
  @vector.set(@scene.getRealVector(@userIndex, @userIsPlayer))
  @scene.wait(16,true)
  factor = @userSprite.zoom_x
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  fp = {}
  for j in 0...24
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    r = 64*factor
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{j}"].x = cx
    fp["#{j}"].y = cx
    fp["#{j}"].z = @userSprite.z
    fp["#{j}"].visible = false
    fp["#{j}"].angle = rand(360)
    z = [0.5,1,0.75][rand(3)]
    fp["#{j}"].zoom_x = z
    fp["#{j}"].zoom_y = z
    dx.push(x)
    dy.push(y)
  end
  # start animation
  pbSEPlay("EBDX/Anim/ground1",80)
  for i in 0...48
    for j in 0...24
      next if j>(i*2)
      fp["#{j}"].visible = true
      if ((fp["#{j}"].x - dx[j])*0.1).abs < 1
        fp["#{j}"].opacity -= 32
      else
        fp["#{j}"].x -= (fp["#{j}"].x - dx[j])*0.1
        fp["#{j}"].y -= (fp["#{j}"].y - dy[j])*0.1
      end
    end
    @scene.wait
  end
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  for j in 0...12
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb010")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
    r = 32*factor
    fp["s#{j}"].x = cx - r + rand(r*2)
    fp["s#{j}"].y = cy - r + rand(r*2)
    fp["s#{j}"].z = @targetSprite.z + 1
    fp["s#{j}"].visible = false
    fp["s#{j}"].tone = Tone.new(255,255,255)
    fp["s#{j}"].angle = rand(360)
  end
  # anim2
  for i in 0...32
    for j in 0...12
      next if j>(i*2)
      fp["s#{j}"].visible = true
      fp["s#{j}"].opacity -= 32
      fp["s#{j}"].zoom_x += 0.02
      fp["s#{j}"].zoom_y += 0.02
      fp["s#{j}"].angle += 8
      fp["s#{j}"].tone.red -= 32
      fp["s#{j}"].tone.green -= 32
      fp["s#{j}"].tone.blue -= 32
    end
    @targetSprite.still
    pbSEPlay("EBDX/Anim/fire2",80) if i%4==0 && i < 16
    @scene.wait
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:SCALD) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}; rndx = []; rndy = []; dx = []; dy = []
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...72
    fp["#{i}2"] = Sprite.new(@viewport)
    fp["#{i}2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb010")
    fp["#{i}2"].ox = fp["#{i}2"].bitmap.width/2
    fp["#{i}2"].oy = fp["#{i}2"].bitmap.height/2
    fp["#{i}2"].opacity = 0
    fp["#{i}2"].z = 19
  end
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = 50
  fp["cir"].zoom_x = @targetIsPlayer ? 0.5 : 1
  fp["cir"].zoom_y = @targetIsPlayer ? 0.5 : 1
  fp["cir"].opacity = 0
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb536")
    fp["#{i}s"].ox = -32 - rand(64)
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height/2
    fp["#{i}s"].angle = rand(270)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector2)
  for i in 0...20
    pbSEPlay("Anim/Water3") if i == 4
    @scene.wait(1,true)
  end
  @scene.wait(4,true)
  pbSEPlay("Anim/Water5")
  for i in 0...96
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...72
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
      next if j>(i)
      x0 = dx[j]
      y0 = dy[j]
      x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].opacity += 51
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].z = @targetSprite.z - 1 if nextx > cx && nexty < cy
      else
        fp["#{j}"].z = @targetSprite.z + 1 if nextx < cx && nexty > cy
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    pbSEPlay("Anim/Water3") if i == 64
    fp["cir"].x, fp["cir"].y = ax, ay
    fp["cir"].angle += 32
    fp["cir"].opacity += (i>72) ? -51 : 255
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].zoom_x += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].zoom_y += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = ax, ay
    end
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  fp["cir"].opacity = 0
  for i in 0...20
    @targetSprite.still
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:TEMPOMARCH) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  @vector.set(vector)
  @scene.wait(16,true)
  cx, cy = @targetSprite.getCenter(true)
  fp = {}
  fp["whip"] = Sprite.new(@viewport)
  fp["whip"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/tempo_march")
  fp["whip"].ox = fp["whip"].bitmap.width*0.75
  fp["whip"].oy = fp["whip"].bitmap.height*0.5
  fp["whip"].angle = 315
  fp["whip"].zoom_x = @targetSprite.zoom_x*1.5
  fp["whip"].zoom_y = @targetSprite.zoom_y*1.5
  fp["whip"].color = Color.new(255,255,255,0)
  fp["whip"].opacity = 0
  fp["whip"].x = cx + 32*@targetSprite.zoom_x
  fp["whip"].y = cy - 48*@targetSprite.zoom_y
  fp["whip"].z = @targetIsPlayer ? 29 : 19
  fp["imp"] = Sprite.new(@viewport)
  fp["imp"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb027_2")
  fp["imp"].ox = fp["imp"].bitmap.width/2
  fp["imp"].oy = fp["imp"].bitmap.height/2
  fp["imp"].zoom_x = @targetSprite.zoom_x*2
  fp["imp"].zoom_y = @targetSprite.zoom_y*2
  fp["imp"].visible = false
  fp["imp"].x = cx
  fp["imp"].y = cy - 48*@targetSprite.zoom_y
  fp["imp"].z = @targetIsPlayer ? 29 : 19
  posx = []
  posy = []
  angl = []
  zoom = []
  for j in 0...12
    fp["#{j}"] = Sprite.new(@viewport)
    fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb129_4")
    fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
    fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
    fp["#{j}"].z = @targetIsPlayer ? 29 : 19
    fp["#{j}"].visible = false
    z = [1,1.25,0.75,0.5][rand(4)]
    fp["#{j}"].zoom_x = @targetSprite.zoom_x*z
    fp["#{j}"].zoom_y = @targetSprite.zoom_y*z
    fp["#{j}"].angle = rand(360)
    posx.push(rand(128))
    posy.push(rand(64))
    angl.push((rand(2)==0 ? 1 : -1))
    zoom.push(z)
    fp["#{j}"].opacity = (155+rand(100))
  end
  # start animation
  k = 1
  for i in 0...32
    pbSEPlay("EBDX/Anim/normal4",80) if i == 4
    if i < 16
      fp["whip"].opacity += 128 if i < 4
      fp["whip"].angle += 16
      fp["whip"].color.alpha += 16 if i >= 8
      fp["whip"].zoom_x -= 0.2 if i >= 8
      fp["whip"].zoom_y -= 0.16 if i >= 4
      fp["whip"].opacity -= 64 if i >= 12
      fp["imp"].visible = true if i == 3
      if i >= 4
        fp["imp"].angle += 4
        fp["imp"].zoom_x -= 0.02
        fp["imp"].zoom_x -= 0.02
        fp["imp"].opacity -= 32
      end
      @targetSprite.zoom_y -= 0.04*k
      @targetSprite.zoom_x += 0.02*k
      @targetSprite.tone = Tone.new(255,255,255) if i == 4
      @targetSprite.tone.red -= 51 if @targetSprite.tone.red > 0
      @targetSprite.tone.green -= 51 if @targetSprite.tone.green > 0
      @targetSprite.tone.blue -= 51 if @targetSprite.tone.blue > 0
      k *= -1 if (i-4)%6==0
    end
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...12
      next if i < 4
      next if j>(i-4)
      fp["#{j}"].visible = true
      fp["#{j}"].x = cx - 64*@targetSprite.zoom_x*zoom[j] + posx[j]*@targetSprite.zoom_x*zoom[j]
      fp["#{j}"].y = cy - posy[j]*@targetSprite.zoom_y*zoom[j] - 48*@targetSprite.zoom_y*zoom[j]# - (i-4)*2*@targetSprite.zoom_y
      fp["#{j}"].angle += angl[j]
    end
    @scene.wait
  end
  @vector.reset if !@multiHit
  for i in 0...16
    @scene.wait(1,true)
    cx, cy = @targetSprite.getCenter(true)
    k = 20 - i
    for j in 0...12
      fp["#{j}"].x = cx - 64*@targetSprite.zoom_x*zoom[j] + posx[j]*@targetSprite.zoom_x*zoom[j]
      fp["#{j}"].y = cy - posy[j]*@targetSprite.zoom_y*zoom[j] - 48*@targetSprite.zoom_y*zoom[j]# - (k)*2*@targetSprite.zoom_y
      fp["#{j}"].opacity -= 16
      fp["#{j}"].angle += angl[j]
      fp["#{j}"].zoom_x = @targetSprite.zoom_x
      fp["#{j}"].zoom_y = @targetSprite.zoom_y
    end
  end
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:SURF) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  factor = @targetIsPlayer ? 2 : 1.5
  # set up animation
  fp = {}
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 6
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/surf",true)
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  fp["bg"].oy = fp["bg"].src_rect.height/2
  fp["bg"].y = @viewport.height/2
  shake = 8
  zoom = -1
  # start animation
  @vector.set(vector)
  @sprites["battlebg"].defocus
  for i in 0...72
    pbSEPlay("EBDX/Anim/poison1",80) if i == 40
    pbSEPlay("EBDX/Anim/water1",80) if i == 62
    if i < 10
      fp["bg"].opacity += 25.5
    elsif i < 20
      fp["bg"].color.alpha -= 25.5
    elsif i >= 62
      fp["bg"].color.alpha += 25.5
      @targetSprite.tone.red += 18
      @targetSprite.tone.green += 18
      @targetSprite.tone.blue += 18
      @targetSprite.zoom_x += 0.04*factor
      @targetSprite.zoom_y += 0.04*factor
    elsif i >= 40
      @targetSprite.ox += shake
      shake = -8 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 4
      shake = 8 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 4
      @targetSprite.still
    end
    zoom *= -1 if i%2 == 0
    fp["bg"].update
    fp["bg"].zoom_y += 0.04*zoom
    @scene.wait(1,(i<62))
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  10.times do
    @targetSprite.tone.red -= 18
    @targetSprite.tone.green -= 18
    @targetSprite.tone.blue -= 18
    @targetSprite.zoom_x -= 0.04*factor
    @targetSprite.zoom_y -= 0.04*factor
    @targetSprite.still
    @scene.wait
  end
  @scene.wait(8)
  @vector.reset if !@multiHit
  10.times do
    fp["bg"].opacity -= 25.5
    @targetSprite.still
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:WATERFALL) do
  pbSEPlay("EBDX/Anim/water1",80)
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  factor = @targetSprite.zoom_x
  # set up animation
  fp = {}; rndx = []; rndy = []
  cx, cy = @targetSprite.getCenter(true)
  for i in 0...12
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb551")
    fp["#{i}"].ox = 10
    fp["#{i}"].oy = 10
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 51
    r = rand(3)
    fp["#{i}"].zoom_x = (factor-0.5)*(r==0 ? 1 : 0.5)
    fp["#{i}"].zoom_y = (factor-0.5)*(r==0 ? 1 : 0.5)
    fp["#{i}"].tone = Tone.new(60,60,60)
    rndx.push(rand(128))
    rndy.push(rand(64))
  end
  wait = []
  for m in 0...8
    fp["w#{m}"] = Sprite.new(@viewport)
    fp["w#{m}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebMega004")
    fp["w#{m}"].ox = 20
    fp["w#{m}"].oy = 16
    fp["w#{m}"].opacity = 0
    fp["w#{m}"].z = 50
    fp["w#{m}"].angle = rand(360)
    fp["w#{m}"].zoom_x = factor - 0.5
    fp["w#{m}"].zoom_y = factor - 0.5
    fp["w#{m}"].x = cx - 32*factor + rand(64*factor)
    fp["w#{m}"].y = cy - 112*factor + rand(112*factor)
    wait.push(0)
  end
  pbSEPlay("EBDX/Anim/poison1",80)
  frame = Sprite.new(@viewport)
  frame.z = 51
  frame.bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb540")
  frame.src_rect.set(0,0,64,64)
  frame.ox = 32
  frame.oy = 32
  frame.zoom_x = 0.5*factor
  frame.zoom_y = 0.5*factor
  frame.x, frame.y = @targetSprite.getCenter(true)
  frame.opacity = 0
  frame.tone = Tone.new(255,255,255)
  frame.y -= 32*@targetSprite.zoom_y
  # start animation
  for i in 1..30
    if i.between?(1,5)
      @targetSprite.still
      @targetSprite.zoom_y-=0.05*factor
      @targetSprite.tone.all-=12.8
      frame.zoom_x += 0.1*factor
      frame.zoom_y += 0.1*factor
      frame.opacity += 51
    end
    frame.tone = Tone.new(0,0,0) if i == 6
    if i.between?(6,10)
      @targetSprite.still
      @targetSprite.zoom_y+=0.05*factor
      @targetSprite.tone.all+=12.8
      frame.angle += 2
    end
    frame.src_rect.x = 64 if i == 10
    if i >= 10
      frame.opacity -= 25.5
      frame.zoom_x += 0.1*factor
      frame.zoom_y += 0.1*factor
      frame.angle += 2
    end
    for m in 0...8
      next if m>(i/2)
      fp["w#{m}"].angle += 2
      fp["w#{m}"].opacity += 32*(wait[m] < 8 ? 1 : -0.25)
      wait[m] +=  1
    end
    for j in 0...12
      cx = frame.x; cy = frame.y
      if fp["#{j}"].opacity == 0 && fp["#{j}"].visible
        fp["#{j}"].x = cx
        fp["#{j}"].y = cy
      end
      x2 = cx - 64*@targetSprite.zoom_x + rndx[j]*@targetSprite.zoom_x
      y2 = cy - 64*@targetSprite.zoom_y + rndy[j]*@targetSprite.zoom_y
      x0 = fp["#{j}"].x
      y0 = fp["#{j}"].y
      fp["#{j}"].x += (x2 - x0)*0.2
      fp["#{j}"].y += (y2 - y0)*0.2
      fp["#{j}"].zoom_x += 0.01
      fp["#{j}"].zoom_y += 0.01
      if i < 20
        fp["#{j}"].tone.red -= 6; fp["#{j}"].tone.blue -= 6; fp["#{j}"].tone.green -= 6
      end
      if (x2 - x0)*0.2 < 1 && (y2 - y0)*0.2 < 1
        fp["#{j}"].opacity -= 51
      else
        fp["#{j}"].opacity += 51
      end
      fp["#{j}"].visible = false if fp["#{j}"].opacity <= 0
    end
    @scene.wait
  end
  frame.dispose
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
EliteBattle.defineMoveAnimation(:RECOVER) do
    EliteBattle.playMoveAnimation(:SOLARBEAM_CHARGE, @scene, @userIndex, @targetIndex)
end
EliteBattle.defineMoveAnimation(:MOONBLAST) do
  # inital configuration
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}; dx = []; dy = []
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/moon")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = @userSprite.z + 1
  fp["cir"].mirror = @userIsPlayer
  fp["cir"].zoom_x = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].zoom_y = (@targetIsPlayer ? 0.75 : 1)
  fp["cir"].opacity = 0
  shake = 4; k = 0
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...40
    if i < 8
    else
      fp["cir"].x, fp["cir"].y = @userSprite.getCenter
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity += 24
    end
    if i == 8
      @vector.set(vector2)
      pbSEPlay("Anim/Heal4",80)
    end
    @scene.wait(1,true)
  end
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/moon")
    fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
    fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
    fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
    r = 128*@userSprite.zoom_x
    z = [0.5,0.25,1,0.75][rand(4)]
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{i}s"].x = cx
    fp["#{i}s"].y = cy
    fp["#{i}s"].zoom_x = z*@userSprite.zoom_x
    fp["#{i}s"].zoom_y = z*@userSprite.zoom_x
    fp["#{i}s"].visible = false
    fp["#{i}s"].z = @userSprite.z + 1
    dx.push(x); dy.push(y)
  end
  fp["shot"] = Sprite.new(@viewport)
  fp["shot"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/moonblast")
  fp["shot"].ox = fp["shot"].bitmap.width/2
  fp["shot"].oy = fp["shot"].bitmap.height/2
  fp["shot"].z = @userSprite.z + 1
  fp["shot"].zoom_x = @userSprite.zoom_x
  fp["shot"].zoom_y = @userSprite.zoom_x
  fp["shot"].opacity = 0
  x = defaultvector[0]; y = defaultvector[1]
  x2, y2 = @vector.spoof(defaultvector)
  fp["shot"].x = cx
  fp["shot"].y = cy
  pbSEPlay("EBDX/Anim/ghost1",80)
  k = -1
  for i in 0...20
    cx, cy = @userSprite.getCenter
    @vector.reset if i == 0
    if i > 0
      fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
      fp["shot"].opacity += 32
      fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
      fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
      for j in 0...8
        fp["#{j}s"].visible = true
        fp["#{j}s"].opacity -= 32
        fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
        fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
      end
      fp["cir"].angle += 24*(@userIsPlayer ? -1 : 1)
      fp["cir"].opacity -= 16
      fp["cir"].x = cx
      fp["cir"].y = cy
    end
    factor = @targetSprite.zoom_x if i == 12
    if i >= 12
      k *= -1 if i%4==0
      @targetSprite.zoom_x -= factor*0.01*k
      @targetSprite.zoom_y += factor*0.04*k
      @targetSprite.still
    end
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,i < 12)
  end
  shake = 2
  16.times do
    fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
    fp["shot"].opacity += 32
    fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
    fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
    fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
    fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 4
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 4
    @targetSprite.still
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:TEMPORALSHIFT) do
  # inital configuration
  pbSEPlay("EBDX/Anim/dragon2",80)
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16, true)
  factor = @targetSprite.zoom_x
  # set up animation
  fp = {}
  cx, cy = @targetSprite.getCenter(true)
  da = []; dx = []; dy = []; doj = []
  for i in 0...32
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb086_2")
    fp["#{i}"].ox = 12
    fp["#{i}"].oy = 1
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = @targetSprite.z + 1
    r = 128*factor
    z = [1,1.25,0.75,1.5][rand(4)]
    fp["#{i}"].zoom_x = z
    #fp["#{i}"].zoom_y = factor
    fp["#{i}"].x = cx
    fp["#{i}"].y = cy
    fp["#{i}"].tone = Tone.new(255,255,255)
    da.push(rand(2)==0 ? 1 : -1)
    dx.push(cx - r + rand(r*2))
    dy.push(cy - r + rand(r*2))
    doj.push(rand(4)+1)
  end
  fp["slash"] = Sprite.new(@viewport)
  fp["slash"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb159")
  fp["slash"].ox = fp["slash"].bitmap.width/2
  fp["slash"].oy = fp["slash"].bitmap.height/2
  fp["slash"].x = cx
  fp["slash"].y = cy
  #fp["slash"].zoom_x = factor
  #fp["slash"].zoom_y = factor
  fp["slash"].z = @targetSprite.z
  fp["slash"].src_rect.height = 0
  pbSEPlay("EBDX/Anim/normal3",80)
  # start animation
  shake = 2
  for i in 0...48
    fp["slash"].src_rect.height += 48 if i < 8
    for j in 0...32
      fp["#{j}"].angle += 32*da[j]
      fp["#{j}"].tone.red -= 8 if fp["#{j}"].tone.red > 0
      fp["#{j}"].tone.green -= 8 if fp["#{j}"].tone.green > 0
      fp["#{j}"].tone.blue -= 8 if fp["#{j}"].tone.blue > 0
      fp["#{j}"].opacity += 16*(i < 24 ? 4 : -1*doj[j])
      fp["#{j}"].x -= (fp["#{j}"].x - dx[j])*0.05
      fp["#{j}"].y -= (fp["#{j}"].y - dy[j])*0.05
    end
    if i >= 4
      fp["slash"].tone.red += 16 if fp["slash"].tone.red < 255
      fp["slash"].tone.green += 16 if fp["slash"].tone.green < 255
      fp["slash"].tone.blue += 16 if fp["slash"].tone.blue < 255
      fp["slash"].opacity -= 32 if i >= 8
    end
    if i >= 8
      @targetSprite.ox += shake
      shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
EliteBattle.defineMoveAnimation(:BULLETPUNCH) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  fp = {}
  # animation start
  @sprites["battlebg"].defocus
  @vector.set(vector)
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  for j in 0...12
    fp["f#{j}"] = Sprite.new(@viewport)
    fp["f#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb086")
    fp["f#{j}"].ox = fp["f#{j}"].bitmap.width/2
    fp["f#{j}"].oy = fp["f#{j}"].bitmap.height/2
    fp["f#{j}"].z = @targetSprite.z + 1
    r = 32*factor
    fp["f#{j}"].x = cx - r + rand(r*2)
    fp["f#{j}"].y = cy - r + rand(r*2)
    fp["f#{j}"].visible = false
    fp["f#{j}"].zoom_x = factor
    fp["f#{j}"].zoom_y = factor
    fp["f#{j}"].color = Color.new(180,53,2,0)
  end
  dx = []
  dy = []
  for j in 0...96
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb024")
    fp["p#{j}"].ox = fp["p#{j}"].bitmap.width/2
    fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
    fp["p#{j}"].z = @targetSprite.z
    r = 148*factor + rand(32)*factor
    x, y = randCircleCord(r)
    fp["p#{j}"].x = cx
    fp["p#{j}"].y = cy
    fp["p#{j}"].visible = false
    fp["p#{j}"].zoom_x = factor
    fp["p#{j}"].zoom_y = factor
    fp["p#{j}"].color = Color.new(180,53,2,0)
    dx.push(cx - r + x)
    dy.push(cy - r + y)
  end
  k = -4
  for i in 0...72
    k *= - 1 if i%4==0
    for j in 0...12
      next if j>(i/4)
      pbSEPlay("Anim/hit",80) if fp["f#{j}"].opacity == 255
      fp["f#{j}"].visible = true
      fp["f#{j}"].zoom_x -= 0.025
      fp["f#{j}"].zoom_y -= 0.025
      fp["f#{j}"].opacity -= 16
      fp["f#{j}"].color.alpha += 32
    end
    for j in 0...96
      next if j>(i*2)
      fp["p#{j}"].visible = true
      fp["p#{j}"].x -= (fp["p#{j}"].x - dx[j])*0.2
      fp["p#{j}"].y -= (fp["p#{j}"].y - dy[j])*0.2
      fp["p#{j}"].opacity -= 32 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 16
      fp["p#{j}"].color.alpha += 16 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 32
      fp["p#{j}"].zoom_x += 0.1
      fp["p#{j}"].zoom_y += 0.1
      fp["p#{j}"].angle = -Math.atan(1.0*(fp["p#{j}"].y-cy)/(fp["p#{j}"].x-cx))*(180.0/Math::PI)
    end
    @targetSprite.still
    @targetSprite.zoom_x -= factor*0.01*k if i < 56
    @targetSprite.zoom_y += factor*0.02*k if i < 56
    @scene.wait
  end
  @vector.reset if !@multiHit
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:POLARITYPULSE) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  factor = @userIsPlayer ? 2 : 1
  # set up animation
  fp = {}; rndx = []; rndy = []; dx = []; dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb027_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  for i in 0...72
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb176_3")
    fp["#{i}"].ox = fp["#{i}"].bitmap.width/2
    fp["#{i}"].oy = fp["#{i}"].bitmap.height/2
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = 19
    rndx.push(rand(16))
    rndy.push(rand(16))
    dx.push(0)
    dy.push(0)
  end
  for i in 0...72
    fp["#{i}2"] = Sprite.new(@viewport)
    fp["#{i}2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb520")
    fp["#{i}2"].ox = fp["#{i}2"].bitmap.width/2
    fp["#{i}2"].oy = fp["#{i}2"].bitmap.height/2
    fp["#{i}2"].opacity = 0
    fp["#{i}2"].z = 19
  end
  fp["cir"] = Sprite.new(@viewport)
  fp["cir"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb024")
  fp["cir"].ox = fp["cir"].bitmap.width/2
  fp["cir"].oy = fp["cir"].bitmap.height/2
  fp["cir"].z = 50
  fp["cir"].zoom_x = @targetIsPlayer ? 0.5 : 1
  fp["cir"].zoom_y = @targetIsPlayer ? 0.5 : 1
  fp["cir"].opacity = 0
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb523")
    fp["#{i}s"].ox = -32 - rand(64)
    fp["#{i}s"].oy = fp["#{i}s"].bitmap.height/2
    fp["#{i}s"].angle = rand(270)
    r = rand(2)
    fp["#{i}s"].zoom_x = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].zoom_y = (r==0 ? 0.1 : 0.2)*factor
    fp["#{i}s"].visible = false
    fp["#{i}s"].opacity = 255 - rand(101)
    fp["#{i}s"].z = 50
  end
  shake = 4
  # start animation
  @sprites["battlebg"].defocus
  @vector.set(vector2)
  for i in 0...20
    if i < 10
      fp["bg"].opacity += 25.5
    else
      fp["bg"].color.alpha -= 25.5
    end
    pbSEPlay("EBDX/Anim/iron5") if i == 4
    fp["bg"].update
    @scene.wait(1,true)
  end
  @scene.wait(4,true)
  pbSEPlay("Anim/Psych Up")
  for i in 0...96
    ax, ay = @userSprite.getAnchor
    cx, cy = @targetSprite.getCenter(true)
    for j in 0...72
      if fp["#{j}"].opacity == 0 && fp["#{j}"].tone.gray == 0
        dx[j] = ax - 8*@userSprite.zoom_x*0.5 + rndx[j]*@userSprite.zoom_x*0.5
        dy[j] = ay - 8*@userSprite.zoom_y*0.5 + rndy[j]*@userSprite.zoom_y*0.5
        fp["#{j}"].x = dx[j]
        fp["#{j}"].y = dy[j]
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
      next if j>(i)
      x0 = dx[j]
      y0 = dy[j]
      x2 = cx - 8*@targetSprite.zoom_x*0.5 + rndx[j]*@targetSprite.zoom_x*0.5
      y2 = cy - 8*@targetSprite.zoom_y*0.5 + rndy[j]*@targetSprite.zoom_y*0.5
      fp["#{j}"].x += (x2 - x0)*0.1
      fp["#{j}"].y += (y2 - y0)*0.1
      fp["#{j}"].opacity += 51
      fp["#{j}"].angle = -Math.atan(1.0*(y2-y0)/(x2-x0))*180/Math::PI + (rand(4)==0 ? 180 : 0)
      nextx = fp["#{j}"].x# + (x2 - x0)*0.1
      nexty = fp["#{j}"].y# + (y2 - y0)*0.1
      if !@targetIsPlayer
        fp["#{j}"].z = @targetSprite.z - 1 if nextx > cx && nexty < cy
      else
        fp["#{j}"].z = @targetSprite.z + 1 if nextx < cx && nexty > cy
      end
      @scene.applySpriteProperties(fp["#{j}"],fp["#{j}2"])
    end
    if i >= 64
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    pbSEPlay("EBDX/Anim/ghost2") if i == 64
    fp["cir"].x, fp["cir"].y = ax, ay
    fp["cir"].angle += 32
    fp["cir"].opacity += (i>72) ? -51 : 255
    fp["bg"].update
    for m in 0...8
      fp["#{m}s"].visible = true
      fp["#{m}s"].opacity -= 12
      fp["#{m}s"].zoom_x += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].zoom_y += 0.04*factor if fp["#{m}s"].opacity > 0
      fp["#{m}s"].x, fp["#{m}s"].y = ax, ay
    end
    @vector.set(vector) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  fp["cir"].opacity = 0
  for i in 0...20
    @targetSprite.still
    if i < 10
      fp["bg"].color.alpha += 25.5
    else
      fp["bg"].opacity -= 25.5
    end
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end

EliteBattle.defineMoveAnimation(:FEATHERDART) do
  # inital configuration
  defaultvector = EliteBattle.get_vector(:MAIN, @battle)
  vector2 = @scene.getRealVector(@userIndex, @userIsPlayer)
  # set up animation
  fp = {}; dx = []; dy = []
  # start animation
  @sprites["battlebg"].defocus
  for i in 0...40
    if i == 8
      @vector.set(vector2)
      pbSEPlay("Anim/Heal4",80)
    end
    @scene.wait(1,true)
  end
  cx, cy = @userSprite.getCenter(true)
  dx = []
  dy = []
  for i in 0...8
    fp["#{i}s"] = Sprite.new(@viewport)
    fp["#{i}s"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb010")
    fp["#{i}s"].src_rect.set(rand(3)*36,0,36,36)
    fp["#{i}s"].ox = fp["#{i}s"].src_rect.width/2
    fp["#{i}s"].oy = fp["#{i}s"].src_rect.height/2
    r = 128*@userSprite.zoom_x
    z = [0.5,0.25,1,0.75][rand(4)]
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    fp["#{i}s"].x = cx
    fp["#{i}s"].y = cy
    fp["#{i}s"].zoom_x = z*@userSprite.zoom_x
    fp["#{i}s"].zoom_y = z*@userSprite.zoom_x
    fp["#{i}s"].visible = false
    fp["#{i}s"].z = @userSprite.z + 1
    dx.push(x); dy.push(y)
  end
  fp["shot"] = Sprite.new(@viewport)
  fp["shot"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb086_2")
  fp["shot"].ox = fp["shot"].bitmap.width/2
  fp["shot"].oy = fp["shot"].bitmap.height/2
  fp["shot"].z = @userSprite.z + 1
  fp["shot"].zoom_x = @userSprite.zoom_x
  fp["shot"].zoom_y = @userSprite.zoom_x
  fp["shot"].opacity = 0
  x = defaultvector[0]; y = defaultvector[1]
  x2, y2 = @vector.spoof(defaultvector)
  fp["shot"].x = cx
  fp["shot"].y = cy
  pbSEPlay("EBDX/Anim/ghost1",80)
  k = -1
  for i in 0...20
    cx, cy = @userSprite.getCenter
    @vector.reset if i == 0
    if i > 0
      fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
      fp["shot"].opacity += 32
      fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
      fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
      fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
      fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
      for j in 0...8
        fp["#{j}s"].visible = true
        fp["#{j}s"].opacity -= 32
        fp["#{j}s"].x -= (fp["#{j}s"].x - dx[j])*0.2
        fp["#{j}s"].y -= (fp["#{j}s"].y - dy[j])*0.2
      end
    end
    factor = @targetSprite.zoom_x if i == 12
    if i >= 12
      k *= -1 if i%4==0
      @targetSprite.zoom_x -= factor*0.01*k
      @targetSprite.zoom_y += factor*0.04*k
      @targetSprite.still
    end
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,i < 12)
  end
  shake = 2
  16.times do
    fp["shot"].angle = Math.atan(1.0*(@vector.y-@vector.y2)/(@vector.x2-@vector.x))*(180.0/Math::PI) + (@targetIsPlayer ? 180 : 0)
    fp["shot"].opacity += 32
    fp["shot"].zoom_x -= (fp["shot"].zoom_x - @targetSprite.zoom_x)*0.1
    fp["shot"].zoom_y -= (fp["shot"].zoom_y - @targetSprite.zoom_y)*0.1
    fp["shot"].x += (@targetIsPlayer ? -1 : 1)*(x2 - x)/24
    fp["shot"].y -= (@targetIsPlayer ? -1 : 1)*(y - y2)/24
    @targetSprite.ox += shake
    shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 4
    shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 4
    @targetSprite.still
    cx, cy = @targetSprite.getCenter(true)
    if !@targetIsPlayer
      fp["shot"].z = @targetSprite.z - 1 if fp["shot"].x > cx && fp["shot"].y < cy
    else
      fp["shot"].z = @targetSprite.z + 1 if fp["shot"].x < cx && fp["shot"].y > cy
    end
    @scene.wait(1,true)
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
EliteBattle.defineMoveAnimation(:NIGHTRUSH) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  fp = {}
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/spectral_shriek_bg")
  fp["bg"].color = Color.new(0,0,0,255)
  fp["bg"].opacity = 0
  # animation start
  @sprites["battlebg"].defocus
  @vector.set(vector)
  for i in 0...16
    fp["bg"].opacity += 32 if i >= 8
    @scene.wait(1,true)
  end
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  for j in 0...12
    fp["f#{j}"] = Sprite.new(@viewport)
    fp["f#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb108")
    fp["f#{j}"].ox = fp["f#{j}"].bitmap.width/2
    fp["f#{j}"].oy = fp["f#{j}"].bitmap.height/2
    fp["f#{j}"].z = @targetSprite.z + 1
    r = 32*factor
    fp["f#{j}"].x = cx - r + rand(r*2)
    fp["f#{j}"].y = cy - r + rand(r*2)
    fp["f#{j}"].visible = false
    fp["f#{j}"].zoom_x = factor
    fp["f#{j}"].zoom_y = factor
    fp["f#{j}"].color = Color.new(180,53,2,0)
  end
  dx = []
  dy = []
  for j in 0...96
    fp["p#{j}"] = Sprite.new(@viewport)
    fp["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebPoison3")
    fp["p#{j}"].ox = fp["p#{j}"].bitmap.width/2
    fp["p#{j}"].oy = fp["p#{j}"].bitmap.height/2
    fp["p#{j}"].z = @targetSprite.z
    r = 148*factor + rand(32)*factor
    x, y = randCircleCord(r)
    fp["p#{j}"].x = cx
    fp["p#{j}"].y = cy
    fp["p#{j}"].visible = false
    fp["p#{j}"].zoom_x = factor
    fp["p#{j}"].zoom_y = factor
    fp["p#{j}"].color = Color.new(180,53,2,0)
    dx.push(cx - r + x)
    dy.push(cy - r + y)
  end
  k = -4
  for i in 0...72
    k *= - 1 if i%4==0
    fp["bg"].color.alpha -= 32 if fp["bg"].color.alpha > 0
    for j in 0...12
      next if j>(i/4)
      pbSEPlay("Anim/hit",80) if fp["f#{j}"].opacity == 255
      fp["f#{j}"].visible = true
      fp["f#{j}"].zoom_x -= 0.025
      fp["f#{j}"].zoom_y -= 0.025
      fp["f#{j}"].opacity -= 16
      fp["f#{j}"].color.alpha += 32
    end
    for j in 0...96
      next if j>(i*2)
      fp["p#{j}"].visible = true
      fp["p#{j}"].x -= (fp["p#{j}"].x - dx[j])*0.2
      fp["p#{j}"].y -= (fp["p#{j}"].y - dy[j])*0.2
      fp["p#{j}"].opacity -= 32 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 16
      fp["p#{j}"].color.alpha += 16 if ((fp["p#{j}"].x - dx[j])*0.2).abs < 32
      fp["p#{j}"].zoom_x += 0.1
      fp["p#{j}"].zoom_y += 0.1
      fp["p#{j}"].angle = -Math.atan(1.0*(fp["p#{j}"].y-cy)/(fp["p#{j}"].x-cx))*(180.0/Math::PI)
    end
    fp["bg"].update
    @targetSprite.still
    @targetSprite.zoom_x -= factor*0.01*k if i < 56
    @targetSprite.zoom_y += factor*0.02*k if i < 56
    @scene.wait
  end
  @vector.reset if !@multiHit
  16.times do
    fp["bg"].color.alpha += 16
    fp["bg"].opacity -= 16
    fp["bg"].update
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  pbDisposeSpriteHash(fp)
end
