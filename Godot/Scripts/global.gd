extends Node

var player_current_attack = false

var current_scene = "World"
var transition_scene = false

var player_exit_Starthens_posx = 768.4
var player_exit_Starthens_posy = 10
var player_start_posx = 398
var player_start_posy = 102

var player_in_chase_range = false

var current_health = 6
var max_health = 10
var player_alive = true
var player_name = "Amilcar"

var game_first_loading = true

func finish_changescenes():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "world":
			current_scene = "starthens"
		else:
			current_scene = "world"

