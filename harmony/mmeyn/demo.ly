\version "2.19.65"

\include "analysisFunctions.ily"
\include "analysisDegrees.ily"

\markup "Auch mit Vollkorn als Schriftart getestet."
%%{
\paper {
  #(define fonts
     (set-global-fonts
      #:roman "Vollkorn"))
}
%}

\markuplist {
  \fontsize #9
  \override #'(padding . 8)
  \override #'(baseline-skip . 19)
  \table #(make-list 7 CENTER) {
    \function #"T"
    \function #"S"
    \function #"Fis"
    \function #"t"
    \function #"s"
    \function #"d"
    \function #"DD"
    \function #"ss"
    \function #"/D"
    \function #"/DD"
    \function #"/T"
    \function #"T-7"
    \function #"D-7-9>"
    \function #"D-6-7-9>"
    \function #"DD-7"
    \function #"()D-v"
    \function #"[]DD-v"
    \function #"s-n"
    \function #"S-N"
    \function #"D_3-7"
    \function #"DD-v_5>"
    \function #"t_3^5"
    \function #"t^5-9"
    \function #"s^6-7"
    \function #"Es^5"
    \function #"(Tg_3^5"
    \function #"dP_3^5"
    \function #")/DD_5>^9<-4-7-6"
  }
}

#(set! uebermaessig-vertikal #t)

\markuplist {
  \fontsize #9
  \override #'(padding . 7)
  \override #'(baseline-skip . 19)
  \table #(make-list 5 CENTER) {
    \degree #"I"
    \degree #"vii"
    \degree #"IV<"
    \degree #"III>"
    \degree #"III.="
    \degree #"IV.>_6"
    \degree #"III.<-7"
    \degree #"V-7_5_6"
    \degree #"V-5<"
    \degree #"V-5=-7<"
    \degree #"V-=-5"
    \degree #"VII-o"
    \degree #"VII-o7"
    \degree #"VII-/o"
    \degree #"[]IV<-ü65"
    \degree #"(IV<-ü6"
    \degree #")II-ü43"
    \degree #"III>.<_3_4-7-9"
    \degree #"III_3_4-5-7-9"
    \degree #"VII-vvv"
  }
}
