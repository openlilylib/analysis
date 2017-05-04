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

% --------------------------------------------------------------------------
%    Frames and Rectangles
% --------------------------------------------------------------------------

% Define configuration variables and set defaults

\registerOption analysis.frames.border-width 0.25
\registerOption analysis.frames.padding 0
\registerOption analysis.frames.broken-bound-padding 4
\registerOption analysis.frames.border-radius 0.5
\registerOption analysis.frames.shorten-pair #'(0 . 0)
\registerOption analysis.frames.y-lower -4
\registerOption analysis.frames.y-upper 4
\registerOption analysis.frames.l-zigzag-width 0
\registerOption analysis.frames.r-zigzag-width 0
\registerOption analysis.frames.open-on-bottom ##f
\registerOption analysis.frames.open-on-top ##f
\registerOption analysis.frames.layer -10
\registerOption analysis.frames.border-color #(rgb-color 0.3  0.3  0.9)
\registerOption analysis.frames.color #(rgb-color 0.8  0.8  1.0)
\registerOption analysis.frames.hide "none"
\registerOption analysis.frames.angle 0



#(define (get-live-properties grob)
   "Return the properties that have to be retrieved from the actual grob"
   (let*
    ((frame-X-extent (ly:stencil-extent (ly:horizontal-bracket::print grob) X))
     (open-on-left  (=  1 (ly:item-break-dir (ly:spanner-bound grob LEFT ))))
     (open-on-right (= -1 (ly:item-break-dir (ly:spanner-bound grob RIGHT)))))
    `((frame-X-extent . ,frame-X-extent)
      (open-on-left . ,open-on-left)
      (open-on-right . ,open-on-right))))

#(define (make-frame-stencil grob props)
   "Create the actual frame stencil using both live and configuration props."
   (let*
    ;; make properties available
    ((live-props (get-live-properties grob))
     (frame-angle (assq-ref props 'frame-angle))
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
     (border-width (assq-ref props 'border-width))
     (padding (assq-ref props 'padding))
     (bb-pad (assq-ref props 'broken-bound-padding))
     (frame-X-extent (assq-ref live-props 'frame-X-extent))
     (open-on-left (assq-ref live-props 'open-on-left))
     (open-on-right (assq-ref live-props 'open-on-right))

     ;; start calculations
           (h-border-width (* border-width (sqrt 2)))  ; X-distance between left and right edges of inner and outer polygon. Must be "border-width" * sqrt 2  (Pythagoras)
           (l-width (* l-zigzag-width  0.5))   ; X-distance of zigzag corners
           (r-width (* r-zigzag-width 0.5))
           (Y-ext (cons 0 0))            ; dummy, needed for ly:stencil-expr  (is there a way without it?)
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
           (points (list))       ; will contain coordinates for outer polygon
           (points-i (list))     ; will contain coordinates for inner polygon
           (slope-upper (/ (- y-r-upper y-l-upper) (- (cdr X-ext) (car X-ext))))  ; slope of the polygon's upper edge

           (slope-lower (/ (- y-r-lower y-l-lower) (- (cdr X-ext) (car X-ext))))  ; slope of the polygon's lower edge
           (d-upper (if open-on-top    0  (* border-width (sqrt (+ (expt slope-upper 2) 1)))))  ; (Pythagoras)
           ; Y-distance between upper edges of inner and outer polygon. Equal to "border-width" if upper edge is horizontal.
           ; Increases as the upper edge's slope increases.
           (d-lower (if open-on-bottom 0  (* border-width (sqrt (+ (expt slope-lower 2) 1)))))  ; same for lower edge
           ; stuff for later calculations:
           (xtemp 0)
           (yLowerLimit 0)
           (yUpperLimit 0)
           (xp 0)
           (yp 0)
           (jumps 0)
           )

    ;; set grob properties that can be set from within the stencil callback
    (ly:grob-set-property! grob 'layer layer)
    (ly:grob-set-property! grob 'Y-offset 0)

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












#(define (get-frame-properties ctx-mod)
   "Process the frame's options.
    All properties are initially populated with (default) values
    of the corresponding options and may be overridden with values
    from the actual frame's \\with clause."
   (let*
    ((props (if ctx-mod
                (context-mod->props ctx-mod)
                '()))
     (frame-angle
      (or (assq-ref props 'angle)
          (getOption '(analysis frames angle))))
     (border-width
      (or (assq-ref props 'border-width)
          (getOption '(analysis frames border-width))))
     (padding
      (or (assq-ref props 'padding)
          (getOption '(analysis frames padding))))
     (broken-bound-padding
      (* -1
        (or (assq-ref props 'broken-bound-padding)
            (getOption '(analysis frames broken-bound-padding)))))
     (border-radius
      (or (assq-ref props 'border-radius)
          (getOption '(analysis frames border-radius))))
     (shorten-pair
      (let*
       ((sp
         (or (assq-ref props 'shorten-pair)
             (getOption '(analysis frames shorten-pair)))))
       (if (pair? sp)
           sp (cons sp sp))))
     (y-lower
      (or (assq-ref props 'y-lower)
          (getOption '(analysis frames y-lower))))
     (y-upper
      (or (assq-ref props 'y-upper)
          (getOption '(analysis frames y-upper))))
     (y-l-lower
      (if (number? y-lower) y-lower (car y-lower)))
     (y-r-lower
      (if (number? y-lower) y-lower (cdr y-lower)))
     (y-l-upper
      (if (number? y-upper) y-upper (car y-upper)))
     (y-r-upper
      (if (number? y-upper) y-upper (cdr y-upper)))
     (l-zigzag-width
      (or (assq-ref props 'l-zigzag-width)
          (getOption '(analysis frames l-zigzag-width))))
     (r-zigzag-width
      (or (assq-ref props 'r-zigzag-width)
          (getOption '(analysis frames r-zigzag-width))))
     (open-on-bottom
      (or (assq-ref props 'open-on-bottom)
          (getOption '(analysis frames open-on-bottom))))
     (open-on-top
      (or (assq-ref props 'open-on-top)
          (getOption '(analysis frames open-on-top))))
     (layer
      (or (assq-ref props 'layer)
          (getOption '(analysis frames layer))))
     (border-color
      (let ((col (assq 'border-color props)))
        (if col (cdr col) (getOption '(analysis frames border-color)))))
     (color
      (let*
       ((prop-col (assq 'color props)))
       (if prop-col
           (cdr prop-col)
           (getOption '(analysis frames color)))))
     (hide 
      (let ((col (assq 'hide props)))
        (if col 
            (string->symbol (cdr col)) 
            (string->symbol (getOption '(analysis frames hide))))))
     )
    `((border-width . ,border-width)
      (padding . ,padding)
      (broken-bound-padding . ,broken-bound-padding)
      (border-radius . ,border-radius)
      (shorten-pair . ,shorten-pair)
      (y-l-lower . ,y-l-lower)
      (y-l-upper . ,y-l-upper)
      (y-r-lower . ,y-r-lower)
      (y-r-upper . ,y-r-upper)
      (l-zigzag-width . ,l-zigzag-width)
      (r-zigzag-width . ,r-zigzag-width)
      (open-on-bottom . ,open-on-bottom)
      (open-on-top . ,open-on-top)
      (layer . ,layer)
      (border-color . ,border-color)
      (color . ,color)
      (hide . ,hide)
      )))

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
#(define-music-function (properties mus)
   ((ly:context-mod?) ly:music?)
   (let*
    ((props (get-frame-properties properties))
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
             \temporary \override Stem.layer = 2
             \temporary \override Beam.layer = 2
             \temporary \override Flag.layer = 2
             \temporary \override Rest.layer = 2
             \temporary \override Accidental.layer = 2
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



#(define-markup-command (on-color layout props color arg) (color? markup?)
   (let* ((stencil (interpret-markup layout props arg))
          (X-ext (ly:stencil-extent stencil X))
          (Y-ext (ly:stencil-extent stencil Y)))
     (ly:stencil-add (ly:make-stencil
                      (list 'color color
                        (ly:stencil-expr (ly:round-filled-box X-ext Y-ext 0))
                        X-ext Y-ext)) stencil)))

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
