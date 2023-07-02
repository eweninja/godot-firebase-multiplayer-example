extends Node2D

var _is_logged_in : bool = false
var Game
var all_data_ref : FirebaseDatabaseReference = null
var players_ref : FirebaseDatabaseReference = null
var rooms_ref : FirebaseDatabaseReference = null
var sessions_ref = null

var local_player_id = ""
var local_player_room_id = ""
var rooms_cache = []

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
	
	players_ref = Firebase.Database.get_database_reference("players", {})
	players_ref.new_data_update.connect(_players_updated)
	players_ref.patch_data_update.connect(_players_patch_updated)
	players_ref.delete_data_update.connect(_player_removed)
	players_ref.push_successful.connect(_players_push_successed)
	players_ref.push_failed.connect(_players_push_failed)
	
	rooms_ref = Firebase.Database.get_database_reference("rooms", {})
	rooms_ref.new_data_update.connect(_rooms_updated)
	rooms_ref.patch_data_update.connect(_rooms_patch_updated)
	rooms_ref.delete_data_update.connect(_room_removed)
	rooms_ref.push_successful.connect(_rooms_push_successed)
	rooms_ref.push_failed.connect(_rooms_push_failed)
	
	Game.emit_signal("login_successed", auth_info)

func _login_failed(code, message):
	_is_logged_in = false
	Game.emit_signal("login_failed", code, message)

func add_new_player_to_list(player_info):
	player_info.updated_time = Time.get_unix_time_from_system()
	players_ref.push(player_info)
	
func _players_updated(data):
	Game.emit_signal("players_online_changed", data)
	if local_player_id == "":
		local_player_id = data.key
		Game.emit_signal("player_added_to_list", local_player_id)
		
	players_cleanup(data)
	
func _players_patch_updated(data):
	Game.emit_signal("players_online_changed", data)
	players_cleanup(data)
	
func _players_push_successed(): print("push successed")
func _players_push_failed(): print("push failed")

func _player_removed(data):
	Game.emit_signal("player_online_removed", data)

func update_player(id, data = {}):
	data.updated_time = Time.get_unix_time_from_system()
	players_ref.update(id, data)

func players_cleanup(data):
	var to_remove = false
	if !data.data: return
	if !"updated_time" in data.data:
		to_remove = true
	else:
		if Time.get_unix_time_from_system() - data.data.updated_time > 120:
			to_remove = true
			
	if to_remove:
		players_ref.delete(str(data.key))
		remove_player_from_room(data.key, false)
		

func _rooms_updated(data):
	if !data.key in rooms_cache: rooms_cache.push(data.key)
	print("room data changed")
	print(data)
	if local_player_room_id == "":
		if local_player_id in data.data.players:
			local_player_room_id = data.key
			Game.emit_signal("room_joined", data)
	
	Game.emit_signal("rooms_changed", data)
	rooms_cleanup(data)
	
func _rooms_patch_updated(data):
	Game.emit_signal("rooms_changed", data)
	rooms_cleanup(data)
	
func _rooms_push_successed(): print("push successed")
func _rooms_push_failed(): print("push failed")

func _room_removed(data):
	pass # todo
	
func rooms_cleanup(data):
	if data.data.players == {}:
		print("room removed by cleanup "+str(data.key))
		rooms_ref.delete(str(data.key))
		Game.emit_signal("room_removed", data)
	
func create_room(data):
	rooms_ref.push({
		"players": {
			local_player_id: {
				"isHost": true
			}
		}
	})


func remove_player_from_room(player_id, room_id):
	if !player_id: return
	if room_id:
		rooms_ref.delete(room_id + "/players/" + player_id)
	else:
		for _room_id in rooms_cache:
			rooms_ref.delete(_room_id + "/players/" + player_id)
