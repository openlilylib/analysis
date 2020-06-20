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
  A frame has a body and a border, which by default are printed both.
}
\pspc
\markup \justify {
  The color of both elements is controlled with the properties \typewriter
  color and \typewriter border-color  (for example \concat {
    \typewriter
    "\\setOption analysis.frames.border-color #green" ),
  }
  and they can be made invisible by setting
  this property to \typewriter white , or they can be completely suppressed by
  setting it to \typewriter "#f".
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
      c8 ^"border only"
      e g c g e
    }

    r4
    \genericFrame \with {
      border-color = ##f
    } {
      c8 ^"body only"
      e g c g e
    }
    r4
  }
}

\markup \column {
  \concat { - " " \typewriter border-width " " (0.25) }
  \concat { - " " \typewriter border-radius " " (0) }
  \concat { - " " \typewriter shorten-pair " " "#'(0 . 0)" }
}
\pspc
\markup \justify {
  The width (or thickness) of the frame border is controlled with the
  \typewriter border-width Property. \typewriter border-radius applies
  a rounded effect on the frame (but will also make it grow outwards).
  Leaving this at \typewriter 0 will
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
    r8
    \genericFrame \with {
      l-zigzag-width = 2
    } {
      e8 ^"Left zigzag 2"
      g c g e
    }
    r4
    \genericFrame \with {
      r-zigzag-width = 1
    } {
      c8 ^"Right zigzag 1"
      e g c g
    }

    r8 r4
    r8
    \genericFrame \with {
      l-zigzag-width = 4
      r-zigzag-width = 2
      border-radius = 1
    } {
      e8 ^"Mixed zigzag 4 / 2, border-radius 1.0"
      g c g
    }
    r8 r4
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
  \concat { - " " \typewriter hide " " (none / staff / music / all) }
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
  that of the other score elements to \typewriter 2.
  Setting \typewriter hide to \typewriter music will place the frame in layer
  \typewriter -1 and the music in layer \typewriter -2.
  So this may interfere
  with any other \typewriter layer settings the user may have applied
  otherwise.


  Setting \typewriter hide to \typewriter all will print the
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
  create fake cross-staff Frames. In that case (and also when using frames
  broken around line breaks), \typewriter border-radius should be left at
  \typewriter 0 .
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
        color = #white
      } {
        c8 ^"Hide staff, white"
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
        hide = music
        color = #white
      } {
        c8 ^"Hide music, white"
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
            layer = -9
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

\spc

\markup \column {
  \concat { - " " \typewriter angle " " (0) }
}
\noPageBreak
\pspc
\noPageBreak
\markup \justify {
  Frames can be rotated couter-clockwise around their center point by
  setting the \typewriter angle property to a positive value in degrees.
  Negative values will turn the frame clockwise.
}

\noPageBreak
\spc
\noPageBreak

\score {
  \relative c'' {
    \genericFrame \with {
      r-zigzag-width = 1
    } {
      c,8 ^"angle: 0 (default)"
      e g c g
    }
    r8 r4
    \genericFrame \with {
      r-zigzag-width = 1
      angle = 5
    } {
      c,8 ^"5 degrees"
      e g c g
    }
    r8 r4
    \genericFrame \with {
      r-zigzag-width = 1
      angle = 10
    } {
      c,8 ^"10"
      e g c g
    }
    r8 r4
    \genericFrame \with {
      r-zigzag-width = 1
      angle = -10
    } {
      c,8 ^"        -10"
      e g c g
    }
    r8 r4
  }
}

\spc

\markup \column {
  \concat { - " " \typewriter caption " " "(#f)" }
  \concat { - " " \typewriter caption-color " " "(#f)" }
}
\noPageBreak
\pspc
\noPageBreak
\markup \justify {
  The \typewriter caption property can be set to a string or markup which will
  be displayed in a label that is automatically aligned to the frame.
  By default, the border color will be used for text background. Therefore it
  can be recommended to choose a light color for the text.
  Any markup command can be used.
  Setting the \typewriter caption-color property to a valid color allows to
  change the caption's background color.
}

\noPageBreak
\spc
\noPageBreak

\score {
  \relative c' {
    \genericFrame \with {
      caption =  "Caption"
      border-color = \colDarkYellow
      color = \colLightYellow
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "white text"
      border-color = \colDarkGreen
      color = \colLightGreen
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \bold \line {  \scale #'(0.5 . 1) \with-color #white some   \concat { \with-color \colLightBlue mark \with-color \colLightOrange \italic up} }
      border-color = \colDarkGreen
      color = \colLightGreen
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "red background"
      caption-color = #red
      border-color = \colDarkGreen
      color = \colLightGreen
    } {
      c8
      e g c g e
    }
    r4
  }
}

\spc

\markup \column {
  \concat { - " " \typewriter caption-halign " " "(-1)" }
  \concat { - " " \typewriter caption-align-bottom " " "(#f)" }
}
\noPageBreak
\pspc
\noPageBreak
\markup \justify {
  By default, the caption is placed left-aligned which corresponds to the
  \typewriter caption-halign property being \typewriter -1. \typewriter 0
  will have it centered,
  \typewriter 1 will result in a right-aligned caption.
  Any value in between can be applied,
  even beyond that range.
  Setting \typewriter caption-align-bottom to \typewriter "#t" will move
  the caption to the bottom edge.
}

\noPageBreak
\spc
\noPageBreak

\score {
  \relative c' {
    \genericFrame \with {
      caption = \markup \with-color #white "-1.0"
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "-0.5"
      caption-halign = #-0.5
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white " 0 "
      caption-halign = #0
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "1.0"
      caption-halign = #1
    } {
      c8
      e g c g e
    }
    r4
  }
}

