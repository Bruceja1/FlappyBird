extends CanvasLayer

signal paused
signal unpaused

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_elements()
	$UnPauseButton.position = $PauseButton.position
	$UnPauseButton.size = $PauseButton.size
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_score(score : int) -> void:
	$ScoreLabel.text = str(score)

func game_over() -> void:
	$PauseButton.hide()
	# Time between getting hit and the score at the top disappearing
	await get_tree().create_timer(0.5).timeout
	hide_elements()

func _on_pause_button_pressed() -> void:
	paused.emit()

func _on_unpause_button_pressed() -> void:
	unpaused.emit()

# This function is needed instead of $MainGameHUD.show() because pause button is hidden
# separately in game_over(). Otherwise The pause button won't appear on game start.
func show_elements() -> void:
	$PauseButton.show()
	$ScoreLabel.show()

func hide_elements() -> void:
	$PauseButton.hide()
	$ScoreLabel.hide()
	$UnPauseButton.hide()
