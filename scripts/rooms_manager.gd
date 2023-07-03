extends Node2D

@onready var fb_manager = get_parent()
var rooms_ref : FirebaseDatabaseReference = null

signal room_updated(data)
signal room_joined(data)
signal room_deleted(data)


func initialize():
	rooms_ref = Firebase.Database.get_database_reference("rooms", {})
	rooms_ref.new_data_update.connect(_room_updated)
	rooms_ref.patch_data_update.connect(_room_updated)
	rooms_ref.delete_data_update.connect(_room_deleted)

func _room_updated(data):
	emit_signal("room_updated", data)
	if !data.data:
		fb_manager.rooms_cache.erase(data.key)
	else:
		if !data.key in fb_manager.rooms_cache:
			fb_manager.rooms_cache[data.key] = data.data
	
		if fb_manager.local_player_room_id == "":
			if fb_manager.local_player_id in data.data.players:
				fb_manager.local_player_room_id = data.key
				emit_signal("room_joined", data)
	
	rooms_cleanup(data)
	

func _room_deleted(data):
	emit_signal("room_updated", data)
	if data.key in fb_manager.rooms_cache:
		fb_manager.rooms_cache.erase(data.key)


# create room with initial data
func create_room(data, player_info):
	rooms_ref.push({
		"room_name": data.room_name,
		"updated_time": Time.get_unix_time_from_system(),
		"players": {
			fb_manager.local_player_id: {
				"is_host": true,
				"nickname": player_info.nickname
			}
		}
	})

func update_room(id, data):
	rooms_ref.update(id, data)

# Remove player from room by playerId and roomId
# If roomId isn't specified, remove player from all rooms
func remove_player_from_room(player_id, room_id = false):
	if !player_id: return
	if room_id:
		rooms_ref.delete(room_id + "/players/" + player_id)
	else:
		for _room_id in fb_manager.rooms_cache:
			rooms_ref.delete(_room_id + "/players/" + player_id)
			

func rooms_cleanup(data):
	var to_remove = false
	if !data.data: return
	if !"updated_time" in data.data:
		to_remove = true
	else:
		if Time.get_unix_time_from_system() - data.data.updated_time > 120:
			to_remove = true
			
	if to_remove: rooms_ref.delete(str(data.key))

func join_room(id, player_info):
	if id in fb_manager.rooms_cache:
		var room = fb_manager.rooms_cache[id]
		if room.players.size() < 4:
			room.players[fb_manager.local_player_id] = {
				"is_host": false,
				"nickname": player_info.nickname
			}
			rooms_ref.update(id, room)
