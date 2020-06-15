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
% along with anaLYsis.  If not, see <http://www.gnu.org/licenses/>.           %
%                                                                             %
% anaLYsis is maintained by Urs Liska, ul@openlilylib.org                     %
% Copyright Klaus Blum & Urs Liska, 2017                                      %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\version "2.19.83"

\include "oll-core/package.ily"
\loadPackage \with {
  modules = highlighters
} analysis

\paper {
  indent = 0
  ragged-right = ##f
  tagline = ##f
  system-system-spacing.basic-distance = 18
}

pspc = \markup \vspace #0.25
spc = \markup \vspace #1

\markup \fill-line {\bold \huge "Highlighters - Showcase"}
\spc
\markup \justify {
  The \typewriter highlighters module of \typewriter anaLYsis provides a tool to
  colorize subsequent noteheads as it would be done with a textmarker on paper.
}

\spc

\markup \left-align {
  \typewriter {"\\relative c' {r16 " \bold "\highlight {" "c d e   f d e c" \bold "}" " g'8 c b c ..."}
}

\pspc




\score {
  \new Staff \relative c'{
    r16 \highlight { c d e   f d e c }
    g'8 c b c

    d16 \highlight { g, a b   c a b g }
    d'8 g f g

    e16 \highlight \with { color = #red } { a g f   e g f a }
    g \highlight \with { color = #red } { f e d   c e d f }

    e16 \highlight \with { color = #red } { d c b   a c b c }
  }

  \layout {
  }
}


\markup \justify {
  Internally this is done by applying LilyPond's \typewriter "\makeClusters" command
  to the given music expression.

  Therefore two highlighted passages in the same voice will melt into one as long as
  they are not separated by a rest or a (non-highlighted) note.
}

\pspc

\score {
  \new Staff{
    \time 6/8
    \relative c'{
      \autoBeamOn
      \highlight {c8^"intended:" d c8*1/2 } \hide r16  \highlight {e8 f e8*1/2} \hide r16  \highlight {g8 a g8*1/2} \hide r16  r4.
      \bar "||"
      \highlight {c,8^"actual result:" d c}  \highlight {e8 f e}  \highlight {g8 a g}  r4.
      \override Rest.color = #grey
      \bar "||"
      \highlight {c,8^"tweak: invisible rests" d c8*1/2 }  r16  \highlight {e8 f e8*1/2}  r16  \highlight {g8 a g8*1/2}  r16
      \revert Rest.color
      r4.
    }
  }

  \layout {
  }
}


\markup \justify {
  To avoid unexpected results, the highlighted passage should not contain multiple voices.
  However, it is possible to have chords in the melody. Also, multiple voices appearing
  at the same time can \italic contain highlighted passages.
}

\score {
  \new Staff{
    \relative c'' \highlight {
      c4 <d b> <e a,> <f c a f> <e c g> <d b g> <e c g c,>
    } r
    \bar "||"
    <<
      \relative c'' {
        g4   \highlight { c8 b   c2 }
        a4    \highlight {d8 c   d2 }
        b4
      } \\
      \relative c' {
        c4    e2    \highlight { f8 e }
        \highlight { f4 } fis2
        \highlight { g8 fis }
        \highlight { g4 }
      }
    >>
  }

  \layout {
  }
}


\markup  \bold { Appearance: }

\spc

\markup \justify {
  The appearance of the highlighting
  can be specified either persistently with openLilyLib options in the
  \typewriter "\setOption analysis.highlighters" tree or individually by overriding
  properties in a \typewriter "\\with {}" block (for details see below).
}

\spc

\markup \bold { Activate: }

\spc

\markup \column {
  \concat { \typewriter active " " " (default: ##t)" }
}

\markup \justify
{
  With \typewriter "\\setOption analysis.highlighters.active ##f" it is possible
  to - globally or within the music - suppress the application of highlighters.
}

\pspc

\markup \justify
{
  Note that this works within music expressions as well as with toplevel expressions.
  This means that you have to take care of switching highlighting back on if you
  disable it within a music expression. The effect of the setting will be visible
  throughout the whole following LilyPond input, even in subsequent scores.
}
\spc

\markup \bold { Options: }

\spc

\markup \column {
  \concat { \typewriter color " " " (default: #green)" }
}
\pspc
\markup \justify {
  Any color can be assigned.
}

