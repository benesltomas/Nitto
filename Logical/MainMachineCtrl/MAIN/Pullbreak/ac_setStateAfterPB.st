(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_setStateAfterPB.st
 * Autor: Awalz
 * Erstellt: 7. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> Fügt eine neue Aktion zum IEC Programm oder Bibliothek </$Description$>*)
ACTION ac_setStateAfterPB: 
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