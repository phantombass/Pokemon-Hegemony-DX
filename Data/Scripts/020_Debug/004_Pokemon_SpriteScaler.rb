class EBSBitmapWrapper
  attr_reader :width, :height, :totalFrames, :animationFrames, :currentIndex
  attr_accessor :constrict, :scale, :frameSkip
  #-----------------------------------------------------------------------------
  @@disableBitmapAnimation = false
  #-----------------------------------------------------------------------------
  #  class constructor
  #-----------------------------------------------------------------------------
  def initialize(file, scale = Settings::FRONT_BATTLER_SPRITE_SCALE, skip = 1)
    # failsafe checks
    raise "filename is nil" if file.nil?
    #---------------------------------------------------------------------------
    @scale = scale
    @constrict = nil
    @width = 0
    @height = 0
    @frame = 0
    @frames = 2
    @frameSkip = skip
    @direction = 1
    @animationFinish = false
    @totalFrames = 0
    @currentIndex = 0
    @changed_hue = false
    @speed = 1
      # 0 - not moving at all
      # 1 - normal speed
      # 2 - medium speed
      # 3 - slow speed
    @bitmapFile = RPG::Cache.load_bitmap("",file)
    # initializes full Pokemon bitmap
    @bitmap = Bitmap.new(@bitmapFile.width,@bitmapFile.height)
    @bitmap.blt(0,0,@bitmapFile,@bitmapFile.rect)
    @width = @bitmapFile.height*@scale
    @height = @bitmap.height*@scale
    #---------------------------------------------------------------------------
    self.refresh
    #---------------------------------------------------------------------------
    @actualBitmap = Bitmap.new(@width,@height)
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/@scale),0,@width/@scale,@height/@scale))
  end
  #-----------------------------------------------------------------------------
  #  returns proper object values when requested
  #-----------------------------------------------------------------------------
  def length; @totalFrames; end
  def disposed?; @actualBitmap.disposed?; end
  def dispose
    @bitmap.dispose
    @bitmapFile.dispose
    @actualBitmap.dispose
  end
  def copy; @actualBitmap.clone; end
  def bitmap; @actualBitmap; end
  def bitmap=(val); @actualBitmap=val; end
  def each; end
  def alterBitmap(index); return @strip[index]; end
  #-----------------------------------------------------------------------------
  #  preparation and compiling of spritesheet for sprite alterations
  #-----------------------------------------------------------------------------
  def prepareStrip
    @strip = []
    for i in 0...@totalFrames
      bitmap = Bitmap.new(@width,@height)
      bitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmapFile,Rect.new((@width/@scale)*i,0,@width/@scale,@height/@scale))
      @strip.push(bitmap)
    end
  end
  def compileStrip
    @bitmap.clear
    for i in 0...@strip.length
      @bitmap.stretch_blt(Rect.new((@width/@scale)*i,0,@width/@scale,@height/@scale),@strip[i],Rect.new(0,0,@width,@height))
    end
  end
  #-----------------------------------------------------------------------------
  #  creates custom loop if defined in data
  #-----------------------------------------------------------------------------
  def compileLoop(data)
    r = @bitmapFile.height; w = 0; x = 0
    @bitmap.clear
    # calculate total bitmap width
    for p in data
      w += p[:range].to_a.length * p[:repeat] * r
    end
    # create new bitmap
    @bitmap = Bitmap.new(w,r)
    # compile strip from data
    for m in 0...data.length
      range = data[m][:range].to_a
      repeat = data[m][:repeat]
      # offset based on previous frames
      x += m > 0 ? (data[m-1][:range].to_a.length * data[m-1][:repeat] * r) : 0
      for i in 0...repeat
        for j in 0...range.length
          x0 = x + (i*range.length*r) + (j*r)
          # draws frame from repeated ranges
          @bitmap.blt(x0,0,@bitmapFile,Rect.new(range[j]*r,0,r,r))
        end
      end
    end
    self.refresh
  end
  #-----------------------------------------------------------------------------
  #  refreshes the metric parameters
  #-----------------------------------------------------------------------------
  def refresh
    # calculates the total number of frames
    @totalFrames = (@bitmap.width.to_f/@bitmap.height).ceil
    @animationFrames = @totalFrames*@frames
  end
  #-----------------------------------------------------------------------------
  #  reverses the animation
  #-----------------------------------------------------------------------------
  def reverse
    if @direction  >  0
      @direction = -1
    elsif @direction < 0
      @direction = +1
    end
  end
  #-----------------------------------------------------------------------------
  #  sets speed of animation
  #-----------------------------------------------------------------------------
  def setSpeed(value)
    @speed = value
  end
  #-----------------------------------------------------------------------------
  #  jumps animation to specific frame
  #-----------------------------------------------------------------------------
  def toFrame(frame)
    # checks if specified string parameter
    if frame.is_a?(String)
      if frame == "last"
        frame = @totalFrames - 1
      else
        frame = 0
      end
    end
    # sets frame
    frame = @totalFrames - 1 if frame >= @totalFrames
    frame = 0 if frame < 0
    @currentIndex = frame
    # draws frame
    @actualBitmap.clear
    x, y, w, h = self.box
    @actualBitmap.stretch_blt(Rect.new(x,y,w,h), @bitmap, Rect.new(@currentIndex*(@width/@scale)+x/@scale, y/@scale, w/@scale, h/@scale))
  end
  #-----------------------------------------------------------------------------
  #  changes the hue of the bitmap
  #-----------------------------------------------------------------------------
  def hue_change(value)
    @bitmap.hue_change(value)
    @changed_hue = true
  end
  def changedHue?; return @changed_hue; end
  #-----------------------------------------------------------------------------
  #  performs animation loop once
  #-----------------------------------------------------------------------------
  def play
    return if self.finished?
    self.update
  end
  #-----------------------------------------------------------------------------
  #  checks if animation is finished
  #-----------------------------------------------------------------------------
  def finished?
    return (@currentIndex >= @totalFrames - 1)
  end
  #-----------------------------------------------------------------------------
  #  fetches the constraints for the sprite
  #-----------------------------------------------------------------------------
  def box
    x = (@constrict.nil? || @width <= @constrict) ? 0 : ((@width-@constrict)/2.0).ceil
    y = (@constrict.nil? || @width <= @constrict) ? 0 : ((@height-@constrict)/2.0).ceil
    w = (@constrict.nil? || @width <= @constrict) ? @width : @constrict
    h = (@constrict.nil? || @width <= @constrict) ? @height : @constrict
    return x, y, w, h
  end
  #-----------------------------------------------------------------------------
  #  performs sprite animation
  #-----------------------------------------------------------------------------
  def update
    return false if @@disableBitmapAnimation
    return false if @actualBitmap.disposed?
    return false if @speed < 1
    case @speed
    # frame skip
    when 2
      @frames = 4
    when 3
      @frames = 5
    else
      @frames = 2
    end
    @frame += 1
    if @frame >= @frames*@frameSkip
      # processes animation speed
      @currentIndex += @direction
      @currentIndex = 0 if @currentIndex >= @totalFrames
      @currentIndex = @totalFrames - 1 if @currentIndex < 0
      @frame = 0
    end
    # updates actual bitmap
    @actualBitmap.clear
    # applies constraint if applicable
    x, y, w, h = self.box
    @actualBitmap.stretch_blt(Rect.new(x,y,w,h), @bitmap, Rect.new(@currentIndex*(@width/@scale)+x/@scale, y/@scale, w/@scale, w/@scale))
  end
  #-----------------------------------------------------------------------------
  #  returns bitmap to original state
  #-----------------------------------------------------------------------------
  def deanimate
    @frame = 0
    @currentIndex = 0
    @actualBitmap.clear
    # applies constraint if applicable
    x, y, w, h = self.box
    @actualBitmap.stretch_blt(Rect.new(x,y,w,h), @bitmap, Rect.new(@currentIndex*(@width/@scale)+x/@scale, y/@scale, w/@scale, h/@scale))
  end
  #-----------------------------------------------------------------------------
