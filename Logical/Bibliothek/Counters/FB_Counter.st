(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_Counter.st
 * Autor: okrebs
 * Erstellt: 31. Juli 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_Counter
	
	R_trig(CLK := triggerInput);
//	
//	IF counter = 0 THEN
//		counter := setPieces;
//	ELSE
	IF (*counter = setPieces*)FALSE THEN // OKrebs 27.04.17
		counter := 0;
	ELSE	
		IF R_trig.Q OR countPlusVisu THEN
			(*counter := counter - 1;*)
			counter := counter + 1;
		ELSIF countMinusVisu THEN
			counter := counter - 1;
//			IF counter = 0 THEN
//				counterTemp := counterTemp + 1;	
//			END_IF
		END_IF
	END_IF
	
	IF reset THEN
		counterTemp := counter; 
		counter := 0;
	END_IF
	
END_FUNCTION_BLOCK