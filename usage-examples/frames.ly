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


\include "oll-core/package.ily"
\loadPackage \with {
  modules = frames
} analysis

\paper {
  indent = 0
  ragged-right = ##f
  %page-count = 2
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

pspc = \markup \vspace #0.25
spc = \markup \vspace #1

\markup \fill-line {\bold \huge "Frames & Rectangles - Showcase"}
\spc
\markup \justify {
  The \typewriter frames module of \typewriter anaLYsis provides numerous
  functions to draw differently looking frames/rectangles. The basic function
  is \typewriter "\\genericFrame" which takes and - horizontally - surrounds a
  music expression as its mandatory argument. The appearance of the frame
  can be specified either persistently with openLilyLib options in the
  \typewriter "\setOption analysis.frames" tree or individually by overriding
  properties in a \typewriter "\\with {}" block (for details see below).
}

\spc
\markup \bold { Generic frames }

\pspc

\markup \justify {
  A frame has a body and a border, which by default are printed both. The
  color of both elements is controlled with the properties \typewriter
  color and \typewriter border-color, and they can be made invisible by setting
  this property to \typewriter white  (for example \typewriter
  "\\setOption analysis.frames.border-color #green"), or they can be completely suppressed by 
  setting it to \typewriter "##f".
}
\spc

\score {
  \relative c' {

    \genericFrame {
      c8 ^"Default: body and border"
      e g c g e
    }
    r4
    \genericFrame \with {
      color = ##f
    } {
      c8 ^"Border only"
      e g c g e
    }

    r4
    \genericFrame \with {
      border-color = ##f
    } {
      c8 ^"Body only"
      e g c g e
    }
    r4
  }
}

\markup \column {
  \concat { - " " \typewriter border-width " " (0.25) }
  \concat { - " " \typewriter border-radius " " (0.5) }
  \concat { - " " \typewriter shorten-pair " " "#'(0 . 0)" }
}
\pspc
\markup \justify {
  The width (or thickness) of the frame border is controlled with the
  \typewriter border-width Property. \typewriter border-radius applies
  a rounded effect on the frame. Setting this to \typewriter 0 will
  produce a sharply angled frame. With \typewriter shorten-pair the right
  and left padding can be modified. Positive values will make the frame
  narrower while negative values will make it wider. This property should
  be handled with specific care.
}

\spc

\score {
  \relative c' {

    \genericFrame \with {
      border-width = 0.7
    } {
      c8 ^"Increased border-width"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-radius = 1.5
      border-width = 0.7
    } {
      c8 ^"Rounded border"
      e g c g e
    }

    r4
    \genericFrame \with {
      shorten-pair = #'(-1.5 . 1)
    } {
      c8 ^"Modified left/right padding"
      e g c g e
    }
    r4
  }
}

\markup \column {
  \concat { - " " \typewriter l-zigzag-width " " (0) }
  \concat { - " " \typewriter r-zigzag-width " " (0) }
}
\pspc
\markup \justify {
  The left and right edges of the frame can be decorated with a zig-zag
  line-thickness. This is achieved by setting \typewriter l-zigzag-width or
  \typewriter r-zigzag-width to a value greater than zero. In order to avoid
  strange results the value should be a divisor of the distance between
  lower and upper corner (see next element). \typewriter border-radius will
  also make the zigzag curved.
}

\spc

\score {
  \relative c' {

    \genericFrame \with {
      l-zigzag-width = 2
    } {
      c8 ^"Left zigzag 2"
      e g c g e
    }
    r4
    \genericFrame \with {
      r-zigzag-width = 1
    } {
      c8 ^"Right zigzag 1"
      e g c g e
    }

    r4
    \genericFrame \with {
      l-zigzag-width = 4
      r-zigzag-width = 2
      border-radius = 1
    } {
      c8 ^"Mixed zigzag 4 / 2, border-radius 1.0"
      e g c g e
    }
    r4
  }
}

\markup \column {
  \concat { - " " \typewriter y-lower " " (-4) }
  \concat { - " " \typewriter y-upper " " (4) }
}
\pspc
\markup \justify {
  The vertical extent of the frame defaults to -4/+4 (in staff spaces
  from the center staffline). These values can be modified using The
  \typewriter y-lower and \typewriter y-upper properties. When given a
  number they cause a horizontal line at that Y position to be drawn.
  But using a pair of numbers flexible polygons can be created.
}

