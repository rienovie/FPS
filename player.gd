extends CharacterBody3D

@onready var head = $"Head (pivot)"
@onready var cam = $"Head (pivot)/Camera3D"

var currentSpeed = 50
var direction = Vector3.ZERO
var currentDampValue = 1.0
var camTiltValue = deg_to_rad(2)
var defaultFOV = 90.0
var fovMod = 5

@export var walkSpeed = 500
@export var sprintSpeed = 600
@export var mouseSensitivity = 0.075
@export var moveSmoothing = 20
@export var lookTiltSmoothing = 15
@export var airDamping = 0.125
@export var jumpVelocity = 6.75

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-deg_to_rad(event.relative.x * mouseSensitivity))
		head.rotate_x(-deg_to_rad(event.relative.y * mouseSensitivity))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	
	if Input.is_action_pressed("sprint"):
		currentSpeed = sprintSpeed
	else:
		currentSpeed = walkSpeed

	if not is_on_floor():
		velocity.y -= gravity * delta
		currentDampValue = airDamping
	else:
		currentDampValue = 1.0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpVelocity

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	direction = lerp(direction,(transform.basis * (Vector3(input_dir.x, 0, input_dir.y)).normalized()),delta * moveSmoothing * currentDampValue)
	if direction:
		velocity.x = direction.x * currentSpeed * delta
		velocity.z = direction.z * currentSpeed * delta
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed) * delta
		velocity.z = move_toward(velocity.z, 0, currentSpeed) * delta
		
	#rotate the camera slightly in the direction you're moving
	if abs(input_dir.x) > 0.5:
		head.rotation.z = lerp(head.rotation.z, camTiltValue * (-1.0 * sign(input_dir.x)), delta * lookTiltSmoothing)
	else:
		head.rotation.z = lerp(head.rotation.z, 0.0, delta * lookTiltSmoothing)
	
	
	# Tried this but it didn't really feel that great, might try again when there's more gameplay
	
	#if abs(input_dir.y) > 0.5:
		#cam.fov = lerp(cam.fov,defaultFOV + (fovMod * sign(input_dir.y)),delta * 10)
	#else:
		#cam.fov = lerp(cam.fov,defaultFOV,delta * 10)

	move_and_slide()
