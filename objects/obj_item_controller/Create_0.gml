// Init item storage
// Each character can hold up to 15 items
global.item_max = 15;

global.char_invs = [];

// Generate the first character's inventory
inventory = [];
array_push(global.char_invs, inventory);

// Coins counter
global.coins = 0;

// Load the items.json file and load the item data into memory
_check = loadItemData();
if _check == 0
{
	show_debug_message("Item data successfully loaded.");
}
else
{
	show_debug_message("Item data failed to load.");
}