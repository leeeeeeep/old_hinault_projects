package studio.crbl.genis.util;

import java.lang.reflect.Type;
import java.net.InetSocketAddress;
import java.util.HashMap;
import java.util.HashSet;

import org.java_websocket.WebSocket;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import studio.crbl.genis.misc.Statistics;

public class WebsocketServer extends WebSocketServer {
    private final double bonus;
    private final double malus;
    private final Gson gson = new Gson();
    private final HashSet<WebSocket> connections = new HashSet<WebSocket>();
    private final HashMap<WebSocket, String> names = new HashMap<>();
    private final HashMap<String, Statistics> stats = new HashMap<>();
    private String password;
    private int maxPlayers;
    private int died = 0;
    private static final Logger logger = Logger.getLogger("WSS");

    public WebsocketServer(int port, double bonus, double malus, String password, int maxPlayers) {
        super(new InetSocketAddress(port));
        this.bonus = bonus;
        this.malus = malus;
        this.password = password;
        this.maxPlayers = maxPlayers;
    }

    @Override
    public void onOpen(WebSocket conn, ClientHandshake handshake) {
        logger.info("New client connected");
    }

    @Override
    public void onClose(WebSocket conn, int code, String reason, boolean remote) {
        logger.info("Client closed");
        this.connections.remove(conn);
    }

    @Override
    public void onMessage(WebSocket conn, String message) {
        logger.info("New message: " + message);
        Message<Object> msg = gson.fromJson(message, Message.class);
        if(msg.type.equals("handshake")) {
            if (this.connections.size() == maxPlayers) {
                conn.close(42, "Server is full");
                return;
            }
            Type t = new TypeToken<Message<Message.Handshake>>(){}.getType();
            Message<Message.Handshake> handshakeMessage = gson.fromJson(message, t);
            Message.Handshake handshake = handshakeMessage.data;
            if(handshake.password.equals(password)) {
                names.put(conn, handshake.name);
                conn.send(gson.toJson(new Message<>("settings", new Message.Settings(bonus, malus))));
                this.connections.add(conn);
                if(this.connections.size() == maxPlayers) {
                    Thread thread = new Thread(() -> {
                        try {
                            Thread.sleep(5000);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        this.connections.forEach(connection -> {
                            logger.error("Sending start");
                            connection.send(gson.toJson(new Message<>("start", null)));
                        });
                    });
                    thread.start();
                }
            } else {
                conn.close(69, "Wrong password");
            }
        } else if(msg.type.equals("stats")) {
            Type t = new TypeToken<Message<Statistics>>(){}.getType();
            Message<Statistics> stats = gson.fromJson(message, t);
            this.stats.put(this.names.get(conn), stats.data);
            if(this.stats.size() == this.connections.size()) {
                this.connections.forEach(connection -> {
                    connection.send(gson.toJson(new Message<>("stats", this.stats)));
                });
            }
        } else if (msg.type.equals("died")){
            this.died++;
            if(died + 1 == this.connections.size()) {
                this.connections.forEach(connection -> {
                    connection.send(gson.toJson(new Message<>("end", null)));
                });
            }
        } else if(msg.type.equals("malus")) {
            this.connections.forEach(connection -> {
                if(!connection.equals(conn)) {
                    connection.send(message);
                }
            });
        }
    }

    @Override
    public void onError(WebSocket conn, Exception ex) {
        logger.info("Ws error: " + ex.getMessage());
        this.connections.remove(conn);
    }

    @Override
    public void onStart() {
        logger.info("Server started");
    }
}
