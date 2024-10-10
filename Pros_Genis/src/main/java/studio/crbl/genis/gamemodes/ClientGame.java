package studio.crbl.genis.gamemodes;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import javafx.application.Platform;
import studio.crbl.genis.misc.Player;
import studio.crbl.genis.misc.Statistics;
import studio.crbl.genis.misc.Word;
import studio.crbl.genis.util.Message;
import studio.crbl.genis.util.WebsocketClient;

public class ClientGame extends Lives {
    private double bonus = 0.1;
    private double malus = 0.1;
    private WebsocketClient wsc;
    private Gson gson = new Gson();
    private HashMap<String, Statistics> stats = new HashMap<>();

    public ClientGame(ArrayList<String> allWords, OnGameOver onGameOver, Player player, WebsocketClient wsc, String hostname, int port, String password) {
        super(allWords, onGameOver, player);
        this.wsc = wsc;
        this.wsc.setOnMessage((msg) -> {
            Message<Object> m = gson.fromJson(msg, Message.class);
            if(m.type.equals("malus")) {
                Platform.runLater(() -> {
                    Word word = new Word((String) m.data, Word.Tag.NORMAL);
                    this.wordsGenerated.add(word);
                    if(wordsTyped.get(player.getName()).size() == wordsGenerated.size() - 15) {
                        addKeyPress(new Word.KeyPress(" ", System.currentTimeMillis()), player);
                    }
                    this.onUpdate.onUpdate();
                });
            } else if(m.type.equals("stats")) {
                Type t = new TypeToken<Message<HashMap<String, Statistics>>>(){}.getType();
                Message<HashMap<String, Statistics>> stats = gson.fromJson(msg, t);
                stats.data.keySet().stream().forEach(n -> {
                    this.stats.put(n, stats.data.get(n));
                    this.addPlayer(new Player(n));
                });
                Platform.runLater(() -> {
                    this.onGameOver.onGameOver();
                });
            } else if (m.type.equals("settings")) {
                Type t = new TypeToken<Message<Message.Settings>>(){}.getType();
                Message<Message.Settings> s = gson.fromJson(msg, t);
                this.bonus = (s.data).bonus;
                this.malus = (s.data).malus;
            } else if (m.type.equals("start")) {
                this.start();
                Platform.runLater(() -> {
                    this.onUpdate.onUpdate();
                });
            } else if (m.type.equals("end")) {
                this.wsc.send(gson.toJson(new Message<Statistics>("stats", this.getStatistics(player))));
            }
        });
        new Thread(() -> {
            this.wsc.run();
        }).start();
        System.out.println("Connecting to " + hostname + ":" + port);
    }

    @Override
    public void start() {
        for(int i = 0; i < 7; i++) {
            wordsGenerated.add(getNewWord());
        }

        super.start();
    }

    @Override
    public boolean isOver() {
        return this.lives.get(player.getName()) <= 0;
    }

    @Override
    public void addKeyPress(Word.KeyPress keyPress, Player player) {
        int numWords = wordsTyped.get(player.getName()).size();
        super.addKeyPress(keyPress, player);
        if(numWords < wordsTyped.get(player.getName()).size()) {
            Word word = wordsTyped.get(player.getName()).get(numWords - 1);
            if(word.getTag() == Word.Tag.MALUS && word.isPerfect()) {
                this.wsc.send(gson.toJson(new Message<>("malus", word.getWord())));
            }
        }

        if (isOver()) {
            this.wsc.send(gson.toJson(new Message<>("died", null)));
            onGameOver.onGameOver();
        } else if(onUpdate != null) {
            onUpdate.onUpdate();
        }
    }

    @Override
    protected Word getNewWord() {
        int index = (int) (Math.random() * allWords.size());
        boolean isBonus = Math.random() < bonus;
        boolean isMalus = Math.random() < malus;
        if(isBonus)
            return new Word(allWords.get(index), Word.Tag.BONUS);
        else if(isMalus)
            return new Word(allWords.get(index), Word.Tag.MALUS);
        else
            return new Word(allWords.get(index), Word.Tag.NORMAL);

    }

    @Override
    public Statistics getStatistics(Player player) {
        var s = stats.get(player.getName());
        if(s != null) {
            return s;
        } else {
            return super.getStatistics(player);
        }
    }
}
