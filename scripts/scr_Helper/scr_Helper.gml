function stringToArray(_string) {
	show_debug_message("Running stringToArray function, string:");
	show_debug_message(_string);
	
	var _len = string_length(_string);
	var _arr = [];
	
	for (var _i = 1; _i <= _len; _i++) {
		array_push(_arr, string_char_at(_string, _i));
	}
	
	show_debug_message("Resulting array: "+string(_arr));
	
	return _arr;
}

function convertTextBuffer(_textBuffer) {
	show_debug_message("Running convertTextBuffer function, text buffer:");
	show_debug_message(string(_textBuffer));
	
	var _maxBoxes = array_length(_textBuffer);
	var _arr = [];
	
	for (var _i = 0; _i < _maxBoxes; _i++) {
		array_push(_arr, stringToArray(_textBuffer[_i]));
	}
	
	show_debug_message("Resulting array: "+string(_arr));
	
	return _arr;
}

function actor_arc_jump(_actor, _targetx, _targety, _height, _speed) {
	// Moves the actor object in an arc towards the target x,y coordinates
	// _height controls how high it goes before coming down
	// _speed controls how fast it moves towards the point
	
	var _dist = point_distance(_actor.x, _actor.y, _targetx, _targety);
	var _maxHeight = _actor.y + _height;
	
	while _dist > 1 {
		if _actor.y < _maxHeight {
			with _actor {
				move_towards_point(_targetx, _actor.y, _speed);
				_actor.y += _speed;
			}
		}
		else {
			with _actor {
				move_towards_point(_targetx, _actor.y, _speed);
				_actor.y -= _speed;
			}
		}
		_dist = point_distance(_actor.x, _actor.y, _targetx, _targety);
	}
	
	return 0;
}

function getActorName(_actor) {
	if _actor.actor_type == "enemy" {
		return string(_actor.enemy_name);
	}
	else if _actor.actor_type == "protag" {
		return string(_actor.char_name);
	}
	else {
		return ""
	}
}