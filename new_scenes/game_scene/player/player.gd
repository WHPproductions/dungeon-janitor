extends CharacterBody2D

signal died
signal health_changed(current: int, maximum: int)
var speed : float = 100.0

@export var max_health: int = 3

var health: int
var is_cleaning: bool = false

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	health = max_health
	health_changed.emit(health, max_health)


func _physics_process(_delta: float) -> void:
	if health <= 0:
		return

	is_cleaning = _is_cleaning_nearby()

	var direction := _get_movement_input()
	if direction and not is_cleaning:
		velocity = direction * speed
		_sprite.play("movement")
		_sprite.flip_h = direction.x < 0.0
	elif is_cleaning:
		velocity = Vector2.ZERO
		if $SweepSFX.playing == false:
			$SweepSFX.play()
		_sprite.play("swipe")
	else:
		velocity = Vector2.ZERO
		$SweepSFX.stop()
		_sprite.play("idle")

	move_and_slide()


func _get_movement_input() -> Vector2:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	return direction


func _is_cleaning_nearby() -> bool:
	if not Input.is_action_pressed("ui_accept"):
		return false
	for cleanable in get_tree().get_nodes_in_group("cleanable"):
		if not is_instance_valid(cleanable):
			continue
		if global_position.distance_to(cleanable.global_position) <= 14.0:
			return true
	return false

func die() -> void:
	speed = 0
	_sprite.play("death")

func take_damage(amount: int = 1) -> void:
	if health <= 0:
		die()
		return
	health = maxi(health - amount, 0)
	health_changed.emit(health, max_health)
	modulate = Color(1.5, 0.5, 0.5)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)
	if health <= 0:
		died.emit()
