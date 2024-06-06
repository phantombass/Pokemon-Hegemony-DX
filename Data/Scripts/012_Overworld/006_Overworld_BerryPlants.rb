Events.onSpritesetCreate += proc { |_sender,e|
  spriteset = e[0]
  viewport  = e[1]
  map = spriteset.map
  for i in map.events.keys
    if map.events[i].name[/berryplant/i]
      spriteset.addUserSprite(BerryPlantMoistureSprite.new(map.events[i],map,viewport))
      spriteset.addUserSprite(BerryPlantSprite.new(map.events[i],map,viewport))
    end
  end
}



class BerryPlantMoistureSprite
  def initialize(event,map,viewport=nil)
    @event=event
    @map=map
    @light = IconSprite.new(0,0,viewport)
    @light.ox=16
    @light.oy=24
    @oldmoisture=-1   # -1=none, 0=dry, 1=damp, 2=wet
    updateGraphic
    @disposed=false
  end

  def disposed?
    return @disposed
  end

  def dispose
    @light.dispose
    @map=nil
    @event=nil
    @disposed=true
  end

  def updateGraphic
    case @oldmoisture
    when -1 then @light.setBitmap("")
    when 0  then @light.setBitmap("Graphics/Characters/berrytreeDry")
    when 1  then @light.setBitmap("Graphics/Characters/berrytreeDamp")
    when 2  then @light.setBitmap("Graphics/Characters/berrytreeWet")
    end
  end

  def update
    return if !@light || !@event
    newmoisture=-1
    if @event.variable && @event.variable.length>6 && @event.variable[1]
      # Berry was planted, show moisture patch
      newmoisture=(@event.variable[4]>50) ? 2 : (@event.variable[4]>0) ? 1 : 0
    end
    if @oldmoisture!=newmoisture
      @oldmoisture=newmoisture
      updateGraphic
    end
    @light.update
    if (Object.const_defined?(:ScreenPosHelper) rescue false)
      @light.x = ScreenPosHelper.pbScreenX(@event)
      @light.y = ScreenPosHelper.pbScreenY(@event)
      @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
    else
      @light.x = @event.screen_x
      @light.y = @event.screen_y
      @light.zoom_x = 1.0
    end
    @light.zoom_y = @light.zoom_x
    pbDayNightTint(@light)
  end
end



class BerryPlantSprite
  def initialize(event,map,_viewport)
    @event=event
    @map=map
    @oldstage=0
    @disposed=false
    berryData=event.variable
    return if !berryData
    @oldstage=berryData[0]
    @event.character_name=""
    berryData=updatePlantDetails(berryData)
    setGraphic(berryData,true)      # Set the event's graphic
    @event.setVariable(berryData)   # Set new berry data
  end

  def dispose
    @event=nil
    @map=nil
    @disposed=true
  end

  def disposed?
    @disposed
  end

  def update                      # Constantly updates, used only to immediately
    berryData=@event.variable     # change sprite when planting/picking berries
    if berryData
      berryData=updatePlantDetails(berryData) if berryData.length>6
      setGraphic(berryData)
      @event.setVariable(berryData)
    end
  end

  def updatePlantDetails(berryData)
    return berryData if berryData[0]==0
    berryvalues = GameData::BerryPlant.get(berryData[1])
    timeperstage = berryvalues.hours_per_stage * 0.1
    timenow=pbGetTimeNow
    if berryData.length>6
      # Gen 4 growth mechanisms
      # Check time elapsed since last check
      timeDiff=(timenow.to_i-berryData[3])   # in seconds
      return berryData if timeDiff<=0
      berryData[3]=timenow.to_i   # last updated now
      # Mulch modifiers
      dryingrate = berryvalues.drying_per_hour
      maxreplants = GameData::BerryPlant::NUMBER_OF_REPLANTS
      ripestages = 4
      case berryData[7]
      when :GROWTHMULCH
        timeperstage = (timeperstage * 0.75).to_i
        dryingrate = (dryingrate * 1.5).ceil
      when :DAMPMULCH
        timeperstage = (timeperstage * 1.25).to_i
        dryingrate = (dryingrate * 0.5).floor
      when :GOOEYMULCH
        maxreplants = (maxreplants * 1.5).ceil
      when :STABLEMULCH
        ripestages = 6
      end
      # Cycle through all replants since last check
      loop do
        secondsalive=berryData[2]
        growinglife=(berryData[5]>0) ? 3 : 4 # number of growing stages
        numlifestages=growinglife+ripestages # number of growing + ripe stages
        # Should replant itself?
        if secondsalive+timeDiff>=timeperstage*numlifestages
          # Should replant
          if berryData[5]>=maxreplants   # Too many replants
            return [0,0,0,0,0,0,0,0]
          end
          # Replant
          berryData[0]=2   # replants start in sprouting stage
          berryData[2]=0   # seconds alive
          berryData[5]+=1  # add to replant count
          berryData[6]=0   # yield penalty
          timeDiff-=(timeperstage*numlifestages-secondsalive)
        else
          break
        end
      end
      # Update current stage and dampness
      if berryData[0]>0
        # Advance growth stage
        oldlifetime=berryData[2]
        newlifetime=oldlifetime+timeDiff
        if berryData[0]<5
          berryData[0]=1+(newlifetime/timeperstage).floor
          berryData[0]+=1 if berryData[5]>0   # replants start at stage 2
          berryData[0]=5 if berryData[0]>5
        end
        # Update the "seconds alive" counter
        berryData[2]=newlifetime
        # Reduce dampness, apply yield penalty if dry
        growinglife=(berryData[5]>0) ? 3 : 4 # number of growing stages
        oldhourtick=(oldlifetime/3600).floor
        newhourtick=(([newlifetime,timeperstage*growinglife].min)/3600).floor
        (newhourtick-oldhourtick).times do
          if berryData[4]>0
            berryData[4]=[berryData[4]-dryingrate,0].max
          else
            berryData[6]+=1
          end
        end
      end
    else
      # Gen 3 growth mechanics
      loop do
        if berryData[0]>0 && berryData[0]<5
          levels=0
          # Advance time
          timeDiff=(timenow.to_i-berryData[3]) # in seconds
          if timeDiff>=timeperstage
            levels+=1
            if timeDiff>=timeperstage*2
              levels+=1
              if timeDiff>=timeperstage*3
                levels+=1
                if timeDiff>=timeperstage*4
                  levels+=1
                end
              end
            end
          end
          levels=5-berryData[0] if levels>5-berryData[0]
          break if levels==0
          berryData[2]=false                  # not watered this stage
          berryData[3]+=levels*timeperstage   # add to time existed
          berryData[0]+=levels                # increase growth stage
          berryData[0]=5 if berryData[0]>5
        end
        if berryData[0]>=5
          # Advance time
          timeDiff=(timenow.to_i-berryData[3])   # in seconds
          if timeDiff>=timeperstage*4   # ripe for 4 times as long as a stage
            # Replant
            berryData[0]=2                      # replants start at stage 2
            berryData[2]=false                  # not watered this stage
            berryData[3]+=timeperstage*4        # add to time existed
            berryData[4]=0                      # reset total waterings count
            berryData[5]+=1                     # add to replanted count
            if berryData[5] > GameData::BerryPlant::NUMBER_OF_REPLANTS   # Too many replants
              berryData = [0,0,false,0,0,0]
              break
            end
          else
            break
          end
        end
      end
      # If raining, automatically water the plant
      if berryData[0] > 0 && berryData[0] < 5 && $game_screen &&
         GameData::Weather.get($game_screen.weather_type).category == :Rain
        if berryData[2] == false
          berryData[2] = true
          berryData[4] += 1
        end
      end
    end
    return berryData
  end

  def setGraphic(berryData,fullcheck=false)
    return if !berryData || (@oldstage==berryData[0] && !fullcheck)
    case berryData[0]
    when 0
      @event.character_name=""
    when 1
      @event.character_name="berrytreeplanted"   # Common to all berries
      @event.turn_down
    else
      filename=sprintf("berrytree%s",GameData::Item.get(berryData[1]).id.to_s)
      if pbResolveBitmap("Graphics/Characters/"+filename)
        @event.character_name=filename
        case berryData[0]
        when 2 then @event.turn_down    # X sprouted
        when 3 then @event.turn_left    # X taller
        when 4 then @event.turn_right   # X flowering
        when 5 then @event.turn_up      # X berries
        end
      else
        @event.character_name="Object ball"
      end
      if @oldstage!=berryData[0] && berryData.length>6   # Gen 4 growth mechanisms
        $scene.spriteset.addUserAnimation(Settings::PLANT_SPARKLE_ANIMATION_ID,@event.x,@event.y,false,1) if $scene.spriteset
      end
    end
    @oldstage=berryData[0]
  end
