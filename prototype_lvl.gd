extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



# Called when signal weapon_switched is emitted from Player Controller
func _on_character_body_3d_weapon_switched(weapon_name: String) -> void:
	#Used to show which Weapon is chosen for debugging > no view models needed
	$HUD/WeaponLabel.text=weapon_name
	


func _on_character_body_3d_new_hitmarker(new_position: Vector3, hit_counter :int) -> void:
	if hit_counter ==0:
		$HitMarker.global_position=new_position
		$HitMarker.visible=true
	else:
		var next_hitmarker=$HitMarker.duplicate()
		next_hitmarker.global_position=new_position
		next_hitmarker.visible=true
		add_child(next_hitmarker)
		
