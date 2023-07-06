extends Node2D

@onready var fb_rooms_manager = $RoomsManager

var _is_logged_in : bool = false
var local_player_cache = {
	"id": null,
	"room_id": null,
	"nickname": ""
}
var local_player_creation_time = 0
var rooms_cache = {}

signal login_successed(auth_info)
signal login_failed(code, error_message)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Auth signals
	Firebase.Auth.connect("signup_succeeded", _logged_in_successfully)
	Firebase.Auth.connect("login_failed", _login_failed)

func generate_random_nick() -> String:
	var id = randi_range(1000, 9999)
	return "Player#"+str(id)
	
func generate_random_room_name() -> String:
	var id = randi_range(10000, 99999)
	return "Room#"+str(id)
	
	
func is_logged_in() -> bool:
	return _is_logged_in
	
func login_anonymously(nickname):
	Firebase.Auth.login_anonymous()
	local_player_cache.nickname = nickname
	local_player_cache.id = generate_player_id()

func _logged_in_successfully(auth_info : Dictionary):
	_is_logged_in = true
	fb_rooms_manager.initialize()
	emit_signal("login_successed", auth_info)

func _login_failed(code, message):
	_is_logged_in = false
	emit_signal("login_failed", code, message)

func get_current_utc_unix():
	var time = Time.get_time_dict_from_system()
	var timezone = Time.get_time_zone_from_system()
	var date = Time.get_date_dict_from_system()
	date.merge(time)
	var unix_time = Time.get_unix_time_from_datetime_dict(date)
	var utc_time = unix_time - timezone.bias * 60
	return utc_time

func generate_player_id() -> String:
	var id = local_player_cache.nickname + str(get_current_utc_unix())
	id = id.replace("#", "").replace("$", "").replace("/", "").replace("[", "").replace("]", "")
	return id
	
