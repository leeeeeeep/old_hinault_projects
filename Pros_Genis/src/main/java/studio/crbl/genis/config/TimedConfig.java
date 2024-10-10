package studio.crbl.genis.config;

import com.beust.jcommander.Parameter;

public class TimedConfig extends BaseConfig {
    @Parameter(names = {"-t", "--time"}, description = "Duration of the game in seconds")
    public int time = 60;
}
