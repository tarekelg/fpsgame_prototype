extends CharacterBody3D

#signals
signal weapon_switched(weapon_name: String)

# Movement
const MAX_VELOCITY_AIR = 0.6
const MAX_VELOCITY_GROUND = 6.0
const MAX_ACCELERATION = 10 * MAX_VELOCITY_GROUND
const GRAVITY = 15.34
const STOP_SPEED = 1.5
const JUMP_IMPULSE = sqrt(2 * GRAVITY * 0.85)
const PLAYER_WALKING_MULTIPLIER = 0.666
const PLAYER_CROUCHING_MULTIPLIER = 0.5
const PLAYER_HEIGHT=1.8
const PLAYER_HEIGHT_FACTOR=0.75
const PLAYER_CROUCHING_HEIGHT=1.35


var direction = Vector3()
var friction = 4
var wish_jump
var walking = false

# crouching
var is_crouching = false
var target_height 
var current_height
var crouch_move_speed: float = 3.0
var equipped=0


# Camera
var sensitivity = 0.05

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	target_height=PLAYER_HEIGHT
	current_height=PLAYER_HEIGHT
	$CrouchShape.disabled=true
	$CrouchShape.visible=false
	
func _input(event):
	# Mouse lock
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_pressed("mouse_left"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Camera rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_handle_camera_rotation(event)
	
func _handle_camera_rotation(event: InputEvent):
	# Rotate the camera based on the mouse movement
	rotate_y(deg_to_rad(-event.relative.x * sensitivity))
	$Head.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
	
	# Stop the head from rotating to far up or down
	$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-60), deg_to_rad(90))
	
func _physics_process(delta):
	process_input()
	process_movement(delta)
	#print("Player position:", global_position)
	#print("Camera position:", $Head/Camera3D.global_position)
	#print("Head Node position:", $Head.global_position)
	#print("target_height:", target_height)
	#print("current_height:", current_height)
	
func process_input():
	direction = Vector3()
	
	# Movement directions
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	if Input.is_action_pressed("crouch"):
		target_height= PLAYER_CROUCHING_HEIGHT
		is_crouching=true
	else:
		target_height=PLAYER_HEIGHT
		is_crouching=false
	if Input.is_action_just_pressed("toggle_camera"):
		if $Head/Camera3D.current==true:
			$Head/Camera3D.current=false
			$DebugCam.current=true
			$DebugCam1.current=false
		elif $DebugCam.current==true:
			$Head/Camera3D.current=false
			$DebugCam.current=false
			$DebugCam1.current=true
		elif $DebugCam1.current==true:
			$Head/Camera3D.current=true
			$DebugCam.current=false
			$DebugCam1.current=false

	# Jumping
	wish_jump = Input.is_action_just_pressed("jump")
	
	# Walking
	walking = Input.is_action_pressed("walk")
	
	# Crouching
	#crouching = Input.is_action_pressed("crouch")
	
func process_movement(delta):
	# Get the normalized input direction so that we don't move faster on diagonals
	var wish_dir = direction.normalized()
	
	if is_on_floor():
		
		adjust_head_height(delta)
		# If wish_jump is true then we won't apply any friction and allow the 
		# player to jump instantly, this gives us a single frame where we can 
		# perfectly bunny hop
		if wish_jump:
			velocity.y = JUMP_IMPULSE
			# Update velocity as if we are in the air
			velocity = update_velocity_air(wish_dir, delta)
			wish_jump = false
		elif walking:
			velocity.x *= PLAYER_WALKING_MULTIPLIER
			velocity.z *= PLAYER_WALKING_MULTIPLIER
		elif is_crouching:
			velocity.x *=PLAYER_CROUCHING_MULTIPLIER
			velocity.z *=PLAYER_CROUCHING_MULTIPLIER
			
		
			
		velocity = update_velocity_ground(wish_dir, delta)
		
		
	else:
		# Only apply gravity while in the air
		velocity.y -= GRAVITY * delta
		velocity = update_velocity_air(wish_dir, delta)
		if is_crouching:
			jump_crouch()

	# Move the player once velocity has been calculated
	move_and_slide()
	
func accelerate(wish_dir: Vector3, max_speed: float, delta):
	# Get our current speed as a projection of velocity onto the wish_dir
	var current_speed = velocity.dot(wish_dir)
	# How much we accelerate is the difference between the max speed and the current speed
	# clamped to be between 0 and MAX_ACCELERATION which is intended to stop you from going too fast
	var add_speed = clamp(max_speed - current_speed, 0, MAX_ACCELERATION * delta)
	
	return velocity + add_speed * wish_dir
	
func update_velocity_ground(wish_dir: Vector3, delta):
	# Apply friction when on the ground and then accelerate
	var speed = velocity.length()
	
	if speed != 0:
		var control = max(STOP_SPEED, speed)
		var drop = control * friction * delta
		
		# Scale the velocity based on friction
		velocity *= max(speed - drop, 0) / speed
	
	return accelerate(wish_dir, MAX_VELOCITY_GROUND, delta)
	
func update_velocity_air(wish_dir: Vector3, delta):
	# Do not apply any friction
	return accelerate(wish_dir, MAX_VELOCITY_AIR, delta)

func adjust_head_height(delta):
	# Camera Movement
	
	current_height=lerp(current_height, target_height, delta* 10.0)
	#checks if there is an object above the player
	
	if current_height>target_height:
		print("target_height:", target_height)
		print("current_height:", current_height)
		print("current_height > target_height")
		# Change Shape
		#$CollisionShape3D.disabled=true
		#$CrouchShape.disabled=false
		$Head.position.y=current_height
		$CollisionShape3D.shape.height=current_height
		$CollisionShape3D/MeshInstance3D.mesh.height=current_height
	else: 
		
		#print(position)
		if try_stand():
			$Head.position.y=current_height
			$CollisionShape3D.shape.height=current_height
			$CollisionShape3D/MeshInstance3D.mesh.height=current_height


func try_stand():
	# Cast a ray upward to check if there is space to stand
	
	var space_check = PhysicsRayQueryParameters3D.create($Head.global_position,$Head.global_position+Vector3(0,PLAYER_HEIGHT-PLAYER_CROUCHING_HEIGHT,0))
	
	var collision = get_world_3d().direct_space_state.intersect_ray(space_check)
	if collision.is_empty():
		return true
	else:
		return false
	#$CrouchShape.disabled=true
	#$CollisionShape3D.disabled=false

func jump_crouch():
	$CollisionShape3D.shape.height=PLAYER_CROUCHING_HEIGHT
	$CollisionShape3D/MeshInstance3D.mesh.height=PLAYER_CROUCHING_HEIGHT

# handles not specified Input
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		#check if weapon switch occured
		if int(OS.get_keycode_string(event.keycode))>0 and int(OS.get_keycode_string(event.keycode))<4:
			switch_weapon(int(OS.get_keycode_string(event.keycode)))

#Handles weapon switch
#type 1 : primary, 2 : secondary, 3 : Melee
func switch_weapon(type : int):
	
	# Setting Weapon name in the HUD
	var current_weapon :String
	if type == 1:
		current_weapon="primary"
		# Switching Bullet Type
		# Bullet object for now
		$Head/Hand0/CastPoint.projectile_type_id=0
	elif type ==2:
		current_weapon="secondary"
		# Switching Bullet Type
		# Raycast for now
		$Head/Hand0/CastPoint.projectile_type_id=1
	elif type ==3:
		current_weapon="melee"
		
	emit_signal("weapon_switched",current_weapon)
	
	

	
