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

% --------------------------------------------------------------------------
%    Frames and Rectangles
% --------------------------------------------------------------------------

% Define configuration variables and set defaults

% Control on/off state
\registerOption analysis.highlighters.active ##t
% Collection of stylesheet definitions
\registerOption analysis.highlighters.stylesheets #'()
\registerOption analysis.highlighters.use-only-stylesheets #'()
\registerOption analysis.highlighters.ignore-stylesheets #'()

% Predicate for valid highlighter styles
% (list allowed names here)
#(define (highlighter-style? obj)
   (if (member
        obj
        '("ramp"
           "leftsided-stairs"
           "rightsided-stairs"
           "centered-stairs"))
       #t
       #f))

% Initialize variable to be used for command validation
#(define highlighting-style-propset
   `(strict
     (? ,symbol? stylesheet)
     ))

% Populate defaults and set up structures
#(let*
  ((defaults
    ;; define options with type and default
    `((color ,color? ,green)
      (thickness ,number? 2)
      (layer ,integer? -5)
      (X-offset ,number? 0.6)
      (X-first ,number? -1.2)
      (X-last ,number? 1.2)
      (Y-first ,number? 0)
      (Y-last ,number? 0)
      (style ,highlighter-style? "ramp"))))
  ;; define list of option names to iterate over
  (registerOption '(analysis highlighters _prop-names) (map car defaults))
  (for-each
   (lambda (default)
     ;; Create options and populate with default values
     (setChildOption '(analysis highlighters)
       (first default)
       (third default))
     ;; Create propset for the command validation
     (set! highlighting-style-propset
           (append highlighting-style-propset
             (append
              (list '?)
              default))))
   defaults))

#(define (process-properties given-props)
   "Process the highlighter's options.
    All properties are initially populated with (default) values
    of the corresponding options and may be overridden with values
    from 
    - an optional stylesheet or
    - the actual highlighter's \\with clause."
   (let*
    ((props
      ;; initialize props with defaults/current option values
      (map (lambda (prop-name)
             (cons prop-name (getChildOption '(analysis highlighters) prop-name)))
        (getOption '(analysis highlighters _prop-names))))
     ;; check if a stylesheet has been named
     (stylesheet-name (assq-ref given-props 'stylesheet))
     ;; if so override defaults with properties from the stylesheet
     (stylesheet
      (if stylesheet-name
          (getChildOptionWithFallback
           '(analysis highlighters stylesheets)
           (string->symbol stylesheet-name)
           '())
          '()))
     )
    ;; Override presets, first with stylesheet (if present),
    ;; then with given props (if present).
    (for-each
     (lambda (stylesheet-prop)
       (set! props
             (assoc-set! props (car stylesheet-prop) (cdr stylesheet-prop))))
     (append stylesheet given-props))
    props))

% Define a stylesheet to be applied later.
% Pass a \with {} block with any options to be specified
% and a name.
setHighlightingStyle =
#(with-required-options define-void-function (name)(symbol?)
   highlighting-style-propset
   (setChildOption '(analysis highlighters stylesheets) name props))

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


#(define (custom-moment->duration moment)
   ;; adapted version to convert ANY moment p/q into duration 1*p/q
   (let* ((p (ly:moment-main-numerator moment))
          (q (ly:moment-main-denominator moment))
          )
     (ly:make-duration 0 0 p q)
     ))

#(define (filtered-by-stylesheet props)
   "Test if the highlighter can be useignored due to stylesheet configuration.
    Returns ##t (highlighting filtered/suppressed) if
    - use-only-stylesheets = ##t:
      no stylesheet is applied
    - use-only-stylesheet is a non-empty list:
      stylesheet is not in the use-only-stylesheets list
      or no stylesheet is used at all
    - ignore-stylesheets is a non-empty list:
      one of the ignored stylesheets is used
    "
   (let*
    ((use-only-stylesheets (getOption '(analysis highlighters use-only-stylesheets)))
     (ignore-stylesheets (getOption '(analysis highlighters ignore-stylesheets)))
     (stylesheet (assq-ref props 'stylesheet))
     )
    (or
     (and (eq? use-only-stylesheets #t) (not stylesheet))
     (and (list? use-only-stylesheets)
          (not (null? use-only-stylesheets))
          (or
           (not stylesheet)
           (not (member stylesheet use-only-stylesheets))))
     (and (not (null? ignore-stylesheets))
          (member stylesheet ignore-stylesheets))
     )
    ))

highlight =
#(with-options define-music-function (mus) (ly:music?)
   highlighting-style-propset
   (or
    (and
     (getOption '(analysis highlighters active))
     ;; http://lilypond.1069038.n5.nabble.com/Apply-event-function-within-music-function-tp202841p202847.html
     (begin
      (set! props (process-properties props))
      (if (filtered-by-stylesheet props)
          #f
          (let*
           ((mus-elts (ly:music-property mus 'elements))
            ; last music-element:
            (lst (last mus-elts)) ; TODO test for list? and ly:music?
            ; length of entire music expression "mus":
            (len (ly:music-length mus))
            ; length of last element only:
            (last-skip (ly:music-length lst))
            ; difference = length of "mus" except the last element:
            (first-skip (ly:moment-sub len last-skip))
            (color (property 'color))
            (thickness (property 'thickness))
            (layer (property 'layer))
            (X-offset (property 'X-offset))
            (X-first (property 'X-first))
            (X-last (property 'X-last))
            (Y-first (property 'Y-first))
            (Y-last (property 'Y-last))
            (style (string->symbol (property 'style)))
            )
           (make-relative (mus) mus  ;; see http://lilypond.1069038.n5.nabble.com/Current-octave-in-relative-mode-tp232869p232870.html  (thanks, David!)
             #{
               <<
                 $mus
                 % \new Voice
                 \makeClusters {
                   \once \override ClusterSpanner.style = $style
                   \once \override ClusterSpanner.color = $color
                   \once \override ClusterSpanner.padding =
                   #(if (< thickness 0.5)
                        (begin (ly:warning "\"thickness\" parameter for \\highlight is below minimum value 0.5 - Replacing with 0.5")
                          0.25)
                        (/ thickness 2))
                   \once \override ClusterSpanner.layer = $layer
                   \once \override ClusterSpanner.X-offset = $X-offset
                   % \once \override ClusterSpannerBeacon.X-offset = $X-first
                   \once \override ClusterSpannerBeacon.Y-offset = $Y-first
                   % -----------------------------------------------------------
                   \override ClusterSpanner.after-line-breaking = 
                   #(lambda (grob)
                      (let* ((orig (ly:grob-original grob))
                             (siblings (if (ly:grob? orig)
                                           (ly:spanner-broken-into orig)
                                           '()))
                             ; (col
                             ;  (if (pair? siblings)
                             ;      (ly:grob-array-ref
                             ;       (ly:grob-object (car siblings) 'columns)
                             ;       0)
                             ;      )
                             ;  )
                             (obj (if (pair? siblings)
                                      (ly:grob-object 
                                       (car (cdr siblings))
                                       'columns)
                                      ) ; the array of ClusterSpannerBeacons
                               )
                             (col
                              (if (pair? siblings)
                                  (ly:grob-array-ref
                                   obj
                                   0)
                                  ) ; first element of array
                              )
                             
                             )
                        (if (pair? siblings)
                            (begin
                             (display "----------------------\n")
                             (display siblings)
                             (display "\n")
                             (display col)
                             (display "\n")
                             (display "----------------------\n")
                             ; (ly:grob-set-property! col 'X-offset -4)
                             (ly:grob-translate-axis! col -5 X)
                             )
                            )
                        )
                      )
                   % -----------------------------------------------------------
                   <<
                     $mus
                     {
                       % skip until last element starts:
                       #(if (not (equal? first-skip (ly:make-moment 0/1 0/1))) ; skip with zero length would cause error
                            (make-music 'SkipEvent 'duration (custom-moment->duration first-skip)))
                       \once \override ClusterSpannerBeacon.X-offset = $X-last
                       \once \override ClusterSpannerBeacon.Y-offset = $Y-last
                     }
                   >>
                 }
               >>
             #})))))
    mus
    ))
