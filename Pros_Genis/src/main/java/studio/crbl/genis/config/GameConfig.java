package studio.crbl.genis.config;

import com.beust.jcommander.Parameter;

public class GameConfig extends BaseConfig {
    @Parameter(names = {"-l", "--level"}, description = "The level to start at")
    public int level = 1;

    @Parameter(names = {"-t", "--timeout"}, description = "The time to wait before the first level starts in seconds")
    public int timeout = 5;

    @Parameter(names = {"-b", "--bonus"}, description = "The probability of a bonus appearing")
    public double bonus = 0.069;

    @Parameter(names = {"-n", "--next-level"}, description = "The amount of words to type to get to the next level")
    public int nextLevel = 25;
}
