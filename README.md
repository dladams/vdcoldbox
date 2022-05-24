# vdcoldbox

David Adams  
May 2022

Software to analyze data from the 2021 vertical-drift cold box test.

## Installation

This is a top-level package that does not require any building. Simply check it out and work in that directory:
<pre>
cd &lt;workdir>
git https://github.com/dladams/vdcoldbox.git
cd vdcoldbox
</pre>

Most of the functionality provided by this package does require that [*dunerun*](https://github.com/dladams/dunerun) and
[*duneproc*](https://github.com/dladams/dunerun) be installed. See those pages for instructions.

## Set up

To set up to use the package, set up dunerun and then use it to start a shell that includes the *duneproc* and *dunesw* environments:
<pre>
source <install-path>/dunerun/setup.sh
dune-run -e dunesw,duneproc shell
cd &lt;workdir>/vdcoldbox
</pre>
Here the version of *dunesw* is that specified when *dunerun* was installed.

## Running

Available commands:

* Generate displays and metric vs. channel plots for one event with
no CNR, unweighted CNR and rawRMS-weighted CNR::
<pre>
./doOneEvent vdproc 11990 5
./doOneEvent vdproc-cnr 11990 5
./doOneEvent vdproc-cnrw 11990 5
</pre>

## Useful links

* [Bottom channel mapping](https://docs.dunescience.org/cgi-bin/sso/RetrieveFile?docid=23684)
* [Top channel mapping](https://indico.cern.ch/event/1073206/contributions/4513488/attachments/2303087/3917868/cbox_chmappin_v1p1.pdf)
* [Channel associations](https://cdcvs.fnal.gov/redmine/attachments/download/65665/vdcb_try2_offline_numbers_detector_strips.pdf)
* [Run list for new data](https://docs.google.com/spreadsheets/d/1JgQOv247h2tZKABBrK74LP3OenXL0vBJRn_uz9lKlrc)
