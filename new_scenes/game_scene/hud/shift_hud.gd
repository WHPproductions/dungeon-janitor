extends Control

@onready var _timer_label: Label = %TimerLabel
@onready var _clean_label: Label = %CleanLabel
@onready var _hp_label: Label = %HPLabel
@onready var _clean_bar: ProgressBar = %CleanBar
@onready var _hp_bar: ProgressBar = %HPBar


func update_timer(seconds_left: float) -> void:
	var total_seconds := maxi(int(ceil(seconds_left)), 0)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	_timer_label.text = "Shift: %02d:%02d" % [minutes, seconds]
	if seconds_left <= 15.0:
		_timer_label.modulate = Color(1.0, 0.35, 0.35)
	else:
		_timer_label.modulate = Color(1.0, 1.0, 1.0)


func update_clean_progress(ratio: float) -> void:
	var percent := int(round(ratio * 100.0))
	_clean_label.text = "Bersih: %d%%" % percent
	_clean_bar.value = percent


func update_health(current: int, maximum: int) -> void:
	_hp_label.text = "HP: %d/%d" % [current, maximum]
	_hp_bar.max_value = maximum
	_hp_bar.value = current
