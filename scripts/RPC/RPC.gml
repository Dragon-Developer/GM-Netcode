function RPC(_socket) constructor {
	self.requests = new Manager();
	self.handlers = {};
	self.socket = _socket;
	self.timeout = 5;
	self.network = undefined;
	static setNetwork = function(_network) {
		self.network = _network;	
	}
	static setTimeout = function(_timeout) {
		self.timeout = _timeout;	
	}
	static hasRequest = function(_id) {
		return requests.hasElement(_id);
	}
	static getRequest = function(_id) {
		return requests.getElement(_id);
	}
	static sendJSON = function(_data, _socket) {
		_data.jsonrpc = "2.0";
		network.sendData(_data, _socket);
	}
	/// @function sendRequest()
	/// @description
	/// Function to send requests by invoking the specified method with the given parameters
	/// over the provided socket. Allows handling both successful results and errors through callbacks.
	///
	/// @param {String} method - Name of the method to be invoked.
	/// @param {Struct|Array} params - Parameters to be used in the request.
	/// @param {Function} socket - Socket to which the request will be sent.
	/// @param {Real} timeout - Time, in seconds, to wait for the request result before timing out.
	static sendRequest = function(_method, _params, _socket = socket, _timeout = timeout) {
		var _id = generateID();
		sendJSON({
			"method": _method,
			"params": _params,
			"id": _id
		}, _socket);
		var _request = new RPCRequest(_id, _timeout, self);
		requests.setElement(_id, _request);
		return _request;
	}
	/// @function sendNotification()
	/// @description
	/// Sends a notification with the specified method and parameters over the given socket.
	///
	/// @param {String} method - Name of the method to be invoked.
	/// @param {Struct|Array} params - Parameters to be used in the notification.
	/// @param {Function} socket - Socket to which the notification will be sent.
	static sendNotification = function(_method, _params, _socket = socket) {
		sendJSON({
			"method": _method,
			"params": _params
		}, _socket);
	}
	/// @function sendError()
	/// @description
	/// Sends an error with the specified code, message, and ID over the given socket.
	///
	/// @param {Real} code - Error code.
	/// @param {String} message - Error message.
	/// @param {Real} id - ID associated with the error.
	/// @param {Function} socket - Socket to which the error will be sent.
	static sendError = function(_code, _message, _id, _socket) {
		sendJSON({
			"error": {
				"code": _code,
				"message": _message
			},
			"id": _id
		}, _socket);
	}
	static sendResult = function(_result, _id, _socket) {
		sendJSON({
			"result": _result,
			"id": _id
		}, _socket);
	}
	static handleMessage = function(_data, _socket) {
		if (struct_exists(_data, "method")) {
			if (struct_exists(_data, "id")) {
				handleRequest(_data, _socket);
			} else {
				handleNotification(_data, _socket);	
			}
			return;
		}
		if (struct_exists(_data, "result")) {
			handleResult(_data, _socket);
			return;
		}
		if (struct_exists(_data, "error")) {
			handleError(_data, _socket);
			return;
		}
		sendError(-32700, "Parse error", -1, _socket);
	}
	static handleRequest = function(_data, _socket) {
		var _method = _data.method;
		var _id = _data.id;
		if (struct_exists(handlers, _method)) {
			var _handler = handlers[$ _method];
			try {
				var _result = _handler(_data.params, _socket);
				sendResult(_result, _id, _socket);
			} catch (_error) {
				sendError(-32600, _error, _id, _socket);
			}
		} else {
			sendError(-32601, "Method not found", _id, _socket);
		}
		requests.removeElement(_id);
	}
	static handleNotification = function(_data, _socket) {
		var _method = _data.method;
		if (struct_exists(handlers, _method)) {
			var _handler = handlers[$ _method];
			_handler(_data.params, _socket);
		}
	}
	static handleResult = function(_data, _socket) {
		var _result = _data.result;
		var _id = _data.id;
		if (requests.hasElement(_id)) {
			var _request = requests.getElement(_id);
			var _callback_result = _request.runCallback(_data.result);
			_request.cancel();
			requests.removeElement(_id);
		} else {
			show_debug_message("Error -32603: Message received after timeout");	
		}
	}
	static handleError = function(_data, _socket) {
		var _error = _data.error;
		var _code = _error.code;
		var _message = _error.message;
		var _id = _data.id;
		if (requests.hasElement(_id)) {
			var _request = requests.getElement(_id);
			_request.runErrback(_error);
			_request.cancel();
			requests.removeElement(_id);
		}
	}
	/// @function registerHandler()
	/// @description
	/// This function allows associating a method with a unique name for later invocation.
	///
	/// @param {String} name - Name associated with the RPC handler.
	/// @param {Function} method - Method to be registered as the RPC handler.
	static registerHandler = function(_name, _method) {
		handlers[$ _name] = _method;
	}
	static generateID = function() {
		static increment = 0;
		increment = (increment + 1) mod 0x80000000;
		return increment;
	}
}
