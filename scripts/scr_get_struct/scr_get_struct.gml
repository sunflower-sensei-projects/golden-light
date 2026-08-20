function name_to_struct(_name, _dataset, _lookup_index){
	if (!is_string(_name)) return undefined;
	var _names = struct_get_names(_lookup_index);
	var _i = 0;
	if array_contains(_names, _name)
	{
		_i = struct_get(_lookup_index, _name);
	} else {
		return undefined;	
	}
	
	return _dataset[_i];
}

function names_to_structs(_name_array, _dataset, _lookup_index) {
	var _names = struct_get_names(_lookup_index);
	var _structs_array = [];
	var _index = 0;
	
	if (_name_array == "") return undefined;
	
	for (var _i = 0; _i < array_length(_name_array); _i++) {
		if (array_contains(_names, _name_array[_i])) {
			_index = struct_get(_lookup_index, _name_array[_i]);
			array_push(_structs_array, _dataset[_index]);
		}
	}
	
	if (array_length(_structs_array) == 0) return undefined;
	if (array_length(_structs_array) == 1) return _structs_array[0];
	
	return _structs_array;
}