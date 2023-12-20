function LockstepInstanceManager() constructor {
	self.array = [];
	static destroy = function(_inst) {
		var _index = array_get_index(self.array, _inst);
		if (_index == -1) return;
		array_delete(self.array, _index, 1);
	}
	static beginStep = function() {
		array_foreach(self.array, function(_instance) {
			_instance.beginStep();
		});
	}
	static step = function() {
		array_foreach(self.array, function(_instance) {
			_instance.step();
			
		});
	}
	static endStep = function() {
		array_foreach(self.array, function(_instance) {
			_instance.endStep();
		});
	}
	static create = function(_x, _y, _object) {
		return self.createDepth(_x, _y, 0, _object);	
	}
	static addDefaultMethods = function(_inst) {
		_inst[$ "beginStep" ] ??= function() {};
		_inst[$ "step" ] ??= function() {};
		_inst[$ "endStep" ] ??= function() {};	
	}
	static createDepth = function(_x, _y, _depth, _object) {
		var _inst = instance_create_depth(_x, _y, _depth, _object);
		array_push(self.array, _inst);
		addDefaultMethods(_inst);
		return _inst;
	}
	static createLayer = function(_x, _y, _layer, _object) {
		var _inst = instance_create_layer(_x, _y, _layer, _object);
		array_push(self.array, _inst);
		addDefaultMethods(_inst);
		return _inst;
	}
}
