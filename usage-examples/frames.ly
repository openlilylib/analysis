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
  color and \typewriter border-color, and they can be suppressed by setting
  this property to \typewriter white or \typewriter "##f" (for example \typewriter 
  "\\setOption analysis.frames.border-color #green").
}
\spc

\score {
  \relative c' {

    \genericFrame {
      c8 ^"Default: fill and frame"
      e g c g e
    }
    r4
    \genericFrame \with {
      color = ##f
    } {
      c8 ^"Frame only"
      e g c g e
    }

    r4
    \genericFrame \with {
      border-color = ##f
    } {
      c8 ^"Fill only"
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
  \typewriter r-zigzag-width to a value greater than zero. Usually it will
  be practical to use multiples of \typewriter 1 as values.
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
    } {
      c8 ^"Mixed zigzag 4 / 2"
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

\spc
\markup \bold { TODO: -layer, -open-on-bottom (-top), padding }

%{
\markup \vspace #1
\markup "Lower and upper border are passed as parameters (zero = middle line):"

\score {
  \relative c' {
    \override SpacingSpanner.common-shortest-duration = #(ly:make-moment 1/4)
    \override TextScript.staff-padding = #7
    \genericSpan #-4 #0 #-4 #0 \colDarkRed \colLightRed #0 #0 ##f ##f
    c8 ^\markup { \override #'(baseline-skip . 2) \left-column { " "  "y-upper: #0"  "y-lower: #-4"}}
    \startGroup e g c g e \stopGroup r4
    \genericSpan #-2 #2 #-2 #2 \colDarkRed \colLightRed #0 #0 ##f ##f
    c8 ^\markup { \override #'(baseline-skip . 2) \left-column {" "  "#2"  "#-2"}}
    \startGroup e g c g e \stopGroup r4
    \genericSpan #-5 #-1 #-0.5 #3.5 \colDarkRed \colLightRed #0 #0 ##f ##f
    c16 ^\markup { \override #'(baseline-skip . 2) \left-column {"left:"  "#-1"  "#-5"}}
    \startGroup
    \once \override TextScript.staff-padding = #4
    d
    _"Left and right edge can have their own Y-extent"
    e f ^\markup { \override #'(baseline-skip . 2) \left-column {"right:"  "#3.5"  "#-0.5"}}
    g a b c d4 \stopGroup r4
    r16
    \genericSpan #-1 #2 #-4 #2 \colDarkRed \colLightRed #0 #0 ##f ##f
    c ^\markup { \override #'(baseline-skip . 2) \left-column {"left:"  "#2"  "#-1"}}
    \startGroup b c a c g c f, ^\markup { \override #'(baseline-skip . 2) \left-column {"right:"  "#2"  "#-4"}}
    c' e, c' \stopGroup r4

  }
}

\markup \vspace #1
%\markup "Parameters for left and right edge: straight or zigzag style"

\score {
  <<
    \new Staff {
      \relative c' {
        \override TextScript.staff-padding = #5
        \genericSpan #-4 #4 #-4 #4 \colDarkGreen \colLightGreen #2 #0 ##f ##f
        c8
        ^\markup {
          \override #'(baseline-skip . 2) \left-column {
            "stepLeft:" "#2"
          }
        }
        ^"\"Zigzag\" parameters:"
        \startGroup e g c g
        ^\markup {
          \override #'(baseline-skip . 2) \center-column {
            "stepRight:    " "#0    "
          }
        }
        e \stopGroup r4
        \genericSpan #-4 #4 #-4 #4 \colDarkViolet \colLightViolet #2 #0 ##f ##f
        c8 \startGroup e ^\markup {
          \override #'(baseline-skip . 2) \left-column {
            "hair-thickness:" "#0"
          }
        }
        ^"property:"
        g c g e \stopGroup r4
        \genericSpan #-4 #4 #-4 #4 \colDarkPurple \colLightPurple #2 #0 ##f ##f
        c8
        ^\markup {
          \override #'(baseline-skip . 2) \left-column {
            "shorten-pair:" "#'(-0.3 . -0.3) [default]"
          }
        }

        ^"property:" \startGroup e g c g e \stopGroup r4
        r2 ^\markup {
          \override #'(baseline-skip . 2) \left-column {
            "broken-bound-padding:" "#0"
          }
        }
        ^"property:"
        \once \override HorizontalBracket.broken-bound-padding = #0
        \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #2 #0 ##f ##f
        c8 \startGroup e g c
        g8 e \stopGroup r4 r2
        \override TextScript.staff-padding = #3
        \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #0 #0 ##t ##f
        c8 ^"open-on-bottom: ##t"
        \startGroup e g c g e \stopGroup r4
        \genericSpan #-6 #4 #-6 #4 \colDarkRed \colLightRed #0 #0 ##t ##f
        c8 ^"Make boxes overlap..." \startGroup e g c g e \stopGroup r4
        \genericSpan #-6 #4 #-6 #4 \colDarkOrange \colLightOrange #0 #0 ##t ##f
        c8 ^"...and choose same color:" \startGroup e g c g e \stopGroup r4
      }
    }
    \new Staff {
      \relative c' {
        \override TextScript.staff-padding = #2
        \genericSpan #-4 #4 #-4 #4 \colDarkGreen \colLightGreen #0 #1 ##f ##f
        c8 ^"#0" \startGroup e g c g e^"#1" \stopGroup r4
        \genericSpan #-4 #4 #-4 #4 \colDarkViolet \colLightViolet #2 #0 ##f ##f
        \once \override HorizontalBracket.hair-thickness = #0.5
        c8 \startGroup e ^"#0.5" g c g e \stopGroup r4
        \genericSpan #-4 #4 #-4 #4 \colDarkPurple \colLightPurple #2 #0 ##f ##f
        \once \override HorizontalBracket.shorten-pair = #'(0 . 1)
        c8 ^"#'(0 . 1)" \startGroup e g c g e \stopGroup r4
        r2 ^"#-4 [default]"
        \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #2 #0 ##f ##f
        c8 \startGroup e g c
        g8 e \stopGroup r4 r2
        \genericSpan #-4 #4 #-4 #4 \colDarkOrange \colLightOrange #0 #0 ##t ##t
        c8 ^\markup {"open-on-bottom: ##t" \italic "and" "open-on-top: ##t"}
        \startGroup e g c g e \stopGroup r4
        \genericSpan #-6 #6 #-6 #6 \colDarkOrange \colLightOrange #0 #0 ##t ##t
        c8 \startGroup e g c g e \stopGroup r4
        \genericSpan #-6 #6 #-6 #6 \colDarkOrange \colLightOrange #0 #0 ##t ##t
        c8 \startGroup e g c g e \stopGroup r4
      }
    }
    \new Staff {
      \relative c' {
        \override TextScript.staff-padding = #2
        \genericSpan #-4 #4 #-4 #4 \colDarkGreen \colLightGreen #4 #3 ##f ##f
        c8 ^"#4"
        _\markup {
          \tiny
          \override #'(baseline-skip . 1.5) \left-column {
            "To avoid strange results," "stepLeft and stepRight" "should be a divisor of" "yUpper - yLower !"
          }
        }
        \startGroup e g c g e^"#3" \stopGroup r4
        \genericSpan #-4 #4 #-4 #4 \colDarkViolet \colLightViolet #2 #0 ##f ##f
        \once \override HorizontalBracket.hair-thickness = #1
        c8 \startGroup e ^"#1" g c g e \stopGroup r4
        \genericSpan #-4 #4 #-4 #4 \colDarkPurple \colLightPurple #2 #0 ##f ##f
        \once \override HorizontalBracket.shorten-pair = #'(-4 . -1)
        c8 ^"#'(-4 . -1)" \startGroup e g c g e \stopGroup r4
        r2 ^"#-8"
        \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #2 #0 ##f ##f
        \once \override HorizontalBracket.broken-bound-padding = #-8
        c8 \startGroup e g c
        g8 e \stopGroup r4 r2
        \genericSpan #-4 #4 #-4 #4 \colDarkYellow \colLightYellow #0 #0 ##f ##t
        c8 ^"open-on-top: ##t" \startGroup e g c g e \stopGroup r4
        \genericSpan #-4 #7 #-4 #7 \colDarkYellow \colLightYellow #0 #0 ##f ##t
        c8 \startGroup e g c g e \stopGroup r4
        \genericSpan #-4 #7 #-4 #7 \colDarkOrange \colLightOrange #0 #0 ##f ##t
        c8 _"to fake cross-staff boxes" \startGroup e g c g e \stopGroup r4
      }
    }

  >>
}

