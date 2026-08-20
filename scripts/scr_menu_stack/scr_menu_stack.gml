/// Menu stack helpers.
///
/// The whole menu system is one array of page structs living on
/// obj_menu_controller (global.menu_stack). Each page is a struct built
/// by one of the scr_menu_page_* constructors (see individual page
/// scripts). "Back" is just popping the stack and calling .enter()
/// again on whatever's now on top, so no menu object ever needs to
/// know how to construct its own parent/sibling - the controller owns
/// that transition, once.
///
/// Page struct shape (all methods optional except step/draw_gui):
///   {
///     name        : string, for debugging / lookups
///     enter       : function(prev_result)  -> called when pushed on top,
///                                              or when returned to via back
///     step        : function(input)        -> called every step while on top
///     draw_world  : function()              -> optional, world-space draw
///     draw_gui    : function()              -> gui-space draw
///     get_cursor  : function()             -> returns {x, y} or undefined
///                                             (undefined = hide obj_menu_pointer)
///   }

function scr_menu_stack_init() {
	global.menu_stack = [];
}

function scr_menu_stack_push(_page, _param) {
	array_push(global.menu_stack, _page);
	if (variable_struct_exists(_page, "enter")) {
		_page.enter(_param);
	}
}

/// Pops the top page. Calls the new top page's `enter` again (with
/// undefined param) so it can refresh anything it needs to on return -
/// e.g. Items menu re-checking inventory length after a drop.
function scr_menu_stack_pop() {
	var _len = array_length(global.menu_stack);
	if (_len <= 0) { return undefined; }
	var _popped = global.menu_stack[_len - 1];
	array_delete(global.menu_stack, _len - 1, 1);

	var _new_top = scr_menu_stack_peek();
	if (!is_undefined(_new_top) && variable_struct_exists(_new_top, "enter")) {
		_new_top.enter(undefined);
	}
	return _popped;
}

function scr_menu_stack_peek() {
	var _len = array_length(global.menu_stack);
	if (_len <= 0) { return undefined; }
	return global.menu_stack[_len - 1];
}

function scr_menu_stack_clear() {
	global.menu_stack = [];
}

function scr_menu_stack_is_empty() {
	return array_length(global.menu_stack) <= 0;
}
