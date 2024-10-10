package studio.crbl.genis.gamemodes;

import java.util.ArrayList;

import javafx.application.Platform;
import studio.crbl.genis.misc.Player;
import studio.crbl.genis.misc.Word;

public class Timed extends AbstractGamemode {
    private final int time;
    private long startTimestamp;
    private Thread thread;

    public Timed(ArrayList<String> words, OnGameOver onGameOver, Player player, int time) {
        super(words, onGameOver, player);
        this.time = time;
    }

    @Override
    public void start() {
        for(int i = 0; i < Math.min(time, 30); i++) {
            wordsGenerated.add(getNewWord());
        }
        super.start();
        startTimestamp = System.currentTimeMillis();
        thread = new Thread(() -> {
            try {
                Thread.sleep(time * 1000);
                Platform.runLater(() -> onGameOver.onGameOver());
            } catch (InterruptedException e) {
                logger.error("Could not sleep until the game is over");
                e.printStackTrace();
            }
        });
        thread.start();
        logger.info("Timed game started");
    }

    @Override
    public boolean isOver() {
        return startTimestamp + (time * 1000) <= System.currentTimeMillis();
    }

    @Override
    public void addKeyPress(Word.KeyPress keyPress, Player player) {
        super.addKeyPress(keyPress, player);
        wordsGenerated.add(getNewWord());
    }

    public long getRemainingSeconds() { return (startTimestamp + (time * 1000) - System.currentTimeMillis()) / 1000;
    }
}
