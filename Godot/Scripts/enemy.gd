extends CharacterBody2D

# Variables
var speed = 35  # Velocidad de movimiento del enemigo
@export var target: Node2D = null  # El objetivo que el enemigo perseguirá, normalmente el jugador
@onready var navigation_agent_2d = $NavigationAgent2D  # Referencia al nodo NavigationAgent2D
var health = 10  # Salud del enemigo
var player_in_attack_range = false  # Bandera para verificar si el jugador está en el rango de ataque
var alive = true  # Bandera para verificar si el enemigo está vivo
var can_take_damage = true  # Bandera para controlar si el enemigo puede recibir daño
var initial_position : Vector2  # Posición inicial del enemigo
var local_player_chase = false # variable local para activar la persecucion del jugador

func _ready():
	initial_position = global_position  # Guardamos la posición inicial del enemigo
	call_deferred("pathfinding")  # Llamamos a la función pathfinding después de que todo esté listo
	$AnimatedSprite2D.play("idle_front")  # Reproducimos la animación de idle al frente
	alive = true # Inicializamos la variable alive true

func _physics_process(_delta):
	deal_with_damage()  # Llamamos a la función que maneja el daño recibido
	move_and_slide()  # Movemos el enemigo
	death() # Llamamos la funcion de muerte
	_navigation()
# Crea el camino para atacar al jugador
func pathfinding():
	await get_tree().physics_frame  # Esperamos un frame de física
	if target and global.player_in_chase_range and local_player_chase == true:
		# Si hay un objetivo y el enemigo debe perseguir, establecemos la posición objetivo del agente de navegación
		navigation_agent_2d.target_position = target.global_position
	else:
		# Si no, el objetivo es la posición inicial del enemigo
		navigation_agent_2d.target_position = initial_position

# Crea el movimiento y la animación
func _navigation():
	if target and global.player_in_chase_range and local_player_chase == true:
		# Si hay un objetivo y el enemigo debe perseguir, establecemos la posición objetivo del agente de navegación
		navigation_agent_2d.target_position = target.global_position
	else:
		# Si no, el objetivo es la posición inicial del enemigo
		navigation_agent_2d.target_position = initial_position
	
	if navigation_agent_2d.is_navigation_finished():
		return  # Si la navegación ha terminado, salimos de la función

	var current_agent_position = global_position  # Obtenemos la posición actual del agente
	var nexth_path_position = navigation_agent_2d.get_next_path_position()  # Obtenemos la siguiente posición en el camino
	velocity = current_agent_position.direction_to(nexth_path_position) * speed  # Calculamos la velocidad en la dirección del siguiente punto en el camino
	move_and_slide()  # Movemos el enemigo

	# Cambiamos la animación según la dirección de la velocidad
	if velocity.x < 0:
		$AnimatedSprite2D.play("walk_left")
	elif velocity.x > 0:
		$AnimatedSprite2D.play("walk_right")
	elif velocity.y < 0:
		$AnimatedSprite2D.play("walk_back")
	elif velocity.y > 0:
		$AnimatedSprite2D.play("walk_front")
# Función del enemigo (actualmente vacía)
func enemy():
	pass
func death():
	if health <= 0:
		alive = false
		health = 0
		speed = 0
		$AnimatedSprite2D.play("death")
		await get_tree().create_timer(3).timeout
		queue_free()

# Área de ataque del enemigo
# Detección de entrada al área
func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		player_in_attack_range = true  # Si el cuerpo que entró tiene el método "player", el jugador está en rango de ataque

# Detección de salida del área
func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_in_attack_range = false  # Si el cuerpo que salió tiene el método "player", el jugador ya no está en rango de ataque

# Función para recibir daño
func deal_with_damage():
	if player_in_attack_range and global.player_current_attack == true:
		if can_take_damage == true:
			health = health - 2  # Reducimos la salud del enemigo
			can_take_damage = false  # Desactivamos la capacidad de recibir daño temporalmente
			$take_damage_cooldown.start()  # Iniciamos el temporizador de cooldown para recibir daño
			print("monster hp ", health)
			if health <= 0:
				alive = false  # Si la salud llega a 0, marcamos al enemigo como muerto

# Temporizador para poder recibir daño nuevamente
func _on_take_damage_cooldown_timeout():
	can_take_damage = true  # Permitimos que el enemigo pueda recibir daño nuevamente

# Detección de enemigos 
func _on_detection_area_body_entered(body):
	if body.has_method("player") and alive and global.player_in_chase_range == true:
		local_player_chase = true # Si el cuerpo que entró es el jugador y está en rango de persecución, activamos la persecución
		
func _on_detection_area_body_exited(body):
	if body.has_method("player") or alive or global.player_in_chase_range == false:
		local_player_chase = false # si el cuerpo que salio es el jugador o el jugador no esta en el rango de persecucion, desactivamos la persecucion

func _on__on_check_chase_timer_timeout_timeout():
	if not global.player_in_chase_range and alive:
		global.player_in_chase_range = false  # Desactivamos la persecución si el jugador ya no está en rango
