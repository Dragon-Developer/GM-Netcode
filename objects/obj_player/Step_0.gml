if (!isMe) {
	return;
}
checkInput();

fsm.step();
fsm.trigger("t_transition");
if (abs(input.hdir)) fsm.trigger("t_run");
if (input.jump) fsm.trigger("t_jump");
x = clamp(x, 8, room_width - 8);

if (input.attack) {
	shootTimer = 0;
	shooting = true;
	shootProjectile(obj_shot);
	animationType = "shoot";
}

if (shooting) {
	shootTimer++;
	if (shootTimer >= shootDuration) {
		shootTimer = 0;
		shooting = false;
		animationType = "normal";
	}
}
animationUpdateType();

sendTimer--;
if (sendTimer <= 0) {
	sendTimer = sendTimerInterval;
	net.sendUpdate("player_state");
}
if (bbox_top >= room_height) {
	x = xstart;
	y = ystart;
}