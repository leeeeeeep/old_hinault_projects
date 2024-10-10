package com.boggle.ouga;

import com.beust.jcommander.Parameter;

public class ArgumentsMain {
    @Parameter(
            names = {"--gui", "-g"},
            description = "gui")
    String gui;

    @Parameter(names = {"--port", "-p"})
    int port = 8080;

    @Parameter(
            names = {"--mot-de-passe", "-w"},
            description = "Mot de passe")
    String motDePasse = "";

    public int getPort() {
        return port;
    }

    public String getMotDePasse() {
        return motDePasse;
    }
}
