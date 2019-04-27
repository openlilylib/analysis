Stufensymbole für LilyPond
==========================

Was unterstützt wird
--------------------
* Einfache und robuste Eingabe: Die Reihenfolge der eingegebenen Bestandteile ist (fast) egal, zu viel eingegebenes wird ignoriert.
* Einfache Verwendung als Liedtext oder in Markups.
* Stufen als römische Zahlen in Klein- und Großbuchstaben.
* Bis zu drei Optionen (mit Alterationen) und drei Generalbaßziffern (ohne Alterationen). Alle können auch ohne Stufensymbol eingegeben werden für Durchgänge und Vorhalte.
* Verminderte Dreiklänge, halb-, voll- und dreifach verminderte Septakkorde sowie übermäßige Sext-, Quintsext- und Terzquart-Akkorde.
* Optional vertikal angeordnete ü65 und ü43.
* Rund und eckig eingeklammerte Stufensymbole. Auch eine einseitige Einklammerung (und damit Einklammerung mehrerer aufeinanderfolgender Symbole) ist möglich.
* Passende Skalierung der Abstände bei veränderter `font-size`.
* Automatische Verwendung von Versalziffern.

Was (noch) nicht unterstützt wird
---------------------------------
* Angepaßte vertikale und horizontale Abstände für eine bessere Lesbarkeit.
* Horizontale Linien zwischen Durchgangs- und Vorhaltstönen.
* Einstellbare Abstände für die Anpassung an verschiedene Schriftarten.

Eingabe einzelner Stufensymbole
----------------------------------
### Grundsätzliche Funktion
Stufen werden ganz natürlich eingegeben, z. B. `V` für V und `iii` für iii. Alterationen werden als `<` oder `>` nach der Stufe eingegeben, z. B. `IV<` für ♯IV.
#### Terz
Die Terz (als Versetzungszeichen rechts der Stufe) kann nach einem Punkt als `>`, `<` oder `=` (Auflösungszeichen) eingegeben werden, z. B. `III.<`.
### Akkordtöne
Einzelne Akkordtöne/Optionen werden als Zahl nach einem `-` eingegeben, z. B. `V-7`. Die Optionen werden dabei in der eingegebenen Reihenfolge von unten nach oben ausgegeben, für die Sortierung ist also der Nutzer verantwortlich.
#### Alteration
Alterationen werden als `<`, `>` oder `=` nach der Zahl eingegeben, z. B. `5>` für 5♭. Außerdem kann eine alterierte Terz ohne 3 eingegeben werden. Diese unterscheidet sich in der Ausgabe von der oben genannten Terz.
#### Besondere Optionen
Es stehen `o` für den verminderten Dreiklang, `o7` für den verminderten und `/o` für den halbverminderten Septakkord sowie `ü6`, `ü65` und `ü43` für übermäßige Sext- und verwandte Akkorde zur Verfügung, z. B. `IV<-ü65`. Außerdem gibt es einen dreifach verminderten Septakkord, einzugeben als `vvv`, z. B. `IV<-vvv`. Standardmäßig werden die „ü-Akkorde“ horizontal ausgeschrieben; um die Ziffern übereinander zu setzen, muß `uebermaessig-vertikal` auf `#t` gesetzt werden, siehe hierzu [demo.ly](demo.ly).
### Generalbaßziffern
Generalbaßziffern werden als Zahl nach einem `_` eingegeben. Für die Reihenfolge gilt das gleiche wie für die Akkordtöne; die Reihenfolge der Generalbaßziffern, Akkordtöne und der Stufen untereinander ist aber egal.
### Einklammern
Einzelne Akkorde können rund oder eckig eingeklammert werden; die Positionierung der Klammern ist dabei egal, z. B. `(V)` oder `[]vi`. Auch das Einklammern mehrerer Stufen ist möglich, indem die erste nur eine öffnende und die letzte nur eine schließende Klammer erhält.

Verwendung
----------
Die Verwendung funktioniert genauso wie die der [Funktionssymbole](README-Funktionen.md), nur daß die Befehle nicht `\function` und `\lyricsToFunctions` heißen, sondern `\degree` und `\lyricsToDegrees`. In der Datei [demo.ly](demo.ly) finden sich Anwendungsbeispiele, die passende Ausgabe in [demo.pdf](demo.pdf).
