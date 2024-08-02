extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if global.game_first_loading == true:
		$player.position.x = global.player_start_posx
		$player.position.y = global.player_start_posy
	else:
		$player.position.x = global.player_exit_Starthens_posx
		$player.position.y = global.player_exit_Starthens_posy
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	change_scene()


func _on_transition_area_body_entered(body):
	if body.has_method("player"):
		global.transition_scene = true


func _on_transition_area_body_exited(body):
	if body.has_method("player"):
		global.transition_scene = false

func change_scene():
	if global.transition_scene == true:
		get_tree().change_scene_to_file("res://Scenes/starthens.tscn")
		global.game_first_loading = false
		global.finish_changescenes()
		

	

# respawn de swordmans
func _on_swordman_area_body_entered(body):
	if body.has_method("player"):
		global.player_in_chase_range = true

func _on_swordman_area_body_exited(body):
	if body.has_method("player"):
		global.player_in_chase_range = false
