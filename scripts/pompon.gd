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
const CAPA_CAJAS := 16

@export var color: TipoColor = TipoColor.ROJO
@export var radio: float = 32.0

# Estas se pueden cambiar desde el Inspector de Godot, sin tocar este
# código, para probar cómo se siente el movimiento.
@export var velocidad: float = 300.0
@export var fuerza_salto: float = 700.0
@export var gravedad: float = 1500.0
@export var rebote_sobre_pompon: float = 1000.0
@export var fuerza_empuje_caja: float = 3000.0

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
	# y puede chocar con el piso gris, las cajas, y las plataformas de SU color.
	collision_layer = CAPA_POMPONES
	var mascara := CAPA_PISO | CAPA_POMPONES | CAPA_CAJAS
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
	if controlado:
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
	else:
		velocity.x = 0.0

	move_and_slide()

	# Godot no empuja las cajas solo porque un CharacterBody2D choque contra
	# ellas (las trata como una pared). Por eso revisamos con qué chocamos
	# y, si es una caja, la empujamos nosotros mismos con una fuerza.
	for i in get_slide_collision_count():
		var colision := get_slide_collision(i)
		var otro := colision.get_collider()
		if otro is CharacterBody2D and otro.get_script() == get_script() and colision.get_normal().y < -0.5:
			# Rebote: los pompones son blandos, así que si uno cae justo
			# encima del OTRO pompón, rebota más alto, como en un trampolín.
			velocity.y = -rebote_sobre_pompon
		elif otro is RigidBody2D:
			# La normal de la colisión apunta desde la caja hacia nosotros;
			# empujamos para el otro lado, o sea hacia adentro de la caja.
			otro.apply_central_force(-colision.get_normal() * fuerza_empuje_caja)


func _draw() -> void:
	# Todavía no tenemos dibujos (sprites) del pompón, así que mientras tanto
	# lo mostramos como un círculo de su color para poder verlo y probarlo.
	var color_para_dibujar := Color.RED if color == TipoColor.ROJO else Color.BLUE
	draw_circle(Vector2.ZERO, radio, color_para_dibujar)
