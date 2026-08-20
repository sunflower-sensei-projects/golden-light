draw_set_alpha(alpha);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (is_crit) {
	// Outline for crits
	draw_set_color(c_black);
	draw_text_transformed(self.x - 1, self.y - 1, string(number), scale, scale, 0);
	draw_text_transformed(self.x + 1, self.y + 1, string(number), scale, scale, 0);
}

draw_set_color(color);
draw_text_transformed(self.x, self.y, string(number), scale, scale, 0);

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);