extends Node

@export var pipe_scene : PackedScene



# Game state flags 
var game_running : bool
var game_over : bool
# Used to move images across the screen
var scroll
var score 
# Change to make the game slower or faster
const scroll_speed : int = 1
# Placeholders
var screen_size : Vector2i
var ground_height : int 
var pipes : Array
# Controls the pipe generation
const pipe_delay : int = 100
const pipe_range : int = 200



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()


func new_game():
	# Reset variables
	game_running = false
	game_over = false
	score = 0
	scroll = 0 
	$ScoreLabel.text = 'SCORE: ' + str(score)
	$GameOver.hide()
	$Bird.reset()
	# Delete pipes after restarting the game
	get_tree().call_group('pipes', 'queue_free')
	pipes.clear()
	# Generate starting pipes
	generate_pipes()


func _input(event):
# Checks if the game is over / When the game starts, the bird is stationary, until the mouse is clicked
# The first mouse click starts the game, the second one makes the bird jump
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				# Checks if the game is running, if not, the mouse click, starts the game
				if game_running == false:
					start_game()
				else:
					if $Bird.flying:
						$Bird.flap()
						check_top()


func start_game():
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	$PipeTimer.start()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		scroll += scroll_speed
		# Move the ground every frame
		$Ground.position.x = -scroll
		# Move pipes
		for pipe in pipes:
			pipe.position.x -= scroll_speed
		# Reset screen scroll 
		if scroll >= screen_size.x:
			scroll = 0
			


func _on_pipe_timer_timeout() -> void:
	generate_pipes()
	
func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + pipe_delay
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-pipe_range, pipe_range)
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe)

func scored():
	score += 1
	$ScoreLabel.text = 'SCORE: ' + str(score)


func bird_hit():
	$Bird.falling = true
	stop_game()

func check_top():
	if $Bird.position.y <= 0:
		$Bird.falling = true
		stop_game()

func stop_game():
	$PipeTimer.stop()
	$GameOver.show()
	$Bird.flying = false
	game_running = false
	game_over = true

func _on_ground_hit() -> void:
	$Bird.falling = false
	stop_game()


func _on_game_over_restart() -> void:
	new_game()
