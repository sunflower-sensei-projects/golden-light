/// scr_menu_page_status(_mgr)
///
/// Full status screen: browse party members left/right, see complete
/// stat sheet for whichever is selected. Simpler than Items/Sorcery -
/// single flat selection, no drill-down.
function scr_menu_page_status(_mgr) {
	var _page = {
		name: "status",
		mgr: _mgr,
		char_select: 0,
		layout: scr_menu_layout().status_full,

		enter: function(_param) {
			var _party_size = array_length(mgr._Party);
			if (char_select >= _party_size) { char_select = 0; }
		},

		step: function(_input) {
			var _party_size = array_length(mgr._Party);
			var _nav = scr_menu_grid_nav(char_select, _party_size, _party_size, _input.right, _input.left, false, false);
			char_select = _nav.index;

			if (_input.back) { return "pop"; }
			return undefined;
		},

		get_cursor: function() {
			// Full-screen browse menu - no grid cursor needed, arrows
			// just flip the whole page, similar to how status used to
			// be a pure left/right browse in the original design intent.
			return undefined;
		},

		draw_gui: function() {
			var _L = self.layout;
			var _char = mgr._Party[char_select];
			var _party_size = array_length(mgr._Party);

			// Portrait / name strip
			draw_sprite_ext(spr_menu_window, 0, _L.portrait.x, _L.portrait.y, _L.portrait.w / sprite_get_width(spr_menu_window), _L.portrait.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			var _faces = struct_get(mgr.face_sprites, _char.char_name);
			draw_sprite(_faces.idle, 0, _L.portrait.x + 8, _L.portrait.y + 8);
			draw_text(_L.portrait.x + 48, _L.portrait.y + 8, _char.char_name);
			draw_text(_L.portrait.x + 48, _L.portrait.y + 24, string(_char.char_class) + "  Lv " + string(_char.char_level));

			draw_text(_L.portrait.x + _L.portrait.w - 60, _L.portrait.y + 8, "< " + string(char_select + 1) + "/" + string(_party_size) + " >");

			// Full stat sheet
			draw_sprite_ext(spr_menu_window, 0, _L.detail.x, _L.detail.y, _L.detail.w / sprite_get_width(spr_menu_window), _L.detail.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			var _dx = _L.detail.x + 12;
			var _dy = _L.detail.y + 12;
			var _line = 16;

			draw_text(_dx, _dy + _line * 0, "HP    " + string(_char.char_hp_current) + " / " + string(_char.char_hp_max));
			draw_text(_dx, _dy + _line * 1, "VP    " + string(_char.char_vp_current) + " / " + string(_char.char_vp_max));
			draw_text(_dx, _dy + _line * 2, "Exp   " + string(_char.char_exp));
			draw_text(_dx, _dy + _line * 3, "Attack   " + string(_char.attack));
			draw_text(_dx, _dy + _line * 4, "Defense  " + string(_char.defense));
			draw_text(_dx, _dy + _line * 5, "Agility  " + string(_char.agility));
			draw_text(_dx, _dy + _line * 6, "Luck     " + string(_char.luck));

			var _dx2 = _L.detail.x + (_L.detail.w / 2);
			draw_text(_dx2, _dy + _line * 0, "Weapon: " + equip_label(_char.eq_weapon));
			draw_text(_dx2, _dy + _line * 1, "Armor:  " + equip_label(_char.eq_armor));
			draw_text(_dx2, _dy + _line * 2, "Helm:   " + equip_label(_char.eq_helm));
			draw_text(_dx2, _dy + _line * 3, "Shield: " + equip_label(_char.eq_shield));
			draw_text(_dx2, _dy + _line * 4, "Shirt:  " + equip_label(_char.eq_shirt));
			draw_text(_dx2, _dy + _line * 5, "Boots:  " + equip_label(_char.eq_boots));
			draw_text(_dx2, _dy + _line * 6, "Acc:    " + equip_label(_char.eq_acc1) + " / " + equip_label(_char.eq_acc2));
		}
	};

	return _page;
}

/// equip_label(_slot)
/// Small helper so the six equip-slot lines above don't each need
/// their own "" check.
function equip_label(_slot) {
	return (_slot == "" or _slot == undefined) ? "---" : _slot.item_name;
}
