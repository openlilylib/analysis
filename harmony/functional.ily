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
% Copyright Klaus Blum & Urs Liska, 2019                                      %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
  This file implements support for functional analysis symbols
  Based on code contributed by Malte Meyn.
%}

\version "2.19.65"

\loadModule analysis.harmony

#(use-modules (ice-9 regex))

\definePropertySet analysis.harmony.functional
#`((double-letter-offset ,number-pair? ,(cons 0.37  -0.37))
   (number-size ,number? 0)
   )

#(define-markup-command (function-markup layout props use-preset properties str)
   (boolean? list? string?)
   #:properties ((font-size 0)
                 (font-features '()))
   ; NOTE/TODO:
   ; The variable use-presets is passed on from the (use-preset) function
   ; of the original with-property-set call. It is not respected yet.
   ; The variable properties holds the properties alist from the
   ; original with-property-set calls in \function and \lyricsToFunctions,
   ; *after* processing (i.e. type and preset checking)
   ; this is currently not used within the markup function.
   (let*
    ((property (lambda (name) (assq-ref properties name))) ;; reimplemented from with-property-set
      (number-size (- (property 'number-size) 6))
      (short (if (string-match "/" str) #t #f))
      (has-paren-left (if (string-match "\\(" str) #t #f))
      (has-paren-right (if (string-match "\\)" str) #t #f))
      (has-bracket-left (if (string-match "\\[" str) #t #f))
      (has-bracket-right (if (string-match "\\]" str) #t #f))
      (function-match (string-match "[A-Za-z]+" str))
      (function-text (if function-match (match:substring function-match) " "))
      (is-double-func (and (< 1 (string-length function-text))
                           (equal? (string-ref function-text 0) (string-ref function-text 1))))
      (double-func
       (if is-double-func (markup (string (string-ref function-text 0)))))
      (bottom-match (string-match "_[0-9]+[<>]?" str))
      (bottom-text (if bottom-match (substring (match:substring bottom-match) 1) ""))
      (top-match (string-match "\\^[0-9]+[<>]?" str))
      (top-text (if top-match (substring (match:substring top-match) 1) ""))
      (number-match (list-matches "-([0-9]+[<>]?|n|N|v)" str))
      (number-text (map (lambda (x) (substring (match:substring x) 1)) number-match))
      (paren-left-markup (cond
                          (has-paren-left "(")
                          (has-bracket-left "[")
                          (else (markup #:null))))
      (paren-right-markup (cond
                           (has-paren-right ")")
                           (has-bracket-right "]")
                           (else (markup #:null))))
      (short-markup (cond
                     ((not short)
                      (markup #:null))
                     ((string-index "st" (string-ref function-text 0))
                      (markup #:translate '(0. . 0.0)
                        #:draw-line '(0.9 . 1.1)))
                     (else (markup #:translate '(0.0 . -0.1)
                             #:draw-line '(1.3 . 1.7)))))
      (function-markup (if is-double-func
                           (markup #:concat
                             (#:combine
                              double-func #:translate (property 'double-letter-offset) double-func
                              (substring function-text 2)))
                           (markup function-text)))
      (bottom-markup (markup #:fontsize number-size bottom-text))
      (top-markup (markup #:fontsize number-size top-text))
      (number-markup (map (lambda (x) (markup #:fontsize number-size x)) number-text))
      (number-markups (case (length number-markup)
                        ((0) (make-list 3 (markup #:null)))
                        ((1) (list (markup #:null) (list-ref number-markup 0) (markup #:null)))
                        ((2) (cons (markup #:null) number-markup))
                        ((3) number-markup))))
    (interpret-markup layout props
      #{
        \markup
        \scale #(cons (magstep font-size) (magstep font-size))
        \override #(cons 'font-features (cons "lnum" font-features))
        \normalsize \concat {
          #paren-left-markup
          \override #(cons 'baseline-skip
                       (+ 1.2 (if (or is-double-func (string-match "[gp]" function-text)) 0.37 0)))
          \center-column {
            \override #(cons 'direction UP)
            \override #(cons 'baseline-skip
                         (- 2 (if (string-match "^[acegips]*$" function-text) 0.47 0)))
            \dir-column \center-align {
              \combine #short-markup #function-markup
              #top-markup
            }
            #bottom-markup
          }
          \hspace
          #(cond
            ((= 3 (length number-markup)) 0.05)
            ((= 0 (length number-markup)) 0)
            (is-double-func -0.37)
            (else -0.1))
          \override #(cons 'direction UP)
          \override #(cons 'baseline-skip 1.0)
          \raise #0.2 \dir-column #number-markups
          #paren-right-markup
        }
      #})))

lyricsToFunctions = \override LyricText.stencil =
#(with-property-set define-scheme-function (grob)(ly:grob?)
   `(analysis harmony functional)
   (grob-interpret-markup grob
     (markup #:function-markup (use-preset) props (ly:grob-property grob 'text))))


function =
#(with-property-set define-scheme-function (code)(string?)
   `(analysis harmony functional)
   #{
     \markup \function-markup #(use-preset) #props #code
   #})
