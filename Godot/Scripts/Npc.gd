extends CharacterBody2D
var npc_name = "Pedro"

func _physics_process(_delta):
	update_npc_name()
	$AnimatedSprite2D.play("idle")
	
func update_npc_name():
	var npcname = $npcname
	npcname.text = npc_name

func npc():
	pass
