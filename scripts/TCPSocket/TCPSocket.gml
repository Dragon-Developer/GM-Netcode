function TCPSocket(_ip, _port) 
: Socket(network_socket_tcp, _ip, _port) constructor {
	self.start();
}

function TCPSocketRAW(_ip, _port) 
: SocketRAW(network_socket_tcp, _ip, _port) constructor {
	self.start();
}
