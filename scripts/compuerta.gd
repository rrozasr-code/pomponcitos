extends StaticBody2D

## Una compuerta bloquea el paso mientras está cerrada. Empieza cerrada,
## y algo (normalmente un botón) la abre o la cierra llamando a estas
## dos funciones.

func _ready() -> void:
	cerrar()


func abrir() -> void:
	# "set_deferred" espera a que termine el paso de física actual antes
	# de desactivar la colisión, para que Godot no se confunda a mitad
	# de un cálculo.
	$ColisionCompuerta.set_deferred("disabled", true)
	modulate.a = 0.3


func cerrar() -> void:
	$ColisionCompuerta.set_deferred("disabled", false)
	modulate.a = 1.0
