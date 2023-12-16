initMe = function() {
	// Init only for local player
	isMe = true;
	if (!is_undefined(global.camera)) {
		global.camera.target = id;
	}
}

initSprites = function(_character, _settings) {
	animations = {};
	character = _character;
	struct_foreach(_settings.prefixes, method({ this: other, settings: _settings}, function(_type, _prefix) {
		var _current_animation = {
			prefix: _prefix,
			sprites: {}
		};
		this.animations[$ _type] = _current_animation;
		array_foreach(settings.actions, method({ this: this, currentAnimation: _current_animation }, function(_action) {
			currentAnimation.sprites[$ _action] = asset_get_index($"spr_{this.character}_{_action}{currentAnimation.prefix}");
		}));
	}));
}

setSpeed = function(_hspd, _vspd) {
	hspd = _hspd;
	vspd = _vspd;
}

getSprite = function() {
	return animations[$ animationType].sprites[$ fsm.get_current_state()];
}

animationPlay = function(_animation = getSprite(), _speed = 1) {
	animation = _animation;
	sprite_index = animations[$ animationType].sprites[$ _animation];
	image_index = 0;
	image_speed = _speed;
}

animationUpdateType = function() {
	sprite_index = animations[$ animationType].sprites[$ animation];
}

checkInput = function() {
	with (input) {
		hdir	= max(keyboard_check(ord("D")), keyboard_check(vk_right)) -
				  max(keyboard_check(ord("A")), keyboard_check(vk_left));
		jump	= max(keyboard_check_pressed(ord("W")), keyboard_check_pressed(vk_up));
		attack	= max(keyboard_check_pressed(ord("Z")));
	}
};

onGround = function() {
	return (place_meeting(x, y + 1, obj_block));	
};

applyGravity = function() {
	vspd = min(vspd + grav, vspdMax);
};

setMovement = function() {
	var _dir = input.hdir;
	hspd = spd * _dir;
	if (_dir != 0) face = _dir;
};

moveAndCollide = function() {
	if (place_meeting(x + hspd, y, obj_block)) {
		while (!place_meeting(x + sign(hspd), y, obj_block)) x += sign(hspd);
		hspd = 0;
	}
	x += hspd;
	if (place_meeting(x, y + vspd, obj_block)) {
		while (!place_meeting(x, y + sign(vspd), obj_block)) y += sign(vspd);
		vspd = 0;
	}
	y += vspd;
};

net.applyState = function(_state) {
	x = _state.x;
	y = _state.y;
	animationType = _state.animationType;
	animationPlay(_state.animation, _state.image_speed);
	image_index = _state.image_index;
	face = _state.face;	
}

net.getStateData = function() {
	return {
		x: x,
		y: y,
		animationType: animationType,
		animation: animation,
		image_index: image_index,
		image_speed: image_speed,
		face: face
	}
}

shootProjectile = function(_object) {
	var _inst = global.client.spawner.createLocalInstance(_object);
	_inst.x = x;
	_inst.y = y;
	_inst.depth = depth - 10;
	_inst.image_xscale = face;
	_inst.speed = face * 6;
	_inst.net.sendUpdate();
}