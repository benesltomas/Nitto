(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_Counters.st
 * Autor: okrebs
 * Erstellt: 31. Juli 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_Counters
//	IF counter1.counter >= counter1.setPieces OR  counter2.counter >= counter2.setPieces OR counter3.counter >= counter3.setPieces
//	 OR counter4.counter >= counter4.setPieces OR 	counter5.counter >= counter5.setPieces OR counter6.counter >= counter6.setPieces
//	 OR counter7.counter >= counter7.setPieces OR 	counter8.counter >= counter8.setPieces OR counter9.counter >= counter9.setPieces AND NOT reset THEN
//		reset := TRUE;
//	END_IF
		
//	IF  setPieces <= counter2.counter OR setPieces <= counter4.counter OR setPieces <= counter6.counter OR
//		setPieces <= counter8.counter THEN
//		Nitto_Table_Full := TRUE;
//	END_IF
// new //26.07.18 // OKrebs
	IF  setPieces <= counter2.counter AND setPieces <= counter4.counter AND setPieces <= counter6.counter AND
		setPieces <= counter8.counter THEN
		Nitto_Table_Full := TRUE;
	END_IF

// new // OKrebs // 27.04.17
//	IF  setPieces <= counter2.counter AND setPieces <= counter4.counter AND setPieces <= counter6.counter AND
//		setPieces <= counter8.counter THEN
//		Nitto_Table_Full := TRUE;
//	END_IF
// end new

	IF EDGEPOS((5 <= counter2.counter AND 10 >= counter2.counter) OR
		(5 <= counter4.counter AND 10 >= counter4.counter) OR
		(5 <= counter6.counter AND 10 >= counter6.counter) OR
		(5 <= counter8.counter AND 10 >= counter8.counter) OR
		manualButton OR visureset)	THEN
		Nitto_Table_Full := FALSE;
	END_IF
	
//	IF visureset OR reset OR EDGEPOS(Nitto_Table_Full) OR manualButton THEN
//		reset := TRUE;
//		visureset := FALSE;
//	ELSIF NOT visureset OR NOT manualButton OR EDGENEG(Nitto_Table_Full)THEN
//		reset := FALSE;
//	END_IF

	TON_reset.PT := T#500ms;

	IF EDGEPOS(visureset OR Nitto_Table_Full OR manualButton) THEN
		TON_reset.IN := TRUE;
	END_IF

	
	


	reset := TON_reset.Q;

	counter1(reset := reset, setPieces := setPieces);
	counter2(reset := reset, setPieces := setPieces);
	counter3(reset := reset, setPieces := setPieces);
	counter4(reset := reset, setPieces := setPieces);
	counter5(reset := reset, setPieces := setPieces);
	counter6(reset := reset, setPieces := setPieces);
	counter7(reset := reset, setPieces := setPieces);
	counter8(reset := reset, setPieces := setPieces);
	counter9(reset := reset, setPieces := setPieces);
	IF validpieces <= counter1.counter OR validpieces <= counter2.counter 
		OR validpieces <= counter3.counter OR validpieces <= counter4.counter OR
		validpieces <= counter4.counter OR validpieces <= counter5.counter OR validpieces <= counter6.counter OR
		validpieces <= counter7.counter OR validpieces <= counter8.counter OR validpieces <= counter9.counter THEN
		valid := TRUE;
	//	Nitto_Table_Full := TRUE;
		(* für ein akusteisches Signal*)
	ELSE 
		valid := FALSE;
	END_IF

	IF TON_reset.Q THEN
		TON_reset.IN := FALSE;
	END_IF

	TON_reset();
	
	// 26.07.18 // OKrebs // Programm fuer die neue Ampel 
	TON_Nitto_Table_Full(IN := Nitto_Table_Full, PT := T#1s);
	TP_GreenLampOut.PT := T#4s;

	IF EDGEPOS(TON_Nitto_Table_Full.Q) THEN
		IF setPieces <> counter2.counterTemp OR setPieces <> counter4.counterTemp OR setPieces <> counter6.counterTemp OR
		setPieces <> counter8.counterTemp THEN 
		RedLampOut := TRUE;
		ELSE
		TP_GreenLampOut.IN := TRUE;
		END_IF
	END_IF

	IF VisuOKButton THEN
		RedLampOut := FALSE;
		GreenLampOut := FALSE;
	END_IF
	
	GreenLampOut := TP_GreenLampOut.Q;

	IF EDGENEG(TP_GreenLampOut.Q) THEN
		TP_GreenLampOut.IN := FALSE;
	END_IF

	TP_GreenLampOut();

END_FUNCTION_BLOCK