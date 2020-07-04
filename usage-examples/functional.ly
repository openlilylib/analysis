\version "2.19.65"

\include "oll-core/package.ily"
\loadModule analysis.harmony.functional

\markup { Demonstration of \typewriter { analysis.harmony.functional, } initial implementation }

\markuplist {
  \fontsize #9
  \override #'(padding . 7)
  \override #'(baseline-skip . 19)
  \table #(make-list 7 CENTER) {
    \function T
    \function S
    \function D
    \function DD
    \function SS
    \function t
    \function s
    
    \function tP
    \function Tp
    \function Tg
    \function tG
    \function TG
    \function Dp
    \function Sp
    
    \function /D
    \function /DD
    \function /T
    \function ()D
    \function [DD-v]
    \function S-N
    \function s-n
    
    \function D-7
    \function D-7-9>
    \function D-6-7-9>
    \function DD-7_3
    \function DD-v_5>
    \function t_3-7<^5
    \function ""
    \function Fis
    \function Es^5
    \function As_3
    \function #"(dP_3^5"
    \function #")/DD_5>^9<-4-7-6"
  }
}
