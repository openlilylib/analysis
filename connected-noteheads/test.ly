% A simple syntax proposal as a starting point.
% Feel free to remove if obsolete.

\version "2.19.37"

connect-noteheads =
#(define-music-function (parser location col mus) (color? ly:music?)
   #{
     <<
       $mus
       % \new Voice    % changes horizontal spacing. Why?
       \makeClusters {
         \override ClusterSpanner.color = $col
         $mus
       }
     >>
   #})

\score {
  \new Staff \relative c'{
    \connect-noteheads #red {
      c4 d e f g f e d
    }
    c4 d e f g f e d
    \connect-noteheads #green {
      c4 d e f g f e d
    }
    c1
  }

  \layout {
    \context {
      \Voice

      \override ClusterSpanner.X-offset = #0.6
      \override ClusterSpanner.padding = #0.5
      \override ClusterSpanner.layer = #-1
    }
  }
}
