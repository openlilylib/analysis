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
%    Arrows
% --------------------------------------------------------------------------


forwardArrow = #(define-music-function (color)
                  (color?)
                  #{ % Cross-staff arrows are made using the VoiceFollower:
                    % \once \override VoiceFollower.layer = #-2
                    % To have the arrow behind the staff, choose a value below 0 for the layer.
                    % If you want the arrows to cover the notes, choose a value of 2 or more.
                    \once \set Voice.followVoice = ##t
                    \once \override VoiceFollower.thickness = #'5    % line thickness
                    \once \override VoiceFollower.color = #color
                    \once \override VoiceFollower.arrow-width =  #(if (lilypond-greater-than? "2.18.2") 1.2 0.5 )
                    \once \override VoiceFollower.arrow-length = #(if (lilypond-greater-than? "2.18.2") 3.2 1.4 )
                    \once \override VoiceFollower.bound-details.left.padding = #2
                    \once \override VoiceFollower.bound-details.right.padding = #(if (lilypond-greater-than? "2.18.2") 1.7 3 )
                    % Padding can be adjusted to move arrow ends closer to the notes
                    \once \override VoiceFollower.bound-details.right.arrow = ##t
                    \once \override VoiceFollower.breakable = ##t  % ##f prevents line breaks within an arrow
                    % Arrows within the same staff use the Glissando spanner:
                    % \once \override Glissando.layer = #-2
                    \once \override Glissando.thickness = #'5
                    \once \override Glissando.color = #color
                    \once \override Glissando.arrow-width =  #(if (lilypond-greater-than? "2.18.2") 1.2 0.5 )
                    \once \override Glissando.arrow-length = #(if (lilypond-greater-than? "2.18.2") 3.2 1.4 )
                    \once \override Glissando.bound-details.left.padding = #2
                    \once \override Glissando.bound-details.right.padding = #(if (lilypond-greater-than? "2.18.2") 1.7 3 )
                    \once \override Glissando.bound-details.right.arrow = ##t
                  #})

backwardArrow = #(define-music-function (parser location color)
                   (color?)
                   #{
                     % \once \override VoiceFollower.layer = #-2
                     \once \set Voice.followVoice = ##t
                     \once \override VoiceFollower.thickness = #'5    % line thickness
                     \once \override VoiceFollower.color = #color
                     \once \override VoiceFollower.arrow-width =  #(if (lilypond-greater-than? "2.18.2") 1.2 0.5 )
                     \once \override VoiceFollower.arrow-length = #(if (lilypond-greater-than? "2.18.2") 3.2 1.4 )
                     \once \override VoiceFollower.bound-details.right.padding = #2
                     \once \override VoiceFollower.bound-details.left.padding = #(if (lilypond-greater-than? "2.18.2") 1.7 3 )
                     % pretty much the same stuff, but arrow head at the left side:
                     \once \override VoiceFollower.bound-details.left.arrow = ##t
                     \once \override VoiceFollower.breakable = ##t
                     % \once \override Glissando.layer = #-2
                     \once \override Glissando.thickness = #'5
                     \once \override Glissando.color = #color
                     \once \override Glissando.arrow-width =  #(if (lilypond-greater-than? "2.18.2") 1.2 0.5 )
                     \once \override Glissando.arrow-length = #(if (lilypond-greater-than? "2.18.2") 3.2 1.4 )
                     \once \override Glissando.bound-details.right.padding = #2
                     \once \override Glissando.bound-details.left.padding = #(if (lilypond-greater-than? "2.18.2") 1.7 3 )
                     \once \override Glissando.bound-details.left.arrow = ##t % same here...
                     \once \override Glissando.breakable = ##t
                   #})

% In the following versions, there are two more parameters:
% size (line thickness and arrow size)
% padding (distance to connected note heads)

