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
		// Example with callback chain
		rpc.sendRequest("sum", [1, 5])
			.onCallback(function(_result) {
				// Result is sum(1, 5) = 6, then request sum(6, 15)
				return rpc.sendRequest("sum", [_result, 15])	
			})
			.onCallback(function(_result) {
				// This callback isn't executed because the result was higher than 10 (error)
				return rpc.sendRequest("sum", [_result, 4])	
			})
			.onCallback(function(_result) {
				// This callback isn't executed because the previous one wasn't executed
				show_debug_message(_result);
			})
			.onError(function(_error) {
				// This is executed because sum(6, 16) resulted in an error
				show_debug_message(_error.message);
				return rpc.sendRequest("sum", [1, 2]);
			})
			.onCallback(function(_result) {
				// Result is sum(1, 2) = 3, then request sum(3, 3)
				return rpc.sendRequest("sum", [_result, 3])	
			})
			.onCallback(function(_result) {
				// Result is sum(3, 3) = 6, then request sum(6, 4)
				return rpc.sendRequest("sum", [_result, 5])	
			})
			.onCallback(function(_result) {
				// Result is 10
				show_debug_message(_result);
			})
			.onFinally(function() {
				// Always execute this
				show_debug_message("Finally");
			});
		sendPing();
	});
	static step = function() {
		if (mouse_check_button(mb_left)) {
			// Send notification to create ball
			rpc.sendNotification("create_ball", {
				x: mouse_x,
				y: mouse_y
			});
		}
	}
}