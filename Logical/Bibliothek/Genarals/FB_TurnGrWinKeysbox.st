(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_TurnGrWinKeysbox.st
 * Autor: Awalz
 * Erstellt: 5. Juni 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_TurnGrWinKeysbox
		GridWinrightkey(clk := clk);   (**)
		GridWinleftkey(clk := clk);
		feederturnkey(clk := clk);
		IF feederturnkey.LDT.rtrig.Q THEN
			(*feederlimitswitch:	BOOL;*)
			feederturn:= TRUE;
		(*	feederFUright:BOOL;*)
		ELSE 
			feederturn:= FALSE;
		END_IF
END_FUNCTION_BLOCK