# [Super Tiny Colors Library](https://nelbren.github.io/en/terminal/2018/05/13/super-tiny-colors.bash/) [\[en Español\]](https://nelbren.github.io/es/terminal/2018/05/13/super-tiny-colors.bash/)

## What is it?
It is an ultra-super small compact and minimalist **library** (*done in 7 code lines*) used for scripts of [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)).

## How does it work?
This uses variables to set the colors, encapsulating in this way the direct use of the [ANSI color codes](https://misc.flogisoft.com/bash/tip_colors_and_formatting), accomplishing quickness, consolidation and independence.

## Wrapper of ANSI color codes:

- ### Use of ANSI color codes:

  ```bash
  echo -e "\e[40;38;5;82m Hello \e[30;48;5;82m World \e[0m"
  ```

  > Example of command execution:
  > ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/tip_colors_and_formatting.png?raw=true)

- ### Use of the super-tiny-colors:

  ```bash
  git clone git@github.com:nelbren/npres.git
  source /usr/local/npres/lib/super-tiny-colors.bash
  echo -e "${nG} Hello ${Iy} World $S"
  echo -e "${nG} Hello ${Ig} World $S"
  echo -e "${nG} Hello ${Ir} World $S"
  echo -e "${nG} Hello ${Iw} World $S"
  ```

  > Example of command execution:
  > ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/uso_de_super-tiny-colors.png?raw=true)

## How do I obtain it?

- ### Through [github](https://github.com/nelbren/npres.git) (recommended):
  
  ```bash
  cd /usr/local/
  git clone https://github.com/nelbren/npres.git
  ```

  *Repository of utilities of support of management of [Debian GNU/Linux](https://debian.org).*

- ### Through wget:

  ```bash
  wget https://raw.githubusercontent.com/nelbren/npres/master/lib/super-tiny-colors.bash
  ```

## How are the colors defined?

- ### Identification of colors:

  **Letter** | **Color**
  --- | ---
  w | white
  m | magenta
  b | blue
  r | red
  g | green
  y | yellow
  a | gray

- ### Format used by the library:

  Description | Background color | Front color | Example
  --- | --- | --- | --- 
  Normal | black | letter | ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/nr.png?raw=true)
  Normal **bright** | black | **LETTER** | ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/nG.png?raw=true)
  Inverse | letter | black | ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/ib.png?raw=true)
  Inverse ***bright color** | letter | black | ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/Iy.png?raw=true)
  Inverse **bright white** | **LETTER** | **white** | ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/iA.png?raw=true)

## Examples:

- ### examples1

  ```bash
  examples1
  ```

  > Example of command execution:
  > ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/examples1.png?raw=true) 

- ### examples2

  ```bash
  examples2
  ```

  > Example of command execution:
  > ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/examples2.png?raw=true) 

