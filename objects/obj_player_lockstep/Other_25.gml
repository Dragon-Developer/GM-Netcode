init = function(_id) {
	playerIndex = _id;
	if (global.game.playerIndex != playerIndex) return;
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
	var _input = global.game.getInput(playerIndex);
	with (input) {
		self[$ "attack"] ??= false;
		attackPressed = !attack && _input.attack
		hdir	= _input.right - _input.left;
		jump	= _input.up;
		attack	= _input.attack
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

shootProjectile = function(_object) {
	var _inst = global.game.instances.createDepth(x, y, depth - 10, _object);
	_inst.image_xscale = face;
	_inst.hspd = face * 6;
}