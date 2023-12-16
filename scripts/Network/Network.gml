/// @function					Network()
function Network() constructor {
	static buffer = buffer_create(1, buffer_grow, 1);
	self.raw = false;
	self.type = network_socket_tcp;
	self.defaultSocket = -1;
	self.compress = false;
	static setRAW = function(_raw) {
		self.raw = _raw;
		return self;
	}
	static setType = function(_type) {
		self.type = _type;	
		return self;
	}
	static setDefaultSocket = function(_socket) {
		self.defaultSocket = _socket;
		return self;
	}
	static setCompress = function(_value) {
		self.compress = _value;	
		return self;
	}
	/// @function						readBufferText()
	/// @description					Read the buffer as a text.
	/// @param {Id.Buffer} buffer		The index of the buffer to read from.
	/// @returns {String}
	static readBufferText = function(_buffer) {
		if (!compress) {
			return buffer_read(_buffer, buffer_text);
		}
		var _decompressed = buffer_decompress(_buffer);	
		buffer_seek(_decompressed, buffer_seek_start, 0);
		var _text = buffer_read(_decompressed, buffer_text);
		buffer_delete(_decompressed);
		return _text;
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
		if (compress) {
			var _compressed = buffer_compress(buffer, 0, buffer_tell(buffer));
			buffer_delete(buffer);
			buffer = _compressed;
			buffer_seek(buffer, 0, buffer_get_size(_compressed));
		}
		array_foreach(_sockets, function(_socket) {
			if (raw) {
				network_send_raw(_socket, buffer, buffer_tell(buffer));
			} else {
				network_send_packet(_socket, buffer, buffer_tell(buffer));
			}
		});
	}
}