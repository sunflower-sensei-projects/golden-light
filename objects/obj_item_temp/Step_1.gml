if _doOnce == false and _isItem != ""
{
	if _isItem == "coins"
	{
		sprite_index = spr_item_coins;
	}
	else
	{
		sprite_index = getItemSprite(_isItem);
	}
	show_debug_message("Temp item sprite changed to "+string(sprite_index));
	_doOnce = true;
}