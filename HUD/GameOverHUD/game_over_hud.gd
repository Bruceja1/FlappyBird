extends CanvasLayer

signal ok_button_pressed

var screen_size : Vector2 # Gets initialized via level.gd
var scoresheet_scroll_speed : int = 20
var default_scoresheet_pos : Vector2
var default_gameover_pos : Vector2
var gameover_distance : int = 10 # How far the image moves upward in the animation
var transparency_delta : int = 10
var transparency_time_interval : float = 0.02
var gameover_move_time_interval : float = 0.01

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_scoresheet_pos = $ScoreSheet/Background.position
	default_gameover_pos = $GameOver.position
	$GameOver.hide()
	$ScoreSheet.hide()
	$Buttons.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func game_over_screen(score : int) -> void:
	show_game_over()
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
	await get_tree().create_timer(0.1).timeout
	$Buttons.show()
	
func _on_ok_button_pressed() -> void:
	ok_button_pressed.emit()

# Makes elements disappear during the fadeout instead of disappearing instantly
func hide_elements() -> void:
	await get_tree().create_timer(0.1).timeout
	# await fadeout signal?
	$GameOver.hide()
	$ScoreSheet.hide()
	$Buttons.hide()

func show_game_over() -> void:
	await get_tree().create_timer(0.5).timeout
	move_game_over()
	$GameOver.show()
	$GameOver.modulate.a8 = 0
	while $GameOver.modulate.a8 < 255: # 255 is the max value; image is completely opaque
		$GameOver.modulate.a8 += transparency_delta
		await get_tree().create_timer(transparency_time_interval).timeout

func move_game_over() -> void:
	while $GameOver.position.y > default_gameover_pos.y - gameover_distance:
		$GameOver.position.y -= 1
		await get_tree().create_timer(gameover_move_time_interval).timeout
	while $GameOver.position.y < default_gameover_pos.y:
		$GameOver.position.y += 1
		await get_tree().create_timer(gameover_move_time_interval).timeout
	
