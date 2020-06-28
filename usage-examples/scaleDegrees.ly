\version "2.20.0"

\include "oll-core/package.ily"
\loadModule analysis.harmony.scale-degrees

figs = \figuremode {
  \scaledeg 1 4
  \scaledeg 2 <4 3>4
  \scaledeg 3 <6>4
  \scaledeg 4 <7>4
  \scaledeg 0 <6>
  \scaledeg 5 4
  \scaledeg 6 <6>2
  \scaledeg 6 <6>4
  \scaledeg 7 <6 5>4
  \scaledeg 1 4
  }

<<
   \new Staff {
     \time 3/4
     \clef bass
     c4 d e f2 g4 as2^"or g sharp?" a4 b4 c'4 % Morgenlich leuchtend ...
   }
   \makeDegrees \figs
 >>
