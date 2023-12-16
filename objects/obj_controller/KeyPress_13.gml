global.server = new GameServer(3000);
instance_create_depth(0, 0, 0, obj_server_status);
instance_destroy();
room_goto(rm_lobby);