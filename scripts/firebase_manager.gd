extends Node2D

var _is_logged_in : bool = false
var Game

# Called when the node enters the scene tree for the first time.
func _ready():
	Game = get_parent()
	
	# Auth signals
	Firebase.Auth.connect("signup_succeeded", _logged_in_successfully)
	Firebase.Auth.connect("login_failed", _login_failed)
	
	
func is_logged_in() -> bool:
	return _is_logged_in
	

func login_anonymously():
	Firebase.Auth.login_anonymous()

func _logged_in_successfully(auth_info : Dictionary):
	_is_logged_in = true
	Game.emit_signal("login_successed")
	print(auth_info)

func _login_failed(code, message):
	_is_logged_in = false
	Game.emit_signal("login_failed", code, message)
