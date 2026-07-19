extends Area2D

@export var damage: int = 1
@export var active_duration: float = 1.2
@export var inactive_duration: float = 1.8

var _is_active: bool = false
var _damaged_bodies: Dictionary = {}

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _cycle_timer: Timer = $CycleTimer


func _ready() -> void:
	add_to_group("trap")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_cycle_timer.timeout.connect(_toggle_active)
	_set_active(true)
	_cycle_timer.start(active_duration)


func _toggle_active() -> void:
	_set_active(not _is_active)
	_damaged_bodies.clear()
	_cycle_timer.start(active_duration if _is_active else inactive_duration)


func _set_active(active: bool) -> void:
	_is_active = active
	if active:
		_sprite.play("active")
	else:
		_sprite.play("idle")


func _on_body_entered(body: Node2D) -> void:
	if not _is_active:
		return
	if not body.is_in_group("player"):
		return
	if _damaged_bodies.has(body.get_instance_id()):
		return
	_damaged_bodies[body.get_instance_id()] = true
	if body.has_method("take_damage"):
		body.take_damage(damage)


func _on_body_exited(body: Node2D) -> void:
	_damaged_bodies.erase(body.get_instance_id())
