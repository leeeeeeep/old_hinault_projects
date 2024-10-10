package studio.crbl.genis;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;
import studio.crbl.genis.config.*;
import studio.crbl.genis.gamemodes.ClientGame;
import studio.crbl.genis.gamemodes.Game;
import studio.crbl.genis.gamemodes.Gamemode;
import studio.crbl.genis.gamemodes.Timed;
import studio.crbl.genis.gamemodes.Words;
import studio.crbl.genis.util.Logger;
import studio.crbl.genis.views.AbstractView;
import studio.crbl.genis.views.ClientGameView;
import studio.crbl.genis.views.GameView;
import studio.crbl.genis.views.TimedView;
import studio.crbl.genis.views.WordsView;

class Args {
    @Parameter(names = {"-d", "--dark-mode"}, description = "Enable dark mode")
    public boolean darkMode = false;
}

public class Genis extends Application {
    private static Logger logger = Logger.getLogger("APP");

    public static void main(String[] args) {
        logger.info("Starting Genis");
        launch(args);
    }

    @Override
    public void start(Stage primaryStage) throws Exception {
        TimedConfig timedConfig = new TimedConfig();
        WordsConfig wordsConfig = new WordsConfig();
        GameConfig gameConfig = new GameConfig();
        MultiplayerGameClientConfig multiplayerGameClientConfig = new MultiplayerGameClientConfig();
        MultiplayerGameServerConfig multiplayerGameServerConfig = new MultiplayerGameServerConfig();
        Args args = new Args();

        JCommander jc = JCommander.newBuilder()
            .addObject(args)
            .addCommand("timed", timedConfig, "t")
            .addCommand("words", wordsConfig, "w")
            .addCommand("game", gameConfig, "g")
            .addCommand("multi-game-client", multiplayerGameClientConfig, "mgc")
            .addCommand("multi-game-server", multiplayerGameServerConfig, "mgs")
            .build();

        try {
            jc.parse(getParameters().getRaw().toArray(new String[0]));
        } catch (Exception e) {
            logger.warn("Unrecognized command");
            jc.usage();
            primaryStage.close();
            System.exit(1);
        }

        String command = jc.getParsedCommand();

        if (command == null) {
            logger.warn("Unrecognized command");
            jc.usage();
            primaryStage.close();
            System.exit(1);
        }

        FXMLLoader fxmlLoader = new FXMLLoader();
        Controller controller = null;
        AbstractView view = null;

        switch (command) {
            case "timed":
                controller = new Controller(Gamemode.TIMED, timedConfig, primaryStage);
                view = new TimedView((Timed)controller.getGame(), controller);
                logger.info("Starting timed game");
                break;
            case "words":
                controller = new Controller(Gamemode.WORDS, wordsConfig, primaryStage);
                view = new WordsView((Words)controller.getGame(), controller);
                logger.info("Starting words game");
                break;
            case "game":
                controller = new Controller(Gamemode.GAME, gameConfig, primaryStage);
                view = new GameView((Game)controller.getGame(), controller);
                logger.info("Starting game game");
                break;
            case "multi-game-client":
                controller = new Controller(Gamemode.MULTIPLAYER_CLIENT_GAME, multiplayerGameClientConfig, primaryStage);
                view = new ClientGameView((ClientGame)controller.getGame(), controller);
                logger.info("Starting client game game");
                break;
            case "multi-game-server":
                logger.info("Starting multiplayer game server");
                break;
        }

        fxmlLoader.setRoot(view);
        fxmlLoader.setController(view);
        Parent p = fxmlLoader.load(Genis.class.getResourceAsStream("/view.fxml"));
        Scene scene = new Scene(p);
        if(args.darkMode) {
            scene.getStylesheets().add(Genis.class.getResource("/dark-style.css").toExternalForm());
        } else {
            scene.getStylesheets().add(Genis.class.getResource("/style.css").toExternalForm());
        }
        primaryStage.setScene(scene);
        primaryStage.onCloseRequestProperty().set(e -> {
            System.exit(0);
        });
        primaryStage.show();
    }
}
