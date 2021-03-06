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

\version "2.19.83"

\include "oll-core/package.ily"
% \include "lilypond-book-preamble.ly"   %%% Remove comment sign to test

\loadPackage \with {
  modules = frames
} analysis

\paper {
  indent = 2\cm
  top-margin = 3\cm
  % ragged-right = ##f
  tagline = ##f
  system-system-spacing.basic-distance = 18
}

colBackColor =    #(rgb-color 0.99 0.96 0.8)

colLightRed =     #(rgb-color 1.0  0.7  0.7)
colDarkRed =      #(rgb-color 0.8  0.2  0.2)

colLightOrange =  #(rgb-color 1.0  0.8  0.6)
colDarkOrange =   #(rgb-color 0.65 0.3  0.1)

colLightYellow =  #(rgb-color 1.0  0.95 0.6)
colDarkYellow =   #(rgb-color 0.8  0.65 0.2)

colLightBrown =   #(rgb-color 0.92 0.82 0.6)
colDarkBrown =    #(rgb-color 0.7  0.5  0.1)

colLightGreen =   #(rgb-color 0.7  0.9  0.7)
colDarkGreen =    #(rgb-color 0.2  0.5  0.3)

colLightBlue =    #(rgb-color 0.8  0.8  1.0)
colDarkBlue =     #(rgb-color 0.3  0.3  0.9)

colLightPurple =  #(rgb-color 0.95 0.7  0.85)
colDarkPurple =   #(rgb-color 0.7  0.3  0.7)

colLightViolet =  #(rgb-color 0.9  0.8  1.0)
colDarkViolet =   #(rgb-color 0.6  0.3  0.9)

%{
\setOption analysis.frames.set-top-edge ##t
\setOption analysis.frames.set-bottom-edge ##t
\setOption analysis.frames.set-left-edge ##t
\setOption analysis.frames.set-right-edge ##t
\setOption analysis.frames.set-caption-extent ##t
%}


pspc = \markup \vspace #0.25
spc = \markup \vspace #1


\score {
  \relative c'' {
    % {
    \genericFrame \with {
      y-lower = -3
      y-upper = 3
      shorten-pair = #'(-10 . 0)
    } {
      c8 
      ^\markup 
      \with-dimensions-from \null
      \translate #'(-11.1 . -6)
      % \with-dimensions-from \null 
      \with-color #red \bold \sans x
      g
    }
    r4
    %}
    % \override HorizontalBracket.direction = #UP
    % \override HorizontalBracket.side-axis = #1
    % \override HorizontalBracket.ignore-collision = ##t
    % \override HorizontalBracket.outside-staff-priority = #1
    
    \genericFrame \with {
      y-lower = #'(-7 . -3)
      y-upper = #'(12 . 6)
      caption = "Caption"
      caption-halign = -1
      % angle = 20
      % caption-align-bottom = ##t
      % border-radius = 2


    } {
      c8_"I'm a markup"\ff g c^"I'm a markup" g c c' \fermata
    }
    r4
    % {
    \genericFrame \with {
      y-lower = -4
      y-upper = 4
    } {
      c,8 g
    }
    r4

    \genericFrame \with {
      y-lower = -3
      y-upper = 3
      % border-radius = 2
      shorten-pair = #'(0 . -6)
    } {
      c8 g
    }
    r4
    %}

  }
}


\layout {
  \override TextScript.staff-padding = #3
  \context {
    \Score
    \remove "Bar_number_engraver"
  }
  \context {
    \Score
    \override System.stencil = #box-grob-stencil
    %% http://lsr.di.unimi.it/LSR/Item?id=257
  }
}

