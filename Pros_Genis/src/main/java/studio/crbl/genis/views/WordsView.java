package studio.crbl.genis.views;

import java.util.List;

import javafx.scene.text.Text;
import studio.crbl.genis.Controller;
import studio.crbl.genis.gamemodes.Words;
import studio.crbl.genis.misc.Word;

public class WordsView extends AbstractView {
    private final Text wordsText = new Text("Remaining words: 0");

    public WordsView(Words words, Controller controller) {
        super(words, controller);
    }

    @Override
    public void initialize(java.net.URL location, java.util.ResourceBundle resources) {
        super.initialize(location, resources);
        leftpane.getChildren().add(wordsText);
    }

    protected List<Word> getWordsToType() {
        int startIndex = gamemode.getWords(controller.getPlayer()).size();
        return gamemode.getWords().subList(startIndex, gamemode.getWords().size());
    }

    @Override
    protected void updateUhd() {
        super.updateUhd();
        wordsText.setText("Remaining words: " + (((Words)gamemode).getRemainingWords()));
    }
}
