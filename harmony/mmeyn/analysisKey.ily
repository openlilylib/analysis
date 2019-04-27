\version "2.18.2"

keyStanza =
#(define-music-function (parser location key) (string?)
   (cond
    ((and (= 2 (string-length key))
          (equal? #\< (string-ref key 1)))
     #{ \set stanza = \markup \box \concat { #(substring key 0 1) \teeny \raise #0.8 \sharp ":" } #})
    ((and (= 2 (string-length key))
          (equal? #\> (string-ref key 1)))
     #{ \set stanza = \markup \box \concat { #(substring key 0 1) \teeny \raise #0.4 \flat ":" } #})
    (else
     #{ \set stanza = \markup \box \concat { #key ":" } #})))
