package studio.crbl.genis.gamemodes;

import java.util.ArrayList;

import studio.crbl.genis.misc.Player;
import studio.crbl.genis.misc.Word;

public class Words extends AbstractGamemode {
    private final int count;

    public Words(ArrayList<String> words, OnGameOver onGameOver, Player player, int count) {
        super(words, onGameOver, player);
        this.count = count;
    }

    @Override
    public void start() {
        logger.info("Words game started");
        for(int i = 0; i < getRemainingWords() - 1; i++) {
            wordsGenerated.add(getNewWord());
        }
        super.start();
    }

    @Override
    public boolean isOver() {
        return getRemainingWords() <= 0;
    }

    @Override
    public void addKeyPress(Word.KeyPress keyPress, Player player) {
        logger.info(player.getName() + " pressed '" + keyPress.key + "'");

        var playerWords = wordsTyped.get(player.getName());
        if(keyPress.key.equals(" ")) {
            if (getRemainingWords() == 1) {
                onGameOver.onGameOver();
                return;
            }
            var w = wordsGenerated.get(playerWords.size());
            wordsTyped.get(player.getName()).add(new Word(w.getWord(), w.getTag()));
        } else {
            playerWords.get(playerWords.size() - 1).addKeyPress(keyPress);
        }

        if(onUpdate != null) {
            onUpdate.onUpdate();
        }
    }

    public int getRemainingWords() {
        return count - wordsTyped.get(player.getName()).size() + 1;
    }
}
