/// obj_fx_quake :: Draw GUI event (screen flash, drawn in GUI layer so it isn't affected by camera shake)

if (flash_alpha > 0.005) {
    draw_set_alpha(flash_alpha);
    draw_set_color(make_color_rgb(255, 220, 150));
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
}