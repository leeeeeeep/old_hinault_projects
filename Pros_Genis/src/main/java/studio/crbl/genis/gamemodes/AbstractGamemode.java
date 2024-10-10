package studio.crbl.genis.gamemodes;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import studio.crbl.genis.misc.Player;
import studio.crbl.genis.misc.Statistics;
import studio.crbl.genis.misc.Word;
import studio.crbl.genis.util.Logger;

public abstract class AbstractGamemode {
    public interface OnGameOver {
        void onGameOver();
    }
    public interface OnUpdate {
        void onUpdate();
    }

    protected static final Logger logger = Logger.getLogger("GAME");
    protected final HashMap<String, Player> players = new HashMap<>();
    protected final HashMap<String, ArrayList<Word>> wordsTyped = new HashMap<>();
    protected final ArrayList<Word> wordsGenerated = new ArrayList<>();
    protected final ArrayList<String> allWords;
    protected OnGameOver onGameOver;
    protected OnUpdate onUpdate;
    protected final Player player;

    public AbstractGamemode(ArrayList<String> allWords, OnGameOver onGameOver, Player player) {
        this.allWords = allWords;
        this.onGameOver = onGameOver;
        this.player = player;
    }

    /**
     * Initializes the game.
     *
     * Used to start timers or similar.
     */
    public void start() {
        var word = wordsGenerated.get(0);
        wordsTyped.forEach((player, words) -> words.add(word));
    }

    /**
     * Returns whether the game is over.
     *
     * @return <code>true</code> if the game is over, <code>false</code> otherwise
     */
    public abstract boolean isOver();

    public void setOnUpdate(OnUpdate onUpdate) {
        this.onUpdate = onUpdate;
    }

    /**
     * Adds a player to the game.
     *
     * @param player The player to add.
     */
    public void addPlayer(Player player) {
        logger.info("Added player " + player.getName());
        players.put(player.getName(), player);

        ArrayList<Word> words = new ArrayList<>();
        wordsTyped.put(player.getName(), words);
    }

    /**
     * Removes a player from the game.
     *
     * @param player The player to remove.
     */
    public void removePlayer(Player player) {
        logger.info("Removed player " + player.getName());
        players.remove(player.getName());

        wordsTyped.remove(player.getName());
    }

    /**
     * Returns a list of all players in the game.
     *
     * @return A list of all players in the game.
     */
    public ArrayList<Player> getPlayers() {
        return players.values().stream().collect(ArrayList::new, ArrayList::add, ArrayList::addAll);
    }

    /**
     * Registers a keypress for a player.
     *
     * @param keyPress The keypress to add.
     * @param player The player that generated the keypress.
     */
    public void addKeyPress(Word.KeyPress keyPress, Player player) {
        logger.info(player.getName() + " pressed '" + keyPress.key + "'");

        var playerWords = wordsTyped.get(player.getName());
        if(keyPress.key.equals(" ")) {
            var w = wordsGenerated.get(playerWords.size());
            wordsTyped.get(player.getName()).add(new Word(w.getWord(), w.getTag()));
        } else {
            playerWords.get(playerWords.size() - 1).addKeyPress(keyPress);
        }

        if(onUpdate != null) {
            onUpdate.onUpdate();
        }
    }

    /**
     * Returns a new word.
     *
     * @return A new word.
     */
    protected Word getNewWord() {
        int index = (int) (Math.random() * allWords.size());
        return new Word(allWords.get(index), Word.Tag.NORMAL);
    }

    /**
     * Returns the words a player typed.
     *
     * @param player The player to get the words for.
     * @return The words the player typed.
     */
    public List<Word> getWords(Player player) {
        return new ArrayList<>(wordsTyped.get(player.getName()));
    }

    /**
     * Returns the words that were generated.
     *
     * @return The words that were generated.
     */
    public List<Word> getWords() {
        return new ArrayList<>(wordsGenerated);
    }

    /**
     * Returns the statistics for a player.
     *
     * @param player The player to get the statistics for.
     * @return The statistics of the player.
     */
    public Statistics getStatistics(Player player) {
        return new Statistics(getWords(player));
    }
}
