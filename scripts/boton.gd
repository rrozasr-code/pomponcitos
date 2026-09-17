extends Area2D

## Botón de presión: cuando algo le hace peso encima (un pompón o una caja),
## avisa con la señal "activado". Cuando ya no queda nada encima, avisa con
## "desactivado". Otras cosas del nivel (como una compuerta) se conectan
## a estas señales para reaccionar, sin que el botón necesite saber qué son.

signal activado
signal desactivado

var cosas_encima := 0


func _ready() -> void:
	body_entered.connect(_al_entrar)
	body_exited.connect(_al_salir)


func _al_entrar(_cuerpo: Node2D) -> void:
	cosas_encima += 1
	if cosas_encima == 1:
		activado.emit()


func _al_salir(_cuerpo: Node2D) -> void:
	cosas_encima -= 1
	if cosas_encima == 0:
		desactivado.emit()
