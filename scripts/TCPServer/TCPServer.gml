function TCPServer(_port, _max_clients = 1000) 
: Server(network_socket_tcp, _port, _max_clients) constructor {
	self.start();
}
function TCPServerRAW(_port, _max_clients = 1000) 
: ServerRAW(network_socket_tcp, _port, _max_clients) constructor {
	self.start();
}