draw_set_alpha(alpha);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(color);
draw_text_transformed(self.x, self.y, string(status_text), scale, scale, 0);

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);