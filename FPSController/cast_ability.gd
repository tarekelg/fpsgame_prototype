extends Node3D



@export var primary_weapon_id : int = 0 #id of the equipped primary weapon
@export var secondary_weapon_id : int = 0 #id of the equipped secondary weapon
@export var melee_weapon_id : int = 0 #id of the equipped melee weapon 
@export var active_weapon_id : int #0: primary , 1: secondary, 2: melee
#dictionary for all the different weapons stats
var hit_counter=0
var cooldown = false

signal new_hitmarker(position: Vector3 , hit_counter : int)
@export var dict_weapons={
	0:{
		"weapon_name":"Pistol",
		"weapon_type" : "secondary",
		"bullet_type" : "Raycast",
		"cooldown_time": 0.3
	},
	
	1:{
		"weapon_name":"AK47",
		"weapon_type" : "primary",
		"bullet_type" : "Raycast",
		"cooldown_time": 0.0
	},
	2:{
		"weapon_name":"Shotgun",
		"weapon_type" : "primary",
		"bullet_type" : "Raycast",
		"cooldown_time": 0.0
	},
	3:{
		"weapon_name":"Knife",
		"weapon_type" : "melee",
		"bullet_type" : "Raycast",
		"cooldown_time": 0.0
	},
	4:{
		"weapon_name":"Katana",
		"weapon_type" : "primary",
		"bullet_type" : "Raycast",
		"cooldown_time": 0.0
	},
	5:{
		"weapon_name":"Grenade Launcher",
		"weapon_type" : "primary",
		"bullet_type" : "B_Object", #Bullet Object
		"cooldown_time": 0.0
	},
	6:{
		"weapon_name":"Sniper",
		"weapon_type" : "primary",
		"bullet_type" : "Raycast",
		"cooldown_time": 0.0
	},
	7:{
		"weapon_name":"Disk Launcher",
		"weapon_type" : "primary",
		"bullet_type" : "B_Object",
		"cooldown_time": 0.0
	},
	8:{
		"weapon_name":"Laser",
		"weapon_type" : "primary",
		"bullet_type" : "Raycast",
		"cooldown_time": 0.0
	},
	9:{
		"weapon_name":"Shuriken",
		"weapon_type" : "secondary",
		"bullet_type" : "Raycast",
		"cooldown_time": 0.0
	},
}

var bullet_scene = preload("res://bullet.tscn")
var firing_rate=0.5
var timer=0.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_loadout(1,0,2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("attack"):
		
		#projectile and hit detection
		#Check if cooldown timer is stopped
		if cooldown==false:
			$CooldownTimer.start()
			cooldown=true
			if dict_weapons[active_weapon_id].bullet_type=="B_Object":
				#shoot
				#new bullet instance
				var projectile = bullet_scene.instantiate()
				add_child(projectile)	
			elif dict_weapons[active_weapon_id].bullet_type=="Raycast":
				#start the cooldown timer
				
				#Raycast
				# use raycast
				var ray_length= 40
				print_debug(get_parent_node_3d().get_child(0).name)
				var from = get_parent_node_3d().get_child(0).global_transform.origin
				var to = from + (-get_parent_node_3d().get_child(0).global_transform.basis.z*ray_length)
				print(from)
				print(to)
				
				var space_state = get_world_3d().direct_space_state
				var query = PhysicsRayQueryParameters3D.create(from, to)
				var result = space_state.intersect_ray(query)
				if result:
					print("Hit at point: ", result.position)
					emit_signal("new_hitmarker",result.position, hit_counter)	
					hit_counter=hit_counter+1
							
					#$HitDetectionObject.global_position=result.position
					#$HitDetectionObject.visible=true
				else:
					print("No Hit")
		else:
			print("Still on cooldown")

#sets the loadout > later in menu
func set_loadout(primary : int, secondary: int, melee: int) -> void:
	primary_weapon_id=primary
	secondary_weapon_id=secondary
	melee_weapon_id=melee


	


func _on_cooldown_timer_timeout() -> void:
	cooldown=false
