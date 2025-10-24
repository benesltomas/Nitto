(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_manualUnwinder.st
 * Autor: Awalz
 * Erstellt: 7. April 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> Fügt eine neue Aktion zum IEC Programm oder Bibliothek </$Description$>*)
ACTION ac_manualWinder: 
		CASE state OF	
	ST_IDLE:
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
			state := ST_IDLE;
			err(reset := TRUE);
			busy := TRUE;
			status.ready := FALSE;
			StateCtrl := CTRL_MANUAL_AFTER;
		ELSE
			IF data.recipeData.mode = CONST.UNITMODEs.ENABLE AND NOT winderaxis.MC_TorqueControl_0.Error THEN 
				winderaxis.cmd := CONST.AXIS.START;
			ELSE 
				winderaxis.cmd := CONST.AXIS.STOP;
			END_IF
		(*	ButtonUp.lamp.aktion := SEL(unwinder.aushub.isup OR ButtonUp.key.inp, CONST.LAMP.OFF, CONST.LAMP.ON);
			ButtonDown.lamp.aktion := SEL(unwinder.aushub.isdown OR ButtonDown.key.inp, CONST.LAMP.OFF, CONST.LAMP.ON);
			unwinder.aushub.manual(
				buttonUP 	:=  ButtonUp.key.inp
									AND NOT unwinder.aushub.isup,
				buttonDown 	:=  ButtonDown.key.inp
									AND NOT unwinder.aushub.isdown);
(*			unwinder.brake.control(dancer := dancer, radius := unwinder.radius); *)
		(*	webGuidng.manual();
			unwinder.ctrl(cmd := unwinder.ctrl.cmdVISU, brake := unwinder.brake, aushub := unwinder.aushub, radius := unwinder.radius, dancer := dancer, status := unwinder.status, data := unwinder.data, machineMaster := machineMaster);
(*			status.ready := unwinder.status.ready; *)
		END_IF
	END_CASE
END_ACTION