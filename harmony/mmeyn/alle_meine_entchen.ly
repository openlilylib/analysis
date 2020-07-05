\version "2.19.65"
\language "deutsch"

\include "oll-core/package.ily"
\loadModule analysis.harmony.functional

\markup "per \\addlyrics: Hier muß für mehrere Zeichen pro Note getrickst werden (unsichtbare Noten),"
\markup "dafür müssen die meisten Positionen nicht von Hand angegeben werden."

\relative {
  c'4 d e f
  g2 g
  a4 a a a
  g1*1/2 \once \hideNotes g
  a4 a a a
  g1
  f4 f f f
  e2 e2*1/2 \once \hideNotes e
  g4 g g g
  c,1
  \bar "|."
}
\addlyrics {
  \lyricsToFunctions
  "T" "/D_3-7" "(D_7)" "S_3"
  "T_5" "_3"
  "Sp_3" _ "DD_3-7" _
  "D-4-6" "-3-5"
  "DD-v^5" _ _ _
  "tP_3"
  "(D-v_5>" "s_5" "/D-5>-7-9>" "D-7-9>)"
  "Tp" "(D_5-7)" "[S]"
  "dG_3" _ "D-6" "-5-7"
  "T"
}

\markup "per \\lyrics: Dauern von Hand eingegeben"

<<
  \relative {
    c'4 d e f
    g2 g
    a4 a a a
    g1
    a4 a a a
    g1
    f4 f f f
    e2 e
    g4 g g g
    c,1
    \bar "|."
  }
  \lyrics {
    \lyricsToFunctions
    "T"4 "/D_3-7" "(D_7)" "S_3"
    "T_5"2 "_3"
    "Sp_3" "DD_3-7"
    "D-4-6" "-3-5"
    "DD-v^5"1
    "tP_3"
    "(D-v_5>"4 "s_5" "/D-5>-7-9>" "D-7-9>)"
    "Tp"2 "(D_5-7)"4 "[S]"
    "dG_3"2 "D-6"4 "-5-7"
    "T"1
  }
>>

\markup "\\lyricsToFunctions kann übrigens per \\undo rückgängig gemacht und mit \\once einmalig eingesetzt werden:"

%\setPresetFilters analysis.harmony.functional require-preset ##t

\relative {
  c'4 c c c c c c c c c c c c c c c c1 \bar "|."
}
\addlyrics {
  \lyricsToFunctions
  "T" "DD-v" "T" "DD-v"
  "T" \undo \lyricsToFunctions ge -- nug ge --
  pen -- delt \once \lyricsToFunctions "tG_3" jetzt
  ist dann auch mal Schluß!
}

\markup "Tonarten können per \refKey eingegeben werden."
\markup \concat { "Versetzungszeichen wie " \teeny \raise #0.8 \sharp " in F" \teeny \raise #0.8 \sharp " werden dabei als < bzw. > eingegeben." }
<<
  \relative {
    \key es \major
    c''2 d4 d
    es2( e
    f2.) f4
    d1
  }
  \addlyrics {
    Freu -- de dem Sterb -- li -- chen
  }
  \addlyrics {
    \lyricsToFunctions
    \refKey "E>"
    "S" "D_7" _ "T_3"
  }
  \addlyrics {
    \override Lyrics.VerticalAxisGroup.nonstaff-nonstaff-spacing.basic-distance = 4.5
    \lyricsToFunctions
    \refKey "Es"
    "S" "D_7" _ "T_3"
  }
  \lyrics {
    \lyricsToFunctions
    _1
    \refKey "B"
    "S_3"2 "DD-v_5>" "D-4-6" "-3-5" "T"1
  }
>>
