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
% Copyright Malte Meyn & Urs Liska, 2020                                      %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
  This module and its submodules implement support for harmony analysis symbols
%}

\version "2.20.0"

% Also defines the available box types
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
            "parenthesize"
            ))
       #t #f))

% Predicate for font names, which must be given as a string or ##f
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
   (raise-sharp ,number? 0)
   (raise-flat ,number? 0)
   (space-before-accidental ,number? 0.2)
   (space-before-separator ,number? 0.35)
   (key-separator ,string? ":")
   )

% Reference key for harmonic analysis
% Implemented as a StanzaNumber, so it has to be applied in a Lyrics context.
% Single argument is the "fundamental",
% which is a string that may have a trailing "<" or ">",
% resulting in a sharp or flat.
% Supports OLL's property infrastructure (see property set above).
refKey =
#(with-property-set define-music-function (fundamental) (string?)
   `(analysis harmony ref-key)
   (let*
    ((_len (string-length fundamental))
     ;; identify the presence of an accidental
     (accidental
      (assq-ref
       ;; Create a pair with raise value and markup for accidentals
       ;; The raise value includes the default raise needed for sharps and flats
       ;; so properties start off from zero.
       `((#\< . ,(cons (+ 0.8 (property 'raise-sharp)) (markup #:sharp)))
         (#\> . ,(cons (+ 0.4 (property 'raise-flat)) (markup #:flat))))
       (string-ref fundamental (- _len 1))))
     ;; actual fundamental to be used (possibly stripped of the accidental indicator)
     (name
      (if accidental
          (substring fundamental 0 (- _len 1))
          fundamental))
     ;; compose the markup for the accidental (if present),
     ;; using spacing and sizing properties
     (accidental-markup
      (if accidental
          (markup #:concat
            (#:hspace (property 'space-before-accidental)
              #:override `(font-size .
                            ,(+ (property 'accidental-size)
                               (- (property 'font-size) 3)))
              #:raise (car accidental) (cdr accidental)))
          (markup "")))
     ;; compose the markup for the separator at the end separator
     (separator (markup #:concat
            (#:hspace (property 'space-before-separator)
              (property 'key-separator))))
     )
    ;; Parametrically enclose the
    ;; Based on solutions by Lukas-Fabian Moser in the thread
    ;; https://lists.gnu.org/archive/html/lilypond-user/2020-07/msg00031.html
    (define-markup-command (enclose layout props content)(markup?)
     (let*
      ((box-type (property 'box-type))
       ;; selecting "none" as box-type will silently re-apply the font-shape property
       (func-to-apply (if (string=? box-type "none") (property 'font-shape) box-type))
       ;; construct a markup function based on the *name* of the requested enclosure
       (box-func (symbol-append 'make- (string->symbol func-to-apply) '-markup)))
      (interpret-markup layout props
        (primitive-eval
         (list 'markup
           (list
            box-func
            `(make-stencil-markup
              ,(interpret-markup layout props content))))))))
    #{
      % If suppressed by preset filters we create the object anyway
      % but hide it (to use up the space and be able to show it
      % without changing the layout).
      #(if (not (use-preset)) #{ \once \hide StanzaNumber #} #{ #})
      \set stanza =
      \markup
      % apply custom boxing function
      \enclose
      % Configure the properties
      \pad-around #(property 'box-padding)
      \override #`(font-shape . ,(string->symbol (property 'font-shape)))
      \override #`(font-series . ,(string->symbol (property 'font-series)))
      \override #`(font-family . ,(string->symbol (property 'font-family)))
      \override #`(font-size . ,(property 'font-size))
      \override #`(font-name . ,(property 'font-name))
      \with-color #(property 'color)
      % The actual content of the refKey symbol:
      \concat { #name #accidental-markup #separator }
    #}))
