var _socket = async_load[? "socket"];
var _type = async_load[? "type"];
var _id = async_load[? "id"];
// Handle connection and disconnection
if (_id == server.socket) {
	switch (_type) {
		case network_type_connect:
			server.addClient(_socket);
			break;
		
		case network_type_disconnect:
			server.removeClient(_socket);
			break;
	}
}
// Handle data packets using RPC
else if (_type == network_type_data && server.hasClient(_id)) {
	var _buffer = async_load[? "buffer"];
	try {
		var _json = server.network.readBufferText(_buffer);
		var _data = json_parse(_json);
		server.triggerEvent("message", {
			data: _data,
			socket: _id
		});
	} catch (_error) {
		server.triggerEvent("error", _error);
	}
}


