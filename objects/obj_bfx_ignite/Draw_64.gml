/// obj_fx_ignite :: Draw GUI event

if (flash_alpha > 0.005) {
    draw_set_alpha(flash_alpha);
    draw_set_color(make_color_rgb(255, 180, 120));
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
}