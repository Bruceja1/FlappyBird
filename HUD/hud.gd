extends CanvasLayer

var score : int = 0

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
	# Time between game over appearing and the scoresheet appearing
	await get_tree().create_timer(1.5).timeout
	$ScoreSheet.show()
	# Displayed final score starts from 0 then increments to the final score on the scoresheet
	# The higher the score, the faster it increments
	var time_per_score : float = 1 / (score + 1.0)
	var counter : int = 0
	while counter <= score:
		$ScoreSheet/ScoreLabel.text = str(counter)
		await get_tree().create_timer(time_per_score).timeout
		counter += 1
			
		 
