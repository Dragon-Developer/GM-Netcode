function EntityManager() constructor {
	self.prefix = "";
	self.entities = {};
	static setPrefix = function(_prefix) {
		self.prefix = _prefix;	
	}
	static generateID = function() {
		static count = 0;
		count++;
		return $"{self.prefix}_{count}";
	}
	static set = function(_id, _instance) {
		self.entities[$ _id] = _instance;
	}
	static get = function(_id) {
		if (struct_exists(self.entities, _id)) {
			var _inst = self.entities[$ _id];
			if (instance_exists(_inst))
				return _inst;
		}
		return noone;
	}
	static has = function(_id) {
		return (self.get(_id) != noone);
	}
	static remove = function(_id) {
		var _inst = self.get(_id);
		if (_inst == noone) return;
		instance_destroy(_inst);
		struct_remove(self.entities, _id);
	}
	static update = function(_id, _data, _method) {
		var _inst = self.get(_id);
		if (_inst == noone) return;
		_method(_inst, _data);
	}
}