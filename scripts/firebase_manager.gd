extends Node2D

@onready var fb_players_manager = $PlayersManager
@onready var fb_rooms_manager = $RoomsManager

var _is_logged_in : bool = false

var rooms_ref : FirebaseDatabaseReference = null
var sessions_ref = null

var local_player_id = ""
var local_player_room_id = ""
var local_player_creation_time = 0

var players_cache = {}
var rooms_cache = {}

signal login_successed(auth_info)
signal login_failed(code, error_message)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Auth signals
	Firebase.Auth.connect("signup_succeeded", _logged_in_successfully)
	Firebase.Auth.connect("login_failed", _login_failed)
	
func is_logged_in() -> bool:
	return _is_logged_in
	
func login_anonymously():
	Firebase.Auth.login_anonymous()

func _logged_in_successfully(auth_info : Dictionary):
	_is_logged_in = true
	fb_players_manager.initialize()
	fb_rooms_manager.initialize()
	emit_signal("login_successed", auth_info)

func _login_failed(code, message):
	_is_logged_in = false
	emit_signal("login_failed", code, message)

func update_player(id, data):
	data.updated_time = Time.get_unix_time_from_system()
	fb_players_manager.update_player(id, data)
	
func update_room(id, data):
	data.updated_time = Time.get_unix_time_from_system()
	fb_rooms_manager.update_room(id, data)
