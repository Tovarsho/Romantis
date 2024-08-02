extends CharacterBody2D

# Variables.
var enemy_in_attack_range = false  # Indica si el enemigo está en rango de ataque
var enemy_attack_cooldown = true  # Controla el tiempo de enfriamiento entre ataques del enemigo
var npc_in_range = false  # Indica si hay un NPC en rango
var attack_in_progress = false  # Indica si un ataque está en progreso
const speed = 150  # Velocidad del jugador
var current_dir = "none"  # Dirección actual del jugador

func _ready():
	# Se ejecuta cuando el nodo está listo
	$AnimatedSprite2D.play("front_idle")  # Reproduce la animación de estar en reposo mirando al frente

func _physics_process(_delta):
	# Procesa la lógica física del juego
	player_movement()  # Llama a la función de movimiento del jugador
	enemy_attack()  # Llama a la función de ataque del enemigo
	attack()  # Llama a la función de ataque del jugador
	update_health()  # Actualiza la barra de salud
	update_player_name()  # Actualiza el nombre del jugador
	death()  # Verifica si el jugador está muerto
	npc_dialog()  # Llama a la función de diálogo con NPCs

# Función de muerte del jugador
func death():
	if global.current_health <= 0: # si la vida actual es menor o igual a 0 hara lo siguiente
		global.player_alive = false  # Marca al jugador como muerto
		global.current_health = 0  # Establece la salud actual en 0
		$AnimatedSprite2D.play("death_animation")  # Reproduce la animación de muerte
		await get_tree().create_timer(2).timeout  # Espera 2 segundos antes de continuar

# Movimiento del jugador
func player_movement():
	if global.player_alive == true: #si el player esta vivo hara lo siguiente
		if Input.is_action_pressed("ui_right"): #si la tecla asignada a "ui_right" es presionada hara lo siguiente
			current_dir = "right"  # Establece la dirección actual a la derecha
			play_anim(1)  # Reproduce la animación de caminar hacia la derecha
			velocity.x = speed  # Establece la velocidad en el eje x
			velocity.y = 0  # Establece la velocidad en el eje y a 0
		elif Input.is_action_pressed("ui_left"): #si la tecla asignada a "ui_left" es presionada hara lo siguiente
			current_dir = "left"  # Establece la dirección actual a la izquierda
			play_anim(1)  # Reproduce la animación de caminar hacia la izquierda
			velocity.x = -speed  # Establece la velocidad en el eje x a negativa
			velocity.y = 0  # Establece la velocidad en el eje y a 0
		elif Input.is_action_pressed("ui_down"): #si la tecla asignada a "ui_down" es presionada hara lo siguiente
			current_dir = "down"  # Establece la dirección actual hacia abajo
			play_anim(1)  # Reproduce la animación de caminar hacia abajo
			velocity.y = speed  # Establece la velocidad en el eje y
			velocity.x = 0  # Establece la velocidad en el eje x a 0
		elif Input.is_action_pressed("ui_up"): #si la tecla asignada a "ui_up" es presionada hara lo siguiente
			current_dir = "up"  # Establece la dirección actual hacia arriba
			play_anim(1)  # Reproduce la animación de caminar hacia arriba
			velocity.y = -speed  # Establece la velocidad en el eje y a negativa
			velocity.x = 0  # Establece la velocidad en el eje x a 0
		else:
			play_anim(0)  # Reproduce la animación de estar en reposo
			velocity.x = 0  # Establece la velocidad en el eje x a 0
			velocity.y = 0  # Establece la velocidad en el eje y a 0
	move_and_slide()  # Mueve el jugador basado en la velocidad

# Animaciones de movimiento
func play_anim(movement):
	var dir = current_dir  # Dirección actual del jugador
	var anim = $AnimatedSprite2D  # Referencia al nodo de animación
	
	if dir == "right":
		anim.flip_h = false  # No voltea la animación horizontalmente
		if movement == 1:
			anim.play("side_walk")  # Reproduce la animación de caminar hacia la derecha
		elif movement == 0:
			if attack_in_progress == false:
				anim.play("side_idle")  # Reproduce la animación de estar en reposo mirando a la derecha
	
	if dir == "left":
		anim.flip_h = true  # Voltea la animación horizontalmente
		if movement == 1:
			anim.play("side_walk")  # Reproduce la animación de caminar hacia la izquierda
		elif movement == 0:
			if attack_in_progress == false:
				anim.play("side_idle")  # Reproduce la animación de estar en reposo mirando a la izquierda
	
	if dir == "down":
		anim.flip_h = false  # No voltea la animación horizontalmente
		if movement == 1:
			anim.play("front_walk")  # Reproduce la animación de caminar hacia abajo
		elif movement == 0:
			if attack_in_progress == false:
				anim.play("front_idle")  # Reproduce la animación de estar en reposo mirando hacia abajo
	
	if dir == "up":
		anim.flip_h = false  # No voltea la animación horizontalmente
		if movement == 1:
			anim.play("back_walk")  # Reproduce la animación de caminar hacia arriba
		elif movement == 0:
			if attack_in_progress == false:
				anim.play("back_idle")  # Reproduce la animación de estar en reposo mirando hacia arriba

# Método de jugador (vacío)
func player():
	pass

# Detección del enemigo

# Entrada al área de ataque del jugador
func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_in_attack_range = true  # Marca al enemigo como en rango de ataque

# Salida del área de ataque del jugador
func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_in_attack_range = false  # Marca al enemigo como fuera de rango de ataque

