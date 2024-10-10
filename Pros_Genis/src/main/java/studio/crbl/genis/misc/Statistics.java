package studio.crbl.genis.misc;

import java.util.ArrayList;
import java.util.List;

public class Statistics {
    public static class PointData {
        public final double wpm;
        public final int errors;
        public final int second;

        public PointData(double wpm, int errors, int second) {
            this.wpm = wpm;
            this.second = second;
            this.errors = errors;
        }
    }
    public final double wpm;
    public final double accuracy;
    public final double consistency;
    public final List<PointData> slidingWindowWpm;

    public Statistics(List<Word> words) {
        if(words.stream().allMatch(w -> w.getTypedWord().length() == 0)) {
            wpm = 0;
            accuracy = 0;
            consistency = 0;
            slidingWindowWpm = new ArrayList<>();
            return;
        }

        double totalCorrectChars = words.stream()
            .mapToInt(word -> word.getCorrectCharacters())
            .sum();
        double normalizedWords = totalCorrectChars / 5;
        double time;
        var lastTypedWord = words.stream()
            .filter(w -> w.getTypedWord().length() > 0)
            .reduce((first, second) -> second)
            .orElse(null); // This should not happen because of first if statement
        var firstTypedWord = words.stream()
            .filter(w -> w.getTypedWord().length() > 0)
            .reduce((first, second) -> first)
            .orElse(null); // This should not happen because of first if statement
        double start = firstTypedWord.getStartTimestamp();
        time = lastTypedWord.getEndTimestamp() - start;
        this.wpm = normalizedWords / time * 60000.0;

        double totalChars = words.stream()
            .mapToInt(word -> word.getWord().length())
            .sum();
        this.accuracy = totalCorrectChars / totalChars * 100.0;


        double count = 0;
        double total = 0;
        for(int i = 0; i < words.size(); i++) {
            long t = words.get(i).getStartTimestamp();
            for(int j = 1; j < words.get(i).getKeyPresses().size(); j++) {
                total += words.get(i).getKeyPresses().get(j).time - t;
                count++;
                t = words.get(i).getKeyPresses().get(j).time;
            }
        }
        double mean = total / count;

        double totalDeviation = 0;

        for(int i = 0; i < words.size(); i++) {
            long t = words.get(i).getStartTimestamp();
            for(int j = 1; j < words.get(i).getKeyPresses().size(); j++) {
                totalDeviation += Math.pow(words.get(i).getKeyPresses().get(j).time - t - mean, 2);
                t = words.get(i).getKeyPresses().get(j).time;
            }
        }

        this.consistency = Math.sqrt(totalDeviation / count) / 1000;

        this.slidingWindowWpm = new ArrayList<>();
        int durationInSeconds = (int) (time / 1000);
        for(int i = 0; i < durationInSeconds; i++) {
            double chars = 0;
            int errors = 0;
            for(int j = 0; j < words.size(); j++) {
                Word word = words.get(j);
                if(word.getStartTimestamp() >= start + i * 1000 - 5000 && word.getStartTimestamp() < start + i * 1000 + 5000) {
                    chars += word.getTypedWord().length();
                }
                if(word.getStartTimestamp() >= start + i * 1000 && word.getStartTimestamp() < start + i * 1000 + 1000) {
                    errors += (word.getKeyPresses().size() - word.getWord().length()) / 2;
                }
            }
            slidingWindowWpm.add(new PointData(chars / 10 / 5 * 60, errors, i));
        }
    }
}
