def pbGetMachineFromMove(moveid)
  GameData::Item.each do |item|
    return item if item.is_machine? && item.move == moveid
  end
end

def pbGetFormattedRegionalNumber(dexid,species)
  number = pbGetRegionalNumber(-1,species)
  ret = ""
  if number < 100
    ret << "0"
  end
  if number < 10
    ret << "0"
  end
  ret << "#{number}"
  return ret
end

def pbDexFormat(dexnum)
  ret = ""
  if dexnum < 100
    ret << "0"
  end
  if dexnum < 10
    ret << "0"
  end
  ret << "#{dexnum}"
  return ret
end

SHRINEMONS = [
  :ARTICUNO,
  :ZAPDOS,
  :MOLTRES,
  :RAIKOU,
  :ENTEI,
  :SUICUNE,
  :UXIE,
  :MESPRIT,
  :AZELF,
  :CRESSELIA,
  :DARKRAI,
  :COBALION,
  :TERRAKION,
  :VIRIZION,
  :TORNADUS,
  :THUNDURUS,
  :LANDORUS,
  :REGIROCK,
  :REGICE,
  :REGISTEEL,
  :REGIELEKI,
  :REGIDRAGO,
  :TAPUKOKO,
  :TAPULELE,
  :TAPUBULU,
  :TAPUFINI,
  :MEWTWO,
  :HEATRAN,
  :HOOH,
  :LUGIA,
  :RAYQUAZA,
  :KYOGRE,
  :GROUDON,
  :DIALGA,
  :PALKIA,
  :GIRATINA,
  :REGIGIGAS,
  :KYUREM,
  :RESHIRAM,
  :ZEKROM,
  :ZYGARDE,
  :XERNEAS,
  :YVELTAL,
  :ZACIAN,
  :ZAMAZENTA,
  :ETERNATUS,
  :NIHILEGO,
  :BUZZWOLE,
  :PHEROMOSA,
  :XURKITREE,
  :CELESTEELA,
  :KARTANA,
  :GUZZLORD,
  :POIPOLE,
  :STAKATAKA,
  :BLACEPHALON,
  :ARCEUS,
  :MEW,
  :CELEBI,
  :JIRACHI,
  :DEOXYS,
  :SHAYMIN,
  :MANAPHY,
  :VICTINI,
  :KELDEO,
  :MELOETTA,
  :GENESECT,
  :MAGEARNA,
  :MELTAN,
  :SPECTRIER,
  :GLASTRIER,
  :ZARUDE,
  :MARSHADOW,
  :VOLCANION,
  :COSMOG,
  :COSMOG_1,
  :CALYREX,
  :ZERAORA,
  :HOOPA
]

MININGITEMS = [
  :FOSSILIZEDBIRD, :FOSSILIZEDDRAKE, :FOSSILIZEDFISH, :FOSSILIZEDDINO, :DOMEFOSSIL, :HELIXFOSSIL, :HELIXFOSSIL, :HELIXFOSSIL, :HELIXFOSSIL, :OLDAMBER, :OLDAMBER, :ROOTFOSSIL, :ROOTFOSSIL, :ROOTFOSSIL, :ROOTFOSSIL, :SKULLFOSSIL, :ARMORFOSSIL, :CLAWFOSSIL, :CLAWFOSSIL, :CLAWFOSSIL, :CLAWFOSSIL, :FIRESTONE, :WATERSTONE, :THUNDERSTONE, :LEAFSTONE, :LEAFSTONE, :MOONSTONE, :MOONSTONE, :SUNSTONE, :OVALSTONE, :EVERSTONE, :STARPIECE, :COMETSHARD, :REVIVE, :MAXREVIVE, :RAREBONE, :RAREBONE, :LIGHTCLAY, :HARDSTONE, :IRONBALL, :ODDKEYSTONE, :HEATROCK, :DAMPROCK, :SMOOTHROCK, :ICYROCK, :REDSHARD, :GREENSHARD, :YELLOWSHARD, :BLUESHARD, :INSECTPLATE, :DREADPLATE, :DRACOPLATE, :ZAPPLATE, :FISTPLATE, :FLAMEPLATE, :MEADOWPLATE, :EARTHPLATE, :ICICLEPLATE, :TOXICPLATE, :MINDPLATE, :STONEPLATE, :SKYPLATE, :SPOOKYPLATE, :IRONPLATE, :SPLASHPLATE
]

ICONS = {
  "BUG"       => "<img src=\"/assets/images/icons/type_BUG.png\">",
  "DARK"      => "<img src=\"/assets/images/icons/type_DARK.png\">",
  "DRAGON"    => "<img src=\"/assets/images/icons/type_DRAGON.png\">",
  "ELECTRIC"  => "<img src=\"/assets/images/icons/type_ELECTRIC.png\">",
  "FAIRY"     => "<img src=\"/assets/images/icons/type_FAIRY.png\">",
  "FIGHTING"  => "<img src=\"/assets/images/icons/type_FIGHTING.png\">",
  "FIRE"      => "<img src=\"/assets/images/icons/type_FIRE.png\">",
  "FLYING"    => "<img src=\"/assets/images/icons/type_FLYING.png\">",
  "GHOST"     => "<img src=\"/assets/images/icons/type_GHOST.png\">",
  "GRASS"     => "<img src=\"/assets/images/icons/type_GRASS.png\">",
  "GROUND"    => "<img src=\"/assets/images/icons/type_GROUND.png\">",
  "ICE"       => "<img src=\"/assets/images/icons/type_ICE.png\">",
  "NORMAL"    => "<img src=\"/assets/images/icons/type_NORMAL.png\">",
  "POISON"    => "<img src=\"/assets/images/icons/type_POISON.png\">",
  "PSYCHIC"   => "<img src=\"/assets/images/icons/type_PSYCHIC.png\">",
  "QMARKS"    => "<img src=\"/assets/images/icons/type_QMARKS.png\">",
  "ROCK"      => "<img src=\"/assets/images/icons/type_ROCK.png\">",
  "SHADOW"    => "<img src=\"/assets/images/icons/type_SHADOW.png\">",
  "STEEL"     => "<img src=\"/assets/images/icons/type_STEEL.png\">",
  "WATER"     => "<img src=\"/assets/images/icons/type_WATER.png\">",

  "Physical"  => "<img src=\"/assets/images/icons/icon_physical.png\" style=\"margin-top: -4px;\">",
  "Special"   => "<img src=\"/assets/images/icons/icon_special.png\" style=\"margin-top: -4px;\">",
  "Status"    => "<img src=\"/assets/images/icons/icon_status.png\" style=\"margin-top: -4px;\">"
}


DEBUG_PATH = "WikiDebug/"

def pbFindEncounter(enc_types, species)
  return false if !enc_types
  ret = {}
  enc_types.each do |key, slots|
    next if !slots
    slots.each { |slot| ret[key] = slot if GameData::Species.get(slot[1]).species == species.species && GameData::Species.get(slot[1]).form == species.form}
  end
  return ret unless ret == {}
  return false
end

def pbCheckKey(key, species)
  return false if !key
  key.each do |k|
    next if !k
    return true if GameData::Species.get(k[1]).species == species.species && GameData::Species.get(k[1]).form == species.form
  end
  return false
end

def getFlagLocations(flag)
  ret = ""
  retlength = 0
  maps = pbMapTree
  maps.each do |map|
    next if map[1].include?("MAP")
    next if !GameData::MapMetadata.try_get(map[0])&.has_flag?(flag)
    ret << ", " if retlength > 0
    ret << "<a href=\"/maps/#{map[1]}\">#{map[1]}</a>"
    retlength += 1
  end
  return ret
end

def checkEvoMethod(myEvos, evolutionParam)
  case myEvos
  when :Level,:Ninjask then return "starting at level #{evolutionParam}"
  when :LevelMale then return "starting at level #{evolutionParam} if it's male"
  when :LevelFemale then return "starting at level #{evolutionParam} if it's female"
  when :LevelDay then return "starting at level #{evolutionParam} during daytime"
  when :LevelNight then return "starting at level #{evolutionParam} during nighttime"
  when :LevelMorning then return "starting at level #{evolutionParam} during the morning"
  when :LevelAfternoon then return "starting at level #{evolutionParam} during the afternoon"
  when :LevelEvening then return "starting at level #{evolutionParam} during the evening"
  when :LevelNoWeather then return "starting at level #{evolutionParam} with clear weather"
  when :LevelSun then return "starting at level #{evolutionParam} during sunny weather"
  when :LevelRain then return "starting at level #{evolutionParam} while it's raining"
  when :LevelSnow then return "starting at level #{evolutionParam} while it's hailing"
  when :LevelSandstorm then return "starting at level #{evolutionParam} during a sandstorm"
  when :LevelDarkInParty then return "starting at level #{evolutionParam} with a Dark-type Pokémon in your party"
  when :AttackGreater then return "starting at level #{evolutionParam} if its Attack is higher than its Defense"
  when :DefenseGreater then return "starting at level #{evolutionParam} if its Defense is higher than its Attack"
  when :AtkDefEqual then return "starting at level #{evolutionParam} if its Attack and Defense are equal"
  when :Cascoon,:Silcoon then return "starting at level #{evolutionParam} depending on its personality value"
  when :Shedinja then return "starting at level #{evolutionParam} as a biproduct when there is a party slot open and there's a free Pokéball in the bag"
  when :Happiness then return "when leveled up with high friendship"
  when :HappinessMale then return "when leveled up with high friendship and is male"
  when :HappinessFemale then return "when leveled up with high friendship and is female"
  when :HappinessDay then return "when leveled up with high friendship during the daytime"
  when :HappinessNight then return "when leveled up with high friendship during the nighttime"
  when :HappinessMoveType then return "when leveled up with high friendship while knowing a #{GameData::Type.get(evolutionParam).name}-type move"
  when :Beauty then return "when leveled up with a high beauty stat"
  when :Location then return "when leveled up in <a href=\"/maps/#{pbGetMapNameFromId(evolutionParam)}\">#{pbGetMapNameFromId(evolutionParam)}</a>"
  when :Item then return "when exposed to a #{GameData::Item.get(evolutionParam).name}"
  when :ItemMale then return "when exposed to a #{GameData::Item.get(evolutionParam).name} and is male"
  when :ItemFemale then return "when exposed to a #{GameData::Item.get(evolutionParam).name} and is female"
  when :TradeItem then return "when traded while holding a #{GameData::Item.get(evolutionParam).name}"
  when :HasMove then return "when leveled up while knowing #{GameData::Move.get(evolutionParam).name}"
  when :HoldItem then return "when leveled while holding a #{GameData::Item.get(evolutionParam).name}"
  when :DayHoldItem then return "when leveled while holding a #{GameData::Item.get(evolutionParam).name} during the day"
  when :NightHoldItem then return "when leveled while holding a #{GameData::Item.get(evolutionParam).name} during the night"
  when :HasInParty then return "when leveled up with a #{GameData::Species.get(evolutionParam).name} in the party"
  when :LocationFlag then return "when leveled up in #{getFlagLocations(evolutionParam)}"
  when :BattleDealCriticalHit then return "after landing #{evolutionParam.to_word} critical hits in a single battle"
  when :Event then return "after talking to the Kubfu enthousiast on <a href=\"/maps/Battle Island\">Battle Island</a>"
  when :EventAfterDamageTaken then return "after it takes at least 49 HP in damage (even if healed) without fainting and interacting with the runes in the <a href=\"/maps/Hubris Museum\">Hubris Museum</a>"
  end
  return ""
