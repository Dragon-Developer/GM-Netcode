function GameClient(_ip, _port) : TCPSocket(_ip, _port) constructor {
	ping = 0;
	started = false;
	pubsub = new PubSub();
	netSync = new NetworkSync(pubsub);
	spawner = new NetworkSpawner();
	spawner.addObject("obj_shot");
	spawner.addObject("obj_player");
	playerID = -1;
	maxDelay = 1;
	setEvent("error", function(err) {
		show_debug_message(err);
	});
	pubsub.createTopic("instance_full").subscribe(0, function(_id, _message) {
		if (!started) return;
		var _state = _message.state;
		var _object = _message.object;
		var _instance_id = _message.instance;
		var _inst = spawner.getOrCreate(_instance_id, _object);
		_inst.net.applyUpdate(_state);
	});
	pubsub.createTopic("instance_destroy").subscribe(0, function(_id, _message) {
		if (!started) return;
		var _instance_id = _message.instance;
		spawner.remove(_instance_id);
	});
	pubsub.createTopic("ping_update").subscribe(0, function(_id, _message) {
		if (!started) return;
		var _player_id = _message.id;
		var _ping = _message.ping;
		netSync.addPing(_player_id, max(ping, _ping));
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
					rpc.sendNotification("ping_update", _ping);
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
					spawner.entityManager.setPrefix(string(playerID));
					playerPos = _result.pos;
					change_room(rm_game, function() {
						player = spawner.createInstance(obj_player);
						player.initMe();
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
					/*
					playerInstances.forEach(function(_id, _inst) {
						instance_destroy(_inst);
					});
					playerInstances.clearAll();
					*/
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