extends KinematicBody2D

const BULLET = preload("res://prefabs/player/bullet.tscn")

export var weapon : Resource setget _set_weapon

var speed := 200.0
var motion_velocity := Vector2()
var weapon_timer := 0.0


onready var animation_legs : AnimationTree = get_node("Sprite/Leg/AnimationTree")
onready var animation_body : AnimationTree = get_node("Sprite/Body/AnimationTree")
onready var animation_mode : AnimationNodeStateMachinePlayback = animation_body.get("parameters/playback")
onready var barrel : Position2D = get_node("Barrel")
onready var audio : AudioStreamPlayer = get_node("AudioStreamPlayer")

func _set_weapon(value: Resource) -> void:
	weapon = value
	update()

func _draw() -> void:
	animation_mode.travel(weapon.name)
	
	
#func _ready() -> void:
#	animation_mode.travel(weapon.name)

func _process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		motion_velocity = direction.normalized() * speed
	else:
		motion_velocity = motion_velocity.move_toward(Vector2.ZERO, speed)
	
	look_at(get_global_mouse_position())
	_animations()
	
	weapon_timer -= delta
	if Input.is_action_pressed("ui_shoot") and weapon_timer <= 0:
		weapon_timer = weapon.cooldown
		_shoot()
		
	if Input.is_action_pressed("ui_reload") and weapon.ammo < weapon.capacity and weapon.max_ammo > 0:
		_reload()
		
	
func _physics_process(delta: float) -> void:
	motion_velocity = move_and_slide(motion_velocity)

func _animations() -> void:
	animation_legs.set("parameters/blend_position", motion_velocity)
	animation_body.set("parameters/%s/blend_position" %weapon.name, motion_velocity)

func _shoot() -> void:
	if weapon.ammo:
		weapon.ammo -= 1
		animation_mode.travel("%s_shoot" % weapon.name)
		_play_sfx(weapon.shoot)
		
		var bullet = BULLET.instance()
		bullet.global_position = barrel.global_position
		bullet.rotation_degrees = rotation_degrees
		bullet.apply_impulse(Vector2(), Vector2(1000, 0).rotated(rotation))
		get_parent().add_child(bullet)
	else:
		_play_sfx(weapon.empty)
	
	print(weapon.ammo)

func _reload() -> void:
	weapon_timer = 1
	var diff = weapon.capacity - weapon.ammo
	 #Capacidade do pente 
	if weapon.max_ammo >= diff:
		weapon.max_ammo -= diff
		weapon.ammo += diff
	else:
		weapon.ammo += weapon.max_ammo
		weapon.max_ammo = 0
		
	animation_mode.travel("%s_reload" %  weapon.name)
	_play_sfx(weapon.reload)
		
	
	
func _play_sfx(sfx: AudioStream) -> void:
	audio.stream = sfx
	audio.play()
