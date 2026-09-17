extends CharacterBody2D

## Un pompón puede ser rojo o azul. Esto se usa después (Fase 2 y 3) para
## saber qué plataformas puede pisar y a qué puerta tiene que llegar.
enum TipoColor { ROJO, AZUL }

@export var color: TipoColor = TipoColor.ROJO
@export var radio: float = 32.0

# Estas tres son las que se pueden cambiar desde el Inspector de Godot,
# sin tocar este código, para probar cómo se siente el movimiento.
@export var velocidad: float = 300.0
@export var fuerza_salto: float = 700.0
@export var gravedad: float = 1500.0


func _ready() -> void:
	# CircleShape2D es la forma de colisión (invisible) del pompón.
	# La creamos acá para que siempre tenga el mismo tamaño que el radio de arriba.
	var forma := CircleShape2D.new()
	forma.radius = radio
	$ColisionPompon.shape = forma

	queue_redraw()


func _physics_process(delta: float) -> void:
	# Gravedad: si el pompón no está tocando el piso, lo empujamos hacia abajo
	# un poquito más en cada fotograma (por eso se multiplica por delta).
	if not is_on_floor():
		velocity.y += gravedad * delta

	# Movimiento izquierda/derecha con las flechas del teclado.
	var direccion := 0.0
	if Input.is_key_pressed(KEY_LEFT):
		direccion -= 1.0
	if Input.is_key_pressed(KEY_RIGHT):
		direccion += 1.0
	velocity.x = direccion * velocidad

	# Saltar: solo si está tocando el piso, así no puede saltar en el aire.
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = -fuerza_salto

	move_and_slide()


func _draw() -> void:
	# Todavía no tenemos dibujos (sprites) del pompón, así que mientras tanto
	# lo mostramos como un círculo de su color para poder verlo y probarlo.
	var color_para_dibujar := Color.RED if color == TipoColor.ROJO else Color.BLUE
	draw_circle(Vector2.ZERO, radio, color_para_dibujar)
