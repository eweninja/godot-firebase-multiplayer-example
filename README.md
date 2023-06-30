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