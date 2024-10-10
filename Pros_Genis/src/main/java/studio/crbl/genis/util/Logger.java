package studio.crbl.genis.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;

public class Logger {
    public enum Level {
        INFO(3),
        WARN(2),
        ERROR(1);

        private final int level;

        private Level(int level) {
            this.level = level;
        }

        public int getLevel() {
            return level;
        }
    };

    private static final HashMap<String, Logger> loggers = new HashMap<>();
    private static final DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");

    private final String name;
    private final Level level;

    static {
        loggers.put("DEFAULT", new Logger("DEFAULT"));
    }

    public Logger(String name, Level level) {
        loggers.put(name, this);
        this.name = name;
        this.level = level;
    }

    public Logger(String name) {
        loggers.put(name, this);
        this.name = name;
        // Get log level from env
        String logLevel = System.getenv("GENIS_" + name.toUpperCase() + "_LOG_LEVEL");

        if (logLevel == null) {
            logLevel = System.getenv("GENIS_LOG_LEVEL");
            if (logLevel == null) {
                this.level = Level.ERROR;
            } else {
                Level level;
                try {
                    level = Level.valueOf(logLevel.toUpperCase());
                } catch (IllegalArgumentException e) {
                    level = null;
                }
                if (level == null) {
                    this.level = Level.ERROR;
                    getLogger("DEFAULT").error("Invalid log level for logger " + name + ": " + logLevel);
                } else {
                    this.level = level;
                }
            }
        } else {
            Level level;
            try {
                level = Level.valueOf(logLevel.toUpperCase());
            } catch (IllegalArgumentException e) {
                level = null;
            }
            if (level == null) {
                this.level = Level.ERROR;
                getLogger("DEFAULT").error("Invalid log level for logger " + name + ": " + logLevel);
            } else {
                this.level = level;
            }
        }
    }

    public static Logger getLogger(String name) {
        if (loggers.containsKey(name)) {
            return loggers.get(name);
        } else {
            Logger logger = new Logger(name);
            loggers.put(name, logger);
            return logger;
        }
    }

    private String generatePrefix(Level level) {
        return String.format("[%5s][%s][%s]", level.toString(), dateTimeFormatter.format(LocalDateTime.now()), name);
    }

    public void info(String message) {
        if (level.getLevel() >= Level.INFO.getLevel()) {
            System.err.printf("%s: %s\n", generatePrefix(Level.INFO), message);
        }
    }

    public void warn(String message) {
        if (level.getLevel() >= Level.WARN.getLevel()) {
            System.err.printf("%s: %s\n", generatePrefix(Level.WARN), message);
        }
    }

    public void error(String message) {
        if (level.getLevel() >= Level.ERROR.getLevel()) {
            System.err.printf("%s: %s\n", generatePrefix(Level.ERROR), message);
        }
    }
}