\pageBreak
\markup \vspace #1
\markup "Property: line-thickness"

\score {
  \relative c' {
    \override HorizontalBracket.line-thickness = #0.0
    \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #0 #2 ##f ##f
    c8 ^"#0" \startGroup e g c g e \stopGroup r4
    \override HorizontalBracket.line-thickness = #0.1
    \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #0 #2 ##f ##f
    c8 ^"#0.1" \startGroup e g c g e \stopGroup r4
    \override HorizontalBracket.line-thickness = #0.2
    \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #0 #2 ##f ##f
    c8 ^"#0.2" \startGroup e g c g e \stopGroup r4
    \override HorizontalBracket.line-thickness = #0.3
    \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #0 #2 ##f ##f
    c8 ^"#0.3" \startGroup e g c g e \stopGroup r4
    \break
    \override HorizontalBracket.line-thickness = #0.4
    \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #0 #2 ##f ##f
    c8 ^"#0.4" \startGroup e g c g e \stopGroup r4
    \override HorizontalBracket.line-thickness = #0.5
    \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #0 #2 ##f ##f
    c8 ^"#0.5" \startGroup e g c g e \stopGroup r4

    \override HorizontalBracket.line-thickness = #0.6
    \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #0 #2 ##f ##f
    c8 ^"#0.6" \startGroup e g c g e \stopGroup r4
    \override HorizontalBracket.line-thickness = #0.7
    \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #0 #2 ##f ##f
    c8 ^"#0.7" \startGroup e g c g e \stopGroup r4
    \break
    \override HorizontalBracket.line-thickness = #0.8
    \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #0 #2 ##f ##f
    c8 ^"#0.8" \startGroup e g c g e \stopGroup r4
    \override HorizontalBracket.line-thickness = #1.0
    \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #0 #2 ##f ##f
    c8 ^"#1.0" \startGroup e g c g e \stopGroup r4
    \override HorizontalBracket.line-thickness = #1.5
    \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #0 #2 ##f ##f
    c8 ^"#1.5"
    _\markup {\tiny \override #'(baseline-skip . 1.5)  \column {"Update: Values above stepLeft or stepRight" "now also will lead to sensible results."}}
    \startGroup e g c g e \stopGroup r4
    \override HorizontalBracket.line-thickness = #2.0
    \genericSpan #-4 #4 #-4 #4 \colDarkRed \colLightRed #0 #2 ##f ##f
    c8 ^"#2.0" \startGroup e g c g e \stopGroup r4

  }
}

