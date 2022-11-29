# vdcoldbox

David Adams  
November 2022

Software to analyze data from the 2021-22 vertical-drift cold box tests.

## Installation

This is a top-level package that does not require any building. Simply check it out and work in that directory:
<pre>
> cd &lt;workdir>
> git https://github.com/dladams/vdcoldbox.git
> cd vdcoldbox
</pre>

Most of the functionality provided by this package does require that [*dunerun*](https://github.com/dladams/dunerun) and
[*duneproc*](https://github.com/dladams/dunerun) be installed. See those pages for instructions.
If you prefer, they may be automatically installed as described below.

## Set up

To set up to use the package, set up dunerun and then use it to start a shell that includes the *duneproc* and *dunesw* environments:
<pre>
> source &lt;install-path>/dunerun/setup.sh
dunerun> cd &lt;workdir>/vdcoldbox
dunerun> ./start-shell
duneproc>
</pre>
Here the version of *dunesw* is that specified when *dunerun* was installed.
If you do not get the duneproc prompt, look for and resolve any error messages.
Unable to find *duneproc* setup means that product was not installed in the same area as *dunerun*
and "command not found" suggests *dunerun* was not installed properly.

Alternatively, dunerun and duneproc will be installed automatically in ./deps and set up from there is a DUNE release tag is specified at set up, e.g.
<pre>
dunerun> ./start-shell v09_44_00d00
</pre>

## Running

Here are some interesting things to do inside this environment.

### Datasets

We make use of *duneproc* which uses it's own notion of datasets to define the event input for a run.
A *duneproc* dataset is just a collection of (logical) file names.
The *duneproc* command finds the file list for dataset \<dsname> by searching the directory tree
$HOME/data/dune/datasets/ for a file name \<dsname>.txt.
You can create these by hand, copy or link some else's definitions or use the *duneproc* scripts
that use sam to locate the files for a run.

This definition of a dataset differs from that of sam which defines a data set with a query that is used to select files at run time.
A sam query is typically used to identify the files that comprise a *duneproc* dataset.
Common dataset definitions include all files from a run, a single file in a run, and a set of contiguous event numbers in a run.
There is a find file command for the 2021 VD (i.e. CRP1) bottom coldbox data:
<pre>
duneproc> vdbcbFindFiles 11990
np02_bde_coldbox_run011990_0000_20211104T091015.hdf5
</pre>
and another for the CRP1 top coldbox data:
<pre>
duneproc> vdtcbFindFiles 429 -
429_100_cb.test
429_101_cb.test
429_102_cb.test
429_103_cb.test
429_104_cb.test
.
.
.
429_97_cb.test
429_98_cb.test
429_99_cb.test
429_9_cb.test
Dataset written to /home/dladams/data/dune/datasets/vdct/vdtcb000429.txt
</pre>

Add a second argument with a directory name to write the file list to a dataset (not a sam dataset) definition file in that directory.
If the argument '-' is used, the directory is in the standard area duneproc uses to search for dataset definitions.

### Single-event datasets

In addition to explicit datasets described above, implicit single-event datasets are also supported.
The names for these have the form DDD-RRR-EEE where DDD is the run type, RRR the run number and EEE the event number.
For vertical-drift coldbox data the run types (actually aliases) of interest are vdtcb and vdbcb for top and bottom data, respectively.

When *duneproc* receives such a dataset name, it uses the command *findRunFiles* to find the file holding the event and
the offset to that event in the file and configures *lar* to process only that one event.

### Staging and caching

DUNE raw data files are stored in a tape-backed dcache system and jobs may experience delays of many minutes, hours or
crash if the requested input files are not in the disk cache.
To help avoid this problem, the command *stageDuneDataset* may be used.
The single argument is the name of an explicit or implicit dataset.
For example, to stage the file holding event 5 of top run 11990:
<pre>
stageDuneDataset vdbcb-11990-5
</pre>

### CRP1 bottom data

The following can be used to generate performance plots for single events in the CRP1 bottom data, here event 5 in run 11990.
They generate event displays and metric vs. channel plots for one event respectively with
no CNR, unweighted CNR and rawRMS-weighted CNR::
<pre>
./doOneEvent vdb1proc 11990 5
./doOneEvent vdb1proc-cnr 11990 5
./doOneEvent vdb1proc-cnrw 11990 5
</pre>

Note the first argument in these commands is the base name of the fcl file in the local directory (e.g. vdbproc.fcl).
Use these as templates to create your own fcl files to run in the same way.
If that name does not begin with "vdb", prepend the arguments with "-b" to indicate bottom data is being processed.

Note that if this is command is run in a browser using an jupyter analysis station such https://analytics-hub.fnal.gov, then
you can navigate to the run directory and view the resulting plots in the browser.

### CRP1 top data

The following produces ADC-level event displays and pedestal and RMS vs. channel run 429 event 1 in the CRP1 top data:
<pre>
duneproc> ./doOneEvent vdtproc 429 1
</pre>
The produced plots may be found at the bottom of [issue 1](https://github.com/dladams/vdcoldbox/issues/1).

#### CRP top run periods

Run periods from Elisabetta:

| | | Runs | File names |
|----|----|-----|----|
| CRP1 | Nov-Dec 2021 | 401-1036 | RRR_FFR_cb.test |
| CRP1B | April 2022 | 1037-1372 | RRR_FFF_cb.test |
| CRP2 | June-July 2022 | 1373-1622 | RRR_FFF_A_cb.txt |
| CRP3 | Septembers 2022 | 1623- | RRR_FFF_A_cb.test |

### More to come...
We should add caibration and CNR to the top analysis and add support for CRP2 and following data.

## Tutorials
[tutorial01](doc/tutorial01) shows how to install this package.

## Useful links

### Dec 2021 data
* [Bottom channel mapping](https://docs.dunescience.org/cgi-bin/sso/RetrieveFile?docid=23684)
* [Top channel mapping](https://indico.cern.ch/event/1073206/contributions/4513488/attachments/2303087/3917868/cbox_chmappin_v1p1.pdf)
* [Channel associations](https://cdcvs.fnal.gov/redmine/attachments/download/65665/vdcb_try2_offline_numbers_detector_strips.pdf)
* [Run list for the Dec 2021 data](https://docs.google.com/spreadsheets/d/1JgQOv247h2tZKABBrK74LP3OenXL0vBJRn_uz9lKlrc)

### April-May 2022 data
* [Run list for BDE April-May 2022](https://docs.google.com/spreadsheets/d/1HSlHqMSSjlwgjpSRbHmaFRFWhb8ffSscm-nQMb22IDo/edit#gid=2099089212)

### July 2022 TDE CRP2 data
* July 2022 data taken cold with CRP2 (1st full TDE):  
  runs 1521-1524, 1527-1531, 1543-1547, 1553-1555, 1571-1575, 1594-1597, 1604, 1611-1618
* [Channel mapping](https://indico.fnal.gov/event/55195/contributions/245292/attachments/156692/204617/vg_crp2_cmap.pdf)
