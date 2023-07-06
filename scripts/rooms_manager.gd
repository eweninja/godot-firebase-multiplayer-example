extends Node2D

@onready var fb_manager = get_parent()
var rooms_ref : FirebaseDatabaseReference = null

signal room_updated(data)
signal room_joined()
signal room_deleted(data)
signal player_left_room(player_id, room_id)

func initialize():
	# Initialize rooms reference and connect signals
	rooms_ref = Firebase.Database.get_database_reference("rooms", {})
	rooms_ref.new_data_update.connect(_room_updated)
	rooms_ref.patch_data_update.connect(_room_patched)
	rooms_ref.delete_data_update.connect(_room_deleted)
	rooms_ref.push_successful.connect(_push_successful)
	rooms_ref.push_failed.connect(_push_failed)

# Called then room changed
func _room_updated(data):
	emit_signal("room_updated", data)

	# if no players in room
	if !data.data:
		fb_manager.rooms_cache.erase(data.key)
	elif data.data and !"players" in data.data:
		# remove room from cache
		rooms_ref.delete(data.key)
	
	# if players are in room
	else:
		
		# Update cache
		fb_manager.rooms_cache[data.key] = data.data
	
	# cleanup database
	rooms_cleanup(data)
	
func _room_patched(data):
	if !data.key in fb_manager.rooms_cache: return
	fb_manager.rooms_cache[data.key].merge(data.data)
	emit_signal("room_updated", {"key": data.key, "data": fb_manager.rooms_cache[data.key]})
	
	# If player doesn't have cached room id and is on the list
	if !fb_manager.local_player_cache.room_id and\
	fb_manager.local_player_cache.id in data.data.players:
			
		# cache room id and emit join signal
		fb_manager.local_player_cache.room_id = data.key
		emit_signal("room_joined")

# called when room is deleted from db
func _room_deleted(data):
	emit_signal("room_updated", data)
	
	# if room is cached
	if data.key in fb_manager.rooms_cache:
		# then remove it
		fb_manager.rooms_cache.erase(data.key)


# create room with initial data
func create_room():
	print(fb_manager.local_player_cache)
	
	rooms_ref.push({
		"room_name": fb_manager.generate_random_room_name(),
		"created_time": fb_manager.get_current_utc_unix(),
		"updated_time": fb_manager.get_current_utc_unix(),
		"is_running": false,
		"players": {
			str(fb_manager.local_player_cache.id): {
				"is_host": true,
				"nickname": fb_manager.local_player_cache.nickname,
				"current_points": 0,
				"is_ready": false,
				"updated_time": fb_manager.get_current_utc_unix()
			}
		}
	})

# Update the room by ID
func update_room(id, data):
	var room = fb_manager.rooms_cache[id]
	room.merge(data, true)
	room.updated_time = fb_manager.Time.get_unix_time_from_system()
	rooms_ref.update(id, room)


func leave_room():
	if !fb_manager.local_player_cache.id: return
	
	for _room_id in fb_manager.rooms_cache:
		var room = fb_manager.rooms_cache[_room_id]
		if fb_manager.local_player_cache.id in room.players:
			room.players.erase(fb_manager.local_player_cache.id)
			if !"players" in room or room.players.size() == 0:
				rooms_ref.delete(fb_manager.local_player_cache.room_id)
			else:
				rooms_ref.update(fb_manager.local_player_cache.room_id, room)
		
	fb_manager.local_player_cache.room_id = null

func rooms_cleanup(data):
	var to_remove = false
	if !data.data: return
	if !"updated_time" in data.data:
		to_remove = true
	else:
		if fb_manager.get_current_utc_unix() - data.data.updated_time > 120:
			to_remove = true
		else:
			remove_timeouted_players(data)
		
	if to_remove: rooms_ref.delete(str(data.key))

func join_room(room_id):
	if room_id in fb_manager.rooms_cache:
		var room = fb_manager.rooms_cache[room_id]
		if room.players.size() < 4:
			room.players[fb_manager.local_player_cache.id] = {
				"is_host": false,
				"nickname": fb_manager.local_player_cache.nickname,
				"current_points": 0,
				"is_ready": false,
				"updated_time": fb_manager.get_current_utc_unix()
			}
			room.updated_time = fb_manager.get_current_utc_unix()
			rooms_ref.update(room_id, room)

func remove_timeouted_players(data):
	if "players" in data.data:
		for player_id in data.data.players:
			var p = data.data.players[player_id]
			var to_remove = false
			if "updated_time" in p:
				if fb_manager.get_current_utc_unix() - p.updated_time > 120:
					to_remove = true
			else: to_remove = true
					
		
			if to_remove: data.data.erase(player_id)
	else:
		rooms_ref.delete(data.key)
		return
	
	rooms_ref.update(data.key, data.data)

func _push_successful(): print("push successful")
func _push_failed(): print("push failed")