end

MenuHandlers.add(:debug_menu, :extractpokemon, {
  "parent"      => :other_menu,
  "name"        => _INTL("Extract Pokemon"),
  "description" => _INTL("Extract Pokemon"),
  "always_show" => true,
  "effect"      => proc {
    pbExtractPkmn
  }
})

###############################
# ITEMS                       #
###############################

def pbExtractItems
  filename = "#{DEBUG_PATH}items.json"
  textresult = writeItemJson()
  File.write(filename, textresult.to_json)
end

ARTEMISMART = [:NETBALL, :DIVEBALL, :NESTBALL, :REPEATBALL, :TIMERBALL, :LUXURYBALL, :DUSKBALL, :TWILIGHTBALL, :HEALBALL, :QUICKBALL, :FASTBALL, :LEVELBALL, :LUREBALL, :HEAVYBALL, :LOVEBALL, :FRIENDBALL, :MOONBALL, :DREAMBALL]
TILDARMART = [:SHADOWORB,:CHARCOAL,:MYSTICWATER,:MAGNET,:MIRACLESEED,:NEVERMELTICE,:BLACKBELT,:POISONBARB,:SOFTSAND,:SHARPBEAK,:TWISTEDSPOON,:SILVERPOWDER,:HARDSTONE,:SPELLTAG,:DRAGONFANG,:BLACKGLASSES,:METALCOAT,:SILKSCARF]
SMITHMART = [:JOYSCENT,:EXCITESCENT,:VIVIDSCENT,:BERRYJUICE,:ENERGYPOWDER,:ENERGYROOT,:ETHER,:ELIXIR,:COMMONCANDY,:REVIVALHERB]
JALSINMART = [:ASSAULTVEST,:HEAVYDUTYBOOTS,:QUICKCLAW,:SAFETYGOGGLES,:STICKYBARB,:WEAKNESSPOLICY,:POWERANKLET,:POWERBAND,:POWERBELT,:POWERBRACER,:POWERLENS,:POWERWEIGHT,:ABSORBBULB,:ADRENALINEORB,:BINDINGBAND,:UTILITYUMBRELLA]
GALVINMART = [:TM01,:TM02,:TM05,:TM12,:TM16,:TM20,:TM21,:TM23,:TM33,:TM42,:TM45,:TM58,:TM63,:TM73,:TM75,:TM76,:TM81,:TM82,:TM90,:TM92,:TM97]
BULGARTMART = [:LEEK,:LIGHTBALL,:LUCKYPUNCH,:METALPOWDER,:QUICKPOWDER,:THICKCLUB]
POLTERMART = [:AIRBALLOON,:BIGROOT,:BRIGHTPOWDER,:CHOICEBAND,:CHOICESCARF,:CHOICESPECS,:DESTINYKNOT,:EXPERTBELT,:FOCUSBAND,:LAGGINGTAIL,:MENTALHERB,:MUSCLEBAND,:POWERHERB,:REDCARD,:RINGTARGET,:SHEDSHELL,:WHITEHERB,:WIDELENS,:WISEGLASSES,:ZOOMLENS,:ELECTRICSEED,:GRASSYSEED,:MISTYSEED,:PSYCHICSEED,:PINKNECTAR,:PURPLENECTAR,:REDNECTAR,:YELLOWNECTAR,:ROCKYHELMET,:TERRAINEXTENDER,:ICYROCK,:HEATROCK,:DAMPROCK,:SMOOTHROCK]
ARCANEMART = [:REAPERCLOTH,:DAWNSTONE,:DUSKSTONE,:ELECTIRIZER,:RAZORCLAW,:CRACKEDPOT,:MAGMARIZER,:OVALSTONE,:PROTECTOR,:SHINYSTONE,:SACHET,:WHIPPEDDREAM,:DEEPSEASCALE,:DRAGONSCALE,:RAZORFANG,:UPGRADE,:DUBIOUSDISC,:PRISMSCALE,:EVERSTONE,:FIRESTONE,:ICESTONE,:LEAFSTONE,:MOONSTONE,:SUNSTONE,:THUNDERSTONE,:WATERSTONE,:SWEETAPPLE,:TARTAPPLE, :GALARICACUFF,:GALARICAWREATH,:STRAWBERRYSWEET, :LOVESWEET, :BERRYSWEET, :CLOVERSWEET,:FLOWERSWEET, :STARSWEET, :RIBBONSWEET]
UPILMART = [:CALCIUM,:CARBOS,:HPUP,:IRON,:PPUP,:PROTEIN,:ZINC,:XACCURACY,:XATTACK,:XDEFENSE,:XSPEED,:DIREHIT,:ABILITYURGE,:GUARDSPEC,:XSPDEF,:XSPATK,:ITEMURGE,:RESETURGE]
VICTORYMART = ARTEMISMART + TILDARMART + SMITHMART + JALSINMART + BULGARTMART + POLTERMART + ARCANEMART + UPILMART + [:LONELYMINT, :ADAMANTMINT, :NAUGHTYMINT, :BRAVEMINT, :BOLDMINT,:IMPISHMINT, :LAXMINT, :RELAXEDMINT, :MODESTMINT, :MILDMINT,:RASHMINT, :QUIETMINT, :CALMMINT, :GENTLEMINT, :CAREFULMINT,:SASSYMINT, :TIMIDMINT, :HASTYMINT, :JOLLYMINT, :NAIVEMINT,:SERIOUSMINT, :SALAMENCITE,:LOPUNNITE,:LUCARIONITE,:MANECTITE,:AGGRONITE,:TYRANITARITE,:AMPHAROSITE,:PINSIRITE,:GYARADOSITE,:PIDGEOTITE,:DRACOPLATE,:DREADPLATE,:EARTHPLATE,:FISTPLATE,:FLAMEPLATE,:ICICLEPLATE,:INSECTPLATE,:IRONPLATE,:MEADOWPLATE,:MINDPLATE,:PIXIEPLATE,:SKYPLATE,:SPLASHPLATE,:SPOOKYPLATE,:STONEPLATE,:TOXICPLATE,:ZAPPLATE,:FLAMEPLATE, :SPLASHPLATE, :ZAPPLATE, :SHADOWGEM,:FIREGEM, :WATERGEM, :ELECTRICGEM, :GRASSGEM, :ICEGEM, :FIGHTINGGEM, :POISONGEM, :GROUNDGEM, :FLYINGGEM, :PSYCHICGEM, :BUGGEM, :ROCKGEM, :GHOSTGEM, :DRAGONGEM, :DARKGEM, :STEELGEM, :FAIRYGEM, :NORMALGEM, :BLACKSLUDGE,:CELLBATTERY,:CLEANSETAG,:EJECTBUTTON,:FLAMEORB,:FLOATSTONE,:FLUFFYTAIL,:HONEY,:KINGSROCK,:LIFEORB,:LIGHTCLAY,:LUMINOUSMOSS,:METRONOME,:POKEDOLL,:POKETOY,:PROTECTIVEPADS,:SCOPELENS,:SHELLBELL,:SMOKEBALL,:SNOWBALL,:SPELLTAG,:TOXICORB,:TM14,:TM15,:TM25,:TM30,:TM32,:TM38,:TM43,:TM46,:TM47,:TM50,:TM53,:TM60,:TM61,:TM64,:TM66,:TM67,:TM68,:TM74,:TM77,:TM79,:TM85,:TM91,:TM96,:TM98,:TM100]
BERRYHOUSE = [:GROWTHMULCH, :DAMPMULCH, :STABLEMULCH, :GOOEYMULCH, :REDNECTAR, :YELLOWNECTAR, :PINKNECTAR, :PURPLENECTAR, :LAXINCENSE, :FULLINCENSE, :LUCKINCENSE, :PUREINCENSE, :SEAINCENSE, :WAVEINCENSE, :ROSEINCENSE, :ODDINCENSE, :ROCKINCENSE, :ENERGYPOWDER, :ENERGYROOT, :JOYSCENT,:EXCITESCENT,:VIVIDSCENT, :HEALPOWDER, :REVIVALHERB, :CHERIBERRY, :CHESTOBERRY, :PECHABERRY, :RAWSTBERRY, :ASPEARBERRY, :LEPPABERRY, :ORANBERRY, :PERSIMBERRY, :LUMBERRY, :SITRUSBERRY, :FIGYBERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY, :RAZZBERRY, :BLUKBERRY, :NANABBERRY, :WEPEARBERRY, :PINAPBERRY, :POMEGBERRY, :KELPSYBERRY, :QUALOTBERRY, :HONDEWBERRY, :GREPABERRY, :TAMATOBERRY, :CORNNBERRY, :MAGOSTBERRY, :RABUTABERRY, :NOMELBERRY, :SPELONBERRY, :PAMTREBERRY, :WATMELBERRY, :DURINBERRY, :BELUEBERRY, :OCCABERRY, :PASSHOBERRY, :WACANBERRY, :RINDOBERRY, :YACHEBERRY, :CHOPLEBERRY, :KEBIABERRY, :SHUCABERRY, :COBABERRY, :PAYAPABERRY, :TANGABERRY, :CHARTIBERRY, :KASIBBERRY, :HABANBERRY, :COLBURBERRY, :BABIRIBERRY, :ROSELIBERRY, :CHILANBERRY, :LIECHIBERRY, :GANLONBERRY, :SALACBERRY, :PETAYABERRY, :APICOTBERRY, :LANSATBERRY, :STARFBERRY, :ENIGMABERRY, :MICLEBERRY, :CUSTAPBERRY, :JABOCABERRY, :ROWAPBERRY, :KEEBERRY, :MARANGABERRY]
SHARDMART = [:FIRESTONE, :WATERSTONE, :THUNDERSTONE, :LEAFSTONE, :TM07, :TM11, :TM18, :TM37, :DUSKSTONE, :DAWNSTONE, :SHINYSTONE, :ICESTONE, :MOONSTONE, :SUNSTONE]
GENERALSTOREALWAYS = [:POTION, :ANTIDOTE, :PARALYZEHEAL, :BURNHEAL, :AWAKENING, :ICEHEAL]
GENERALSTOREBALLS = [:POKEBALL, :ESCAPEROPE, :REPEL]
GENERALSTOREGYM1 = [:GREATBALL, :REVIVE, :SUPERREPEL, :SUPERPOTION]
GENERALSTOREGYM2 = [:ETHER, :FULLHEAL]
GENERALSTOREGYM3 = [:ELIXIR, :MAXREPEL, :HYPERPOTION]
GENERALSTOREGYM4 = [:ULTRABALL]
GENERALSTOREGYM5 = [:MAXETHER, :MAXELIXIR, :HMEMULATOR]
GENERALSTOREGYM7 = [:MAXPOTION]
GENERALSTOREGYM8 = [:FULLRESTORE]
CASINOCOUNTER1 = [:SMOKEBALL, :WIDELENS, :ZOOMLENS, :METRONOME,:REDFLUTE, :BLUEFLUTE, :YELLOWFLUTE,:WHITEFLUTE, :BLACKFLUTE,:AMULETCOIN, :LUCKYEGG, :SOOTHEBELL,:REDNECTAR, :YELLOWNECTAR, :PINKNECTAR, :PURPLENECTAR,:BUGMEMORY,:DARKMEMORY,:DRAGONMEMORY,:ELECTRICMEMORY,:FAIRYMEMORY,:FIGHTINGMEMORY,:FIREMEMORY,:FLYINGMEMORY,:GHOSTMEMORY,:PSYCHICMEMORY,:ROCKMEMORY,:STEELMEMORY,:WATERMEMORY]
CASINOCOUNTER2 = [:TM04,:TM06,:TM09,:TM13,:TM17,:TM22,:TM24,:TM26,:TM35,:TM36,:TM41,:TM48,:TM51,:TM52,:TM69,:TM71,:TM78,:TM88,:TM94,:TM95]


