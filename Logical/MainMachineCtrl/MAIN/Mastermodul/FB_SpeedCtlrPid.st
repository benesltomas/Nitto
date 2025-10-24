(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_SpeedCtlrPid.st
 * Autor: awalz
 * Erstellt: 10. Dezember 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_SpeedCtlrPid
	IF firststart THEN
		LCRPIDpara_0.Kfbk			:= 2.0; // Anti-windup used
		LCRPIDpara_0.d_mode			:= LCRPID_D_MODE_E;	// differentiate control deviation
		LCRPIDpara_0.fbk_mode		:= LCRPID_FBK_MODE_INTERN;	// feedback of internal output
		LCRPID_0.mode				:= LCRPID_MODE_AUTO;	// Standard PID operating mod
		// 50.000 = 3 m/min
		LCRPID_0.Y_max				:= 10;	// percent
		LCRPID_0.Y_min				:= -10;// percent
		LCRPIDpara_0.invert			:= TRUE;
		LCRPIDpara_0.Kp				:= PID_Kp; //1.6; (*11*)//0.2//17.09.15 geändert 
		LCRPIDpara_0.Tn				:= 7;// 6;	//(*1.1*)//7 //17.09.15 geändert  
		LCRPIDpara_0.Tv				:= 0.0; // D-part
		LCRPIDpara_0.Tf				:= 0;(*0.020;*)
		LCRPIDpara_0.WX_max			:= 1000.0;
		LCRPIDpara_0.WX_min			:= -1000.0;
		LCRPID_0.ident				:= LCRPIDpara_0.ident;
		zeitkonstante				:= 0.1;
		lowPassEnable				:= TRUE;
		// Maximum controller output:
		firststart := FALSE;
	 END_IF 
	lowPass.enable := lowPassEnable;
	IF dancepos >32767 THEN (* weil der Sensor zu nahe sitzt gibt es ein Ünerlauf*)
		test := 2000;
	ELSE
		test := dancepos;
	END_IF
	lowPass.x := INT_TO_REAL (test);
	lowPass.t := zeitkonstante; //2
	lowPass();
	lowPassSpeed.enable := TRUE;
	lowPassSpeed.x := INT_TO_REAL (ConveyerVelocity); // analog Input from conveyer
	lowPassSpeed.t := 3;
	lowPassSpeed();
//	lowPass.y_set := 0;
//	lowPass.set := TRUE;
//	rDancepos := INT_TO_REAL (dancepos) * SCALE_10V_TO_MM;
	rDancepos := lowPass.y * SCALE_10V_TO_MM; // gefilterte Tänzer position in mm
	inc_to_volt := lowPassSpeed.y * SCALE_INC_TO_V;
	volt_to_speed := maxMainVelocity /10 * inc_to_volt;

	LCRPIDpara_0();
	//************************** LCRPID *******************************
	LCRPID_0.ident						:= LCRPIDpara_0.ident;
	// PID controller:
	//  setpoint  		"W" = dancer position from application recipe
	//  actual value	"X" = measured act dancer position from analog input (*override wird beim füllen draufgegebe*)
	LCRPID_0.W			:= LIMIT (0, setDancerpos , 1000);
	LCRPID_0.X			:= rDancepos;  (*LCRPT1e_ActTension.y;*)
	LCRPID_0();
	(*OutPID				:= LCRPID_TM.Y * TM_SCALE_PID_OUT_TO_OFFSET;*)


	IF reset THEN
		setVelocity := LIMIT (0, volt_to_speed, 21); (*setVelocity;*) (*+ velocityOffset;*) (* Offset damit der Tänzer in der Mitte bleibt*) // OKrebs // statt 11 -> 21
	ELSE
		IF lowPassSpeed.y < 600 THEN //  weil das Signal drunter nur ein Rauschen ist
			tempvalue	:= 0;
		ELSE
			tempvalue		:= LIMIT (-3, LCRPID_0.Y * TM_SCALE_PID_OUT_TO_OFFSET, 3(*maxMainVelocity*)) ;
		END_IF
//		setVelocity := LIMIT (0,( volt_to_speed + tempvalue), 11); // OKrebs 12.04.17
		
		IF startCycleWebturrit THEN  // OKrebs // 12.04.17 // ANFANG
			IF NOT dancerWasEmpty THEN (*1*)
				setVelocity := LIMIT (0, volt_to_speed + 2, 21); // Geschwindigkeit erhöhen bis Tänzer leer ist // // OKrebs // statt 11 -> 21
			END_IF
			IF rDancepos < minDancerPos THEN  (*2*)// Wenn Tänzer leer/oben ist				
				setVelocity := LIMIT (0, speedToCycleWebturrit, 21); // Geschwindigkeit verringern bis der Tänzer wieder voll ist // // OKrebs // statt 11 -> 21
				dancerWasEmpty := TRUE;
			END_IF
			IF dancerWasEmpty AND (rDancepos > maxDancerPos) THEN (*3*) // Wenn Tänzer wieder voll ist
				startCycleWebturrit := FALSE;
			END_IF
		ELSE
			setVelocity := LIMIT (0,( volt_to_speed + tempvalue), 21);  // // OKrebs // statt 11 -> 21
			dancerWasEmpty := FALSE;	
		END_IF // OKrebs // ENDE
		
	END_IF
	// ================
	// CHECK ERRORS
	// ================

	IF (LCRPID_0.status > 12022) AND
	   (LCRPID_0.status < 65534) THEN
//		// Error in PID controller detected -> stop control
		AxisStep		:= ST_CTRL_OFF;
	END_IF

	CASE AxisStep OF
		//********************* INITIALISATION ************************
		ST_INIT1:
			LCRPIDpara_0.enable		:= TRUE;
			LCRPIDpara_0.enter		:= FALSE;
			LCRPID_0.enable			:= FALSE; (* 10.12.14*)
			AxisStep					:= ST_READY;
			
		//********************* WAIT FOR COMMANDS ************************
		ST_READY:
				LCRPID_0.enable			:= FALSE;
				AxisStep		:= ST_WAIT_POWER_ENABLED;
			// End of STEP_TM_READY
		//********************* WAIT FOR DRIVES BEING ENABLED ************************
		ST_WAIT_POWER_ENABLED:
		(*	IF  MC_ReadStatus_0.StandStill OR  MC_ReadStatus_0.ContinuousMotion THEN*)
				AxisStep			:= ST_LOAD_PARA_START;
				// Generate rising edge at the enter input in order to update 
				// PID controller parameters
				LCRPIDpara_0.enter	:= FALSE;
			// End of STEP_TM_WAIT_POWER_ENABLED
		//********************* START PARAMETER LOADING ************************
		ST_LOAD_PARA_START:	
			// Rising edge for updating controller parameter
			LCRPIDpara_0.enter		:= TRUE;
			AxisStep				:= ST_WAIT_LOAD_PARA_DONE;
//		//********************* WAIT FOR PARAMETER LOAD COMPLETE ************************
		ST_WAIT_LOAD_PARA_DONE:
			LCRPIDpara_0.enter		:= FALSE;
			AxisStep				:= ST_WAIT_SWITCH_CTRL_ON;
			// End of STEP_TM_WAIT_LOAD_PARA_DONE
//
//		//********************* ACTIVATE CONTROL ************************
		ST_WAIT_SWITCH_CTRL_ON:
			IF   (LCRPIDpara_0.ident <> 0)  THEN
				// Enable PID controller and Offset correction for web tension control
				LCRPID_0.enable				:= TRUE;
			(*	AxisStep						:= ST_CTRL_ACTIVE*);
			ELSIF reset THEN 
				AxisStep := ST_INIT1;
			END_IF

	END_CASE




END_FUNCTION_BLOCK