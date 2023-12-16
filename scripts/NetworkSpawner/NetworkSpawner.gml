function NetworkSpawner() constructor {
	self.objectStruct = {};
	static addObject = function(_name) {
		objectStruct[$ _name] = asset_get_index(_name);
		return self;
	}
	static getObject = function(_name) {
		return objectStruct[$ _name];	
	}
	static createLocalInstance = function(_object) {
		var _inst = createInstance(_object);
		_inst.net.isLocal = true;
		return _inst;
	}
	static createInstance = function(_object) {
		var _inst = instance_create_depth(0, 0, 0, _object);
		_inst.net = new NetworkInstance(_inst);
		return _inst;
	}

}