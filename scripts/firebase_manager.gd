extends Node2D

var _is_logged_in : bool = false
var Game

var players_ref = null
var rooms_ref = null
var sessions_ref = null


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
	Game.emit_signal("login_successed", auth_info)
	

func _login_failed(code, message):
	_is_logged_in = false
	Game.emit_signal("login_failed", code, message)

func add_new_player_to_list(player_info):
	print("adding user... ")
	var playerRef = Firebase.Database.get_database_reference("players")
	playerRef.push(player_info)
	var data = await playerRef.new_data_update
	print(data)
