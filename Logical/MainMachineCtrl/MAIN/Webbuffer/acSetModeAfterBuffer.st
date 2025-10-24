(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: acSetModeAfterBuffer.st
 * Autor: awalz
 * Erstellt: 10. Juli 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* Fügt einae neue Aktion zum IEC Programm oder Bibliothek *)
ACTION acSetModeAfterBuffer: 
	IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
		StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
	ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
		StateCtrl := CTRL_SAFETYSTOP_BEFORE;
	ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
		StateCtrl := CTRL_STOP_BEFORE;
	ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
		StateCtrl := CTRL_STOP_BEFORE;
	END_IF
END_ACTION