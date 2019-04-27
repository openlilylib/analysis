\version "2.19.65"

#(use-modules (ice-9 regex))

#(define uebermaessig-vertikal #f)

#(define-markup-command (degree layout props str) (string?)
   #:properties ((font-size 0)
                 (font-features '()))
   (let* ((F -6)
          (A -6)
          (kl (if (string-match "\\(" str) #t #f))
          (kr (if (string-match "\\)" str) #t #f))
          (el (if (string-match "\\[" str) #t #f))
          (er (if (string-match "\\]" str) #t #f))
          (s-match (string-match "[IViv]+[<>]?" str))
          (s (if s-match (match:substring s-match) " "))
          (l (1- (string-length s)))
          (t-match (string-match "\\.[<>=]" str))
          (t (if t-match (substring (match:substring t-match) 1) #f))
          (o-match (list-matches "-([0-9]+[<>=]?|[<>=o]|o7|/o|ü(65|43|6)|vvv)" str))
          (o (map (lambda (x) (substring (match:substring x) 1)) o-match))
          (g-match (list-matches "_[0-9]+" str))
          (g (map (lambda (x) (substring (match:substring x) 1)) g-match))
          (kl-markup (cond
                      (kl "(")
                      (el "[")
                      (else (markup #:null))))
          (kr-markup (cond
                      (kr ")")
                      (er "]")
                      (else (markup #:null))))
          (s-markup (case (string-ref s l)
                      ((#\i #\I #\v #\V)
                       (markup s))
                      (else
                       (markup (substring s 0 l)))))
          (a #t)
          (a-markup (case (string-ref s l)
                      ((#\<)
                       (markup #:fontsize A
                         #:musicglyph "accidentals.sharp"))
                      ((#\>)
                       (markup #:fontsize A
                         #:musicglyph "accidentals.flat"))
                      (else
                       (begin
                        (set! a #f)
                        (markup #:null)))))
          (t-markup (if t
                        (case (string-ref t 0)
                          ((#\<)
                           (markup #:fontsize A
                             #:musicglyph "accidentals.sharp"))
                          ((#\=)
                           (markup #:fontsize A
                             #:musicglyph "accidentals.natural"))
                          ((#\>)
                           (markup #:fontsize A
                             #:musicglyph "accidentals.flat"))
                          (else
                           (markup #:null)))
                        (markup #:null)))
          (o-markup (map (lambda (x)
                           (let ((v (1- (string-length x))))
                             (case (string-ref x v)
                               ((#\<)
                                (markup #:fontsize F #:concat
                                  ((substring x 0 v)
                                   #:fontsize -4
                                   #:raise 0.4
                                   #:musicglyph "accidentals.sharp")))
                               ((#\=)
                                (markup #:fontsize F #:concat
                                  ((substring x 0 v)
                                   #:fontsize -4
                                   #:raise 0.4
                                   #:musicglyph "accidentals.natural")))
                               ((#\>)
                                (markup #:fontsize F #:concat
                                  ((substring x 0 v)
                                   #:fontsize -4
                                   #:raise 0.2
                                   #:musicglyph "accidentals.flat")))
                               ((#\o)
                                (markup #:fontsize F "ø"))
                               ((#\v)
                                (markup #:fontsize F "3-f. v."))
                               (else
                                (if (and uebermaessig-vertikal
                                         (= 3 v)
                                         (equal? "ü" (substring x 0 2)))
                                    (markup #:fontsize F
                                      #:concat ("ü"
                                                 #:override '(baseline-skip . 1.0)
                                                 #:center-column
                                                 ((substring x 2 3) (substring x 3))))
                                    (markup #:fontsize F x)))))) o))
          (o-markups (case (length o-markup)
                       ((0) (make-list 3 (markup #:null)))
                       ((1) (if t
                                (list (list-ref o-markup 0) (markup #:null) (markup #:null))
                                (list (markup #:null) (list-ref o-markup 0) (markup #:null))))
                       ((2) (if t
                                (append o-markup (list (markup #:null)))
                                (cons (markup #:null) o-markup)))
                       ((3) o-markup)))
          (g-markup (map (lambda (x) (markup #:fontsize F x)) g))
          (g-markups (case (length g-markup)
                       ((0) (make-list 3 (markup #:null)))
                       ((1) (if a
                                (list (list-ref g-markup 0) (markup #:null) (markup #:null))
                                (list (markup #:null) (list-ref g-markup 0) (markup #:null))))
                       ((2) (if a
                                (append g-markup (list (markup #:null)))
                                (cons (markup #:null) g-markup)))
                       ((3) g-markup))))
     (interpret-markup layout props
       #{
         \markup
         \scale #(cons (magstep font-size) (magstep font-size))
         \override #(cons 'font-features (cons "lnum" font-features))
         \normalsize \concat {
           #kl-markup
           \override #(cons 'direction UP)
           \override #(cons 'baseline-skip 1.0)
           \raise #0.2 \dir-column
           #(if a (cons a-markup g-markups) g-markups)
           #s-markup
           \override #(cons 'direction UP)
           \override #(cons 'baseline-skip 1.0)
           \raise #0.2 \dir-column
           #(if t (cons t-markup o-markups) o-markups)
           #kr-markup
         }
       #})))

lyricsToDegrees = \override LyricText.stencil =
#(lambda (grob)
   (grob-interpret-markup grob
     (markup #:degree (ly:grob-property grob 'text))))
