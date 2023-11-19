function WebSocketServer(_port, _max_clients = 1000) 
: Server(network_socket_ws, _port, _max_clients) constructor {
	self.start();
}
function WebSocketServerRAW(_port, _max_clients = 1000) 
: ServerRAW(network_socket_ws, _port, _max_clients) constructor {
	self.start();
}