\score {
  \relative c'' {
    <<
      {
        r2 r4
        \genericFrame \with {
          caption = \markup \with-color #white "top"
          color = ##f
          y-upper = #'( 5 .  1)
          y-lower = #'(-1 . -5)
        } {
          c g e c
        }
        r
      }\\{
        \genericFrame \with {
          caption = \markup \with-color #white "bottom"
          caption-align-bottom = ##t
          color = ##f
          border-color = \colDarkRed
          y-upper = #'(-1 .  3)
          y-lower = #'(-7 . -3)
        } {
          c4 e g c
        }
        r1
      }
    >>
    \oneVoice
    \genericFrame \with {
      caption = \markup \with-color #white " 0 "
      caption-halign = #0
      caption-align-bottom = ##t
    } {
      c,8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "1.2"
      caption-halign = #1.2
      caption-align-bottom = ##t
    } {
      c8
      e g c g e
    }
    r4
  }
}

\spc

\markup \column {
  \concat { - " " \typewriter caption-padding  "  (0.25)" }
  \concat { - " " \typewriter caption-radius "  (0.25)" }
}
\noPageBreak
\pspc
\noPageBreak
\markup \justify {
  The distance between the caption text and the label's borders can be
  controlled with the \typewriter caption-padding property. Setting
  \typewriter caption-radius to a positive value will apply rounded corners
  to the caption label.
}

\noPageBreak
\spc
\noPageBreak

\score {
  \relative c' {
    \genericFrame \with {
      caption = \markup \with-color #white "default: 0.25"
    } {
      c8^"caption-padding:"
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "0.5"
      caption-padding = #0.5
    } {
      c8 e g
    }
    r8
    \genericFrame \with {
      caption = \markup \with-color #white "1.0"
      caption-padding = #1
    } {
      g8 e c
    }
    r8
    \genericFrame \with {
      caption = \markup \with-color #white "default: 0.25"
    } {
      c8^"caption-radius:"
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white " 0 "
      caption-radius = #0
    } {
      c8 e g
    }
    r8
    \genericFrame \with {
      caption = \markup \with-color #white "1.0"
      caption-radius = #1
    } {
      g8 e c
    }
    r8
  }
}

\pageBreak

% \spc

\markup \column {
  \concat { - " " \typewriter caption-translate-x  "  (0)" }
}
\noPageBreak
\pspc
\noPageBreak
\markup \justify {
  In some situations it can look better to manually move the caption away
  from the frame's corners by a fixed number of spaces.
  This can be controlled with the \typewriter caption-translate-x property.
  Positive values will move it to the right, negative values to the left side.
}

\noPageBreak
\spc
\noPageBreak

\score {
  \relative c' {
    \genericFrame \with {
      y-upper = #'(1.5 . 4.5)
      y-lower = #'(-4.5 . -1.5)
      caption = \markup \with-color #white "0 (default)"
    } {
      c8
      d e f g a
    }
    r4
    \genericFrame \with {
      y-upper = #'(1.5 . 4.5)
      y-lower = #'(-4.5 . -1.5)
      caption-translate-x = 0.5
      caption = \markup \with-color #white "0.5"
    } {
      c,8
      d e f g a
    }
    r4
    \genericFrame \with {
      border-width = 0.5
      border-radius = 2
      caption-radius = 0.75
      caption = \markup \with-color #white "0 (default)"
    } {
      c,8
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 0.5
      border-radius = 2
      caption-radius = 0.75
      caption-translate-x = 1
      caption = \markup \with-color #white "1.0"
    } {
      c8
      e g c g e
    }
    r4

  }
}

#(define-markup-command (extend-height layout props text)
   (markup?)
   (interpret-markup layout props
     (markup
      #:combine
      text
      #:transparent
      #:scale (cons 0.1 1)
      #:combine
      "É" "j"
      )
     )
   )

