(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_getMode1.st
 * Autor: okrebs
 * Erstellt: 10. Juni 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* Fügt eine neue Aktion zum IEC Programm oder Bibliothek *)
ACTION ac_getMode: 
	busy := TRUE;(* nur Module die immer aktive sind*)
	IF NOT	UnwinderUnit.ctrl.busy AND NOT masterModul.ctrl.busy 
		AND NOT pullbreak.ctrl.busy (*AND NOT pullbreakSt.ctrl.busy *)AND NOT conveyor.ctrl.busy AND NOT catchbelt.ctrl.busy THEN
		IF  UnwinderUnit.ctrl.BetrStatus.value = tmpMode  AND masterModul.ctrl.BetrStatus.value = tmpMode 
			AND pullbreak.ctrl.BetrStatus.value = tmpMode (*AND pullbreakSt.ctrl.BetrStatus.value = tmpMode*) AND
			conveyor.ctrl.BetrStatus.value = tmpMode AND catchbelt.ctrl.BetrStatus.value = tmpMode THEN 
			busy := FALSE;
		END_IF
	END_IF				
END_ACTION