/// @function					Network()
function Network() constructor {
	self.buffer = buffer_create(1, buffer_grow, 1);
	/// @function					sendData()
	/// @description				Send data to server.
	/// @param {Struct} data		Data to be sent.
	/// @param {Id.Socket} socket	Socket to send to.
	static sendData = function(_data, _socket) {
		buffer_seek(buffer, buffer_seek_start, 0);
		var _json_string = json_stringify(_data);
		buffer_write(buffer, buffer_text, _json_string);
		network_send_packet(_socket, buffer, buffer_tell(buffer));
	}
}
global.network = new Network();