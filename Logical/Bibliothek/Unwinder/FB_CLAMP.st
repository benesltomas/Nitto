(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_CLAMP_SPLICETABLE.st
 * Autor: Awalz
 * Erstellt: 5. Juni 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_CLAMP
	buttonDown(clk := clk);
	IF disable THEN
		toDown_o := FALSE;		
	ELSIF buttonDown.LDT.rtrig.Q (*buttonDown.LDT.button*) THEN
		IF toDown_o THEN
			toDown_o := FALSE;
		ELSE
			toDown_o := TRUE;
		END_IF
	ELSIF visutrigg.Q THEN
		IF toDown_o THEN
			toDown_o := FALSE;
		ELSE
			toDown_o := TRUE;
		END_IF
	END_IF
	buttonDown.LDT.aktion := SEL(toDown_o,CONST.LAMP.OFF, CONST.LAMP.ON);
	visutrigg(CLK := buttonvisu);
END_FUNCTION_BLOCK