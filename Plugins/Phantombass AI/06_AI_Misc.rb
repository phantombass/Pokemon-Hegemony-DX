def deep_copy(obj)
  Marshal.load(Marshal.dump(obj))
end

def pbHashConverter(mod,hash)
  newhash = {}
  hash.each {|key, value|
      for i in value
          newhash[mod.const_get(i.to_sym)]=key
      end
  }
  return newhash
end

def pbHashForwardizer(hash) #one-stop shop for your hash debackwardsing needs!
  return if !hash.is_a?(Hash)
  newhash = {}
  hash.each {|key, value|
      for i in value
          newhash[i]=key
      end
  }
  return newhash
end

def arrayToConstant(mod,array)
  newarray = []
  for symbol in array
    const = mod.const_get(symbol.to_sym) rescue nil
    newarray.push(const) if const
  end
  return newarray
end

def hashToConstant(mod,hash)
  for key in hash.keys
    const = mod.const_get(hash[key].to_sym) rescue nil
    hash.merge!(key=>const) if const
  end
  return hash
end

def hashArrayToConstant(mod,hash)
  for key in hash.keys
    array = hash[key]
    newarray = arrayToConstant(mod,array)
    hash.merge!(key=>newarray) if !newarray.empty?
  end
  return hash
end

Essentials::ERROR_TEXT += "[Phantombass AI v#{Phantombass_AI::VERSION}\r\n"

=begin
STATUSTEXTS = ["status", "sleep", "poison", "burn", "paralysis", "ice"]
STATSTRINGS = ["HP", "Attack", "Defense", "Speed", "Sp. Attack", "Sp. Defense"]

class PBStuff
  #rejuv stuff while we work out the kinks
  #massive arrays of stuff that no one wants to see
  #List of Abilities that either prevent or co-opt Intimidate
  TRACEABILITIES = arrayToConstant(GameData::Ability,[:PROTEAN,:CONTRARY,:INTIMIDATE, :WONDERGUARD,:MAGICGUARD,
    :SWIFTSWIM,:SLUSHRUSH, :SANDRUSH,:TELEPATHY,:SURGESURFER, :SOLARPOWER,:DRYSKIN,:DOWNLOAD, :LEVITATE,
    :LIGHTNINGROD,:MOTORDRIVE, :VOLTABSORB,:FLASHFIRE,:MAGMAARMOR, :ADAPTABILITY,:DEFIANT,:COMPETITIVE, 
    :PRANKSTER,:SPEEDBOOST,:MULTISCALE, :SHADOWSHIELD,:SAPSIPPER,:FURCOAT, :FLUFFY,:MAGICBOUNCE,
    :REGENERATOR, :DAZZLING,:QUEENLYMAJESTY,:SOUNDPROOF, :TECHNICIAN,:SPEEDBOOST,:STEAMENGINE, 
    :ICESCALES,:BEASTBOOST,:SHEDSKIN, :CLEARBODY,:WHITESMOKE,:MOODY, :THICKFAT,:STORMDRAIN,
    :SIMPLE,:PUREPOWER,:MARVELSCALE,:STURDY,:MEGALAUNCHER,:LIBERO,:SHEERFORCE,:UNAWARE,:CHLOROPHYLL])
  NEGATIVEABILITIES = arrayToConstant(GameData::Ability,[:TRUANT,:DEFEATIST,:SLOWSTART,:KLUTZ,:STALL,:GORILLATACTICS,:RIVALRY])

#Standardized lists of moves or abilities which are sometimes called
  #Blacklisted abilities USUALLY can't be copied.
###--------------------------------------ABILITYBLACKLIST-------------------------------------------------------###
ABILITYBLACKLIST = arrayToConstant(GameData::Ability,[:MULTITYPE, :COMATOSE,:DISGUISE, :SCHOOLING, 
  :RKSSYSTEM, :IMPOSTER,:SHIELDSDOWN, :POWEROFALCHEMY,:RECEIVER,:TRACE, :FORECAST, :FLOWERGIFT,
  :ILLUSION,:WONDERGUARD, :ZENMODE, :STANCECHANGE,:POWERCONSTRUCT,:ICEFACE,:MULTITOOL])

