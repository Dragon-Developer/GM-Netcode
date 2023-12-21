function LockstepGame() constructor {
	self.instances = new LockstepInstanceManager()
	self.inputs = new LockstepInputManager();
	self.currentFrame = 0;
	self.lastInputFrame = -1;
	self.playerIndex = 0;
	self.maxInputDelay = 3;
	self.sendInput = function(_frame, _input) {};
	self.running = false;
	self.started = false;
	static getLocalInput = function() {
		return {
			left: keyboard_check(vk_left),
			right: keyboard_check(vk_right),
			up: keyboard_check(vk_up),
			down: keyboard_check(vk_down),
			attack: keyboard_check(ord("Z"))
		};
	}
	static addLocalInput = function() {
		if (self.lastInputFrame - self.currentFrame >= self.maxInputDelay) return;
		self.lastInputFrame++;
		var _input = self.getLocalInput();
		self.inputs.addInput(self.lastInputFrame, self.playerIndex, _input);
		self.sendInput(self.lastInputFrame, _input);
	}
	static getInput = function(_player_index) {
		return self.inputs.getInput(self.currentFrame, _player_index);	
	}
	static start = function() {
		self.started = true;
		self.addLocalInput();
	}
	static runCurrentFrame = function() {
		if (!self.running) return;
		self.instances.beginStep();
		self.instances.step();
		self.instances.endStep();
		self.inputs.removeFrame(self.currentFrame);
		self.currentFrame++;
	}
	static step = function() {
		if (!started) return;
		self.running = (self.running && self.inputs.canContinue(self.currentFrame))
					|| (self.inputs.canContinue(self.lastInputFrame));
		self.runCurrentFrame();
		self.addLocalInput();
	}
}
