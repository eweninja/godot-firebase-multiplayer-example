# godot-firebase-multiplayer-example

**Work in progress**.

Example project in Godot 4.1 using [GodotFirebase](https://github.com/GodotNuts/GodotFirebase).
Shared multiplayer with authority for own player.

## Reason

- I'm creating this project for reference, as a basic example of creating multiplayer in Godot 4 using Firebase (mostly Firebase Realtime Database).
- Learning. 😊



## About project

- Anonymous login.
- Setting nickname.
- Creating lobby room.
- Joining lobby room.
- Matchmaking:
	- Search for open rooms:
		- If open room exists, join it.
		- Else create new open room and wait for other players.
- In lobby room:
	- Starting game.
	- Leaving room.
	- Text chat (optionally).
- Gameplay:
	- Spawning players:
		- Self.
		- Remote.
	- Sending player position.
	- Receiving remote players position.
	- Broadcasting player actions.
	- Host migration.
- Game end:
	- Showing results.
	- Going back to lobby.


## Todo

- [x] Add login (anonymous).
- [x] Add simple player scene.
- [x] Add player nicknames.
- [ ] Lobby rooms.
- [ ] Matchmaking.
- [ ] Simple "gameplay".
- [ ] Game end.


## Database structure

```json
{
  "players": {
	"$playerId": {
	  "nickname": "Player#1000",
	  "updated_time": 0
	}
  },
  "rooms": {
	"$roomId": {
	  "name": "Room 1",
	  "players": {
		"$playerId": {
		  "isHost": true
		}
	  }
	}
  },
  "sessions": {
	"$sessionId": {
	  "roomId": "abc123",
	  "status": "active",
	  "startTime": 1656789123456,
	  "stats": {
		"$playerId": {}
	   }
	}
  }
}
```

- Players | Keeps track of online players.
- Rooms | Keeps track of lobby rooms.
- Sessions | Keeps track of ongoing games.

