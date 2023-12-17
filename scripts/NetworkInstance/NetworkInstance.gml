function NetworkInstance(_owner = other) constructor {
	owner = _owner;
	isLocal = false;
	onCreation = true;
	objectName = object_get_name(_owner.object_index);
	static sendUpdate = function(_type = "instance_state") {
		if (isLocal) {
			global.client.rpc.sendNotification(_type, {
				state: getStateData(),
				object: objectName
			});	
		}
	}
	static applyState = function(_state) {
		with (owner) {
			x = _state.x;
			y = _state.y;
			sprite_index = _state.sprite_index
			image_index = _state.image_index;
			image_xscale = _state.image_xscale;
			speed = _state.speed;
		}
	}
	static getStateData = function() {
		with (owner) {
			return {
				x: x,
				y: y,
				sprite_index: sprite_index, // not recommended
				image_index: image_index,
				image_xscale: image_xscale,
				speed: speed,
			}
		}
	}
}