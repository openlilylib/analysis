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
% along with ScholarLY.  If not, see <http://www.gnu.org/licenses/>.          %
%                                                                             %
% anaLYsis is maintained by Urs Liska, ul@openlilylib.org                     %
% Copyright Klaus Blum & Urs Liska, 2017                                      %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
  This file implements support for drawing analysis arrows
%}

% TODO:
% Make layer stuff configurable

% --------------------------------------------------------------------------
%    Frames and Rectangles
% --------------------------------------------------------------------------


\layout {
  \override HorizontalBracket.layer = #-10
  \override HorizontalBracket.shorten-pair = #'(-0.3 . -0.3)
  % "Abuse" properties that are not used by HorizontalBracket:
  \override HorizontalBracket.line-thickness = #0.3
  \override HorizontalBracket.broken-bound-padding = #-4
  \override HorizontalBracket.hair-thickness = #0
  \override HorizontalBracket.zigzag-width = #1.5
  \context {
    \Voice
    \consists "Horizontal_bracket_engraver"
  }
}


% The "central" drawing procedure:

#(define (makeDeltaSpan
          y-l-lower y-l-upper         ; number: Y-dimensions (left edge)
          y-r-lower y-r-upper         ; number: Y-dimensions (right edge)
          frame-color fill-color      ; (color or ##f): colors for outer and inner polygon (won't be drawn if set to ##f)
          stepLeft stepRight          ; number: size of zigzag elements for left and right edge (vertical edge / no zigzag if set to zero)
          open-on-bottom open-on-top  ; boolean: no visible frame on bottom/top edge (no distance between inner and outer polygon's edges)
          thick                       ; number: frame thickness - distance between inner and outer polygon's edges
          pad                         ; number: broken-bound-padding - amount to shorten spanners where separated by a line break
          X-ext-param                 ; pair: the spanner's X-dimensions
          open-on-left open-on-right  ; boolean: no visible frame on left/right edge (no distance between inner and outer polygon's edges)
          ;   We'll assume that this indicates a line break!
          radius                      ; number: radius for "round-filled-polygon" procedure
          )

   (let* (
           (h-thick (* thick (sqrt 2)))  ; X-distance between left and right edges of inner and outer polygon. Must be "thick" * sqrt 2  (Pythagoras)
           (l-width (* stepLeft  0.5))   ; X-distance of zigzag corners
           (r-width (* stepRight 0.5))
           (Y-ext (cons 0 0))            ; dummy, needed for ly:stencil-expr  (is there a way without it?)
           (X-ext (cons
                   (if (> stepLeft 0)    ; left edge has zigzag shape
                       (- (+ (car X-ext-param) (/ l-width 2)) h-thick)  ; Half of the zigzag space will be taken from inside, other half from the outside. Frame space taken from outside.
                       (if open-on-left  (- (car X-ext-param) h-thick) (- (car X-ext-param) thick))
                       )
                   (if (> stepRight 0)   ; right edge has zigzag shape
                       (+ (- (cdr X-ext-param) (/ r-width 2)) h-thick)
                       (if open-on-right (+ (cdr X-ext-param) h-thick) (+ (cdr X-ext-param) thick))
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
     (if (and (> stepLeft 0) (not open-on-left))
         (let loop ((cnt y-l-lower))
           (if (< cnt y-l-upper)
               (begin
                (if (and (< cnt y-l-upper) (> cnt y-l-lower))  ; only add to list if point is inside the given Y-range
                    (set! points (cons (cons    (car X-ext)             cnt                 ) points)))
                (if (and (< (+ cnt (/ stepLeft 2)) y-l-upper) (> (+ cnt (/ stepLeft 2)) y-l-lower))
                    (set! points (cons (cons (- (car X-ext) l-width) (+ cnt (/ stepLeft 2)) ) points)))
                (loop (+ cnt stepLeft))))))

     ; upper-left corner:
     (set! points (cons
                   (cons (car X-ext) y-l-upper)
                   points ))
     ; upper-right corner:
     (set! points (cons
                   (cons (cdr X-ext) y-r-upper)
                   points ))
     ; right outer zigzag border:
     (if (and (> stepRight 0) (not open-on-right))
         (let loop ((cnt y-r-upper))
           (if (> cnt y-r-lower)
               (begin
                (if (and (< cnt y-r-upper) (> cnt y-r-lower))
                    (set! points (cons (cons    (cdr X-ext)             cnt                  ) points)))
                (if (and (< (- cnt (/ stepRight 2)) y-r-upper) (> (- cnt (/ stepRight 2)) y-r-lower))
                    (set! points (cons (cons (+ (cdr X-ext) r-width) (- cnt (/ stepRight 2)) ) points)))
                (loop (- cnt stepRight))))))

     ; lower-right corner:
     (set! points (cons
                   (cons (cdr X-ext) y-r-lower)
                   points ))

     ; shrink X-ext for use with inner stuff:
     (if (not open-on-left)
         (if (> stepLeft 0)
             (set! X-ext (cons (+ (car X-ext) h-thick) (cdr X-ext)))
             (set! X-ext (cons (+ (car X-ext)   thick) (cdr X-ext)))
             )
         )
     (if (not open-on-right)
         (if (> stepRight 0)
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
         (if (> stepLeft 0)
             (if (not (eq? slope-lower -1))
                 (begin
                  (set! jumps 0)
                  (while (> (- (+ (* slope-lower h-thick) d-lower) (* jumps stepLeft)) stepLeft)
                    (set! jumps (+ 1 jumps)))
                  (set! xtemp (/ (- (+ h-thick (* jumps stepLeft)) d-lower) (+ slope-lower 1)))
                  ; results from the solution for a system of two equations. Forgive me, I'm a maths teacher :-)
                  (if (< xtemp (- h-thick (/ stepLeft 2)))
                      (if (= 1 slope-lower)
                          (set! xtemp h-thick)
                          (set! xtemp
                                (/ (+ (- d-lower (* stepLeft (+ 1 jumps))) h-thick) (- 1 slope-lower)))))  ; another system of 2 equations...
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
     (if (not (and (and (not open-on-left) (> stepLeft 0)) (eq? slope-lower -1)))
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
         (if (> stepLeft 0)
             (if (not (eq? slope-upper 1))
                 (begin
                  (set! jumps 0)
                  (while (<
                          (+ (- (* slope-upper h-thick) d-upper) (* jumps stepLeft))
                          (- stepLeft))
                    (set! jumps (+ jumps 1)))
                  (set! xtemp (/ (- d-upper (+ h-thick (* jumps stepLeft))) (- slope-upper 1)))
                  (if (< xtemp (- h-thick (/ stepLeft 2)))
                      (if (= -1 slope-upper)
                          (set! xtemp h-thick)
                          (set! xtemp
                                (/ (- (- (* stepLeft (+ 1 jumps)) d-upper) h-thick) (- (- 1) slope-upper)))
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
          (and (and (not open-on-left) (> stepLeft 0)) (eq? slope-upper 1))
          )
         (set! yUpperLimit yp))


     ; left (inner) zigzag:
     (if (and (> stepLeft 0) (not open-on-left))
         (begin
          (let loop ((cnt y-l-lower))
            (if (< cnt y-l-upper)
                (begin
                 (if (and (> cnt yLowerLimit) (< cnt yUpperLimit))
                     (set! points-i (cons (cons    (car X-ext)             cnt                 ) points-i))
                     )
                 (if (and (> (+ cnt (/ stepLeft 2)) yLowerLimit) (< (+ cnt (/ stepLeft 2)) yUpperLimit))
                     (set! points-i (cons (cons (- (car X-ext) l-width) (+ cnt (/ stepLeft 2)) ) points-i))
                     )
                 (loop (+ cnt stepLeft))
                 )
                )
            )
          )
         )

     ; insert upper-left corner (yes, AFTER the zigzag points, so all the points will be given in clockwise order):
     (if (not
          (and (and (not open-on-left) (> stepLeft 0)) (eq? slope-upper 1))
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
         (if (> stepRight 0)
             (if (not (eq? slope-upper -1))
                 (begin
                  (set! jumps 0)
                  (while (<
                          (+ (- (* slope-upper (- h-thick)) d-upper) (* jumps stepRight))
                          (- stepRight))
                    (set! jumps (+ jumps 1)))
                  (set! xtemp (/ (- d-upper (+ h-thick (* jumps stepRight))) (+ slope-upper 1)))
                  (if (> xtemp (- (/ stepRight 2) h-thick  ))
                      (if (= 1 slope-upper)
                          (set! xtemp (- h-thick))
                          (set! xtemp
                                (/ (- (- (* stepRight (+ 1 jumps)) d-upper) h-thick) (- 1 slope-upper)))
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
          (and (and (not open-on-right) (> stepRight 0)) (eq? slope-upper -1)))
         (begin
          (set! points-i (cons (cons xp yp) points-i))
          (set! yUpperLimit yp)))

     ; calculate lower-right corner:
     (if open-on-right
         (begin
          (set! xp (cdr X-ext))
          (set! yp (+ y-r-lower d-lower))
          )
         (if (> stepRight 0)
             (if (not (eq? slope-lower 1))
                 (begin
                  (set! jumps 0)
                  (while (> (- (- d-lower (* slope-lower h-thick)) (* jumps stepRight)) stepRight)
                    (set! jumps (+ 1 jumps)))
                  (set! xtemp (/ (- (+ h-thick (* jumps stepRight)) d-lower) (- slope-lower 1)))
                  (if (> xtemp (- (/ stepRight 2) h-thick)   )
                      (if (= -1 slope-lower)
                          (set! xtemp (- h-thick))
                          (set! xtemp
                                (/ (+ (- d-lower (* stepRight (+ 1 jumps))) h-thick) (- -1 slope-lower)))))
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

     (if (not (and (and (not open-on-right) (> stepRight 0)) (eq? slope-lower 1)))
         (set! yLowerLimit yp))

     ; right zigzag:
     (if (and (> stepRight 0) (not open-on-right))
         (begin
          (let loop ((cnt y-r-upper))
            (if (> cnt y-r-lower)
                (begin
                 (if (and (> cnt yLowerLimit) (< cnt yUpperLimit))
                     (set! points-i (cons (cons    (cdr X-ext)             cnt                  ) points-i)))
                 (if (and (> (- cnt (/ stepRight 2)) yLowerLimit) (< (- cnt (/ stepRight 2)) yUpperLimit))
                     (set! points-i (cons (cons (+ (cdr X-ext) r-width) (- cnt (/ stepRight 2)) ) points-i)))
                 (loop (- cnt stepRight))
                 )
                )
            )
          )
         )

     ; insert lower-right corner:
     (if (not (and (and (not open-on-right) (> stepRight 0)) (eq? slope-lower 1)))
         (set! points-i (cons (cons xp yp) points-i)))

     (ly:stencil-add
      ; draw outer polygon:
      (if (color? frame-color)  ; only add stencil if set to a valid color (could also be set to ##f)
          (ly:make-stencil (list 'color frame-color
                             (ly:stencil-expr (ly:round-filled-polygon points radius))
                             X-ext Y-ext))
          empty-stencil)
      ; draw inner polygon:
      (if (color? fill-color)   ; only add stencil if set to a valid color (could also be set to ##f)
          (ly:make-stencil (list 'color fill-color
                             (ly:stencil-expr (ly:round-filled-polygon points-i radius))
                             X-ext Y-ext))
          empty-stencil)
      )
     )
   )

% The following music functions will use makeDeltaSpan:

#(define (get-properties grob)
   (let*
    ((area (ly:horizontal-bracket::print grob))
     (thick (ly:grob-property grob 'line-thickness 1))
     (pad (ly:grob-property grob 'broken-bound-padding 0))
     (radius (ly:grob-property grob 'hair-thickness 0))
     (X-ext-param (ly:stencil-extent area X))
     (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
     (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
     )
    `((area . ,area)
      (thick . ,thick)
      (pad . ,pad)
      (radius . ,radius)
      (X-ext-param . ,X-ext-param)
      (open-on-left . ,open-on-left)
      (open-on-right . ,open-on-right))
    ))

genericSpan =
#(define-music-function (y-l-lower y-l-upper y-r-lower y-r-upper frame-color fill-color stepLeft stepRight open-on-bottom open-on-top)
   (number? number? number? number? scheme? scheme? number? number? boolean? boolean?)
   ; Calling this procedure IMMEDIATELY before \startGroup will replace the stencil of HorizontalBracket.
   ; Some parameters are taken out of HorizontalBracket's properties
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let*
         ((props (get-properties grob)))
          (makeDeltaSpan
           y-l-lower y-l-upper y-r-lower y-r-upper
           frame-color fill-color
           stepLeft stepRight
           (assq-ref props 'open-on-bottom)
           (assq-ref props 'open-on-top)
           (assq-ref props 'thick)
           (assq-ref props 'pad)
           (assq-ref props 'X-ext-param)
           (assq-ref props 'open-on-left)
           (assq-ref props 'open-on-right)
           (assq-ref props 'radius))
          ))
     \once\override HorizontalBracket.Y-offset = #0
   #})

roundedRectangleSpan =
#(define-music-function (y-lower y-upper frame-color fill-color radius)
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
                (if (color? frame-color)
                    (ly:make-stencil (list 'color frame-color
                                       (ly:stencil-expr (ly:round-filled-box X-ext Y-ext radius))
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
           (if (color? fill-color)
               (ly:make-stencil (list 'color fill-color
                                  (ly:stencil-expr (ly:round-filled-box X-ext Y-ext (- radius thick)))
                                  X-ext Y-ext))
               empty-stencil)
           )
          ))
     \once\override HorizontalBracket.Y-offset = #0
     %\once\override HorizontalBracket.shorten-pair = #'(-0.6 . -0.6)
   #})

tornSpan = #(define-music-function (y-lower y-upper frame-color fill-color stepLeft stepRight)
              (number? number? scheme? scheme? number? number?)
              #{  \genericSpan $y-lower $y-upper $y-lower $y-upper $frame-color $fill-color $stepLeft $stepRight ##f ##f  #})


% Here are some functions with pre-defined zigzag edges at the left / right / at both sides.
% They read out the property HorizontalBracket.zigzag-width and automatically round it to the nearest sensible value

leftZZSpan =
#(define-music-function (y-lower y-upper frame-color fill-color)
   (number? number? scheme? scheme?)
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* ((area (ly:horizontal-bracket::print grob))
               (thick (ly:grob-property grob 'line-thickness 1))
               (pad (ly:grob-property grob 'broken-bound-padding 0))
               (radius (ly:grob-property grob 'hair-thickness 0))
               (X-ext-param (ly:stencil-extent area X))
               (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
               (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
               (stepLeft (ly:grob-property grob 'zigzag-width 1.5))
               (dist-y (- y-upper y-lower))
               (cnt 1)
               )
          (if (not (= stepLeft 0))
              (begin
               (set! cnt (round (/ dist-y stepLeft)))  ; calculate number of zigzags, round to nearest integer
               (if (> cnt 0)
                   (set! stepLeft (/ dist-y cnt))       ; calculate exact zigzag size
                   (set! stepLeft 0))))
          (makeDeltaSpan  y-lower y-upper (+ 0 y-lower) (+ 0 y-upper) frame-color fill-color stepLeft 0 #f #f
            thick pad X-ext-param open-on-left open-on-right radius)))
     \once\override HorizontalBracket.Y-offset = #0
   #})

rightZZSpan =
#(define-music-function (y-lower y-upper frame-color fill-color)
   (number? number? scheme? scheme?)
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* ((area (ly:horizontal-bracket::print grob))
               (thick (ly:grob-property grob 'line-thickness 1))
               (pad (ly:grob-property grob 'broken-bound-padding 0))
               (radius (ly:grob-property grob 'hair-thickness 0))
               (X-ext-param (ly:stencil-extent area X))
               (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
               (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
               (stepRight (ly:grob-property grob 'zigzag-width 1.5))
               (dist-y (- y-upper y-lower))
               (cnt 1)
               )
          (if (not (= stepRight 0))
              (begin
               (set! cnt (round (/ dist-y stepRight)))
               (if (> cnt 0)
                   (set! stepRight (/ dist-y cnt))
                   (set! stepRight 0))))
          (makeDeltaSpan  y-lower y-upper (+ 0 y-lower) (+ 0 y-upper) frame-color fill-color 0 stepRight #f #f
            thick pad X-ext-param open-on-left open-on-right radius)))
     \once\override HorizontalBracket.Y-offset = #0
   #})

ZZSpan =
#(define-music-function (y-lower y-upper frame-color fill-color)
   (number? number? scheme? scheme?)
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* ((area (ly:horizontal-bracket::print grob))
               (thick (ly:grob-property grob 'line-thickness 1))
               (pad (ly:grob-property grob 'broken-bound-padding 0))
               (radius (ly:grob-property grob 'hair-thickness 0))
               (X-ext-param (ly:stencil-extent area X))
               (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
               (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
               (stepLeft (ly:grob-property grob 'zigzag-width 1.5))
               (stepRight (ly:grob-property grob 'zigzag-width 1.5))
               (dist-y (- y-upper y-lower))
               (cnt 1)
               )
          (if (not (= stepLeft 0))
              (begin
               (set! cnt (round (/ dist-y stepLeft)))
               (if (> cnt 0)
                   (set! stepLeft (/ dist-y cnt))
                   (set! stepLeft 0))))
          (if (not (= stepRight 0))
              (begin
               (set! cnt (round (/ dist-y stepRight)))
               (if (> cnt 0)
                   (set! stepRight (/ dist-y cnt))
                   (set! stepRight 0))))
          (makeDeltaSpan  y-lower y-upper (+ 0 y-lower) (+ 0 y-upper) frame-color fill-color stepLeft stepRight #f #f
            thick pad X-ext-param open-on-left open-on-right radius)))
     \once\override HorizontalBracket.Y-offset = #0
   #})

tornDYSpan = #(define-music-function (y-l-lower y-l-upper y-r-lower y-r-upper frame-color fill-color stepLeft stepRight)
                (number? number? number? number? scheme? scheme? number? number?)
                #{  \genericSpan $y-l-lower $y-l-upper $y-r-lower $y-r-upper $frame-color $fill-color $stepLeft $stepRight ##f ##f  #})

DYSpan = #(define-music-function (y-l-lower y-l-upper y-r-lower y-r-upper frame-color fill-color)
            (number? number? number? number? scheme? scheme?)
            #{  \genericSpan $y-l-lower $y-l-upper $y-r-lower $y-r-upper $frame-color $fill-color #0 #0 ##f ##f  #})

colorSpan = #(define-music-function (y-lower y-upper fill-color)
               (number? number? scheme?)
               #{  \genericSpan $y-lower $y-upper $y-lower $y-upper ##f $fill-color #0 #0 ##f ##f  #})

framedSpan = #(define-music-function (y-lower y-upper frame-color fill-color)
                (number? number? scheme? scheme?)
                #{  \genericSpan $y-lower $y-upper $y-lower $y-upper $frame-color $fill-color #0 #0 ##f ##f  #})

roundRectSpan = #(define-music-function (y-lower y-upper frame-color fill-color radius)
                   (number? number? scheme? scheme? number?)
                   #{  \roundedRectangleSpan $y-lower $y-upper $frame-color $fill-color $radius  #})


% The following is pretty much the same thing as makeDeltaSpan, but it will only produce a frame that won't be filled.
% The lower, upper, left and right edge will each be drawn as a separate polygon.

#(define (makeDeltaFrame
          y-l-lower y-l-upper         ; number: Y-dimensions (left edge)
          y-r-lower y-r-upper         ; number: Y-dimensions (right edge)
          frame-color                 ; frame color (if set to ##f, no frame will be drawn)
          stepLeft stepRight          ; number: size of zigzag elements for left and right edge (vertical edge / no zigzag if set to zero)
          open-on-bottom open-on-top  ; boolean: if set to #t, lower resp. upper edge won't be drawn
          thick                       ; number: frame thickness - if set to zero, no frame will be drawn
          pad                         ; number: broken-bound-padding - amount to shorten spanners where separated by a line break (negative values can be used for lengthening)
          X-ext-param                 ; pair: the spanner's X-dimensions
          open-on-left open-on-right  ; boolean: if set to #t, left resp. right edge won't be drawn
          ;   We'll assume that this indicates a line break!
          )

   (let* (
           (h-thick (* thick (sqrt 2)))  ; X-distance between left and right edges of inner and outer polygon. Must be "thick" * sqrt 2  (Pythagoras)
           (l-width (* stepLeft  0.5))   ; X-distance of zigzag corners
           (r-width (* stepRight 0.5))
           (Y-ext (cons 0 0))            ; dummy, needed for ly:stencil-expr  (is there a way without it?)
           (X-ext (cons
                   (if (> stepLeft 0)    ; left edge has zigzag shape
                       (- (+ (car X-ext-param) (/ l-width 2)) h-thick)  ; Half of the zigzag space will be taken from inside, other half from the outside. Frame space taken from outside.
                       (if open-on-left  (- (car X-ext-param) h-thick) (- (car X-ext-param) thick))
                       )
                   (if (> stepRight 0)   ; right edge has zigzag shape
                       (+ (- (cdr X-ext-param) (/ r-width 2)) h-thick)
                       (if open-on-right (+ (cdr X-ext-param) h-thick) (+ (cdr X-ext-param) thick))
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
     (if (and (> stepLeft 0) (not open-on-left))
         (let loop ((cnt y-l-lower))
           (if (< cnt y-l-upper)
               (begin
                (if (and (< cnt y-l-upper) (> cnt y-l-lower))  ; only add to list if point is inside the given Y-range
                    (set! points-l (cons (cons    (car X-ext)             cnt                 ) points-l)))
                (if (and (< (+ cnt (/ stepLeft 2)) y-l-upper) (> (+ cnt (/ stepLeft 2)) y-l-lower))
                    (set! points-l (cons (cons (- (car X-ext) l-width) (+ cnt (/ stepLeft 2)) ) points-l)))
                (loop (+ cnt stepLeft))))))

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
     (if (and (> stepRight 0) (not open-on-right))
         (let loop ((cnt y-r-upper))
           (if (> cnt y-r-lower)
               (begin
                (if (and (< cnt y-r-upper) (> cnt y-r-lower))
                    (set! points-r (cons (cons    (cdr X-ext)             cnt                  ) points-r)))
                (if (and (< (- cnt (/ stepRight 2)) y-r-upper) (> (- cnt (/ stepRight 2)) y-r-lower))
                    (set! points-r (cons (cons (+ (cdr X-ext) r-width) (- cnt (/ stepRight 2)) ) points-r)))
                (loop (- cnt stepRight))))))

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
         (if (> stepLeft 0)
             (set! X-ext (cons (+ (car X-ext) h-thick) (cdr X-ext)))
             (set! X-ext (cons (+ (car X-ext)   thick) (cdr X-ext)))
             )
         )
     (if (not open-on-right)
         (if (> stepRight 0)
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
         (if (> stepLeft 0)
             (if (not (eq? slope-upper 1))
                 (begin
                  (set! jumps 0)
                  (while (<
                          (+ (- (* slope-upper h-thick) d-upper) (* jumps stepLeft))
                          (- stepLeft))
                    (set! jumps (+ jumps 1)))
                  (set! xtemp (/ (- d-upper (+ h-thick (* jumps stepLeft))) (- slope-upper 1)))
                  (if (< xtemp (- h-thick (/ stepLeft 2)))
                      (if (= -1 slope-upper)
                          (set! xtemp h-thick)
                          (set! xtemp
                                (/ (- (- (* stepLeft (+ 1 jumps)) d-upper) h-thick) (- (- 1) slope-upper)))
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
          (and (and (not open-on-left) (> stepLeft 0)) (eq? slope-upper 1))
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
         (if (> stepLeft 0)
             (if (not (eq? slope-lower -1))
                 (begin
                  (set! jumps 0)
                  (while (> (- (+ (* slope-lower h-thick) d-lower) (* jumps stepLeft)) stepLeft)
                    (set! jumps (+ 1 jumps)))
                  (set! xtemp (/ (- (+ h-thick (* jumps stepLeft)) d-lower) (+ slope-lower 1)))
                  ; results from the solution for a system of two equations. Forgive me, I'm a maths teacher :-)
                  (if (< xtemp (- h-thick (/ stepLeft 2)))
                      (if (= 1 slope-lower)
                          (set! xtemp h-thick)
                          (set! xtemp
                                (/ (+ (- d-lower (* stepLeft (+ 1 jumps))) h-thick) (- 1 slope-lower)))))  ; another system of 2 equations...
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

     (if (not (and (and (not open-on-left) (> stepLeft 0)) (eq? slope-lower -1)))
         (set! yLowerLimit yp)
         )

     ; left (inner) zigzag:
     (if (and (> stepLeft 0) (not open-on-left))
         (begin
          (let loop ((cnt y-l-upper))
            (if (> cnt y-l-lower)
                (begin
                 (if (and (> cnt yLowerLimit) (< cnt yUpperLimit))
                     (set! points-l (cons (cons    (car X-ext)             cnt                 ) points-l))
                     )
                 (if (and (> (- cnt (/ stepLeft 2)) yLowerLimit) (< (- cnt (/ stepLeft 2)) yUpperLimit))
                     (set! points-l (cons (cons (- (car X-ext) l-width) (- cnt (/ stepLeft 2)) ) points-l))
                     )
                 (loop (- cnt stepLeft))
                 )
                )
            )
          )
         )

     ; insert lower-left corner (yes, AFTER the zigzag points, so all the points will be given in clockwise order):
     (if (not (and (and (not open-on-left) (> stepLeft 0)) (eq? slope-lower -1)))
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
         (if (> stepRight 0)
             (if (not (eq? slope-lower 1))
                 (begin
                  (set! jumps 0)
                  (while (> (- (- d-lower (* slope-lower h-thick)) (* jumps stepRight)) stepRight)
                    (set! jumps (+ 1 jumps)))
                  (set! xtemp (/ (- (+ h-thick (* jumps stepRight)) d-lower) (- slope-lower 1)))
                  (if (> xtemp (- (/ stepRight 2) h-thick)   )
                      (if (= -1 slope-lower)
                          (set! xtemp (- h-thick))
                          (set! xtemp
                                (/ (+ (- d-lower (* stepRight (+ 1 jumps))) h-thick) (- -1 slope-lower)))))
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
     (if (not (and (and (not open-on-right) (> stepRight 0)) (eq? slope-lower 1)))
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
         (if (> stepRight 0)
             (if (not (eq? slope-upper -1))
                 (begin
                  (set! jumps 0)
                  (while (<
                          (+ (- (* slope-upper (- h-thick)) d-upper) (* jumps stepRight))
                          (- stepRight))
                    (set! jumps (+ jumps 1)))
                  (set! xtemp (/ (- d-upper (+ h-thick (* jumps stepRight))) (+ slope-upper 1)))
                  (if (> xtemp (- (/ stepRight 2) h-thick  ))
                      (if (= 1 slope-upper)
                          (set! xtemp (- h-thick))
                          (set! xtemp
                                (/ (- (- (* stepRight (+ 1 jumps)) d-upper) h-thick) (- 1 slope-upper)))
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
          (and (and (not open-on-right) (> stepRight 0)) (eq? slope-upper -1)))
         (set! yUpperLimit yp))

     ; right zigzag:
     (if (and (> stepRight 0) (not open-on-right))
         (begin
          (let loop ((cnt y-r-lower))
            (if (< cnt y-r-upper)
                (begin
                 (if (and (> cnt yLowerLimit) (< cnt yUpperLimit))
                     (begin
                      (set! points-r (cons (cons    (cdr X-ext)             cnt                  ) points-r))
                      ))
                 (if (and (> (+ cnt (/ stepRight 2)) yLowerLimit) (< (+ cnt (/ stepRight 2)) yUpperLimit))
                     (begin
                      (set! points-r (cons (cons (+ (cdr X-ext) r-width) (+ cnt (/ stepRight 2)) ) points-r))
                      ))
                 (loop (+ cnt stepRight))
                 )
                )
            )
          )
         )

     ; insert upper-right corner:
     (if (not
          (and (and (not open-on-right) (> stepRight 0)) (eq? slope-upper -1)))
         (set! points-r (cons (cons xp yp) points-r)))


     (ly:stencil-add
      ; draw upper edge:
      (if (and (and (> thick 0) (not open-on-top)) (color? frame-color))
          (ly:make-stencil (list 'color frame-color
                             (ly:stencil-expr (ly:round-filled-polygon points-up 0))
                             X-ext Y-ext))
          empty-stencil)
      ; draw lower edge:
      (if (and (and (> thick 0) (not open-on-bottom)) (color? frame-color))
          (ly:make-stencil (list 'color frame-color
                             (ly:stencil-expr (ly:round-filled-polygon points-lo 0))
                             X-ext Y-ext))
          empty-stencil)
      ; draw left edge:
      (if (and (and (> thick 0) (not open-on-left)) (color? frame-color))
          (ly:make-stencil (list 'color frame-color
                             (ly:stencil-expr (ly:round-filled-polygon points-l 0))
                             X-ext Y-ext))
          empty-stencil)
      ; draw right edge:
      (if (and (and (> thick 0) (not open-on-right)) (color? frame-color))
          (ly:make-stencil (list 'color frame-color
                             (ly:stencil-expr (ly:round-filled-polygon points-r 0))
                             X-ext Y-ext))
          empty-stencil)
      )
     )
   )

% The following music functions will use the above makeDeltaFrame:

genericFrame =
#(define-music-function (y-l-lower y-l-upper y-r-lower y-r-upper frame-color stepLeft stepRight open-on-bottom open-on-top)
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
                (X-ext-param (ly:stencil-extent area X))
                (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
                (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
                )
          (makeDeltaFrame  y-l-lower y-l-upper y-r-lower y-r-upper frame-color stepLeft stepRight open-on-bottom open-on-top
            thick pad X-ext-param open-on-left open-on-right)
          ))
     \once\override HorizontalBracket.Y-offset = #0
   #})


tornFrame = #(define-music-function (y-lower y-upper frame-color stepLeft stepRight)
               (number? number? scheme? number? number?)
               #{  \genericFrame $y-lower $y-upper $y-lower $y-upper $frame-color $stepLeft $stepRight ##f ##f  #})


% Here are some functions with pre-defined zigzag edges at the left / right / at both sides.
% They read out the property HorizontalBracket.zigzag-width and automatically round it to the nearest sensible value

leftZZFrame =
#(define-music-function (y-lower y-upper frame-color)
   (number? number? scheme?)
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* ((area (ly:horizontal-bracket::print grob))
               (thick (ly:grob-property grob 'line-thickness 1))
               (pad (ly:grob-property grob 'broken-bound-padding 0))
               (X-ext-param (ly:stencil-extent area X))
               (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
               (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
               (stepLeft (ly:grob-property grob 'zigzag-width 1.5))
               (dist-y (- y-upper y-lower))
               (cnt 1)
               )
          (if (not (= stepLeft 0))
              (begin
               (set! cnt (round (/ dist-y stepLeft)))  ; calculate number of zigzags, round to nearest integer
               (if (> cnt 0)
                   (set! stepLeft (/ dist-y cnt))       ; calculate exact zigzag size
                   (set! stepLeft 0))))
          (makeDeltaFrame  y-lower y-upper (+ 0 y-lower) (+ 0 y-upper) frame-color stepLeft 0 #f #f
            thick pad X-ext-param open-on-left open-on-right)))
     \once\override HorizontalBracket.Y-offset = #0
   #})

rightZZFrame =
#(define-music-function (y-lower y-upper frame-color)
   (number? number? scheme?)
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* ((area (ly:horizontal-bracket::print grob))
               (thick (ly:grob-property grob 'line-thickness 1))
               (pad (ly:grob-property grob 'broken-bound-padding 0))
               (X-ext-param (ly:stencil-extent area X))
               (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
               (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
               (stepRight (ly:grob-property grob 'zigzag-width 1.5))
               (dist-y (- y-upper y-lower))
               (cnt 1)
               )
          (if (not (= stepRight 0))
              (begin
               (set! cnt (round (/ dist-y stepRight)))
               (if (> cnt 0)
                   (set! stepRight (/ dist-y cnt))
                   (set! stepRight 0))))
          (makeDeltaFrame  y-lower y-upper (+ 0 y-lower) (+ 0 y-upper) frame-color 0 stepRight #f #f
            thick pad X-ext-param open-on-left open-on-right)))
     \once\override HorizontalBracket.Y-offset = #0
   #})

ZZFrame =
#(define-music-function (y-lower y-upper frame-color)
   (number? number? scheme?)
   #{
     \once\override HorizontalBracket.stencil =
     $(lambda (grob)
        (let* ((area (ly:horizontal-bracket::print grob))
               (thick (ly:grob-property grob 'line-thickness 1))
               (pad (ly:grob-property grob 'broken-bound-padding 0))
               (X-ext-param (ly:stencil-extent area X))
               (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
               (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT))))
               (stepLeft (ly:grob-property grob 'zigzag-width 1.5))
               (stepRight (ly:grob-property grob 'zigzag-width 1.5))
               (dist-y (- y-upper y-lower))
               (cnt 1)
               )
          (if (not (= stepLeft 0))
              (begin
               (set! cnt (round (/ dist-y stepLeft)))
               (if (> cnt 0)
                   (set! stepLeft (/ dist-y cnt))
                   (set! stepLeft 0))))
          (if (not (= stepRight 0))
              (begin
               (set! cnt (round (/ dist-y stepRight)))
               (if (> cnt 0)
                   (set! stepRight (/ dist-y cnt))
                   (set! stepRight 0))))
          (makeDeltaFrame  y-lower y-upper (+ 0 y-lower) (+ 0 y-upper) frame-color stepLeft stepRight #f #f
            thick pad X-ext-param open-on-left open-on-right)))
     \once\override HorizontalBracket.Y-offset = #0
   #})

tornDYFrame = #(define-music-function (y-l-lower y-l-upper y-r-lower y-r-upper frame-color stepLeft stepRight)
                 (number? number? number? number? scheme? number? number?)
                 #{  \genericFrame $y-l-lower $y-l-upper $y-r-lower $y-r-upper $frame-color $stepLeft $stepRight ##f ##f  #})

DYFrame = #(define-music-function (y-l-lower y-l-upper y-r-lower y-r-upper frame-color)
             (number? number? number? number? scheme?)
             #{  \genericFrame $y-l-lower $y-l-upper $y-r-lower $y-r-upper $frame-color #0 #0 ##f ##f  #})

colorFrame = #(define-music-function (y-lower y-upper frame-color)
                (number? number? scheme? scheme?)
                #{  \genericFrame $y-lower $y-upper $y-lower $y-upper $frame-color #0 #0 ##f ##f  #})



#(define-markup-command (on-color layout props color arg) (color? markup?)
   (let* ((stencil (interpret-markup layout props arg))
          (X-ext (ly:stencil-extent stencil X))
          (Y-ext (ly:stencil-extent stencil Y)))
     (ly:stencil-add (ly:make-stencil
                      (list 'color color
                        (ly:stencil-expr (ly:round-filled-box X-ext Y-ext 0))
                        X-ext Y-ext)) stencil)))

#(define-markup-command (sticker layout props frame-color fill-color arg) (color? color? markup?)
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
       (car Y-ext) (cdr Y-ext) (car Y-ext) (cdr Y-ext) frame-color fill-color
       step step #f #f 0.1 ; thick
       0 X-ext #f #f 0)
      stencil)))
