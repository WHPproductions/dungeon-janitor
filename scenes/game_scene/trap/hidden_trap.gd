extends Area2D

@export var damage: int = 1

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("trap")

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		$AnimatedSprite2D.play("active")
		body.take_damage(damage)
