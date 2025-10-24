(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_MachineSetModeCtrl.st
 * Autor: Awalz
 * Erstellt: 27. März 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(*<$Description$> TODO: hier werden durch die EIgangssignale von Tatsen entspechende Kommandos gesetzt.Die Kommandos werden
 als cmd Eingangsvariable an die Einheiten wie CuttingUnit, Winder ect. weiter geleitet.</$Description$>*)
FUNCTION_BLOCK FB_MachineSetModeCtrl
	panel();
	safety();
	summerystartstop(panel:= panel, clk := panel.clk);
	safety.ResetStartupInhibit := NOT panel.LDTControlON.LDT.button;(*request safety speed*)
	(*safety.ResetStartupInhibit := panel.LDTRESET.LDT.rtrig.Q;*)
	safety.Control_OFF := panel.LDTControlOFF.LDT.button;
	safety.ResetSafeMC := panel.LDTRESET.LDT.button;
	(*status(value := ctrl.value);*)
		CASE state OF
			// idle
			// ======
		
		ST_IDLE:
				IF panel.LDTRESET.LDT.button THEN 
					timer (IN := FALSE);
				END_IF
				visuLocking := 0;
				IOs.controlOn := TRUE;
				timer(IN := safety.Request_ONdelay, PT := T#2s);
				(*timer(IN := panel.LDTControlON.LDT.button, PT := T#2s);*)
				ctrl.set := FALSE;
				ctrl(set := TRUE, value := CONST.MACHINEMODES.EMERGENCYSTOP);
				safety.manuelmode := FALSE;
				IF timer.Q THEN
				(*IF panel.LDTControlON.Value.InVal  THEN
					panel.LDTControlON.Value.ActOut	:= TRUE;*)
					ctrl(set := TRUE, value := CONST.MACHINEMODES.MANUAL);
					state := ST_MANUAL;
				END_IF
					
		ST_SAFETYSTOP: 

				safety.manuelmode := FALSE;
				visuLocking := 0;
				IF safety.Request_ONdelay THEN (*Rückmeldung der Safety PLC = Safety bereit*)
					ctrl(set := TRUE, value := CONST.MACHINEMODES.MANUAL);
					visuLocking := 0;
					state := ST_MANUAL;
				END_IF
				
		ST_AUTO:	//AUTOMATIC
				ctrl.set := FALSE;
				safety.manuelmode := FALSE;
				visuLocking := 0;
				IF NOT  summerystartstop.stop (*panel.LDTStop.LDT.button*) THEN
					ctrl (set := TRUE, value := CONST.MACHINEMODES.MANUAL);
					state := ST_MANUAL;
				ELSIF NOT safety.RequestSLS	THEN
					ctrl (set := TRUE, value := CONST.MACHINEMODES.MANUAL);
					state := ST_MANUAL;
				ELSIF  panel.Emergency.LDT.button OR NOT safety.RequestSTO THEN 
					ctrl(set := TRUE, value := CONST.MACHINEMODES.SAFETYSTOP);
					state	:= ST_SAFETYSTOP;
				ELSIF panel.LDTControlOFF.LDT.button THEN 
					ctrl(set := TRUE, value := CONST.MACHINEMODES.EMERGENCYSTOP);
					state := ST_IDLE;
				END_IF
			
		ST_MANUAL:		
				// No reaction on start if a discrete movement is running
				ctrl.set := FALSE;
				safety.manuelmode := TRUE;
				visuLocking := 1;
				IF NOT safety.RequestSTO OR NOT safety.Request_ONdelay OR panel.LDTControlOFF.LDT.rtrig.Q THEN
					ctrl(set := TRUE, value := CONST.MACHINEMODES.SAFETYSTOP);
					state := ST_SAFETYSTOP;
				ELSIF summerystartstop.start AND masterModul.ctrl.unitsStatus.ready THEN // 14.01.16 OKrebs "AND masterModul.status.ready" wurde dazu eingefügt
					ctrl(set := TRUE, value := CONST.MACHINEMODES.AUTOMATIC);
					state:= ST_AUTO;	
				END_IF
		END_CASE


END_FUNCTION_BLOCK