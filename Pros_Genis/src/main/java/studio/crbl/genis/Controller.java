package studio.crbl.genis;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashMap;

import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.stage.Stage;
import studio.crbl.genis.config.Config;
import studio.crbl.genis.config.GameConfig;
import studio.crbl.genis.config.MultiplayerGameClientConfig;
import studio.crbl.genis.config.TimedConfig;
import studio.crbl.genis.config.WordsConfig;
import studio.crbl.genis.gamemodes.AbstractGamemode;
import studio.crbl.genis.gamemodes.ClientGame;
import studio.crbl.genis.gamemodes.Game;
import studio.crbl.genis.gamemodes.Gamemode;
import studio.crbl.genis.gamemodes.Timed;
import studio.crbl.genis.gamemodes.Words;
import studio.crbl.genis.gamemodes.AbstractGamemode.OnGameOver;
import studio.crbl.genis.misc.Player;
import studio.crbl.genis.misc.Statistics;
import studio.crbl.genis.misc.Word;
import studio.crbl.genis.util.Logger;
import studio.crbl.genis.util.WebsocketClient;
import studio.crbl.genis.views.StatsView;

public class Controller implements OnGameOver {
    private AbstractGamemode game;
    private static final Logger logger = Logger.getLogger("CONTROLLER");
    private final Player player;
    private Stage stage;
    public Controller(Gamemode gamemode, Config config, Stage primaryStage) {
        this.stage = primaryStage;
        ArrayList<String> words = new ArrayList<>();
        new BufferedReader(new InputStreamReader(Controller.class.getResourceAsStream("/words.txt"))).lines().forEach(words::add);
        switch(gamemode) {
            case TIMED:
                TimedConfig timedConfig = (TimedConfig) config;
                player = new Player("Player");
                game = new Timed(words, this, player, timedConfig.time);
                break;
            case WORDS:
                WordsConfig wordsConfig = (WordsConfig) config;
                player = new Player("Player");
                game = new Words(words, this, player, wordsConfig.count);
                break;
            case GAME:
                GameConfig gameConfig = (GameConfig) config;
                player = new Player("Player");
                game = new Game(words, this, player, gameConfig.level, gameConfig.timeout, gameConfig.bonus, gameConfig.nextLevel);
                break;
            case MULTIPLAYER_CLIENT_GAME:
                MultiplayerGameClientConfig mgcc = (MultiplayerGameClientConfig) config;
                WebsocketClient wsc = null;
                try {
                    wsc = new WebsocketClient(new URI(String.format("ws://%s:%s", mgcc.host, mgcc.port)), mgcc.name, mgcc.password, (e) -> {
                        System.exit(1);
                    });
                } catch (URISyntaxException e) {
                    logger.error("Bad host or port");
                    System.exit(1);
                }
                player = new Player(mgcc.name);
                game = new ClientGame(words, this, player, wsc, mgcc.host, mgcc.port, mgcc.password);
                break;
            default:
                player = new Player("");
                logger.error("Multiplayer game is not implemented yet");
                throw new UnsupportedOperationException("Multiplayer game is not implemented yet");
        }

        game.addPlayer(player);

        if(gamemode != Gamemode.MULTIPLAYER_CLIENT_GAME) {
            game.start();
        }
    }

    @Override
    public void onGameOver() {
        Statistics statistics = game.getStatistics(player);
        logger.info(String.format("Speed (WPM): %f", statistics.wpm));
        logger.info(String.format("Accuracy: %f", statistics.accuracy));
        logger.info(String.format("Consistency: %f", statistics.consistency));
        HashMap<String, Statistics> stats = new HashMap<>();
        for(Player p: game.getPlayers()) {
            stats.put(p.getName(), game.getStatistics(p));
        }
        StatsView statsView = new StatsView(stats, player);
        FXMLLoader fxmlLoader = new FXMLLoader();

        fxmlLoader.setController(statsView);
        fxmlLoader.setRoot(statsView);
        try {
            Parent p = fxmlLoader.load(Genis.class.getResourceAsStream("/stats.fxml"));
            stage.getScene().setRoot(p);
        } catch (Exception e) {
            e.printStackTrace();
            logger.error("Could not load stats view");
        }
    }

    public void onKeyPress(String key) {
        Word.KeyPress keyPress = new Word.KeyPress(key, System.currentTimeMillis());
        game.addKeyPress(keyPress, player);
    }

    public AbstractGamemode getGame() {
        return game;
    }

    public Player getPlayer() {
        return player;
    }
}
