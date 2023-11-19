function GameClient(_ip, _port) : TCPSocket(_ip, _port) constructor {
	self.ping = 0;
	rpc.registerHandler("create_ball", function(_position) {
		instance_create_depth(_position.x, _position.y, 0, obj_ball);
	});
	sendPing = function() {
		// Wait 1 second to send ping
		call = call_later(1, time_source_units_seconds, function() {
			rpc.sendRequest("ping", current_time, function(_result) {
				var _ping = current_time - _result;
				ping = _ping;
				show_debug_message($"{_ping} ms");
				sendPing();
			}, function(_error) {
				show_debug_message($"Error {_error.code}: {_error.message}");	
				sendPing();
			});	
		});
	}
	setEvent("connected", function() {
		// Send request to set name
		rpc.sendRequest("set_name", "Hazy", function(_result) { 
			show_debug_message("Changed name!");
		}, function(_error) {
			show_debug_message($"Error {_error.code}: {_error.message}");	
		});
		// Send request to get name list
		rpc.sendRequest("get_name_list", [], function(_result) {
			show_debug_message(_result);	
		});
		sendPing();
	});
	static step = function() {
		if (mouse_check_button_pressed(mb_left)) {
			// Send notification to create ball
			rpc.sendNotification("create_ball", {
				x: mouse_x,
				y: mouse_y
			});
		}
	}
}