def writeItemJson
  ret = []
  fieldItems = pbGetAllItems
  GameData::Item.each do |item|
    next if [:CLEVERFEATHER,:GENIUSFEATHER,:HEALTHFEATHER,:MUSCLEFEATHER,:PRETTYFEATHER,:RESISTFEATHER,:SWIFTFEATHER].include?(item.id)
    next if item.is_mail?
    next if item.is_apricorn?
    next if [:MAXMUSHROOMS, :MAXHONEY, :ITEMDROP, :DIREHIT2, :DIREHIT3, :ITEMFINDER, :DOWSINGMACHINE, :TOWNMAP, :POKERADAR, :SOOTSACK, :DEVONSCOPE, :SILPHSCOPE, :DNASPLICERSUSED, :NSOLARIZER, :NSOLARIZERUSED, :NLUNARIZER, :NLUNARIZERUSED, :REINSOFUNITYUSED, :MEGARING, :MEGAPENDANT, :MEGALOCKET, :OLDSEAMAP,:AURORATICKET, :BATTLECARD, :EXPSHARE, :EXPALLOFF, :FRONTIERPASSM, :FRONTIERPASSF, :FRONTIERPASSO, :SAFARIBALL, :SPORTBALL, :CHERISHBALL, :BEASTBALL, :SWEETHEART, :BIGMALASADA, :PEWTERCRUNCHIES, :RAGECANDYBAR, :LAVACOOKIE, :OLDGATEAU, :LUMIOSEGALETTE, :SHALOURSABLE].include?(item.id)
    pbSetWindowText(_INTL("Writing json hash for {1}...", item.id))
    itemlocations = []
    # Location based items
    # Field Items
    mapIds = []
    fieldItems.each do |fielditem|
      next unless fielditem["item"] == item && !itemlocations.include?(fielditem["location"])
      mapIds.push(fielditem["mapid"])
      itemlocations.push(fielditem["location"])
    end
    # Store bought items
    GENERALSTOREALWAYS.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Any Poké Mart")
    end
    GENERALSTOREBALLS.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Any Poké Mart (After getting your first Poké Balls)")
    end
    GENERALSTOREGYM1.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Any Poké Mart (After 1st Gym)")
    end
    GENERALSTOREGYM2.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Any Poké Mart (After 2nd Gym)")
    end
    GENERALSTOREGYM3.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Any Poké Mart (After 3rd Gym)")
    end
    GENERALSTOREGYM4.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Any Poké Mart (After 4th Gym)")
    end
    GENERALSTOREGYM5.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Any Poké Mart (After 5th Gym)")
    end
    GENERALSTOREGYM7.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Any Poké Mart (After 7th Gym)")
    end
    GENERALSTOREGYM8.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Any Poké Mart (After 8th Gym)")
    end
    # Special Store
    ARTEMISMART.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Artemis City Poké Mart")
    end
    TILDARMART.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Tildar City Poké Mart")
    end
    SMITHMART.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Smith City Poké Mart")
    end
    JALSINMART.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Jalsin City Poké Mart")
    end
    GALVINMART.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Galvin City Poké Mart")
    end
    POLTERMART.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Polter City Poké Mart")
    end
    ARCANEMART.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Arcane City Poké Mart")
    end
    BULGARTMART.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Bulgart Town Poké Mart")
    end
    UPILMART.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Upil City Poké Mart")
    end
    VICTORYMART.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Victory City Dept. Store")
    end
    BERRYHOUSE.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Dim Village Berry House")
    end
    SHARDMART.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Hubris Tunnel Shard Mart")
    end
    [:ACROBIKE, :MACHBIKE].each do |store_item|
      next if store_item != item.id
      itemlocations.push("Smith City Bike Shop")
    end
    [:FRESHWATER, :SODAPOP, :LEMONADE, :MOOMOOMILK].each do |store_item|
      next if store_item != item.id
      itemlocations.push("Any Vending Machine (Poké Marts)")
    end
    itemlocations.push("Any Vending Machine (1% chance)") if :SILVERMERCURY == item.id
    # Casino
    CASINOCOUNTER1.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Galvin City Casino (Silver Haired Attendant)")
    end
    CASINOCOUNTER2.each do |store_item|
      next if store_item != item.id
      itemlocations.push("Galvin City Casino (Blue Haired Attendant)")
    end
    # Held items
    GameData::Species.each do |species|
      next if species.wild_item_common != item.id && species.wild_item_uncommon != item.id && species.wild_item_rare != item.id
      rarity = 50 if species.wild_item_common == item.id
      rarity = 5 if species.wild_item_uncommon == item.id
      rarity = 1 if species.wild_item_rare == item.id
      rarity = 100 if species.wild_item_common == item.id && species.wild_item_uncommon == item.id && species.wild_item_rare == item.id
      next if rarity == 0
      itemlocations.push("Held by #{pbRealName(species)} (#{rarity}%)")
    end
    # Mega gifts
    [:AUDINITE,:VENUSAURITE,:SCEPTILITE,:CHARIZARDITEX,:CHARIZARDITEY,:BLAZIKENITE,:BLASTOISINITE,:SWAMPERTITE].each do |ms|
      next if ms != item.id
      itemlocations.push("From Borad in Dim Forest or Post Game from Prof. Orchid")
    end
    [:LATIASITE,:LATIOSITE].each do |ms|
      next if ms != item.id
      itemlocations.push("Held by gift Pokémon from Liz & Arnold (After beating the league)")
    end
    itemlocations.push("Held by gift Diancie from Upsilon (After beating the league)") if item.id == :DIANCITE
    # Legendary items
    itemlocations.push("From a fisherman on Battle Island after showing him a Shaymin") if :GRACIDEA == item.id
    itemlocations.push("From a fisherman on Battle Island after showing him one of the weather genies") if :REVEALGLASS == item.id
    itemlocations.push("From a fisherman on Battle Island after showing him a Hoopa") if :PRISONBOTTLE == item.id
    itemlocations.push("From a fisherman on Battle Island after showing him a Zygarde") if :ZYGARDECUBE == item.id
    itemlocations.push("From a fisherman on Battle Island after showing him one of the tao trio") if :DNASPLICERS == item.id
    itemlocations.push("From a fisherman on Battle Island after showing him Spectrier, Glastrier or Calyrex") if :REINSOFUNITY == item.id
    # Dex evaluation
    itemlocations.push("Evaluating your Pokédex by Prof. Orchid after catching more than 50 Pokémon") if :OVALCHARM == item.id
    itemlocations.push("Evaluating your Pokédex by Prof. Orchid after catching more than 100 Pokémon") if :EXPCHARM == item.id
    itemlocations.push("Evaluating your Pokédex by Prof. Orchid after catching more than 400 Pokémon") if :CATCHINGCHARM == item.id
    itemlocations.push("Evaluating your Pokédex by Prof. Orchid after catching at least 858 Pokémon") if :SHINYCHARM == item.id
    # Mining
    if MININGITEMS.include?(item.id)
      itemlocations.push("Hubris Tunnel (Mining)")
    end
    # Following pkmn
    [:POTION,:SUPERPOTION,:FULLRESTORE,:REVIVE,:PPUP,:PPMAX,:RARECANDY,:REPEL,:MAXREPEL,:ESCAPEROPE,:HONEY,:TINYMUSHROOM,:PEARL,:NUGGET,:GREATBALL,:ULTRABALL,:THUNDERSTONE,:MOONSTONE,:SUNSTONE,:DUSKSTONE].each do |fi|
      next if fi != item.id
      itemlocations.push("Held by Following Pokémon")
    end
    itemlocations.push("Held by Following Pokémon (Only on Battle Island)") if [:POKEBALL, :GREATBALL, :ULTRABALL].include?(item.id)
    # Abilities
    itemlocations.push("Pickup (Ability)") if PICKUP_COMMON_ITEMS.include?(item.id) || PICKUP_RARE_ITEMS.include?(item.id)
    itemlocations.push("Honey Gather (Ability)") if item.id == :HONEY
    # Process
    next if itemlocations.empty? # temporary solution
    itemlocations = ["Unobtainable"] if itemlocations.empty?
    obtain_loc = ""
    itemlocations.each_with_index { |i, c| obtain_loc += i + (itemlocations.length > c+1 ? ", " : "") }
    itemname = item.name
    itemname += " - #{GameData::Move.get(item.move).name}" if item.is_machine?
    ret.push({
      "id"          => "#{item.id.to_s}",
      "name"        => "#{itemname}",
      "location"    => "#{obtain_loc}",
      "description" => "#{item.real_description}",
      "icon"        => "#{pbItemFilename(item)}"
    })
  end
  return ret
