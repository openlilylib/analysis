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
\definePropertySet analysis.highlighters.config
#`((active ,boolean? #t))

% Predicate for valid highlighter styles
% (list allowed names here)
#(define (highlighter-style? obj)
   (if (member
        obj
        '(ramp
          leftsided-stairs
          rightsided-stairs
          centered-stairs))
       #t
       #f))

\definePropertySet analysis.highlighters.appearance
#`((color ,color? ,green)
   (thickness ,number? 2)
   (layer ,integer? -5)
   (X-offset ,number? 0.6)
   (X-first ,number? -1.2)
   (X-last ,number? 1.2)
   (Y-first ,number? 0)
   (Y-last ,number? 0)
   (style ,highlighter-style? ramp))


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

% TODO: Replace with new functionality

highlight =
#(with-propset define-music-function (mus)(ly:music?)
   `(analysis highlighters appearance)
   (or
    ;; if all checks return true return highlighted music
    ;; else the original music argument
    (and
     (getProperty '(analysis highlighters config) 'active)
     ;; http://lilypond.1069038.n5.nabble.com/Apply-event-function-within-music-function-tp202841p202847.html
     (if (use-preset)
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
           ;; (make properties explicit)
           (color (property 'color))
           (thickness (property 'thickness))
           (layer (property 'layer))
           (X-offset (property 'X-offset))
           (X-first (property 'X-first))
           (X-last (property 'X-last))
           (Y-first (property 'Y-first))
           (Y-last (property 'Y-last))
           (style (property 'style)))
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
                  \once \override ClusterSpannerBeacon.X-offset = $X-first
                  \once \override ClusterSpannerBeacon.Y-offset = $Y-first
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
            #})
          
          )
         #f))
    mus))