\score {
  \new Staff{
    \relative c' {
      \highlight \with { color = #(rgb-color 1.0 0.0 0.0) } { f4 g f } r
      \highlight \with { color = #(rgb-color 1.0 0.4 0.0) } { f4 g f } r
      \highlight \with { color = #(rgb-color 1.0 0.8 0.0) } { f4 g f } r
      \highlight \with { color = #(rgb-color 1.0 1.0 0.0) } { f4 g f } r
      \highlight \with { color = #(rgb-color 0.8 1.0 0.0) } { f4 g f } r
      \highlight \with { color = #(rgb-color 0.4 1.0 0.0) } { f4 g f } r
      \highlight \with { color = #(rgb-color 0.0 1.0 0.0) } { f4 g f } r
    }
  }

  \layout {
  }
}


\markup \column {
  \concat { \typewriter thickness " " " (default: #2.0)" }
}
\pspc
\markup \justify {
  The thickness of the highlighting line, measured in staff-spaces, can be adjusted. The minimal value is
  0.5 (This is caused by the behavior of the \typewriter ClusterSpanner grob).
  Smaller values will be set to 0.5 which will be indicated by a compiler warning.
}

\pspc

\score {
  \new Staff \new Voice {
    <<
      \relative c'' {
        e4^"thickness: 2.0 (default)" f e d    e2 r
        e4^"thickness: 1.0" f e d    e2 r
        e4^"thickness: 0.5 (minimum)" f e d    e2 r
      }
      \relative c'' {
        \highlight { c4 c c b    c2 } r
        \highlight \with { thickness = #1.0 } { c4 c c b    c2 } r
        \highlight \with { thickness = #0.5 } { c4 c c b    c2 } r
      }
      \relative c'' {
        g4 a g g    g2 r
        g4 a g g    g2 r
        g4 a g g    g2 r
      }
    >>
  }

  \layout {
  }
}

\spc

\markup \column {
  \concat { \typewriter layer " " " (default: #-5)" }
}

\pspc

\markup \justify {
  The \typewriter layer property allows detailed control over the stacking
  of elements. With values above 1 the highlightings would cover the staff
  lines and notes, therefore the value should always be below zero.
  By default, \typewriter layer is set to -5 which is between \italic anaLYsis'
  frames and the staff with its contents.
}

\pspc

\score {
  \new Staff {
    \relative c' {
      \highlight {c4^"layer: -5 (default)" e g c  g e c} r
      \highlight \with {layer = #0 }  {c4^"layer: 0"  e g c  g e c} r
      \highlight \with {layer = #2 }  {c4^"layer: 2"  e g c  g e c} r
    }
  }

  \layout {
  }
}

\spc

\markup \column {
  \concat { \typewriter X-first " " " (default: #-1.0)" }
  \concat { \typewriter X-last  " " " (default: #1.0)" }
  \concat { \typewriter X-offset " " " (default: #0.6)" }
}

\pspc

\markup \justify {
  The beginning and the end of the highlighted area can be shifted horizontally
  by modifying the \typewriter X-first and \typewriter X-last properties.
  By default, there is an offset to the left for the first note and an offset to
  the right for the last note. In most cases, this helps to have the entire note head
  covered by the highlighed area.
}
\pspc
\markup \justify {
  However, in some cases (e.g. large intervals or small \typewriter thickness values) it can look better to set these values
  to zero.
}
\pspc
\markup \justify {
  The \typewriter X-offset property controls a general shift to the right for the
  entire highlighting. By default it is set to 0.6 to have the highlightings aligned
  to the center of the note heads. Usually there should be no need to change this
  setting.
}

\spc


\score {
  \new Staff {
    \override TextScript.self-alignment-X = #CENTER
    \relative c' {
      \highlight { c8^"-1.0"^"first:"^"X-" d c^"1.0"^"last:"^"X-" }
      r8_"X-offset: 0.6 (default)"
      \highlight \with {
        X-first = #0
        X-last  = #0
      } { c8^"0"^"first:"^"X-" d c^"0"^"last:"^"X-" }
      r8
      \highlight \with {
        thickness = #1.0
      } {
        c16^" -1.0"^" first:"^" X-" a''  c,, a''c,,^"(default)"  a''   c,,
        a''^" 1.0"^" last:"^" X-"
      } r2
      \highlight \with {
        thickness = #1.0
        X-first = #0
        X-last  = #0
      } {
        c,,16^" 0"^" first:"^" X-" a''  c,, a'' c,, a''   c,,
        a''^" 0"^" last:"^" X-"
      } r2
      \highlight \with {
        thickness = #1.0
        X-first = #0
        X-last  = #0
        X-offset = #0
      } {
        c,,16^" 0"^" first:"^" X-" a''   c,, a'' c,,_"X-offset: 0" a''   c,,
        a''^" 0"^" last:"^" X-"
      } r2
    }
  }

  \layout {
  }
}

\spc

\markup \justify {
  Non-zero values of \typewriter X-first and \typewriter X-last can have an unwanted side effect:
  They can move the highlighted area away from the first or last notehead when covering large
  intervals. This can be compensated using the following properties:
}

\spc

\markup \column {
  \concat { \typewriter Y-first " " " (default: #0)" }
  \concat { \typewriter Y-last  " " " (default: #0)" }
}

\pspc

\markup \justify {
  These properties allow to manually move the beginning and the end of the highlighted area
  in vertical direction. Negative values will move the beginning/end down, positive values will
  move it up.
}


\pspc


\score {
  \new Staff {
    \override TextScript.self-alignment-X = #CENTER
    \relative c' {
      \highlight \with {

      } { c4^" 0"^" first:"^" Y-" e8 e c4^" 0"^" last:"^" Y-" } r
      \highlight \with {

      } { c4^" 0"^" first:"^" Y-" a''8 a c,,4^" 0"^" last:"^" Y-" } r
      \highlight \with {
        Y-first = #-0.8
        Y-last  = #-1
      } { c4^" -0.8"^" first:"^" Y-" a''8 a c,,4^" -1.0"^" last:"^" Y-" } r
    }
  }


  \layout {
  }
}


\spc

\markup \column {
  \concat { \typewriter style  " " " (default: #'ramp)" }
}

\pspc

\markup \justify {
  The visual appearance of the highlighted area is controlled by the ClusterSpanner
  grob which offers four different styles:
  \typewriter ramp, \typewriter leftsided-stairs, \typewriter rightsided-stairs and
  \typewriter centered-stairs.
}


\pspc



\score {
  \new Staff {
    % \override TextScript.self-alignment-X = #CENTER
    \relative c' {
      \highlight \with {
        thickness = #0.8
        X-first = #0
        X-last  = #0
        style = #'ramp
      } { c8^"ramp" e g c g[ e] c } r
      \highlight \with {
        thickness = #0.8
        X-first = #0
        X-last  = #0
        style = #'leftsided-stairs
      } { c8^"leftsided-stairs" e g c g[ e] c } r
      \highlight \with {
        thickness = #0.8
        X-first = #0
        X-last  = #0
        style = #'rightsided-stairs
      } { c8^"rightsided-stairs" e g c g[ e] c } r
      \highlight \with {
        thickness = #0.8
        X-first = #0
        X-last  = #0
        style = #'centered-stairs
      } { c8^"centered-stairs" e g c g[ e] c } r

    }
  }


  \layout {
  }
}


\spc

\markup \justify {
  In most cases (e.g. if a motif is marked) the default \typewriter ramp style will be the
  best choice.
  Eventually there might be some cases where another style can be useful, e.g. for
  illustrating the pitch of long sustained notes in a counterpoint context:
}


\pspc

\score {
  \new Staff <<
    \hide Staff.TimeSignature
    \time 4/2
    \cadenzaOn

    \new Voice {
      \voiceOne
      r2^"ramp"
      \relative c''
      {
        \highlight \with {
          thickness = #0.5
          X-first = #0
          X-last  = #0
          color = #green
        }
        {
          f2. e4 d c
          b a g2 c a
          \hideNotes a8 \unHideNotes
        }
      }
      \hide r8
      \bar "||"
      r2^"leftsided-stairs"
      \relative c''
      {
        \highlight \with {
          thickness = #0.5
          X-first = #0
          X-last  = #0
          color = #green
          style = #'leftsided-stairs
        }
        {
          f2. e4 d c
          b a g2 c a
          \hideNotes a8 \unHideNotes
        }
      }
      \hide r8
      \bar "||"
    }

    \new Voice {
      \voiceTwo
      \relative c' {
        \highlight \with {
          thickness = #0.8
          X-first = #0
          X-last  = #0
          color = #red
        }
        {
          d1 f g a1
          \hideNotes a8 \unHideNotes
        }
      }
      \hide r8
      \relative c' {
        \highlight \with {
          thickness = #0.8
          X-first = #0
          X-last  = #0
          color = #red
          style = #'leftsided-stairs
        }
        {
          d1 f g a1
          \hideNotes a8 \unHideNotes
        }
      }
      \hide r8
    }
  >>
}

\spc

\markup \bold Stylesheets

\spc

\markup \justify  {
  In order to avoid redundancy in specifying multiple instances
  of identical settings, and to enable semantic markup of highlighted
  music, \italic stylesheets may be provided with the \typewriter
  "\\setHighlightingStyle" command. This expects a \typewriter "\\with { }"
  block where any of the available options can be specified, plus a name
  for the stylesheet.
}

\pspc

\markup \justify {
  When a highligting command is encountered the options are first populated
  with the values from the currently active option settings. If a stylesheet
  is requested for the instance all options defined in the stylesheet are
  overridden. Finally any options given explicitly take precedents over the
  previous two elements. This way it is possible to semantically mark up a
  section and still apply some custom styling for a given instance.
}

\setHighlightingStyle \with {
  thickness = #0.5
  X-first = #0
  X-last  = #0
  color = #green
} counterpoint

\setHighlightingStyle \with {
  thickness = 0.5
  X-first = #0
  color = #darkgreen
  style = #'leftsided-stairs
} cantus

\pspc

% Play around with these to see the effect of en/disabling stylesheets
%\setOption analysis.highlighters.use-only-stylesheets #'(cantus counterpoint)
%\setOption analysis.highlighters.use-only-stylesheets #'(cantus)
\setOption analysis.highlighters.use-only-stylesheets ##t
%\setOption analysis.highlighters.ignore-stylesheets #'(counterpoint)

\score {
  \new Staff <<
    \hide Staff.TimeSignature
    \time 4/2
    \cadenzaOn

    \new Voice {
      \voiceOne
      r2 ^"counterpoint"
      \relative c''
      {
        \highlight \with {
          stylesheet = #'counterpoint
        }
        {
          f2. e4 d c
          b a g2 c a
          \hideNotes a8 \unHideNotes
        }
      }
      \hide r8
      \bar "||"
      r2^"counterpoint with color override"
      \relative c''
      {
        \highlight \with {
          stylesheet = #'counterpoint
          color = #blue
        }
        {
          f2. e4 d c
          b a g2 c a
          \hideNotes a8 \unHideNotes
        }
      }
      \hide r8
      \bar "||"
    }

    \new Voice {
      \voiceTwo
      \relative c' {
        \highlight \with {
          stylesheet = #'cantus
        }
        {
          d1 _"cantus" f g a1
          \hideNotes a8 \unHideNotes
        }
      }
      \hide r8
      \relative c' {
        \highlight \with {
          stylesheet = #'cantus
          X-first = #2
        }
        {
          d1 _"cantus with X-first override" f g a1
          \hideNotes a8 \unHideNotes
        }
      }
      \hide r8
    }
  >>
}

\spc

\markup \bold { Enable/disable stylesheets }

\spc

\markup \column {
  \concat { \typewriter use-only-stylesheets  " " " (list or ##t, default: #'())" }
  \concat { \typewriter ignore-stylesheets  " " " (default: #'())" }
}

\pspc

\markup \justify {
  If the \typewriter use-only-stylesheets option is set to a list of stylesheet names
  only highlighters with these stylesheets are active. Highlighters with
  different or no stylesheets will be ignored. If it is set to \typewriter "##t" then
  highlighters with explicit (but any) stylesheets will be applied.
}

\pspc

\markup \justify {
  If the \typewriter ignore-stylesheets option is set to a list of stylesheet names
  highlighters included in the list will be ignored. Highlighters without
  stylesheet are not affected.
}

\spc

\markup \bold { some random stuff (to be removed if it cannot be used to demonstrate something useful): }

\spc

\score {
  \new Staff \relative c'''{
    \cadenzaOn
    \key d \major
    r16 \highlight {
      a32[ g fis16 a]    e[ a d, a']    cis,[ a' d, a']   cis,[ a' b, a']
      \bar "|" \noBreak
      \stemDown a,[
    } \hideNotes a]  s8 \unHideNotes
    \bar "|" \noBreak
    r16 \highlight \with {
      thickness = #0.8
      X-first = #0
      X-last = #0
    } {
      a'32[ g fis16 a]    e[ a d, a']    cis,[ a' d, a']   cis,[ a' b, a']
      \bar "|" \noBreak
      \stemDown a,[
    } \hideNotes a]  s8
  }

  \layout {}
}



\score {
  \new Staff \relative c''{
    \cadenzaOn
    \key d \major
    r16
    <<
      {
        s16 \highlight { fis8[ e d cis8*1/2 ] } \hide r16 \highlight { d8[ cis b a] }
      }
      \\
      {
        a'32[ g fis16 a]    e[ a d, a']    cis,[ a' d, a']   cis,[ a' b, a']
        \bar "|" \noBreak
        \stemDown a,[
        \hideNotes a]  s8 \unHideNotes
      }
    >>
    \bar "|" \noBreak
    r16
    <<
      {
        s16 \hideNotes
        \highlight { fis'8[ e d cis8*1/2 ] } \hide r16 \highlight { d8[ cis b a] }
        \unHideNotes
      }
      \\
      {
        a'32[ g fis16 a]    e[ a d, a']    cis,[ a' d, a']   cis,[ a' b, a']
        \bar "|" \noBreak
        \stemDown a,[
        \hideNotes a]  s8 \unHideNotes
      }
    >>
  }

  \layout {}
}

