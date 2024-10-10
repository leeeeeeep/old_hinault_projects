package studio.crbl.genis.config;

import com.beust.jcommander.Parameter;

public abstract class BaseConfig implements Config {
    @Parameter(names = {"-w", "--word-list"}, description = "File containing the words to be used")
    public String wordList = null;
}
