
GENERIC_LETTERSOUND = "message_pop"

def letterSound(name)
  if nil_or_empty?(name)
    #pbSEPlay(GENERIC_LETTERSOUND,60,rand(98+pbGet(50)..102+pbGet(50)))
  else
    pbSEPlay("letterpop_#{name}",60,rand(98+pbGet(50)..102+pbGet(50)))
  end
end