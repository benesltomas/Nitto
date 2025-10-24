(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_TensionMeasure.st
 * Autor: Awalz
 * Erstellt: 12. Mai 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_TensionMeasure
IF init THEN

	LCRPIDpara_TM.Kw						:= 1.0; // No weakening of input
	LCRPIDpara_TM.Kfbk						:= 2.0; // Anti-windup used
	LCRPIDpara_TM.d_mode					:= LCRPID_D_MODE_E;	// differentiate control deviation
	LCRPIDpara_TM.fbk_mode					:= LCRPID_FBK_MODE_INTERN;	// feedback of internal output
	PIDControler.mode						:= LCRPID_MODE_AUTO;	// Standard PID operating mode
	LCRPIDpara_TM.Kp						:= 1.0;
	LCRPIDpara_TM.Tn						:= 0.5;	// Integrative part
	LCRPIDpara_TM.Tv						:= 0.0; // D-part
	LCRPIDpara_TM.Tf						:= 0.020;
	LCRPIDpara_TM.WX_max					:= 1000.0;
	LCRPIDpara_TM.WX_min					:= -1000.0;
	PIDControler.ident						:= LCRPIDpara_TM.ident;
	// Maximum controller output:
	// 50.000 = 3 m/min
	PIDControler.Y_max						:= 100;	// percent
	PIDControler.Y_min						:= -100;	// percent

	// Set output scaling:
	//TensMeas.Data.scaleOut					:= TM_SCALE_PID_OUT_TO_OFFSET;

	//set filter time for tension sensor
	FilterPT1.V	:= 1.0;
	FilterPT1.T1:= TENSION_T_FILTER;
	FilterPT1.enable := TRUE;
	
	//sign of controller output
	//TensMeas.Para.InverseControl	:= TRUE;// ================
	init := FALSE;
END_IF 
	// READ INPUTS
	// ================
	
		FilterPT1(); (*Eingang filtern*)
		actValue := FilterPT1.y;
			// ================
	// CHECK ERRORS
	// ================

	IF (PIDControler.status > 12022) AND
	   (PIDControler.status < 65534) THEN
		// Error in PID controller detected -> stop control
		(*TensMeas.Data.mainStep		:= STEP_TM_CTRL_OFF;*)
		
	END_IF

	IF data.mode = CONST.UNITMODEs.DISABLE THEN (* hier noch velocity > 0 detektieren*)
		PIDControler.enable;
	
	END_IF
	
	status.mode := data.mode;
	IF status.mode = CONST.UNITMODEs.ENABLE THEN
		status.ready := TRUE;
	ELSE
		status.ready := FALSE;
	END_IF
		PIDControler ();
END_FUNCTION_BLOCK