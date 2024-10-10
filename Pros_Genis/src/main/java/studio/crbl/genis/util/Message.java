package studio.crbl.genis.util;

public class Message<T> {
    public String type;
    public T data;

    public Message(String type, T data) {
        this.type = type;
        this.data = data;
    }

    static public class Settings {
        public double bonus;
        public double malus;

        public Settings(double bonus, double malus) {
            this.bonus = bonus;
            this.malus = malus;
        }
    }

    static public class Handshake {
        public String name;
        public String password;

        public Handshake(String name, String password) {
            this.name = name;
            this.password = password;
        }
    }
}
