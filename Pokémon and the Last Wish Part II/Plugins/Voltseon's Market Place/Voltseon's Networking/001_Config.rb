=begin

  A battle will be over on URL/battleID (being a random hex value between 000000 and FFFFFF)
  :TrainerH     => $Trainer (Host)
  :TrainerC     => $Trainer (Connected)
  :BAH          => BattleAction (Host)
  :BAC          => BattleAction (Connected)
  :RandSeed     => Random int between 000000 and 999999 (decides damage calc and accuracy based on this value and turn number)

  Trainer Battle Actions
  :Forfeit  => bool         # Forfeits the battle
  :Item     => symbol       # Uses item in battle
  :Move     => int          # Index of move selects
  :Switch   => int          # Index of party switched into
  :Unready  => bool         # When set then wait for opponent

  Trading stuff
  "Trainer"     => $Trainer
  "Pokemon"     => <#Pokemon>
  "Ready"       => bool

=end
URL = 'https://my-worker.voltseon3290.workers.dev'

def vnTradeScreen(roomcode,is_host)
  scene = NetworkingTrading_Scene.new(roomcode,is_host)
  screen = NetworkingTrading_Screen.new(scene)
  screen.pbStartScreen
end

def vnTest
  send = {
    :Hello => "hi",
    :Howareyou => "sky",
    :Ithasbeen => "sure",
    :Number    => rand(10)
  }
  code = vnGenerateCode
  echoln pbPostData(URL + '/' + code + '/post', send) # 
  echoln _INTL('code is: {1}', code)
end

def vnPost(code,send,is_host)
  (is_host) ? code += '-H' : code += '-C'
  data = pbPostData(URL + '/' + code + '/post', send)
end

#pbEnterText("Cache Key",0,100,"",2)
def vnGet(code,want_host)
  (want_host) ? code += '-H' : code += '-C'
  data = pbDownloadData(URL+ '/' + code)
  return data
end

def vnGenerateCode(length=6)
  possibleKeys=[0,1,2,3,4,5,6,7,8,9,'A','B','C','D','E','F']
  code = ""
  for i in (0...length)
    code += "#{possibleKeys[rand(0...possibleKeys.length)]}"
  end
  return code
end