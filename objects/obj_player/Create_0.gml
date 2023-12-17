// Is me?
isMe = false;

// Setup
mask_index = spr_blastalot_idle;

// Network
net = new NetworkInstance();
net.isLocal = true;

// Declare methods
event_user(15);

// Sprite management
sprites = {};
spriteSettings = {
	prefixes: {
		normal: "",
		shoot: "_shoot"
	},
	actions: [
		"idle",
		"jump",
		"fall",
		"run"
	]
}
animationType = "normal";
typePrefix = {
	normal: "",
	shoot: "_shoot",
};
initSprites("blastalot", spriteSettings);

// Variables
spd = 1.5;
hspd = 0;
vspd = 0;
vspdMax = 10;

jspd = 10;
gravGround = .5;	// Normal gravity
grav = gravGround;

face = 1;

animation = "idle";

sendTimer = 0;
sendTimerInterval = 1;

stateArray = [];

shooting = false;
shootTimer = 0;
shootDuration = 10;

// Input
input = {};
checkInput();

onCreation = true;

// State Machine
fsm = new SnowState("idle", false);

fsm
	.history_enable()
	.history_set_max_size(20)
	.event_set_default_function("draw", function() {
		if (isMe) {
			draw_sprite(spr_player_arrow, 0, x, y - 24);
		}
		draw_sprite_ext(sprite_index, image_index, x, y, face * image_xscale, image_yscale, image_angle, image_blend, image_alpha);
	})
	.add("idle", {
		enter: function() {
			animationPlay("idle");
			setSpeed(0, 0);
		},
		step: function() {
			applyGravity();
			moveAndCollide();
		}
	})
	.add("run", {
		enter: function() {
			animationPlay("run");
		},
		step: function() {
			setMovement();
			applyGravity();
			moveAndCollide();
		}
	})
	.add("jump", {
		enter: function() {
			animationPlay("jump");
			vspd = -jspd;
		},
		step: function() {
			setMovement();
			applyGravity();
			moveAndCollide();
		}
	})
	.add("fall", {
		enter: function() {
			animationPlay("fall");			
		},
		step: function() {
			setMovement();
			applyGravity();
			moveAndCollide();
		}
	})
	.add_transition("t_run", "idle", "run")
	.add_transition("t_jump", ["idle", "run"], "jump")
	.add_transition("t_transition", ["idle", "run"], "fall", function() { return !onGround(); })
	.add_transition("t_transition", "jump", "fall", function() { return (vspd >= 0); })
	.add_transition("t_transition", "run", "idle", function() { return (input.hdir == 0); })
	.add_transition("t_transition", "fall", "idle", function() { return onGround(); })