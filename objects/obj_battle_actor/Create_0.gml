hsp = 0;
vsp = 0;
movesp = 3;
max_jump_height = 55;  //displacement in pixels
jump_time = 25;        //in frames

//calculations
jump_to_peak_time = jump_time / 2;
jumpsp = max_jump_height / ( (jump_to_peak_time + 1) / 2);
grav = jumpsp / jump_to_peak_time;

_dist = 0;
_targetx = 0;
_targety = 0;

attack = false;
hurt = false;
downed = false;

sprite_scale = 1.5;

standing_sprite = spr_b_sat_front;
attack_sprite = spr_b_sat_front_attack1;
attack_sprite_2 = spr_b_sat_front_attack2;
hurt_sprite = spr_b_sat_front_hit;