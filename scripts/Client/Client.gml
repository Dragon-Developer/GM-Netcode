function Client() constructor {
	self.name = "";
	static setName = function(_name) {
		self.name = _name;	
	}
	static getName = function() {
		return self.name;	
	}
}