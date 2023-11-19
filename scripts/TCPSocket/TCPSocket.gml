function TCPSocket(_ip, _port) constructor {
	self.events = {};
	self.socket = network_create_socket(network_socket_tcp);
	self.ip = _ip;
	self.port = _port;
	self.clientInstance = undefined;
	self.rpc = new RPC(socket);
	static setEvent = function(_event, _method) {
		events[$ _event] = _method;
	}
	static triggerEvent = function(_event) {
		if (struct_exists(events, _event)) {
			events[$ _event]();	
		}
	}
	static start = function() {
		network_connect_async(socket, ip, port);
		clientInstance = instance_create_depth(0, 0, 0, obj_client);
		clientInstance.client = self;
	}
	static destroy = function() {
		network_destroy(socket);
		instance_destroy(clientInstance);
	}
	static step = function() {	}
	self.start();
}
