function Socket(_type, _ip, _port) constructor {
	self.events = {};
	self.socket = -1;
	self.type = _type;
	self.ip = _ip;
	self.port = _port;
	self.clientInstance = undefined;
	self.rpc = undefined;
	self.connect = function() {
		network_connect_async(socket, ip, port);	
		show_message("SOCKET NON RAW");
	}
	static setType = function(_type) {
		type = _type;	
	}
	static setEvent = function(_event, _method) {
		events[$ _event] = _method;
	}
	static triggerEvent = function(_event) {
		if (struct_exists(events, _event)) {
			events[$ _event]();	
		}
	}
	static start = function() {
		socket = network_create_socket(type);
		rpc = new RPC(socket);
		rpc.network.setType(type);
		connect();
		clientInstance = instance_create_depth(0, 0, 0, obj_client);
		clientInstance.client = self;
	}
	static destroy = function() {
		network_destroy(socket);
		instance_destroy(clientInstance);
	}
	static step = function() {	}
}
function SocketRAW(_type, _ip, _port) : Socket(_type, _ip, _port) constructor {
	self.connect = function() {
		self.rpc.network.setRAW(true);
		network_connect_raw_async(socket, ip, port);	
		show_message("SOCKET RAW");
	}
}
