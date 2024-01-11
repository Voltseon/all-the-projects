class Battle::Scene
  def pbCommandMenuEx(idxBattler, texts, mode = 0)
    pbShowWindow(COMMAND_BOX)
    cw = @sprites["commandWindow"]
    cw.setTexts(texts)
    cw.setIndexAndMode(@lastCmd[idxBattler],mode)
    pbSelectBattler(idxBattler)
    ret = -1
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index&1)==1
      elsif Input.trigger?(Input::RIGHT)
        cw.index += 1 if (cw.index&1)==0
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index&2)==2
      elsif Input.trigger?(Input::DOWN)
        cw.index += 2 if (cw.index&2)==0
      end
      pbPlayCursorSE if cw.index!=oldIndex
      # Actions
      if Input.trigger?(Input::USE)                # Confirm choice
        pbPlayDecisionSE
        ret = cw.index
        @lastCmd[idxBattler] = ret
        break
      elsif Input.trigger?(Input::BACK) && mode==1 # Cancel
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::F9) && $DEBUG    # Debug menu
        pbPlayDecisionSE
        ret = -2
        break
			elsif Input.trigger?(Input::ACTION)          # New, check stats
				player = @battle.array_change_stats_in_battle
				opponent = @battle.array_change_stats_in_battle(1)
				quantity = []
				2.times { |i| quantity << @battle.pbSideBattlerCount(i) }
				activef = @battle.active_field
				actives = @battle.active_side
				activep = @battle.active_position
				team = [player, opponent]
				activestore = [activef, actives, activep]
				CheckStatsInBattle.show(team, quantity, activestore)
			end
    end
    return ret
  end
end