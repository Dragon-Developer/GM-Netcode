// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
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
	/*
	static syncState = function(_state) {
		array_push(stateArray, _state);
		if (onCreation) {
			updateState();
			onCreation = false;
		};
	}
	static updateState = function() {
		var _state_length = array_length(stateArray);
		var _state_max_delay = global.client.maxDelay;
		if (_state_length > _state_max_delay) {
			array_delete(stateArray, 0, _state_length - _state_max_delay);
		}
		_state_length = array_length(stateArray);
		if (_state_length > 0) {
			applyState(stateArray[0]);
			array_delete(stateArray, 0, 1);
		}
	}*/
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