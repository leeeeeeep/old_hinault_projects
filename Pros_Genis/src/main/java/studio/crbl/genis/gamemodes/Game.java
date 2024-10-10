package studio.crbl.genis.gamemodes;

import java.util.ArrayList;

import javafx.application.Platform;
import studio.crbl.genis.misc.Player;
import studio.crbl.genis.misc.Word;

public class Game extends Lives implements Runnable {
    private int level;
    private final int nextLevel;
    private final int timeout;
    private final double bonus;
    private Thread thread;

    public Game(ArrayList<String> words, OnGameOver onGameOver, Player player, int level, int timeout, double bonus, int nextLevel) {
        super(words, onGameOver, player);
        this.level = level;
        this.timeout = timeout;
        this.bonus = bonus;
        this.nextLevel = nextLevel;
    }

    @Override
    public void start() {
        for(int i = 0; i < 15; i++) {
            wordsGenerated.add(getNewWord());
        }
        super.start();
        thread = new Thread(() -> {
            try {
                Thread.sleep(timeout * 1000);
                Platform.runLater(() -> {
                    tick();
                });
            } catch (InterruptedException e) {
                logger.error("Could not wait timeout");
                e.printStackTrace();
            }
        });
        thread.start();
        logger.info("Game game started");
    }

    @Override
    public boolean isOver() {
        return this.lives.values().stream().allMatch(lives -> lives <= 0);
    }

    @Override
    public void addKeyPress(Word.KeyPress keyPress, Player player) {
        int numWords = wordsTyped.get(player.getName()).size();
        super.addKeyPress(keyPress, player);
        if(numWords < wordsTyped.get(player.getName()).size() && super.getAllWords(player).size() % nextLevel == 0) {
            level++;
        }

        if (isOver()) {
            thread.interrupt();
            onGameOver.onGameOver();
        } else if(onUpdate != null) {
            onUpdate.onUpdate();
        }
    }

    @Override
    protected Word getNewWord() {
        int index = (int) (Math.random() * allWords.size());
        boolean isBonus = Math.random() < bonus;
        return new Word(allWords.get(index), isBonus ? Word.Tag.BONUS : Word.Tag.NORMAL);
    }

    private void tick() {
        wordsGenerated.add(getNewWord());
        Player player = players.entrySet().iterator().next().getValue();
        if(wordsTyped.get(player.getName()).size() == wordsGenerated.size() - 15) {
            addKeyPress(new Word.KeyPress(" ", System.currentTimeMillis()), player);
        }

        if (isOver()) {
            onGameOver.onGameOver();
            return;
        }

        if(onUpdate != null) {
            onUpdate.onUpdate();
        }

        thread = new Thread(this);
        thread.start();
    }

    private long getTickDuration() {
        return (long)(5.0 * Math.pow(0.9, level - 1) * 1000);
    }

    @Override
    public void run() {
        try {
            Thread.sleep(getTickDuration());
            Platform.runLater(() -> tick());
        } catch (InterruptedException e) {
            logger.info("Tick sleep interrupted");
            e.printStackTrace();
        }
    }

    public int getLevel() {
        return level;
    }
}
