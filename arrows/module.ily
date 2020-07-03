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

% --------------------------------------------------------------------------
%    Arrows
% --------------------------------------------------------------------------

#(define (arrow-direction? obj)
   (member obj '("forward" "backward" "both")))

\definePropertySet analysis.arrows.appearance
#`((thickness ,number? 5)
   (color ,color? ,red)
   (layer ,integer? -2)
   (arrow-width ,number? 1.2)
   (arrow-length ,number? 3.2)
   (padding-left ,number? 2)
   (padding-right ,number? 1.7)
   (direction ,arrow-direction? "forward")
   )

% Draw an analysis arrow from the anchor note/chord
% to the next note that follows (will skip rests and skips).
% Internally creates a glissando object
% By default an arrow head is created at the right edge.
arrow =
#(with-property-set define-music-function (anchor) (ly:music?)
   `(analysis arrows appearance)
   (let*
    ((thickness (property 'thickness))
     (color (property 'color))
     (arrow-width (property 'arrow-width))
     (arrow-length (property 'arrow-length))
     (padding-left (property 'padding-left))
     (padding-right (property 'padding-right))
     (arrow-left (if (member (property 'direction) '("backward" "both")) #t #f))
     (arrow-right (if (member (property 'direction) '("forward" "both")) #t #f))
     )
    #{ 
      \once \override Glissando.thickness = #thickness
      \once \override Glissando.color = #color
      \once \override Glissando.arrow-width =  #arrow-width
      \once \override Glissando.arrow-length = #arrow-length
      \once \override Glissando.bound-details.left.padding = #padding-left
      \once \override Glissando.bound-details.right.padding = #padding-right
      \once \override Glissando.bound-details.left.arrow = #arrow-left
      \once \override Glissando.bound-details.right.arrow = #arrow-right
      #anchor \glissando
    #}))

% Draw an analysis arrow in a separate (hidden) voice.
% A \with block is passed along to \arrow
% Expects three arguments:
% - anchor 1: note/chord to start the arrow from
% - skip: "music" (typically skips) to define the length. May include aStaff change.
% - anchor 2: note/chord to end the arrow at
arrowV =
#(define-music-function (opts anchor1 skip anchor2)
   ((ly:context-mod? (ly:make-context-mod)) ly:music? ly:music? ly:music?)
   #{
     \new Voice {
     \hideNotes
     \temporary \override NoteColumn.ignore-collision = ##t
     \arrow #opts #anchor1
     #skip
     #anchor2
     \unHideNotes
     \revert NoteColumn.ignore-collision
     }
   #}
   )

% Deprecated functions

forwardArrow = #(define-music-function (color)
                  (color?)
                  (oll:warn "
Deprecated use of '\\forwardArrow'.
Please use \\arrow instead.")
                  #{ % Cross-staff arrows are made using the VoiceFollower:
                    % \once \override VoiceFollower.layer = #-2
                    % To have the arrow behind the staff, choose a value below 0 for the layer.
                    % If you want the arrows to cover the notes, choose a value of 2 or more.
                    \once \set Voice.followVoice = ##t
                    \once \override VoiceFollower.thickness = #'5    % line thickness
                    \once \override VoiceFollower.color = #color
                    \once \override VoiceFollower.arrow-width = #1.2
                    \once \override VoiceFollower.arrow-length = #3.2
                    \once \override VoiceFollower.bound-details.left.padding = #2
                    \once \override VoiceFollower.bound-details.right.padding = #1.7
                    % Padding can be adjusted to move arrow ends closer to the notes
                    \once \override VoiceFollower.bound-details.right.arrow = ##t
                    \once \override VoiceFollower.breakable = ##t  % ##f prevents line breaks within an arrow
                    % Arrows within the same staff use the Glissando spanner:
                    % \once \override Glissando.layer = #-2
                    \once \override Glissando.thickness = #'5
                    \once \override Glissando.color = #color
                    \once \override Glissando.arrow-width =  #1.2
                    \once \override Glissando.arrow-length = #3.2
                    \once \override Glissando.bound-details.left.padding = #2
                    \once \override Glissando.bound-details.right.padding = #1.7
                    \once \override Glissando.bound-details.right.arrow = ##t
                  #})

backwardArrow = #(define-music-function (parser location color)
                   (color?)
                  (oll:warn "
Deprecated use of '\\backwardArrow'.
Please use \\arrow instead.")
                   #{
                     % \once \override VoiceFollower.layer = #-2
                     \once \set Voice.followVoice = ##t
                     \once \override VoiceFollower.thickness = #'5    % line thickness
                     \once \override VoiceFollower.color = #color
                     \once \override VoiceFollower.arrow-width =  #1.2
                     \once \override VoiceFollower.arrow-length = #3.2
                     \once \override VoiceFollower.bound-details.right.padding = #2
                     \once \override VoiceFollower.bound-details.left.padding = #1.7
                     % pretty much the same stuff, but arrow head at the left side:
                     \once \override VoiceFollower.bound-details.left.arrow = ##t
                     \once \override VoiceFollower.breakable = ##t
                     % \once \override Glissando.layer = #-2
                     \once \override Glissando.thickness = #'5
                     \once \override Glissando.color = #color
                     \once \override Glissando.arrow-width =  #1.2
                     \once \override Glissando.arrow-length = #3.2
                     \once \override Glissando.bound-details.right.padding = #2
                     \once \override Glissando.bound-details.left.padding = #1.7
                     \once \override Glissando.bound-details.left.arrow = ##t % same here...
                     \once \override Glissando.breakable = ##t
                   #})

% In the following versions, there are two more parameters:
% size (line thickness and arrow size)
% padding (distance to connected note heads)

forwardArrowSized = #(define-music-function (parser location size pad color)
                       (number? number? color?)
                  (oll:warn "
Deprecated use of '\\forwardArrowSized'.
Please use \\arrow instead.")
                       #{ % Cross-staff arrows are made using the VoiceFollower:
                         % \once \override VoiceFollower.layer = #-2
                         % To have the arrow behind the staff, choose a value below 0 for the layer.
                         % If you want the arrows to cover the notes, choose a value of 2 or more.
                         \once \set Voice.followVoice = ##t
                         \once \override VoiceFollower.thickness = $size    % line thickness
                         \once \override VoiceFollower.color = #color
                         \once \override VoiceFollower.arrow-width =  #(* 0.24 size)
                         \once \override VoiceFollower.arrow-length = #(* 0.64 size)
                         \once \override VoiceFollower.bound-details.left.padding = $pad
                         \once \override VoiceFollower.bound-details.right.padding = #(- pad 0.3)
                         % Padding can be adjusted to move arrow ends closer to the notes
                         \once \override VoiceFollower.bound-details.right.arrow = ##t
                         \once \override VoiceFollower.breakable = ##t  % ##f prevents line breaks within an arrow
                         % Arrows within the same staff use the Glissando spanner:
                         % \once \override Glissando.layer = #-2
                         \once \override Glissando.thickness = $size
                         \once \override Glissando.color = #color
                         \once \override Glissando.arrow-width =  #(* 0.24 size)
                         \once \override Glissando.arrow-length = #(* 0.64 size)
                         \once \override Glissando.bound-details.left.padding = $pad
                         \once \override Glissando.bound-details.right.padding = #(- pad 0.3)
                         \once \override Glissando.bound-details.right.arrow = ##t
                       #})

backwardArrowSized = #(define-music-function (parser location size pad color)
                        (number? number? color?)
                                          (oll:warn "
Deprecated use of '\\backwardArrowSized'.
Please use \\arrow instead.")
                        #{ % \once \override VoiceFollower.layer = #-2
                          \once \set Voice.followVoice = ##t
                          \once \override VoiceFollower.thickness = $size    % line thickness
                          \once \override VoiceFollower.color = #color
                          \once \override VoiceFollower.arrow-width =  #(* 0.24 size)
                          \once \override VoiceFollower.arrow-length = #(* 0.64 size)
                          \once \override VoiceFollower.bound-details.right.padding = $pad
                          \once \override VoiceFollower.bound-details.left.padding = # (- pad 0.3)
                          % pretty much the same stuff, but arrow head at the left side:
                          \once \override VoiceFollower.bound-details.left.arrow = ##t
                          \once \override VoiceFollower.breakable = ##t  % ##f prevents line breaks within an arrow
                          % \once \override Glissando.layer = #-2
                          \once \override Glissando.thickness = $size
                          \once \override Glissando.color = #color
                          \once \override Glissando.arrow-width =  #(* 0.24 size)
                          \once \override Glissando.arrow-length = #(* 0.64 size)
                          \once \override Glissando.bound-details.right.padding = $pad
                          \once \override Glissando.bound-details.left.padding = #(- pad 0.3)
                          \once \override Glissando.bound-details.left.arrow = ##t
                        #})
