extends CharacterBody2D

signal collide

var min_speed = 100

@export var speed_val = 8000
@export var jump_force = 400
@export var max_speed = 600
@export var friction = 2000
@export var gravity_vec = Vector2(0, 1000)
@export var max_grav = 600

var base_jump_ability = 10
var jumb_spend = 1
var jump_ability = base_jump_ability
var in_jump = false
var can_dash = true
var dash_power = 1200
var dash_vel = Vector2.ZERO
var cur_dash_power = 0

var screen_size
var collide_vector = Vector2.ZERO

func apply_friction(speed, friction_coof) -> Vector2:
	var frictioned = speed - speed.clamp(Vector2(-INF, 0), Vector2(INF, 0)).normalized() * friction_coof
	
	if frictioned.dot(speed) <= 0:
		return speed.clamp(Vector2(0, -INF), Vector2(0, INF))
	
	return frictioned
	
func apply_friction_with_grav(speed, friction_coof) -> Vector2:
	var frictioned = speed - speed.normalized() * friction_coof
	
	if frictioned.dot(speed) <= 0:
		return Vector2.ZERO
	
	return frictioned
	
func apply_dash(dash, speed, max_dash) -> Vector2:
	return dash + (speed * (max_dash - dash.length()) / max_dash)

func _physics_process(delta):
	var inp_velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		inp_velocity.x += 1
	if Input.is_action_pressed("move_left"):
		inp_velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		inp_velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		inp_velocity.y += 1
		
	if Input.is_action_pressed("dash") and can_dash:
		can_dash = false
		dash_vel = inp_velocity.normalized() * dash_power
	
	if Input.is_action_pressed("jump") and (is_on_floor() or jump_ability > 0 and in_jump):
		velocity += Vector2.UP * jump_force * jump_ability / base_jump_ability
		in_jump = true
		jump_ability -= jumb_spend
	else:
		in_jump = false
		
			
	if inp_velocity.length() > 0:
		velocity += inp_velocity.clamp(Vector2.LEFT, Vector2.RIGHT) * speed_val * delta
		
	velocity = velocity.clamp(Vector2(-max_speed, -max_grav), Vector2(max_speed, max_grav))
		
	var friction_coof = 1
	
	if not is_on_floor():
		velocity += gravity_vec * delta
	else:
		jump_ability = base_jump_ability
		can_dash = true

	if inp_velocity.length() == 0:
		velocity = apply_friction(velocity, delta * friction * friction_coof)
	
	velocity = apply_dash(dash_vel, velocity, dash_power)
	
	dash_vel = apply_friction_with_grav(dash_vel, delta * friction)

	move_and_slide()
	# position = position.clamp(Vector2.ZERO, screen_size)
		
	if velocity.length() < min_speed:
		pass # velocity = Vector2.ZERO
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(_body):
	collide.emit(_body.position - position)
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)


func _on_collide(vector) -> void:
	collide_vector = vector
