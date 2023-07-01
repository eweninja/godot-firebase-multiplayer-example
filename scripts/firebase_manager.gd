extends Node2D

var _is_logged_in : bool = false
var Game
var all_data_ref : FirebaseDatabaseReference = null
var players_ref : FirebaseDatabaseReference = null
var rooms_ref = null
var sessions_ref = null

var local_player_id = ""


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
	players_ref = Firebase.Database.get_database_reference("players", {})
	
	players_ref.new_data_update.connect(_players_updated)
	players_ref.patch_data_update.connect(_players_patch_updated)
	players_ref.push_successful.connect(_players_push_successed)
	players_ref.push_failed.connect(_players_push_failed)
	
	players_ref.push(player_info)
	
func _players_updated(data):
	if local_player_id == "":
		local_player_id = data.key
		Game.emit_signal("player_added_to_list", local_player_id)
	else:
		return
	
func _players_patch_updated(data):
	print(data)	
	
func _players_push_successed():
	print("push successed")
	
func _players_push_failed():
	print("push failed")