###--------------------------------------FIXEDABILITIES---------------------------------------------------------###
#Fixed abilities USUALLY can't be changed.
FIXEDABILITIES = arrayToConstant(GameData::Ability,[:MULTITYPE, :ZENMODE, :STANCECHANGE, :SCHOOLING, 
  :COMATOSE,:SHIELDSDOWN, :DISGUISE, :RKSSYSTEM, :POWERCONSTRUCT,:ICEFACE, :GULPMISSILE])

#Standardized lists of moves with similar purposes/characteristics
#(mostly just "stuff that gets called together")

###--------------------------------------UNFREEZEMOVE-----------------------------------------------------------###
UNFREEZEMOVE = arrayToConstant(GameData::Move,[:FLAMEWHEEL,:SACREDFIRE,:FLAREBLITZ, :FUSIONFLARE, 
  :SCALD, :STEAMERUPTION, :BURNUP])

###--------------------------------------SETUPMOVE--------------------------------------------------------------###
SETUPMOVE = arrayToConstant(GameData::Move,[:SWORDSDANCE, :DRAGONDANCE, :CALMMIND, :WORKUP,:NASTYPLOT, 
  :TAILGLOW,:BELLYDRUM, :BULKUP,:COIL,:CURSE, :GROWTH, :HONECLAWS, :QUIVERDANCE, :SHELLSMASH])

###--------------------------------------PROTECTMOVE------------------------------------------------------------###
PROTECTMOVE = arrayToConstant(GameData::Move,[:PROTECT, :DETECT,:KINGSSHIELD, :SPIKYSHIELD, :BANEFULBUNKER])

###--------------------------------------PROTECTIGNORINGMOVE----------------------------------------------------###
PROTECTIGNORINGMOVE = arrayToConstant(GameData::Move,[:FEINT, :HYPERSPACEHOLE,:HYPERSPACEFURY, :SHADOWFORCE, :PHANTOMFORCE])

###--------------------------------------SCREENBREAKERMOVE------------------------------------------------------###
SCREENBREAKERMOVE = arrayToConstant(GameData::Move,[:DEFOG, :BRICKBREAK,:PSYCHICFANGS])

###--------------------------------------CONTRARYBAITMOVE-------------------------------------------------------###
CONTRARYBAITMOVE = arrayToConstant(GameData::Move,[:SUPERPOWER,:OVERHEAT,:DRACOMETEOR, :LEAFSTORM, 
  :FLEURCANNON, :PSYCHOBOOST])

###--------------------------------------TWOTURNAIRMOVE---------------------------------------------------------###
TWOTURNAIRMOVE = arrayToConstant(GameData::Move,[:BOUNCE,:FLY, :SKYDROP])

###--------------------------------------PIVOTMOVE--------------------------------------------------------------###
PIVOTMOVE = arrayToConstant(GameData::Move,[:UTURN, :VOLTSWITCH,:PARTINGSHOT,:CHILLYRECEPTION,:SHEDTAIL,:FLIPTURN,:TELEPORT])

###--------------------------------------DANCEMOVE--------------------------------------------------------------###
DANCEMOVE = arrayToConstant(GameData::Move,[:QUIVERDANCE, :DRAGONDANCE, :FIERYDANCE, 
  :FEATHERDANCE,:PETALDANCE,:SWORDSDANCE, :TEETERDANCE, :LUNARDANCE,:REVELATIONDANCE])

###--------------------------------------BULLETMOVE-------------------------------------------------------------###
BULLETMOVE = arrayToConstant(GameData::Move,[:ACIDSPRAY, :AURASPHERE,:BARRAGE, :BULLETSEED,
  :EGGBOMB, :ELECTROBALL, :ENERGYBALL, :FOCUSBLAST,:GYROBALL,:ICEBALL, :MAGNETBOMB, 
  :MISTBALL,:MUDBOMB, :OCTAZOOKA, :ROCKWRECKER, :SEARINGSHOT, :SEEDBOMB,:SHADOWBALL,
  :SLUDGEBOMB, :WEATHERBALL, :ZAPCANNON, :BEAKBLAST])

