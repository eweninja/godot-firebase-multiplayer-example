extends MarginContainer

@onready var room_id_label : Label = $VBoxContainer/HBoxContainer/RoomId
@onready var number_of_players_label : Label = $VBoxContainer/HBoxContainer/NumberOfPlayers
@onready var join_button : Button = $VBoxContainer/Join

var _number_of_players : int = 0
var _room_id : String = ""

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
