# The function to call to open the editor
def pbTilesetEditor
  TilesetEditor.new
end

# Aliasing the Debug menu to add this editor
#alias ct_debug_menu_cmds pbDebugMenuCommands
#def pbDebugMenuCommands(showall = true)
#  cmds = ct_debug_menu_cmds(showall)
#  cmds.add("editorsmenu","tilesets",_INTL("Edit Common Tiles"),
#      _INTL("Edit the common events of tiles."))
#  return cmds
#end

DebugMenuCommands.register("tilesets", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Edit Common Tiles"),
  "description" => _INTL("Edit the common events of tiles."),
  "effect"      => proc {
    pbTilesetEditor
  }
})

# Aliasing the Debug menu to add this editor
#alias ct_debug_actions pbDebugMenuActions
#def pbDebugMenuActions(cmd = "", sprites = nil, viewport = nil)
#  if cmd == "tilesets"
#    pbFadeOutIn(99999) { pbTilesetEditor }
#    return
#  end
#  ct_debug_actions(cmd, sprites, viewport)
#end

# RPG::Tileset#common_events is what stores the common events
module RPG
  class Tileset
    attr_writer :common_events

    alias common_event_init initialize
    def initialize(*args)
      common_event_init(*args)
      @common_events ||= [nil] * (@priorities.xsize - 384)
    end

    def common_events
      @common_events ||= [nil] * (@priorities.xsize - 384)
      return @common_events
    end
  end
end

# Returns this map's tileset
class Game_Map
  def tileset
    return $data_tilesets[@map.tileset_id]
  end
end

# Overwrite Game_Player#check_event_trigger_there to call any common events
class Game_Player
  alias ct_check_there check_event_trigger_there
  def check_event_trigger_there(triggers)
    ret = ct_check_there(triggers)
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    return ret if $game_player.map.events.any? { |e| e[1].x == new_x && e[1].y == new_y }
    return ret unless $game_map.valid?(new_x, new_y)
    common_events = []
    for i in [2, 1, 0]
      tile_id = $game_player.map.data[new_x, new_y, i]
      tile_id -= 384
      if $game_player.map.tileset.common_events[tile_id]
        for j in 0...$game_player.map.tileset.common_events[tile_id].size
          common_events << $game_player.map.tileset.common_events[tile_id][j]
        end
      end
    end
    for c in common_events
      pbCommonEvent(c)
    end
    return ret
  end
end

