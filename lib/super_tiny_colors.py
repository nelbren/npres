#!/usr/bin/python3
#
# super-tiny-colors.py
#
# v0.0.1 - 2021-07-01 - nelbren@gmail.com
#

S='\033[0m'; E='\033[K'; n=f'{S}\033[38;5'; N='\033[9'; i='\033[30;48;5'; e='\033[7'; f='97m'
I=f'{e};49;9';O='\033[1;48;5';U='\033[4m';W='7m';M='5m';B='6m';A='7m';R='1m';G='2m';Y='3m'
nw=f'{S}';nm=f'{n};{M}';nb=f'{n};{B}';na=f'{n};{A}';nr=f'{n};{R}';ng=f'{n};{G}';ny=f'{n};{Y}'
nW=f'{N}{A}';nM=f'{N}{M}';nB=f'{N}{B}';nR=f'{N}{R}';nG=f'{N}{G}';nY=f'{N}{Y}';nA=f'{N}{A}'
iw=f'{e};49;{f}';im=f'{i};{M}';ib=f'{i};{B}';ir=f'{i};{R}';ig=f'{i};{G}';iy=f'{i};{Y}';ia=f'{i};{A}'
Iw=f'{I}{A}';Im=f'{I}{M}';Ib=f'{I}{B}';Ir=f'{I}{R}';Ig=f'{I}{G}';Iy=f'{I}{Y}';Ia=f'{I}{A}'
iW=f'{e};107;{f}';iM=f'{O};{M}';iB=f'{O};{B}';iR=f'{O};{R}';iG=f'{O};{G}';iY=f'{O};{Y}';iA=f'{O};{A}'
COK=Ig;CWA=Iy;CCR=iR;CUN=iM;CIN=Ib;CIN1=Ib;CIN2=Iw;CIN3=nW;CIN4=ia;CIN5=f'{U}{nY}'
cOK=nG;cWA=nY;cCR=nR;cUN=nM;cIN=nA

def examples1():
    print(f'BG:BLK/FG:COL:{nw}nw{nm}nm{nb}nb{nr}nr{ng}ng{ny}ny{na}na{S}S')
    print(f'BG:BLK/FG:HCO:{nW}nW{nM}nM{nB}nB{nR}nR{nG}nG{nY}nY{nA}nA{S}')
    print(f'BG:COL/FG:BLK:{iw}iw{S}{im}im{S}{ib}ib{S}{ir}ir{S}{ig}ig{S}{iy}iy{S}{ia}ia{S}')
    print(f'BG:HCO/FG:BLK:{Iw}Iw{S}{Im}Im{S}{Ib}Ib{S}{Ir}Ir{S}{Ig}Ig{S}{Iy}Iy{S}{Ia}Ia{S}')
    print(f'BG:COL/FG:HWH:{iW}iW{S}{iM}iM{S}{iB}iB{S}{iR}iR{S}{iG}iG{S}{iY}iY{S}{iA}iA{S}')


def examples2():
    print(f'{COK}OK{S}\n{CWA}WA{S}\n{CCR}CRI{S}\n{CUN}UNKN{S}\n{CIN1}INF1{S}\n{CIN2}INF2{S}\n{CIN3}INF3{S}\nNORMAL')

if __name__ == '__main__':
    examples1()         # uncomment to try
    examples2()         # uncomment to try
