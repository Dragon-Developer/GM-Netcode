var _w = display_get_gui_width();
draw_set_halign(fa_right);
draw_set_color(c_red);
draw_text(_w - 8, 8, $"{global.client.ping} ms");
draw_text(_w - 8, 24, $"Frame {global.game.currentFrame}");

draw_set_color(c_white);
draw_set_halign(fa_left);


