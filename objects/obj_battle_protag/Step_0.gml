if attack == true {
	_dist = distance_to_point(_targetx, _targety);
	
	if _dist < 10 {
		sprite_index = attack_sprite_2;
		attack = false;
		vsp = 0;
		hsp = 0;
		speed = 0;
		battle_actor_hurt(obj_battle_enemy, 30);
	}
	else {
		move_towards_point(_targetx, _targety, hsp);
		self.y += vsp;
		vsp = vsp + grav;
	}
}
else if hurt == true {
	_dist = distance_to_point(_targetx, _targety);
	
	if _dist < 5 {
		hurt = false;
		hsp = 0;
		vsp = 0;
		speed = 0;
	}
	else {
		move_towards_point(_targetx, _targety, hsp);
		self.y += vsp;
		vsp = vsp + grav;
	}
}
else {
	vsp = 0;
	hsp = 0;
	speed = 0;
}