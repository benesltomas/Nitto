(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: acBuffercyclic.st
 * Autor: awalz
 * Erstellt: 27. November 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* Fügt eine neue Aktion zum IEC Programm oder Bibliothek *)
ACTION acBuffercyclic: 

	IF axis.ctrl.MC_ReadActualPosition_0.Position > 6555 AND axis.bufferaxis.MC_BR_VelocityControl_0.Active  THEN
		axis.bufferaxis.cmd := CONST.AXIS.STOP; (* da kein Endlageschalter vorhanden Moment abschalten*)
	END_IF

	IF keys.up.LDT.button THEN
			axis.bufferaxis.cmd := CONST.AXIS.JOG_POS;
	ELSIF keys.down.LDT.button THEN
			axis.bufferaxis.cmd := CONST.AXIS.JOG_NEG;
	ELSIF keys.down.LDT.ftrig.Q OR keys.up.LDT.ftrig.Q THEN 
		axis.bufferaxis.cmd := CONST.AXIS.NOACTION;	
//	ELSIF keys.home.LDT.button THEN
//		cmdCtrl.value := CONST.CUTTINGUNIT.CMDs.CALIBR;
//	ELSE
//		cmdCtrl.value := CONST.CUTTINGUNIT.CMDs.NO_CMD;
	END_IF
	buffertofullRtrig(CLK := online (*OR buffertofull*));

	IF NOT online THEN (*der Bahnspeicher darf nur bis zur Position X fahren*)
			axis.bufferaxis.override := 0;
		IF torquelow AND NOT keys.down.LDT.button AND NOT keys.up.LDT.button  THEN (*wird von der Klemmbalken gesetzt und soll der Speicher in Standstill versetzen*)
			axis.bufferaxis.cmd := CONST.AXIS.STOP;
		ELSIF axis.ctrl.MC_ReadActualPosition_0.Position > setposition 	AND  NOT keys.down.LDT.button AND NOT keys.up.LDT.button  THEN
			axis.bufferaxis.cmd := CONST.AXIS.STOP;
		ELSIF axis.ctrl.MC_ReadActualPosition_0.Position < setposition 	AND  NOT keys.down.LDT.button AND NOT keys.up.LDT.button AND NOT torquelow THEN
			axis.bufferaxis.cmd := CONST.AXIS.START;
		END_IF
	ELSE (*online muss der Puffer gefüllt werden bzw ständig voll sein*)
		IF torquelow THEN (*der Bahnspeicher darf bis zum oberen Endschalter fahren*)
			axis.bufferaxis.override := 0;
			axis.bufferaxis.cmd := CONST.AXIS.START;
		ELSE 	
			IF  axis.ctrl.MC_ReadActualPosition_0.Position < 6000 THEN (* Position gilt noch zu definieren*)
				axis.bufferaxis.override := 80; (* da beim Inlinebetrieb der Speicher keine Funktion hat*)
				axis.bufferaxis.cmd := CONST.AXIS.START;
			ELSIF  axis.ctrl.MC_ReadActualPosition_0.Position > 6000 THEN
				axis.bufferaxis.override := 0;
				axis.bufferaxis.cmd := CONST.AXIS.STOP;
			END_IF
		END_IF
	END_IF


END_ACTION