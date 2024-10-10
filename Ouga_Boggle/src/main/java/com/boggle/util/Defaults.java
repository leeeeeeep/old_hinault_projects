package com.boggle.util;

public class Defaults {
    public static String getDossierSauvegardes() {
        return System.getProperty("user.home") + "/.local/share/ouga-boggle/saves";
    }

    public static String getDossierHistorique() {
        return System.getProperty("user.home") + "/.local/share/ouga-boggle/history";
    }
}
