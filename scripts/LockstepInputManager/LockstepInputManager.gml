function LockstepInputManager() constructor {
	self.frameInput = {};
	self.maxFrames = 3;
	self.totalPlayers = 2;
	static setTotalPlayers = function(_total_players) {
		self.totalPlayers = _total_players;
	}
	static getTotalPlayers = function() {
		return self.totalPlayers;
	}
	static canContinue = function(_current_frame) {
		return 
			struct_exists(self.frameInput, _current_frame) &&
			struct_names_count(self.frameInput[$ _current_frame]) == self.totalPlayers;
	}
	static getInput = function(_frame, _player_index) {
		var _n = max(_frame - self.maxFrames, 0);
		return self.frameInput[$ _n][$ _player_index];
	}
	static addInput = function(_frame, _player_index, _input) {
		if (!struct_exists(self.frameInput, _frame)) {
			self.frameInput[$ _frame] = {};
		}
		self.frameInput[$ _frame][$ _player_index] = _input;
	}
}