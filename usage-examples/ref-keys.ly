\version "2.20.0"

% Usage example for the \refKey function to indicate the
% reference key signature in harmonic analysis.
% (Also used as a usage example for openLilyLib properties.)

\include "oll-core/package.ily"
\loadModule analysis.harmony

% Initially there's a bunch of default properties
% which would be in effect without further configuration:
%{
#`((box-type ,box-type? "rounded-box")
   (box-padding ,number? 0.15)
   ; TODO: This is not implemented yet
   (box-thickness ,number? 1)
   (corner-radius ,number? 1)
   ;
   (color ,color? ,black)
   (font-name ,string-or-false? #f)
   (font-shape ,string? "upright")
   (font-family ,string? "roman")
   (font-series ,string? "bold")
   (font-size ,number? 0)
   (accidental-size ,number? 0)
   (raise-sharp ,number? 0.8)
   (raise-flat ,number? 0.4)
   (space-before-accidental ,number? 0.2)
   (space-before-separator ,number? 0.35)
   (key-separator ,string? ":")
   )
%}

% Properties can be set globally, (and also change throughout the document).
% Setting properties is the way to define a document-wide appearance
\setProperty analysis.harmony.ref-key font-shape italic
% Note that properties are type-checked.
% This fails with a warning but no effect
\setProperty analysis.harmony.ref-key color #'(3 . 5)

% Presets override a subset of available properties
\definePreset \with {
  color = #blue
  box-padding = 1
} analysis.harmony.ref-key default

% Through the (virtual) 'parent' property it is possible to create
% hierarchical (cascading) stylesheets for more complex documents.
\definePreset \with {
  parent = default
  box-type = none
  box-padding = 0.3
  space-before-separator = 0.7
} analysis.harmony.ref-key one

\definePreset \with {
  parent = default
  accidental-size = 4
  space-before-accidental = -0.75
} analysis.harmony.ref-key two

% Through "preset filters" it is possible to control which refKeys
% are displayed. Useful for example to reveal an analysis step by step.
% Play around with the three following filters to understand their effect.
%\setPresetFilters analysis.harmony.ref-key require-preset ##t
%\setPresetFilters analysis.harmony.ref-key use-only-presets one
%\setPresetFilters analysis.harmony.ref-key ignore-presets #'(one two)

{
  <<
    \new Staff {
      c' d' e' f' g' a' b' c''
      d'' c'' b' a' g' f' e' d'
      c'1
    }
    \new Lyrics \lyricmode {
       \skip2
       % simple invocation with a string for the key
       \refKey E
       D1
       % "<" and ">" produce accidentals
       \refKey E>
       T2
    }
    \new Lyrics \lyricmode {
      \skip1*2
      % Use presets
      \refKey \with { preset = one } C> T1
      \refKey \with { preset = two } F< S2
      % Use a preset but override individual properties
      \refKey \with {
        preset = one
        box-type = box
        font-size = -2
        color = #magenta
      } A s
    }
    \new Lyrics \lyricmode {
      \skip1*4
      % Heavily customized instance without preset
      % (would usually be configured as a preset)
      \refKey \with {
        box-type = hbracket
        box-padding = 0.3
        font-shape = upright
        font-size = 2
        accidental-size = -3
        raise-flat = -0.6
        space-before-accidental = 0
        key-separator = "=>"
        space-before-separator = 0.5
      } D>
      T
    }
  >>
}

\layout {
  \context {
    \Lyrics
    \override VerticalAxisGroup.nonstaff-nonstaff-spacing.minimum-distance = 6
  }
}