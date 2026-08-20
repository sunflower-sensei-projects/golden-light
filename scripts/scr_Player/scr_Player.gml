function playerReset(){
	self.x = global.player_last_x;
	self.y = global.player_last_y;
	self.facing_x = global.player_last_facing_x;
	self.facing_y = global.player_last_facing_y;
	self.sprite_index = global.player_last_sprite;
	self.image_index = global.player_last_spr_index;

	global.resetPlayer = false;
}

function playerGiveItem(_itemName){
	// Make the player turn to face the camera and do the item_get animation
	global.paused = true;
	Player.sprite_index = spr_isaac_item_get;
	Player.image_index = 0;
	Player.image_speed = 1;
	var _item = instance_create_depth(Player.x-8, Player.y-40, Player.depth-10, obj_item_temp);
	_item._isItem = _itemName;
	var _check = addItemParty(global.char_invs, _itemName, 1);
	if _check == 0
	{
		show_debug_message("Player given item: "+string(_itemName));
		smallTextbox("Joshua got a "+string(_itemName));
		return 0;
	}
	else
	{
		show_debug_message("Player has too many items.");
		smallTextbox("Joshua got a "+string(_itemName));
		return -1;
	}
}

function playerGiveCoins(_coinAmt){
	global.paused = true;
	Player.sprite_index = spr_isaac_item_get;
	Player.image_index = 0;
	Player.image_speed = 1;
	var _item = instance_create_depth(Player.x-8, Player.y-40, Player.depth-10, obj_item_temp);
	_item.sprite_index = spr_item_coins;
	var _check = addCoins(_coinAmt);
	smallTextbox("Joshua got "+string(_coinAmt)+" coins.");
}

function smallTextbox(_text){
	global.sm_text_buffer = string(_text);
	instance_create_depth(0, 0, -20, obj_menu_textbox_sm);
}

function regTextbox(_charName, _textArray, _face){
	global.char_talking = _charName;
	global.text_buffer = _textArray;
	global.speaking_face = _face;
	instance_create_depth(0, 0, -20, obj_menu_textbox);
}

function scr_Player_Refresh_Sprites() {
	active_sprites = scr_Leader_Sprites();
	
	// Reset to idle sprite to avoid jittering
	if (active_sprites != undefined) {
		sprite_index = active_sprites.idle;
		image_index = 0;
		image_speed = 1;
	}
}