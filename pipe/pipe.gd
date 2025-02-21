extends Node2D

@export var pipe_speed : float = 2
@export var despawn_delay : float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Pipe")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	position.x -= pipe_speed

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("This pipe is off screen now!")
	await get_tree().create_timer(despawn_delay).timeout
	queue_free()
	print("This pipe is deleted now!")
	
func _on_body_entered(body: Node2D) -> void:
	if body.get_class() != "StaticBody2D":
		print("Pipe touched!")
	if body.get_class() == "CharacterBody2D":
		body.game_over()
