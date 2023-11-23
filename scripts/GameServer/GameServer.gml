function GameServer(_port) : TCPServer(_port) constructor {
	network.setCompress(true);
	static createClient = function() {
		return new Client();	
	};
	rpc.registerHandler("ping", function(_params, _socket) {
		return _params;
	});
	rpc.registerHandler("sum", function(_params, _socket) {
		var _sum = _params[0] + _params[1];
		if (_sum > 10) throw "Sum error";
		return _sum;
	});
	rpc.registerHandler("create_ball", function(_position, _socket) {
		ballPosition = _position;
		rpc.sendNotification("create_ball", ballPosition, sockets);
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