\noPageBreak
\spc
\noPageBreak

\score {
  \relative c' {

    \genericFrame \with {
      y-lower = -5.5
      y-upper = 5.5
    } {
      g8 ^"-5.5 / +5.5"
      e' g g' e c
    }
    r4
    \genericFrame \with {
      y-upper = #'(2 . 5)
      y-lower = -4.5
    } {
      c,8 ^"Lower straight, upper diagonal"
      e g c g e
    }

    r4
    \genericFrame \with {
      y-lower = #'(-4 . -6)
      y-upper = #'(3 . 6)
    } {
      c8 ^"Both modified"
      e g c g e
    }
    r4
  }
}

\pageBreak

\markup \column {
  \concat { - " " \typewriter hide " " (none / staff / all) }
  \concat { - " " \typewriter layer " " (-10) }
  \concat { - " " \typewriter broken-bound-padding " " (4) }
  \concat { - " " \typewriter open-on-bottom " (##f)" }
  \concat { - " " \typewriter open-on-top " (##f)" }
}
\pspc
\markup \justify {
  By default frames are printed behind the staff, which is achieved by
  setting its \typewriter layer property to \typewriter -10. By manually
  modifying this property the user has detailed control over the stacking
  of elements. If the \typewriter hide property is set to \typewriter staff
  the frame is placed between the staff lines and the music. This is achieved
  by temporarily setting the frame's \typewriter layer to \typewriter 1 and
  that of the other score elements to \typewriter 2. So this may interfere
  with any other \typewriter layer settings the user may have applied
  otherwise. Setting \typewriter hide to \typewriter all will print the
  frame in front of everything else (or concretely at the layer
  \typewriter 5. This can be used to reserve space in exercise sheets.
}
\pspc
\markup \justify {
  Frames can be nested in a straightforward manner. However, this behaves
  differently from spanners like manual beams or slurs. In order to
  print overlapping frames they have to exist in separate voices. \bold
  NOTE: nested frames may behave strangely with other frames acting at the
  same time. In the example the “hide all” frame makes the stacked frame
  in the top staff disappear unless the \typewriter layer property is
  explicitly set to \typewriter -1 (or a layer higher than the outer
  frame's.
}
\pspc
\markup \justify {
  If frames are broken around line breaks the broken edge will be printed
  without border and zigzag lines. The amount of protrusion into the
  margin can be set with the \typewriter broken-bound-padding property.
}
\pspc
\markup \justify {
  With the boolean \typewriter open-on-top and \typewriter open-on-bottom
  the top and/or bottom borders can be switched off, which can be used to
  create fake cross-staff Frames.
}
\spc

\score {
  <<
    \new Staff \relative c'{
      \genericFrame \with {
      } {
        c8 ^"Frame behind staff (default)"
        e g c g e
      } r4
      \genericFrame \with {
      } {
        c16 ^"Stack frames"
        c32 d
        \genericFrame \with {
          color = #white
          border-color = #red
          border-radius = 1
          y-lower = -3.25
          y-upper = -0.25
          % It is totally unclear why this is necessary.
          % The hide = all in the middle system seems to
          % unset this in a peculiar way
          layer = -1
        } {
          e16 e32
        }
        f g8 c g e
      } r4
      \genericFrame \with {
        broken-bound-padding = 0
        r-zigzag-width = 2
      } {
        c8 ^"broken-bound-padding 0"
        e g c
        \bar ""
        \break
        g e
      } r4
      \genericFrame \with {
        open-on-bottom = ##t
        border-width = 0.5
      } {
        c8 ^"Bottom open"
        e g c g e
      } r4
      \genericFrame \with {
        open-on-bottom = ##t
        border-width = 0.5
        border-color = \colDarkRed
        color = \colLightRed
        y-lower = -7
      } {
        c8 ^"Make boxes overlap"
        e g c g e
      } r4
      \genericFrame \with {
        open-on-bottom = ##t
        border-width = 0.5
        y-lower = -7
      } {
        c8 ^"Simulate cross-staff frames"
        e g c g e
      } r4
    }

    % Middle staff
    \new Staff \relative c'{
      \genericFrame \with {
        hide = staff
      } {
        c8 ^"Hide staff"
        e g c g e
      } r4
      \genericFrame \with {
        hide = all
        color = #(rgb-color 0.9 0.9 0.9)
      } {
        c8 ^"Hide all"
        e g c g e
      } r4
      \genericFrame \with {
        broken-bound-padding = 2
        r-zigzag-width = 2
      } {
        c8 ^"broken-bound-padding 2"
        e g c g e
      } r4
      \genericFrame \with {
        open-on-bottom = ##t
        open-on-top = ##t
        border-width = 0.5
      } {
        c8 ^"Bottom/Top open"
        e g c g e
      } r4
      \genericFrame \with {
        open-on-bottom = ##t
        open-on-top = ##t
        border-width = 0.5
        border-color = \colDarkOrange
        color = \colLightOrange
        y-lower = -6
        y-upper = 6
      } {
        c8 ^""
        e g c g e
      } r4
      \genericFrame \with {
        open-on-bottom = ##t
        open-on-top = ##t
        border-width = 0.5
        y-lower = -6
        y-upper = 6
      } {
        c8 ^""
        e g c g e
      } r4
    }

    % Lower staff
    \new Staff \relative c'{
      \genericFrame \with {
        hide = staff
        color = #white
      } {
        c8 ^"Hide staff, empty"
        e g c g e
      } r4
      <<
        {
          \genericFrame \with {
          } {
            c8 ^"Overlapping frames"
            e g
          }
          c g e r4
        }
        \new Voice {
          s4
          \genericFrame \with {
            y-upper = -0.25
            y-lower = -1.75
            border-width = 0.1
            shorten-pair = #'(0 . -0.5)
            border-color = \colDarkYellow
            color = \colLightYellow
          } {
            \hide r4 \hide r8
          }
        }
      >>
      \genericFrame \with {
        r-zigzag-width = 2
      } {
        c8 ^"broken-bound-padding 4 (default)"
        e g c g e
      } r4
      \genericFrame \with {
        border-width = 0.5
        open-on-top = ##t
      } {
        c8 ^"Top open"
        e g c g e
      } r4
      \genericFrame \with {
        border-width = 0.5
        open-on-top = ##t
        border-color = \colDarkYellow
        color = \colLightYellow
        y-upper = 5.5
      } {
        c8 ^""
        e g c g e
      } r4
      \genericFrame \with {
        border-width = 0.5
        open-on-top = ##t
        y-upper = 5.5
      } {
        c8 ^""
        e g c g e
      } r4
    }
  >>
}
%{


\score {
  \new Staff
  \relative c'{
    \time 3/4
    <<
      {
        % \new Voice
        \DYSpan #-5 #1 #-3 #3 \colDarkBlue #white
        c16 ^\markup {
          \override #'(baseline-skip . 2) \left-column {
            "Update:" "If you don't like that overlapping" "boxes cover each other..."
            \transparent "X"
          }
        }
        \startGroup d e f    g \stopGroup f e d
        c4
      }
      \\
      {
        % \new Voice
        s4
        \DYSpan #-5 #1 #-7 #-1 \colDarkGreen #white
        \hide r4 \startGroup \hide r4  \stopGroup
      }
    >>
    <<
      {
        % \new Voice
        \DYFrame #-5 #1 #-3 #3 \colDarkBlue
        c16 ^\markup {
          \override #'(baseline-skip . 2) \left-column {
            "...you can now have frames" "with nothing inside."
            \transparent "X"
          }
        }
        \startGroup d
        \ZZFrame #-5 #0 \colDarkPurple
        e \startGroup f \stopGroup
        g \stopGroup f
        \tornDYFrame #-3 #3 #-3.5 #2.5 \colDarkRed #2 #2
        e \startGroup d \stopGroup
        c4
      }
      \\
      {
        % \new Voice
        s4
        \DYFrame #-5 #1 #-7 #-1 \colDarkGreen
        \hide r4 \startGroup \hide r4  \stopGroup
      }
    >>
  }
}

\markup \vspace #1

\score {
  \relative c'{
    r4^\markup { \rotate #10 \sticker \colDarkGreen \colLightGreen \pad-markup #0.4 "Adhesive tape..." }
    r r r^\markup { "... a useless" \sticker \colDarkYellow \colLightYellow \pad-markup #0.4 "side product" "for markups" }
    r
    r r r
    r r r r^\markup { \rotate #-97 \sticker \colDarkOrange \colLightOrange \pad-markup #0.4 ":-)" }

  }
}

%}
\layout {
  \override TextScript.staff-padding = #3
  \context {
    \Score
    \remove "Bar_number_engraver"
  }
}

