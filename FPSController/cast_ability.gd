extends Node3D

@export var weapon_type : int = 1 #1 : primary, 2 : secondary, 3 : melee
@export var primary_weapon_id : int = 0 #id of the equipped primary weapon
@export var secondary_weapon_id : int = 0 #id of the equipped secondary weapon
@export var melee_weapon_id : int = 0 #id of the equipped melee weapon 


var bullet_scene = preload("res://bullet.tscn")
var firing_rate=0.5
var timer=0.5

@export var projectile_type_id : int = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if Input.is_action_just_pressed("attack"):
		
		
		if projectile_type_id == 0:
			#shoot
			#new bullet instance
			var projectile = bullet_scene.instantiate()
			add_child(projectile)
			
		else:
			#Raycast
			# use raycast
			var ray_length= 40
			
			var from = get_parent_node_3d().get_parent_node_3d().get_child(0).global_transform.origin
			var to = from + (-get_parent_node_3d().get_parent_node_3d().get_child(0).global_transform.basis.z*ray_length)
			print(from)
			print(to)
			
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var result = space_state.intersect_ray(query)
			if result:
				print("Hit at point: ", result.position)
			else:
				print("No Hit")
	
	


	
