extends CharacterBody2D

var _is_self = false
var _nickname = ""
const SPEED = 300.0

@onready var nickname_label : Label = $Nickname

func _physics_process(delta):
	if !is_self(): return
	
	var direction = Vector2.ZERO
	if Input.is_action_pressed("left"):
		direction.x = -1
	elif Input.is_action_pressed("right"):
		direction.x = 1
	if Input.is_action_pressed("up"):
		direction.y = -1
	elif Input.is_action_pressed("down"):
		direction.y = 1
	
	velocity = direction.normalized() * SPEED
	move_and_slide()

func is_self() -> bool:
	return _is_self

func set_is_self(is_self_player):
	_is_self = is_self_player

func set_nickname(nick):
	_nickname = nick
	nickname_label.text = _nickname
