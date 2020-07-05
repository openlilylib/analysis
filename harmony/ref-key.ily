\version "2.18.2"

#(define (box-type? obj)
   (if (member obj
         '("none"
            "box"
            "rounded-box"
            "circle"
            "ellipse"
            "oval"
            "bracket"
            "hbracket"
            "parenthesize"))
       #t #f))

#(define (string-or-false? obj)
   (or (string? obj)
       (eq? obj #f)))

\definePropertySet analysis.harmony.ref-key
#`((box-type ,box-type? "rounded-box")
   (box-padding ,number? 0.15)
   ; TODO: This is not implemented yet
   (box-thickness ,number? 1)
   (corner-radius ,number? 1)
   ;
   (color ,color? ,black)
   (font-name ,string-or-false? #f)
   (font-shape ,string? "upright")
   (font-family ,string? "roman")
   (font-series ,string? "bold")
   (font-size ,number? 0)
   (accidental-size ,number? 0)
   (raise-sharp ,number? 0.8)
   (raise-flat ,number? 0.4)
   (space-before-accidental ,number? 0.2)
   (space-before-separator ,number? 0.35)
   (key-separator ,string? ":")
   )

refKey =
#(with-property-set define-music-function (fundamental) (string?)
   `(analysis harmony ref-key)
   (let*
    ((_len (string-length fundamental))
     (accidental
      (assq-ref
       `((#\< . ,(cons (property 'raise-sharp) (markup #:sharp)))
         (#\> . ,(cons (property 'raise-flat) (markup #:flat))))
       (string-ref fundamental (- _len 1))))
     (name
      (if accidental
          (substring fundamental 0 (- _len 1))
          fundamental))
     (accidental-markup
      (if accidental
          (markup #:concat
            (#:hspace (property 'space-before-accidental)
              #:override `(font-size .
                            ,(+ (property 'accidental-size)
                               (- (property 'font-size) 3)))
              #:raise (car accidental) (cdr accidental)))
          (markup "")))
     (end (markup #:concat
            (#:hspace (property 'space-before-separator)
              (property 'key-separator))))
     )
    (define-markup-command (enclose layout props content)(markup?)
     (let*
      ((box-type (property 'box-type))
       ;; selecting "none" as box-type will silently re-apply the font-shape property
       (func-to-apply (if (string=? box-type "none") (property 'font-shape) box-type))
       (get-scheme-markup-function
        (lambda (func) (symbol-append 'make- func '-markup)))
       (box-func (get-scheme-markup-function (string->symbol func-to-apply))))
      (interpret-markup layout props
        (primitive-eval
         (list 'markup
           (list
            box-func
            `(make-stencil-markup
              ,(interpret-markup layout props content))))))))
    #{
      #(if (not (use-preset)) #{ \once \hide StanzaNumber #} #{ #})
      \set stanza =
      \markup
      \enclose
      \pad-around #(property 'box-padding)

      \override #`(font-shape . ,(string->symbol (property 'font-shape)))
      \override #`(font-series . ,(string->symbol (property 'font-series)))
      \override #`(font-family . ,(string->symbol (property 'font-family)))
      \override #`(font-size . ,(property 'font-size))
      \override #`(font-name . ,(property 'font-name))
      \with-color #(property 'color)
      \concat { #name #accidental-markup #end }
    #}))
