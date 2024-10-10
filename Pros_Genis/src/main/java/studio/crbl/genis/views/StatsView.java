package studio.crbl.genis.views;

import java.net.URL;
import java.util.HashMap;
import java.util.ResourceBundle;

import javafx.beans.property.SimpleDoubleProperty;
import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.chart.LineChart;
import javafx.scene.chart.XYChart;
import javafx.scene.control.TabPane;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import studio.crbl.genis.misc.Player;
import studio.crbl.genis.misc.Statistics;

public class StatsView extends TabPane implements Initializable {
    private static class PlayerStat {
        public final String name;
        public final Statistics stats;

        public PlayerStat(String name, Statistics stats) {
            this.name = name;
            this.stats = stats;
        }
    }

    @FXML private TableView<PlayerStat> table;
    @FXML private TableColumn<PlayerStat, String> nameColumn;
    @FXML private TableColumn<PlayerStat, Double> wpmColumn;
    @FXML private TableColumn<PlayerStat, Double> accuracyColumn;
    @FXML private TableColumn<PlayerStat, Double> consistencyColumn;
    @FXML private LineChart<Integer, Double> chart;

    private ObservableList<PlayerStat> data = FXCollections.observableArrayList();;

    private Statistics stats;

    public StatsView(HashMap<String, Statistics> stats, Player player) {
        stats.forEach((name, stat) -> data.add(new PlayerStat(name, stat)));
        this.stats = stats.get(player.getName());
    }

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        nameColumn.setCellValueFactory(cellData -> new SimpleStringProperty(cellData.getValue().name));
        wpmColumn.setCellValueFactory(cellData -> new SimpleDoubleProperty(cellData.getValue().stats.wpm).asObject());
        accuracyColumn.setCellValueFactory(cellData -> new SimpleDoubleProperty(cellData.getValue().stats.accuracy).asObject());
        consistencyColumn.setCellValueFactory(cellData -> new SimpleDoubleProperty(cellData.getValue().stats.consistency).asObject());

        table.setItems(data);

        chart.setTitle("Game resume");

        // add axis to chart

        XYChart.Series<Integer, Double> series = new XYChart.Series<>();
        series.setName("WPM");
        for(int i = 0; i < stats.slidingWindowWpm.size(); i++) {
            series.getData().add(new XYChart.Data<Integer, Double>(i, stats.slidingWindowWpm.get(i).wpm));
        }
        chart.getData().add(series);
    }
}
