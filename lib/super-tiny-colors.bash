#!/bin/bash
#
# super-tiny-colors.bash
#
# v0.0.1 - 2018-01-02 - nelbren@gmail.com
# v0.0.2 - 2018-01-07 - nelbren@gmail.com
#
# https://notabug.org/demure/dotfiles
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
# https://stackoverflow.com/questions/19915208/extending-terminal-colors-to-the-end-of-line
#

S="\e[0m"; E="\e[K"; n="$S\e[38;5"; N="\e[9"; i="\e[30;48;5"; e="\e[7"; f="97m"
I="$e;49;9";O="\e[1;48;5";U="\e[4m";W=7m;M=5m;B=6m;A=7m;R=1m;G=2m;Y=3m
nw="$S";nm="$n;$M";nb="$n;$B";na="$n;$A";nr="$n;$R";ng="$n;$G";ny="$n;$Y"
nW="$N$A";nM="$N$M";nB="$N$B";nR="$N$R";nG="$N$G";nY="$N$Y";nA="$N$A"
iw="$e;49;$f";im="$i;$M";ib="$i;$B";ir="$i;$R";ig="$i;$G";iy="$i;$Y";ia="$i;$A"
Iw="$I$A";Im="$I$M";Ib="$I$B";Ir="$I$R";Ig="$I$G";Iy="$I$Y";Ia="$I$A"
iW="$e;107;$f";iM="$O;$M";iB="$O;$B";iR="$O;$R";iG="$O;$G";iY="$O;$Y";iA="$O;$A"
COK=$Ig;CWA=$Iy;CCR=$iR;CUN=$iM;CIN=$Ib;CIN1=$Ib;CIN2=$Iw;CIN3=$nW;CIN4=$ia;CIN5="$U$nY"
cOK=$nG;cWA=$nY;cCR=$nR;cUN=$nM;cIN=$nA

examples1() {
  echo -e "BG:BLK/FG:COL:${nw}nw${nm}nm${nb}nb${nr}nr${ng}ng${ny}ny${na}na${S}S"
  echo -e "BG:BLK/FG:HCO:${nW}nW${nM}nM${nB}nB${nR}nR${nG}nG${nY}nY${nA}nA$S"
  echo -e "BG:COL/FG:BLK:${iw}iw$S${im}im$S${ib}ib$S${ir}ir$S${ig}ig$S${iy}iy$S${ia}ia$S"
  echo -e "BG:HCO/FG:BLK:${Iw}Iw$S${Im}Im$S${Ib}Ib$S${Ir}Ir$S${Ig}Ig$S${Iy}Iy$S${Ia}Ia$S"
  echo -e "BG:COL/FG:HWH:${iW}iW$S${iM}iM$S${iB}iB$S${iR}iR$S${iG}iG$S${iY}iY$S${iA}iA$S"
}

examples2() {
  echo -e "${COK}OK$S\n${CWA}WA$S\n${CCR}CRI$S\n${CUN}UNKN$S\n${CIN1}INF1$S\n${CIN2}INF2$S\n${CIN3}INF3$S\nNORMAL"
}

#examples1         # uncomment to try
#examples2         # uncomment to try
