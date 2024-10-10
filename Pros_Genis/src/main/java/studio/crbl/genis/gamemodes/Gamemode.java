package studio.crbl.genis.gamemodes;

public enum Gamemode {
    TIMED("Timed"),
    WORDS("Words"),
    GAME("Game"),
    MULTIPLAYER_CLIENT_GAME("Multiplayer Client Game"),
    MULTIPLAYER_SERVER_GAME("Multiplayer Server Game");

    private final String name;

    private Gamemode(String name) {
        this.name = name;
    }

    public String toString() {
        return name;
    }
}
