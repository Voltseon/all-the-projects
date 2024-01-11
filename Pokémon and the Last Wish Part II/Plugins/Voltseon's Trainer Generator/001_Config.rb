######################################
#
# Voltseon's Trainer Generator
#
######################################
# Version 1.0
######################################
#
# Configuration
#
######################################

# Common event that plays before the battle starts
RT_COMMON_EVENT_ID = 3

# The odds of the trainer using a gender neutral name
GENDER_NEUTRAL_CHANCE = 25 # Out of 100

# Whether to use the species blacklist or whitelist
# true = blacklist, false = whitelist
USE_SPECIES_BLACKLIST = false

# An array of lose texts
LOSE_TEXTS = [
  "Aww man, I thought I had a chance.",
  "I suppose I am the loser.",
  "Wow, you're pretty strong!",
  "Those were some cool moves!",
  "Pfft. Before I could get serious, I lost!",
  "OK! I give up!",
  "I lost. I lost!",
  "I'm glad I got to see your Pokemon!",
  "Hmm. This is disappointing.",
  "Ow, ow, ow!",
  "Just as I thought, you're tough!",
  "Argh, I can't do anymore...",
  "Looks like you're the stronger one...",
  "Way to go!",
  "That's too bad.",
  "Just what I expected.",
  "Oh... That's disappointing!",
  "That's odd.",
  "...Humph! Are you happy you won?",
  "Tch! I tried to rush things...",
  "Argh! You're too strong!",
  "I was not expecting to lose that hard.",
  "Aack! My Pokemon!",
  "I was no match...",
  "Didn't I train enough?",
  "I see. So you can battle that way.",
  "That's strange. I won before.",
  "I was whipped...",
  "...Hmmm...",
  "Yow! You're too strong!",
  "This can't be true!",
  "Gaah!",
  "Yikes! Not fast enough!",
  "What an amazing battle!",
  "Phew...",
  "Pretty impressive! I'm sure you can go anywhere with that skill!",
  "You're too much!",
  "Good battle!",
  "Gwa ha ha! I lost.",
  "I can't move anymore...",
  "That's shocking!",
  "Whew... Good battle.",
  "Oh, yikes! We lost!",
  "Whatever!",
  "Heh, I guess I didn't try hard enough.",
  "I lost that one!",
  "Gulp! This is a bleak moment.",
  "Mercy!",
  "Tch! I took you too lightly!",
  "Uh-oh! I was also sunk by indecision!",
  "Ayeeee!",
  "Uww... I blew it.",
  "Impresive...",
  "We give up! You're the winner!",
  "Looks like we underestimated you",
  "Oh, so close! I almost had you!",
  "...did I win?",
  "Oh... I lost... you're not weak...",
  "Oh, dear! I wanted to win!",
  "Yikes! Sorry!",
  "... ... I'll go train some more...",
  "Yaha! I lost!",
  "I was no match...",
  "Uwahauwaha!",
  "Nyuraahahhaah",
  "You never saw me...",
  "Uwaaah! Eeek!",
  "Grr! I lost that...",
  "Oh... I lost...",
  "Peace--even though I lost!",
  "I did not expect to lose this battle.",
  "Ugh, why do I always keep losing these battles?",
  "No way!",
  "Aww, darn it!",
  "You cheated! It's that simple.",
  "I should've guessed you would cheat.",
  "I thought I was prepared for anything!",
  "I can't accept defeat like this...",
  "I knew you would win.",
  "Wow, you're too good!",
  "This can't be happening.",
  "Wow! You're super impressive.",
  "Hang on, this makes no sense..."
]

# An array of available Pokémon
SPECIES_WHITELIST = [
  :SCEPTILE, :TYPHLOSION, :BLASTOISE,
  :VENUSAUR, :BLAZIKEN, :FERALIGATR,
  :BUTTERFREE, :BEEDRILL, :ARIADOS,
  :LEDIAN, :KRICKETUNE, :SWELLOW,
  :STARAPTOR, :FEAROW, :FURRET,
  :RATICATE, :LINOONE, :BIBAREL,
  :MIGHTYENA, :QUAGSIRE_1, :SHUCKLE,
  :ARCANINE, :NINETALES, :MAGCARGO,
  :LUXRAY, :FLOATZEL_1, :GOLEM,
  :BRELOOM, :LUCARIO, :TOXICROAK,
  :AGGRON, :SANDSLASH, :PELIPPER,
  :DUNSPARCE, :CROBAT, :DUGTRIO,
  :GARDEVOIR, :GALLADE, :VESPIQUEN,
  :RAICHU, :VAPOREON, :JOLTEON,
  :FLAREON, :ESPEON, :UMBREON,
  :LEAFEON, :GLACEON, :NOCTOWL,
  :XATU, :MAGNEZONE, :MANECTRIC,
  :MAWILE, :SABLEYE, :MAWILE_1,
  :SABLEYE_1, :SPIRITOMB_1, :CACTURNE_1,
  :TENTACRUEL, :POLIWRATH, :POLITOED,
  :GYARADOS, :LUMINEON, :WALREIN,
  :LAPRAS, :WEAVILE, :MAMOSWINE,
  :ABOMASNOW, :FROSLASS, :STEELIX,
  :RAMPARDOS, :BASTIODON, :GENGAR,
  :MISMAGIUS, :HOUNDOOM, :DITTO,
  :ROTOM, :DRAGONITE, :TYRANITAR
]

