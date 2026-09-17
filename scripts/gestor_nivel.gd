extends Node2D

## El "director" del nivel: conoce a los dos pompones y las dos puertas,
## decide cuál pompón controlas en cada momento (modo Solo), y se da cuenta
## cuando el nivel está completo.

# Las rutas a los nodos se configuran desde el Inspector (son las líneas
# que dicen "Pompon Rojo Path", etc.), y acá buscamos el nodo real con esa ruta.
@export var pompon_rojo_path: NodePath
@export var pompon_azul_path: NodePath
@export var puerta_roja_path: NodePath
@export var puerta_azul_path: NodePath

var pompon_rojo: CharacterBody2D
var pompon_azul: CharacterBody2D
var puerta_roja: Area2D
var puerta_azul: Area2D

var pompon_activo: CharacterBody2D
var rojo_en_su_puerta := false
var azul_en_su_puerta := false


func _ready() -> void:
	pompon_rojo = get_node(pompon_rojo_path)
	pompon_azul = get_node(pompon_azul_path)
	puerta_roja = get_node(puerta_roja_path)
	puerta_azul = get_node(puerta_azul_path)

	# Al empezar, controlas al rojo. El azul se queda quieto hasta que cambies.
	pompon_activo = pompon_rojo
	pompon_rojo.controlado = true
	pompon_azul.controlado = false

	puerta_roja.body_entered.connect(_al_entrar_puerta_roja)
	puerta_roja.body_exited.connect(_al_salir_puerta_roja)
	puerta_azul.body_entered.connect(_al_entrar_puerta_azul)
	puerta_azul.body_exited.connect(_al_salir_puerta_azul)


func _unhandled_input(event: InputEvent) -> void:
	# Tab cambia cuál de los dos pompones controlas (modo Solo).
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		cambiar_personaje()


func cambiar_personaje() -> void:
	pompon_activo.controlado = false
	pompon_activo = pompon_azul if pompon_activo == pompon_rojo else pompon_rojo
	pompon_activo.controlado = true


func _al_entrar_puerta_roja(cuerpo: Node2D) -> void:
	if cuerpo == pompon_rojo:
		rojo_en_su_puerta = true
		revisar_si_nivel_completo()


func _al_salir_puerta_roja(cuerpo: Node2D) -> void:
	if cuerpo == pompon_rojo:
		rojo_en_su_puerta = false


func _al_entrar_puerta_azul(cuerpo: Node2D) -> void:
	if cuerpo == pompon_azul:
		azul_en_su_puerta = true
		revisar_si_nivel_completo()


func _al_salir_puerta_azul(cuerpo: Node2D) -> void:
	if cuerpo == pompon_azul:
		azul_en_su_puerta = false


func revisar_si_nivel_completo() -> void:
	# Se completa solo cuando los DOS pompones están, al mismo tiempo,
	# parados sobre su puerta correspondiente.
	if rojo_en_su_puerta and azul_en_su_puerta:
		print("¡Nivel completo!")
