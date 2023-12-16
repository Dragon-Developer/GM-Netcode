function GameClient(_ip, _port) : TCPSocket(_ip, _port) constructor {
	ping = 0;
	started = false;
	playerInstances = new Manager();
	pubsub = new PubSub();
	netSync = new NetworkSync(pubsub);
	spawner = new NetworkSpawner();
	spawner.addObject("obj_shot");
	playerID = -1;
	maxDelay = 1;
	setEvent("error", function(err) {
		show_debug_message(err);
	});
	pubsub.createTopic("player_state").subscribe(0, function(_id, _message) {
		if (!started) return;
		var _player_id = _message.id;
		var _state = _message.state;
		var _player_inst = playerInstances.getElement(_player_id);
		if (is_undefined(_player_inst) || !instance_exists(_player_inst)) {		
			_player_inst = instance_create_depth(0, 0, 0, obj_player);
			playerInstances.setElement(_player_id, _player_inst);		
		}
		_player_inst.net.applyState(_state);
	});
	pubsub.createTopic("instance_state").subscribe(0, function(_id, _message) {
		if (!started) return;
		var _state = _message.state;
		var _object_name = _message.object;
		var _object = spawner.getObject(_object_name);
		var _inst = spawner.createInstance(_object);
		_inst.net.applyState(_state);
	});
	pubsub.createTopic("player_left").subscribe(0, function(_id, _message) {
		if (!started) return;
		var _player_id = _message.id;
		if (_player_id == playerID) return;
		if (playerInstances.hasElement(_player_id)) {
			var _inst = playerInstances.getElement(_player_id);
			playerInstances.removeElement(_player_id);
			instance_destroy(_inst);
		}
	});
	rpc.registerHandler("room_send", function(_params) {
		var _type = _params.type;
		if (_type == "frame_advance") {
			netSync.frameAdvance(_params.data.id);	
			return;
		} 
		netSync.addData(_params);
	});
	sendPing = function() {
		// Wait 1 second to send ping
		call = call_later(1, time_source_units_seconds, function() {
			rpc.sendRequest("ping", current_time)
				.onCallback(function(_result) {
					var _ping = current_time - _result;
					ping = _ping;
					netSync.addPing(ping);
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
		sendPing();
	});
	setEvent("step", function() {
		if (!connected) return;
		netSync.step();
		if (keyboard_check_pressed(vk_enter)) {		
			rpc.sendRequest("room_join", 1)
				.onCallback(function(_result) {
					if (started) return;
					started = true;
					playerID = _result.id;
					playerPos = _result.pos;
					change_room(rm_game, function() {
						player = instance_create_depth(playerPos.x, playerPos.y, 0, obj_player);
						player.initMe(true);
						playerInstances.setElement(playerID, player);
						show_debug_message("Joined room");		
					});
				})
				.onError(function(_error) {
					show_debug_message(_error.message);	
				});
		}
		else if (keyboard_check_pressed(vk_space)) {		
			rpc.sendRequest("room_leave", [])
				.onCallback(function() {
					started = false;
					playerInstances.forEach(function(_id, _inst) {
						instance_destroy(_inst);
					});
					playerInstances.clearAll();
					room_goto(rm_lobby);
					show_debug_message("Left room");	
				})
				.onError(function(_error) {
					show_debug_message(_error.message)	
				});
		}
	});
	setEvent("step_end", function() { 
		if (!connected) return;
		rpc.sendNotification("frame_advance");
	});
}