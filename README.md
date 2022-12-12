# vdcoldbox

David Adams  
December 2022

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
*Unable to find duneproc setup* means that product was not installed in the same area as *dunerun*
and *command not found* suggests *dunerun* was not installed properly.

Alternatively, dunerun and duneproc will be installed automatically in ./deps and set up from there is a DUNE release tag is specified at set up, e.g.
<pre>
dunerun> ./start-shell v09_63_01d00
</pre>

## Running

Here are some interesting things to do inside this environment.

### Explicit datasets

We make use of *duneproc* which uses it's own notion of datasets to define the event input for a run.
A *duneproc* explicit dataset is just a collection of (logical) event file names.
The *duneproc* command finds the file list for dataset \<dsname> by searching the directory tree
$HOME/data/dune/datasets/ for a file name \<dsname>.txt.
You can create these by hand, copy or link some else's definitions or use the *duneproc* scripts
that use sam to locate the files for a run.

This definition of a dataset differs from that of sam which defines a data set with a query that is used to select files at run time.
A sam query is typically used to identify the files that comprise a *duneproc* dataset.
Common dataset definitions include all files from a run, a single file in a run, and the files containing a set of contiguous event numbers in a run.
Dataset definiton files for a run may be created with a find file command for the VD bottom coldbox data:
<pre>
duneproc> vdbcbFindFiles 11990
np02_bde_coldbox_run011990_0000_20211104T091015.hdf5
</pre>
and another for the VD top coldbox data:
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

Add a second argument with a directory name to write the file list to a dataset definition file in that directory.
If the argument '-' is used, the directory is in the standard area duneproc uses to search for dataset definitions.
This was done in the second example abovew.
The dataset name includes the run number and is the base name without extension of the dataset file, vdtcb000429 in the example above.

### Implicit (single-event datasets)

In addition to explicit datasets described above, there is also support for implicit datasets, i.e. those for which no
explicit dataset definition file exists.
At present, the only type of these are single-event datasets with names in the the form DDD-RRR-EEE where DDD is the run type,
RRR the run number and EEE the event number.
The latter two may contain any number of leading zeros.
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
The script list files as the are staged (or found to be already staged) finally producing with the message "Done" when all files are staged.
It does not terminate and may be interrupted with ctrl-C with the file staging continuaing in the background.
Run the command again to get the name of the log file with the list of staged files.

### Processing single events
This package emphasizes the processing of single events to generate dataprep event displays and plots of various metric (e.g. noise) vs. channel number.
The script *doOneEvent* is provided for this purpose. It calls *duneproc* which in turn issues the *lar* command.

#### CRP1 bottom data

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
you can navigate to the run directory and view the resulting plots in the browser or using the view notebook in that directory.

#### CRP1 top data

The following produces ADC-level event displays and pedestal and RMS vs. channel run 429 event 1 in the CRP1 top data:
<pre>
duneproc> ./doOneEvent vdt1proc 429 1
</pre>
The produced plots may be found at the bottom of [issue 1](https://github.com/dladams/vdcoldbox/issues/1).

#### CRP2+ top data

Top data was taken in 2022 with CRP2 and CRP3. These have very similar geometry and are collectively referenced as CRP2+.
Configurations are provided to create single event displays and noise vs. channel plots for raw (pedestal subtracted), calibrated
(common rough charge calibration) and calibrated with CNR (coherent noise removal) and weighted CNR.
The top-level fcl for these is vdt2proc-XXX.fcl with XXX = raw, cal, cnr and cnw, respectively. E.g.

<pre>
duneproc> ./doOneEvent vdt2proc-cal 1727 1
</pre>
  
#### CRU top run periods

Run periods from Elisabetta and sam:

| | | Runs | File names |
|----|----|-----|----|
| CRP1 | Nov-Dec 2021 | 401-1036 | RRR_FFR_cb.test |
| CRP1B | April 2022 | 1037-1372 | RRR_FFF_cb.test |
| CRP2 | June-July 2022 | 1373-1622 | RRR_FFF_A_cb.txt |
| CRP3 | September 2022 | 1623- | RRR_FFF_A_cb.test |
| CRP2 | November 2022 | | |

Cosmic runs from Laura Zambelli (https://indico.fnal.gov/event/57419):

| Date | E-field | Date | Runs |
|---|---|---|---|
| CRP2 | nominal | July 13, 2022 | 1521-4, 1527-31 |
| | | July 18, 2022 | 1543-47 |
| | | July 19, 2022 | 1553-55 |
| CRP3 | nominal | October 11, 2022 | 1723-24 |
| | | October 12, 2022 | 1727-43  |
| | | October 14, 2022 | 1779 |
| | | October 15, 2022 | 1797 |
| CRP2 | high | November 3, 2022| 1857-71 |
| | nominal | November 4, 2022 | 1883-86, 1892 |
| | high | November 4, 2022 | 1893, 1895-98 |

The nominal HV setting is (-1260, -360, 0, 900) V and high is (-1400, -450, 0, 950) V.
The above talk includes estimates of field strength and electron lifetime for some
of these runs.
The second set of CRP2 data were taken after repairing problems causing many dead channels.

### More to come...

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