end

#-----------------------------------------------------------------------------
#  new method for finding emptiness of top of bitmap
#-----------------------------------------------------------------------------
def findTop(bitmap)
  return 0 if !bitmap
  for i in 1..bitmap.height
    for j in 0..bitmap.width-1
      return i if bitmap.get_pixel(j,bitmap.height-i).alpha>0
    end
  end
  return 0
end

#-----------------------------------------------------------------------------
#  aliasing the old Pokemon Sprite Functions and fixing UI overflow issues
#-----------------------------------------------------------------------------
if !defined?(EliteBattle)

  #-----------------------------------------------------------------------------
  #  All Pokemon Sprite files now return EBSBitmapWrapper
  #-----------------------------------------------------------------------------
  module GameData
    class Species
      def self.front_sprite_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false)
        filename = self.front_sprite_filename(species, form, gender, shiny, shadow)
        return (filename) ? EBSBitmapWrapper.new(filename) : nil
      end

      def self.back_sprite_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false)
        filename = self.back_sprite_filename(species, form, gender, shiny, shadow)
        return (filename) ? EBSBitmapWrapper.new(filename,Settings::BACK_BATTLER_SPRITE_SCALE) : nil
      end

      def self.egg_sprite_bitmap(species, form = 0)
        filename = self.egg_sprite_filename(species, form)
        return (filename) ? EBSBitmapWrapper.new(filename) : nil
      end
    end
  end

  #-----------------------------------------------------------------------------
  #  Accounting for sprite scale in the sprite positioner
  #-----------------------------------------------------------------------------
  class SpritePositioner
    def pbAutoPosition
      species_data = GameData::Species.get(@species)
      old_back_y         = species_data.back_sprite_y
      old_front_y        = species_data.front_sprite_y
      old_front_altitude = species_data.front_sprite_altitude
      bitmap1 = @sprites["pokemon_0"].bitmap
      bitmap2 = @sprites["pokemon_1"].bitmap
      bottom = findBottom(bitmap1)
      top = findTop(bitmap1)
      actual_height = bottom - top
      value = actual_height < (bitmap1.height/2) ? 5 : 3
      new_back_y = (bitmap1.height - bottom + (bottom/value) + 1)/2
      new_front_y = (bitmap2.height - (findBottom(bitmap2) + 1)) / 2
      new_front_y += 4   # Just because
      if new_back_y != old_back_y || new_front_y != old_front_y || old_front_altitude != 0
        species_data.back_sprite_y         = new_back_y
        species_data.front_sprite_y        = new_front_y
        species_data.front_sprite_altitude = 0
        @metricsChanged = true
        refresh
      end
    end
  end

  #-----------------------------------------------------------------------------
  #  Accounting for sprite scale in the sprite positioner
  #-----------------------------------------------------------------------------
  def pbAutoPositionAll
    GameData::Species.each do |sp|
      Graphics.update if sp.id_number % 50 == 0
      bitmap1 = GameData::Species.sprite_bitmap(sp.species, sp.form, nil, nil, nil, true)
      bitmap2 = GameData::Species.sprite_bitmap(sp.species, sp.form)
      if bitmap1 && bitmap1.bitmap   # Player's y
        bottom = findBottom(bitmap1.bitmap)
        top = findTop(bitmap1.bitmap)
        actual_height = bottom - top
        value = actual_height < (bitmap1.bitmap.height/2) ? 5 : 3
        sp.back_sprite_x = 0
        sp.back_sprite_y = (bitmap1.bitmap.height - bottom + (bottom/value) + 1)/2
      end
      if bitmap2 && bitmap2.bitmap   # Foe's y
        sp.front_sprite_x = 0
        sp.front_sprite_y = (bitmap2.height - (findBottom(bitmap2.bitmap) + 1)) / 2
        sp.front_sprite_y += 4   # Just because
      end
      sp.front_sprite_altitude = 0   # Shouldn't be used
      sp.shadow_x              = 0
      sp.shadow_size           = 2
      bitmap1.dispose if bitmap1
      bitmap2.dispose if bitmap2
    end
    GameData::Species.save
    Compiler.write_pokemon
    Compiler.write_pokemon_forms
  end

  #-----------------------------------------------------------------------------
  #  Adding Box constraints to the Pokemon Sprite Bitmap
  #-----------------------------------------------------------------------------
  class PokemonSprite < SpriteWrapper
    def constrict(amt, deanimate = true)
      @_iconbitmap.constrict = amt if @_iconbitmap.respond_to?(:constrict)
      @_iconbitmap.setSpeed(0) if @_iconbitmap.respond_to?(:setSpeed) && deanimate
      @_iconbitmap.deanimate if @_iconbitmap.respond_to?(:deanimate) && deanimate
    end
  end

  #-----------------------------------------------------------------------------
  #  fix misalignment and add box constraints in Pokedex Menu
  #-----------------------------------------------------------------------------
  class PokemonPokedexInfo_Scene
    alias pbUpdateDummyPokemon_gen8 pbUpdateDummyPokemon unless self.method_defined?(:pbUpdateDummyPokemon_gen8)
    def pbUpdateDummyPokemon
      pbUpdateDummyPokemon_gen8
      @sprites["infosprite"].constrict(208)
      @sprites["formfront"].constrict(200) if @sprites["formfront"]
      if @sprites["formback"]
        @sprites["formback"].constrict(200)
        @sprites["formback"].setOffset(PictureOrigin::Center)
        @sprites["formback"].y = @sprites["formfront"].y if @sprites["formfront"]
        if Settings::BACK_BATTLER_SPRITE_SCALE > Settings::FRONT_BATTLER_SPRITE_SCALE
          @sprites["formback"].zoom_x = (Settings::FRONT_BATTLER_SPRITE_SCALE/Settings::BACK_BATTLER_SPRITE_SCALE)
          @sprites["formback"].zoom_y = (Settings::FRONT_BATTLER_SPRITE_SCALE/Settings::BACK_BATTLER_SPRITE_SCALE)
        end
      end
    end
  end

  #-----------------------------------------------------------------------------
  #  Adding Box constraints to the Pokemon Sprite Bitmap in Pokedex info
  #-----------------------------------------------------------------------------
  class PokemonPokedex_Scene
    alias setIconBitmap_gen8 setIconBitmap unless self.method_defined?(:setIconBitmap_gen8)
    def setIconBitmap(*args)
      setIconBitmap_gen8(*args)
      @sprites["icon"].constrict(224)
    end
  end


  #-----------------------------------------------------------------------------
  #  Adding Box constraints to the Pokemon Sprite Bitmap in Storage Menu
  #-----------------------------------------------------------------------------
  class PokemonStorageScene
    alias pbUpdateOverlay_gen8 pbUpdateOverlay unless self.method_defined?(:pbUpdateOverlay_gen8)
    def pbUpdateOverlay(*args)
      pbUpdateOverlay_gen8(*args)
      @sprites["pokemon"].constrict(168)
    end
  end

  #-----------------------------------------------------------------------------
  #  Adding Box constraints to the Pokemon Sprite Bitmap in Summary Screen
  #-----------------------------------------------------------------------------
  class PokemonSummary_Scene
    #-----------------------------------------------------------------------------
    #  restrains the sprite from overflowing out of the sprite area
    #-----------------------------------------------------------------------------
    alias pbStartScene_gen8 pbStartScene unless self.method_defined?(:pbStartScene_gen8)
    def pbStartScene(*args)
      ret = pbStartScene_gen8(*args)
      @sprites["pokemon"].constrict(164, false)
    end
    alias pbChangePokemon_gen8 pbChangePokemon unless self.method_defined?(:pbChangePokemon_gen8)
    def pbChangePokemon
      pbChangePokemon_gen8
      @sprites["pokemon"].constrict(164, false)
    end
  end
end

PluginManager.register({
  :name => "Generation 8 Project for Essentials v19",
  :version => "1.0.0",
  :credits => ["Golisopod User","Vendily","TheToxic",
               "HM100","Aioross","WolfPP","MFilice",
               "lolface","KyureJL","DarrylBD99",
               "Turn20Negate","TheKandinavian",
               "ErwanBeurier","Luka S.J."]
})
