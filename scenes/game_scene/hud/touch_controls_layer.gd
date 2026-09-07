extends CanvasLayer

## Screen-space touch controls shown during gameplay on touch devices.

## Force visible the GUI for debugging purposes
@export var force_visible: bool = false


func _ready() -> void:
	visible = force_visible or _should_show_touch_controls()


func _should_show_touch_controls() -> bool:
	if DisplayServer.is_touchscreen_available():
		return true
	else:
		return OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")


func _on_pause_button_pressed() -> void:
	var cancel_event = InputEventAction.new()
	cancel_event.action = "ui_cancel"
	cancel_event.pressed = true
	Input.parse_input_event(cancel_event)