class TilesetEditor
  SelectorColor = Color.new(239,52,52) # The color of the tile selector
  SelectorWidth = 3 # How many pixels the tile selector should be wide

  def initialize
    # Initialize a new Viewport for all graphical elements
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    # Black overlay
    @blk = Sprite.new(@viewport)
    @blk.bmp(-1,-1)
    @blk.bmp.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0))
    @blk.z = -1
    # Load all tilesets from Data/Tilesets
    @data = File.open('Data/Tilesets.rxdata', 'rb') do |f|
      next Marshal.load(f)[1..-1] # Ignore the first entry, nil
    end
    # Which tileset is selected
    @sel = 0
    loop do
      @sel = choose_tileset # Pick a tileset
      if @sel == -1
        if Kernel.pbConfirmMessage("Save before exiting?")
          File.delete('Data/Tilesets.rxdata') if File.file?('Data/Tilesets.rxdata')
          f = File.new('Data/Tilesets.rxdata', 'wb')
          Marshal.dump([nil].concat(@data), f)
          f.close
          Kernel.pbMessage("For the changes to take effect, please close RPG" +
              " Maker <b>without saving</b> the project.")
        end
        break
      end
      load_tileset # Load the sprite, initialize a selector sprite and call main
    end
    @blk.dispose
    @blk = nil
    @viewport.dispose
    @viewport = nil
  end

  # Picks a tileset from all tilesets
  def choose_tileset
    cmds = []
    @data.each_with_index { |e,i| cmds << "#{i + 1}: #{e.name}" }
    Kernel.pbMessage("Choose a Tileset to edit.", cmds, -1)
  end

  # Gets the array of terrain tags per tile
  def get_terrain_tags(tileset = @data[@sel])
    tags = tileset.terrain_tags
    new = []
    for x in 384...tags.xsize
      new << tags[x]
    end
    return new
  end

  # Gets the array of priority values per tile
  def get_priorities(tileset = @data[@sel])
    pr = tileset.priorities
    new = []
    for x in 384...pr.xsize
      new << pr[x]
    end
    return new
  end

  def load_tileset(tileset = @data[@sel])
    # Create the tileset's sprite
    @tileset = Sprite.new(@viewport)
    @tileset.bmp("Graphics/Tilesets/" + tileset.tileset_name)
    @selector = make_selector
    @current = Sprite.new(@viewport)
    @current.bmp(@tileset.bmp)
    @current.src_rect.width = 32
    @current.src_rect.height = 32
    @current.zoom_x = 2
    @current.zoom_y = 2
    @current.x = @tileset.bmp.width + (Graphics.width - @tileset.bmp.width) / 2
    @current.y = Graphics.height / 2
    @current.x -= 32
    @current.y -= 32
    @x = 0
    @y = 0
    @txt = TextSprite.new(@viewport,[
        ["Terrain Tag: #{get_terrain_tags[0]}", @current.x + 32, @current.y + 70,
            2, Color.new(255,255,255)],
        ["Priority: #{get_priorities[0]}", @current.x + 32, @current.y + 100,
            2, Color.new(255,255,255)],
        ["Common Events: #{@data[@sel].common_events[0].size rescue 0}",
            @current.x + 32, @current.y + 130, 2, Color.new(255,255,255)],
        ["Tile ID: #{@x + 8 * @y + 384}", @current.x + 32, @current.y + 160, 2, Color.new(255,255,255)]
    ])
    loop do
      Graphics.update
      Input.update
      old_x = @x
      old_y = @y
      refresh = false
      if Input.repeat?(Input::RIGHT) && @x % 8 < 7
        @selector.x += 32
        @x += 1
      end
      if Input.repeat?(Input::LEFT) && @x % 8 > 0
        @selector.x -= 32
        @x -= 1
      end
      if Input.repeat?(Input::DOWN) && @y < @tileset.bmp.height / 32 - 1
        if @selector.y >= Graphics.height - 32
          @tileset.y -= 32
        else
          @selector.y += 32
        end
        @y += 1
      end
      if Input.repeat?(Input::UP) && @y > 0
        if @selector.y <= 0
          @tileset.y += 32
        else
          @selector.y -= 32
        end
        @y -= 1
      end
      if Input.trigger?(Input::C)
        options = []
        options << "Add Common Event"
        options << "Show Common events" if (@data[@sel].common_events[@x + @y * 8].size > 0 rescue false)
        options << "Cancel"
        cmd = Kernel.pbMessage("What do want to do with this tile?", options, 2)
        next if cmd == -1
        if cmd == 0 # Add Common Event
          params = ChooseNumberParams.new
          params.setMaxDigits(3)
          id = Kernel.pbMessageChooseNumber("Enter the ID of the common event you'd like to assign " +
              "to this tile.", params)
          @data[@sel].common_events[@x + @y * 8] ||= []
          @data[@sel].common_events[@x + @y * 8] << id
          refresh = true
        elsif cmd == 1 && options.size == 3 # Show Common events
          display = @data[@sel].common_events[@x + @y * 8].map do |e|
            next "#{e}: #{$data_common_events[e].name}"
          end
          cmd = Kernel.pbMessage("These are all common events assigned to this event.",
              display, -1)
          break if cmd == -1
          if Kernel.pbConfirmMessage("Do you want to delete common event \"<b>#{display[cmd]}</b>\"?")
            @data[@sel].common_events[@x + @y * 8][cmd] = nil
            @data[@sel].common_events[@x + @y * 8].compact!
            refresh = true
          end
        end
      end
      if @x != old_x || @y != old_y || refresh
        @current.src_rect.x = @x * 32
        @current.src_rect.y = @y * 32
        @txt.clear
        @txt.draw([
            ["Terrain Tag: #{get_terrain_tags[@x + @y * 8]}", @current.x + 32,
                @current.y + 70, 2, Color.new(255,255,255)],
            ["Priority: #{get_priorities[@x + @y * 8]}", @current.x + 32,
                @current.y + 100, 2, Color.new(255,255,255)],
            ["Common Events: #{@data[@sel].common_events[@x + @y * 8].size rescue 0}",
                @current.x + 32, @current.y + 130, 2, Color.new(255,255,255)],
            ["Tile ID: #{@x + 8 * @y + 384}", @current.x + 32, @current.y + 160, 2, Color.new(255,255,255)]
        ])
      end
      break if Input.trigger?(Input::B)
    end
    @tileset.dispose
    @tileset = nil
    @selector.dispose
    @selector = nil
    @current.dispose
    @current = nil
    @txt.dispose
    @txt = nil
    Input.update
  end

  # Creates a sprite used as the selector and returns it
  def make_selector
    selector = Sprite.new(@viewport)
    selector.bmp(32,32)
    selector.bmp.fill_rect(0,0,32,SelectorWidth,SelectorColor)
    selector.bmp.fill_rect(0,0,SelectorWidth,32,SelectorColor)
    selector.bmp.fill_rect(32 - SelectorWidth,0,32,32,SelectorColor)
    selector.bmp.fill_rect(0,32- SelectorWidth,32,32,SelectorColor)
    return selector
  end
end
