extends Area2D

signal player_exited

var _unlocked: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func set_unlocked(unlocked: bool) -> void:
	_unlocked = unlocked
	if unlocked:
		$Sprite2D.texture.region = Rect2(145.0, 48.0, 16.0, 16.0)


func _on_body_entered(body: Node2D) -> void:
	if not _unlocked:
		return
	if body.is_in_group("player"):
		player_exited.emit()
