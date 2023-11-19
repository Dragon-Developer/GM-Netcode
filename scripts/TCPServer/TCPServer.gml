function TCPServer(_port, _max_clients = 1000) constructor {
	self.socket = -1;
	self.port = _port;
	self.maxClients = _max_clients;
	self.clients = [];
	self.clientManager = new Manager();
	self.serverInstance = undefined;
	self.rpc = new RPC();
	self.events = {};
	static start = function() {
		socket = network_create_server(network_socket_tcp, port, maxClients);
		serverInstance = instance_create_depth(0, 0, 0, obj_server);
		serverInstance.server = self;
	}
	static createClient = function() {
		return {};
	}
	static addClient = function(_socket) {
		clientManager.setElement(_socket, createClient());
		triggerEvent("connected", _socket);
	}
	static hasClient = function(_socket) {
		return clientManager.hasElement(_socket);	
	}
	static getClient = function(_socket) {
		return clientManager.getElement(_socket);	
	}
	static removeClient = function(_socket) {
		triggerEvent("disconnected", _socket);
		clientManager.removeElement(_socket);
	}
	static destroy = function() {
		network_destroy(socket);
		instance_destroy(serverInstance);
		clientManager.clearAll();
	}
	static step = function() {	}
	static setEvent = function(_event, _method) {
		events[$ _event] = _method;
	}
	static triggerEvent = function(_event, _params) {
		if (struct_exists(events, _event)) {
			events[$ _event](_params);	
		}
	}
	self.start();
}