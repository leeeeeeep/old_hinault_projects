package studio.crbl.genis;

import com.beust.jcommander.JCommander;

import studio.crbl.genis.config.MultiplayerGameServerConfig;
import studio.crbl.genis.util.Logger;
import studio.crbl.genis.util.WebsocketServer;

public class Server {
    private static Logger logger = Logger.getLogger("SERVER");

    public static void main(String[] args) {
        MultiplayerGameServerConfig conf = new MultiplayerGameServerConfig();

        JCommander jc = JCommander.newBuilder()
            .addObject(conf)
            .build();

        jc.parse(args);

        WebsocketServer server = new WebsocketServer(conf.port, conf.bonus, conf.malus, conf.password, conf.maxPlayers);
        server.run();
    }
}
