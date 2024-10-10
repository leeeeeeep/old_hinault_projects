package studio.crbl.genis.misc;

import java.util.ArrayList;
import java.util.List;

public class Word {
    public enum Tag {
        NORMAL,
        BONUS,
        MALUS,
    };

    public static class KeyPress {
        // The key that was pressed
        public final String key;

        // The timestamp of the keypress in milliseconds
        public final long time;

        public KeyPress(String key, long time) {
            this.key = key;
            this.time = time;
        }
    }

    private final String word;
    private final Tag tag;
    private final ArrayList<KeyPress> keyPresses = new ArrayList<>();

    public Word(String word, Tag tag) {
        this.word = word;
        this.tag = tag;
    }

    public String getWord() {
        return word;
    }

    public Tag getTag() {
        return tag;
    }

    public void addKeyPress(String key, long time) {
        keyPresses.add(new KeyPress(key, time));
    }

    public void addKeyPress(KeyPress keyPress) {
        keyPresses.add(keyPress);
    }

    public String getTypedWord() {
        return keyPresses.stream()
            .map(keyPress -> keyPress.key)
            .reduce("", (a, b) -> {
                if (b.equals("RET")) {
                    if (a.length() > 0) {
                        return a.substring(0, a.length() - 1);
                    } else {
                        return a;
                    }
                } else {
                    return a + b;
                }
            });
    }

    public long getStartTimestamp() {
        if(keyPresses.size() == 0) {
            return System.currentTimeMillis();
        }
        return keyPresses.get(0).time;
    }

    public long getEndTimestamp() {
        if(keyPresses.size() == 0) {
            return System.currentTimeMillis();
        }
        return keyPresses.get(keyPresses.size() - 1).time;
    }

    public int getErrors() {
        String typedWord = getTypedWord();
        int[][] distance = new int[word.length() + 1][typedWord.length() + 1];

        for (int i = 0; i <= word.length(); i++) {
            distance[i][0] = i;
        }

        for (int j = 0; j <= typedWord.length(); j++) {
            distance[0][j] = j;
        }

        for (int i = 1; i <= word.length(); i++) {
            for (int j = 1; j <= typedWord.length(); j++) {
                distance[i][j] = Math.min(
                    Math.min(
                        distance[i - 1][j] + 1,
                        distance[i][j - 1] + 1
                    ),
                    distance[i - 1][j - 1] + ((word.charAt(i - 1) == typedWord.charAt(j - 1)) ? 0 : 1)
                );
            }
        }

        return distance[word.length()][typedWord.length()];
    }

    public int getCorrectCharacters() {
        return word.length() - getErrors();
    }

    public List<KeyPress> getKeyPresses() {
        return new ArrayList<>(keyPresses);
    }

    public boolean isPartiallyCorrect() {
        var typedWord = getTypedWord();
        return typedWord.length() <= word.length() && typedWord.equals(word.substring(0, typedWord.length()));
    }

    public boolean isCorrect() {
        return getTypedWord().equals(word);
    }

    public boolean isPartiallyPerfect() {
        return isPartiallyCorrect() && keyPresses.size() == getTypedWord().length();
    }

    public boolean isPerfect() {
        return isCorrect() && keyPresses.size() == word.length();
    }
}
