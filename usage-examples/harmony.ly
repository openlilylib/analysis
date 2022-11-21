%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% This file is part of anaLYsis,                                              %
%                      ========                                               %
% a toolkit to highlight analytical results and comments in musical scores,   %
% belonging to openLilyLib (https://github.com/openlilylib                    %
%              -----------                                                    %
%                                                                             %
% anaLYsis is free software: you can redistribute it and/or modify            %
% it under the terms of the GNU General Public License as published by        %
% the Free Software Foundation, either version 3 of the License, or           %
% (at your option) any later version.                                         %
%                                                                             %
% anaLYsis is distributed in the hope that it will be useful,                 %
% but WITHOUT ANY WARRANTY; without even the implied warranty of              %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               %
% GNU Lesser General Public License for more details.                         %
%                                                                             %
% You should have received a copy of the GNU General Public License           %
% along with ScholarLY.  If not, see <http://www.gnu.org/licenses/>.          %
%                                                                             %
% anaLYsis is maintained by Urs Liska, ul@openlilylib.org                     %
% Copyright Klaus Blum & Urs Liska, 2017                                      %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
  This file loads the analysis.harmony module
  and shows some examples
%}

\version "2.23.80"
\include "oll-core/package.ily"
\loadPackage \with {
  modules = harmony
} analysis


% ---------------------------------------------------------------
% ----- Voices: soprano, alto, tenor
% ---------------------------------------------------------------

global  = { \key c \major  \time 4/4}

sopranmel = \relative c'' {
  \clef treble
  \stemUp
  \global
  e4 e e( d)
  c4 d d2
  d4 e8 d c4 c
  d8( c) <b g>4 c2\fermata

}

altmel = \relative c'' {
  \clef treble
  \stemDown
  \global
  c4 bes a2
  a4 c c( b)
  b2 g4 a
  a4 \hideNotes g8 s \unHideNotes g2
}

tenormel = \relative c' {
  \clef treble
  \stemDown
  \global
  g'4 g f2
  d4 a' a( g)
  e2 e4 f
  d4 d8( f) e2
}



% ---------------------------------------------------------------
% ----- hidden bass voice (not to be displayed, only
% ----- for aligning the lyrics via "lyricsto"
% ---------------------------------------------------------------

bassmelhidden =
\relative c {
  \clef bass
  \stemDown
  \global
  \override NoteHead.color = #red
  \override NoteColumn.ignore-collision = ##t
  f,4 cis'4 d d
  f4 fis4 g g
  gis4 gis8 gis bes4 a8 g
  fis8 fis g8 g c,2
}

% ---------------------------------------------------------------
% ----- bass voice to be displayed
% ---------------------------------------------------------------

bassmelshown = \relative c {
  \clef bass
  \stemNeutral
  \global
  %    \hideNotes
  c4 cis4 d2
  f4 fis4 g2
  gis2 bes4 a8 g
  fis4 g4 c,2
}

% ---------------------------------------------------------------
% ----- "lyrics": Symbols for functional harmony
% ---------------------------------------------------------------

lyr = \lyricmode {
  \override LyricText.self-alignment-X = #LEFT
  \override LyricExtender.left-padding = #-0.5
  \override LyricExtender.extra-offset = #'(0 . 0.5)

  % Usage:
  %
  % FunctionLetter SopranoNote BassNote OptA OptB OptC OptD OptE FillStr

  \set stanza = #"C-Dur:"
  \markup \fSymbol "T" "3" ""  "" "" "" "" ""   ""
  \openbracket
  \markup \fSymbol \crossout "D" "" "3" "7" "9>" "" "" ""   ")"
  \fExtend "     " % call this function BEFORE the lyric event
  \markup \fSymbol "Sp" "" ""  "9" "" "" "" ""   ""
  \startTextSpan  % call \startTextSpan AFTER the lyric event
  \markup \fSymbol "" "" ""  "8" "" "" "" ""   ""
  \stopTextSpan
  \markup \fSymbol "S" "" ""  "5" "6" "" "" ""   ""
  \openbracket
  \markup \fSymbol "D" "" "3"  "7" "" "" "" ""   " )"
  \fExtend "   "
  \markup \fSymbol "D" "" ""  "2" "4" "" "" ""   ""
  \startTextSpan
  \markup \fSymbol "" "" ""  "1" "3" "" "" ""   ""
  \stopTextSpan
  \openbracket
  \fExtend "   "
  \markup \fSymbol "D" "" "3"  "7" "" "" "" ""   ""
  \startTextSpan
  \markup \fSymbol "" "" ""  "8" "" "" "" ""   ""
  \markup \fSymbol "" "" ""  "7" "" "" "" ""   " )[Tp]"
  \stopTextSpan
  \openbracket
  \markup \fSymbol "D" "" "7"  "" "" "" "" ""   ")"
  \fExtend "   "
  \markup \fSymbol "S" "" "3"  "" "" "" "" ""   ""
  \startTextSpan
  \markup \fSymbol " " "" "2"  "" "" "" "" ""   ""
  \stopTextSpan
  \fExtend "    "
  \markup \fSymbol \double "D" "" "3"  "8" "" "" "" ""   ""
  \startTextSpan
  \markup \fSymbol "" "" ""  "7" "" "" "" ""   ""
  \stopTextSpan
  \fExtend "   "
  \markup \fSymbol "D" "" ""  "5" "" "" "" ""   ""
  \startTextSpan
  \markup \fSymbol "" "" ""  "7" "" "" "" ""   ""
  \stopTextSpan
  \markup \fSymbol "T" "" ""  "" "" "" "" ""   ""
}


\score {
  \new GrandStaff <<
    \new Staff = upper
    \with { printPartCombineTexts = ##f }
    {
      <<
        \sopranmel \\
        \partCombine \altmel \tenormel
      >>
    }
    \new Staff = lower
    \new Voice = "bassstimmeSichtbar"
    \with { printPartCombineTexts = ##f }
    {
      <<
        \bassmelshown
        % change "NullVoice" to "Voice" to make the hidden bass voice visible:
        \new NullVoice = "bassstimme" {\shiftOff  \bassmelhidden}
        \new Lyrics \lyricsto "bassstimme" \lyr
      >>
    }
  >>
  \layout {
    \context {
      \Lyrics
      \consists "Text_spanner_engraver"
    }
  }
}

\markup \vspace #2

\score {
  \relative c' { c1 c c2 c c c c c }
  \addlyrics {
    \override LyricText.self-alignment-X = #LEFT
    \set stanza = #"Usage:"
    \markup \fSymbol "F" "2" "3"  "4" "5" "6" "7" "8"   "9"
    \markup \fSymbol "Function" "Soprano" "Bass"  "OptA" "OptB" "OptC" "OptD" "OptE"   "FillStr       "
    \override LyricText.self-alignment-X = #CENTER
    \markup \fSymbol "S" "" ""  "" "" "" "" ""   ""
    \markup \fSymbol "D" "" ""  "" "" "" "" ""   ""
    \markup \fSymbol \double S "  \double S  " ""  "" "" "" "" ""   ""
    \markup \fSymbol \double "D" "  \double D  " ""  "" "" "" "" ""   ""
    \markup \fSymbol \crossout "D" "  \crossout D  " ""  "" "" "" "" ""   ""
    \markup \fSymbol \crossout \double "D" "  \crossout\double D  " ""  "" "" "" "" ""   ""
  }
}
