\version "2.20.0"

\include "oll-core/package.ily"
\loadModule analysis.harmony

\definePreset \with {
  color = #red
  box-padding = 1
} analysis.harmony.ref-key default

\definePreset \with {
  parent = default
  box-type = ellipse
  box-padding = 0.3
  space-before-separator = 0.7
} analysis.harmony.ref-key one

\definePreset \with {
  parent = default
  accidental-size = 4
  space-before-accidental = -0.5
} analysis.harmony.ref-key two


{
  <<
    \new Staff { c' d' e' f' g' a' b' c' }
    \new Lyrics \lyricmode {
      \refKey  \with  { preset = one } C> T1
      \refKey  \with  { preset = two } F< S
    }
  >>
}
