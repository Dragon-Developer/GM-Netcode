function GameServer(_port) : TCPServer(_port) constructor {
	game_set_speed(60, gamespeed_fps);
	self.createClient = function() {
		return new Client();
	}
	pubsub = new PubSub();
	pubsub.createTopic("room_1");
	rooms = {};
	rooms[$ "1"] = [];
	// Send this data to everyone in the room (except a specific socket)
	roomSend = function(_room, _type, _data, _ignore_socket = -1) {
		if (_room == -1) return;
		var _topic = $"room_{_room}";
		if (pubsub.hasTopic(_topic)) {
			pubsub.getTopic(_topic).publish({
				params:	{
					type: _type,
					data: _data
				},
				ignore_socket: _ignore_socket
			});	
		}
	}
	setEvent("disconnected", function(_socket) {
		var _client = getClient(_socket);
		roomSend(_client.room, "player_left", { 
			id: _socket
		});
		pubsub.unsubscribeAll(_socket);
	});
	setEvent("connected", function(_socket) {
		rpc.sendNotification("update_rate", game_get_speed(gamespeed_fps), _socket);
	});
	rpc.registerHandler("ping", function(_params, _socket) {
		return _params;
	});
	rpc.registerHandler("ping_update", function(_params, _socket) {
		var _client = getClient(_socket);
		roomSend(_client.room, "ping_update", {
			id: _socket,
			ping: _params
		}, _socket);
	});
	rpc.registerHandler("room_join", function(_room_id, _socket) {
		var _topic = $"room_{_room_id}";
		if (!pubsub.hasTopic(_topic)) throw "Invalid room";
		pubsub.getTopic(_topic).subscribe(_socket, function(_socket, _data) {
			if (_data.ignore_socket == _socket) return;
			rpc.sendNotification("room_send", _data.params, _socket);
		});
		var _client = getClient(_socket);
		_client.room = _room_id;
		array_push(rooms[$ _client.room], {
			id: _socket,
			confirmed: false
		});
		return {
			id: _socket
		};
	});
	rpc.registerHandler("room_leave", function(_params, _socket) {
		var _client = getClient(_socket);
		var _topic = $"room_{_client.room}";
		if (!pubsub.hasTopic(_topic)) throw "Invalid room";
		pubsub.getTopic(_topic).unsubscribe(_socket);
		roomSend(_client.room, "player_left", { 
			id: _socket
		});
		_client.room = -1;
		return true;
	});
	rpc.registerHandler("room_send_all", function(_params, _socket) {
		var _client = getClient(_socket);
		roomSend(_client.room, "room_send", _params);
	});
	rpc.registerHandler("room_send_others", function(_params, _socket) {
		var _client = getClient(_socket);
		roomSend(_client.room, "room_send", _params, _socket);
	});
	rpc.registerHandler("instance_full", function(_params, _socket) {
		var _client = getClient(_socket);
		roomSend(_client.room, "instance_full", {
			id: _socket,
			state: _params.state,
			object: _params.object,
			instance: _params.instance
		}, _socket);
	});
	rpc.registerHandler("instance_destroy", function(_params, _socket) {
		var _client = getClient(_socket);
		roomSend(_client.room, "instance_destroy", {
			id: _socket,
			instance: _params.instance
		}, _socket);
	});
	rpc.registerHandler("instance_update", function(_params, _socket) {
		var _client = getClient(_socket);
		roomSend(_client.room, "instance_state", {
			id: _socket,
			state: _params.state,
			instance: _params.instance
		}, _socket);
	});
	rpc.registerHandler("frame_advance", function(_params, _socket) {
		var _client = getClient(_socket);
		roomSend(_client.room, "frame_advance", {
			id: _socket
		}, _socket);
	});
	rpc.registerHandler("player_input", function(_params, _socket) {
		var _client = getClient(_socket);
		roomSend(_client.room, "player_input", {
			id: _socket,
			frame: _params.frame,
			input: _params.input
		}, _socket);
	});
	rpc.registerHandler("start_game", function(_params, _socket) {
		var _client = getClient(_socket);
		var _room = rooms[$ _client.room ];
		socketCheck = _socket;
		var _player_index = array_find_index(_room, function(_player) {
			return _player.id == socketCheck;
		});
		var _player = _room[_player_index];
		_player.confirmed = true;
		var _all_confirmed = array_find_index(_room, function(_player) {
			return !_player.confirmed;
		}) == -1;
		if (!_all_confirmed) return;
		roomSend(_client.room, "start_game", {
			players: _room
		});
	});
	setEvent("step", function() {
		if (keyboard_check_pressed(ord("C"))) {
			var _speed = get_integer("Network Rate", game_get_speed(gamespeed_fps));
			game_set_speed(_speed, gamespeed_fps);
		}
	});
}