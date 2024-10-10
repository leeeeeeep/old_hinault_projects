package com.boggle.util;

import java.awt.*;
import java.net.URL;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;
import javax.swing.UIManager;

public class Util {
    public static synchronized void playSound(final String url) {
        new Thread(new Runnable() {
                    public void run() {
                        try {
                            // Play the sound
                            URL u = Util.class.getResource("/sons/" + url);
                            Clip clip = AudioSystem.getClip();
                            clip.open(AudioSystem.getAudioInputStream(u));
                            clip.start();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                })
                .start();
    }

    public static void setUIFont(javax.swing.plaf.FontUIResource f) {
        java.util.Enumeration keys = UIManager.getDefaults().keys();
        while (keys.hasMoreElements()) {
            Object key = keys.nextElement();
            Object value = UIManager.get(key);
            if (value instanceof javax.swing.plaf.FontUIResource) UIManager.put(key, f);
        }
    }

    public static Color getPrimaryDarkColor() {
        return new Color(30, 30, 46);
    }

    public static Color getPrimaryLightColor() {
        return new Color(201, 203, 255);
    }

    public static Color getAccentColor() {
        return new Color(232, 162, 175);
    }
}
