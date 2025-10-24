(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_WinderCtrl.st
 * Autor: okrebs
 * Erstellt: 6. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einzufügen *)
FUNCTION_BLOCK FB_WinderCtrl
	winderaxis(machineaxis := machineMaster, data := data, (*status := status*));
	(*die Daten später von der Visu bzw. dem Rezept setzen*)
	data.machData.frictionCompensation := 3;
	data.recipeData.minDiamTension := 20;
	data.recipeData.maxDiamTension := 80; 
	(* und auch auf Kraft N normieren *)
//	data.recipeData.mode := CONST.UNITMODEs.ENABLE;
	
//status.modeName := CONST.UNITMODEs.texts[1];
	status.ready := (*winderaxis.MC_ReadStatus_0.ContinuousMotion OR (AND *) NOT winderaxis.MC_ReadStatus_0.Disabled AND NOT winderaxis.MC_TorqueControl_0.Error;
	CASE StateCtrl OF
		CTRL_FIRST_START:
			busy := TRUE;
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;			
		CTRL_MANUAL_BEFORE:
			IF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
				BetrStatus(set := TRUE,value := CONST.MACHINEMODES.MANUAL);
				busy := FALSE;  
				(*clamp.init(clk := clk);*)
				chkStatus.enable := TRUE;
				err(reset := TRUE);
				timer(IN:= FALSE);
				state := ST_IDLE;
				firstStart := TRUE;
				StateCtrl := CTRL_MANUAL;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
				StateCtrl := CTRL_AUTO_BEFORE;
			END_IF
	
		CTRL_MANUAL:
			IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
				err(reset := TRUE);
				busy := TRUE;
				StateCtrl := CTRL_MANUAL_AFTER;
			ELSE
				(*winderaxis.enable := TRUE;*)
				ac_manualWinder; (*Aufruf der Action*)
			END_IF	
	
	

		CTRL_MANUAL_AFTER:
			chkStatus.enable := FALSE;
		ac_setStateAfterWinder; (*Aufruf der Action*)

		CTRL_AUTO_BEFORE:
			IF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
				BetrStatus(set := TRUE, value := CONST.MACHINEMODES.AUTOMATIC);
			(*clamp.init(clk := clk);*)
			chkStatus.enable := TRUE;
				err(reset := TRUE);
				busy := FALSE;
				state := ST_IDLE;
				winderaxis.enable := TRUE;
				StateCtrl := CTRL_AUTO;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
				StateCtrl := CTRL_MANUAL_BEFORE;
			END_IF

		(* ******************************** *)
		(* *********** AUTO *************** *)
		(* ******************************** *)
		CTRL_AUTO:
			IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
				err(reset := TRUE);
				busy := TRUE;				
				StateCtrl := CTRL_AUTO_AFTER;
			ELSE
				winderaxis.cmd := CONST.AXIS.START;
				(*ac_automatic();*)
			END_IF


		CTRL_AUTO_AFTER:
			chkStatus.enable := FALSE;
			winderaxis.cmd := CONST.AXIS.STOP;
			state := ST_IDLE;
			ac_setStateAfterWinder;

		CTRL_STOP_BEFORE:
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSE
				state := ST_IDLE;
				StateCtrl := CTRL_STOP;
			END_IF

		CTRL_STOP:
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSE
				CASE state OF
					ST_IDLE:
						state := ST_QUIT;

					ST_QUIT:
						state := ST_IDLE;
						StateCtrl := CTRL_STOP_AFTER;
				END_CASE
			END_IF

		CTRL_STOP_AFTER:
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
				StateCtrl := CTRL_MANUAL_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
				StateCtrl := CTRL_AUTO_BEFORE;
			END_IF

		CTRL_RESET_START:
			BetrStatus.set := TRUE;
			BetrStatus.value := CONST.MACHINEMODES.RESET;
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSE
				IF winderaxis.busy  OR winderaxis.cmd <> CONST.AXIS.NOACTION THEN
					winderaxis(cmd := CONST.AXIS.NOACTION, machineaxis := machineMaster, data := data(*, status := status*));
				ELSE
					winderaxis(cmd := CONST.AXIS.RESET, machineaxis := machineMaster, data := data(*, status := status*));
					StateCtrl := CTRL_RESET;
				END_IF
			END_IF

		CTRL_RESET: 
			winderaxis(machineaxis := machineMaster, data := data(*, status := status*));
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSE
				IF NOT winderaxis.busy THEN
					winderaxis.cmd := CONST.AXIS.NOACTION;
					StateCtrl := CTRL_RESET_AFTER;
				END_IF
			END_IF

		CTRL_RESET_AFTER:
			IF BetrCtrl.value = CONST.MACHINEMODES.RESET THEN
				busy := FALSE;
			ELSE
				busy := TRUE;
			(*clamp.init(clk := clk);*)
				err(reset := TRUE);
				IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
					StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
				ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
					StateCtrl := CTRL_SAFETYSTOP_BEFORE;
				ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
					StateCtrl := CTRL_SAFETYSTOP_BEFORE;
				ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
					supplydelay(IN:= TRUE, PT := T#8s);
					IF supplydelay.Q THEN
						winderaxis.cmd := CONST.AXIS.POWER_ON;
						busy := TRUE;
						supplydelay(IN:= FALSE);
						StateCtrl := CTRL_MANUAL_BEFORE;
					END_IF
				ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
					supplydelay(IN:= TRUE, PT := T#8s);
					IF supplydelay.Q THEN
						winderaxis.cmd := CONST.AXIS.POWER_ON;
						busy := TRUE;
						supplydelay(IN:= FALSE);
						StateCtrl := CTRL_AUTO_BEFORE;
					END_IF
				END_IF
			END_IF

		CTRL_SAFETYSTOP_BEFORE:
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSE
				BetrStatus.set := TRUE;
				BetrStatus.value := CONST.MACHINEMODES.SAFETYSTOP;
				state := ST_IDLE;
				StateCtrl := CTRL_SAFETYSTOP;
			END_IF

		CTRL_SAFETYSTOP:
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSE
				CASE state OF
					ST_IDLE:
						state := ST_QUIT;

					ST_QUIT:
						state := ST_QUIT;
						StateCtrl := CTRL_SAFETYSTOP_AFTER;
				END_CASE
			END_IF

		CTRL_SAFETYSTOP_AFTER:
			busy := FALSE;
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				busy := TRUE;
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
				supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					winderaxis.cmd := CONST.AXIS.POWER_ON;;
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_MANUAL_BEFORE;
				END_IF
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
					supplydelay(IN:= TRUE, PT := T#8s);
				IF supplydelay.Q THEN
					winderaxis.cmd := CONST.AXIS.POWER_ON;
					busy := TRUE;
					supplydelay(IN:= FALSE);
					StateCtrl := CTRL_AUTO_BEFORE;
				END_IF
			END_IF

		CTRL_EMERGENCYSTOP_BEFORE:
			(*axis.drvCtrl.resetRelease(ref := axis.ctrl.ref);*)
			BetrStatus(set := TRUE,value := CONST.MACHINEMODES.EMERGENCYSTOP);
			(*mode.status.set(value := CONST.MACHINEMODES.EMERGENCYSTOP);*)
			busy := FALSE;
			StateCtrl := CTRL_EMERGENCYSTOP;

		CTRL_EMERGENCYSTOP:
			winderaxis.cmd := CONST.AXIS.POWER_OFF;
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				;
			ELSE
				busy := TRUE;
				timer(IN := TRUE, PT := T#2s);
				StateCtrl := CTRL_EMERGENCYSTOP_AFTER;
			END_IF

		CTRL_EMERGENCYSTOP_AFTER:
			timer();
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				timer(IN := FALSE);
				BetrStatus(set := TRUE,value := CONST.MACHINEMODES.EMERGENCYSTOP);
				busy := FALSE;
				StateCtrl := CTRL_EMERGENCYSTOP;
			ELSIF timer.Q THEN
				timer(IN := FALSE);
				StateCtrl := CTRL_RESET_START;
			END_IF

		ELSE
			;
	END_CASE
END_FUNCTION_BLOCK