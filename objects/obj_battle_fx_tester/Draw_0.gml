// ============================================================
// Draw Event (marker crosshair — drawn in world space, not GUI,
// so it lines up with where the effect will actually spawn)
// ============================================================

draw_set_color(c_lime);
draw_set_alpha(0.8);
draw_line(marker_x - 10, marker_y, marker_x + 10, marker_y);
draw_line(marker_x, marker_y - 10, marker_x, marker_y + 10);
draw_circle(marker_x, marker_y, 4, true);
draw_set_alpha(1);