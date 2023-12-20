function GameClientLockstep(_ip, _port) : TCPSocket(_ip, _port) constructor {
	ping = 0;
	started = false;
	pubsub = new PubSub();
	netSync = new NetworkSync(pubsub);
	playerID = -1;
	maxDelay = 1;
	global.game = new LockstepGame();
	setEvent("error", function(err) {
		show_debug_message(err);
	});
	global.game.sendInput = function(_frame, _input) {
		rpc.sendNotification("player_input", {
			frame: _frame,
			input: _input
		});
	}
	pubsub.createTopic("start_game").subscribe(0, function(_id, _message) {
		players = _message.players;
		totalPlayers = array_length(players);
		global.game.inputs.setTotalPlayers(totalPlayers);
		change_room(rm_game, function() {
			for (var i = 0; i < totalPlayers; i++) {
				var _inst = global.game.instances.create(24 + i * 32, 100, obj_player_lockstep);
				_inst.init(players[i].id);
			}
			global.game.start();
		});
	});
	pubsub.createTopic("player_input").subscribe(0, function(_id, _message) {
		if (!started) return;
		var _player_id = _message.id;
		var _frame = _message.frame;
		var _input = _message.input;
		global.game.inputs.addInput(_frame, _player_id, _input);
	});
	
	rpc.registerHandler("room_send", function(_params) {
		netSync.processData(_params);
	});
	
	sendPing = function() {
		// Wait 1 second to send ping
		call = call_later(1, time_source_units_seconds, function() {
			rpc.sendRequest("ping", current_time)
				.onCallback(function(_result) {
					var _ping = current_time - _result;
					ping = _ping;
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
		rpc.sendRequest("room_join", 1)
			.onCallback(function(_result) {
				started = true;
				playerID = _result.id;
				global.game.playerIndex = playerID;
			})
			.onError(function(_error) {
				show_debug_message(_error.message);	
			});
	});
	setEvent("step", function() {
		if (!connected) return;
		if (keyboard_check_pressed(vk_enter)) {		
			rpc.sendNotification("start_game");
		}
		global.game.step();
	});
}