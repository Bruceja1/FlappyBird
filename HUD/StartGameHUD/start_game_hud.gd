extends CanvasLayer

var transparency_delta : int = 7
var transparency_time_interval : float = 0.01

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fade_in_icons() -> void:
	await get_tree().create_timer(0.1).timeout
	show()
	# Opacity 0
	$Items.modulate.a8 = 0
	# Slowly fade in
	while $Items.modulate.a8 < 255:
		$Items.modulate.a8 += transparency_delta
		await get_tree().create_timer(transparency_time_interval).timeout
	
func fade_out_icons() -> void:
	# Slowly fade out: decrease opacity to 0
	while $Items.modulate.a8 > 0:
		$Items.modulate.a8 -= transparency_delta
		await get_tree().create_timer(transparency_time_interval).timeout
	hide()