###--------------------------------------BITEMOVE---------------------------------------------------------------###
BITEMOVE = arrayToConstant(GameData::Move,[:BITE,:CRUNCH,:THUNDERFANG, :FIREFANG,:ICEFANG,
  :POISONFANG,:HYPERFANG, :PSYCHICFANGS, :COSMICFANGS, :DRACOFANGS, :IRONFANGS, :LEECHLIFE])

###--------------------------------------PHASEMOVE--------------------------------------------------------------###
PHASEMOVE = arrayToConstant(GameData::Move,[:ROAR,:WHIRLWIND, :CIRCLETHROW, :DRAGONTAIL,:YAWN,:PERISHSONG])

###--------------------------------------SCREENMOVE-------------------------------------------------------------###
SCREENMOVE = arrayToConstant(GameData::Move,[:LIGHTSCREEN, :REFLECT, :AURORAVEIL])

###--------------------------------------OHKOMOVE-------------------------------------------------------------###
OHKOMOVE = arrayToConstant(GameData::Move,[:FISSURE,:SHEERCOLD,:GUILLOTINE,:HORNDRILL])

#Moves that inflict statuses with at least a 50% of hitting
###--------------------------------------BURNMOVE---------------------------------------------------------------###
BURNMOVE = arrayToConstant(GameData::Move,[:WILLOWISP, :SACREDFIRE,:INFERNO])

###--------------------------------------PARAMOVE---------------------------------------------------------------###
PARAMOVE = arrayToConstant(GameData::Move,[:THUNDERWAVE, :STUNSPORE, :GLARE, :NUZZLE,:ZAPCANNON])

###--------------------------------------SLEEPMOVE--------------------------------------------------------------###
SLEEPMOVE = arrayToConstant(GameData::Move,[:SPORE, :SLEEPPOWDER, :HYPNOSIS, :DARKVOID,:GRASSWHISTLE,
  :LOVELYKISS,:SING, :YAWN])

###--------------------------------------POISONMOVE-------------------------------------------------------------###
POISONMOVE = arrayToConstant(GameData::Move,[:TOXIC, :POISONPOWDER,:POISONGAS, :TOXICTHREAD])

###--------------------------------------CONFUMOVE--------------------------------------------------------------###
CONFUMOVE = arrayToConstant(GameData::Move,[:CONFUSERAY,:SUPERSONIC,:FLATTER, :SWAGGER, :SWEETKISS, 
  :TEETERDANCE, :CHATTER, :DYNAMICPUNCH])

#all the status inflicting moves
###--------------------------------------STATUSCONDITIONMOVE----------------------------------------------------###
STATUSCONDITIONMOVE = arrayToConstant(GameData::Move,[:WILLOWISP, :DARKVOID,:GRASSWHISTLE, :HYPNOSIS,
  :LOVELYKISS,:SING,:SLEEPPOWDER, :SPORE, :YAWN,:POISONGAS, :POISONPOWDER, :TOXIC, :NUZZLE,
  :STUNSPORE, :THUNDERWAVE, :DEEPFREEZE])


#Odd groups of moves/effects with similar behavior
###--------------------------------------HEALFUNCTIONS----------------------------------------------------------###
HEALFUNCTIONS =["0D5","0D6","0D7","0D8","0D9","0DD","0DE","0DF",
  "0E3","0E4","114","139","158","162","169","16C","172"]

###--------------------------------------RATESHARERS------------------------------------------------------------###
RATESHARERS = arrayToConstant(GameData::Move,[:PROTECT, :DETECT,:QUICKGUARD, :WIDEGUARD, :ENDURE,
  :KINGSSHIELD, :SPIKYSHIELD, :BANEFULBUNKER, :CRAFTYSHIELD, :OBSTRUCT])

