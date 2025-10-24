(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_ClkPulse.st
 * Autor: Awalz
 * Erstellt: 30. April 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_ClkPulse

CASE state OF
	CLOCK_ON:
		IF enable THEN
			Output := TRUE;
			timer(IN := FALSE);
			timer(IN := TRUE, PT := TimeOn);
		  	state:= CLOCK_WAIT_ON;
		END_IF

	CLOCK_WAIT_ON:
		timer();
		IF NOT enable THEN
			timer(IN := FALSE);
			Output := FALSE;
			state := CLOCK_ON;
		ELSIF timer.Q THEN
			timer(IN := FALSE);
			Output := FALSE;
			timer(IN := TRUE, PT := TimeOff);
	   		state := CLOCK_WAIT_OFF;
		END_IF

	CLOCK_WAIT_OFF:
		timer();
		IF NOT enable THEN
			timer(IN := FALSE);
			Output := FALSE;
			state := CLOCK_ON;
		ELSIF timer.Q THEN
			Output := TRUE;
			timer(IN := FALSE);
			timer(IN := TRUE, PT := TimeOn);
		   	state:= CLOCK_WAIT_ON;
		END_IF
	ELSE  						(* Unknown program state *)
		state:= CLOCK_ON;
	END_CASE
END_FUNCTION_BLOCK