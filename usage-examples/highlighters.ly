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
  Internally this is done by applying LilyPond's \typewriter "\makeClusters" commmand
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
      \highlight {c,8^"actual result:" d c}  \highlight {e8 f e}  \highlight {g8 a g}  r4.
      \override Rest.color = #grey
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
    << \relative c'' {
      g4   \highlight { c8 b   c2 }
      a4    \highlight {d8 c   d2 }
      b4
       } \\ 
       \relative c' {
         c4    e2    \highlight { f8 e }
         \highlight { f4 } fis2    \highlight { g8 fis }
         \highlight { g4 }
    } >>
  }
  
  \layout {
  }
}

\markup \justify {
  The appearance of the highlighting
  can be specified either persistently with openLilyLib options in the
  \typewriter "\setOption analysis.highlighters" tree or individually by overriding
  properties in a \typewriter "\\with {}" block (for details see below).
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
      \highlight \with { color = #(rgb-color 1.0 0.0 0.0) } { f4 f' f, } r
      \highlight \with { color = #(rgb-color 1.0 0.4 0.0) } { f4 f' f, } r
      \highlight \with { color = #(rgb-color 1.0 0.8 0.0) } { f4 f' f, } r
      \highlight \with { color = #(rgb-color 1.0 1.0 0.0) } { f4 f' f, } r
      \highlight \with { color = #(rgb-color 0.8 1.0 0.0) } { f4 f' f, } r
      \highlight \with { color = #(rgb-color 0.4 1.0 0.0) } { f4 f' f, } r
      \highlight \with { color = #(rgb-color 0.0 1.0 0.0) } { f4 f' f, } r
    }
  }
  
  \layout {
  }
}


\markup \column {
  \concat { \typewriter thickness " " " (default: #1.0)" }
}
\pspc
\markup \justify {
  The thickness of the highlighting line can be adjusted. The minimal value is 
  about 0.25 whereas smaller values will increase the optical thickness
  again. This is caused by the behavior of the \typewriter ClusterSpanner grob.
}

\pspc

\score {
  \new Staff \new Voice {
    << 
      \relative c'' { 
        e4^"thickness: 1.0 (default)" f e d    e2 r 
        e4^"thickness: 0.5" f e d    e2 r 
        e4^"thickness: 0.25 (minimum)" f e d    e2 r 
      }
      \relative c'' {
        \highlight { c4 c c b    c2 } r
        \highlight \with { thickness = #0.5 } { c4 c c b    c2 } r
        \highlight \with { thickness = #0.25 } { c4 c c b    c2 } r
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
  \concat { \typewriter offset-first " " " (default: #-1.0)" }
  \concat { \typewriter offset-last  " " " (default: #1.0)" }
  \concat { \typewriter X-offset " " " (default: #0.6)" }
}

\pspc

\markup \justify {
  The beginning and the end of the highlighted area can be shifted horizontally 
  by modifying the \typewriter offset-first and \typewriter offset-last properties. 
  By default, there is an offset to the left for the first note and an offset to 
  the right for the last note. In most cases, this helps to have the entire note head
  covered by the highlighed area. 
}
\pspc
\markup \justify {
  However, in some cases (e.g. large intervals) it can look better to set these values 
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
      \highlight { c8^"-1.0"^"first:" d^" "^" "^"offset-" c^"1.0"^"last:" }
      r8_"X-offset: 0.6 (default)"
      \highlight \with { 
        offset-first = #0
        offset-last  = #0
      } { c8^"0"^"first:" d^" "^" "^"offset-" c^"0"^"last:" }
      r8
      \highlight \with { 
        thickness = #0.5 
      } {  
        c16^" -1.0"^" first:"^" offset-" a''  c,, a''c,,^"(default)"  a''   c,, 
        a''^" 1.0"^" last:"^" offset-" } r2
      \highlight \with { 
        thickness = #0.5
        offset-first = #0
        offset-last  = #0
      } {  
        c,,16^" 0"^" first:"^" offset-" a''  c,, a'' c,, a''   c,, 
        a''^" 0"^" last:"^" offset-" } r2
      \highlight \with { 
        thickness = #0.5 
        offset-first = #0
        offset-last  = #0
        X-offset = #0
      } {  c,,16^" 0"^" first:"^" offset-" a''   c,, a'' c,,_"X-offset: 0" a''   c,, 
           a''^" 0"^" last:"^" offset-" } r2
    }
  }
  
  \layout {
  }
}


\spc


\spc \spc \spc \spc

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
      thickness = #0.4 
      offset-first = #0
      offset-last = #0
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

