var _count = global.server.clients.getCount();
var _rate = game_get_speed(gamespeed_fps);
draw_text(16, 16, "Total Client: " + string(_count));
draw_text(16, 32, "Network Rate: " + string(_rate) + " Hz");
draw_text(16, 64, "Press C to change Network Rate");