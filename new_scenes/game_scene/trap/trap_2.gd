extends Area2D

@export var damage: int = 1
@export var countdown: float = 3

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _current_countdown: float 
var _is_active: bool = false
var _the_player: CharacterBody2D

func _process(delta: float) -> void:
	if _is_active:
		_current_countdown -= delta
		$Label.text = str(int(ceil(_current_countdown)))
	
	if _current_countdown <= 0:
		explode()

func _ready() -> void:
	$Label.global_position = global_position + Vector2(-20, -27)
	_current_countdown = countdown
	add_to_group("trap")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	else:
		_is_active = true
		_the_player = body
		$Label.visible = true

func _on_body_exited(body: Node2D) -> void:
	_the_player = null

func explode() -> void:
	_current_countdown = countdown
	_is_active = false
	$Label.visible = false
	$AnimatedSprite2D.play("active")
	if _the_player:
		_the_player.take_damage(damage)


func _on_animated_sprite_2d_animation_finished() -> void:
	$AnimatedSprite2D.play("idle")
