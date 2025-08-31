extends Node3D

var BULLET_SPEED = 5 

const KILL_TIMER=10
var timer = 0
var hit_something = false
var projectile_type_id : int = 0
@export var bullet_type : int =0 #Bullet object : 0, raycast : 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var velocity=Vector3.FORWARD * BULLET_SPEED 
	
	if projectile_type_id ==0:
		translate(velocity)
		
		timer += delta
		if timer >= KILL_TIMER:
			queue_free()
	else:
		
		# use raycast
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(Vector3.FORWARD, Vector3.FORWARD*20)
		var result = space_state.intersect_ray(query)
		if result:
			print("Hit at point: ", result.position)

		
		
	
