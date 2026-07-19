extends Area2D

signal player_exited

var _unlocked: bool = false

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _label: Label = $Label


func _ready() -> void:
	_label.global_position = global_position + Vector2(-24, -24)
	body_entered.connect(_on_body_entered)
	_set_locked()


func set_unlocked(unlocked: bool) -> void:
	_unlocked = unlocked
	if unlocked:
		_label.text = "KELUAR"
		$Sprite2D.texture.region = Rect2(145.0, 48.0, 18.0, 16.0)
	else:
		_set_locked()


func _set_locked() -> void:
	_sprite.modulate = Color(0.45, 0.45, 0.45, 0.8)
	_label.text = "TERKUNCI"


func _on_body_entered(body: Node2D) -> void:
	if not _unlocked:
		return
	if body.is_in_group("player"):
		player_exited.emit()
