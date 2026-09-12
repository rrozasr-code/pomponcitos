# Pomponcitos — Briefing del proyecto

> Guardar este archivo como `CLAUDE.md` en la raíz del repositorio.
> Claude Code lo lee automáticamente al inicio de cada sesión.

---

## 1. Contexto y forma de trabajar

Juego 2D para Android desarrollado por **Rodrigo junto a su hijo de 10 años**, que está aprendiendo a programar (viene de programación por bloques, sin experiencia en código escrito).

El objetivo es doble: publicar el juego en Google Play **y** que el niño aprenda en el proceso. Esto condiciona todas las decisiones técnicas.

**Reglas para Claude en este proyecto:**

- Todo en español: explicaciones, comentarios del código, nombres de variables del dominio del juego.
- Prioriza **claridad sobre elegancia**. Código directo y legible, aunque sea más largo.
- Nada de patrones avanzados: sin state machines abstractas, sin sistemas de eventos genéricos, sin herencia profunda, sin inyección de dependencias.
- Nunca entregues un archivo completo reescrito si solo cambian tres líneas. Indica qué cambiar y dónde.
- Explica el *porqué* de cada bloque de código en una o dos frases, en lenguaje que entienda un niño de 10 años.
- Cuando haya una decisión de diseño abierta, pregunta en vez de asumir.

---

## 2. Diseño del juego

### Concepto

Dos pompones de colores (con ojos y pies) tienen que llegar juntos a la meta de cada nivel. Puzzle-plataformas.

Modelo de referencia: *Fireboy & Watergirl*.

### Mecánica central: el color

- Pompón **rojo** y pompón **azul**.
- Las plataformas rojas solo las pisa el rojo. Las azules solo el azul. Las grises las pisan ambos.
- Los pompones son blandos: uno puede **saltar encima del otro** para rebotar más alto.
- El nivel se completa cuando **cada pompón llega a su puerta del mismo color**.

### Los dos modos usan los mismos 20 niveles

Esta es la decisión clave del proyecto: no se duplica contenido.

| Modo | Control |
|---|---|
| **Solo** | Controlas un pompón. Un botón cambia al otro. El que no controlas queda quieto. |
| **Cooperativo** | Pantalla compartida en un mismo dispositivo. Controles táctiles en cada mitad de la pantalla. |

### Elementos de nivel (v1 completa, no agregar más)

- Plataformas de color (rojo / azul / gris)
- Botones de presión (mantienen una puerta abierta mientras algo los pisa)
- Cajas empujables
- Puertas de color (meta)

### Curva de dificultad

- Niveles 1–5: moverse, saltar, entender el color
- Niveles 6–12: botones y cajas
- Niveles 13–20: rebote entre pompones y timing

### Fuera de alcance en v1

Sin historia. Sin diálogos. Sin enemigos. Sin vidas ni muerte permanente (reiniciar el nivel y listo). Sin multijugador en red.

---

## 3. Stack técnico

| Pieza | Elección |
|---|---|
| Motor | Godot 4 (GDScript) |
| Export | `.aab` para Google Play |
| Control de versiones | Git + repositorio privado en GitHub |
| Arte | Piskel (pixel art, gratis, en navegador) |
| Guardado | Archivo local (`user://`). **Sin Firebase.** |
| Backend | Ninguno |
| Monetización v1 | **Ninguna** — sin anuncios ni compras |

**Por qué sin monetización en v1:** el juego cae bajo la política de Familias de Google Play, que restringe fuertemente anuncios y compras en apps para niños. Publicar gratis reduce el trabajo y el riesgo de rechazo. Si más adelante se monetiza, la vía limpia es *una sola* compra opcional que desbloquee niveles extra — nunca vidas ni monedas.

---

## 4. Estructura del proyecto

```
res://
├── escenas/
│   ├── pompon.tscn          # personaje (uno solo, parametrizado por color)
│   ├── boton.tscn
│   ├── caja.tscn
│   └── puerta.tscn
├── niveles/
│   ├── nivel_01.tscn
│   └── ...                  # una escena por nivel, hasta nivel_20
├── scripts/
│   ├── pompon.gd
│   ├── gestor_nivel.gd
│   └── guardado.gd
├── ui/
│   ├── menu_principal.tscn
│   ├── selector_nivel.tscn
│   └── controles_tactiles.tscn
└── assets/
    ├── sprites/
    └── audio/
```