###--------------------------------------INVULEFFECTS-----------------------------------------------------------###
INVULEFFECTS = arrayToConstant(PBEffects,[:Protect, :Endure,:Obstruct, :KingsShield, :SpikyShield, :MatBlock, 
  :BanefulBunker])

###--------------------------------------POWDERMOVES------------------------------------------------------------###
POWDERMOVES = arrayToConstant(GameData::Move,[:COTTONSPORE, :SLEEPPOWDER, :STUNSPORE, :SPORE, :RAGEPOWDER,
  :POISONPOWDER,:POWDER])

###--------------------------------------AIRHITMOVES------------------------------------------------------------###
AIRHITMOVES = arrayToConstant(GameData::Move,[:THUNDER, :HURRICANE, :GUST, :TWISTER, :SKYUPPERCUT, 
  :SMACKDOWN, :THOUSANDARROWS])

# Blacklist stuff
###--------------------------------------NOCOPYMOVE-------------------------------------------------------------###
NOCOPYMOVE = arrayToConstant(GameData::Move,[:ASSIST,:COPYCAT, :MEFIRST, :METRONOME, :MIMIC, :MIRRORMOVE,
  :NATUREPOWER, :SHELLTRAP, :SKETCH,:SLEEPTALK, :STRUGGLE, :BEAKBLAST, :FOCUSPUNCH,:TRANSFORM, 
  :BELCH, :CHATTER, :KINGSSHIELD, :BANEFULBUNKER, :BESTOW, :COUNTER, :COVET, :DESTINYBOND, :DETECT, 
  :ENDURE,:FEINT, :FOLLOWME,:HELPINGHAND, :MATBLOCK,:MIRRORCOAT,:PROTECT, :RAGEPOWDER, :SNATCH,
  :SPIKYSHIELD, :SPOTLIGHT, :SWITCHEROO, :THIEF, :TRICK])

###--------------------------------------NOAUTOMOVE-------------------------------------------------------------###
NOAUTOMOVE = arrayToConstant(GameData::Move,[:ASSIST,:COPYCAT, :MEFIRST, :METRONOME, :MIMIC, :MIRRORMOVE,
  :NATUREPOWER, :SHELLTRAP, :SKETCH,:SLEEPTALK, :STRUGGLE])

###--------------------------------------DELAYEDMOVE------------------------------------------------------------###
DELAYEDMOVE = arrayToConstant(GameData::Move,[:BEAKBLAST, :FOCUSPUNCH, :SHELLTRAP])

###--------------------------------------TWOTURNMOVE------------------------------------------------------------###
TWOTURNMOVE = arrayToConstant(GameData::Move,[:BOUNCE,:DIG, :DIVE, :FLY, :PHANTOMFORCE,:SHADOWFORCE, :SKYDROP])

###--------------------------------------FORCEOUTMOVE-----------------------------------------------------------###
FORCEOUTMOVE = arrayToConstant(GameData::Move,[:CIRCLETHROW, :DRAGONTAIL,:ROAR, :WHIRLWIND])
###--------------------------------------REPEATINGMOVE----------------------------------------------------------###
REPEATINGMOVE = arrayToConstant(GameData::Move,[:ICEBALL, :OUTRAGE, :PETALDANCE, :ROLLOUT, :THRASH])

###--------------------------------------CHARGEMOVE-------------------------------------------------------------###
CHARGEMOVE = arrayToConstant(GameData::Move,[:BIDE, :GEOMANCY,:RAZORWIND, :SKULLBASH,:SKYATTACK,:SOLARBEAM, 
  :SOLARBLADE, :FREEZESHOCK, :ICEBURN, :METEORSHOWER])
end

=end
class PokeBattle_Battle
  def typesInverted?
    return $PokemonTemp.battleRules["inverseBattle"] == true
  end
end

module Effectiveness
  def get_resisted_types(type)
    resisted = []
    for i in types
      resisted.push(i) if self.resistant_type?(i,type)
    end
    return resisted
  end

  def get_super_effective_types(type)
    superE = []
    for i in types
      superE.push(i) if self.super_effective_type?(i,type)
    end
    return superE
  end
end
