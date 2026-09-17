extends CharacterBody2D

## Un pompón puede ser rojo o azul. Se usa para saber qué plataformas
## puede pisar y a qué puerta tiene que llegar.
enum TipoColor { ROJO, AZUL }

# Estos números son "capas de colisión": una forma de decirle a Godot
# quién puede chocar con quién. Cada capa es como una etiqueta invisible.
const CAPA_PISO := 1
const CAPA_PLATAFORMA_ROJA := 2
const CAPA_PLATAFORMA_AZUL := 4
const CAPA_POMPONES := 8

@export var color: TipoColor = TipoColor.ROJO
@export var radio: float = 32.0

# Estas tres son las que se pueden cambiar desde el Inspector de Godot,
# sin tocar este código, para probar cómo se siente el movimiento.
@export var velocidad: float = 300.0
@export var fuerza_salto: float = 700.0
@export var gravedad: float = 1500.0

# Cuando no es tu turno (en modo Solo, el que no controlas), esto queda
# en false y el pompón no se mueve solo, pero sigue afectado por la gravedad.
var controlado: bool = true


func _ready() -> void:
	# CircleShape2D es la forma de colisión (invisible) del pompón.
	# La creamos acá para que siempre tenga el mismo tamaño que el radio de arriba.
	var forma := CircleShape2D.new()
	forma.radius = radio
	$ColisionPompon.shape = forma

	# Todo pompón está en la capa "Pompones" (así se pueden pisar entre ellos),
	# y puede chocar con el piso gris y con las plataformas de SU color.
	collision_layer = CAPA_POMPONES
	var mascara := CAPA_PISO | CAPA_POMPONES
	if color == TipoColor.ROJO:
		mascara |= CAPA_PLATAFORMA_ROJA
	else:
		mascara |= CAPA_PLATAFORMA_AZUL
	collision_mask = mascara

	queue_redraw()


func _physics_process(delta: float) -> void:
	# Gravedad: si el pompón no está tocando el piso, lo empujamos hacia abajo
	# un poquito más en cada fotograma (por eso se multiplica por delta).
	# Esto pasa siempre, esté controlado o no (si no, quedaría flotando en el aire).
	if not is_on_floor():
		velocity.y += gravedad * delta

	# Si no es el pompón que estás controlando ahora, se queda quieto
	# (no camina solo), pero igual cae si no tiene piso debajo.
	if not controlado:
		velocity.x = 0.0
		move_and_slide()
		return

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
