extends CharacterBody2D

var player_info = {
	"is_me": false,
	"nickname": "",
	"id": ""
}
const SPEED = 300.0

@onready var nickname_label = $Nickname

func _physics_process(delta):
	if !is_me(): return
	
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

func is_me() -> bool:
	return player_info.is_me

func set_is_me(is_me : bool):
	player_info.is_me = is_me

func set_nickname(nick):
	player_info.nickname = nick
	nickname_label.text = nick

func set_id(id):
	player_info.id = id
