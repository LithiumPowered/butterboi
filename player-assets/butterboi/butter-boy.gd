extends KinematicBody2D

const UP_DIRECTION := Vector2.UP

export var speed :=  300.0
export var acceleration := 0.3
export var friction := 0.2

export var dash_strength := 2240.0
export var dash_acceleration := 0.5
export var dash_wait_time := 0.5

export var jump_strength :=  500.0
export var maximum_jumps := 2
export var double_jump_strength := 300.0
export var gravity := 2000.0

var _jumps_made := 0
var _velocity := Vector2.ZERO
var _currently_dashing := false

onready var _animated_sprite = $"PlayerSkin"
onready var _dash_timer = $"DashTimer"

func _physics_process(delta: float) -> void:
	var _horizontal_direction = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	
	if _horizontal_direction != 0: _velocity.x = lerp(_velocity.x, _horizontal_direction * speed, acceleration)
	elif _horizontal_direction == 0: _velocity.x = lerp(_velocity.x, _horizontal_direction * speed, friction)
	_velocity.y += gravity * delta
	
	# In Air Movement
	var is_falling := _velocity.y > 0.0 and not is_on_floor()
	var is_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	var is_double_jumping := Input.is_action_just_pressed("jump") and is_falling

	# On Ground Movement
	var is_running := is_on_floor() and (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"))
	var is_idling := is_on_floor() and not is_running
	
	# Dashing
	var is_dashing = Input.is_action_just_pressed("move_dash")
	
	if is_dashing and not _currently_dashing:
		_currently_dashing = true
		_velocity.x = lerp(_velocity.x, _horizontal_direction * dash_strength, dash_acceleration)
		_dash_timer.wait_time = dash_wait_time
		_dash_timer.start()
	elif is_jumping: 
		_jumps_made += 1
		_velocity.y = -jump_strength
	elif is_double_jumping:
		_jumps_made += 1
		if _jumps_made <= maximum_jumps:
			_velocity.y = -double_jump_strength
	elif is_idling or is_running:
		_jumps_made = 0
	
	_velocity = move_and_slide(_velocity, UP_DIRECTION)
	
	# Flip character only if moving
	if not is_idling: _animated_sprite.flip_h = bool(_horizontal_direction < 0)
	
	if is_jumping or is_double_jumping: _animated_sprite.play("Jumping")
	elif is_running: _animated_sprite.play("Running")
	elif is_dashing: _animated_sprite.play("Running") # TODO add dashing animation
	elif is_falling: _animated_sprite.play("Jumping")
	elif is_idling: _animated_sprite.play("Idle")


func _on_DashTimer_timeout():
	_currently_dashing = false
