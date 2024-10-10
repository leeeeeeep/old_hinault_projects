package studio.crbl.genis.gamemodes;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import studio.crbl.genis.misc.Player;
import studio.crbl.genis.misc.Statistics;
import studio.crbl.genis.misc.Word;

public abstract class Lives extends AbstractGamemode {
    protected final HashMap<String, Integer> lives = new HashMap<>();

    public Lives(ArrayList<String> words, OnGameOver onGameOver, Player player) {
        super(words, onGameOver, player);
    }

    @Override
    public void addKeyPress(Word.KeyPress keyPress, Player player) {
        int numWords = wordsTyped.get(player.getName()).size();
        super.addKeyPress(keyPress, player);

        if (numWords < wordsTyped.get(player.getName()).size()) {
            Word word = wordsTyped.get(player.getName()).get(numWords - 1);

            if (!word.isCorrect()) {
                lives.put(player.getName(), lives.get(player.getName()) - word.getErrors());
            } else if(word.isPerfect() && word.getTag() == Word.Tag.BONUS) {
                lives.put(player.getName(), lives.get(player.getName()) + word.getWord().length());
            }
        }

        if(super.getWords().size() - super.getWords(player).size() < 7) {
            wordsGenerated.add(getNewWord());
        }
    }

    @Override
    public void addPlayer(Player player) {
        super.addPlayer(player);
        lives.put(player.getName(), 10);
    }

    @Override
    public void removePlayer(Player player) {
        super.removePlayer(player);
        lives.remove(player.getName());
    }

    public int getLives(Player player) {
        return lives.get(player.getName());
    }

    @Override
    public List<Word> getWords() {
        var words = super.getWords();
        return words.subList(Math.max(0, words.size() - 15), words.size());
    }

    @Override
    public List<Word> getWords(Player player) {
        var words = super.getWords(player);
        return words.subList(Math.max(0, super.getWords().size() - 15), words.size());
    }

    public List<Word> getAllWords() {
        return super.getWords();
    }

    public List<Word> getAllWords(Player player) {
        return super.getWords(player);
    }

    public int getWordsTyped(Player player) {
        return wordsTyped.get(player.getName()).size();
    }

    @Override
    public Statistics getStatistics(Player player) {
        return new Statistics(super.getWords(player));
    }
}
