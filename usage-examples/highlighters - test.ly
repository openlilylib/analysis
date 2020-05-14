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

\version "2.19.83"

\include "oll-core/package.ily"
\loadPackage \with {
  modules = highlighters
} analysis

\score {
  \new Staff \relative c'{
    \highlighter {
      c4 d e f g f e d
    }
    c4 d e f g f e d
    \highlighter \with { color = #green } {
      c4 d e f g f e d
    }
    c1
  }

  \layout {
  }
}
