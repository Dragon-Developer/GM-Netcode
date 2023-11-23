# GM Netcode
This library is designed to simplify the setup of a GameMaker server and client.  
It uses [JSON-RPC](https://www.jsonrpc.org/specification) to invoke methods from another application but you can disable it if needed.  

_Note: it is still in its early stages, there is still much to document and improve._

Server classes:
- TCPServer
- TCPServerRAW
- WebSocketServer ([bug](https://github.com/YoYoGames/GameMaker-Bugs/issues/2109))
- WebSocketServerRAW

Socket classes (client):
- TCPSocket
- TCPSocketRAW
- WebSocket ([bug](https://github.com/YoYoGames/GameMaker-Bugs/issues/2109))
- WebSocketRAW

You must use the same socket type in server and client.  
Below are usage instructions for creating a server and a client:  

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
    // Client received notification to create ball
    rpc.registerHandler("create_ball", function(_pos) {
        // Create the ball instance
        instance_create_depth(_pos.x, _pos.y, 0, obj_ball);
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
    // Server received notification to create ball
    rpc.registerHandler("create_ball", function(_pos, _socket) {
        // Send "create_ball" notification to all clients
        rpc.sendNotification("create_ball", _pos, sockets);
    });
}
```
Start the server and multiple clients, 
then click on the screen to check if the balls appear on all clients.
## Example without RPC
If you don't want to use RPC, override the "message" event on server/client.
1. Disabling RPC on GameServer:
```gml
function GameServer(_port) : TCPServer(_port) constructor {
    // Disable RPC by setting the message event
    setEvent("message", function(_message) {
        var _data = _message.data;
        var _socket = _message.socket;
        // If the message type is "create_ball"
        if (_data.type == "create_ball") {
            // Send this data to all clients
            network.sendData(_data, sockets);
        }
    });
}
```
2. Disable RPC on GameClient:
```gml
function GameClient(_ip, _port) : TCPSocket(_ip, _port) constructor {
    // Disable RPC by setting the message event
    setEvent("message", function(_message) {
        var _data = _message.data;
        // If the message type is "create_ball"
        if (_data.type == "create_ball") {
            // Create the ball instance
            instance_create_depth(_data.x, _data.y, 0, obj_ball);
        }
    });
    static step = function() {
        if (mouse_check_button_pressed(mb_left)) {
            // Send message to create ball
            network.sendData({
                type: "create_ball",
                x: mouse_x,
                y: mouse_y
            });
        }
    }
}
```