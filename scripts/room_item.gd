extends MarginContainer

@onready var room_id_label : Label = $VBoxContainer/HBoxContainer/RoomId
@onready var number_of_players_label : Label = $VBoxContainer/HBoxContainer/NumberOfPlayers
@onready var join_button : Button = $VBoxContainer/Join
@onready var room_name_label : Label = $VBoxContainer/RoomName

var _number_of_players : int = 0
var _room_id = null
var _room_name = null

signal join_room(id)

func _ready():
	join_button.pressed.connect(_join_room_pressed)

func set_room_name(name):
	_room_name = name
	room_name_label.text = name
	

func set_number_of_players(i):
	_number_of_players = i
	number_of_players_label.text = str(i) + "/4"
	if i >= 4:
		join_button.disabled = true
	else:
		join_button.disabled = false




func set_room_id(id):
	_room_id = id
	room_id_label.text = str(id)


func _join_room_pressed():
	if _room_id:
		emit_signal("join_room", _room_id)

func remove(): queue_free()
