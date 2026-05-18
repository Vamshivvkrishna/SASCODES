LIBNAME RAWDATA "F:\rawdatasets\SDTM RAW";


DATA SDM;SET RAWDATA.DM ;RUN;

DATA SDM1;
SET SDM;
IF AGE < 65 THEN AGEGR1='<65';
ELSE 	AGEGR1='>=65';
TRT01P=STRIP(ARM);
TRT01A=STRIP(ACTARM);

if index(upcase(arm),'TREATMENT 1') > 0 then TRT01PN = 1;
  else                                       TRT01PN = 2;
  TRT01AN = TRT01PN;
keep studyid usubjid armcd subjid siteid 
       age ageu sex race ethnic country
       dthfl dthdtC rficdtc rfstdtC rfendtC
       TRT01P TRT01A TRT01PN TRT01AN AGEGR1;


RUN;

DATA EXS;
SET RAWDATA.EX;
RUN;

PROC SORT DATA=EXS OUT=EX1;BY USUBJID EXSTDTC;RUN
;
data ex_dates;
set ex1;
 by usubjid;
 retain trtsdt trtedt ;
if first.usubjid then 
trtsdt= EXSTDTC;
if last.usubjid then
trtedt= EXENDTC;
IF NOT MISSING(TRTSDT)  AND NOT MISSING(TRTEDT)  THEN 
trtdurd=trtedt-trtsdt+1;
/*if last.usubjid then do;*/
/*trtdurd=trtedt-trtsdt+1;end;*/
  format trtedt  trtsdt EXSTDTC EXENDTC YYMMDD10.;
  run;

  proc sort data=ex_dates out=exm;
  by usubjid;
  run;

  proc sort data=SDM1 out=dms;
  by usubjid;
  run;

  data dm_ex;
  merge dms(in=a) exm(in=b);
  by usubjid;
  if not missing(trtsdt) then saffl="Y";
  else saffl='';
if not missing(rficdtc) then enrlfl='Y';
else enrlfl='';
if armcd ne'' then ittfl="Y";
else ittfl='';
if ittfl='Y' and saffl="Y" then EFFFL='Y';
ELSE EFFFL='';
IF   ittfl='Y' and saffl="Y" AND EFFFL='Y' THEN PPROTFL="Y";
ELSE PPROTFL="Y";

  run;
