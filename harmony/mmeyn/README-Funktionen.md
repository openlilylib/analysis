Funktionssymbole für LilyPond
=============================

Was unterstützt wird
--------------------
* Einfache und robuste Eingabe: Die Reihenfolge der eingegebenen Bestandteile ist (fast) egal, zu viel eingegebenes wird ignoriert.
* Einfache Verwendung als Liedtext oder in Markups.
* Funktionen T, t, D, d, S, s und Doppelfunktionen (Doppeldominanten etc.).
* Parallelen (P, p) und Gegenklänge (G, g, L, l).
* (Deutschsprachige) Tonnamen statt Funktionen.
* Sopran- und Baßtöne sowie bis zu drei Optionen. Alle können auch ohne Funktionssymbol eingegeben werden für Durchgänge und Vorhalte.
* Verkürzte Akkorde (Durchstreichung), Neapolitaner (n, N) und verminderte Septakkorde (v).
* Rund und eckig eingeklammerte Funktionssymbole. Auch eine einseitige Einklammerung (und damit Einklammerung mehrerer aufeinanderfolgender Symbole) ist möglich.
* Angepaßte vertikale und horizontale Abstände für eine bessere Lesbarkeit.
* Passende Skalierung der Abstände bei veränderter `font-size`.
* Automatische Verwendung von Versalziffern.

Was (noch) nicht unterstützt wird
---------------------------------
* Orgelpunkte.
* Horizontale Linien zwischen Durchgangs- und Vorhaltstönen.
* Alterationen mit ♯ und ♭ statt < und >.
* Automatische Positionierung von Toniken, die nicht auftreten wie in „(s D⁷) [Tp]“.
* Einstellbare Abstände für die Anpassung an verschiedene Schriftarten.
* Zu Tonnamen: Das ganze Alphabet ist nutzbar, es gibt also keine Beschränkung auf die deutsche Sprache (bis auf die Abstände von Baß- und Soprantönen). Noch nicht unterstützt werden aber Tonnamen mit Versetzungszeichen wie F♯ statt Fis.

Eingabe einzelner Funktionssymbole
----------------------------------
### Grundsätzliche Funktion
Funktionen oder Tonnamen werden ganz natürlich eingegeben, z. B. `fis` für fis und `Tp` für Tp; Doppeldominanten und -subdominanten erhält man dabei mit einem doppelten Buchstaben, z. B. `DD`.
### Verkürzen
Eine Funktion wird durch einen Schrägstrich verkürzt, z. B. `/D`. Wo der Strich genau steht, ist dabei egal.
### Akkordtöne
Einzelne Akkordtöne/Optionen werden als Zahl nach einem `_` (Baßton), `^` (Sopranton) oder `-` (Optionston, rechts oben) eingegeben, z. B. `D-7`. Die Optionen werden dabei in der eingegebenen Reihenfolge von unten nach oben ausgegeben, für die Sortierung ist also der Nutzer verantwortlich. Ob aber Baß- und Sopranton vorher oder nachher eingegeben werden, ist egal.
#### Alteration
Alterationen werden als `>` und `<` direkt nach der Zahl eingegeben, z. B. `D-5<`.
#### Besondere Optionen
Es stehen `v` für den verminderten Septakkord und `n` sowie `N` für den normalen und den verselbständigten Neapolitaner zur Verfügung, z. B. `s-n`.
### Einklammern
Einzelne Akkorde können rund oder eckig eingeklammert werden; die Positionierung der Klammern ist dabei egal, z. B. `(D)` oder `[]Tp`. Auch das Einklammern mehrerer Funktionen ist möglich, indem die erste nur eine öffnende und die letzte nur eine schließende Klammer erhält.

Verwendung
----------
### In Markups
Es steht der Markup-Befehl `\function` zur Verfügung, dieser kann in beliebigen Markups verwendet werden:

	\markup \concat {
		"Der übermäßige Quintsextakkord ist i. d. R. ein "
		\function #"/DD_5>-7-9>"
		". Er kann kurz als "
		\function #"DD-v_5>"
		" geschrieben werden."
	}

Weitere Beispiele finden sich in der Datei [demo.ly](demo.ly), die passende Ausgabe in [demo.pdf](demo.pdf).
### In Liedtexten
Die Funktionen können ganz einfach als Silben im `\lyricmode` (also auch in `\lyrics` und `\addlyrics`) eingegeben werden. Zu beachten ist dabei, daß die Symbole i. d. R. wegen der vorkommenden Zahlen und Sonderzeichen in Anführungszeichen zu setzen sind. Ansonsten wird wie mit normalem Liedtext verfahren, nur vor die erste Silbe wird noch der Befehl `\lyricsToFunctions` gesetzt:

	\lyrics {
		\lyricsToFunctions
		"T^8"1
		"/D_3"4 "T" "S_3" "(D_3)"
		"Tp"2
	}

Weitere Beispiele finden sich in der Datei [alle\_meine\_entchen.ly](alle_meine_entchen.ly), die passende Ausgabe in [alle\_meine\_entchen.pdf](alle_meine_entchen.pdf).

Der Befehl `\lyricsToFunctions` ist mit `\once` und `\undo` kombinierbar.
