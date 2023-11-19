function Server(_type, _port, _max_clients) constructor {
	self.socket = -1;
	self.type = _type;
	self.port = _port;
	self.maxClients = _max_clients;
	self.clients = [];
	self.clientManager = new Manager();
	self.serverInstance = undefined;
	self.rpc = new RPC();
	self.rpc.network.setType(_type);
	self.events = {};
	static createServerInstance = function() {
		serverInstance = instance_create_depth(0, 0, 0, obj_server);
		serverInstance.server = self;
	}
	createServer = function() {
		show_message("SERVER NON RAW");
		return network_create_server(type, port, maxClients);
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
	static setEvent = function(_event, _method) {
		events[$ _event] = _method;
	}
	static triggerEvent = function(_event, _params) {
		if (struct_exists(events, _event)) {
			events[$ _event](_params);	
		}
	}
	static start = function() {
		socket = createServer();
		createServerInstance();
	}
	static step = function() {}
}
function ServerRAW(_type, _port, _max_clients) : Server(_type, _port, _max_clients) constructor {
	self.rpc.network.setRAW(true);
	createServer = function() {
		show_message("SOCKET RAW");
		return network_create_server_raw(type, port, maxClients);
	}
}