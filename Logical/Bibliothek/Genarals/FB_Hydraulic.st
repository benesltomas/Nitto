(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_Hydraulic.st
 * Autor: Awalz
 * Erstellt: 23. Juni 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_Hydraulic
IF  enable THEN
	IF buttonUp AND NOT buttonDown AND NOT limitswitch THEN
		go_up := TRUE;
		LED_is_up:= TRUE;
		LED_is_down := FALSE;
		commonValve:=TRUE;(*main Valve right or left side*)
		pumpe:=TRUE;
	ELSIF buttonDown AND NOT buttonUp THEN
		go_up := FALSE;
		LED_is_down:=TRUE;
		commonValve:=TRUE;
	ELSIF NOT buttonDown AND NOT buttonUp THEN
		go_up := FALSE;
		LED_is_down := FALSE;
		commonValve:=FALSE;
		pumpe:=FALSE;
	END_IF
	IF limitswitch THEN
		LED_is_up :=TRUE;
		pumpe :=FALSE;
	ELSE
		LED_is_up :=FALSE; 
	END_IF
ELSE 
	go_up := FALSE;
	commonValve:=FALSE;
	pumpe:=FALSE;
	LED_is_down := FALSE;
END_IF
END_FUNCTION_BLOCK