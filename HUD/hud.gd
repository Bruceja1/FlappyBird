extends CanvasLayer

var score : int = 0
# Gets set by the level script
var screen_size : Vector2
var scoresheet_scroll_speed : int = 20


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ScoreLabel.text = str(score)
	$GameOver.hide()
	$ScoreSheet.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_score() -> void:
	score += 1
	$ScoreLabel.text = str(score)
	
func game_over() -> void:
	# Time between getting hit and the score at the top disappearing
	await get_tree().create_timer(1).timeout
	$ScoreLabel.hide()
	$GameOver.show()
	$MenuSelectSound.play()
	# Time between game over appearing and the scoresheet appearing
	await get_tree().create_timer(1.5).timeout
	$ScoreSheet.show()
	$MenuSelectSound.play()
	
	# When the scoresheet appears, it scrolls from the bottom to the middle of the screen
	# So first put the scoresheet at the bottom
	for item in $ScoreSheet.get_children():
		item.position.y += screen_size.y
	var original_y_pos : int = $ScoreSheet/Background.position.y - screen_size.y
	# Move the scoresheet upwards
	while $ScoreSheet/Background.position.y >= original_y_pos:
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
			
		 