---

## 5. Convenciones técnicas

- **Resolución base:** 1280×720. Stretch mode `canvas_items`, aspect `expand`.
- **Nombres:** archivos en `snake_case`, clases en `PascalCase`, todo en español.
- **Niveles:** un `TileMapLayer` por nivel. Cada nivel es una escena independiente para que el niño pueda editarlos visualmente sin tocar código.
- **Regla importante:** toda constante ajustable (velocidad, altura de salto, gravedad, fuerza de rebote) va como `@export` al inicio del script, para que el niño pueda cambiarla desde el inspector de Godot sin abrir el código. Esta es la principal vía de aprendizaje del proyecto.

```gdscript
@export var velocidad: float = 300.0
@export var fuerza_salto: float = 700.0
@export var rebote_sobre_pompon: float = 1000.0
```

- **Un solo script `pompon.gd`** para ambos personajes, con el color como propiedad exportada. No dos scripts duplicados.

---

## 6. Roadmap por fases

Cada fase tiene un criterio de "listo" verificable. No avanzar sin cumplirlo.

| Fase | Objetivo | Listo cuando... |
|---|---|---|
| **0** | Godot + git + pipeline de export Android | Un "hola mundo" corre instalado en el teléfono real |
| **1** | Movimiento básico | Un pompón camina y salta en un nivel de prueba |
| **2** | Núcleo de dos personajes | Dos pompones, cambio de personaje, colisión por color, puerta de meta |
| **3** | Elementos de puzzle + primeros niveles | Botones, cajas, rebote funcionando + niveles 1–5 jugables |
| **4** | Envoltura | Menú, selector de nivel, guardado de progreso, sonidos |
| **5** | Contenido | Niveles 6–20 (los diseña el hijo) |
| **6** | Publicación | Cuenta Play, test cerrado, publicado |

**Riesgo crítico:** la Fase 0 se hace **primero y completa**. Configurar el export de Android (JDK, Android SDK, keystore de firma) es lo más tedioso del proyecto y donde mueren estos proyectos si se deja para el final.

---

## 7. Comandos útiles (PowerShell)

```powershell
# Inicializar el repositorio
git init
git add .
git commit -m "Estructura inicial del proyecto"

# Guardar avance (enseñarle esto al niño como "guardar la partida")
git add .
git commit -m "Descripcion de lo que funciona ahora"
git push

# Exportar a .aab desde consola
& "C:\Godot\Godot_v4.exe" --headless --path . --export-release "Android" build\pomponcitos.aab
```

`.gitignore` mínimo para Godot 4:

```
.godot/
build/
*.translation
export_presets.cfg
```

> `export_presets.cfg` contiene la ruta al keystore de firma. Mantenerlo fuera del repositorio, y **nunca** subir el archivo `.keystore`.

---

## 8. Trámites de Google Play (en paralelo al desarrollo)

- La cuenta de desarrollador es de **Rodrigo**, no del niño (se requiere ser mayor de edad).
- Costo: USD 25, pago único.
- Las cuentas personales nuevas deben correr un **test cerrado con mínimo 12 testers inscritos durante 14 días continuos** antes de poder pedir acceso a producción. Deben ser personas reales con dispositivos reales.
- **Empezar a reclutar testers desde ya.** Apuntar a 15–16 para absorber deserciones.
- Al publicar habrá que completar: política de privacidad, formulario de Data Safety y la sección de Target Audience (declarando que el público objetivo son niños).

---

## 9. Primera tarea

Fase 0. Guía paso a paso, en PowerShell, para:

1. Instalar Godot 4 y las plantillas de exportación
2. Instalar JDK y Android SDK, y configurarlos en Godot
3. Generar el keystore de firma
4. Crear el proyecto, inicializarlo con git y subirlo a GitHub
5. Exportar un proyecto vacío e instalarlo en un teléfono Android real

No escribir código de juego hasta que el paso 5 funcione.
