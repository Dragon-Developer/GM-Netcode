function Socket(_type, _ip, _port) constructor {
	self.connected = false;
	self.events = {};
	self.socket = -1;
	self.type = _type;
	self.ip = _ip;
	self.port = _port;
	self.clientInstance = undefined;
	self.rpc = undefined;
	self.network = new Network();
	self.connect = function() {
		network_connect_async(socket, ip, port);	
	}
	static setType = function(_type) {
		type = _type;	
	}
	static setEvent = function(_event, _method) {
		events[$ _event] = _method;
	}
	static triggerEvent = function(_event, _params) {
		if (struct_exists(events, _event)) {
			events[$ _event](_params);	
		}
	}
	static start = function() {
		socket = network_create_socket(type);
		network.setDefaultSocket(socket);
		rpc = new RPC(socket);
		rpc.setNetwork(network);
		network.setType(type);
		connect();
		clientInstance = instance_create_depth(0, 0, 0, obj_client);
		clientInstance.client = self;
		setEvent("message", function(_msg) {
			rpc.handleMessage(_msg.data, _msg.socket);
		});
	}
	static destroy = function() {
		network_destroy(socket);
		instance_destroy(clientInstance);
	}
}
function SocketRAW(_type, _ip, _port) : Socket(_type, _ip, _port) constructor {
	self.connect = function() {
		self.network.setRAW(true);
		network_connect_raw_async(socket, ip, port);	
	}
}
