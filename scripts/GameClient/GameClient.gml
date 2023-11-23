function GameClient(_ip, _port) : TCPSocket(_ip, _port) constructor {
	network.setCompress(true);
	self.ping = 0;
	rpc.registerHandler("create_ball", function(_pos) {
		var _inst = instance_create_depth(_pos.x, _pos.y, 0, obj_ball);
	});
	sendPing = function() {
		// Wait 1 second to send ping
		call = call_later(1, time_source_units_seconds, function() {
			rpc.sendRequest("ping", current_time)
				.onCallback(function(_result) {
					var _ping = current_time - _result;
					ping = _ping;
					show_debug_message($"{_ping} ms");
				})
				.onError(function(_error) {
					show_debug_message($"Error {_error.code}: {_error.message}");	
				})
				.onFinally(function() {
					sendPing();
				});
		});
	}
	setEvent("connected", function() {
		// Send request to set name
		rpc.sendRequest("set_name", "Test")
			.onCallback(function(_result) { 
				show_debug_message("Changed name!");
			})
			.onError(function(_error) {
				show_debug_message($"Error {_error.code}: {_error.message}");	
			});
		// Send request to get name list
		rpc.sendRequest("get_name_list", [])
			.onCallback(function(_result) {
				show_debug_message(_result);	
			});
		// Example with chaining callbacks
		rpc.sendRequest("sum", [1, 2])
			.onCallback(function(_result) {
				return rpc.sendRequest("sum", [_result, 3])	
			})
			.onCallback(function(_result) {
				return rpc.sendRequest("sum", [_result, 4])	
			})
			.onCallback(function(_result) {
				show_debug_message(_result); // 1 + 2 + 3 + 4 = 10
			})
			.onError(function(_error) {
				show_debug_message(_error.message);
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