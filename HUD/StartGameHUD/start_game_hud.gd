extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fade_in_icons() -> void:
	show()
	# Opacity 0
	# Slowly fade in

func fade_out_icons() -> void:
	# Slowly fade out: decrease opacity to 0
	hide()
