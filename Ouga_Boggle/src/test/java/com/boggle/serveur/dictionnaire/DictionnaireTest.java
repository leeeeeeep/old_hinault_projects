package com.boggle.serveur.dictionnaire;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import com.boggle.serveur.jeu.Langue;
import org.junit.Test;

/**
 * Test de la classe Dictionnaire.
 */
public class DictionnaireTest {
    @Test
    public void trouveLesMotsFrancais() {
        Dictionnaire.generer(Langue.FR);
        assertTrue(Dictionnaire.estUnMot("chapeau"));
        assertTrue(Dictionnaire.estUnMot("cheval"));
        assertTrue(Dictionnaire.estUnMot("des"));
        assertTrue(Dictionnaire.estUnMot("desabonnaient"));
        assertFalse(Dictionnaire.estUnMot("desabonnaien"));
        assertFalse(Dictionnaire.estUnMot("hfaghd"));
        assertFalse(Dictionnaire.estUnMot("friend"));
        assertFalse(Dictionnaire.estUnMot(""));
    }

    @Test
    public void trouveLesMotsAnglais() {
        Dictionnaire.generer(Langue.EN);
        assertTrue(Dictionnaire.estUnMot("hat"));
        assertTrue(Dictionnaire.estUnMot("hello"));
        assertFalse(Dictionnaire.estUnMot("anglais"));
        assertFalse(Dictionnaire.estUnMot(""));
    }

    @Test
    public void trouveLesMotsEspagnols() {
        Dictionnaire.generer(Langue.ES);
        assertTrue(Dictionnaire.estUnMot("senorita"));
        assertTrue(Dictionnaire.estUnMot("embicadura"));
        assertFalse(Dictionnaire.estUnMot("bonjour"));
        assertFalse(Dictionnaire.estUnMot(""));
    }

    @Test
    public void trouveLesMotsAllemands() {
        Dictionnaire.generer(Langue.DE);
        assertTrue(Dictionnaire.estUnMot("mitteilenswerter"));
        assertTrue(Dictionnaire.estUnMot("verfahrensstufe"));
        assertFalse(Dictionnaire.estUnMot("bonjour"));
        assertFalse(Dictionnaire.estUnMot(""));
    }
}