end

def pbItemFilename(item_data)
  if item_data.is_a?(Symbol)
    item_data = GameData::Item.try_get(item_data)
  end
  return "back" if item_data.nil?
  return "000" if item_data.nil?
  # Check for files
  ret = sprintf("%s", item_data.id)
  return ret if pbResolveBitmap("Graphics/Items/#{ret}")
  # Check for TM/HM type icons
  if item_data.is_machine?
    prefix = "machine"
    if item_data.is_HM?
      prefix = "machine_hm"
    elsif item_data.is_TR?
      prefix = "machine_tr"
    end
    move_type = GameData::Move.get(item_data.move).type
    type_data = GameData::Type.get(move_type)
    ret = sprintf("%s_%s", prefix, type_data.id)
    return ret if pbResolveBitmap("Graphics/Items/#{ret}")
    if !item_data.is_TM?
      ret = sprintf("machine_%s", type_data.id)
      return ret if pbResolveBitmap("Graphics/Items/#{ret}")
    end
  end
  return "000"
end

###############################
# POKÉDEX                     #
###############################
def extractPokemonInfo
  ret = "name,dexno,"
  GameData::Species.each do |species|
    ret << species.name.downcase + ","
    ret << pbGetFormattedRegionalNumber(2,species) + ","
    File.write("pokemondata.csv", ret)
  end
end

def pbGetNationalDexNum(species, species_array = [])
  GameData::Species.each_species { |s| species_array.push(s.species) } if species_array == []
  sp = GameData::Species.get(species)
  ret = species_array.index(sp.species)
  ret = 0 if ret.nil? || !ret.is_a?(Integer)
  return ret
end

def pbExtractPokedex
  textresult = "internalname,realname,type1,type2,dexnumber"
  dexarray = []
  GameData::Species.each do |species|
    next if species.form > 0
    dexarray.push(species)
  end
  dexarray = dexarray.sort_by {|species| [pbGetNationalDexNum(species.species, dexarray), species.form] }
  dexarray.each do |species|
    next if species.types.include?(:QMARKS)
    sp = GameData::Species.get(species)
    textresult << "\n#{species.id},#{species.name.gsub(":","")},#{GameData::Type.get(sp.types[0]).name},#{(sp.types.length > 1 ? GameData::Type.get(sp.types[1]).name : "")},#{pbDexFormat(pbGetNationalDexNum(sp.species) + 1)}"
  end
  File.write("#{DEBUG_PATH}pokedex.csv", textresult)
end


###############################
# POKÉMON                     #
###############################
def pbRealName(species)
  real_name = ""
  real_name += "#{species.form_name} " unless nil_or_empty?(species.form_name) || species.name == "Unown" || species.form == 0
  is_mega = species.form_name&.include?("Mega")
  if is_mega
    real_name.chop
  else
    real_name += species.name
  end
  #real_name += " #{species.form_name}" if species.name == "Unown"
  real_name = real_name.gsub("?", "question")
  real_name = real_name.gsub("!", "exclaim")
  real_name = real_name.gsub("%", "-percent")
  return real_name
end

def pbExtractPkmn
  progressindex = 1
  GameData::Species.each do |species|
    next if species.types.include?(:QMARKS)
    next if species.form > 0
    pbSetWindowText(_INTL("(#{progressindex}/899) Writing article for {1}...", species.id))
    base_species = GameData::Species.get(species.species)
    # Alternate forms
    alternate_forms = []
    GameData::Species.each do |sp|
      next unless sp.form > 0
      next if sp.types.include?(:QMARKS)
      next if sp.species != species.species
      next if sp.form != 0 && (!sp.real_form_name || sp.real_form_name.empty?)
      next if sp.pokedex_form != sp.form
      alternate_forms.push(sp)
    end
    filename = "#{DEBUG_PATH}Mons/#{species.name.downcase.gsub(" ", "-").gsub(":", "")}.md"
    textresult = pbWritePage(species)
    alternate_forms.each do |alternate_form|
      next if alternate_form.species == :UNOWN
      textresult << "\n<hr>\n"
      textresult << pbWritePage(alternate_form, species)
    end
    File.write(filename, textresult)
    #File.write("#{DEBUG_PATH}/PostToWiki/vagrant/post_data/#{species.name}.txt", textresult)
    echoln "(#{progressindex}/899) - Extracted wiki article for #{species.id} to #{DEBUG_PATH}Mons/#{species.name}.txt"
    progressindex += 1
    #echoln getAllGiftMons
  end
  pbSetWindowText(nil)
  echoln "** Successfully extracted articles for all mons to #{DEBUG_PATH}Mons/ **"
end

