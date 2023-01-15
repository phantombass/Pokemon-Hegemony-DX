Settings::TIME_SHADING = false
Settings::MECHANICS_GENERATION = 8
Settings::SPEECH_WINDOWSKINS = [
#    "speech hgss 1",
#    "speech hgss 2",
#    "speech hgss 3",
#    "speech hgss 4",
#    "speech hgss 5",
#    "speech hgss 6",
#    "speech hgss 7",
#    "speech hgss 8",
#    "speech hgss 9",
#    "speech hgss 10",
#    "speech hgss 11",
#    "speech hgss 12",
#    "speech hgss 13",
#    "speech hgss 14",
#    "speech hgss 15",
#    "speech hgss 16",
#    "speech hgss 17",
#    "speech hgss 18",
#    "speech hgss 19",
#    "speech hgss 20",
#    "speech pl 18",
    "frlgtextskin"
  ]
Settings::MENU_WINDOWSKINS = [
#    "choice 1",
#    "choice 2",
#    "choice 3",
#    "choice 4",
#    "choice 5",
#    "choice 6",
#    "choice 7",
#    "choice 8",
#    "choice 9",
#    "choice 10",
#    "choice 11",
#    "choice 12",
#    "choice 13",
#    "choice 14",
#    "choice 15",
#    "choice 16",
#    "choice 17",
#    "choice 18",
#    "choice 19",
#    "choice 20",
#    "choice 21",
#    "choice 22",
#    "choice 23",
#    "choice 24",
#    "choice 25",
#    "choice 26",
#    "choice 27",
#    "choice 28",
    "frlgtextskin"
  ]
Settings::FIELD_MOVES_COUNT_BADGES = false
Settings::MAXIMUM_LEVEL = 120

module Settings
  def self.storage_creator_name
    return _INTL("Yule")
  end

  def self.pokedex_names
    return [
      [_INTL("Parthenia Pokédex"), 0],
      [_INTL("Armadia Pokédex"), 1],
      _INTL("National Pokédex")
    ]
  end
  GEN_9_SNOW = true
end
