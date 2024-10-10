package studio.crbl.genis.views;

import java.util.List;

import org.fxmisc.richtext.StyleClassedTextArea;

import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;
import studio.crbl.genis.Controller;
import studio.crbl.genis.gamemodes.AbstractGamemode;
import studio.crbl.genis.misc.Word;

public abstract class AbstractView extends GridPane implements Initializable, Runnable {
    protected StyleClassedTextArea textArea = new StyleClassedTextArea();
    protected AbstractGamemode gamemode;
    protected Controller controller;
    protected final Text wpmText = new Text("WPM: 0");
    @FXML protected HBox leftpane;
    @FXML protected VBox rightpane;

    public AbstractView(AbstractGamemode gamemode, Controller controller) {
        this.gamemode = gamemode;
        this.controller = controller;
    }

    /**
     * @return the list of words to be displayed before the cursor
     */
    protected List<Word> getWordsTyped() {
        var list = gamemode.getWords(controller.getPlayer());
        if(list.isEmpty()) {
            return list;
        } else {
            return list.subList(0, list.size() - 1);
        }
    }

    /**
     * @return the word that is curretly being typed
     */
    protected Word getTypingWord() {
        var words = gamemode.getWords(controller.getPlayer());
        if(words.isEmpty()) {
            return null;
        } else {
            return words.get(words.size() - 1);
        }
    }

    /**
     * @return the list of words to be displayed after the cursor
     */
    protected List<Word> getWordsToType() {
        int startIndex = gamemode.getWords(controller.getPlayer()).size();
        int endIndex = Math.min(gamemode.getWords().size(), startIndex + 10);
        return gamemode.getWords().subList(startIndex, endIndex);
    }

    public final void refresh() {
        textArea.setPrefWidth(this.getWidth());
        textArea.clear();
        if(getTypingWord() == null) {
            return;
        }

        for (Word word : getWordsTyped()) {
            String real = word.getWord();
            String typed = word.getTypedWord();
            for (int i = 0; i < real.length() && i < typed.length(); i++) {
                textArea.appendText(String.valueOf(real.charAt(i)));
                if(real.charAt(i) == typed.charAt(i)) {
                    switch(word.getTag()) {
                        case NORMAL:
                            textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "correct");
                            break;
                        case BONUS:
                            if(word.isPerfect()) {
                                textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "bonus-correct");
                            } else {
                                textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "bonus-failed");
                            }
                            break;
                        case MALUS:
                            if(word.isPerfect()) {
                                textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "malus-correct");
                            } else {
                                textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "malus-failed");
                            }
                            break;
                    }
                } else {
                    textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "incorrect");
                }
            }
            for(int i = real.length(); i < typed.length(); i++) {
                textArea.appendText(String.valueOf(typed.charAt(i)));
                textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "overflow");
            }
            for(int i = typed.length(); i < real.length(); i++) {
                textArea.appendText(String.valueOf(real.charAt(i)));
                textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "incorrect");
            }
            textArea.appendText(" ");
            textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "normal");
        }

        int cursor = textArea.getLength();

        {
            Word word = getTypingWord();
            String real = word.getWord();
            String typed = word.getTypedWord();

            for(int i = 0; i < typed.length() && i < real.length(); i++) {
                textArea.appendText(String.valueOf(real.charAt(i)));
                if(real.charAt(i) == typed.charAt(i)) {
                    switch(word.getTag()) {
                        case NORMAL:
                            textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "correct");
                            break;
                        case BONUS:
                            if(word.isPartiallyPerfect()) {
                                textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "bonus-correct");
                            } else {
                                textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "bonus-failed");
                            }
                            break;
                        case MALUS:
                            if(word.isPartiallyPerfect()) {
                                textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "malus-correct");
                            } else {
                                textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "malus-failed");
                            }
                            break;
                    }
                } else {
                    textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "incorrect");
                }
            }
            for(int i = real.length(); i < typed.length(); i++) {
                textArea.appendText(String.valueOf(typed.charAt(i)));
                textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "overflow");
            }
            cursor = textArea.getLength();
            for(int i = typed.length(); i < real.length(); i++) {
                textArea.appendText(String.valueOf(real.charAt(i)));
                switch(word.getTag()) {
                    case NORMAL:
                        textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "normal");
                        break;
                    case BONUS:
                        if(word.isPartiallyPerfect()) {
                            textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "bonus");
                        } else {
                            textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "bonus-failed-untyped");
                        }
                        break;
                    case MALUS:
                        if(word.isPartiallyPerfect()) {
                            textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "malus");
                        } else {
                            textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "malus-failed-untyped");
                        }
                        break;
                }
            }
            textArea.appendText(" ");
            textArea.setStyleClass(textArea.getLength() - 1, textArea.getLength(), "normal");
        }

        for (Word word : getWordsToType()) {
            textArea.appendText(word.getWord() + " ");
                switch(word.getTag()) {
                    case NORMAL:
                        textArea.setStyleClass(textArea.getLength() - word.getWord().length() - 1, textArea.getLength(), "normal");
                        break;
                    case BONUS:
                        textArea.setStyleClass(textArea.getLength() - word.getWord().length() - 1, textArea.getLength(), "bonus");
                        break;
                    case MALUS:
                        textArea.setStyleClass(textArea.getLength() - word.getWord().length() - 1, textArea.getLength(), "malus");
                        break;
                }
        }

        textArea.moveTo(cursor);
    }

    @Override
    public void initialize(java.net.URL location, java.util.ResourceBundle resources) {
        Thread thread = new Thread(this);
        leftpane.getChildren().add(wpmText);
        leftpane.setId("leftpane");
        rightpane.getChildren().add(textArea);
        thread.start();
        textArea.setWrapText(true);
        textArea.setPrefHeight(100);
        textArea.setMaxWidth(600);
        textArea.onKeyTypedProperty().set(event -> {
            if(event.getCharacter().charAt(0) == 8) {
                controller.onKeyPress("RET");
            } else if (!Character.isISOControl(event.getCharacter().charAt(0))) {
                controller.onKeyPress(event.getCharacter());
            }
            event.consume();
        });
        gamemode.setOnUpdate(this::refresh);
        refresh();
        textArea.setId("text-area");
        this.setId("global");
    }

    /**
     * Gets called repeatedly to update the HUD
     */
    protected void updateUhd() {
        wpmText.setText(String.format("WPM: %.2f", gamemode.getStatistics(controller.getPlayer()).wpm));
    }

    @Override
    public void run() {
        if(!gamemode.isOver()) {
            try {
                Thread.sleep(40);
                updateUhd();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            Thread thread = new Thread(this);
            thread.start();
        }
    }
}
