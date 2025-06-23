extends CharacterBody2D


const gravity : int = 1000 # How quickly the bird drops
const max_vel : int = 600 # Limits the max fall speed
const flap_speed : int = -500 # Defines the jump height 
var flying : bool = false # Active as long the bird hasn't collided 
var falling : bool = false # Active when the bird hits a pipe
const start_pos = Vector2(100, 400)  # Bird's starting position when the scene loads

func _ready():
	reset()

func reset():
	falling = false
	flying = false 
	position = start_pos
	set_rotation(0)

func _physics_process(delta: float) -> void:
	if flying or falling:
		velocity.y += gravity * delta
	if velocity.y > max_vel:
		velocity.y = max_vel
	if flying:
		set_rotation(deg_to_rad(velocity.y * 0.05))
	elif falling:
		set_rotation(PI/2)
	move_and_collide(velocity * delta) # Moves the bird


func flap():
	velocity.y = flap_speed
	
