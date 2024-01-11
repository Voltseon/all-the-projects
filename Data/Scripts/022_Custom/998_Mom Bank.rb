# Variable in which the saved up money is stored
MOM_BANK_VARIABLE = 33 # [step_count, interest, amount]

STEPS_PER_INCREMENT = 500

INTEREST_PER_BADGE = {
  0 => 1.02,
  1 => 1.05,
  2 => 1.1,
  3 => 1.15,
  4 => 1.2,
  5 => 1.25,
  6 => 1.3,
  7 => 1.35,
  8 => 1.5
}

EventHandlers.add(:on_player_step_taken, :mom_bank,
  proc {
    bank = get_mom_bank
    next if bank[2] < 1
    if bank[0] < STEPS_PER_INCREMENT
      bank[0] += 1
      set_mom_bank(bank)
      next
    end
    bank[1] = mom_interest
    bank[2] = (bank[2]*bank[1]).clamp(0, Settings::MAX_MONEY)
    bank[0] = 0
    set_mom_bank(bank)
  }
)

def get_mom_bank
  ret = pbGet(MOM_BANK_VARIABLE)
  ret[2] = ret[2].decrypt if ret[2].is_a?(String)
  interest = mom_interest
  ret = [0, interest, 0] unless ret.is_a?(Array)
  ret[2] = ret[2].round
  return ret
end

def set_mom_bank(new_value)
  new_value[2] = new_value[2].encrypt
  pbSet(MOM_BANK_VARIABLE, new_value)
end

def mom_interest
  interest = INTEREST_PER_BADGE[$player.badge_count]
  interest = INTEREST_PER_BADGE[8] if interest.nil?
  return interest
end

def deposit_mom
  params = ChooseNumberParams.new
  params.setMaxDigits("#{$player.money.decrypt}".length)
  params.setDefaultValue($player.money.decrypt)
  params.setRange(0,$player.money.decrypt)
  params.setCancelValue(0)
  deposit_amt = pbMessageChooseNumber("\\G\\MG\\rHow much would you like to deposit?", params)
  return if deposit_amt < 1
  bank = get_mom_bank
  bank[2] += deposit_amt
  $player.money = $player.money.decrypt - deposit_amt
  pbSEPlay("mart_buy")
  set_mom_bank(bank)
end

def withdraw_mom
  bank = get_mom_bank
  params = ChooseNumberParams.new
  params.setMaxDigits("#{bank[2]}".length)
  params.setDefaultValue(bank[2])
  params.setRange(0,bank[2])
  params.setCancelValue(0)
  withdraw_amt = pbMessageChooseNumber("\\G\\MG\\rHow much would you like to withdraw?", params)
  return if withdraw_amt < 1
  if withdraw_amt > bank[2]
    pbPlayBuzzerSE
    pbMessage("\\G\\MGI'm sorry honey, but I cannot give you more than I have!")
    return
  end
  pbSEPlay("mart_buy")
  $player.money = $player.money.decrypt + withdraw_amt
  bank[2] -= withdraw_amt
  set_mom_bank(bank)
end

def pbDisplayMomGoldWindow(msgwindow)
  moneyString = get_mom_bank[2].to_s_formatted
  goldwindow = Window_AdvancedTextPokemon.new(_INTL("Mom:\n<ar>${1}</ar>", moneyString))
  goldwindow.setSkin("Graphics/Windowskins/goldskin")
  goldwindow.resizeToFit(goldwindow.text, Graphics.width)
  goldwindow.width = 160 if goldwindow.width <= 160
  if msgwindow.y == 0
    goldwindow.y = Graphics.height - goldwindow.height*2 + 32
  else
    goldwindow.y = goldwindow.height + 32
  end
  goldwindow.viewport = msgwindow.viewport
  goldwindow.z = msgwindow.z
  return goldwindow
end