forwardArrowSized = #(define-music-function (parser location size pad color)
                       (number? number? color?)
                       #{ % Cross-staff arrows are made using the VoiceFollower:
                         % \once \override VoiceFollower.layer = #-2
                         % To have the arrow behind the staff, choose a value below 0 for the layer.
                         % If you want the arrows to cover the notes, choose a value of 2 or more.
                         \once \set Voice.followVoice = ##t
                         \once \override VoiceFollower.thickness = $size    % line thickness
                         \once \override VoiceFollower.color = #color
                         \once \override VoiceFollower.arrow-width =  #(if (lilypond-greater-than? "2.18.2") (* 0.24 size) (* 0.10 size))
                         \once \override VoiceFollower.arrow-length = #(if (lilypond-greater-than? "2.18.2") (* 0.64 size) (* 0.28 size))
                         \once \override VoiceFollower.bound-details.left.padding = $pad
                         \once \override VoiceFollower.bound-details.right.padding = #(if (lilypond-greater-than? "2.18.2") (- pad 0.3) (+ pad (* 0.2 size)))
                         % Padding can be adjusted to move arrow ends closer to the notes
                         \once \override VoiceFollower.bound-details.right.arrow = ##t
                         \once \override VoiceFollower.breakable = ##t  % ##f prevents line breaks within an arrow
                         % Arrows within the same staff use the Glissando spanner:
                         % \once \override Glissando.layer = #-2
                         \once \override Glissando.thickness = $size
                         \once \override Glissando.color = #color
                         \once \override Glissando.arrow-width =  #(if (lilypond-greater-than? "2.18.2") (* 0.24 size) (* 0.10 size))
                         \once \override Glissando.arrow-length = #(if (lilypond-greater-than? "2.18.2") (* 0.64 size) (* 0.28 size))
                         \once \override Glissando.bound-details.left.padding = $pad
                         \once \override Glissando.bound-details.right.padding = #(if (lilypond-greater-than? "2.18.2") (- pad 0.3) (+ pad (* 0.2 size)))
                         \once \override Glissando.bound-details.right.arrow = ##t
                       #})

backwardArrowSized = #(define-music-function (parser location size pad color)
                        (number? number? color?)
                        #{ % \once \override VoiceFollower.layer = #-2
                          \once \set Voice.followVoice = ##t
                          \once \override VoiceFollower.thickness = $size    % line thickness
                          \once \override VoiceFollower.color = #color
                          \once \override VoiceFollower.arrow-width =  #(if (lilypond-greater-than? "2.18.2") (* 0.24 size) (* 0.10 size))
                          \once \override VoiceFollower.arrow-length = #(if (lilypond-greater-than? "2.18.2") (* 0.64 size) (* 0.28 size))
                          \once \override VoiceFollower.bound-details.right.padding = $pad
                          \once \override VoiceFollower.bound-details.left.padding = #(if (lilypond-greater-than? "2.18.2") (- pad 0.3) (+ pad (* 0.2 size)))
                          % pretty much the same stuff, but arrow head at the left side:
                          \once \override VoiceFollower.bound-details.left.arrow = ##t
                          \once \override VoiceFollower.breakable = ##t  % ##f prevents line breaks within an arrow
                          % \once \override Glissando.layer = #-2
                          \once \override Glissando.thickness = $size
                          \once \override Glissando.color = #color
                          \once \override Glissando.arrow-width =  #(if (lilypond-greater-than? "2.18.2") (* 0.24 size) (* 0.10 size))
                          \once \override Glissando.arrow-length = #(if (lilypond-greater-than? "2.18.2") (* 0.64 size) (* 0.28 size))
                          \once \override Glissando.bound-details.right.padding = $pad
                          \once \override Glissando.bound-details.left.padding = #(if (lilypond-greater-than? "2.18.2") (- pad 0.3) (+ pad (* 0.2 size)))
                          \once \override Glissando.bound-details.left.arrow = ##t
                        #})
