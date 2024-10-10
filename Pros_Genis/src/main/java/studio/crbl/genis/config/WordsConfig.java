package studio.crbl.genis.config;

import com.beust.jcommander.Parameter;

public class WordsConfig extends BaseConfig {
    @Parameter(names = {"-c", "--count"}, description = "The number of words")
    public int count = 60;
}