\markup {
  \override #'(baseline-skip . 2)
  \column {
    \wordwrap {
      When line-thickness increases, the colored box will increase its X-extent to have the first and last note
      inside the box. However, it will NOT increase its Y-extent, because this is a value explicitly passed as a parameter.
    }
    \vspace #0.1
    \wordwrap {Is this reasonable/usable? What do you think?}
  }
}

\pageBreak
\markup \vspace #1
\markup "Some more tricks:"

\score {
  \relative c' {
    \override HorizontalBracket.line-thickness = #0.3
    \genericSpan #-4.5 #3.5 #-4.5 #3.5 \colDarkRed #white #0 #2 ##f ##f
    e8 ^\markup {
      \override #'(baseline-skip . 2) \left-column {
        "\"empty\" box: use" "#white as inner color"
      }
    } \startGroup g c e c g \stopGroup r4
    \genericSpan #-4.5 #3.5 #-4.5 #3.5 \colDarkRed \colLightRed #0 #2 ##f ##f
    c,16 \startGroup
    \once \override HorizontalBracket.line-thickness = #0.1
    \genericSpan #-4 #-1 #-4 #-1 \colDarkRed #white #0 #0 ##f ##f
    c32 ^"Boxes can be \"stacked\""
    \startGroup d \stopGroup
    e16
    \once \override HorizontalBracket.line-thickness = #0.1
    \once \override HorizontalBracket.layer = #-9
    \genericSpan #-3 #0 #-3 #0 \colDarkRed #white #0 #0 ##f ##f
    e32 \startGroup f \stopGroup g8 c g e8 \stopGroup r4
    \override HorizontalBracket.layer = #-9
    \genericSpan #-4.5 #3.5 #-4.5 #3.5 \colDarkRed \colLightRed #0 #2 ##f ##f
    c16 \startGroup
    \once \override HorizontalBracket.line-thickness = #0
    \genericSpan #-2.6 #-2.5 #-2.6 #-2.5 \colDarkRed #white #0 #0 ##f ##f
    \override HorizontalBracket.hair-thickness = #2
    \override HorizontalBracket.shorten-pair = #'(1.7 . 1.7)
    \once \override HorizontalBracket.layer = #-9
    c32 \startGroup d \stopGroup
    e16
    \once \override HorizontalBracket.line-thickness = #0
    \once \override HorizontalBracket.layer = #-9
    \genericSpan #-1.6 #-1.5 #-1.6 #-1.5 \colDarkRed #white #0 #0 ##f ##f
    e32 \startGroup f \stopGroup g8 c g e8 \stopGroup r4

  }
}

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

