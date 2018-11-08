% This document contains some test cases.
% It can be deleted as soon as the development
% of the "caption" property is finished.

\version "2.19.82"


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

\markup \wordwrap {
  This document contains some test cases.
  It can be deleted as soon as the development
  of the \typewriter caption property is finished.
}

pspc = \markup \vspace #0.25
spc = \markup \vspace #1

\setOption analysis.frames.caption \markup \with-color #white "blah"

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


\spc

\markup "border-radius: 0"
\pspc

\score {
  \relative c' {

    \genericFrame \with {
      border-width = 0.25
      border-radius = 0
    } {
      c8 ^"border-width 0.25"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 0.5
      border-radius = 0
    } {
      c8 ^"border-width 0.5"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 0.75
      border-radius = 0
    } {
      c8 ^"border-width 0.75"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 1
      border-radius = 0
    } {
      c8 ^"border-width 1"
      e g c g e
    }
    r4
  }
}


\spc

\markup "border-radius: 0.25"
\pspc

\score {
  \relative c' {

    \genericFrame \with {
      border-width = 0.25
      border-radius = 0.25
    } {
      c8 ^"border-width 0.25"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 0.5
      border-radius = 0.25
    } {
      c8 ^"border-width 0.5"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 0.75
      border-radius = 0.25
    } {
      c8 ^"border-width 0.75"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 1
      border-radius = 0.25
    } {
      c8 ^"border-width 1"
      e g c g e
    }
    r4
  }
}


\spc

\markup "border-radius: 0.5"
\pspc

\score {
  \relative c' {

    \genericFrame \with {
      border-width = 0.25
      border-radius = 0.5
    } {
      c8 ^"border-width 0.25"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 0.5
      border-radius = 0.5
    } {
      c8 ^"border-width 0.5"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 0.75
      border-radius = 0.5
    } {
      c8 ^"border-width 0.75"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 1
      border-radius = 0.5
    } {
      c8 ^"border-width 1"
      e g c g e
    }
    r4
  }
}


\spc

\markup "border-radius: 0.75"
\pspc

\score {
  \relative c' {

    \genericFrame \with {
      border-width = 0.25
      border-radius = 0.75
    } {
      c8 ^"border-width 0.25"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 0.5
      border-radius = 0.75
    } {
      c8 ^"border-width 0.5"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 0.75
      border-radius = 0.75
    } {
      c8 ^"border-width 0.75"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 1
      border-radius = 0.75
    } {
      c8 ^"border-width 1"
      e g c g e
    }
    r4
  }
}


\spc

\markup "border-radius: 1"
\pspc

\score {
  \relative c' {

    \genericFrame \with {
      border-width = 0.25
      border-radius = 1
    } {
      c8 ^"border-width 0.25"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 0.5
      border-radius = 1
    } {
      c8 ^"border-width 0.5"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 0.75
      border-radius = 1
    } {
      c8 ^"border-width 0.75"
      e g c g e
    }
    r4
    \genericFrame \with {
      border-width = 1
      border-radius = 1
    } {
      c8 ^"border-width 1"
      e g c g e
    }
    r4
  }
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


\score {
  \relative c' {

    \genericFrame \with {
      y-lower = #'(-7.5 . -2.5)
      caption-align-bottom = ##t
    } {
      g8
      e' g g' e c
    }
    r4
    \genericFrame \with {
      y-upper = #'(-1.5 . 10)
      y-lower = #'(-6.5 . -4.5)
    } {
      c,8
      e g c g e
    }

    r4
    \genericFrame \with {
      y-lower = #'(-4 . -6)
      y-upper = #'(6 . 1)
    } {
      c8
      e g c g e
    }
    r4
  }
}

\spc
\markup "caption-halign"
\pspc

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

\spc
\markup "caption-padding"
\pspc

\score {
  \relative c' {
    \genericFrame \with {
      caption = \markup \with-color #white "default: 0.25"
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "0.5"
      caption-padding = #0.5
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "1.0"
      caption-padding = #1
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "2.0"
      caption-padding = #2
    } {
      c8
      e g c g e
    }
    r4
  }
}

\markup "caption-color"
\pspc

\score {
  \relative c' {
    \genericFrame \with {
      caption = \markup \with-color #white "default: #f "
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "default: #f "
      border-color = \colDarkOrange
      color = \colLightOrange
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white "default: #f "
      border-color = \colDarkGreen
      color = \colLightGreen
    } {
      c8
      e g c g e
    }
    r4
    \genericFrame \with {
      caption = \markup \with-color #white " red "
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
      caption = \markup \line { \huge \rotate #20 \with-color #white any \bold \huge \concat { \with-color \colLightBlue mark \with-color \colLightGreen \italic up} }
      border-color = \colDarkOrange
      color = \colLightOrange
    } {
      c,8
      e g c g e c
    }
    r8
    \genericFrame \with {
      caption = \markup \translate #'(-1 . 1) \with-color #white "\\translate #'(-1 . 1)"
    } {
      c8
      e g c g e
    }
    r4
  }
}

\spc
\markup \line { Still a problem: ascenders and descenders --- \box É \box E \box e \box g \box "-" \box Pa \box pa \box ge \box no }
\pspc

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



\layout {
  \override TextScript.staff-padding = #7
  \context {
    \Score
    \remove "Bar_number_engraver"
  }
}

