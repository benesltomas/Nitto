(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_Lamp.st
 * Autor: Awalz
 * Erstellt: 12. Mai 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_Lamp
 rtrig(CLK := button);
	ftrig(CLK := button);
 	IF aktion = CONST.LAMP.OFF THEN
 		output := FALSE;
	ELSIF aktion = CONST.LAMP.ON THEN
		output := TRUE;
	ELSIF aktion = CONST.LAMP.BLINK200 THEN
		output := clk.c200.Output;
	ELSIF aktion = CONST.LAMP.BLINK500 THEN
		output := clk.c500.Output;
	ELSIF aktion = CONST.LAMP.BLINK1000 THEN
		output := clk.c1000.Output;
	ELSIF aktion = CONST.LAMP.BLINK5000 THEN
		output := clk.c5000.Output;
	END_IF
		
	led := output;
	ledinv := NOT output;
	
END_FUNCTION_BLOCK