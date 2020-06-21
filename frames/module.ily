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
% along with anaLYsis.  If not, see <http://www.gnu.org/licenses/>.          %
%                                                                             %
% anaLYsis is maintained by Urs Liska, ul@openlilylib.org                     %
% Copyright Klaus Blum & Urs Liska, 2017                                      %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------------
%    Frames and Rectangles
% --------------------------------------------------------------------------

% Define configuration variables and set defaults

\registerOption analysis.frames #'()
\registerOption analysis.frames.stylesheets #'()

% Necessary predicates
#(define (color-or-false? obj)
   (or (color? obj) (eq? obj #f)))

#(define (hide-target? obj)
   (if (member
        obj
        #'("none"
            "staff"
            "music"
            "all"))
       #t
       #f))

#(define (caption? obj)
   (or (string? obj)
       (markup? obj)
       (eq? obj #f)))

% Initialize variable to be used for command validation
#(define frame-style-propset
   `(strict
     (? ,symbol? stylesheet)
     (? ,string? default)
     ))

% Populate defaults and set up structures
#(let*
  ((defaults
    ;; define options with type and default
    `((border-width ,number? 0.25)
      (padding ,number? 0)
      (broken-bound-padding ,number? 4)
      (border-radius ,number? 0)
      (shorten-pair ,number-pair? #'(0 . 0))
      (y-lower ,number? -4)
      (y-upper ,number? 4)
      (l-zigzag-width ,number? 0)
      (r-zigzag-width ,number? 0)
      (open-on-bottom ,boolean? ,#f)
      (open-on-top ,boolean? ,#f)
      (layer ,integer? -10)
      (border-color ,color-or-false? ,(rgb-color 0.3  0.3  0.9))
      (color ,color-or-false? ,(rgb-color 0.8  0.8  1.0))
      (hide ,hide-target? "none")
      (angle ,number? 0)
      (caption ,caption? ,#f)
      (caption-padding ,number? 0.25)
      (caption-radius ,number? 0.25)
      (caption-align-bottom ,boolean? ,#f)
      (caption-halign ,number? -1)  ; from -1=left to 1=right
      (caption-color ,color-or-false? ,#f)  ; ##f will use border-color
      (caption-keep-y ,boolean? ,#f)
      (caption-translate-x ,number? 0)
      (set-top-edge ,boolean? ,#f)
      (set-bottom-edge ,boolean? ,#f)
      (set-left-edge ,boolean? ,#f)
      (set-right-edge ,boolean? ,#f)
      (set-caption-extent ,boolean? ,#f)
      )))

  ;; define list of option names to iterate over
  (registerOption '(analysis frames _prop-names) (map car defaults))
  (for-each
   (lambda (default)
     ;; Create options and populate with default values
     (setChildOption '(analysis frames)
       (first default)
       (third default))
     ;; Create propset for the command validation
     (set! frame-style-propset
           (append frame-style-propset
             (append
              (list '?)
              default))))
   defaults))

#(define (process-calculated-frame-properties props)
   "Process the frame's options.
    This function handles the properties that have to be
    processed instead of only be looked up.
"
   (let*
    ((y-lower (assq-ref props 'y-lower))
     (y-upper (assq-ref props 'y-upper))
     (processed-props
      `((broken-bound-padding .
          ,(* -1 (assq-ref props 'broken-bound-padding)))
        (shorten-pair .
          ,(let*
            ((sp
              (assq-ref props 'shorten-pair)))
            (if (pair? sp)
                sp
                (cons sp sp))))
        (y-l-lower .
          ,(if (number? y-lower) y-lower (car y-lower)))
        (y-r-lower .
          ,(if (number? y-lower) y-lower (cdr y-lower)))
        (y-l-upper .
          ,(if (number? y-upper) y-upper (car y-upper)))
        (y-r-upper .
          ,(if (number? y-upper) y-upper (cdr y-upper)))
        (border-color .
          ,(let ((col (assq 'border-color props)))
             (if col (cdr col) (getOption '(analysis frames border-color)))))
        (color .
          ,(let*
            ((prop-col (assq 'color props)))
            (if prop-col
                (cdr prop-col)
                (getOption '(analysis frames color)))))
        (hide .
          ,(let ((col (assq 'hide props)))
             (if col
                 (string->symbol (cdr col))
                 (string->symbol (getOption '(analysis frames hide)))))))))
    (for-each
     (lambda (prop)
       (set! props
             (assoc-set! props (car prop) (cdr prop))))
     processed-props)
    props))

#(define (update-alist alst props)
   "Return a copy of the association list alst,
    superseded with properties from the association list props."
   (for-each
    (lambda (prop)
      (set! alst
            (assoc-set! alst (car prop) (cdr prop))))
    props)
   alst)

#(define (process-frame-properties given-props)
   "Process the stylesheet and given options.
    All properties are initially populated with (default) values
    of the corresponding options and may be overridden with values
    from 
    - an optional stylesheet or
    - the actual highlighter's \\with clause."
   (let*
    ((props
      ;; initialize props with defaults/current option values
      (map (lambda (prop-name)
             (cons prop-name (getChildOption '(analysis frames) prop-name)))
        (getOption '(analysis frames _prop-names))))
     ;; check if a stylesheet has been named
     (stylesheet-name (assq-ref given-props 'stylesheet))
     ;; if so override defaults with properties from the stylesheet
     (stylesheet
      (if stylesheet-name
          (getChildOptionWithFallback
           '(analysis frames stylesheets)
           (string->symbol stylesheet-name)
           '())
          '()))
     ;; Override presets, first with stylesheet (if present),
     ;; then with given props (if present).
     (props (update-alist props (append stylesheet given-props)))
     )
    (process-calculated-frame-properties props))
   )

% Define a stylesheet to be applied later.
% Pass a \with {} block with any options to be specified
% and a name.
% if an option 'parent is given first all properties of the
% parent stylesheet are loaded before the newly given
% properties are applied.
defineFrameStylesheet =
#(with-required-options define-void-function (name)(symbol?)
   frame-style-propset
   (let ((parent (assq-ref props 'parent)))
     (if parent
         (set! props (update-alist props
           (getChildOptionWithFallback '(analysis frames stylesheets)
             (string->symbol parent) '()))))
     (setChildOption '(analysis frames stylesheets) name props)))


#(define-markup-command (on-box layout props radius color arg) (number? scheme? markup?)
   (let* ((stencil (interpret-markup layout props arg))
          (X-ext (ly:stencil-extent stencil X))
          (Y-ext (ly:stencil-extent stencil Y)))
     (if (color? color)
         (ly:stencil-add (ly:make-stencil
                          (list 'color color
                            (ly:stencil-expr (ly:round-filled-box X-ext Y-ext radius))
                            X-ext Y-ext)) stencil)
         stencil)
     )
   )

#(define (get-live-properties grob)
   "Return the properties that have to be retrieved from the actual grob"
   (let*
    ((frame-X-extent (ly:stencil-extent (ly:horizontal-bracket::print grob) X))
     (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
     (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT)))))
    `((frame-X-extent . ,frame-X-extent)
      (open-on-left . ,open-on-left)
      (open-on-right . ,open-on-right))))

#(define (rotate-point point-to-add rotation x-center y-center)
   "Rotate the given point (point-to-add) around (x-center, y-center) by
     the given rotation angle (in degrees)."
   (let*
    (
      (x-to-add (car point-to-add))
      (y-to-add (cdr point-to-add))
      ; convert (x-to-add | y-to-add) to polar coordinates (distance ; direction):
      (x-diff (- x-to-add x-center))
      (y-diff (- y-to-add y-center))
      (distance (sqrt (+ (expt x-diff 2) (expt y-diff 2))))
      (direction
       (if (eq? 0 x-diff)
           ;(then...)
           (if (> y-diff 0) 90 -90)
           ;(else...)
           (+ (atan (/ y-diff x-diff)) (if (< x-diff 0) 3.141592653589 0))
           )
       )
      ; apply rotation:
      (new-direction (+ direction (* rotation (/ 3.14159265 180))))
      (new-x (+ x-center (* distance (cos new-direction))))
      (new-y (+ y-center (* distance (sin new-direction))))
      )
    #!
    (display "X: ")
    (display x-to-add)
    (display " - ")
    (display x-center)
    (display " = ")
    (display x-diff)
    (display "  |  Y: ")
    (display y-to-add)
    (display " - ")
    (display y-center)
    (display " = ")
    (display y-diff)
    (display "  |  dist=")
    (display distance)
    (display "  dir=")
    (display (* direction (/ 180 3.14159265)))
    (display "\n")
    !#
    ; return rotated point as pair of coordinates:
    (cons new-x new-y)
    )
   )

#(define (expand-range range point-to-add)
   "Expand the borders of the given range until it contains the added point.
    Return the expanded range."
   (let*
    ; split pair of pairs into separate variables for better usability:
    (
      (x-lo (car (car range)))
      (x-hi (cdr (car range)))
      (y-lo (car (cdr range)))
      (y-hi (cdr (cdr range)))
      (x-to-add (car point-to-add))
      (y-to-add (cdr point-to-add))
      )
    ; initial values are #f. Replace them, if present:
    (if (eq? #f x-lo) (set! x-lo x-to-add))
    (if (eq? #f x-hi) (set! x-hi x-to-add))
    (if (eq? #f y-lo) (set! y-lo y-to-add))
    (if (eq? #f y-hi) (set! y-hi y-to-add))
    ; now expand borders:
    (if (< x-to-add x-lo) (set! x-lo x-to-add))
    (if (> x-to-add x-hi) (set! x-hi x-to-add))
    (if (< y-to-add y-lo) (set! y-lo y-to-add))
    (if (> y-to-add y-hi) (set! y-hi y-to-add))
    ; return expanded range as pair of pairs:
    (cons (cons x-lo x-hi) (cons y-lo y-hi))
    )
   )

#(define (make-frame-stencil grob props)
   "Create the actual frame stencil using both live and configuration props."
   (let*
    ;; make properties available
    ((live-props (get-live-properties grob))
     (frame-angle (assq-ref props 'angle))
     (border-width (assq-ref props 'border-width))
     (border-radius (assq-ref props 'border-radius))
     (y-l-lower (assq-ref props 'y-l-lower))
     (y-l-upper (assq-ref props 'y-l-upper))
     (y-r-lower (assq-ref props 'y-r-lower))
     (y-r-upper (assq-ref props 'y-r-upper))
     (layer (assq-ref props 'layer))
     (border-color (assq-ref props 'border-color))
     (color (assq-ref props 'color))
     (l-zigzag-width (assq-ref props 'l-zigzag-width))
     (r-zigzag-width (assq-ref props 'r-zigzag-width))
     (open-on-bottom (assq-ref props 'open-on-bottom))
     (open-on-top (assq-ref props 'open-on-top))
     ;; (border-width (assq-ref props 'border-width))    ;; already done above...
     (padding (assq-ref props 'padding))
     (bb-pad (assq-ref props 'broken-bound-padding))
     (frame-X-extent (assq-ref live-props 'frame-X-extent))
     (open-on-left (assq-ref live-props 'open-on-left))
     (open-on-right (assq-ref live-props 'open-on-right))
     (caption (assq-ref props 'caption))
     (caption-padding (assq-ref props 'caption-padding))
     (caption-radius (assq-ref props 'caption-radius))
     (caption-align-bottom (assq-ref props 'caption-align-bottom))
     (caption-halign (assq-ref props 'caption-halign))
     (caption-color (assq-ref props 'caption-color))
     (caption-keep-y (assq-ref props 'caption-keep-y))
     (caption-translate-x (assq-ref props 'caption-translate-x))
     (set-top-edge (assq-ref props 'set-top-edge))
     (set-bottom-edge (assq-ref props 'set-bottom-edge))
     (set-left-edge (assq-ref props 'set-left-edge))
     (set-right-edge (assq-ref props 'set-right-edge))
     (set-caption-extent (assq-ref props 'set-caption-extent))

     (layout (ly:grob-layout grob))
     (caption-props (ly:grob-alist-chain grob (ly:output-def-lookup layout 'text-font-defaults)))
     (caption-stencil empty-stencil)
     (caption-markup empty-markup)
     (caption-x 0)
     (caption-y 0)
     (caption-width 0)
     (caption-height 0)
     (y-with-descender 0)
     (y-without-descender 0)
     (descender-height 0)
     (temp-value 0)
     (caption-left-edge 0)
     (caption-right-edge 0)
     (caption-lower-edge 0)
     (caption-upper-edge 0)
     (caption-mid-x 0)
     (caption-angle 0)
     (caption-angle-rad 0)


     ;; store polygon points.
     ;; retrieve list of all inner or outer points
     ;; pass either one out of the four point lists or the result of invoking all-points
     (inner-points
      (lambda (side)
        (if (null? side) '()
            (map car side))))
     (outer-points
      (lambda (side)
        (if (null? side) '()
            (map cdr side))))
     ;; add a pair of inner/outer points to the pts list
     (add-points (lambda (side pts) (set! side (append side (list pts)))))
     (add-corner (lambda (p side h-dir v-dir diag)
                   (let*
                    ((x-fact (if diag (* border-width (sqrt 2)) border-width))
                     (outer-point
                      (cons
                       (+ (car p) (* x-fact h-dir))
                       (+ (cdr p) v-dir))))
                    (add-points side (cons p outer-point)))))

     ;; each entry is a pair of two pairs with coordinates of inner and outer point
     ;; (left-points '())
     ;; (top-points '())
     ;; (right-points '())
     ;; (bottom-points '())
     ;; (all-points (lambda ()
     ;;              (append left-points top-points right-points bottom-points)))
     ;; start calculations
     (h-border-width (* border-width (sqrt 2)))  ; X-distance between left and right edges of inner and outer polygon. Must be "border-width" * sqrt 2  (Pythagoras)
     (l-width (* l-zigzag-width  0.5))   ; X-distance of zigzag corners
     (r-width (* r-zigzag-width 0.5))
     (Y-ext (cons 0 0))  ; dummy, needed for ly:stencil-expr  (is there a way without it?)
     (stencil-ext (cons (cons #f #f) (cons #f #f)))  ; will be used to set the stencil's dimensions
     ;                     ( x-lo x-hi ) ( y-lo y-hi )
     (X-ext (cons
             (if (> l-zigzag-width 0)    ; left edge has zigzag shape
                 (- (+ (car frame-X-extent) (/ l-width 2)) h-border-width)  ; Half of the zigzag space will be taken from inside, other half from the outside. Frame space taken from outside.
                 (if open-on-left  (- (car frame-X-extent) h-border-width) (- (car frame-X-extent) border-width))
                 )
             (if (> r-zigzag-width 0)   ; right edge has zigzag shape
                 (+ (- (cdr frame-X-extent) (/ r-width 2)) h-border-width)
                 (if open-on-right (+ (cdr frame-X-extent) h-border-width) (+ (cdr frame-X-extent) border-width))
                 )))
     (X-ext (cons
             (if open-on-left  (- (+ (car X-ext) bb-pad) (/ l-width 2)) (car X-ext))     ; shorten/lengthen by broken-bound-bb-padding if spanner is broken
             (if open-on-right (+ (- (cdr X-ext) bb-pad) (/ r-width 2)) (cdr X-ext))))
     ; Now X-ext represents the overall X-extent WITHOUT the zigzag attachments
     (frame-X-extent (cons
                      (- (- (car X-ext) (/ border-radius 2)) l-width)
                      (+ (+ (cdr X-ext) (/ border-radius 2)) r-width)
                      ))
     ; Now frame-X-extent represents the overall X-extent including everything...
     (points-up (list))    ; will contain coordinates for upper edge polygon
     (points-lo (list))    ; will contain coordinates for lower edge polygon
     (points-l (list))     ; will contain coordinates for left  edge polygon
     (points-r (list))     ; will contain coordinates for right edge polygon
     (points-i (list))     ; will contain coordinates for inner polygon
     (slope-upper (/ (- y-r-upper y-l-upper) (- (cdr X-ext) (car X-ext))))  ; slope of the polygon's upper edge

     (slope-lower (/ (- y-r-lower y-l-lower) (- (cdr X-ext) (car X-ext))))  ; slope of the polygon's lower edge
     (d-upper (if open-on-top    0  (* border-width (sqrt (+ (expt slope-upper 2) 1)))))  ; (Pythagoras)
     ; Y-distance between upper edges of inner and outer polygon. Equal to "border-width" if upper edge is horizontal.
     ; Increases as the upper edge's slope increases.
     (d-lower (if open-on-bottom 0  (* border-width (sqrt (+ (expt slope-lower 2) 1)))))  ; same for lower edge
     ; Where to find the center points for rotation:
     (rotation-center-x (/ (- (cdr X-ext) (car X-ext)) 2))
     (rotation-center-y (/ (+ y-l-upper y-r-upper y-l-lower y-r-lower) 4))
     (caption-left (car X-ext))
     (caption-right (cdr X-ext))
     (caption-space-factor 1)
     (caption-x-deficit 0)

     ; stuff for later calculations:
     (xtemp 0)
     (yLowerLimit 0)
     (yUpperLimit 0)
     (xp 0)
     (yp 0)
     (jumps 0)
     (need-upper-polygon (and (and (> border-width 0) (not open-on-top))    (color? border-color)))
     (need-lower-polygon (and (and (> border-width 0) (not open-on-bottom)) (color? border-color)))
     (need-left-polygon  (and (and (> border-width 0) (not open-on-left))   (color? border-color)))
     (need-right-polygon (and (and (> border-width 0) (not open-on-right))  (color? border-color)))
     (need-inner-polygon (color? color))
     (need-caption (markup? caption))

     ;; stencils to be placed on the topmost/leftmost/... border (ugly hack to set the actual X-extent):
     (top-edge-stencil empty-stencil)
     (bottom-edge-stencil empty-stencil)
     (left-edge-stencil empty-stencil)
     (right-edge-stencil empty-stencil)
     )

    ;; set grob properties that can be set from within the stencil callback
    (ly:grob-set-property! grob 'layer layer)
    (ly:grob-set-property! grob 'Y-offset 0)

    ;; (add-corner (cons 0 0) left-points -1 -1 #f)

    ; (calculate outer polygon's borders:)

    ; start calculating left edge borders:
    ; lower-left corner:
    (if need-left-polygon
        (begin
         (set! points-l (list (cons (car X-ext) y-l-lower)))

         ; calculate coordinates for left (outer) zigzag border:
         (if (and (> l-zigzag-width 0) (not open-on-left))
             (let loop ((cnt y-l-lower))
               (if (< cnt y-l-upper)
                   (begin
                    (if (and (< cnt y-l-upper) (> cnt y-l-lower))  ; only add to list if point is inside the given Y-range
                        (set! points-l (cons (cons    (car X-ext)             cnt                 ) points-l)))
                    (if (and (< (+ cnt (/ l-zigzag-width 2)) y-l-upper) (> (+ cnt (/ l-zigzag-width 2)) y-l-lower))
                        (set! points-l (cons (cons (- (car X-ext) l-width) (+ cnt (/ l-zigzag-width 2)) ) points-l)))
                    (loop (+ cnt l-zigzag-width))))))

         ; upper-left corner:
         (set! points-l (cons
                         (cons (car X-ext) y-l-upper)
                         points-l ))
         ))
    ; start calculating right edge borders:
    ; upper-right corner:
    (if need-right-polygon
        (begin
         (set! points-r (cons
                         (cons (cdr X-ext) y-r-upper)
                         points-r ))
         ; right outer zigzag border:
         (if (and (> r-zigzag-width 0) (not open-on-right))
             (let loop ((cnt y-r-upper))
               (if (> cnt y-r-lower)
                   (begin
                    (if (and (< cnt y-r-upper) (> cnt y-r-lower))
                        (set! points-r (cons (cons    (cdr X-ext)             cnt                  ) points-r)))
                    (if (and (< (- cnt (/ r-zigzag-width 2)) y-r-upper) (> (- cnt (/ r-zigzag-width 2)) y-r-lower))
                        (set! points-r (cons (cons (+ (cdr X-ext) r-width) (- cnt (/ r-zigzag-width 2)) ) points-r)))
                    (loop (- cnt r-zigzag-width))))))

         ; lower-right corner:
         (set! points-r (cons
                         (cons (cdr X-ext) y-r-lower)
                         points-r ))
         ))

    ; calculate lower edge borders:

    (if need-lower-polygon
        (begin
         ; lower-left corner:
         (set! points-lo (list (cons (car X-ext) y-l-lower)))
         ; upper-left corner:
         (set! points-lo (cons (cons (car X-ext) (+ y-l-lower border-width)) points-lo))
         ; upper-right corner:
         (set! points-lo (cons (cons (cdr X-ext) (+ y-r-lower border-width)) points-lo))
         ; lower-right corner:
         (set! points-lo (cons (cons (cdr X-ext) y-r-lower) points-lo))
         ))


    ; calculate upper edge borders:

    (if need-upper-polygon
        (begin
         ; lower-left corner:
         (set! points-up (list (cons (car X-ext) (- y-l-upper border-width) )))
         ; upper-left corner:
         (set! points-up (cons (cons (car X-ext) y-l-upper) points-up))
         ; upper-right corner:
         (set! points-up (cons (cons (cdr X-ext) y-r-upper) points-up))
         ; lower-right corner:
         (set! points-up (cons (cons (cdr X-ext) (- y-r-upper border-width) ) points-up))
         ))

    ; shrink X-ext for use with inner stuff:
    (if (not open-on-left)
        (if (> l-zigzag-width 0)
            (set! X-ext (cons (+ (car X-ext) h-border-width) (cdr X-ext)))
            (set! X-ext (cons (+ (car X-ext)   border-width) (cdr X-ext)))
            )
        )
    (if (not open-on-right)
        (if (> r-zigzag-width 0)
            (set! X-ext (cons (car X-ext) (- (cdr X-ext) h-border-width)))
            (set! X-ext (cons (car X-ext) (- (cdr X-ext)   border-width)))
            )
        )
    ; Now X-ext represents INNER polygon's width WITHOUT the zigzag corners.

    ; Now, finish left-edge and right-edge polygons.
    ; Use the same points to build the inner polygon.
    ; xp and yp will be the coordinates of the corner currently being calculated

    ; continue calculating left edge coordinates:

    (set! yLowerLimit y-l-lower)
    (set! yUpperLimit y-l-upper)

    ; calculate upper-left corner:
    ; (LEFT border of inner polygon = RIGHT border of left-edge polygon)
    (if open-on-left
        (begin
         (set! xp (car X-ext))
         (set! yp (- y-l-upper d-upper))
         )
        (if (> l-zigzag-width 0)
            (if (not (eq? slope-upper 1))
                (begin
                 (set! jumps 0)
                 (while (<
                         (+ (- (* slope-upper h-border-width) d-upper) (* jumps l-zigzag-width))
                         (- l-zigzag-width))
                   (set! jumps (+ jumps 1)))
                 (set! xtemp (/ (- d-upper (+ h-border-width (* jumps l-zigzag-width))) (- slope-upper 1)))
                 (if (< xtemp (- h-border-width (/ l-zigzag-width 2)))
                     (if (= -1 slope-upper)
                         (set! xtemp h-border-width)
                         (set! xtemp
                               (/ (- (- (* l-zigzag-width (+ 1 jumps)) d-upper) h-border-width) (- (- 1) slope-upper)))
                         )
                     )
                 (set! xp (+ (- (car X-ext) h-border-width) xtemp))
                 (set! yp (- (+ y-l-upper (* slope-upper xtemp)) d-upper))
                 )
                )
            (begin
             (set! xp (car X-ext))
             (set! yp (- (+ y-l-upper (* border-width slope-upper)) d-upper))
             )
            )
        )

    ; insert upper-left corner's coordinates into list:
    (if (not
         (and (and (not open-on-left) (> l-zigzag-width 0)) (eq? slope-upper 1))
         )
        (begin
         (set! points-l (cons (cons xp yp) points-l))
         (set! points-i (cons (cons xp yp) points-i))
         (set! yUpperLimit yp))
        )

    ; calculate lower-left corner:
    (if open-on-left
        (begin
         (set! xp (car X-ext))
         (set! yp (+ y-l-lower d-lower))
         )
        (if (> l-zigzag-width 0)
            (if (not (eq? slope-lower -1))
                (begin
                 (set! jumps 0)
                 (while (> (- (+ (* slope-lower h-border-width) d-lower) (* jumps l-zigzag-width)) l-zigzag-width)
                   (set! jumps (+ 1 jumps)))
                 (set! xtemp (/ (- (+ h-border-width (* jumps l-zigzag-width)) d-lower) (+ slope-lower 1)))
                 ; results from the solution for a system of two equations. Forgive me, I'm a maths teacher :-)
                 (if (< xtemp (- h-border-width (/ l-zigzag-width 2)))
                     (if (= 1 slope-lower)
                         (set! xtemp h-border-width)
                         (set! xtemp
                               (/ (+ (- d-lower (* l-zigzag-width (+ 1 jumps))) h-border-width) (- 1 slope-lower)))))  ; another system of 2 equations...
                 (set! xp (+ (- (car X-ext) h-border-width) xtemp))
                 (set! yp (+ (+ y-l-lower (* slope-lower xtemp)) d-lower))
                 )
                )
            (begin
             (set! xp (car X-ext))
             (set! yp (+ (+ y-l-lower (* border-width slope-lower)) d-lower))
             )
            )
        )

    (if (not (and (and (not open-on-left) (> l-zigzag-width 0)) (eq? slope-lower -1)))
        (set! yLowerLimit yp)
        )

    ; left (inner) zigzag:
    (if (and (> l-zigzag-width 0) (not open-on-left))
        (begin
         (let loop ((cnt y-l-upper))
           (if (> cnt y-l-lower)
               (begin
                (if (and (> cnt yLowerLimit) (< cnt yUpperLimit))
                    (begin
                     (set! points-l (cons (cons    (car X-ext)             cnt                 ) points-l))
                     (set! points-i (cons (cons    (car X-ext)             cnt                 ) points-i))
                     ))
                (if (and (> (- cnt (/ l-zigzag-width 2)) yLowerLimit) (< (- cnt (/ l-zigzag-width 2)) yUpperLimit))
                    (begin
                     (set! points-l (cons (cons (- (car X-ext) l-width) (- cnt (/ l-zigzag-width 2)) ) points-l))
                     (set! points-i (cons (cons (- (car X-ext) l-width) (- cnt (/ l-zigzag-width 2)) ) points-i))
                     ))
                (loop (- cnt l-zigzag-width))
                )
               )
           )
         )
        )

    ; insert lower-left corner (yes, AFTER the zigzag points, so all the points will be given in clockwise order):
    (if (not (and (and (not open-on-left) (> l-zigzag-width 0)) (eq? slope-lower -1)))
        (begin
         (set! points-l (cons (cons xp yp) points-l))
         (set! points-i (cons (cons xp yp) points-i))
         ))

    ; continue calculating right edge borders:

    (set! yLowerLimit y-r-lower)
    (set! yUpperLimit y-r-upper)

    ; calculate lower-right corner:
    ; (RIGHT border of inner polygon = LEFT border of right-edge polygon)
    (if open-on-right
        (begin
         (set! xp (cdr X-ext))
         (set! yp (+ y-r-lower d-lower))
         )
        (if (> r-zigzag-width 0)
            (if (not (eq? slope-lower 1))
                (begin
                 (set! jumps 0)
                 (while (> (- (- d-lower (* slope-lower h-border-width)) (* jumps r-zigzag-width)) r-zigzag-width)
                   (set! jumps (+ 1 jumps)))
                 (set! xtemp (/ (- (+ h-border-width (* jumps r-zigzag-width)) d-lower) (- slope-lower 1)))
                 (if (> xtemp (- (/ r-zigzag-width 2) h-border-width)   )
                     (if (= -1 slope-lower)
                         (set! xtemp (- h-border-width))
                         (set! xtemp
                               (/ (+ (- d-lower (* r-zigzag-width (+ 1 jumps))) h-border-width) (- -1 slope-lower)))))
                 (set! xp (+ (+ (cdr X-ext) h-border-width) xtemp))
                 (set! yp (+ (+ y-r-lower (* slope-lower xtemp)) d-lower))
                 )
                )
            (begin
             (set! xp (cdr X-ext))
             (set! yp (+ (- y-r-lower (* border-width slope-lower)) d-lower))
             )
            )
        )

    ; insert lower-right corner:
    (if (not (and (and (not open-on-right) (> r-zigzag-width 0)) (eq? slope-lower 1)))
        (begin
         (set! yLowerLimit yp)
         (set! points-r (cons (cons xp yp) points-r))
         (set! points-i (cons (cons xp yp) points-i))
         ))


    ; calculate upper-right corner:
    (if open-on-right
        (begin
         (set! xp (cdr X-ext))
         (set! yp (- y-r-upper d-upper))
         )
        (if (> r-zigzag-width 0)
            (if (not (eq? slope-upper -1))
                (begin
                 (set! jumps 0)
                 (while (<
                         (+ (- (* slope-upper (- h-border-width)) d-upper) (* jumps r-zigzag-width))
                         (- r-zigzag-width))
                   (set! jumps (+ jumps 1)))
                 (set! xtemp (/ (- d-upper (+ h-border-width (* jumps r-zigzag-width))) (+ slope-upper 1)))
                 (if (> xtemp (- (/ r-zigzag-width 2) h-border-width  ))
                     (if (= 1 slope-upper)
                         (set! xtemp (- h-border-width))
                         (set! xtemp
                               (/ (- (- (* r-zigzag-width (+ 1 jumps)) d-upper) h-border-width) (- 1 slope-upper)))
                         )
                     )
                 (set! xp (+ (+ (cdr X-ext) h-border-width) xtemp))
                 (set! yp (- (+ y-r-upper (* slope-upper xtemp)) d-upper))
                 )
                )
            (begin
             (set! xp (cdr X-ext))
             (set! yp (- (- y-r-upper (* border-width slope-upper)) d-upper))
             )
            )
        )

    (if (not
         (and (and (not open-on-right) (> r-zigzag-width 0)) (eq? slope-upper -1)))
        (set! yUpperLimit yp))

    ; right zigzag:
    (if (and (> r-zigzag-width 0) (not open-on-right))
        (begin
         (let loop ((cnt y-r-lower))
           (if (< cnt y-r-upper)
               (begin
                (if (and (> cnt yLowerLimit) (< cnt yUpperLimit))
                    (begin
                     (set! points-r (cons (cons    (cdr X-ext)             cnt                  ) points-r))
                     (set! points-i (cons (cons    (cdr X-ext)             cnt                  ) points-i))
                     ))
                (if (and (> (+ cnt (/ r-zigzag-width 2)) yLowerLimit) (< (+ cnt (/ r-zigzag-width 2)) yUpperLimit))
                    (begin
                     (set! points-r (cons (cons (+ (cdr X-ext) r-width) (+ cnt (/ r-zigzag-width 2)) ) points-r))
                     (set! points-i (cons (cons (+ (cdr X-ext) r-width) (+ cnt (/ r-zigzag-width 2)) ) points-i))
                     ))
                (loop (+ cnt r-zigzag-width))
                )
               )
           )
         )
        )

    ; insert upper-right corner:
    (if (not
         (and (and (not open-on-right) (> r-zigzag-width 0)) (eq? slope-upper -1)))
        (begin
         (set! points-r (cons (cons xp yp) points-r))
         (set! points-i (cons (cons xp yp) points-i))
         ))

    ; Edge polygons are finished now.

    (if need-caption
        (begin
         (set! caption-stencil (interpret-markup layout caption-props (markup "j")))
         (set! y-with-descender    (car (ly:stencil-extent caption-stencil Y)) )
         (set! caption-stencil (interpret-markup layout caption-props (markup "i")))
         (set! y-without-descender (car (ly:stencil-extent caption-stencil Y)) )
         (set! descender-height (- y-without-descender y-with-descender))

         (set! caption-markup
               (markup #:on-box caption-radius (if (color? caption-color) caption-color border-color)
                 #:pad-markup caption-padding
                 (if caption-keep-y
                     caption
                     (markup
                      #:combine caption
                      #:transparent
                      #:scale (cons 0.1 1)
                      #:combine "É" "j"
                      )
                     )
                 ))
         (set! caption-stencil (interpret-markup layout caption-props caption-markup))
         (set! caption-width  (- (cdr (ly:stencil-extent caption-stencil X)) (car (ly:stencil-extent caption-stencil X)) ))
         (set! caption-height (- (cdr (ly:stencil-extent caption-stencil Y)) (car (ly:stencil-extent caption-stencil Y)) ))
         (set! caption-space-factor
               (/
                (+
                 caption-right
                 (- caption-left)
                 (- (* caption-width (cos (atan (if caption-align-bottom slope-lower slope-upper))))))
                (- caption-right caption-left)
                )
               )
         (set! caption-x-deficit (* 0.5 caption-width (- 1 (cos (atan (if caption-align-bottom slope-lower slope-upper))))))
         (set! caption-x    ; cross-fade between left and right position:
               (+
                (* (/ (- 1 caption-halign) 2)   ; factor between 1 and 0  (caption-halign is between -1=left and 1=right)
                  (+ caption-left caption-padding (- (/ border-radius 2)) (- caption-x-deficit))  ; left-edge position
                  )
                (* (/ (+ 1 caption-halign) 2)   ; factor between 0 and 1
                  (+ caption-right caption-padding (/ border-radius 2) (- caption-width) caption-x-deficit)  ; right-edge position
                  )
                caption-translate-x
                )
               )
         (set! caption-y
               (+
                (* (+
                    (/ (- 1 (* caption-halign caption-space-factor)) 2)   ; factor between 1 and 0  (caption-halign is between -1=left and 1=right)
                    (/ caption-translate-x (- caption-left caption-right))
                    )
                  (if caption-align-bottom y-l-lower y-l-upper)  ; left-edge position
                  )
                (* (+
                    (/ (+ 1 (* caption-halign caption-space-factor)) 2)   ; factor between 0 and 1
                    (/ caption-translate-x (- caption-right caption-left))
                    )
                  (if caption-align-bottom y-r-lower y-r-upper)  ; right-edge position
                  )
                )
               )
         (if caption-align-bottom
             (set! caption-y (+ (- 0.04) caption-y caption-padding border-width (- (/ border-radius 2)) (- caption-height) descender-height))
             (set! caption-y (+ 0.04 caption-y caption-padding (- border-width) (/ border-radius 2) descender-height))
             )
         ; (set! caption-stencil (ly:stencil-translate caption-stencil (cons caption-x caption-y)))
         (set! caption-markup (markup #:translate (cons caption-x caption-y) caption-markup))
         (set! caption-stencil (interpret-markup layout caption-props caption-markup))

         (set! caption-left-edge  (car (ly:stencil-extent caption-stencil X)))
         (set! caption-right-edge (cdr (ly:stencil-extent caption-stencil X)))
         (set! caption-lower-edge (car (ly:stencil-extent caption-stencil Y)))
         (set! caption-upper-edge (cdr (ly:stencil-extent caption-stencil Y)))
         (set! caption-mid-x (/ (+ caption-left-edge caption-right-edge) 2))
         (set! caption-angle-rad (atan (if caption-align-bottom slope-lower slope-upper)))
         (set! caption-angle (* caption-angle-rad (/ 180 3.141592653589)))

         #!
         (set! caption-stencil (ly:stencil-rotate
                                caption-stencil
                                caption-angle
                                0
                                (if caption-align-bottom 1 -1)
                                ))
         !#
         ; ----- replaced by:
         (set! caption-markup
               (markup #:translate
                 (if caption-align-bottom
                     (cons
                      (* (sin caption-angle-rad) (/ caption-height 2))
                      (* (- 1 (cos caption-angle-rad)) (/ caption-height 2))
                      )
                     (cons
                      (- 0 (* (sin caption-angle-rad) (/ caption-height 2)))
                      (- 0 (* (- 1 (cos caption-angle-rad)) (/ caption-height 2)))
                      )
                     )
                 (markup #:rotate caption-angle caption-markup)))
         (set! caption-stencil (interpret-markup layout caption-props caption-markup))
         ; -----

         ; determine overall stencil-extent
         ; test caption corners: (top-left)
         (set! stencil-ext
               (expand-range stencil-ext
                 (rotate-point
                  (rotate-point
                   (cons caption-left-edge caption-upper-edge)
                   caption-angle caption-mid-x (if caption-align-bottom caption-upper-edge caption-lower-edge))
                  frame-angle rotation-center-x rotation-center-y)))
         ; bottom-left corner:
         (set! stencil-ext
               (expand-range stencil-ext
                 (rotate-point
                  (rotate-point
                   (cons caption-left-edge caption-lower-edge)
                   caption-angle caption-mid-x (if caption-align-bottom caption-upper-edge caption-lower-edge))
                  frame-angle rotation-center-x rotation-center-y)))
         ; top-right corner:
         (set! stencil-ext
               (expand-range stencil-ext
                 (rotate-point
                  (rotate-point
                   (cons caption-right-edge caption-upper-edge)
                   caption-angle caption-mid-x (if caption-align-bottom caption-upper-edge caption-lower-edge))
                  frame-angle rotation-center-x rotation-center-y)))
         ; bottom-right corner:
         (set! stencil-ext
               (expand-range stencil-ext
                 (rotate-point
                  (rotate-point
                   (cons caption-right-edge caption-lower-edge)
                   caption-angle caption-mid-x (if caption-align-bottom caption-upper-edge caption-lower-edge))
                  frame-angle rotation-center-x rotation-center-y)))

         #!
    (set! caption-stencil
          (ly:stencil-rotate-absolute
           caption-stencil
           frame-angle rotation-center-x rotation-center-y))
         !#
         ; ----- replaced by:
         ;   re-use caption-angle-rad:
         (set! caption-angle-rad (* frame-angle (/ 3.141592653589 180)))
         ;   re-use caption-x and caption-y as current caption center:
         (set! caption-x (/ (+ (car (ly:stencil-extent caption-stencil X)) (cdr (ly:stencil-extent caption-stencil X))) 2))
         (set! caption-y (/ (+ (car (ly:stencil-extent caption-stencil Y)) (cdr (ly:stencil-extent caption-stencil Y))) 2))

         (set! caption-markup
               (markup
                #:translate
                (cons
                 (+
                  (* (- rotation-center-x caption-x) (- 1 (cos caption-angle-rad)))
                  (* (- rotation-center-y caption-y) (sin caption-angle-rad))
                  )
                 (+
                  (* (- caption-x rotation-center-x) (sin caption-angle-rad))
                  (* (- rotation-center-y caption-y) (- 1 (cos caption-angle-rad)))
                  )
                 )
                #:rotate frame-angle caption-markup))

         (if (not set-caption-extent)
             (set! caption-markup (markup #:with-dimensions (cons 0 0) (cons 0 0) caption-markup)))

         (set! caption-stencil (interpret-markup layout caption-props caption-markup))
         ))
    ; -----

    ; determine overall stencil-extent
    ; start with frame's top-left corner:
    (set! stencil-ext
          (expand-range stencil-ext
            (rotate-point
             (cons (car frame-X-extent) (+ y-l-upper (/ border-radius 2)))
             frame-angle rotation-center-x rotation-center-y)))
    ; bottom-left corner:
    (set! stencil-ext
          (expand-range stencil-ext
            (rotate-point
             (cons (car frame-X-extent) (- y-l-lower (/ border-radius 2)))
             frame-angle rotation-center-x rotation-center-y)))
    ; top-right corner:
    (set! stencil-ext
          (expand-range stencil-ext
            (rotate-point
             (cons (cdr frame-X-extent) (+ y-r-upper (/ border-radius 2)))
             frame-angle rotation-center-x rotation-center-y)))
    ; bottom-right corner:
    (set! stencil-ext
          (expand-range stencil-ext
            (rotate-point
             (cons (cdr frame-X-extent) (- y-r-lower (/ border-radius 2)))
             frame-angle rotation-center-x rotation-center-y)))

    ; (display stencil-ext)
    ; (display "\n")

    ;; (ly:grob-set-property! grob 'X-extent (car stencil-ext))
    ;; (ly:grob-set-property! grob 'Y-extent (cdr stencil-ext))

    (set! top-edge-stencil
          (ly:stencil-translate
           (interpret-markup layout caption-props (markup #:with-dimensions (cons 0 0) (cons 0 0) " "))
           (cons 0 (cdr (cdr stencil-ext)))
           )
          )
    (set! bottom-edge-stencil
          (ly:stencil-translate
           (interpret-markup layout caption-props (markup #:with-dimensions (cons 0 0) (cons 0 0) " "))
           (cons 0 (car (cdr stencil-ext)))
           )
          )
    (set! left-edge-stencil
          (ly:stencil-translate
           (interpret-markup layout caption-props (markup #:with-dimensions (cons 0 0) (cons 0 0) " "))
           (cons (car (car stencil-ext)) 0)
           )
          )
    (set! right-edge-stencil
          (ly:stencil-translate
           (interpret-markup layout caption-props (markup #:with-dimensions (cons 0 0) (cons 0 0) " "))
           (cons (cdr (car stencil-ext)) 0)
           )
          )


    (ly:stencil-add
     ; draw upper edge:
     (if need-upper-polygon
         (ly:make-stencil (list 'color border-color
                            (ly:stencil-expr (ly:stencil-rotate-absolute
                                              (ly:round-filled-polygon points-up border-radius 0)
                                              frame-angle rotation-center-x rotation-center-y))
                            X-ext Y-ext))
         empty-stencil)
     ; draw lower edge:
     (if need-lower-polygon
         (ly:make-stencil (list 'color border-color
                            (ly:stencil-expr (ly:stencil-rotate-absolute
                                              (ly:round-filled-polygon points-lo border-radius 0)
                                              frame-angle rotation-center-x rotation-center-y))
                            X-ext Y-ext))
         empty-stencil)
     ; draw left edge:
     (if need-left-polygon
         (ly:make-stencil (list 'color border-color
                            (ly:stencil-expr (ly:stencil-rotate-absolute
                                              (ly:round-filled-polygon points-l  border-radius 0)
                                              frame-angle rotation-center-x rotation-center-y))
                            X-ext Y-ext))
         empty-stencil)
     ; draw right edge:
     (if need-right-polygon
         (ly:make-stencil (list 'color border-color
                            (ly:stencil-expr (ly:stencil-rotate-absolute
                                              (ly:round-filled-polygon points-r  border-radius 0)
                                              frame-angle rotation-center-x rotation-center-y))
                            X-ext Y-ext))
         empty-stencil)
     ; draw inner polygon:
     (if need-inner-polygon
         (ly:make-stencil (list 'color color
                            (ly:stencil-expr (ly:stencil-rotate-absolute
                                              (ly:round-filled-polygon points-i  border-radius 0)
                                              frame-angle rotation-center-x rotation-center-y))
                            X-ext Y-ext))
         empty-stencil)
     ; draw caption:
     (if need-caption caption-stencil empty-stencil)
     ; invisible null-dimension markups to set stencil extent:
     (if set-top-edge top-edge-stencil empty-stencil)
     (if set-bottom-edge bottom-edge-stencil empty-stencil)
     (if set-left-edge left-edge-stencil empty-stencil)
     (if set-right-edge right-edge-stencil empty-stencil)

     )
    )
   )







#(define (offset-shorten-pair props)
   "Offset the shorten-pair property by -0.3 on both sides,
    which is our default 'origin'."
   (let ((shorten-pair (assq-ref props 'shorten-pair)))
     (cons
      (- (car shorten-pair) 0.3)
      (- (cdr shorten-pair) 0.3))))

% This is the generic music function to create a frame.
% It takes an optional \with {} block for configuration
% and a music expression which will be enclosed by the frame.
genericFrame =
#(with-options define-music-function (mus)
   (ly:music?)
   frame-style-propset
   (let*
    ((props (process-frame-properties props))
     (mus-elts (ly:music-property mus 'elements))
     (frst (first mus-elts)) ; TODO test for list? and ly:music?
     (lst (last mus-elts)) ; TODO test for list? and ly:music?
     (frst-artic (ly:music-property frst 'articulations '())) ; look for eventchords ...
     (lst-artic (ly:music-property lst 'articulations '()))
     )
    ;; apply the bracket to the first and last element of the music
    (ly:music-set-property! frst 'articulations
      `(,@frst-artic ,(make-music 'NoteGroupingEvent 'span-direction -1)))
    (ly:music-set-property! lst 'articulations
      `(,@lst-artic ,(make-music 'NoteGroupingEvent 'span-direction 1)))
    #{
      \once \override HorizontalBracket.shorten-pair = #(offset-shorten-pair props)
      #(case (assq-ref props 'hide)
         ((staff)
          #{
            #(set! props (assq-set! props 'layer 1))
            \temporary \override NoteHead.layer = 2
            \temporary \override Staff.LedgerLineSpanner.layer = 2
            \temporary \override Stem.layer = 2
            \temporary \override Beam.layer = 2
            \temporary \override Flag.layer = 2
            \temporary \override Rest.layer = 2
            \temporary \override Accidental.layer = 2
          #})
         ((music)
          #{
            #(set! props (assq-set! props 'layer -1))
            \temporary \override NoteHead.layer = -2
            \temporary \override Staff.LedgerLineSpanner.layer = -2
            \temporary \override Stem.layer = -2
            \temporary \override Beam.layer = -2
            \temporary \override Flag.layer = -2
            \temporary \override Rest.layer = -2
            \temporary \override Accidental.layer = -2
          #})
         ((all)
          (set! props (assq-set! props 'layer 5))))
      %      \once \override HorizontalBracket.rotation = #'(45 0 0)
      \once\override HorizontalBracket.stencil =
      $(lambda (grob) (make-frame-stencil grob props))
      % Return the processed music expression
      #mus
      #(if (eq? (assq-ref props 'hide) 'staff)
           #{
             \revert NoteHead.layer
             \revert Stem.layer
             \revert Beam.layer
             \revert Flag.layer
             \revert Rest.layer
             \revert Accidental.layer
           #})
    #}))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Original implementation and original "client" functions

% The "central" drawing procedure:

#(define (makeDeltaSpan
          y-l-lower y-l-upper         ; number: Y-dimensions (left edge)
          y-r-lower y-r-upper         ; number: Y-dimensions (right edge)
          border-color color      ; (color or ##f): colors for outer and inner polygon (won't be drawn if set to ##f)
          l-zigzag-width r-zigzag-width          ; number: size of zigzag elements for left and right edge (vertical edge / no zigzag if set to zero)
          open-on-bottom open-on-top  ; boolean: no visible frame on bottom/top edge (no distance between inner and outer polygon's edges)
          thick                       ; number: frame thickness - distance between inner and outer polygon's edges
          pad                         ; number: broken-bound-padding - amount to shorten spanners where separated by a line break
          frame-X-extent                 ; pair: the spanner's X-dimensions
          open-on-left open-on-right  ; boolean: no visible frame on left/right edge (no distance between inner and outer polygon's edges)
          ;   We'll assume that this indicates a line break!
          border-radius                      ; number: border-radius for "round-filled-polygon" procedure
          )

   (let* (
           (h-thick (* thick (sqrt 2)))  ; X-distance between left and right edges of inner and outer polygon. Must be "thick" * sqrt 2  (Pythagoras)
           (l-width (* l-zigzag-width  0.5))   ; X-distance of zigzag corners
           (r-width (* r-zigzag-width 0.5))
           (Y-ext (cons 0 0))            ; dummy, needed for ly:stencil-expr  (is there a way without it?)
           (X-ext (cons
                   (if (> l-zigzag-width 0)    ; left edge has zigzag shape
                       (- (+ (car frame-X-extent) (/ l-width 2)) h-thick)  ; Half of the zigzag space will be taken from inside, other half from the outside. Frame space taken from outside.
                       (if open-on-left  (- (car frame-X-extent) h-thick) (- (car frame-X-extent) thick))
                       )
                   (if (> r-zigzag-width 0)   ; right edge has zigzag shape
                       (+ (- (cdr frame-X-extent) (/ r-width 2)) h-thick)
                       (if open-on-right (+ (cdr frame-X-extent) h-thick) (+ (cdr frame-X-extent) thick))
                       )))
           (X-ext (cons
                   (if open-on-left  (- (+ (car X-ext) pad) (/ l-width 2)) (car X-ext))     ; shorten/lengthen by broken-bound-padding if spanner is broken
                   (if open-on-right (+ (- (cdr X-ext) pad) (/ r-width 2)) (cdr X-ext))))
           (points (list))       ; will contain coordinates for outer polygon
           (points-i (list))     ; will contain coordinates for inner polygon
           (slope-upper (/ (- y-r-upper y-l-upper) (- (cdr X-ext) (car X-ext))))  ; slope of the polygon's upper edge
           (slope-lower (/ (- y-r-lower y-l-lower) (- (cdr X-ext) (car X-ext))))  ; slope of the polygon's lower edge
           (d-upper (if open-on-top    0  (* thick (sqrt (+ (expt slope-upper 2) 1)))))  ; (Pythagoras)
           ; Y-distance between upper edges of inner and outer polygon. Equal to "thick" if upper edge is horizontal.
           ; Increases as the upper edge's slope increases.
           (d-lower (if open-on-bottom 0  (* thick (sqrt (+ (expt slope-lower 2) 1)))))  ; same for lower edge
           ; stuff for later calculations:
           (xtemp 0)
           (yLowerLimit 0)
           (yUpperLimit 0)
           (xp 0)
           (yp 0)
           (jumps 0)
           )

     ; calculate outer polygon's borders:

     ; lower-left corner:
     (set! points (list (cons (car X-ext) y-l-lower)))

     ; calculate coordinates for left (outer) zigzag border:
     (if (and (> l-zigzag-width 0) (not open-on-left))
         (let loop ((cnt y-l-lower))
           (if (< cnt y-l-upper)
               (begin
                (if (and (< cnt y-l-upper) (> cnt y-l-lower))  ; only add to list if point is inside the given Y-range
                    (set! points (cons (cons    (car X-ext)             cnt                 ) points)))
                (if (and (< (+ cnt (/ l-zigzag-width 2)) y-l-upper) (> (+ cnt (/ l-zigzag-width 2)) y-l-lower))
                    (set! points (cons (cons (- (car X-ext) l-width) (+ cnt (/ l-zigzag-width 2)) ) points)))
                (loop (+ cnt l-zigzag-width))))))

     ; upper-left corner:
     (set! points (cons
                   (cons (car X-ext) y-l-upper)
                   points ))
     ; upper-right corner:
     (set! points (cons
                   (cons (cdr X-ext) y-r-upper)
                   points ))
     ; right outer zigzag border:
     (if (and (> r-zigzag-width 0) (not open-on-right))
         (let loop ((cnt y-r-upper))
           (if (> cnt y-r-lower)
               (begin
                (if (and (< cnt y-r-upper) (> cnt y-r-lower))
                    (set! points (cons (cons    (cdr X-ext)             cnt                  ) points)))
                (if (and (< (- cnt (/ r-zigzag-width 2)) y-r-upper) (> (- cnt (/ r-zigzag-width 2)) y-r-lower))
                    (set! points (cons (cons (+ (cdr X-ext) r-width) (- cnt (/ r-zigzag-width 2)) ) points)))
                (loop (- cnt r-zigzag-width))))))

     ; lower-right corner:
     (set! points (cons
                   (cons (cdr X-ext) y-r-lower)
                   points ))

     ; shrink X-ext for use with inner stuff:
     (if (not open-on-left)
         (if (> l-zigzag-width 0)
             (set! X-ext (cons (+ (car X-ext) h-thick) (cdr X-ext)))
             (set! X-ext (cons (+ (car X-ext)   thick) (cdr X-ext)))
             )
         )
     (if (not open-on-right)
         (if (> r-zigzag-width 0)
             (set! X-ext (cons (car X-ext) (- (cdr X-ext) h-thick)))
             (set! X-ext (cons (car X-ext) (- (cdr X-ext)   thick)))
             )
         )
     ; Now X-ext represents INNER polygon's width WITHOUT the zigzag corners.

     ; Now calculate inner borders:
     ; xp and yp will be the coordinates of the corner currently being calculated

     ; calculate lower-left corner:

     (set! yLowerLimit y-l-lower)
     (set! yUpperLimit y-l-upper)

     (if open-on-left
         (begin
          (set! xp (car X-ext))
          (set! yp (+ y-l-lower d-lower))
          )
         (if (> l-zigzag-width 0)
             (if (not (eq? slope-lower -1))
                 (begin
                  (set! jumps 0)
                  (while (> (- (+ (* slope-lower h-thick) d-lower) (* jumps l-zigzag-width)) l-zigzag-width)
                    (set! jumps (+ 1 jumps)))
                  (set! xtemp (/ (- (+ h-thick (* jumps l-zigzag-width)) d-lower) (+ slope-lower 1)))
                  ; results from the solution for a system of two equations. Forgive me, I'm a maths teacher :-)
                  (if (< xtemp (- h-thick (/ l-zigzag-width 2)))
                      (if (= 1 slope-lower)
                          (set! xtemp h-thick)
                          (set! xtemp
                                (/ (+ (- d-lower (* l-zigzag-width (+ 1 jumps))) h-thick) (- 1 slope-lower)))))  ; another system of 2 equations...
                  (set! xp (+ (- (car X-ext) h-thick) xtemp))
                  (set! yp (+ (+ y-l-lower (* slope-lower xtemp)) d-lower))
                  )
                 )
             (begin
              (set! xp (car X-ext))
              (set! yp (+ (+ y-l-lower (* thick slope-lower)) d-lower))
              )
             )
         )

     ; insert lower-left corner's coordinates into list:
     (if (not (and (and (not open-on-left) (> l-zigzag-width 0)) (eq? slope-lower -1)))
         (begin
          (set! points-i (cons (cons xp yp) points-i))
          (set! yLowerLimit yp)
          )
         )

     ; calculate upper-left corner:
     (if open-on-left
         (begin
          (set! xp (car X-ext))
          (set! yp (- y-l-upper d-upper))
          )
         (if (> l-zigzag-width 0)
             (if (not (eq? slope-upper 1))
                 (begin
                  (set! jumps 0)
                  (while (<
                          (+ (- (* slope-upper h-thick) d-upper) (* jumps l-zigzag-width))
                          (- l-zigzag-width))
                    (set! jumps (+ jumps 1)))
                  (set! xtemp (/ (- d-upper (+ h-thick (* jumps l-zigzag-width))) (- slope-upper 1)))
                  (if (< xtemp (- h-thick (/ l-zigzag-width 2)))
                      (if (= -1 slope-upper)
                          (set! xtemp h-thick)
                          (set! xtemp
                                (/ (- (- (* l-zigzag-width (+ 1 jumps)) d-upper) h-thick) (- (- 1) slope-upper)))
                          )
                      )
                  (set! xp (+ (- (car X-ext) h-thick) xtemp))
                  (set! yp (- (+ y-l-upper (* slope-upper xtemp)) d-upper))
                  )
                 )
             (begin
              (set! xp (car X-ext))
              (set! yp (- (+ y-l-upper (* thick slope-upper)) d-upper))
              )
             )
         )

     (if (not
          (and (and (not open-on-left) (> l-zigzag-width 0)) (eq? slope-upper 1))
          )
         (set! yUpperLimit yp))


     ; left (inner) zigzag:
     (if (and (> l-zigzag-width 0) (not open-on-left))
         (begin
          (let loop ((cnt y-l-lower))
            (if (< cnt y-l-upper)
                (begin
                 (if (and (> cnt yLowerLimit) (< cnt yUpperLimit))
                     (set! points-i (cons (cons    (car X-ext)             cnt                 ) points-i))
                     )
                 (if (and (> (+ cnt (/ l-zigzag-width 2)) yLowerLimit) (< (+ cnt (/ l-zigzag-width 2)) yUpperLimit))
                     (set! points-i (cons (cons (- (car X-ext) l-width) (+ cnt (/ l-zigzag-width 2)) ) points-i))
                     )
                 (loop (+ cnt l-zigzag-width))
                 )
                )
            )
          )
         )

     ; insert upper-left corner (yes, AFTER the zigzag points, so all the points will be given in clockwise order):
     (if (not
          (and (and (not open-on-left) (> l-zigzag-width 0)) (eq? slope-upper 1))
          )
         (set! points-i (cons (cons xp yp) points-i)))

     ; calculate upper-right corner:

     (set! yLowerLimit y-r-lower)
     (set! yUpperLimit y-r-upper)

     (if open-on-right
         (begin
          (set! xp (cdr X-ext))
          (set! yp (- y-r-upper d-upper))
          )
         (if (> r-zigzag-width 0)
             (if (not (eq? slope-upper -1))
                 (begin
                  (set! jumps 0)
                  (while (<
                          (+ (- (* slope-upper (- h-thick)) d-upper) (* jumps r-zigzag-width))
                          (- r-zigzag-width))
                    (set! jumps (+ jumps 1)))
                  (set! xtemp (/ (- d-upper (+ h-thick (* jumps r-zigzag-width))) (+ slope-upper 1)))
                  (if (> xtemp (- (/ r-zigzag-width 2) h-thick  ))
                      (if (= 1 slope-upper)
                          (set! xtemp (- h-thick))
                          (set! xtemp
                                (/ (- (- (* r-zigzag-width (+ 1 jumps)) d-upper) h-thick) (- 1 slope-upper)))
                          )
                      )
                  (set! xp (+ (+ (cdr X-ext) h-thick) xtemp))
                  (set! yp (- (+ y-r-upper (* slope-upper xtemp)) d-upper))
                  )
                 )
             (begin
              (set! xp (cdr X-ext))
              (set! yp (- (- y-r-upper (* thick slope-upper)) d-upper))
              )
             )
         )

     ; insert upper-right corner:
     (if (not
          (and (and (not open-on-right) (> r-zigzag-width 0)) (eq? slope-upper -1)))
         (begin
          (set! points-i (cons (cons xp yp) points-i))
          (set! yUpperLimit yp)))

     ; calculate lower-right corner:
     (if open-on-right
         (begin
          (set! xp (cdr X-ext))
          (set! yp (+ y-r-lower d-lower))
          )
         (if (> r-zigzag-width 0)
             (if (not (eq? slope-lower 1))
                 (begin
                  (set! jumps 0)
                  (while (> (- (- d-lower (* slope-lower h-thick)) (* jumps r-zigzag-width)) r-zigzag-width)
                    (set! jumps (+ 1 jumps)))
                  (set! xtemp (/ (- (+ h-thick (* jumps r-zigzag-width)) d-lower) (- slope-lower 1)))
                  (if (> xtemp (- (/ r-zigzag-width 2) h-thick)   )
                      (if (= -1 slope-lower)
                          (set! xtemp (- h-thick))
                          (set! xtemp
                                (/ (+ (- d-lower (* r-zigzag-width (+ 1 jumps))) h-thick) (- -1 slope-lower)))))
                  (set! xp (+ (+ (cdr X-ext) h-thick) xtemp))
                  (set! yp (+ (+ y-r-lower (* slope-lower xtemp)) d-lower))
                  )
                 )
             (begin
              (set! xp (cdr X-ext))
              (set! yp (+ (- y-r-lower (* thick slope-lower)) d-lower))
              )
             )
         )

     (if (not (and (and (not open-on-right) (> r-zigzag-width 0)) (eq? slope-lower 1)))
         (set! yLowerLimit yp))

     ; right zigzag:
     (if (and (> r-zigzag-width 0) (not open-on-right))
         (begin
          (let loop ((cnt y-r-upper))
            (if (> cnt y-r-lower)
                (begin
                 (if (and (> cnt yLowerLimit) (< cnt yUpperLimit))
                     (set! points-i (cons (cons    (cdr X-ext)             cnt                  ) points-i)))
                 (if (and (> (- cnt (/ r-zigzag-width 2)) yLowerLimit) (< (- cnt (/ r-zigzag-width 2)) yUpperLimit))
                     (set! points-i (cons (cons (+ (cdr X-ext) r-width) (- cnt (/ r-zigzag-width 2)) ) points-i)))
                 (loop (- cnt r-zigzag-width))
                 )
                )
            )
          )
         )

     ; insert lower-right corner:
     (if (not (and (and (not open-on-right) (> r-zigzag-width 0)) (eq? slope-lower 1)))
         (set! points-i (cons (cons xp yp) points-i)))

     (ly:stencil-add
      ; draw outer polygon:
      (if (color? border-color)  ; only add stencil if set to a valid color (could also be set to ##f)
          (ly:make-stencil (list 'color border-color
                             (ly:stencil-expr (ly:round-filled-polygon points border-radius))
                             X-ext Y-ext))
          empty-stencil)
      ; draw inner polygon:
      (if (color? color)   ; only add stencil if set to a valid color (could also be set to ##f)
          (ly:make-stencil (list 'color color
                             (ly:stencil-expr (ly:round-filled-polygon points-i border-radius))
                             X-ext Y-ext))
          empty-stencil)
      )
     )
   )












roundedRectangleSpan =
#(define-music-function (y-lower y-upper border-color color border-radius)
   (number? number? scheme? scheme? number?)
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* (
                (area (ly:horizontal-bracket::print grob))
                (thick (ly:grob-property grob 'line-thickness 1))
                (pad (ly:grob-property grob 'broken-bound-padding 0))
                (X-ext (ly:stencil-extent area X))
                (X-ext (cons (- (car X-ext) thick) (+ (cdr X-ext)  thick)))
                (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
                (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
                (X-ext (cons
                        (if open-on-left  (+ (car X-ext) pad) (car X-ext))
                        (if open-on-right (- (cdr X-ext) pad) (cdr X-ext))))
                (Y-ext (cons y-lower y-upper))
                (outer-rect empty-stencil)
                )
          ; calculate outer borders:
          (set! outer-rect
                (if (color? border-color)
                    (ly:make-stencil (list 'color border-color
                                       (ly:stencil-expr (ly:round-filled-box X-ext Y-ext border-radius))
                                       X-ext Y-ext))
                    empty-stencil)
                )
          ; shrink X-ext for use with inner stuff:
          (set! X-ext (cons (+ (car X-ext) thick) (cdr X-ext)))
          (set! X-ext (cons (car X-ext) (- (cdr X-ext) thick)))
          ; shrink Y-ext for use with inner stuff:
          (set! Y-ext (cons (+ (car Y-ext) thick) (cdr Y-ext)))
          (set! Y-ext (cons (car Y-ext) (- (cdr Y-ext) thick)))
          ;(ly:grob-set-property! grob 'layer -10)
          (ly:stencil-add
           outer-rect
           ; draw (inner) fill-rectangle
           (if (color? color)
               (ly:make-stencil (list 'color color
                                  (ly:stencil-expr (ly:round-filled-box X-ext Y-ext (- border-radius thick)))
                                  X-ext Y-ext))
               empty-stencil)
           )
          ))
     \once\override HorizontalBracket.Y-offset = #0
     %\once\override HorizontalBracket.shorten-pair = #'(-0.6 . -0.6)
   #})

tornSpan = #(define-music-function (y-lower y-upper border-color color l-zigzag-width r-zigzag-width)
              (number? number? scheme? scheme? number? number?)
              #{  \genericSpan $y-lower $y-upper $y-lower $y-upper $border-color $color $l-zigzag-width $r-zigzag-width ##f ##f  #})


% Here are some functions with pre-defined zigzag edges at the left / right / at both sides.
% They read out the property HorizontalBracket.zigzag-width and automatically round it to the nearest sensible value

leftZZSpan =
#(define-music-function (y-lower y-upper border-color color)
   (number? number? scheme? scheme?)
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* ((area (ly:horizontal-bracket::print grob))
               (thick (ly:grob-property grob 'line-thickness 1))
               (pad (ly:grob-property grob 'broken-bound-padding 0))
               (border-radius (ly:grob-property grob 'hair-thickness 0))
               (frame-X-extent (ly:stencil-extent area X))
               (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
               (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
               (l-zigzag-width (ly:grob-property grob 'zigzag-width 1.5))
               (dist-y (- y-upper y-lower))
               (cnt 1)
               )
          (if (not (= l-zigzag-width 0))
              (begin
               (set! cnt (round (/ dist-y l-zigzag-width)))  ; calculate number of zigzags, round to nearest integer
               (if (> cnt 0)
                   (set! l-zigzag-width (/ dist-y cnt))       ; calculate exact zigzag size
                   (set! l-zigzag-width 0))))
          (makeDeltaSpan  y-lower y-upper (+ 0 y-lower) (+ 0 y-upper) border-color color l-zigzag-width 0 #f #f
            thick pad frame-X-extent open-on-left open-on-right border-radius)))
     \once\override HorizontalBracket.Y-offset = #0
   #})

rightZZSpan =
#(define-music-function (y-lower y-upper border-color color)
   (number? number? scheme? scheme?)
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* ((area (ly:horizontal-bracket::print grob))
               (thick (ly:grob-property grob 'line-thickness 1))
               (pad (ly:grob-property grob 'broken-bound-padding 0))
               (border-radius (ly:grob-property grob 'hair-thickness 0))
               (frame-X-extent (ly:stencil-extent area X))
               (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
               (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
               (r-zigzag-width (ly:grob-property grob 'zigzag-width 1.5))
               (dist-y (- y-upper y-lower))
               (cnt 1)
               )
          (if (not (= r-zigzag-width 0))
              (begin
               (set! cnt (round (/ dist-y r-zigzag-width)))
               (if (> cnt 0)
                   (set! r-zigzag-width (/ dist-y cnt))
                   (set! r-zigzag-width 0))))
          (makeDeltaSpan  y-lower y-upper (+ 0 y-lower) (+ 0 y-upper) border-color color 0 r-zigzag-width #f #f
            thick pad frame-X-extent open-on-left open-on-right border-radius)))
     \once\override HorizontalBracket.Y-offset = #0
   #})

ZZSpan =
#(define-music-function (y-lower y-upper border-color color)
   (number? number? scheme? scheme?)
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* ((area (ly:horizontal-bracket::print grob))
               (thick (ly:grob-property grob 'line-thickness 1))
               (pad (ly:grob-property grob 'broken-bound-padding 0))
               (border-radius (ly:grob-property grob 'hair-thickness 0))
               (frame-X-extent (ly:stencil-extent area X))
               (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
               (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
               (l-zigzag-width (ly:grob-property grob 'zigzag-width 1.5))
               (r-zigzag-width (ly:grob-property grob 'zigzag-width 1.5))
               (dist-y (- y-upper y-lower))
               (cnt 1)
               )
          (if (not (= l-zigzag-width 0))
              (begin
               (set! cnt (round (/ dist-y l-zigzag-width)))
               (if (> cnt 0)
                   (set! l-zigzag-width (/ dist-y cnt))
                   (set! l-zigzag-width 0))))
          (if (not (= r-zigzag-width 0))
              (begin
               (set! cnt (round (/ dist-y r-zigzag-width)))
               (if (> cnt 0)
                   (set! r-zigzag-width (/ dist-y cnt))
                   (set! r-zigzag-width 0))))
          (makeDeltaSpan  y-lower y-upper (+ 0 y-lower) (+ 0 y-upper) border-color color l-zigzag-width r-zigzag-width #f #f
            thick pad frame-X-extent open-on-left open-on-right border-radius)))
     \once\override HorizontalBracket.Y-offset = #0
   #})

tornDYSpan = #(define-music-function (y-l-lower y-l-upper y-r-lower y-r-upper border-color color l-zigzag-width r-zigzag-width)
                (number? number? number? number? scheme? scheme? number? number?)
                #{  \genericSpan $y-l-lower $y-l-upper $y-r-lower $y-r-upper $border-color $color $l-zigzag-width $r-zigzag-width ##f ##f  #})

DYSpan = #(define-music-function (y-l-lower y-l-upper y-r-lower y-r-upper border-color color)
            (number? number? number? number? scheme? scheme?)
            #{  \genericSpan $y-l-lower $y-l-upper $y-r-lower $y-r-upper $border-color $color #0 #0 ##f ##f  #})

colorSpan = #(define-music-function (y-lower y-upper color)
               (number? number? scheme?)
               #{  \genericSpan $y-lower $y-upper $y-lower $y-upper ##f $color #0 #0 ##f ##f  #})

framedSpan = #(define-music-function (y-lower y-upper border-color color)
                (number? number? scheme? scheme?)
                #{  \genericSpan $y-lower $y-upper $y-lower $y-upper $border-color $color #0 #0 ##f ##f  #})

roundRectSpan = #(define-music-function (y-lower y-upper border-color color border-radius)
                   (number? number? scheme? scheme? number?)
                   #{  \roundedRectangleSpan $y-lower $y-upper $border-color $color $border-radius  #})


% The following is pretty much the same thing as makeDeltaSpan, but it will only produce a frame that won't be filled.
% The lower, upper, left and right edge will each be drawn as a separate polygon.

#(define (makeDeltaFrame
          y-l-lower y-l-upper         ; number: Y-dimensions (left edge)
          y-r-lower y-r-upper         ; number: Y-dimensions (right edge)
          border-color                 ; frame color (if set to ##f, no frame will be drawn)
          l-zigzag-width r-zigzag-width          ; number: size of zigzag elements for left and right edge (vertical edge / no zigzag if set to zero)
          open-on-bottom open-on-top  ; boolean: if set to #t, lower resp. upper edge won't be drawn
          thick                       ; number: frame thickness - if set to zero, no frame will be drawn
          pad                         ; number: broken-bound-padding - amount to shorten spanners where separated by a line break (negative values can be used for lengthening)
          frame-X-extent                 ; pair: the spanner's X-dimensions
          open-on-left open-on-right  ; boolean: if set to #t, left resp. right edge won't be drawn
          ;   We'll assume that this indicates a line break!
          )

   (let* (
           (h-thick (* thick (sqrt 2)))  ; X-distance between left and right edges of inner and outer polygon. Must be "thick" * sqrt 2  (Pythagoras)
           (l-width (* l-zigzag-width  0.5))   ; X-distance of zigzag corners
           (r-width (* r-zigzag-width 0.5))
           (Y-ext (cons 0 0))            ; dummy, needed for ly:stencil-expr  (is there a way without it?)
           (X-ext (cons
                   (if (> l-zigzag-width 0)    ; left edge has zigzag shape
                       (- (+ (car frame-X-extent) (/ l-width 2)) h-thick)  ; Half of the zigzag space will be taken from inside, other half from the outside. Frame space taken from outside.
                       (if open-on-left  (- (car frame-X-extent) h-thick) (- (car frame-X-extent) thick))
                       )
                   (if (> r-zigzag-width 0)   ; right edge has zigzag shape
                       (+ (- (cdr frame-X-extent) (/ r-width 2)) h-thick)
                       (if open-on-right (+ (cdr frame-X-extent) h-thick) (+ (cdr frame-X-extent) thick))
                       )))
           (X-ext (cons
                   (if open-on-left  (- (+ (car X-ext) pad) (/ l-width 2)) (car X-ext))     ; shorten/lengthen by broken-bound-padding if spanner is broken
                   (if open-on-right (+ (- (cdr X-ext) pad) (/ r-width 2)) (cdr X-ext))))
           (points-up (list))    ; will contain coordinates for upper edge polygon
           (points-lo (list))    ; will contain coordinates for lower edge polygon
           (points-l (list))     ; will contain coordinates for left  edge polygon
           (points-r (list))     ; will contain coordinates for right edge polygon
           (slope-upper (/ (- y-r-upper y-l-upper) (- (cdr X-ext) (car X-ext))))  ; slope of the polygon's upper edge
           (slope-lower (/ (- y-r-lower y-l-lower) (- (cdr X-ext) (car X-ext))))  ; slope of the polygon's lower edge
           (d-upper (if open-on-top    0  (* thick (sqrt (+ (expt slope-upper 2) 1)))))  ; (Pythagoras)
           ; Y-distance between upper edges of inner and outer polygon. Equal to "thick" if upper edge is horizontal.
           ; Increases as the upper edge's slope increases.
           (d-lower (if open-on-bottom 0  (* thick (sqrt (+ (expt slope-lower 2) 1)))))  ; same for lower edge
           ; stuff for later calculations:
           (xtemp 0)
           (yLowerLimit 0)
           (yUpperLimit 0)
           (xp 0)
           (yp 0)
           (jumps 0)
           )

     ; calculate outer polygon's borders...

     ; start calculating left edge borders:
     ; lower-left corner:
     (set! points-l (list (cons (car X-ext) y-l-lower)))

     ; calculate coordinates for left (outer) zigzag border:
     (if (and (> l-zigzag-width 0) (not open-on-left))
         (let loop ((cnt y-l-lower))
           (if (< cnt y-l-upper)
               (begin
                (if (and (< cnt y-l-upper) (> cnt y-l-lower))  ; only add to list if point is inside the given Y-range
                    (set! points-l (cons (cons    (car X-ext)             cnt                 ) points-l)))
                (if (and (< (+ cnt (/ l-zigzag-width 2)) y-l-upper) (> (+ cnt (/ l-zigzag-width 2)) y-l-lower))
                    (set! points-l (cons (cons (- (car X-ext) l-width) (+ cnt (/ l-zigzag-width 2)) ) points-l)))
                (loop (+ cnt l-zigzag-width))))))

     ; upper-left corner:
     (set! points-l (cons
                     (cons (car X-ext) y-l-upper)
                     points-l ))

     ; start calculating right edge borders:
     ; upper-right corner:
     (set! points-r (cons
                     (cons (cdr X-ext) y-r-upper)
                     points-r ))
     ; right outer zigzag border:
     (if (and (> r-zigzag-width 0) (not open-on-right))
         (let loop ((cnt y-r-upper))
           (if (> cnt y-r-lower)
               (begin
                (if (and (< cnt y-r-upper) (> cnt y-r-lower))
                    (set! points-r (cons (cons    (cdr X-ext)             cnt                  ) points-r)))
                (if (and (< (- cnt (/ r-zigzag-width 2)) y-r-upper) (> (- cnt (/ r-zigzag-width 2)) y-r-lower))
                    (set! points-r (cons (cons (+ (cdr X-ext) r-width) (- cnt (/ r-zigzag-width 2)) ) points-r)))
                (loop (- cnt r-zigzag-width))))))

     ; lower-right corner:
     (set! points-r (cons
                     (cons (cdr X-ext) y-r-lower)
                     points-r ))



     ; calculate lower edge borders:

     ; lower-left corner:
     (set! points-lo (list (cons (car X-ext) y-l-lower)))
     ; upper-left corner:
     (set! points-lo (cons (cons (car X-ext) (+ y-l-lower thick)) points-lo))
     ; upper-right corner:
     (set! points-lo (cons (cons (cdr X-ext) (+ y-r-lower thick)) points-lo))
     ; lower-right corner:
     (set! points-lo (cons (cons (cdr X-ext) y-r-lower) points-lo))


     ; calculate upper edge borders:

     ; lower-left corner:
     (set! points-up (list (cons (car X-ext) (- y-l-upper thick) )))
     ; upper-left corner:
     (set! points-up (cons (cons (car X-ext) y-l-upper) points-up))
     ; upper-right corner:
     (set! points-up (cons (cons (cdr X-ext) y-r-upper) points-up))
     ; lower-right corner:
     (set! points-up (cons (cons (cdr X-ext) (- y-r-upper thick) ) points-up))



     ; shrink X-ext for use with inner stuff:
     (if (not open-on-left)
         (if (> l-zigzag-width 0)
             (set! X-ext (cons (+ (car X-ext) h-thick) (cdr X-ext)))
             (set! X-ext (cons (+ (car X-ext)   thick) (cdr X-ext)))
             )
         )
     (if (not open-on-right)
         (if (> r-zigzag-width 0)
             (set! X-ext (cons (car X-ext) (- (cdr X-ext) h-thick)))
             (set! X-ext (cons (car X-ext) (- (cdr X-ext)   thick)))
             )
         )
     ; Now X-ext represents INNER polygon's width WITHOUT the zigzag corners


     ; Now calculate inner borders:
     ; xp and yp will be the coordinates of the corner currently being calculated

     ; continue calculating left edge coordinates:
     (set! yLowerLimit y-l-lower)
     (set! yUpperLimit y-l-upper)

     ; calculate upper-left corner:
     (if open-on-left
         (begin
          (set! xp (car X-ext))
          (set! yp (- y-l-upper d-upper))
          )
         (if (> l-zigzag-width 0)
             (if (not (eq? slope-upper 1))
                 (begin
                  (set! jumps 0)
                  (while (<
                          (+ (- (* slope-upper h-thick) d-upper) (* jumps l-zigzag-width))
                          (- l-zigzag-width))
                    (set! jumps (+ jumps 1)))
                  (set! xtemp (/ (- d-upper (+ h-thick (* jumps l-zigzag-width))) (- slope-upper 1)))
                  (if (< xtemp (- h-thick (/ l-zigzag-width 2)))
                      (if (= -1 slope-upper)
                          (set! xtemp h-thick)
                          (set! xtemp
                                (/ (- (- (* l-zigzag-width (+ 1 jumps)) d-upper) h-thick) (- (- 1) slope-upper)))
                          )
                      )
                  (set! xp (+ (- (car X-ext) h-thick) xtemp))
                  (set! yp (- (+ y-l-upper (* slope-upper xtemp)) d-upper))
                  )
                 )
             (begin
              (set! xp (car X-ext))
              (set! yp (- (+ y-l-upper (* thick slope-upper)) d-upper))
              )
             )
         )

     ; insert upper-left corner's coordinates into list:
     (if (not
          (and (and (not open-on-left) (> l-zigzag-width 0)) (eq? slope-upper 1))
          )
         (begin
          (set! points-l (cons (cons xp yp) points-l))
          (set! yUpperLimit yp))
         )

     ; calculate lower-left corner:
     (if open-on-left
         (begin
          (set! xp (car X-ext))
          (set! yp (+ y-l-lower d-lower))
          )
         (if (> l-zigzag-width 0)
             (if (not (eq? slope-lower -1))
                 (begin
                  (set! jumps 0)
                  (while (> (- (+ (* slope-lower h-thick) d-lower) (* jumps l-zigzag-width)) l-zigzag-width)
                    (set! jumps (+ 1 jumps)))
                  (set! xtemp (/ (- (+ h-thick (* jumps l-zigzag-width)) d-lower) (+ slope-lower 1)))
                  ; results from the solution for a system of two equations. Forgive me, I'm a maths teacher :-)
                  (if (< xtemp (- h-thick (/ l-zigzag-width 2)))
                      (if (= 1 slope-lower)
                          (set! xtemp h-thick)
                          (set! xtemp
                                (/ (+ (- d-lower (* l-zigzag-width (+ 1 jumps))) h-thick) (- 1 slope-lower)))))  ; another system of 2 equations...
                  (set! xp (+ (- (car X-ext) h-thick) xtemp))
                  (set! yp (+ (+ y-l-lower (* slope-lower xtemp)) d-lower))
                  )
                 )
             (begin
              (set! xp (car X-ext))
              (set! yp (+ (+ y-l-lower (* thick slope-lower)) d-lower))
              )
             )
         )

     (if (not (and (and (not open-on-left) (> l-zigzag-width 0)) (eq? slope-lower -1)))
         (set! yLowerLimit yp)
         )

     ; left (inner) zigzag:
     (if (and (> l-zigzag-width 0) (not open-on-left))
         (begin
          (let loop ((cnt y-l-upper))
            (if (> cnt y-l-lower)
                (begin
                 (if (and (> cnt yLowerLimit) (< cnt yUpperLimit))
                     (set! points-l (cons (cons    (car X-ext)             cnt                 ) points-l))
                     )
                 (if (and (> (- cnt (/ l-zigzag-width 2)) yLowerLimit) (< (- cnt (/ l-zigzag-width 2)) yUpperLimit))
                     (set! points-l (cons (cons (- (car X-ext) l-width) (- cnt (/ l-zigzag-width 2)) ) points-l))
                     )
                 (loop (- cnt l-zigzag-width))
                 )
                )
            )
          )
         )

     ; insert lower-left corner (yes, AFTER the zigzag points, so all the points will be given in clockwise order):
     (if (not (and (and (not open-on-left) (> l-zigzag-width 0)) (eq? slope-lower -1)))
         (set! points-l (cons (cons xp yp) points-l))
         )

     ; continue calculating right edge borders:

     (set! yLowerLimit y-r-lower)
     (set! yUpperLimit y-r-upper)

     ; calculate lower-right corner:
     (if open-on-right
         (begin
          (set! xp (cdr X-ext))
          (set! yp (+ y-r-lower d-lower))
          )
         (if (> r-zigzag-width 0)
             (if (not (eq? slope-lower 1))
                 (begin
                  (set! jumps 0)
                  (while (> (- (- d-lower (* slope-lower h-thick)) (* jumps r-zigzag-width)) r-zigzag-width)
                    (set! jumps (+ 1 jumps)))
                  (set! xtemp (/ (- (+ h-thick (* jumps r-zigzag-width)) d-lower) (- slope-lower 1)))
                  (if (> xtemp (- (/ r-zigzag-width 2) h-thick)   )
                      (if (= -1 slope-lower)
                          (set! xtemp (- h-thick))
                          (set! xtemp
                                (/ (+ (- d-lower (* r-zigzag-width (+ 1 jumps))) h-thick) (- -1 slope-lower)))))
                  (set! xp (+ (+ (cdr X-ext) h-thick) xtemp))
                  (set! yp (+ (+ y-r-lower (* slope-lower xtemp)) d-lower))
                  )
                 )
             (begin
              (set! xp (cdr X-ext))
              (set! yp (+ (- y-r-lower (* thick slope-lower)) d-lower))
              )
             )
         )

     ; insert lower-right corner:
     (if (not (and (and (not open-on-right) (> r-zigzag-width 0)) (eq? slope-lower 1)))
         (begin
          (set! yLowerLimit yp)
          (set! points-r (cons (cons xp yp) points-r)))
         )


     ; calculate upper-right corner:
     (if open-on-right
         (begin
          (set! xp (cdr X-ext))
          (set! yp (- y-r-upper d-upper))
          )
         (if (> r-zigzag-width 0)
             (if (not (eq? slope-upper -1))
                 (begin
                  (set! jumps 0)
                  (while (<
                          (+ (- (* slope-upper (- h-thick)) d-upper) (* jumps r-zigzag-width))
                          (- r-zigzag-width))
                    (set! jumps (+ jumps 1)))
                  (set! xtemp (/ (- d-upper (+ h-thick (* jumps r-zigzag-width))) (+ slope-upper 1)))
                  (if (> xtemp (- (/ r-zigzag-width 2) h-thick  ))
                      (if (= 1 slope-upper)
                          (set! xtemp (- h-thick))
                          (set! xtemp
                                (/ (- (- (* r-zigzag-width (+ 1 jumps)) d-upper) h-thick) (- 1 slope-upper)))
                          )
                      )
                  (set! xp (+ (+ (cdr X-ext) h-thick) xtemp))
                  (set! yp (- (+ y-r-upper (* slope-upper xtemp)) d-upper))
                  )
                 )
             (begin
              (set! xp (cdr X-ext))
              (set! yp (- (- y-r-upper (* thick slope-upper)) d-upper))
              )
             )
         )

     (if (not
          (and (and (not open-on-right) (> r-zigzag-width 0)) (eq? slope-upper -1)))
         (set! yUpperLimit yp))

     ; right zigzag:
     (if (and (> r-zigzag-width 0) (not open-on-right))
         (begin
          (let loop ((cnt y-r-lower))
            (if (< cnt y-r-upper)
                (begin
                 (if (and (> cnt yLowerLimit) (< cnt yUpperLimit))
                     (begin
                      (set! points-r (cons (cons    (cdr X-ext)             cnt                  ) points-r))
                      ))
                 (if (and (> (+ cnt (/ r-zigzag-width 2)) yLowerLimit) (< (+ cnt (/ r-zigzag-width 2)) yUpperLimit))
                     (begin
                      (set! points-r (cons (cons (+ (cdr X-ext) r-width) (+ cnt (/ r-zigzag-width 2)) ) points-r))
                      ))
                 (loop (+ cnt r-zigzag-width))
                 )
                )
            )
          )
         )

     ; insert upper-right corner:
     (if (not
          (and (and (not open-on-right) (> r-zigzag-width 0)) (eq? slope-upper -1)))
         (set! points-r (cons (cons xp yp) points-r)))


     (ly:stencil-add
      ; draw upper edge:
      (if (and (and (> thick 0) (not open-on-top)) (color? border-color))
          (ly:make-stencil (list 'color border-color
                             (ly:stencil-expr (ly:round-filled-polygon points-up 0))
                             X-ext Y-ext))
          empty-stencil)
      ; draw lower edge:
      (if (and (and (> thick 0) (not open-on-bottom)) (color? border-color))
          (ly:make-stencil (list 'color border-color
                             (ly:stencil-expr (ly:round-filled-polygon points-lo 0))
                             X-ext Y-ext))
          empty-stencil)
      ; draw left edge:
      (if (and (and (> thick 0) (not open-on-left)) (color? border-color))
          (ly:make-stencil (list 'color border-color
                             (ly:stencil-expr (ly:round-filled-polygon points-l 0))
                             X-ext Y-ext))
          empty-stencil)
      ; draw right edge:
      (if (and (and (> thick 0) (not open-on-right)) (color? border-color))
          (ly:make-stencil (list 'color border-color
                             (ly:stencil-expr (ly:round-filled-polygon points-r 0))
                             X-ext Y-ext))
          empty-stencil)
      )
     )
   )

% The following music functions will use the above makeDeltaFrame:

genericFrameBak =
#(define-music-function (y-l-lower y-l-upper y-r-lower y-r-upper border-color l-zigzag-width r-zigzag-width open-on-bottom open-on-top)
   (number? number? number? number? scheme? number? number? boolean? boolean?)
   ; Calling this procedure IMMEDIATELY before \startGroup will replace the stencil of HorizontalBracket.
   ; Some parameters are taken out of HorizontalBracket's properties
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* (
                (area (ly:horizontal-bracket::print grob))
                (thick (ly:grob-property grob 'line-thickness 1))
                (pad (ly:grob-property grob 'broken-bound-padding 0))
                (frame-X-extent (ly:stencil-extent area X))
                (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
                (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
                )
          (makeDeltaFrame  y-l-lower y-l-upper y-r-lower y-r-upper border-color l-zigzag-width r-zigzag-width open-on-bottom open-on-top
            thick pad frame-X-extent open-on-left open-on-right)
          ))
     \once\override HorizontalBracket.Y-offset = #0
   #})


tornFrame = #(define-music-function (y-lower y-upper border-color l-zigzag-width r-zigzag-width)
               (number? number? scheme? number? number?)
               #{  \genericFrame $y-lower $y-upper $y-lower $y-upper $border-color $l-zigzag-width $r-zigzag-width ##f ##f  #})


% Here are some functions with pre-defined zigzag edges at the left / right / at both sides.
% They read out the property HorizontalBracket.zigzag-width and automatically round it to the nearest sensible value

leftZZFrame =
#(define-music-function (y-lower y-upper border-color)
   (number? number? scheme?)
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* ((area (ly:horizontal-bracket::print grob))
               (thick (ly:grob-property grob 'line-thickness 1))
               (pad (ly:grob-property grob 'broken-bound-padding 0))
               (frame-X-extent (ly:stencil-extent area X))
               (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
               (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
               (l-zigzag-width (ly:grob-property grob 'zigzag-width 1.5))
               (dist-y (- y-upper y-lower))
               (cnt 1)
               )
          (if (not (= l-zigzag-width 0))
              (begin
               (set! cnt (round (/ dist-y l-zigzag-width)))  ; calculate number of zigzags, round to nearest integer
               (if (> cnt 0)
                   (set! l-zigzag-width (/ dist-y cnt))       ; calculate exact zigzag size
                   (set! l-zigzag-width 0))))
          (makeDeltaFrame  y-lower y-upper (+ 0 y-lower) (+ 0 y-upper) border-color l-zigzag-width 0 #f #f
            thick pad frame-X-extent open-on-left open-on-right)))
     \once\override HorizontalBracket.Y-offset = #0
   #})

rightZZFrame =
#(define-music-function (y-lower y-upper border-color)
   (number? number? scheme?)
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* ((area (ly:horizontal-bracket::print grob))
               (thick (ly:grob-property grob 'line-thickness 1))
               (pad (ly:grob-property grob 'broken-bound-padding 0))
               (frame-X-extent (ly:stencil-extent area X))
               (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
               (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
               (r-zigzag-width (ly:grob-property grob 'zigzag-width 1.5))
               (dist-y (- y-upper y-lower))
               (cnt 1)
               )
          (if (not (= r-zigzag-width 0))
              (begin
               (set! cnt (round (/ dist-y r-zigzag-width)))
               (if (> cnt 0)
                   (set! r-zigzag-width (/ dist-y cnt))
                   (set! r-zigzag-width 0))))
          (makeDeltaFrame  y-lower y-upper (+ 0 y-lower) (+ 0 y-upper) border-color 0 r-zigzag-width #f #f
            thick pad frame-X-extent open-on-left open-on-right)))
     \once\override HorizontalBracket.Y-offset = #0
   #})

ZZFrame =
#(define-music-function (y-lower y-upper border-color)
   (number? number? scheme?)
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* ((area (ly:horizontal-bracket::print grob))
               (thick (ly:grob-property grob 'line-thickness 1))
               (pad (ly:grob-property grob 'broken-bound-padding 0))
               (frame-X-extent (ly:stencil-extent area X))
               (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
               (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
               (l-zigzag-width (ly:grob-property grob 'zigzag-width 1.5))
               (r-zigzag-width (ly:grob-property grob 'zigzag-width 1.5))
               (dist-y (- y-upper y-lower))
               (cnt 1)
               )
          (if (not (= l-zigzag-width 0))
              (begin
               (set! cnt (round (/ dist-y l-zigzag-width)))
               (if (> cnt 0)
                   (set! l-zigzag-width (/ dist-y cnt))
                   (set! l-zigzag-width 0))))
          (if (not (= r-zigzag-width 0))
              (begin
               (set! cnt (round (/ dist-y r-zigzag-width)))
               (if (> cnt 0)
                   (set! r-zigzag-width (/ dist-y cnt))
                   (set! r-zigzag-width 0))))
          (makeDeltaFrame  y-lower y-upper (+ 0 y-lower) (+ 0 y-upper) border-color l-zigzag-width r-zigzag-width #f #f
            thick pad frame-X-extent open-on-left open-on-right)))
     \once\override HorizontalBracket.Y-offset = #0
   #})

tornDYFrame = #(define-music-function (y-l-lower y-l-upper y-r-lower y-r-upper border-color l-zigzag-width r-zigzag-width)
                 (number? number? number? number? scheme? number? number?)
                 #{  \genericFrame $y-l-lower $y-l-upper $y-r-lower $y-r-upper $border-color $l-zigzag-width $r-zigzag-width ##f ##f  #})

DYFrame = #(define-music-function (y-l-lower y-l-upper y-r-lower y-r-upper border-color)
             (number? number? number? number? scheme?)
             #{  \genericFrame $y-l-lower $y-l-upper $y-r-lower $y-r-upper $border-color #0 #0 ##f ##f  #})

colorFrame = #(define-music-function (y-lower y-upper border-color)
                (number? number? scheme? scheme?)
                #{  \genericFrame $y-lower $y-upper $y-lower $y-upper $border-color #0 #0 ##f ##f  #})


#(define-markup-command (on-color layout props color arg) (scheme? markup?)
   (let* ((stencil (interpret-markup layout props arg))
          (X-ext (ly:stencil-extent stencil X))
          (Y-ext (ly:stencil-extent stencil Y)))
     (if (color? color)
         (ly:stencil-add (ly:make-stencil
                          (list 'color color
                            (ly:stencil-expr (ly:round-filled-box X-ext Y-ext 0))
                            X-ext Y-ext)) stencil)
         stencil)
     )
   )


#(define-markup-command (sticker layout props border-color color arg) (color? color? markup?)
   (let* ((stencil (interpret-markup layout props arg))
          (X-ext (ly:stencil-extent stencil X))
          (Y-ext (ly:stencil-extent stencil Y))
          (cnt 0)
          (step 0)
          (dist-y (- (cdr Y-ext) (car Y-ext))))
     (set! cnt (round (/ dist-y 0.7)))
     (if (> cnt 0)
         (set! step (/ dist-y cnt))
         (set! step 0))
     (ly:stencil-add
      (makeDeltaSpan
       (car Y-ext) (cdr Y-ext) (car Y-ext) (cdr Y-ext) border-color color
       step step #f #f 0.1 ; thick
       0 X-ext #f #f 0)
      stencil)))


% make the underlying engraver available automatically
\layout {
  \context {
    \Voice
    \consists "Horizontal_bracket_engraver"
  }
}