def pbWritePage(species, origin_species = nil)
  pageicons = ICONS
  real_name = pbRealName(species)
  speciest = Pokemon.new(species,1)
  textresult = "---\nlayout: page\ntitle: #{real_name.gsub(":", "")}\n---\n"
  textresult = "" unless origin_species.nil?
  textresult << "<div class=\"post-content\">\n"
  textresult << "  <div class=\"columnright\">\n"
  textresult << "    <div class=\"absolutepkmn\">\n      <div class=\"infoboxheader\">\n"
  textresult << "        <p class=\"infoboxtext\">#{real_name}</p>\n"
  textresult << "        <p class=\"infoboxtext\"><a href=\"/pokedex\" style=\"color: inherit;\">##{pbDexFormat(pbGetNationalDexNum(species) + 1)}</a></p>\n"
  textresult << "      </div>\n      <img src=\"/assets/images/pokemon/front/"
  textresult << species.id.to_s
  textresult << ".png\" class=\"pkmn\">\n"
  textresult << "      <div class=\"infoboxdatabox\">\n        <p class=\"infoboxdataboxheader\">Type</p>\n        <div class=\"infoboxdataboxcontent\" style=\"justify-content: center;\">\n"
  textresult << "          <img src=\"/assets/images/icons/type_#{GameData::Type.get(species.types[0]).id.to_s}.png\" class=\"infoboxdataboxobject\">\n"
  textresult << "          <img src=\"/assets/images/icons/type_#{GameData::Type.get(species.types[1]).id.to_s}.png\" class=\"infoboxdataboxobject\">\n" if species.types[1]
  textresult << "        </div>\n      </div>\n      <div class=\"infoboxdatabox\">\n        <p class=\"infoboxdataboxheader\">Abilities</p>\n        <div class=\"infoboxdataboxcontent\">\n"
  species.abilities.each do | ability |
    textresult << "          <p class=\"infoboxdataboxobject\">#{GameData::Ability.get(ability).real_name}</p>\n"
  end
  species.hidden_abilities.each do | ha |
    textresult << "          <p class=\"infoboxdataboxobject\">#{GameData::Ability.get(ha).real_name} (Hidden Ability)</p>\n" unless species.abilities.include?(ha)
  end
  textresult << "        </div>\n      </div>\n    </div>\n  </div>\n\n"
  textresult << "  <div class=\"columnleft\">\n"
  textresult << "    <h1 id=\"#{real_name.downcase.gsub(" ","-").gsub(":","")}\">#{real_name}</h1>\n"
  textresult << "    <hr style=\"margin-bottom: 25px;\">\n    <p><strong>#{real_name}</strong> is a "
  textresult << "#{GameData::Type.get(species.types[0]).name}"
  textresult << "/#{GameData::Type.get(species.types[1]).name}" if species.types[1]
  textresult << "-type Pokémon.</p>\n    <br>\n"
  previousSpecies = GameData::Species.get_species_form(species.get_previous_species, species.form)
  myEvolutions = GameData::Species.get(species).get_evolutions
  if previousSpecies.name != species.name
    myEvolutions = previousSpecies.get_evolutions
    myEvolutions.count.times do |i|
      next unless myEvolutions[i][0].to_s.include?(species.id.to_s) || species.id.to_s.include?(myEvolutions[i][0].to_s)
      evolutionMethod = ""
      evolutionParam = myEvolutions[i][2]
      evolutionMethod = checkEvoMethod(myEvolutions[i][1], evolutionParam)
      textresult << "    <p>It evolves from <a href=\"/pokemon/#{previousSpecies.name.downcase.gsub(" ", "-").gsub(":", "")}##{pbRealName(previousSpecies).downcase.gsub(" ","-").gsub(":","")}\">#{previousSpecies.name}</a> #{evolutionMethod}.</p>\n"
    end
  end
  myEvolutions = GameData::Species.get(species).get_evolutions
  myEvolutions.count.times do |i|
    evolutionMethod = ""
    evolutionParam = myEvolutions[i][2]
    evolutionMethod = checkEvoMethod(myEvolutions[i][1], evolutionParam)
    textresult << "    <p>It evolves into <a href=\"/pokemon/#{GameData::Species.get(myEvolutions[i][0]).name.downcase}##{pbRealName(GameData::Species.get(myEvolutions[i][0])).downcase.gsub(" ","-").gsub(":","")}\">#{GameData::Species.get(myEvolutions[i][0]).name}</a> #{evolutionMethod}.</p>\n"
  end
  textresult << "    <p>It is not known to evolve into or from any other Pokémon.</p>\n" if previousSpecies.name == species.name && !myEvolutions[0]
  textresult << "    <div class=\"tableofcontents\">\n      <strong>Contents</strong>\n      <ol style=\"margin-top: 4px;margin-bottom: 2px;\">\n"
  textresult << "        <li><a href=\"#game-locations\">Game locations</a></li>\n        <li><a href=\"#learnset\">Learnset</a>\n"
  textresult << "          <ol style=\"\">\n            <li><a href=\"#by-level\">By level</a></li>\n            <li><a href=\"#by-tm-hm\">By TM/HM</a></li>\n          </ol>\n        </li>\n      </ol>\n    </div>\n"
  textresult << "    <div>\n      <h2 id=\"game-locations\">Game locations</h2>\n    <hr>\n"
  textresult << "      <table>\n        <thead>\n          <tr>\n"
  textresult << "            <th style=\"text-align: left\">Area</th>\n"
  textresult << "            <th style=\"text-align: left\">Type</th>\n"
  textresult << "            <th style=\"text-align: center\">Lvl</th>\n"
  textresult << "            <th style=\"text-align: right\">#{(SHRINEMONS.include?(species.id) ? "Condition" : "Rate")}</th>\n"
  textresult << "          </tr>\n        </thead>\n"
  mapInfos = pbLoadMapInfos
  foundAny = false
  textresult << "        <tbody>\n"
  newmapname = ""
  GameData::Encounter.each_of_version(0) do |enc_data|
    encounterTypes = []
    findEncounter = pbFindEncounter(enc_data.types, species)
    next if findEncounter == false
    enc_data.types.keys.each_with_index do |key, i|
      next if !pbCheckKey(enc_data.types[key],species)
      encounterTypes[i] = []
      case key
        when :Land then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_grass.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass")
        when :LandDay then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_day.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass (Day)")
        when :LandNight then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_night.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass (Night)")
        when :Cave then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_cave.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Cave")
        when :Water then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_surf.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Surfing")
        when :OldRod then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_fishing.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Fishing")
        when :GoodRod then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_fishing.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Fishing")
        when :SuperRod then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_fishing.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Fishing")
        when :RockSmash then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_rocksmash.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Rock Smash")
        when :SeaGrass then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_seagrass.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Underwater")
        when :LandRain then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_rain.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass (Raining)")
        when :LandSandstorm then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_sandstorm.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass (Sandstorm)")
        when :LandSunny then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_sun.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass (Sunny Day)")
        when :LandHail then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_hail.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass (Hail)")
        when :Shrine then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_shrine.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Shrine")
        when :PhenomenonGrass then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_phenomenon.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Shaking Grass")
        when :PhenomenonCave then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_phenomenon.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Dust Cloud")
        when :PhenomenonWater then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_phenomenon.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Water Bubbles")
        when :Egg then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_egg.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Egg")
        when :Gift then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_gift.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Gift")
        when :Event then encounterTypes[i].push("<img src=\"/assets/images/icons/icon_event.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Event")
        else encounterTypes[i].push("<img src=\"/assets/images/icons/icon_grass.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Unknown")
      end
      encounterTypes[i].push(findEncounter[key])
    end
    next if encounterTypes == []
    mapname = "<a href=\"/maps/#{mapInfos[enc_data.map].name}\">#{mapInfos[enc_data.map].name}</a>"
    textresult << "        </tbody>\n        <tbody>\n" if mapname != newmapname && newmapname != ""
    encounterTypes.each_with_index do |enc, i|
      next if enc.nil?
      foundAny = true
      levels = "#{enc[1][2]} - #{enc[1][3]}"
      textresult << "          <tr>\n"
      textresult << "            <td rowspan=\"0\" style=\"text-align: left\">#{mapname}</td>\n" unless mapname == newmapname
      newmapname = mapname
      textresult << "            <td style=\"text-align: left\">#{enc[0]}</td>\n"
      textresult << "            <td style=\"text-align: center\">#{levels}</td>\n"
      textresult << "            <td style=\"text-align: right\">#{pbGetRateOrCondition(species.id,enc[1][0])}</td>\n"
      textresult << "          </tr>\n"
    end
  end
  textresult << "          <tr>\n            <td style=\"text-align: center\" colspan=\"4\">None</td>\n          </tr>\n" unless foundAny
  textresult << "        </tbody>\n      </table>\n    </div>\n"
  # Learnset
  if origin_species.nil? || (origin_species.moves != species.moves || origin_species.tutor_moves != species.tutor_moves)
    # Level
    textresult << "    <div class=\"learnset-level\">\n      <h2 id=\"learnset\">Learnset</h2>\n    <hr>\n      <h3 id=\"by-level\">By level</h3>\n        <table>\n        <tr>\n"
    textresult << "          <th>Level</th>\n"
    textresult << "          <th>Move</th>\n"
    textresult << "          <th style=\"text-align: center\">Type</th>\n"
    textresult << "          <th style=\"text-align: center\">Cat.</th>\n"
    textresult << "          <th>Pwr.</th>\n"
    textresult << "          <th>Acc.</th>\n"
    textresult << "        </tr>\n"
    if species.moves.length < 1
      textresult << "        <tr>\n"
      textresult << "          <td colspan=\"6\">None</td>\n"
      textresult << "        </tr>\n"
    end
    species.moves.each do |move|
      move_data = GameData::Move.get(move[1])
      textresult << "        <tr>\n"
      textresult << "          <td>#{move[0]}</td>\n"
      textresult << "          <td>#{move_data.name}</td>\n"
      textresult << "          <td>#{pageicons[GameData::Type.get(move_data.type).id.to_s]}</td>\n"
      textresult << "          <td>#{pageicons[getCategoryName(move_data.category)]}</td>\n"
      textresult << "          <td>#{(move_data.base_damage > 1 ? "#{move_data.base_damage}" : "-")}</td>\n"
      textresult << "          <td>#{(move_data.accuracy > 1 ? "#{move_data.accuracy}%" : "-")}</td>\n"
      textresult << "        </tr>\n"
    end
    textresult << "      </table>\n    </div>\n"
    # TMs / HMs
    textresult << "    <div class=\"learnset-tm-hm\">\n      <h3 id=\"by-tm-hm\">By TM/HM</h3>\n        <table>\n        <tr>\n"
    textresult << "          <th colspan=2 style=\"text-align: center\">TM</th>\n"
    textresult << "          <th>Move</th>\n"
    textresult << "          <th style=\"text-align: center\">Type</th>\n"
    textresult << "          <th style=\"text-align: center\">Cat.</th>\n"
    textresult << "          <th>Pwr.</th>\n"
    textresult << "          <th>Acc.</th>\n"
    textresult << "        </tr>\n"
    machine_count = 0
    GameData::Item.each do |i|
      next unless i.is_machine?
      move = i.move
      next unless species.compatible_with_move?(move)
      machine_count += 1
      move_data = GameData::Move.get(move)
      textresult << "        <tr>\n"
      textresult << "          <td><img src=\"/assets/images/items/#{pbItemFilename(i)}.png\" class=\"icon\" style=\"object-fit: contain; width: 24px; height: 24px; max-width: none;\"></td>\n"
      textresult << "          <td>#{i.name}</td>\n"
      textresult << "          <td>#{move_data.name}</td>\n"
      textresult << "          <td>#{pageicons[GameData::Type.get(move_data.type).id.to_s]}</td>\n"
      textresult << "          <td>#{pageicons[getCategoryName(move_data.category)]}</td>\n"
      textresult << "          <td>#{(move_data.base_damage > 1 ? "#{move_data.base_damage}" : "-")}</td>\n"
      textresult << "          <td>#{(move_data.accuracy > 1 ? "#{move_data.accuracy}%" : "-")}</td>\n"
      textresult << "        </tr>\n"
    end
    if machine_count < 1
      textresult << "    <tr>\n"
      textresult << "      <td colspan=\"7\" style=\"text-align: center\">None</td>\n"
      textresult << "    </tr>\n"
    end
    textresult << "      </table>\n    </div>\n"
  end
  textresult << "  </div>\n</div>"
  return textresult
end

def getCategoryName(cat)
  case cat
  when 0 then return "Physical"
  when 1 then return "Special"
  when 2 then return "Status"
  end
end

