Tonarten in Liedtexten
======================

Was unterstützt wird
--------------------
* Einfache Eingabe von Tonarten als deutsche oder englische Tonnamen.

Was (noch) nicht unterstützt wird
---------------------------------
* Einstellbares Erscheinungsbild (Kasten oder Kreis etc.).

Verwendung in Liedtexten
------------------------
Siehe hierzu auch Abschnitt „Verwendung“ in der [Dokumentation zu Funktionssymbolen](README-Funktionen.md).

Um die Tonart anzugeben, wird der Befehl `\keyStanza` verwendet. Dabei können deutsche Tonnamen wie beispielsweise `Ges` verwendet werden. Stattdessen können aber auch wie im Englischen üblich, Versetzungszeichen genutzt werden. In Anlehnung an Alterationen bei Funktionssymbolen werden diese als `<` für ♯ und `>` für ♭ eingegeben, z. B. `G>` für G♭.

	\lyrics {
		\lyricsToFunctions
		\keyStanza "Es"
		"T^8"1
		"/D_3"4 "T" "S_3" "(D_3)"
		\keyStanza "c"
		"T"2
	}

Ein Beispiel einer Modulation mit mehreren Zeilen für mehrere Tonarten findet sich in der Datei [alle\_meine\_entchen.ly](alle_meine_entchen.ly), die passende Ausgabe in [alle\_meine\_entchen.pdf](alle_meine_entchen.pdf).
