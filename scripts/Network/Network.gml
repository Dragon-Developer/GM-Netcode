/// @function					Network()
function Network() constructor {
	static buffer = buffer_create(1, buffer_grow, 1);
	self.raw = false;
	self.type = network_socket_tcp;
	self.defaultSocket = -1;
	static setRAW = function(_raw) {
		self.raw = _raw;
	}
	static setType = function(_type) {
		self.type = _type;	
	}
	static setDefaultSocket = function(_socket) {
		self.defaultSocket = _socket;	
	}
	/// @function						sendData()
	/// @description					Send data to socket.
	/// @param {Struct} data			Data to be sent.
	/// @param {Id.Socket} [sockets]	Sockets to send to.
	static sendData = function(_data, _sockets = [self.defaultSocket]) {
		if (!is_array(_sockets)) {
			_sockets = [_sockets];	
		}
		buffer_seek(buffer, buffer_seek_start, 0);
		var _json_string = json_stringify(_data);
		buffer_write(buffer, buffer_text, _json_string);
		array_foreach(_sockets, function(_socket) {
			if (raw) {
				network_send_raw(_socket, buffer, buffer_tell(buffer));
			} else {
				network_send_packet(_socket, buffer, buffer_tell(buffer));
			}
		});
	}
}