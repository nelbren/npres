# System Information Bar

## <i class="fa fa-question-circle" aria-hidden="true"></i> What is this?

### <i class="fa fa-quote-left" aria-hidden="true"></i> Scientia potentia est <i class="fa fa-quote-right" aria-hidden="true"></i>
***Knowledge is power.*** Knowing before hand or previewsly the system colapses or run out of resources, it becomes a priority, due to this, and to contemplate the panorama of programs that show us the resources and performance of our systems, **SI** arrives with a super powerful, fabulous and extremely concise bar of information of the actual resources.

## <i class="fa fa-globe" aria-hidden="true"></i> Tools with more detail:

- ### <i class="fa fa-terminal" aria-hidden="true"></i> Terminal:

  - #### <i class="fa fa-star" aria-hidden="true"></i> [sysstat - Performance monitoring tools for Linux](http://sebastien.godard.pagesperso-orange.fr/)

  - #### <i class="fa fa-star" aria-hidden="true"></i> [top - Dynamic real-time view of running processes](https://gitlab.com/procps-ng/procps)

  - #### <i class="fa fa-star" aria-hidden="true"></i> [htop - Interactive process viewer for Unix](https://hisham.hm/htop/)

  - #### <i class="fa fa-star" aria-hidden="true"></i> [conky-cli - Light-weight system monitor for terminal](https://github.com/brndnmtthws/conky)

  - #### <i class="fa fa-star" aria-hidden="true"></i> [glances - An Eye on your system. A top/htop alternative](https://nicolargo.github.io/glances/)

  - #### <i class="fa fa-star" aria-hidden="true"></i> [The Stress Terminal UI: s-tui](https://amanusk.github.io/s-tui/)

    - ##### <i class="fa fa-line-chart" aria-hidden="true"></i> pip install s-tui; apt install stress; s-tui
    ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/stress_s-tui.png)
    - ##### <i class="fa fa-tachometer" aria-hidden="true"></i> while true; do si; done
    ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/stress_si.png)

- ### <i class="fa fa-desktop" aria-hidden="true"></i> Web:

  - #### <i class="fa fa-star" aria-hidden="true"></i> [conky - Light-weight system monitor for X](https://github.com/brndnmtthws/conky)

  - #### <i class="fa fa-star" aria-hidden="true"></i> [munin - Networked resource monitoring tool](http://munin-monitoring.org/)

  - #### <i class="fa fa-star" aria-hidden="true"></i> [scout_realtime - Top for the modern developer](https://scoutapp.github.io/scout_realtime/)

  - #### <i class="fa fa-star" aria-hidden="true"></i> [eZ Server Monitor - Monitoring Linux servers](https://www.ezservermonitor.com/)

## <i class="fa fa-wrench" aria-hidden="true"></i> How does it work?
It is a sequence of commands from bash which extracts the information utilizing the tools from the system or the files of the process, according to the thresholds it assigns the color, and shows everything in a single line in less than 80 characters.

## <i class="fa fa-eye" aria-hidden="true"></i> Information shown:

  ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/sib_system-information-bar.png?raw=true)

## <i class="fa fa-arrow-circle-down" aria-hidden="true"></i> How do i obtain it?

- ### <i class="fa fa-github-square" aria-hidden="true"></i> Through [github](https://github.com/nelbren/npres.git):
  ```bash
  cd /usr/local/
  git clone https://github.com/nelbren/npres.git
  ```

## <i class="fa fa-info-circle" aria-hidden="true"></i> How do i use it?

- ### <i class="fa fa-sign-in" aria-hidden="true"></i> When logging in, , add to the file **/etc/profile**:
  ```bash
  . /usr/local/npres/bin/alias/set.bash
  ```

- ### <i class="fa fa-keyboard-o" aria-hidden="true"></i> By demand:
  ```bash
  si
  ```

## <i class="fa fa-eye" aria-hidden="true"></i> Examples:

- ### <i class="fa fa-sign-in" aria-hidden="true"></i> When logging in:
  Example of command execution:
  ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/sib_example_etc_profile.png?raw=true)

- ### <i class="fa fa-keyboard-o" aria-hidden="true"></i> By demand:
  Example of command execution:
  ![](https://github.com/nelbren/nelbren.github.io/blob/master/img/custom/sib_example_por_demanda.png?raw=true)

<hr class="small">

## <i class="fa fa-thumbs-up" aria-hidden="true"></i> Thanks to:

  - #### <i class="fa fa-male" aria-hidden="true"></i> Paul Colby <i class="fa fa-smile-o" aria-hidden="true"></i> by the code of [Calculating CPU Usage from /proc/stat](http://colby.id.au/calculating-cpu-usage-from-proc-stat/)
  - #### <i class="fa fa-male" aria-hidden="true"></i> Nelbren <i class="fa fa-smile-o" aria-hidden="true"></i> by the code of [si](https://github.com/nelbren/npres/blob/master/bin/system/si.bash)  
