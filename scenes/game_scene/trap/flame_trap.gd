extends Area2D

@export var damage: int = 1
@export var countdown: float = 2.3

var _current_countdown: float 
var _is_countdown_active: bool = false
var _is_fire_active: bool = false
var _damaged_players: Dictionary = {}

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _fire_particle: GPUParticles2D = $GPUParticles2D
@onready var _countdown_timer: Timer = $CountdownTimer


func _process(delta: float) -> void:
	if _is_countdown_active:
		_current_countdown -= delta
		var color_substraction : float = _current_countdown / countdown
		_sprite.self_modulate = Color(1, color_substraction, color_substraction)
	
	if _current_countdown <= 0:
		combust()
	
	if _is_fire_active:
		_damage_players_in_area()

func _ready() -> void:
	_countdown_timer.wait_time = countdown
	_countdown_timer.timeout.connect(extinguish)
	_current_countdown = countdown

func combust() -> void:
	_current_countdown = countdown
	_countdown_timer.start()
	_fire_particle.emitting = true
	_is_fire_active = true
	_is_countdown_active = false

func extinguish() -> void:
	_sprite.self_modulate = Color(1, 1, 1)
	_fire_particle.emitting = false
	_is_fire_active = false


func _damage_players_in_area() -> void:
	var players_in_area: Dictionary[int, bool]
	
	for body in get_overlapping_bodies():
		if not body.is_in_group("player"):
			continue
	
		var player_id := body.get_instance_id()
		players_in_area[player_id] = true
		if _damaged_players.has(player_id):
			continue
		if not body.has_method("take_damage"):
			continue
	
		_damaged_players[player_id] = true
		body.take_damage(damage)
	
	for player_id in _damaged_players.keys():
		if not players_in_area.has(player_id):
			_damaged_players.erase(player_id)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_is_countdown_active = true
