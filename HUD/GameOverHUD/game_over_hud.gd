extends CanvasLayer

signal ok_button_pressed

var screen_size : Vector2
var scoresheet_scroll_speed : int = 20
var default_scoresheet_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_scoresheet_pos = $ScoreSheet/Background.position
	$GameOver.hide()
	$ScoreSheet.hide()
	$Buttons.hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func game_over_screen(score : int) -> void:
	$GameOver.show()
	$MenuSelectSound.play()
	# Time between game over appearing and the scoresheet appearing
	await get_tree().create_timer(1).timeout

	# Code below makes scoresheet appear, moves it up and displays the final score
	$ScoreSheet.show()
	$MenuSelectSound.play()
	
	# When the scoresheet appears, it scrolls from the bottom to the middle of the screen
	# So first put the scoresheet at the bottom
	for item in $ScoreSheet.get_children():
		item.position.y += screen_size.y
		
	# Move the scoresheet upwards
	while $ScoreSheet/Background.position.y >= default_scoresheet_pos.y:
		await get_tree().create_timer(0.0001).timeout
		for item in $ScoreSheet.get_children():
			if !item.name.begins_with("Background"):
				item.position.y -= scoresheet_scroll_speed
		$ScoreSheet/Background.position.y -= scoresheet_scroll_speed
		
	# Displayed final score on the scoresheet starts from 0 then increments towards the final score
	# The higher the score, the faster it increments
	var time_per_score : float = 1 / (score + 1.0)
	var counter : int = 0
	while counter <= score:
		$ScoreSheet/ScoreLabel.text = str(counter)
		await get_tree().create_timer(time_per_score).timeout
		counter += 1

	# Time between scoresheet appearing and buttons appearing
	await get_tree().create_timer(1).timeout
	$Buttons.show()
	
	

func _on_ok_button_pressed() -> void:
	$MenuSelectSound.play()
	await get_tree().create_timer(0.2).timeout
	# Signal will be received by the level script to trigger game reset
	ok_button_pressed.emit()
