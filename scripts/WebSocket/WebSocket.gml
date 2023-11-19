function WebSocket(_ip, _port) 
: Socket(network_socket_ws, _ip, _port) constructor {
	self.start();
}

function WebSocketRAW(_ip, _port) 
: SocketRAW(network_socket_ws, _ip, _port) constructor {
	self.start();
}
