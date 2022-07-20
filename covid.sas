/* Starter Code for an arbirary Y variable: cases per popdensity */
/* Change directory path in the DATAFILE */
PROC IMPORT DATAFILE='/home/u59232468/BSTT 401/covid.xlsx'
	DBMS=XLSX
	OUT=WORK.temp
	REPLACE;
	GETNAMES=YES;
RUN;



* Defining arbitrary new Y= CASE FATILITY RATE;

DATA TEMP;
     SET TEMP;
     IF DEATHS = . OR CASES = . THEN LCFR = .;
     ELSE IF cases=0 THEN LCFR =.;
     ELSE LCFR =log(1000*(DEATHS+0.001)/CASES);
     
RUN;

PROC CONTENTS DATA=WORK.temp; 
RUN;

proc print data = temp (obs = 100);

/* Note: Moderately large n and complex collinear Predictors */
/* SES predictors */
proc corr data=temp plots(maxpoints=100000)=matrix(hist);
var lcfr theme1  ;
run;
/* Health and HealthCare predictors */
proc corr data=temp plots(maxpoints=100000)=matrix(hist);
var lcfr  theme4;
run;
/* Preventive Public Health Meassures: Vaccine */
proc corr data=temp plots(maxpoints=100000)=matrix(hist);
var lcfr dose1;
run;
/* Preventive Public Health Meassures: Masking */
proc corr data=temp plots(maxpoints=100000)=matrix(hist);
var lcfr maskalways;
run;

*Geographical predictors;
proc corr data=temp plots(maxpoints=100000)=matrix(hist);
var lcfr theme7 ;
run;

DATA temp;
     set temp;
     If theme1 = 0 then ttheme1 = 0.001;
     if theme4 = 0 then ttheme4 = 0.001;
     If theme7 = 0 then ttheme7 = 0.001;
     if dose1 = 0 then tdose1 = 0.001;
     if masalways = 0 then tmaskalways = 0.001;

	ltheme1=log(ttheme1);
	ltheme4=log(ttheme4);
	ltheme7=log(ttheme7);
    ldose1=log(tdose1);
    lmaskalways=log(tmaskalways);	
run;

proc corr data=temp plots(maxpoints=100000)=matrix(hist);
var lcfr ltheme1  ;
run;
/* Health and HealthCare predictors */
proc corr data=temp plots(maxpoints=100000)=matrix(hist);
var lcfr  ltheme4;
run;
/* Preventive Public Health Meassures: Vaccine */
proc corr data=temp plots(maxpoints=100000)=matrix(hist);
var lcfr ldose1;
run;
/* Preventive Public Health Meassures: Masking */
proc corr data=temp plots(maxpoints=100000)=matrix(hist);
var lcfr lmaskalways;
run;

*Geographical predictors;
proc corr data=temp plots(maxpoints=100000)=matrix(hist);
var lcfr ltheme7 ;
run;
/* Very selective Predictive Model */
proc reg data=temp;
model lcfr= theme1 theme4 theme7 dose1 maskalways/ ss2 tol vif;
run;

Proc reg data = temp;
model lcfr= theme4 theme5 theme6/ selection=cp best=5;
/* Do reg. coeffcients making sense?
   Does dose165plus need transformation?
   Does including interaction between Urban and dose165plus/maskalways help?
*/

Proc reg data = temp;
model lcfr= Theme1 theme4 dose1 maskalways theme7/ collinoint selection=cp best=5;


Proc reg data = temp;
model lcfr= Theme1 theme4 dose165plus maskalways theme7 theme7*maskalways /P R CLM CLI SS1 SS2 ;

PROC SORT DATA = WORK.BDOSE;
          BY ;
PROC BOXPLOT DATA = WORK.BDOSE;
	         PLOT GROWTH*MALE / BOXSTYLE=schematicidfar;
	 
RUN;   