#(define-markup-command (extend-public layout props text)
   (markup?)
   (interpret-markup layout props
     (markup
      #:combine
      text
      #:with-color grey
      #:scale (cons 0.5 1)
      #:combine
      "É" "j"
      )
     )
   )

\spc

\markup \column {
  \concat { - " " \typewriter caption-keep-y  "  (#f)" }
}
\noPageBreak
\pspc
\noPageBreak
\markup \line {
  The overall height of a markup depends on whether it contains
  ascenders or descenders:
}
\markup \line {
  \box É \box E \box e \box g \box "-"
  \box Pa \box pa \box ge \box no
}
\markup \justify {
  This would make it impossible to always correctly align the labels to the
  upper or lower frame border.
  Therefore caption labels are extended to a height that leaves enough space
  for ascenders and descenders:
}
\markup \line {
  \box \extend-height É \box \extend-height E \box \extend-height e
  \box \extend-height g \box \extend-height "-"
  \box \extend-height Pa \box \extend-height pa \box \extend-height ge \box \extend-height no
}
\markup \justify {
  Internally this is done by adding an invisible (and compressed) \box É and \box j
  stencil to every markup:
}
\markup \line {
  \box \extend-public É \box \extend-public E \box \extend-public e
  \box \extend-public g \box \extend-public "-"
  \box \extend-public Pa \box \extend-public pa \box \extend-public ge \box \extend-public no
}

\noPageBreak
\spc
\noPageBreak

\score {
  \relative c'' {
    \genericFrame \with {
      caption = \markup \with-color #white "Pa"
      color = ##f
      caption-halign = 0
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "pa"
      color = ##f
      caption-halign = 0
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "ge"
      color = ##f
      caption-halign = 0
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "no"
      color = ##f
      caption-halign = 0
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "Pa"
      color = ##f
      caption-halign = 0
      caption-align-bottom = ##t
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "pa"
      color = ##f
      caption-halign = 0
      caption-align-bottom = ##t
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "ge"
      color = ##f
      caption-halign = 0
      caption-align-bottom = ##t
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "no"
      color = ##f
      caption-halign = 0
      caption-align-bottom = ##t
    } {
      e8 e
    }
    r4
  }
}

\score {
  \relative c' {
    \genericFrame \with {
      caption = \markup \magnify #2 \with-color #white "big"
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \translate #'(-1 . 1) \with-color #white "translated"
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \rotate #10 \with-color #white "rotated"
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \magnify #2 \with-color #white "big"
      caption-align-bottom = ##t
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \translate #'(-1 . 1) \with-color #white "translated"
      caption-align-bottom = ##t
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \rotate #10 \with-color #white "rotated"
      caption-align-bottom = ##t
    } {
      c8
      e g c g e
    }
    r4
  }
}

\spc

\markup \justify {
  This behaviour can lead to unwanted results, e.g. when applying markup commands that
  change the size or position of the text.
  It can be turned off by setting the \typewriter caption-keep-y
  property to \concat { \typewriter "#t" "." } Then the \typewriter "\\translate"
  markup command can be used to manually move the caption:
}

\noPageBreak
\spc
\noPageBreak

\score {
  \relative c'' {
    \genericFrame \with {
      caption = \markup \with-color #white "Pa"
      color = ##f
      caption-halign = 0
      caption-keep-y = ##t
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "pa"
      color = ##f
      caption-halign = 0
      caption-keep-y = ##t
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "ge"
      color = ##f
      caption-halign = 0
      caption-keep-y = ##t
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "no"
      color = ##f
      caption-halign = 0
      caption-keep-y = ##t
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "Pa"
      color = ##f
      caption-halign = 0
      caption-align-bottom = ##t
      caption-keep-y = ##t
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "pa"
      color = ##f
      caption-halign = 0
      caption-align-bottom = ##t
      caption-keep-y = ##t
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "ge"
      color = ##f
      caption-halign = 0
      caption-align-bottom = ##t
      caption-keep-y = ##t
    } {
      e8 e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "no"
      color = ##f
      caption-halign = 0
      caption-align-bottom = ##t
      caption-keep-y = ##t
    } {
      e8 e
    }
    r4
  }
}

\score {
  \relative c' {
    \genericFrame \with {
      caption = \markup \magnify #2 \with-color #white "big"
      caption-keep-y = ##t
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \translate #'(-1 . 1) \with-color #white "translated"
      caption-keep-y = ##t
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \rotate #10 \with-color #white "rotated"
      caption-keep-y = ##t
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \magnify #2 \with-color #white "big"
      caption-keep-y = ##t
      caption-align-bottom = ##t
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \translate #'(-1 . 1) \with-color #white "translated"
      caption-keep-y = ##t
      caption-align-bottom = ##t
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \rotate #10 \with-color #white "rotated"
      caption-keep-y = ##t
      caption-align-bottom = ##t
    } {
      c8
      e g c g e
    }
    r4
  }
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

