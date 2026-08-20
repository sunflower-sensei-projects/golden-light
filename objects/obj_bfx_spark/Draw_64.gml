/// obj_fx_spark :: Draw GUI event

if (flash_alpha > 0.005) {
    draw_set_alpha(flash_alpha);
    draw_set_color(make_color_rgb(220, 255, 248));
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
}