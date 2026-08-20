switch (battle_state) {
	
	case eBattleState.ENTER:
		scr_battle_enter();
		break;
	
	case eBattleState.PLAYER_TURN:
		scr_battle_player_turn(party_battlers);
		break;
	
	case eBattleState.ENEMY_TURN:
		scr_battle_enemy_turn(enemy_battlers);
		break;
		
	case eBattleState.ACTION:
		scr_battle_action();
		break;
		
	case eBattleState.ANIMATION:
		scr_battle_tick_animation();
		break;
	
	case eBattleState.SUMMON:
		scr_battle_tick_summon();
		break;
	
	case eBattleState.ROTATE:
		scr_battle_tick_rotation();
		break;
	
	case eBattleState.WIN():
	case eBattleState.LOSE():
		scr_battle_end();
		break;
	
	case eBattleState.EXIT():
		scr_battle_exit();
		break;
}

// Project all battlers to the screen space every frame regardless of state
scr_battle_project_all();