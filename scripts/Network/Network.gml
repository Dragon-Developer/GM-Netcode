/// @function					Network()
function Network() constructor {
	static buffer = buffer_create(1, buffer_grow, 1);
	self.raw = false;
	self.type = network_socket_tcp;
	static setRAW = function(_raw) {
		self.raw = _raw;
	}
	static setType = function(_type) {
		self.type = _type;	
	}
	/// @function					sendData()
	/// @description				Send data to server.
	/// @param {Struct} data		Data to be sent.
	/// @param {Id.Socket} socket	Socket to send to.
	static sendData = function(_data, _socket) {
		buffer_seek(buffer, buffer_seek_start, 0);
		var _json_string = json_stringify(_data);
		buffer_write(buffer, buffer_text, _json_string);
		if (raw) {
			if (type == network_socket_ws) {
				network_send_raw(_socket, buffer, buffer_tell(buffer), network_send_text);
			} else {
				network_send_raw(_socket, buffer, buffer_tell(buffer));
			}
		} else {
			network_send_packet(_socket, buffer, buffer_tell(buffer));
		}
	}
}