extends Node

signal level_lost
signal level_won(level_path: String)
@warning_ignore("unused_signal")
signal level_changed(level_path: String)

## Optional path to the next level if using an open world level system.
@export_file("*.tscn") var next_level_path: String
@export var shift_duration_seconds: float = 90.0

var level_state: LevelState

var _total_cleanables: int = 0
var _cleaned_count: int = 0
var _time_left: float = 0.0
var _ended: bool = false

@onready var _exit_door: Area2D = %ExitDoor
@onready var _player: CharacterBody2D = %Player
@onready var _hud: Control = %ShiftHUD
@onready var _cleanables_layer: TileMapLayer = $Cleanables
@onready var _traps_layer: TileMapLayer = $Traps


func _ready() -> void:
	level_state = GameState.get_level_state(scene_file_path)
	_time_left = shift_duration_seconds
	_cleanables_layer.update_internals()
	_traps_layer.update_internals()
	_count_cleanables()
	_connect_cleanables()
	_connect_player()
	_exit_door.player_exited.connect(_on_player_exited)
	_update_hud()
	if not level_state.tutorial_read:
		open_tutorials()


func _process(delta: float) -> void:
	if _ended:
		return
	_time_left -= delta
	_update_hud()
	if _time_left <= 0.0 and _get_clean_ratio() < 1.0:
		_end_level(false)


func open_tutorials() -> void:
	%TutorialManager.open_tutorials()
	level_state.tutorial_read = true
	GlobalState.save()


func _count_cleanables() -> void:
	_total_cleanables = get_tree().get_nodes_in_group("cleanable").size()
	_cleaned_count = 0


func _connect_cleanables() -> void:
	for cleanable in get_tree().get_nodes_in_group("cleanable"):
		if cleanable.has_signal("cleaned"):
			cleanable.cleaned.connect(_on_cleanable_cleaned)


func _connect_player() -> void:
	_player.died.connect(_on_player_died)
	_player.health_changed.connect(_on_player_health_changed)


func _on_cleanable_cleaned() -> void:
	_cleaned_count += 1
	_update_hud()
	if _get_clean_ratio() >= 1.0:
		_exit_door.set_unlocked(true)


func _on_player_died() -> void:
	_end_level(false)


func _on_player_exited() -> void:
	if _get_clean_ratio() >= 1.0:
		_end_level(true)


func _on_player_health_changed(current: int, maximum: int) -> void:
	_hud.update_health(current, maximum)


func _get_clean_ratio() -> float:
	if _total_cleanables <= 0:
		return 1.0
	return float(_cleaned_count) / float(_total_cleanables)


func _update_hud() -> void:
	_hud.update_timer(_time_left)
	_hud.update_clean_progress(_get_clean_ratio())
	if is_instance_valid(_player):
		_hud.update_health(_player.health, _player.max_health)


func _end_level(won: bool) -> void:
	if _ended:
		return
	_ended = true
	set_process(false)
	if won:
		level_won.emit(next_level_path)
	else:
		level_lost.emit()
	_show_end_overlay(won)


func _show_end_overlay(won: bool) -> void:
	var ui_layer: CanvasLayer = get_node_or_null("ui")
	if ui_layer == null:
		return

	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.65)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(overlay)

	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 24)
	label.text = "Shift selesai!\nPintu keluar aman." if won else "Shift gagal!\nCoba lagi?"
	ui_layer.add_child(label)

	if won and not next_level_path.is_empty():
		var next_timer := get_tree().create_timer(1.5)
		next_timer.timeout.connect(func() -> void:
			get_tree().change_scene_to_file(next_level_path)
		)
	elif not won:
		var retry_timer := get_tree().create_timer(2.0)
		retry_timer.timeout.connect(func() -> void:
			get_tree().reload_current_scene()
		)
