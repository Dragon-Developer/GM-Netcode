function RPCRequest(_id, _timeout, _parent) constructor {
	self.requestID = _id;
	self.parent = _parent;
	self.callbacks = [[]];
	self.errbacks = [];
	self.finallyMethod = undefined;
	self.errorLevel = 0;
	self.runLevel = 0;
	static onCallback = function(_callback) {
		array_push(self.callbacks[self.errorLevel], _callback);
		return self;
	}
	static onError = function(_errback) {
		array_push(self.errbacks, _errback);
		self.errorLevel += 1;
		if (self.errorLevel >= array_length(self.callbacks)) { 
			self.callbacks[self.errorLevel] = [];
		}
		return self;
	}
	static onFinally = function(_finally) {
		self.finallyMethod = _finally;
		return self;
	}
	static copy = function(_request) {
		self.runLevel = _request.runLevel;
		self.callbacks = _request.callbacks;
		self.errbacks = _request.errbacks;
		self.onFinally(_request.finallyMethod);
	}
	static runCallback = function(_params) {
		if (runLevel < array_length(callbacks) && array_length(callbacks[runLevel]) > 0) {
			var _callback_array = callbacks[runLevel];
			var _callback = _callback_array[0];
			if (is_method(_callback)) {
				var _callback_result = _callback(_params);
				if (is_struct(_callback_result) && is_instanceof(_callback_result, RPCRequest)) {
					array_delete(_callback_array, 0, 1);
					_callback_result.copy(self);
					return;
				}
			}
		}
		self.runFinally();	
	}
	static runErrback = function(_error) {
		if (runLevel < array_length(errbacks)) {
			var _errback = errbacks[runLevel];
			if (is_method(_errback)) {
				var _error_result = _errback(_error);
				if (is_struct(_error_result) && is_instanceof(_error_result, RPCRequest)) {
					runLevel++;
					_error_result.copy(self);
					return;
				}
			}
		}
		self.runFinally();	
	}
	static runFinally = function() {
		if (!is_method(finallyMethod)) return;
		self.finallyMethod();
	}
	self.call = call_later(_timeout, time_source_units_seconds, function() {
		var _requests = parent.requests;
		if (!_requests.hasElement(requestID)) return;
		var _request = _requests.getElement(requestID);
		var _error = {
			code: -32603,
			message: "Timeout error"
		};
		_request.runErrback(_error);
		_requests.removeElement(requestID);
	});
	static cancel = function() {
		call_cancel(call);	
	}
}