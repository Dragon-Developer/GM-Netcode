timer = 0;
duration = 3*60;
dir = 1;
hspd = 0;
step = function() {
	x += hspd;
	if (timer >= duration) {
		global.game.instances.destroy(id);	
	}
}