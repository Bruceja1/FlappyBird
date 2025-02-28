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
var sparkle_loop_time_interval : float = 0.5
var sparkle_range : int = 20 # Max distance from default position the sparkle can appear
var default_sparkle_pos : Vector2
var random_sparkle_x_pos : int
var random_sparkle_y_pos : int
var sparkle_loop_done : bool = true # Prevents _process() from calling move_sparkle()
									 # when still in the middle of an animation loop

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_scoresheet_pos = $ScoreSheet/Background.position
	default_gameover_pos = $GameOver.position
	default_sparkle_pos = Vector2($Badges/Gold.position + $Badges/Gold.size / 2)
	$Badges/Silver.position = $Badges/Gold.position
	$Badges/Silver.size = $Badges/Gold.size
	$Badges/Bronze.position = $Badges/Gold.position
	$Badges/Bronze.size = $Badges/Gold.size
	$GameOver.hide()
	$ScoreSheet.hide()
	$Buttons.hide()
	hide_badge()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_sparkle()

func game_over_screen(score : int, goldscore : int, silverscore : int, bronzescore: int) -> void:
	show_game_over()
	$MenuSelectSound.play()
	# Time between game over appearing and the scoresheet appearing
	await get_tree().create_timer(1).timeout

	# Code below makes scoresheet appear, moves it up and displays the final score
	$ScoreSheet.show()
	$ScoreSheet/BestScoreLabel.text = str(goldscore)
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

	# Time between scoresheet appearing and buttons and badges appearing
	await get_tree().create_timer(0.1).timeout
	$Buttons.show()
	show_badge(score, goldscore, silverscore, bronzescore)
	
func show_badge(score : int, goldscore : int, silverscore : int, bronzescore: int) -> void:
	if score == 0:
		return
	if score == goldscore:
		$Badges/Gold.show()
		$Badges/Sparkle.show()
	elif score == silverscore:
		$Badges/Silver.show()
		$Badges/Sparkle.show()
	elif score == bronzescore:
		$Badges/Bronze.show()
		$Badges/Sparkle.show()
	
func hide_badge() -> void:
	$Badges/Gold.hide()
	$Badges/Silver.hide()
	$Badges/Bronze.hide()
	$Badges/Sparkle.hide()

func move_sparkle() -> void:
	if !sparkle_loop_done:
		return
	sparkle_loop_done = false
	$Badges/Sparkle.play()
	await get_tree().create_timer(sparkle_loop_time_interval).timeout
	# Move to random new spot
	random_sparkle_x_pos = randi_range(default_sparkle_pos.x - sparkle_range, default_sparkle_pos.x + sparkle_range)
	random_sparkle_y_pos = randi_range(default_sparkle_pos.y - sparkle_range, default_sparkle_pos.y + sparkle_range)
	$Badges/Sparkle.position = Vector2(random_sparkle_x_pos, random_sparkle_y_pos)
	sparkle_loop_done = true

func _on_ok_button_pressed() -> void:
	ok_button_pressed.emit()

# Makes elements disappear during the fadeout instead of disappearing instantly
func hide_elements() -> void:
	await get_tree().create_timer(0.1).timeout
	$GameOver.hide()
	$ScoreSheet.hide()
	$Buttons.hide()
	hide_badge()

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
	