# Manejo del ataque enemigo
func enemy_attack():
	if enemy_in_attack_range and enemy_attack_cooldown and global.player_alive == true: # si el enemigo esta en rango, no tiene temporizador de ataque y el jugador este vivo
		global.current_health = global.current_health - 1  # Reduce la salud del jugador en el valor seleccionado
		print("player hp ", global.current_health)
		enemy_attack_cooldown = false  # Desactiva el enfriamiento de ataque del enemigo
		$damage_cooldown.start()  # Inicia el temporizador de enfriamiento de daño
		print(global.current_health)

# Temporizador de ataque enemigo
func _on_damage_cooldown_timeout():
	enemy_attack_cooldown = true  # Activa el enfriamiento de ataque del enemigo

# Funciones de ataque del jugador
func attack():
	var dir = current_dir  # Dirección actual del jugador
	
	if Input.is_action_just_pressed("attack"): # si la tecla asignada para el "attack" es presionada hara lo siguiente
		global.player_current_attack = true  # Indica que el jugador está atacando
		attack_in_progress = true  # Marca que un ataque está en progreso
		if dir == "right": #si la direccion actual es derecha hara lo siguiente
			$AnimatedSprite2D.flip_h = false  # No voltea la animación horizontalmente
			$AnimatedSprite2D.play("side_attack")  # Reproduce la animación de ataque hacia la derecha
			$attack_cooldown.start()  # Inicia el temporizador de enfriamiento de ataque
		if dir == "left": #si la direccion actual es izquierda hara lo siguiente
			$AnimatedSprite2D.flip_h = true  # Voltea la animación horizontalmente
			$AnimatedSprite2D.play("side_attack")  # Reproduce la animación de ataque hacia la izquierda
			$attack_cooldown.start()  # Inicia el temporizador de enfriamiento de ataque
		if dir == "down": #si la direccion actual es abajo hara lo siguiente
			$AnimatedSprite2D.flip_h = false  # No voltea la animación horizontalmente
			$AnimatedSprite2D.play("front_attack")  # Reproduce la animación de ataque hacia abajo
			$attack_cooldown.start()  # Inicia el temporizador de enfriamiento de ataque
		if dir == "up": #si la direccion actual es arriba hara lo siguiente
			$AnimatedSprite2D.flip_h = false  # No voltea la animación horizontalmente
			$AnimatedSprite2D.play("back_attack")  # Reproduce la animación de ataque hacia arriba
			$attack_cooldown.start()  # Inicia el temporizador de enfriamiento de ataque

# Cooldown del ataque
func _on_attack_cooldown_timeout():
	$attack_cooldown.stop()  # Detiene el temporizador de enfriamiento de ataque
	global.player_current_attack = false  # Marca que el jugador no está atacando
	attack_in_progress = false  # Marca que no hay un ataque en progreso

# Funciones de vida
func update_health():
	var healthbar = $Healthbar #asigna el valor de la variable healthbar a la barra de progresion $healthbar
	healthbar.value = global.current_health  # Actualiza el valor de la barra de salud
	healthbar.max_value = global.max_health  # Actualiza el valor máximo de la barra de salud
	
	var health_ratio = global.current_health / float(global.max_health)
	if health_ratio <= 0.15: #si el porcentaje es igual o menor a 15% hara lo siguiente
		healthbar.modulate = Color.DARK_RED  # Cambia el color de la barra de salud a rojo oscuro
	elif health_ratio <= 0.33: #si el porcentaje es igual o menor a 33% hara lo siguiente
		healthbar.modulate = Color.RED  # Cambia el color de la barra de salud a rojo
	elif health_ratio <= 0.66: #si el porcentaje es igual o menor a 66% hara lo siguiente
		healthbar.modulate = Color.YELLOW  # Cambia el color de la barra de salud a amarillo
	elif health_ratio <= 0.95: #si el porcentaje es igual o menor a 95% hara lo siguiente
		healthbar.modulate = Color.GREEN_YELLOW  # Cambia el color de la barra de salud a verde amarillento
	else:
		healthbar.modulate = Color.GREEN  # Cambia el color de la barra de salud a verde

# Función de regeneración de vida
func _on_regen_timer_timeout():
	if global.player_alive == true: #si el juagdor esta vivo hara lo siguiente
		if global.current_health < global.max_health: #si la vida actual es menor a la vida maxima hara lo siguiente
			global.current_health = global.current_health + 1  # Incrementa la salud del jugador
			if global.current_health > global.max_health: #si la vida actual es mayor que la vida maxima hara lo siguiente
				global.current_health = global.max_health  # Ajusta la salud al máximo si se excede
		if global.current_health <= 0: #si la vida actual es menor o igual a 0 asignara lo siguiente
			global.current_health = 0  # Asegura que la salud no sea negativa

# Nombre del jugador
func update_player_name():
	var playername = $Playername #asigna el valor de la variable playername a la etiqueta $Playername
	playername.text = global.player_name  # Actualiza el texto del nombre del jugador

# Detectar NPCs

# Entrada al área de detección de NPCs
func _on_npc_detection_area_body_entered(body):
	if body.has_method("npc"): #Si el cuerpo que entro tiene metodo "npc" hara lo siguiente
		npc_in_range = true  # Marca al NPC como en rango

# Salida del área de detección de NPCs
func _on_npc_detection_area_body_exited(body):
	if body.has_method("npc"): #Si el cuerpo que salio tiene metodo "npc" hara lo siguiente
		npc_in_range = false  # Marca al NPC como fuera de rango

# Comenzar diálogo con NPC
func npc_dialog():
	if npc_in_range == true: #si el npc esta en rango hara lo siguiente
		if Input.is_action_just_pressed("ui_accept"): # si la tecla asignada para el "ui_accept" es presionada hara lo siguiente
			DialogueManager.show_example_dialogue_balloon(load("res://Scripts/npcpedro.dialogue"), "start")  # Inicia el diálogo con el NPC que esta en esa direccion
			return  # Termina la función aquí
