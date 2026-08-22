/// obj_party_controller Create
persistent = true;
global.max_chars = 8;

// Sprite lookup tables (unchanged from your current version)
function scr_make_char_sprites(_idle, _walk, _run, _climb, _push, _slip, _fall, _land_soft, _land_hard, _jump) {
    return {
        idle: _idle, walk: _walk, run: _run, climb: _climb, push: _push,
        slip: _slip, fall: _fall, land_soft: _land_soft, land_hard: _land_hard, jump: _jump
    };
}

function scr_make_face_sprites(_idle) {
    return { idle: _idle };
}

char_sprites = {
    Joshua   : scr_make_char_sprites(
			   spr_joshua_stand, spr_joshua_walk, spr_joshua_run, 
			   spr_joshua_climb, spr_joshua_push, spr_joshua_slip, 
			   spr_joshua_fall, spr_joshua_land_soft, spr_joshua_land_hard, spr_joshua_jump),
    Ariadne  : scr_make_char_sprites(
			   spr_ariadne_stand, spr_ariadne_walk, spr_ariadne_run, 
			   spr_ariadne_climb, spr_ariadne_push, spr_ariadne_slip, 
			   spr_ariadne_fall, spr_ariadne_land_soft, spr_ariadne_land_hard, spr_ariadne_jump),
    Janesh   : scr_make_char_sprites(
			   spr_janesh_stand, spr_janesh_walk, spr_janesh_run, 
			   spr_janesh_climb, spr_janesh_push, spr_janesh_slip, 
			   spr_janesh_fall, spr_janesh_land_soft, spr_janesh_land_hard, spr_janesh_jump),
    Freya    : scr_make_char_sprites(
			   spr_freya_stand, spr_freya_walk, spr_freya_run, 
			   spr_freya_climb, spr_freya_push, spr_freya_slip, 
			   spr_freya_fall, spr_freya_land_soft, spr_freya_land_hard, spr_freya_jump),
    Meredith : scr_make_char_sprites(
			   spr_meredith_stand, spr_meredith_walk, spr_meredith_run, 
			   spr_meredith_climb, spr_meredith_push, spr_meredith_slip, 
			   spr_meredith_fall, spr_meredith_land_soft, spr_meredith_land_hard, spr_meredith_jump),
    Ken      : scr_make_char_sprites(
			   spr_ken_stand, spr_ken_walk, spr_ken_run, 
			   spr_ken_climb, spr_ken_push, spr_ken_slip, 
			   spr_ken_fall, spr_ken_land_soft, spr_ken_land_hard, spr_ken_jump),
    Henrik   : scr_make_char_sprites(
			   spr_henrik_stand, spr_henrik_walk, spr_henrik_run,
			   spr_henrik_climb, spr_henrik_push, spr_henrik_slip, 
			   spr_henrik_fall, spr_henrik_land_soft, spr_henrik_land_hard, spr_henrik_jump),
    Hebat    : scr_make_char_sprites(
			   spr_hebat_stand, spr_hebat_walk, spr_hebat_run, 
			   spr_hebat_climb, spr_hebat_push, spr_hebat_slip, 
			   spr_hebat_fall, spr_hebat_land_soft, spr_hebat_land_hard, spr_hebat_jump)
};

face_sprites = {
    Joshua : scr_make_face_sprites(spr_face_joshua_default)
    // add others as needed
};

// Party starts empty. Joshua is added only in new_game().
_Party = [];