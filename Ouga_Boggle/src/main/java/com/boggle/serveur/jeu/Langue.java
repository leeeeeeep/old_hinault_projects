package com.boggle.serveur.jeu;

import com.beust.jcommander.IStringConverter;

/** Liste des langues supportées. */
public enum Langue implements IStringConverter<Langue> {
    FR,
    EN,
    DE,
    ES;

    @Override
    public Langue convert(String value) {
        try {
            return Langue.valueOf(value);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
