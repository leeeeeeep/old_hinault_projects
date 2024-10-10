package studio.crbl.genis.config;

import com.beust.jcommander.Parameter;

public class MultiplayerGameClientConfig implements Config {
    @Parameter(names = {"-h", "--host"}, description = "The host to connect to")
    public String host = "localhost";

    @Parameter(names = {"-p", "--port"}, description = "The port to connect to")
    public int port = 6942;

    @Parameter(names = {"-n", "--name"}, description = "The name to use", required = true)
    public String name = null;

    @Parameter(names = {"-P", "--password"}, description = "The password of the server")
    public String password = null;
}
