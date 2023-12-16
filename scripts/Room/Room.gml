function change_room(_room, _something) {
	var _inst = instance_create_depth(0, 0, 0, obj_room_change);
	_inst.desiredRoom = _room;
	_inst.callback = _something;
	room_goto(_room);
}