end



def pbBerryPlant
  pbMessage(_INTL("The ground is dried out and unusable..."))
end

def pbPickBerry(berry, qty = 1)
  interp=pbMapInterpreter
  thisEvent=interp.get_character(0)
  berryData=interp.getVariable
  berry=GameData::Item.get(berry)
  case berry.id
  when :CUSTAPBERRY,:ENIGMABERRY,:IAPAPABERRY,:WIKIBERRY,:FIGYBERRY,:AGUAVBERRY,:MAGOBERRY,:JABOCABERRY,:ROWAPBERRY
    qty = rand(3) + 1
  when :ORANBERRY,:CHERIBERRY,:RAWSTBERRY,:PERSIMBERRY,:PECHABERRY,:ASPEARBERRY,:CHESTOBERRY
    qty = rand(11) + 10
  else
    qty = rand(6) + 10
  end
  itemname=(qty>1) ? berry.name_plural : berry.name
  if qty>1
    message=_INTL("There are {1} \\c[1]{2}\\c[0]!",qty,itemname)
  else
    message=_INTL("There is 1 \\c[1]{1}\\c[0]!",itemname)
  end
  pbMessage(message)
  if !$PokemonBag.pbCanStore?(berry,qty)
    pbMessage(_INTL("Too bad...\nThe Bag is full..."))
    return
  end
  $PokemonBag.pbStoreItem(berry,qty)
  playBerryPickME
  if qty>1
    pbMessage(_INTL("You picked the {1} \\c[1]{2}\\c[0].\\wtnp[30]",qty,itemname))
  else
    pbMessage(_INTL("You picked the \\c[1]{1}\\c[0].\\wtnp[30]",itemname))
  end
  pocket = berry.pocket
  pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0] in the <icon=bagPocket{3}>\\c[1]{4}\\c[0] Pocket.\1",
     $Trainer.name,itemname,pocket,PokemonBag.pocketNames()[pocket]))
  if Settings::NEW_BERRY_PLANTS
    pbMessage(_INTL("The soil returned to its soft and earthy state."))
    berryData=[0,nil,0,0,0,0,0,0]
  else
    pbMessage(_INTL("The soil returned to its soft and loamy state."))
    berryData=[0,nil,false,0,0,0]
  end
  interp.setVariable(berryData)
  pbSetSelfSwitch(thisEvent.id,"A",true)
end
