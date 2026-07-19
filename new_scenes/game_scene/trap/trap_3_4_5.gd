extends Area2D

signal cleaned

@export var clean_time: float = 1.5

var _player_in_range: bool = false
var _progress: float = 0.0
var _is_cleaned: bool = false
var _the_player: CharacterBody2D

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _frame_count: int = $AnimatedSprite2D.sprite_frames.get_frame_count("default")
@onready var _progress_bar: ProgressBar = $ProgressBar


func _ready() -> void:
	add_to_group("cleanable")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_progress_bar.max_value = 100.0
	_progress_bar.value = 0.0
	_progress_bar.visible = false


func _process(delta: float) -> void:
	if _is_cleaned:
		return

	_sprite.frame = round((_progress / clean_time) * _frame_count)

	_progress_bar.global_position = global_position + Vector2(-18, -22)

	if _player_in_range and Input.is_action_pressed("ui_accept"):
		_progress += delta / clean_time
		_progress_bar.visible = true
		_progress_bar.value = _progress * 100.0
		if _progress >= 1.0:
			_finish_cleaning()
	elif _progress > 0.0 and not Input.is_action_pressed("ui_accept"):
		_progress = maxf(_progress - delta * 0.5, 0.0)
		_progress_bar.value = _progress * 100.0
		if _progress <= 0.0:
			_progress_bar.visible = false


func _finish_cleaning() -> void:
	if _is_cleaned:
		return
	_sprite.play("eat")
	_the_player.take_damage(1)
	_is_cleaned = true
	#queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_the_player = body
		_player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_the_player = null
		_player_in_range = false
