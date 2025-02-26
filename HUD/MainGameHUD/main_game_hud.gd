extends CanvasLayer
var score : int

signal score_updated

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_score() -> void:
	score += 1
	$ScoreLabel.text = str(score)
	score_updated.emit()

func game_over() -> void:
	# Time between getting hit and the score at the top disappearing
	await get_tree().create_timer(1).timeout
	hide()

func reset_score() -> void:
	print("SCore is being reset!")
	score = 0
	score_updated.emit()
