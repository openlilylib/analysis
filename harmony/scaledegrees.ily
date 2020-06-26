\version "2.20.0"

\layout {
  \override BassFigureAlignment.stacking-dir = #UP
}

#(define (figure-signature? obj)
   (or
    (and
     (ly:music? obj)
     (music-is-of-type? obj 'event-chord))
    (ly:duration? obj)))

#(define (parse-signature sig) ; based on \reverseFigures by Harm
   (if
    (ly:music? sig)
    (let*
     ((reversed
       (reverse
        (map
         (lambda (e)
           (cond ((and
                   (eq? #t (ly:music-property e 'bracket-start))
                   (eq? #t (ly:music-property e 'bracket-stop)))
                  '())
             ((eq? #t (ly:music-property e 'bracket-start))
              (begin
               (ly:music-set-property! e 'bracket-start '())
               (ly:music-set-property! e 'bracket-stop #t)))
             ((eq? #t (ly:music-property e 'bracket-stop))
              (begin
               (ly:music-set-property! e 'bracket-stop '())
               (ly:music-set-property! e 'bracket-start #t))))
           e)
         (ly:music-property sig 'elements))))
      (duration (ly:music-property (first reversed) 'duration)))
     (cons duration reversed))
    (cons sig '())
    ))

#(define-scheme-function (mus)(ly:music?)
   (let*
    ((reversed
      (reverse
       (map
        (lambda (e)
          (cond ((and
                  (eq? #t (ly:music-property e 'bracket-start))
                  (eq? #t (ly:music-property e 'bracket-stop)))
                 '())
            ((eq? #t (ly:music-property e 'bracket-start))
             (begin
              (ly:music-set-property! e 'bracket-start '())
              (ly:music-set-property! e 'bracket-stop #t)))
            ((eq? #t (ly:music-property e 'bracket-stop))
             (begin
              (ly:music-set-property! e 'bracket-stop '())
              (ly:music-set-property! e 'bracket-start #t))))
          e)
        (ly:music-property mus 'elements))))
     (duration (ly:music-property (first reversed) 'duration)))
    (cons duration reversed)))

#(define (base-step degree duration)
   (let
    ((step-markup
      (if (eqv? degree 0)
          (markup #:null)
          #{ \markup \circle \small \number #(number->string degree) #})))
    (make-music
     'BassFigureEvent
     'duration
     duration
     'text
     #{ \markup
        \with-dimensions #'(0 . 1) #'(0 . 5)
        #step-markup
     #})))

#(define (bass-degree? obj)
   (and (integer? obj) (> 8 obj) (< -1 obj)))

scaledeg =
#(define-music-function (num signature) ((bass-degree? 0) figure-signature?)
   (let*
    ((props (parse-signature signature))
     (duration (car props))
     (used-signature (cdr props)))
    (make-music
     'EventChord
     'elements
     (cons (base-step num duration)
       used-signature))))

<<
  \new Staff { \clef bass d2 e4 fis g2 a b cis' d' g2 fis1 }
  \figures {
    \scaledeg 1 <5 3>2
    \scaledeg 2 <6>4
    \scaledeg 3 <6>4
    \scaledeg 4 <6 5>2
    \scaledeg 5 2
    \scaledeg 6 <6>2
    \scaledeg 7 <6>4
    \scaledeg <6 5>
    \scaledeg 1 <5 3>2
    \scaledeg 4 <4 2>
    \scaledeg 3 <6>1
  }
>>
