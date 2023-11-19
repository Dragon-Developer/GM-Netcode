function RPC(_socket) constructor {
	self.requests = new Manager();
	self.handlers = {};
	self.socket = _socket;
	self.timeout = 5;
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
		global.network.sendData(_data, _socket);
	}
	static sendRequest = function(_method, _params, _callback, _errback, _socket = socket, _timeout = timeout) {
		var _id = generateID();
		sendJSON({
			"method": _method,
			"params": _params,
			"id": _id
		}, _socket);
		requests.setElement(_id, new RPCRequest(_id, _callback, _errback, _timeout, self));
	}
	static sendNotification = function(_method, _params, _socket = socket) {
		sendJSON({
			"method": _method,
			"params": _params
		}, _socket);
	}
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
			var _call = _request.callback;
			if (is_method(_call)) {
				_call(_data.result);
			}
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
			var _call = _request.errback;
			if (is_method(_call)) {
				_call(_error);
			}
			_request.cancel();
			requests.removeElement(_id);
		}
	}
	static registerHandler = function(_name, _method) {
		handlers[$ _name] = _method;
	}
	static generateID = function() {
		static increment = 0;
		increment = (increment + 1) mod 0x80000000;
		return increment;
	}
}
function RPCRequest(_id, _callback, _errback, _timeout, _parent) constructor {
	self.requestID = _id;
	self.parent = _parent;
	self.callback = _callback;
	self.errback = _errback;
	self.call = call_later(_timeout, time_source_units_seconds, function() {
		var _requests = parent.requests;
		if (!_requests.hasElement(requestID)) return;
		var _call = _requests.getElement(requestID).errback;
		var _error = {
			code: -32603,
			message: "Timeout error"
		};
		if (is_method(_call)) {
			_call(_error);
		}
		_requests.removeElement(requestID);
	});
	static cancel = function() {
		call_cancel(call);	
	}
}
	