% A simple syntax proposal as a starting point.
% Feel free to remove if obsolete.

\version "2.19.53"

#(define (moment->duration moment)
   ;; see duration.cc in Lilypond sources (Duration::Duration)
   ;; http://lsr.di.unimi.it/LSR/Item?id=542
   (let* ((p (ly:moment-main-numerator moment))
          (q (ly:moment-main-denominator moment))
          (k (- (ly:intlog2 q) (ly:intlog2 p)))
          (dots 0))
     ;(ash p k) = p * 2^k
     (if (< (ash p k) q) (set! k (1+ k)))
     (set! p (- (ash p k) q))
     (while (begin (set! p (ash p 1))(>= p q))
       (set! p (- p q))
       (set! dots (1+ dots)))
     (if (> k 6)
         (ly:make-duration 6 0)
         (ly:make-duration k dots))
     ))

connect-noteheads =
#(define-music-function (parser location col mus) (color? ly:music?)
   ;; http://lilypond.1069038.n5.nabble.com/Apply-event-function-within-music-function-tp202841p202847.html
   (let* ((elms (ly:music-property mus 'elements))
          ; last music-element:
          (lst (last elms)) ; TODO test for list? and ly:music?
          ; length of entire music expression "mus":
          (len (ly:music-length mus))
          ; length of last element only:
          (last-skip (ly:music-length lst))
          ; difference = length of "mus" except the last element:
          (first-skip (ly:moment-sub len last-skip)))
     #{
       <<
         $mus
         % \new Voice
         \makeClusters {
           \once \override ClusterSpanner.color = $col
           \once \override ClusterSpannerBeacon.X-offset = #-1.5  % TODO: replace fixed value with parameter or property
           <<
             $mus
             {
               % skip until last element starts:
               #(if (not (equal? first-skip (ly:make-moment 0/1 0/1))) ; skip with zero length would cause error
                    (make-music 'SkipEvent 'duration (moment->duration first-skip)))
               \once \override ClusterSpannerBeacon.X-offset = #1.5  % TODO: replace fixed value with parameter or property
             }
           >>
         }
       >>
     #}))

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
      \override ClusterSpanner.padding = #1.0
      \override ClusterSpanner.layer = #-1
    }
  }
}
