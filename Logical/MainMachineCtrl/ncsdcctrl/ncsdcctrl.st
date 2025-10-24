PROGRAM _INIT

	(* initialize variables *)
	gUnwFeeder_HW.DrvIf_Typ := ncSDC_DRVSERVO16;
	strcpy( ADR(gUnwFeeder_HW.DrvIf_Name[0]), ADR('gUnwFeeder_DrvIf') );
	gUnwFeeder_HW.DiDoIf_Typ := ncSDC_DIDO;
	strcpy( ADR(gUnwFeeder_HW.DiDoIf_Name[0]), ADR('gUnwFeeder_DiDoIf') );

	(* force variable offset generation *)
	gUnwFeeder.size                      := gUnwFeeder.size;
	gUnwFeeder_DrvIf.iLifeCnt            := gUnwFeeder_DrvIf.iLifeCnt;
	gUnwFeeder_DiDoIf.iLifeCntDriveReady := gUnwFeeder_DiDoIf.iLifeCntDriveReady;
	gUnwFeeder_ModuleOk                  := gUnwFeeder_ModuleOk;


(* ### BEGIN gPackBelt ### *)
 
(* initialize variables *)
 gPackBelt_HW.DrvIf_Typ := ncSDC_DRVSERVO16;
 strcpy( ADR(gPackBelt_HW.DrvIf_Name[0]), ADR('gPackBelt_DrvIf') );
 gPackBelt_HW.DiDoIf_Typ := ncSDC_DIDO;
 strcpy( ADR(gPackBelt_HW.DiDoIf_Name[0]), ADR('gPackBelt_DiDoIf') );
  
(* force variable offset generation *)
 gPackBelt.size                      := gPackBelt.size;
 gPackBelt_DrvIf.iLifeCnt            := gPackBelt_DrvIf.iLifeCnt;
 gPackBelt_DiDoIf.iLifeCntDriveReady := gPackBelt_DiDoIf.iLifeCntDriveReady;
 gPackBelt_ModuleOk                  := gPackBelt_ModuleOk;
  
(* assign your hardware inputs here*)
 
(* gPackBelt_DiDoIf.iPosHwEnd  := gPackBelt_DiDoIf.iPosHwEnd;
 gPackBelt_DiDoIf.iNegHwEnd  := gPackBelt_DiDoIf.iNegHwEnd;
 gPackBelt_DiDoIf.iReference := gPackBelt_DiDoIf.iReference;
 *)
 
(* ### END gPackBelt ### *)

END_PROGRAM

PROGRAM _CYCLIC

(* ### BEGIN gLaminator ### *)
(* life counter emulation of digital inputs *)
	gUnwFeeder_DiDoIf.iLifeCntReference := gUnwFeeder_DiDoIf.iLifeCntReference + 1;
	gUnwFeeder_DiDoIf.iLifeCntNegHwEnd  := gUnwFeeder_DiDoIf.iLifeCntNegHwEnd  + 1;
	gUnwFeeder_DiDoIf.iLifeCntPosHwEnd  := gUnwFeeder_DiDoIf.iLifeCntPosHwEnd  + 1;
(* ### END gLaminator ### *)

(* ### BEGIN gPackBelt ### *)
 
(* life counter emulation of digital inputs *)
 gPackBelt_DiDoIf.iLifeCntReference := gPackBelt_DiDoIf.iLifeCntReference + 1;
 gPackBelt_DiDoIf.iLifeCntNegHwEnd  := gPackBelt_DiDoIf.iLifeCntNegHwEnd  + 1;
 gPackBelt_DiDoIf.iLifeCntPosHwEnd  := gPackBelt_DiDoIf.iLifeCntPosHwEnd  + 1;
 
	(* ### END gPackBelt ### *)
	
	


END_PROGRAM
