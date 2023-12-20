function LockstepGame() constructor {
	self.instances = new LockstepInstanceManager()
	self.inputs = new LockstepInputManager();
	self.currentFrame = 0;
	self.playerIndex = 0;
	self.sendInput = function(_frame, _input) {};
	self.running = false;
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
		var _input = self.getLocalInput();
		self.inputs.addInput(self.currentFrame, self.playerIndex, _input);
		self.sendInput(self.currentFrame, _input);
	}
	static getInput = function(_player_index) {
		return self.inputs.getInput(self.currentFrame, _player_index);	
	}
	static start = function() {
		self.addLocalInput();
	}
	static step = function() {
		if (!self.inputs.canContinue(self.currentFrame - self.inputs.maxFrames)) {
			self.running = false;
		}
		if (self.inputs.canContinue(self.currentFrame)) {
			self.running = true;	
		}
		if (!self.running) return;
		self.instances.beginStep();
		self.instances.step();
		self.instances.endStep();
		self.currentFrame++;
		self.addLocalInput();
	}
}
