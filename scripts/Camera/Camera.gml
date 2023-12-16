function Camera() constructor {
	self.target = noone;
	self.cam = view_camera[0];	
	self.roomW = room_width;
	self.roomH = room_height;
	self.x = 0;
	self.y = 0;
	static step = function() {
		var _w = camera_get_view_width(cam);
		var _h = camera_get_view_height(cam);	
		
		if (instance_exists(target)) {
			x = target.x - _w / 2;
			y = target.y - _h / 2;
		}
		
		x = clamp(x, 0, roomW - _w);
		y = clamp(y, 0, roomH - _h);
		camera_set_view_pos(cam, x, y);
	}
	static setSize = function(_w, _h) {
		camera_set_view_size(cam, _w, _h);	
	}
}