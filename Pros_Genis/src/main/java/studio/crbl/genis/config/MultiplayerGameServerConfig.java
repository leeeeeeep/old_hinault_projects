package studio.crbl.genis.config;

import com.beust.jcommander.Parameter;

public class MultiplayerGameServerConfig extends BaseConfig {
    @Parameter(names = {"-h", "--host"}, description = "The ip to bind to")
    public String ip = "localhost";

    @Parameter(names = {"-p", "--port"}, description = "The port to listen on")
    public int port = 6942;

    @Parameter(names = {"-P", "--password"}, description = "The password of the server")
    public String password = null;

    @Parameter(names = {"-m", "--max-players"}, description = "The maximum number of players")
    public int maxPlayers = 2;

    @Parameter(names = {"-b", "--bonus"}, description = "The probability of a bonus appearing")
    public double bonus = 0.069;

    @Parameter(names = {"-M", "--malus"}, description = "The probability of a malus appearing")
    public double malus = 0.1;
}
