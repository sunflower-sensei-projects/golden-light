/// scr_Boot_Load_All_Data
/// Central boot loader. Returns { success: bool, errors: array }

function scr_Boot_Load_All_Data() {
    var _errors = [];
    var _r;
    
    // Characters
    _r = scr_Load_JSON_Array("chars.json", "Characters", "char_data", "char_index");
    if (!_r.success) array_push(_errors, _r.error);
    
    // Enemies (special case: enemies + bosses)
    _r = scr_Load_Enemy_Data();
    if (!_r.success) array_push(_errors, _r.error);
    
    // Items / Equipment
    _r = scr_Load_Item_Data();
    if (!_r.success) array_push(_errors, _r.error);
    
    // Sorceries
    _r = scr_Load_JSON_Array("magic.json", "Sorceries", "sorcery_data", "sorcery_index");
    if (!_r.success) array_push(_errors, _r.error);
    
    // Abilities
    _r = scr_Load_JSON_Array("abilities.json", "Abilities", "ability_data", "ability_index");
    if (!_r.success) array_push(_errors, _r.error);
    
    // Faefolk
    _r = scr_Load_JSON_Array("faefolk.json", "Faefolk", "fae_data", "fae_index");
    if (!_r.success) array_push(_errors, _r.error);
    
    // Summons
    _r = scr_Load_JSON_Array("summons.json", "Summons", "summon_data", "summon_index");
    if (!_r.success) array_push(_errors, _r.error);
    
    // Registries that only make sense after data is loaded
    scr_field_sorcery_registry_init();
    
    return {
        success : array_length(_errors) == 0,
        errors  : _errors
    };
}


/// Generic loader for a simple { "RootKey": [ ... ] } JSON file
function scr_Load_JSON_Array(_filename, _root_key, _global_data_name, _global_index_name) {
    if (!file_exists(_filename)) {
        return { success: false, error: "Missing file: " + _filename };
    }
    
    var _buf = buffer_load(_filename);
    if (_buf == -1) {
        return { success: false, error: "Failed to open buffer: " + _filename };
    }
    
    var _str = buffer_read(_buf, buffer_string);
    buffer_delete(_buf);
    
    var _data = json_parse(_str);
    if (!is_struct(_data)) {
        return { success: false, error: "JSON parse failed or root is not a struct: " + _filename };
    }
    
    if (!variable_struct_exists(_data, _root_key)) {
        return { success: false, error: "Missing root key '" + _root_key + "' in " + _filename };
    }
    
    var _arr = variable_struct_get(_data, _root_key);
    if (!is_array(_arr)) {
        return { success: false, error: "Root key '" + _root_key + "' is not an array in " + _filename };
    }
    
    // Basic sanity: every entry must have a "name" field
    for (var i = 0; i < array_length(_arr); i++) {
        if (!is_struct(_arr[i]) || !variable_struct_exists(_arr[i], "name")) {
            return { success: false, error: "Entry " + string(i) + " in " + _filename + " is missing a 'name' field" };
        }
    }
    
    variable_global_set(_global_data_name, _arr);
    variable_global_set(_global_index_name, buildIndex(_arr));
    
    show_debug_message("Loaded " + string(array_length(_arr)) + " entries from " + _filename);
    return { success: true, error: "" };
}


/// Enemy loader (enemies + bosses concatenated)
function scr_Load_Enemy_Data() {
    var _filename = "enemies.json";
    
    if (!file_exists(_filename)) {
        return { success: false, error: "Missing file: " + _filename };
    }
    
    var _buf = buffer_load(_filename);
    if (_buf == -1) {
        return { success: false, error: "Failed to open buffer: " + _filename };
    }
    
    var _str = buffer_read(_buf, buffer_string);
    buffer_delete(_buf);
    
    var _data = json_parse(_str);
    if (!is_struct(_data)) {
        return { success: false, error: "JSON parse failed: " + _filename };
    }
    
    if (!variable_struct_exists(_data, "enemies") || !variable_struct_exists(_data, "bosses")) {
        return { success: false, error: "enemies.json must contain both 'enemies' and 'bosses' arrays" };
    }
    
    var _enemies = _data.enemies;
    var _bosses  = _data.bosses;
    
    if (!is_array(_enemies) || !is_array(_bosses)) {
        return { success: false, error: "'enemies' and 'bosses' must both be arrays" };
    }
    
    global.enemy_data  = array_concat(_enemies, _bosses);
    global.enemy_index = buildIndex(global.enemy_data);
    
    show_debug_message("Loaded " + string(array_length(global.enemy_data)) + " enemies/bosses");
    return { success: true, error: "" };
}


/// Item / equipment loader (all categories concatenated)
function scr_Load_Item_Data() {
    var _filename = "items.json";
    
    if (!file_exists(_filename)) {
        return { success: false, error: "Missing file: " + _filename };
    }
    
    var _buf = buffer_load(_filename);
    if (_buf == -1) {
        return { success: false, error: "Failed to open buffer: " + _filename };
    }
    
    var _str = buffer_read(_buf, buffer_string);
    buffer_delete(_buf);
    
    var _data = json_parse(_str);
    if (!is_struct(_data)) {
        return { success: false, error: "JSON parse failed: " + _filename };
    }
    
    // Required category keys (add or remove as your file evolves)
    var _keys = ["Items", "Weapons", "Armor", "Helms", "Shields", "Shirts", "Boots", "Rings", "Misc"];
    var _combined = [];
    
    for (var i = 0; i < array_length(_keys); i++) {
        var _k = _keys[i];
        if (variable_struct_exists(_data, _k)) {
            var _arr = variable_struct_get(_data, _k);
            if (is_array(_arr)) {
                _combined = array_concat(_combined, _arr);
            }
        }
    }
    
    if (array_length(_combined) == 0) {
        return { success: false, error: "No item categories found or all empty in items.json" };
    }
    
    global.item_data  = _combined;
    global.item_index = buildIndex(global.item_data);
    
    show_debug_message("Loaded " + string(array_length(global.item_data)) + " items/equipment");
    return { success: true, error: "" };
}