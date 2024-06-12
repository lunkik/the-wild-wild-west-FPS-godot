extends CharacterBody3D

var speed = 1.0
const SPRINT_SPEED = 8.5
const WALK_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const sensitivity = 0.01
const BOB_freq = 2.0
const BOB_amp = 0.08
var t_BOB = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8
@onready var head = $head
@onready var camera = $head/Camera3D
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func  _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	



func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0.0
		velocity.z = move_toward(velocity.z, 0, speed)
		
		t_BOB += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_BOB)

	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_freq) * BOB_amp
	pos.x = cos(time * BOB_freq / 2) * BOB_amp
	return pos
