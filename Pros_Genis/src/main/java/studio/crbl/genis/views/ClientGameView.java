package studio.crbl.genis.views;

import java.util.List;

import javafx.scene.text.Text;
import studio.crbl.genis.Controller;
import studio.crbl.genis.gamemodes.ClientGame;
import studio.crbl.genis.misc.Word;

public class ClientGameView extends AbstractView {
    private final Text livesText = new Text("Lives: 0");
    private final Text wordsText = new Text("Words typed: 0");

    public ClientGameView(ClientGame clientGame, Controller controller) {
        super(clientGame, controller);
    }

    @Override
    public void initialize(java.net.URL location, java.util.ResourceBundle resources) {
        super.initialize(location, resources);
        leftpane.getChildren().add(livesText);
        leftpane.getChildren().add(wordsText);
    }

    @Override
    protected void updateUhd() {
        super.updateUhd();
        livesText.setText("Lives: " + (((ClientGame)gamemode).getLives(controller.getPlayer())));
        wordsText.setText("Words: " + (((ClientGame)gamemode).getWordsTyped(controller.getPlayer())));
    }

    @Override
    protected List<Word> getWordsToType() {
        int startIndex = gamemode.getWords(controller.getPlayer()).size();
        return gamemode.getWords().subList(startIndex, gamemode.getWords().size());
    }
}
