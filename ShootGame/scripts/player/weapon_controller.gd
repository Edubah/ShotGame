extends Node2D

export var pistol : Resource = null
export var rifle  : Resource = null

func _process(delta) -> void:
	
	if Input.is_physical_key_pressed(KEY_1):
		get_parent().weapon = pistol
		
	if Input.is_physical_key_pressed(KEY_2):
		get_parent().weapon = rifle
