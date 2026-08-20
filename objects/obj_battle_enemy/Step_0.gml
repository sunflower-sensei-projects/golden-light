if attack == true {
	_dist = distance_to_point(_targetx, _targety);
	
	if _dist < 10 {
		sprite_index = attack_sprite_2;
		attack = false;
		vsp = 0;
		hsp = 0;
		speed = 0;
	}
	else {
		move_towards_point(_targetx, _targety, hsp);
		self.y += vsp;
		vsp = vsp + grav;
	}
}
else if hurt == true {
	_dist = sqrt(sqr(self.x-_targetx)+sqr(self.y-_targety));
	show_debug_message("_dist: "+string(_dist));
	
	if _dist <= 3 {
		hurt = false;
		hsp = 0;
		speed = 0;
	}
	else {
		move_towards_point(_targetx, _targety, hsp);
	}
}
else {
	vsp = 0;
	hsp = 0;
	speed = 0;
}