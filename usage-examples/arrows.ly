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
  This file loads the whole ScholarLY library,
  currently only the annotate module is implemented
%}

\version "2.23.80"
\include "oll-core/package.ily"
\loadPackage \with {
  modules = arrows
} analysis

% --------------------------------------------------------------------------
%    Arrows
% --------------------------------------------------------------------------


\markuplist {
  \column {
    \vspace #1
    \huge \bold "Arrows"
    "functions with 1 parameter:"
    \line {\typewriter "\forwardArrow" \italic color}
    \line {\typewriter "\backwardArrow" \italic color}
    "functions with 3 parameters:"
    \line {\typewriter "\forwardArrowSized" \italic "size padding color"}
    \line {\typewriter "\backwardArrowSized" \italic "size padding color"}
  }
}

\score {
  \relative c' {
    <<
      % Usage: place the arrow function call before the note, the glissando statement after the note
      \new Staff = upper {c4 d e \forwardArrowSized #5 #2 #red c \glissando   R1   g'4_\markup \with-color #red "Transposition" a b g}
      \new Staff = middle
      <<
        \new Voice {R1    c,4_\markup \with-color #green "Imitation" d e c   R1}
        \new Voice
        {
          \override NoteColumn.ignore-collision = ##t
          % Cross-staff arrows use an additional voice with hidden notes between them.
          % To make these notes visible, uncomment the following line:
          %     \override NoteHead.color = #cyan \override NoteHead.layer = #2
          % and remove the following "\hideNotes" line:
          \hideNotes
          \set Voice.followVoice = ##t
          \change Staff = "upper"  c4 s2.
          % place the arrow function call immediately before the staff change:
          \forwardArrowSized #5 #2 #green
          \change Staff = "middle"  c4 s2.
        }
      >>
    >>
  }
}

\markup \wordwrap {
  Different from the examples in the blog post, the layer is no more hard-coded
  via \typewriter "\once \override VoiceFollower.layer = #-2" and
  \typewriter "\once \override Glissando.layer = #-2" inside the arrow functions.
}
\markup \vspace #0.3
\markup \wordwrap {
  Instead, including this file / loading this module sets \typewriter "\override VoiceFollower.layer = #-2" and \typewriter "\override Glissando.layer = #-2" .
  That keeps the layer user-changeable, and I don't think there's any problem with the "\"normal\"" use of \typewriter VoiceFollower and \typewriter Glissando.
}
\markup \vspace #3


\markup \wordwrap {
  Of course, you can use all those techniques at the same time and in combination with each other.
}