# An array of banned Pokémon
SPECIES_BLACKLIST = [
  :ZAPDOS, :MOLTRES, :ARTICUNO,
  :MEW, :MEWTWO,
  :RAIKOU, :SUICUNE, :ENTEI,
  :LUGIA, :CELEBI, :HOOH,
  :LATIAS, :LATIOS,
  :REGICE, :REGISTEEL, :REGIROCK,
  :GROUDON, :KYOGRE, :RAYQUAZA,
  :JIRACHI, :DEOXYS
]

# An array of possible Items
ITEM_WHITELIST = [
  :HYPERPOTION,
  :MAXPOTION,
  :FULLRESTORE,
  :XATTACK,
  :XDEFENSE,
  :XSPATK,
  :XSPDEF,
  :XSPEED,
  :XACCURACY,
  :DIREHIT,
  :FULLHEAL
]

# An array of all viable trainer classes
# [CLASS, Gender, Overworld, Preferred types]
RT_TRAINER_WHITELIST = [
  [:AROMALADY,1,"NPC_051_Aroma_Lady",:GRASS,:FAIRY],
  [:BEAUTY,1,"NPC_044_Beauty",:NORMAL],
  [:BIRDKEEPER_M,0,"NPC_Z01_Bird_Keeper_M",:FLYING],
  [:BIRDKEEPER_F,1,"NPC_Z02_Bird_Keeper_F",:FLYING],
  [:BUGCATCHER,0,"NPC_013_Bug_Catcher",:BUG],
  [:ENGINEER,0,"NPC_080_Worker",:ELECTRIC,:STEEL],
  [:GAMBLER,0,"NPC_Z05_Private_Investigator"],
  [:FISHERMAN,0,"NPC_068_Fisherman",:WATER],
  [:GENTLEMAN,0,"NPC_037_Gentleman"],
  [:HIKER,0,"NPC_046_Hiker",:GROUND,:ROCK,:STEEL],
  [:JUGGLER,0,"NPC_086_Juggler"],
  [:LADY,1,"NPC_043_Lady",:NORMAL],
  [:PAINTER,0,"NPC_070_Artist",:NORMAL],
  [:RUINMANIAC,0,"NPC_081_Ruin_Maniac",:ROCK],
  [:TAMER,0,"NPC_Z03_Dragon_Tamer",:DRAGON,:FIRE],
  [:POKEMONBREEDER,1,"NPC_Z08_Breeder_F"],
  [:SAILOR,0,"NPC_033_Sailor",:WATER],
  [:SUPERNERD,0,"NPC_053_Super_Nerd",:ELECTRIC,:STEEL],
  [:BLACKBELT,0,"NPC_007_Black_Belt",:FIGHTING],
  [:CRUSHGIRL,1,"NPC_211_BattleGirl",:FIGHTING],
  [:LASS,1,"NPC_026_Lass",:NORMAL],
  [:YOUNGSTER,0,"NPC_023_Youngster",:NORMAL],
  [:PSYCHIC_M,0,"NPC_082_Psychic",:PSYCHIC,:GHOST],
  [:PSYCHIC_F,1,"trchar042",:PSYCHIC,:GHOST],
  [:EXPLORER,1,"NPC_209_Explorer",:GROUND,:ROCK,:STEEL],
  [:PILOT,0,"NPC_210_Pilot",:FLYING],
  [:COOLTRAINER_M,0,"NPC_005_Ace_Trainer_M"],
  [:COOLTRAINER_F,1,"NPC_006_Ace_Trainer_F"],
  [:ACETRAINER_M,0,"NPC_003_Ace_Trainer_M",:ICE],
  [:ACETRAINER_F,1,"NPC_004_Ace_Trainer_F",:ICE],
  [:CHANELLER,1,"NPC_078_Medium",:GHOST,:DARK]
]