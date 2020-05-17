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

\registerOption analysis.highlighters.color #green
\registerOption analysis.highlighters.thickness #1.0
\registerOption analysis.highlighters.layer #-5
\registerOption analysis.highlighters.X-offset #0.6
\registerOption analysis.highlighters.offset-first #-1.2
\registerOption analysis.highlighters.offset-last #1.2


#(define (get-highlighter-properties ctx-mod)
   "Process the highlighter's options.
    All properties are initially populated with (default) values
    of the corresponding options and may be overridden with values
    from the actual highlighter's \\with clause."
   (let*
    (
      (props (if ctx-mod
                 (context-mod->props ctx-mod)
                 '()))
      (color
       (let*
        ((prop-col (assq 'color props)))
        (if prop-col
            (cdr prop-col)
            (getOption '(analysis highlighters color)))))
      
      (thickness
       (or (assq-ref props 'thickness)
           (getOption '(analysis highlighters thickness))))
      (layer
       (or (assq-ref props 'layer)
           (getOption '(analysis highlighters layer))))
      (X-offset
       (or (assq-ref props 'X-offset)
           (getOption '(analysis highlighters X-offset))))
      (offset-first
       (or (assq-ref props 'offset-first)
           (getOption '(analysis highlighters offset-first))))
      (offset-last
       (or (assq-ref props 'offset-last)
           (getOption '(analysis highlighters offset-last))))
      )
    `(
       (color . ,color)
       (thickness . ,thickness)
       (layer . ,layer)
       (X-offset . ,X-offset)
       (offset-first . ,offset-first)
       (offset-last . ,offset-last)
       )
    )
   )


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


highlight =
#(define-music-function (properties mus)
   ((ly:context-mod?) ly:music?)
   ;; http://lilypond.1069038.n5.nabble.com/Apply-event-function-within-music-function-tp202841p202847.html
   (let* 
    (
      (props (get-highlighter-properties properties))
      (mus-elts (ly:music-property mus 'elements))
      ; last music-element:
      (lst (last mus-elts)) ; TODO test for list? and ly:music?
      ; length of entire music expression "mus":
      (len (ly:music-length mus))
      ; length of last element only:
      (last-skip (ly:music-length lst))
      ; difference = length of "mus" except the last element:
      (first-skip (ly:moment-sub len last-skip))
      (color (assq-ref props 'color))
      (thickness (assq-ref props 'thickness))
      (layer (assq-ref props 'layer))
      (X-offset (assq-ref props 'X-offset))
      (offset-first (assq-ref props 'offset-first))
      (offset-last (assq-ref props 'offset-last))
      )
    ;; (display "---- len: ")
    ;; (display len)
    ;; (display "  ----  last-skip: ")
    ;; (display last-skip)
    ;; (display "  ----  first-skip: ")
    ;; (display first-skip)
    ;; (display "\n")
    ;; (display (custom-moment->duration first-skip))
    (make-relative (mus) mus  ;; see http://lilypond.1069038.n5.nabble.com/Current-octave-in-relative-mode-tp232869p232870.html  (thanks, David!)
      #{
        <<
          $mus
          % \new Voice
          \makeClusters {
            \once \override ClusterSpanner.color = $color
            \once \override ClusterSpanner.padding = $thickness
            \once \override ClusterSpanner.layer = $layer
            \once \override ClusterSpanner.X-offset = $X-offset
            \once \override ClusterSpannerBeacon.X-offset = $offset-first
            <<
              $mus
              {
                % skip until last element starts:
                #(if (not (equal? first-skip (ly:make-moment 0/1 0/1))) ; skip with zero length would cause error
                     (make-music 'SkipEvent 'duration (custom-moment->duration first-skip)))
                \once \override ClusterSpannerBeacon.X-offset = $offset-last
              }
            >>
          }
        >>
      #})))


