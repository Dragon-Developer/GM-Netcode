This framework is designed to simplify the setup of a GameMaker server and client.  
It uses [JSON-RPC](https://www.jsonrpc.org/specification) to invoke methods from another application.  
Below are usage instructions for creating a server and a client:

_Note: it is still in its early stages, there is still much to document and improve._

## Creating Server
1. Define a GameServer constructor that inherits from TCPServer.
```gml
function GameServer(_port) : TCPServer(_port) constructor {
    rpc.registerHandler("ping", function(_time, _socket) {
        return _time;
    });
    // Register other handlers...
}
```
2. In some create event, instantiate the server using the following code:
```gml
global.server = new GameServer(3000);
```
## Creating Client
1. Define a GameClient constructor that inherits from TCPSocket and takes the server's IP and port as parameters.
```gml
function GameClient(_ip, _port) : TCPSocket(_ip, _port) constructor {
    setEvent("connected", function() {
        // Send ping after connection is established
        rpc.sendRequest("ping", current_time, function(_previous_time) {
            // Show ping
            var _ping = current_time - _previous_time;
            show_debug_message($"{_ping} ms");
        }, function(_error) {
            // Show error message
            show_debug_message($"Error {_error.code}: {_error.message}");    
        });    
    });
}
```
2. In some create event, instantiate the client using the following code:
```gml
global.client = new GameClient("127.0.0.1", 3000);
```
## Notification Example
Notifications are requests that don't expect a response, they don't have callback/error handling.
1. Create an object called `obj_ball` with the following code in Draw Event:
```gml
draw_circle(x, y, 8, false);
```
2. Define the following handler in the GameClient constructor:
```gml
function GameClient(_ip, _port) : TCPSocket(_ip, _port) constructor {
    // [...]
    rpc.registerHandler("create_ball", function(_pos) {
        // Client received notification to create ball, then let's create the ball instance
        instance_create_depth(_pos.x, _pos.y, 0, obj_ball);
        // This handler doesn't have a return value, because it's a notification
    });
    static step = function() {
        if (mouse_check_button_pressed(mb_left)) {
            // This will send a "create_ball" notification to the server
            rpc.sendNotification("create_ball", {
                x: mouse_x,
                y: mouse_y
            });
        }
    }
}
```
3. Define the following handler in the GameServer constructor:
```gml
function GameServer(_port) : TCPServer(_port) constructor {
    // [...]
    rpc.registerHandler("create_ball", function(_pos, _socket) {
        // Server received notification to create ball, then store the ball position
        ballPosition = _pos;
        // Send "create_ball" notification to all clients
        clientManager.forEach(function(_client_socket, _client) {
            rpc.sendNotification("create_ball", ballPosition, _client_socket);
        });
    });
}
```
Start the server and multiple clients, 
then click on the screen to check if the balls appear on all clients.