extends Area2D

@export var damage: int = 1
@export var active_duration: float = 1.2
@export var inactive_duration: float = 1.8

var _is_active: bool = false
var _damaged_players: Dictionary = {}

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _cycle_timer: Timer = $CycleTimer


func _ready() -> void:
	_cycle_timer.timeout.connect(_toggle_active)
	_set_active(true)
	_cycle_timer.start(active_duration)


func _process(_delta: float) -> void:
	if not _is_active:
		return
	
	_damage_players_in_area()


func _toggle_active() -> void:
	_set_active(not _is_active)
	_damaged_players.clear()
	_cycle_timer.start(active_duration if _is_active else inactive_duration)


func _set_active(active: bool) -> void:
	_is_active = active
	if active:
		_sprite.play("active")
	else:
		_sprite.play("idle")

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
