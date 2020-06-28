\version "2.20.0"

#(define (scale-degree degree)
   (if (eqv? degree 0)
       (markup #:null)
       (markup #:circle #:small #:number (number->string degree))))

#(define (bass-degree? obj)
   "A bass degree is either a number between 1 and 7 or 0 (eqv. to
nothing)!"
   (and (integer? obj) (> 8 obj) (< -1 obj)))

#(define (event-chord? obj)
   (and (ly:music? obj) (music-is-of-type? obj 'event-chord)))


#(define (figure-signature? obj)
   "A figure signature is either an EventChord music or a duration."
   (or
    (event-chord? obj)
    (ly:duration? obj)))

duration-from-event-chord =
#(define-scheme-function (chord) (event-chord?)
   (let ((els (ly:music-property chord 'elements)))
     (ly:music-property (first els) 'duration)))

scaledeg =
#(define-music-function (num signature) ((bass-degree? 0) figure-signature?)
   (let ((dur (if (ly:duration? signature)
                  signature
                  (duration-from-event-chord signature))))
     #{
       <<
         #(if (ly:music? signature)
              signature
              #{ s $signature #})
         \context Lyrics = "scaleDegrees" \lyricmode
         {
           \markup { #(scale-degree num) } $dur
         }
       >>
     #}))


makeDegrees = 
#(with-options define-music-function (degrees)(ly:music?)
   `(strict
     ()
     )
   #{
     <<
       \new FiguredBass \with {
         \override VerticalAxisGroup.nonstaff-nonstaff-spacing.padding = 1
         \override BassFigureAlignment.stacking-dir = #DOWN
       } \figs
       \new Lyrics = "scaleDegrees" { #(skip-of-length degrees) }
     >>
   #})
