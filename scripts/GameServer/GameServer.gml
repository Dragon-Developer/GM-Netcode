function GameServer(_port) : TCPServer(_port) constructor {
	static createClient = function() {
		return new Client();	
	};
	rpc.registerHandler("ping", function(_params, _socket) {
		return _params;
	});
	rpc.registerHandler("create_ball", function(_position, _socket) {
		ballPosition = _position;
		clients.forEach(function(_client_socket) {
			rpc.sendNotification("create_ball", ballPosition, _client_socket);
		});
	});
	rpc.registerHandler("set_name", function(_params, _socket) {
		if (string_length(_params) > 10) {
			throw "Your name must have a maximum of 10 characters";
		}
		var _client = self.getClient(_socket);
		_client.setName(_params);
		return true;
	});
	rpc.registerHandler("get_name_list", function(_params, _socket) {
		nameList = [];
		clients.forEach(function(_client_socket, _client) {
			array_push(nameList, _client.getName());
		});
		return string_join_ext(", ", nameList);	
	});
}