(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: UserSpilke
 * Datei: FB_MACHINE_MODE.st
 * Autor: Awalz
 * Erstellt: 24. März 2014
 ********************************************************************
 * Implementierung der Library UserSpilke
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einzufügen *)
FUNCTION_BLOCK FB_MACHINE_MODE
	IF set THEN 
		IF value < CONST.MACHINEMODES.MANUAL OR value > CONST.MACHINEMODES.EMERGENCYSTOP THEN
			text := 'UNDEF';
		ELSE
			text := CONST.MACHINEMODES.texts[value];
		END_IF
		set := FALSE;
	END_IF
END_FUNCTION_BLOCK