def pbGetRateOrCondition(species, rate=0)
  return "#{rate}%" unless SHRINEMONS.include?(species)
  case species
  when :ARTICUNO then return "Only have Pokémon from Gen 1 in your party. (Roaming)"
  when :ZAPDOS then return "Only have Pokémon from Gen 1 in your party. (Roaming)"
  when :MOLTRES then return "Only have Pokémon from Gen 1 in your party. (Roaming)"
  when :RAIKOU then return "Only have Pokémon from Gen 2 in your party. (Roaming)"
  when :ENTEI then return "Only have Pokémon from Gen 2 in your party. (Roaming)"
  when :SUICUNE then return "Only have Pokémon from Gen 2 in your party. (Roaming)"
  when :UXIE then return "Only have Pokémon from Gen 4 in your party. (Roaming)"
  when :MESPRIT then return "Only have Pokémon from Gen 4 in your party. (Roaming)"
  when :AZELF then return "Only have Pokémon from Gen 4 in your party. (Roaming)"
  when :CRESSELIA then return "Only have Pokémon from Gen 4 in your party during the day. (Roaming)"
  when :DARKRAI then return "Only have Pokémon from Gen 4 in your party during the night. (Roaming)"
  when :COBALION then return "Only have Pokémon from Gen 5 in your party. (Roaming)"
  when :TERRAKION then return "Only have Pokémon from Gen 5 in your party. (Roaming)"
  when :VIRIZION then return "Only have Pokémon from Gen 5 in your party. (Roaming)"
  when :TORNADUS then return "Only have Pokémon from Gen 5 in your party. (Roaming)"
  when :THUNDURUS then return "Only have Pokémon from Gen 5 in your party. (Roaming)"
  when :LANDORUS then return "Only have Pokémon from Gen 5 in your party. (Roaming)"
  when :REGIROCK then return "Only have Pokémon from Gen 3 in your party and the leading Pokémon is Rock-type."
  when :REGICE then return "Only have Pokémon from Gen 3 in your party and the leading Pokémon is Ice-type. "
  when :REGISTEEL then return "Only have Pokémon from Gen 3 in your party and the leading Pokémon is Steel-type."
  when :REGIELEKI then return "Only have Pokémon from Gen 3 in your party and the leading Pokémon is Electric-type."
  when :REGIDRAGO then return "Only have Pokémon from Gen 3 in your party and the leading Pokémon is Dragon-type."
  when :TAPUKOKO then return "Only have Pokémon from Gen 7 in your party including a <a href=\"/pokemon/jolteon\">Jolteon</a>."
  when :TAPULELE then return "Only have Pokémon from Gen 7 in your party including a <a href=\"/pokemon/sylveon\">Sylveon</a>."
  when :TAPUBULU then return "Only have Pokémon from Gen 7 in your party including a <a href=\"/pokemon/leafeon\">Leafeon</a>."
  when :TAPUFINI then return "Only have Pokémon from Gen 7 in your party including a <a href=\"/pokemon/vaporeon\">Vaporeon</a>."
  when :MEWTWO then return "None"
  when :HEATRAN then return "Only have Fire-type Pokémon in your party."
  when :HOOH then return "Have <a href=\"/pokemon/articuno\">Articuno</a>, <a href=\"/pokemon/zapdos\">Zapdos</a> and <a href=\"/pokemon/moltres\">Moltres</a> in your party including a Shadow Pokémon."
  when :LUGIA then return "Have <a href=\"/pokemon/articuno\">Articuno</a>, <a href=\"/pokemon/zapdos\">Zapdos</a> and <a href=\"/pokemon/moltres\">Moltres</a> in your party without any Shadow Pokémon."
  when :RAYQUAZA then return "Have <a href=\"/pokemon/latias\">Latias</a>, <a href=\"/pokemon/latios\">Latios</a>, <a href=\"/pokemon/groudon\">Groudon</a> and <a href=\"/pokemon/kyogre\">Kyogre</a> in your party."
  when :KYOGRE then return "Have <a href=\"/pokemon/latias\">Latias</a> and <a href=\"/pokemon/latios\">Latios</a> in your party while it is raining."
  when :GROUDON then return "Have <a href=\"/pokemon/latias\">Latias</a> and <a href=\"/pokemon/latios\">Latios</a> in your party while it is sunny."
  when :DIALGA then return "Have <a href=\"/pokemon/uxie\">Uxie</a>, <a href=\"/pokemon/mesprit\">Mesprit</a> and <a href=\"/pokemon/azelf\">Azelf</a> in your party while the leading Pokémon is holding the <a href=\"/items#adamantorb\">Adamant Orb</a>."
  when :PALKIA then return "Have <a href=\"/pokemon/uxie\">Uxie</a>, <a href=\"/pokemon/mesprit\">Mesprit</a> and <a href=\"/pokemon/azelf\">Azelf</a> in your party while the leading Pokémon is holding the <a href=\"/items#lustrousorb\">Lustrous Orb</a>."
  when :GIRATINA then return "Have <a href=\"/pokemon/uxie\">Uxie</a>, <a href=\"/pokemon/mesprit\">Mesprit</a> and <a href=\"/pokemon/azelf\">Azelf</a> in your party while the leading Pokémon is holding the <a href=\"/items#griseousorb\">Griseous Orb</a>."
  when :REGIGIGAS then return "Have all 5 Regis in your party."
  when :KYUREM then return "Have <a href=\"/pokemon/tornadus\">Tornadus</a>, <a href=\"/pokemon/thundurus\">Thundurus</a>, <a href=\"/pokemon/landorus\">Landorus</a>, <a href=\"/pokemon/reshiram\">Reshiram</a> and <a href=\"/pokemon/zekrom\">Zekrom</a> in your party"
  when :RESHIRAM then return "Have <a href=\"/pokemon/tornadus\">Tornadus</a>, <a href=\"/pokemon/thundurus\">Thundurus</a> and <a href=\"/pokemon/landorus\">Landorus</a> in your party during the day."
  when :ZEKROM then return "Have <a href=\"/pokemon/tornadus\">Tornadus</a>, <a href=\"/pokemon/thundurus\">Thundurus</a> and <a href=\"/pokemon/landorus\">Landorus</a> in your party during the night."
  when :ZYGARDE then return "Have a <a href=\"/pokemon/noivern\">Noivern</a>, <a href=\"/pokemon/xerneas\">Xerneas</a> and <a href=\"/pokemon/yveltal\">Yveltal</a> in your party."
  when :XERNEAS then return "Have a <a href=\"/pokemon/noivern\">Noivern</a> and a <a href=\"/pokemon/mawile\">Mawile</a> in your party."
  when :YVELTAL then return "Have a <a href=\"/pokemon/noivern\">Noivern</a> and a <a href=\"/pokemon/sableye\">Sableye</a> in your party."
  when :ZACIAN then return "Have a <a href=\"/pokemon/stonjourner\">Stonjourner</a> and an <a href=\"/pokemon/aegislash\">Aegislash</a> in your party."
  when :ZAMAZENTA then return "Have a <a href=\"/pokemon/stonjourner\">Stonjourner</a> and a <a href=\"/pokemon/bastiodon\">Bastiodon</a> in your party."
  when :ETERNATUS then return "Have a <a href=\"/pokemon/stonjourner\">Stonjourner</a> and any Ultra Beast in your party."
  when :NIHILEGO then return "Have <a href=\"/pokemon/solgaleo\">Solgaleo</a> or <a href=\"/pokemon/lunala\">Lunala</a> in your party as well as a <a href=\"/pokemon/jellicent\">Jellicent</a>."
  when :BUZZWOLE then return "Have <a href=\"/pokemon/solgaleo\">Solgaleo</a> or <a href=\"/pokemon/lunala\">Lunala</a> in your party as well as a male <a href=\"/pokemon/heracross\">Heracross</a>."
  when :PHEROMOSA then return "Have <a href=\"/pokemon/solgaleo\">Solgaleo</a> or <a href=\"/pokemon/lunala\">Lunala</a> in your party as well as a female <a href=\"/pokemon/heracross\">Heracross</a>."
  when :XURKITREE then return "Have <a href=\"/pokemon/solgaleo\">Solgaleo</a> or <a href=\"/pokemon/lunala\">Lunala</a> in your party as well as a male <a href=\"/pokemon/electivire\">Electivire</a>."
  when :CELESTEELA then return "Have <a href=\"/pokemon/solgaleo\">Solgaleo</a> or <a href=\"/pokemon/lunala\">Lunala</a> in your party as well as a male <a href=\"/pokemon/metagross\">Metagross</a>."
  when :KARTANA then return "Have <a href=\"/pokemon/solgaleo\">Solgaleo</a> or <a href=\"/pokemon/lunala\">Lunala</a> in your party as well as a male <a href=\"/pokemon/aegislash\">Aegislash</a>."
  when :GUZZLORD then return "Have <a href=\"/pokemon/solgaleo\">Solgaleo</a> or <a href=\"/pokemon/lunala\">Lunala</a> in your party as well as a male <a href=\"/pokemon/absol\">Absol</a>."
  when :POIPOLE then return "Have <a href=\"/pokemon/solgaleo\">Solgaleo</a> or <a href=\"/pokemon/lunala\">Lunala</a> in your party as well as a male <a href=\"/pokemon/skrelp\">Skrelp</a>."
  when :STAKATAKA then return "Have <a href=\"/pokemon/solgaleo\">Solgaleo</a> or <a href=\"/pokemon/lunala\">Lunala</a> in your party as well as a male <a href=\"/pokemon/rhyperior\">Rhyperior</a>."
  when :BLACEPHALON then return "Have <a href=\"/pokemon/solgaleo\">Solgaleo</a> or <a href=\"/pokemon/lunala\">Lunala</a> in your party as well as a male <a href=\"/pokemon/magmortar\">Magmortar</a>."
  when :ARCEUS then return "Have every other legendary (excluding Ultra Beasts) from the Silver Shrine caught."
  when :MEW then return "Have <a href=\"/pokemon/mewtwo\">Mewtwo</a> in your party."
  when :CELEBI then return "Have <a href=\"/pokemon/ho-oh\">Ho-oh</a> and <a href=\"/pokemon/lugia\">Lugia</a> in your party."
  when :JIRACHI then return "Have <a href=\"/pokemon/rayquaza\">Rayquaza</a> in your party while the leading Pokémon is holding a <a href=\"/items#starpiece\">Star Piece</a>."
  when :DEOXYS then return "Have <a href=\"/pokemon/rayquaza\">Rayquaza</a> in your party while the leading Pokémon is holding a <a href=\"/items#cometshard\">Comet Shard</a>."
  when :SHAYMIN then return "Have <a href=\"/pokemon/heatran\">Heatran</a> in your party."
  when :MANAPHY then return "Have <a href=\"/pokemon/heatran\">Heatran</a>, a <a href=\"/pokemon/qwilfish\">Qwilfish</a>, a <a href=\"/pokemon/buizel\">Buizel</a> and a <a href=\"/pokemon/mantyke\">Mantyke</a> or their evolutions in your party."
  when :VICTINI then return "Have only 1 Pokémon in your party."
  when :KELDEO then return "Have <a href=\"/pokemon/terrakion\">Terrakion</a>, <a href=\"/pokemon/cobalion\">Cobalion</a>, <a href=\"/pokemon/virizion\">Virizion</a> in your party."
  when :MELOETTA then return "Have the <a href=\"/items#ancientscroll\">Ancient Scroll</a> in your bag."
  when :GENESECT then return "Have the <a href=\"/items#rocketdrive\">Rocket Drive</a> in your bag."
  when :MAGEARNA then return "Have the <a href=\"/items#oldpokeball\">Old Poké Ball</a> in your bag."
  when :MELTAN then return "Have the <a href=\"/items#silvermercury\">Silver Mercury</a> in your bag."
  when :SPECTRIER then return "Have the <a href=\"/items#shaderootcarrot\">Shaderoot Carrot</a> in your bag."
  when :GLASTRIER then return "Have the <a href=\"/items#icerootcarrot\">Iceroot Carrot</a> in your bag."
  when :ZARUDE then return "Have the <a href=\"/items#junglescarf\">Jungle Scarf</a> in your bag."
  when :MARSHADOW then return "Have at least four <a href=\"/pokemon/mimikyu\">Mimikyu</a> in your party."
  when :VOLCANION then return "Have <a href=\"/pokemon/magearna\">Magearna</a> in your party."
  when :COSMOG then return "Have <a href=\"/pokemon/tapu-koko\">Tapu Koko</a>, <a href=\"/pokemon/tapu-lele\">Tapu Lele</a>, <a href=\"/pokemon/tapu-bulu\">Tapu Bulu</a> and <a href=\"/pokemon/tapu-fini\">Tapu Fini</a> in your party, once during the day and another during the night."
  when :COSMOG_1 then return "Have <a href=\"/pokemon/tapu-koko\">Tapu Koko</a>, <a href=\"/pokemon/tapu-lele\">Tapu Lele</a>, <a href=\"/pokemon/tapu-bulu\">Tapu Bulu</a> and <a href=\"/pokemon/tapu-fini\">Tapu Fini</a> in your party, once during the day and another during the night."
  when :CALYREX then return "Have <a href=\"/pokemon/spectrier\">Spectrier</a> and <a href=\"/pokemon/glastrier\">Glastrier</a> in your party."
  when :ZERAORA then return "Have <a href=\"/pokemon/mewtwo\">Xurkitree</a> in your party."
  when :HOOPA then return "Have every other mythical Pokémon from the Gold Shrine caught."
  end
  return "Unknown"
