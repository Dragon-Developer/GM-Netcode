function Server(_type, _port, _max_clients) constructor {
	self.socket = -1;
	self.type = _type;
	self.port = _port;
	self.maxClients = _max_clients;
	self.sockets = [];
	self.clients = new Manager();
	self.serverInstance = undefined;
	self.network = new Network();
	self.network.setType(_type);
	self.rpc = new RPC();
	self.rpc.setNetwork(network);
	self.events = {};
	static createServerInstance = function() {
		serverInstance = instance_create_depth(0, 0, 0, obj_server);
		serverInstance.server = self;
	}
	self.createServer = function() {
		return network_create_server(type, port, maxClients);
	}
	self.createClient = function() {
		return {};
	}
	static addClient = function(_socket) {
		clients.setElement(_socket, createClient());
		array_push(sockets, _socket);
		triggerEvent("connected", _socket);
	}
	static hasClient = function(_socket) {
		return clients.hasElement(_socket);	
	}
	static getClient = function(_socket) {
		return clients.getElement(_socket);	
	}
	static removeClient = function(_socket) {
		triggerEvent("disconnected", _socket);
		clients.removeElement(_socket);
		var _index = array_get_index(sockets, _socket);
		if (_index == -1) return;
		array_delete(sockets, _index, 1);
	}
	static destroy = function() {
		network_destroy(socket);
		instance_destroy(serverInstance);
		clients.clearAll();
		sockets = [];
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
		network.setDefaultSocket(socket);
		createServerInstance();
		setEvent("message", function(_msg) {
			rpc.handleMessage(_msg.data, _msg.socket);
		});
	}
	static step = function() {}
}
function ServerRAW(_type, _port, _max_clients) : Server(_type, _port, _max_clients) constructor {
	self.network.setRAW(true);
	createServer = function() {
		return network_create_server_raw(type, port, maxClients);
	}
}