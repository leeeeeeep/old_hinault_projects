package studio.crbl.genis.views;

import javafx.scene.text.Text;
import studio.crbl.genis.Controller;
import studio.crbl.genis.gamemodes.Timed;

public class TimedView extends AbstractView {
    private final Text timeText = new Text("Remaining time: 0s");

    public TimedView(Timed timed, Controller controller) {
        super(timed, controller);
    }

    @Override
    public void initialize(java.net.URL location, java.util.ResourceBundle resources) {
        super.initialize(location, resources);
        leftpane.getChildren().add(timeText);
    }

    @Override
    protected void updateUhd() {
        super.updateUhd();
        timeText.setText("Remaining time: " + (((Timed)gamemode).getRemainingSeconds()) + "s");
    }
}