end

def pbFixEncounterPBS
  newfile = File.open("PBS/encounter.txt", "wb") { |nf|
    nf.write("# See the documentation on the wiki to learn how to edit this file.\r\n")
    pbs = File.open("PBS/encounters.txt", "rb") { |f|
      i = 0
      f.each_line { |line|
        i += 1
        next unless i > 1
        content = line.gsub(" ", "")
        skip = false
        if (content == "" || content.nil? || content[0] == "#") || !["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].include?(content[0])
          nf.write(line)
          skip = true
        end
        next if skip
        encounter = content.split(",")
        rarity = encounter[0].to_i
        species = encounter[1].to_sym
        level = encounter[2].to_i
        if species == :COSMOG || species == :COSMOG_1
          nf.write(line)
          skip = true
        end
        next if skip
        result = []
        (-2..2).each do |i|
          newlevel = [[level+i,1].max,100].min
          evolves = pbCheckEvolveDevolve(species, newlevel)
          result.push([evolves[0],newlevel])
        end
        parsed = []
        endresult = ""
        result.each do |r|
          next if parsed.include?(r[0])
          levelrange = []
          result.each do |lr|
            next unless lr[0] == r[0]
            levelrange.push(lr[1])
          end
          chance = (rarity.to_f*(levelrange.length.to_f/5.0)).round.to_i
          endresult << "  #{chance},#{r[0]},#{levelrange.min},#{levelrange.max}\r\n"
          parsed.push(r[0])
        end
        nf.write(endresult)
      }
    }
  }
end

###############################
# MAPS                        #
###############################
INCLUDED_MAPS = {
  32  =>  [32,33,42],
  48  => [48],
  76  => [76,80,77,78,79],
  81  => [81],
  82  => [82,89,83,84,85,86,87,88],
  90  => [90,166],
  91  => [91],
  92  => [92],
  93  => [93,98,165,94,95,96,97],
  99  => [99],
  100 => [100],
  101 => [101,105,102,103,104],
  106 => [106],
  107 => [107,110,112,108,109,111,113,114,115],
  121 => [121],
  122 => [122],
  141 => [141,144,142,143,145,146,147],
  123 => [123],
  124 => [124],
  125 => [125,128,132,126,127,129,130,131],
  133 => [133],
  134 => [134],
  135 => [135,140,136,137,138,139],
  148 => [148],
  149 => [149],
  150 => [150,153,151,152,154,155,156],
  157 => [157],
  158 => [158],
  159 => [159,162,160,161,163,164],
  167 => [167,168,169,170,171],
  172 => [172],
  173 => [173,176,174,175,177,178,179],
  180 => [180,181,182], # Mt. Vanity (Floor Number should only say in subpages)
  183 => [183,184],
  185 => [185],
  186 => [186],
  187 => [187,191,192,193,194,195,188,189,190,205],
  197 => [197,198,199,200,201,202,203],
  206 => [206,207],
  209 => [209],
  210 => [210,58,60,62]
}

def pbExportMaps
  INCLUDED_MAPS.each_key do |key, value|
    echoln "- Extracting map #{key} (#{pbGetMapNameFromId(key)})"
    pbExportMap(key)
    echoln ""
  end
  echoln "** Successfully extracted articles for all maps to #{DEBUG_PATH}Maps/ **"
end

def pbExtractMaps
  INCLUDED_MAPS.each_key do |key, value|
    echoln "- Extracting map #{key} (#{pbGetMapNameFromId(key)})"
    pbExtractMap(key)
    echoln ""
  end
  echoln "** Successfully extracted articles for all maps to #{DEBUG_PATH}Maps/ **"
end

def pbExtractMap(id)
  pageicons = ICONS
  mainmapname = pbGetMapNameFromId(id)
  maptype = maptype(mainmapname)  
  # Start
  textresult = "---\nlayout: page\ntitle: #{mainmapname}\n---\n\n"
  INCLUDED_MAPS[id].each do |mapid|
    mapname = pbGetMapNameFromId(mapid)
    maptype = maptype(mapname)
    mapname.gsub!(mainmapname,"") if mapid != id && !mapname.include?("Gym")

    # Get map information
    map_items = getMapItems(mapid)
    mapInfos = pbLoadMapInfos
    foundAny = false
    enc_data = GameData::Encounter.get(mapid, 0)
    map_trainers = getMapTrainers(mapid)
    next if map_items == [] && enc_data == nil && map_trainers == []

    textresult << "<div class=\"post-content\" id=\"route\">\n"
    textresult << "  <h1 id=\"#{mapname.downcase.gsub(" ","-")}\">#{mapname}</h1>\n\n" unless mapname == ""
    textresult << "  <hr style=\"margin-bottom: 25px;\">\n" unless mapname == ""
    textresult << "\n  <p><strong>#{mapname}</strong> is #{a_an(maptype)} #{maptype} in the Tepora Region.</p>\n\n" if mapid == id

    # Table of Contents
    if mapid == id
      textresult << "  <div class=\"tableofcontents\">\n    <strong>Contents</strong>\n"
      textresult << "    <ol style=\"margin-top: 4px;margin-bottom: 2px;\">#{map_items != [] ? "\n    <li><a href=\"#items\">Items</a></li>" : ""}#{enc_data != nil ? "\n    <li><a href=\"#pokemon\">Pokémon</a></li>" : ""}#{map_trainers != [] ? "\n    <li><a href=\"#trainers\">Trainers</a></li>" : ""}"
      textresult << "\n    </ol>\n  </div>\n"
    end

    # Item List
    unless map_items == []
      textresult << "  <h2 id=\"items\">Items</h2>\n  <hr>\n\n"
      textresult << "  <div>\n"
      textresult << "    <table>\n      <thead>\n        <tr>\n"
      textresult << "          <th colspan=\"2\" style=\"text-align: center\">Item</th>\n"
      textresult << "          <th style=\"text-align: left\">Location</th>\n"
      textresult << "        </tr>\n      </thead>\n"
      textresult << "      <tbody>\n"


      iterated_items = []
      map_items.each do |it|
        next if iterated_items.include?(it["item"])
        iterated_items.push(it["item"])
        item_count = map_items.count(it)
        item = it["item"]
        location = it["location"]
        textresult << "      <tr>\n"
        textresult << "        <td style=\"text-align: center; width: 48px;\"><img src=\"/assets/images/items/#{pbItemFilename(item)}.png\" class=\"icon\" style=\"object-fit: contain; width: 24px; height: 24px; max-width: none;\">#{item_count > 1 ? "<br>x#{item_count}" : ""}</td>\n"
        textresult << "        <td style=\"text-align: center\"><a href=\"/items\##{item.id.downcase}\">#{item.name}</a></td>\n"
        textresult << "        <td style=\"text-align: left\">#{location_mod(location,mapname,mainmapname)}</td>\n"
        textresult << "      </tr>\n"
      end
      textresult << "      </tbody>\n    </table>\n  </div>\n\n"
      textresult << "  <hr>\n\n"
    end
    # Pokémon
    if enc_data
      textresult << "  <h2 id=\"pokemon\">Pokémon</h2>\n  <hr>\n  <div class=\"encountergrid\">\n"
      foundAny = true
      encounterTypes = []
      enc_data.types.each_with_index do |type, i|
        if (i % 2 == 0) && (i > 0)
          textresult << "  </div>\n  <div class=\"encountergrid\">\n"
        end
        encounterTypes = []
        case type[0]
          when :Land then enc_type = "<img src=\"/assets/images/icons/icon_grass.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass"
          when :LandDay then enc_type = "<img src=\"/assets/images/icons/icon_day.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass (Day)"
          when :LandNight then enc_type = "<img src=\"/assets/images/icons/icon_night.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass (Night)"
          when :Cave then enc_type = "<img src=\"/assets/images/icons/icon_cave.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Cave"
          when :Water then enc_type = "<img src=\"/assets/images/icons/icon_surf.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Surfing"
          when :OldRod then enc_type = "<img src=\"/assets/images/icons/icon_fishing.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Fishing"
          when :GoodRod then enc_type = "<img src=\"/assets/images/icons/icon_fishing.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Fishing"
          when :SuperRod then enc_type = "<img src=\"/assets/images/icons/icon_fishing.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Fishing"
          when :RockSmash then enc_type = "<img src=\"/assets/images/icons/icon_rocksmash.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Rock Smash"
          when :LandRain then enc_type = "<img src=\"/assets/images/icons/icon_rain.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass (Raining)"
          when :LandSandstorm then enc_type = "<img src=\"/assets/images/icons/icon_sandstorm.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass (Sandstorm)"
          when :LandSunny then enc_type = "<img src=\"/assets/images/icons/icon_sun.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass (Sunny Day)"
          when :LandHail then enc_type = "<img src=\"/assets/images/icons/icon_hail.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Grass (Hail)"
          when :Shrine then enc_type = "<img src=\"/assets/images/icons/icon_shrine.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Shrine"
          when :PhenomenonGrass then enc_type = "<img src=\"/assets/images/icons/icon_phenomenon.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Shaking Grass"
          when :PhenomenonCave then enc_type = "<img src=\"/assets/images/icons/icon_phenomenon.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Dust Cloud"
          when :PhenomenonWater then enc_type = "<img src=\"/assets/images/icons/icon_phenomenon.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Water Bubbles"
          when :Egg then enc_type = "<img src=\"/assets/images/icons/icon_egg.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Egg"
          when :Gift then enc_type = "<img src=\"/assets/images/icons/icon_gift.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Gift"
          when :Event then enc_type = "<img src=\"/assets/images/icons/icon_event.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Event"
          when :SeaGrass then enc_type = "<img src=\"/assets/images/icons/icon_seagrass.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Underwater"
          else enc_type = "<img src=\"/assets/images/icons/icon_grass.png\" class=\"icon\" style=\"object-fit: contain; width: 32px;\"> Unknown"
        end
        textresult << "    <div class=\"column\">\n      <table>\n        <thead>\n          <tr>\n"
        textresult << "            <th colspan=\"4\" style=\"text-align: center\">#{enc_type}</th>\n"
        textresult << "          </tr>\n        </thead>\n        <thead>\n          <tr>\n"
        textresult << "            <th colspan=\"2\" style=\"text-align: center\">Pokémon</th>\n"
        textresult << "            <th style=\"text-align: center\">Levels</th>\n"
        textresult << "            <th style=\"text-align: right\">Rate</th>\n          </tr>\n        </thead>\n        <tbody>\n"
        type[1].each do | encounter |
          #echoln "  * encounter = #{encounter}"
          textresult << "          <tr>\n"
          icon = (!pbResolveBitmap("Graphics/Pokemon/Icons/#{encounter[1].to_s}") ? GameData::Species.get(encounter[1]).species.id.to_s : encounter[1].to_s)
          textresult << "            <td style=\"text-align: center; width: 64px;\"><img src=\"/assets/images/pokemon/icons/#{icon}.png\" class=\"icon\"></td>\n"
          textresult << "            <td style=\"text-align: center\"><a href=\"/pokemon/#{GameData::Species.get(encounter[1]).name.downcase.gsub(" ", "-").gsub(":", "")}\">#{pbRealName(GameData::Species.get(encounter[1]))}</a></td>\n"
          textresult << "            <td style=\"text-align: center\">#{encounter[2]} - #{encounter[3]}</td>\n"
          textresult << "            <td style=\"text-align: center\">#{pbGetRateOrCondition(encounter[1],encounter[0])}</td>\n"
          textresult << "          </tr>\n"
        end
        textresult << "        </tbody>\n      </table>\n    </div>\n"
      end
      textresult << "</div>\n"
    end
    # Trainers
    unless map_trainers == []
      textresult << "\n  <h2 id=\"trainers\">Trainers</h2>\n  <hr>\n\n  <div class=\"column\">\n    <table class=\"trainers\">\n"
      textresult << "        <thead>\n          <tr><th colspan=\"4\" style=\"text-align: center\">Trainers</th></tr>\n        </thead>\n"
      textresult << "        <thead>\n          <tr>\n            <th style=\"text-align: center\">Trainer</th>\n            <th colspan=\"2\" style=\"text-align: center\">Pokémon</th>\n          </tr>\n        </thead>"
      map_trainers.each do |trainerh|
        next if trainerh.nil?
        trainer = trainerh.to_trainer
        textresult << "        <tbody style=\"border-bottom: inherit; border-bottom-width: 4px;\">\n          <tr>\n            <td rowspan=\"#{(trainer.party.length)+1}\" style=\"text-align: center\"><img src=\"/assets/images/trainers/#{trainer.trainer_type.to_s}.png\" style=\"max-width: 64px;\"><br>#{GameData::TrainerType.get(trainer.trainer_type).name} #{trainer.name}"
        textresult << "<br>(Rematch)<br>" if trainerh.version > 0 && !["Grunt","Borad","Ashley","Silver"].include?(trainer.name)
        unless trainer.items == []
          textresult << "<br><strong>Items:</strong><br>"
          trainer.items.each do |item|
            next if [:MEGARING, :BORADMEGA, :ASHLEYMEGA].include?(item)
            textresult << "<img src=\"/assets/images/items/#{pbItemFilename(item)}.png\" alt=\"#{item.name}\" class=\"icon\" style=\"object-fit: contain; width: 24px; height: 24px; max-width: none; margin-right: 4px;\">"
          end
        end
        textresult << "</td>\n          </tr>\n"
        trainer.party.each do |pkmn|
          if pkmn.species_data.id == :STARTER
            icon = "000"
            textresult << "        <tr>\n          <td style=\"text-align: center;border: none;\"><img class=\"icon\" src=\"/assets/images/pokemon/icons/#{icon}.png\"> #{trainer.trainer_type == :RIVAL1 ? "Starter weak against yours" : (trainer.trainer_type == :RIVAL2 ? "Starter strong against yours" : "Meganium, Typhlosion or Feraligatr")} (Lv. #{pkmn.level})"
            textresult << "</td>\n          <td style=\"text-align: center;display: flex;flex-direction: column;justify-content: space-evenly;align-items: stretch;border: none;\">\n"
            textresult << "          </td>\n        </tr>\n"
            next
          end
          icon = (!pbResolveBitmap("Graphics/Pokemon/Icons/#{pkmn.species_data.id.to_s}") ? GameData::Species.get_species_form(pkmn.species, 0).id.to_s : pkmn.species_data.id.to_s)
          textresult << "        <tr>\n          <td style=\"text-align: center;border: none;\"><img class=\"icon\" src=\"/assets/images/pokemon/icons/#{icon}.png\"><a href=\"/pokemon/#{pkmn.species_data.name.downcase.gsub(" ", "-").gsub(":", "")}\">#{pbRealName(pkmn.species_data)}</a> Lv. #{pkmn.level}"
          if pkmn.hasItem?
            textresult << "<br><br><strong>Held item:</strong><br><img src=\"/assets/images/items/#{pbItemFilename(pkmn.item)}.png\" alt=\"#{pkmn.item.name}\" class=\"icon\" style=\"object-fit: contain;width: 24px;height: 24px;max-width: none;margin-right: 4px;\">#{pkmn.item.name}"
          end
          textresult << "</td>\n          <td style=\"text-align: center;display: flex;flex-direction: column;justify-content: space-evenly;align-items: stretch;border: none;\">\n"
          pkmn.moves.each do |move|
            textresult << "            <table class=\"move\"><td style=\"text-align: left;border: none;\"><img src=\"/assets/images/icons/type_#{move.type.to_s}.png\" style=\"margin-right: 7px; height: 20px;\">#{move.name}</td></table>\n"
          end
          textresult << "          </td>\n        </tr>\n"
        end
        textresult << "      </tbody>\n"
      end
      textresult << "    </table>\n  </div>\n"
    end

    # ADD SUBPAGES HERE

    textresult << "</div>\n"
  end
  #return textresult
  filename = "#{DEBUG_PATH}Maps/#{mainmapname.gsub(":", "")}.md"
  File.write(filename, textresult)
end

def maptype(m="")
  mapname = m.downcase
  return "route" if mapname.include?("route")
  return "town" if mapname.include?("town")
  return "village" if mapname.include?("village")
  return "city" if mapname.include?("city")
  return "island" if mapname.include?("island") || mapname.include?("isle")
  return "shrine" if mapname.include?("shrine")
  return "forest" if mapname.include?("forest") || mapname.include?("woods")
  return "place"
end

def a_an(str="")
  return "an" if ["a","e","i","o","u",""].include?(str[0].downcase)
  return "a"
end

def location_mod(location, mapname, mainmapname)
  ret = location.gsub("#{mapname}", "").gsub("#{mainmapname}", "").gsub(" (", "").gsub(")", "")
  ret = ret.gsub("After 5th gym"," (After 5th gym)") unless ret == ""
  ret = ret.gsub("After beating the league"," (After beating the league)") unless ret == ""
  ret = "Field" if ret == ""
  return ret
end