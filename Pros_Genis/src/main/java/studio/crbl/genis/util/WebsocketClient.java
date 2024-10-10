package studio.crbl.genis.util;

import java.net.URI;

import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;

import com.google.gson.Gson;

public class WebsocketClient extends WebSocketClient {
    public interface Error {
        public void error(String message);
    }
    public interface OnMessage {
        public void onMessage(String message);
    }
    private final String name;
    private final String password;
    private static final Gson gson = new Gson();
    private final Error error;
    private OnMessage onMessage;
    private static final Logger logger = Logger.getLogger("CLIENT");

    public WebsocketClient(URI serverUri, String name, String password, Error error) {
        super(serverUri);
        this.name = name;
        this.password = password;
        this.error = error;
    }

    public void setOnMessage(OnMessage onMessage) {
        this.onMessage = onMessage;
    }

    @Override
    public void onOpen(ServerHandshake handshakedata) {
        this.send(gson.toJson(new Message("handshake", new Message.Handshake(name, password))));
    }

    @Override
    public void onMessage(String message) {
        logger.info(message);
        onMessage.onMessage(message);
    }

    @Override
    public void onClose(int code, String reason, boolean remote) {
        if(code == 69) {
            logger.error("Wrong password");
        } else if(code == 42) {
            logger.error("Server is full");
            error.error("Server is full");
        } else {
            logger.error("Websocket error: " + reason);
            error.error("Websocket error");
        }
    }

    @Override
    public void onError(Exception ex) {
        logger.error("Websocket error: " + ex.getMessage());
        error.error("Websocket error");
    }
}