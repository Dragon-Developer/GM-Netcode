timer++;
net.step();
if (timer >= duration) {
	instance_destroy();	
}