extends Node2D

@onready var fb_manager = get_parent()
var players_ref : FirebaseDatabaseReference = null

signal players_online_changed(data)
signal player_added_to_list(id)



func initialize():
	players_ref = Firebase.Database.get_database_reference("players", {})
	players_ref.new_data_update.connect(_player_updated)
	players_ref.patch_data_update.connect(_player_updated)
	players_ref.delete_data_update.connect(_player_deleted)
	
func _player_updated(data):
	if !data.data:
		fb_manager.players_cache.erase(data.key)
	else:
		if !data.key in fb_manager.players_cache and data.data:
			fb_manager.players_cache[data.key] = data.data
	
	emit_signal("players_online_changed", data)
	if fb_manager.local_player_id == "" and data.data:
		if fb_manager.local_player_creation_time == data.data.created_time:
			fb_manager.local_player_id = data.key
			emit_signal("player_added_to_list", fb_manager.local_player_id)
		
	players_cleanup(data)
	
func _player_deleted(data):
	if data.key in fb_manager.players_cache:
		fb_manager.players_cache.erase(data.key)
		
	emit_signal("players_online_changed", data)
	players_cleanup(data)
	
func add_new_player_to_list(player_info):
	player_info.updated_time = Time.get_unix_time_from_system()
	player_info.created_time = player_info.updated_time
	fb_manager.local_player_creation_time = player_info.updated_time
	players_ref.push(player_info)

func update_player(id, data):
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
		fb_manager.fb_rooms_manager.remove_player_from_room(data.key, false)
