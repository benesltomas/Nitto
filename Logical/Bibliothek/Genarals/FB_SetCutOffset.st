(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: SetCutOffset.st
 * Autor: okrebs
 * Erstellt: 23. Juli 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_SetCutOffset
	
	IF enable THEN
		
		IF UpdateRecipe THEN
			UpdateRecipe := FALSE;
			setvalueVisu := setvalueVisuRecipe/1000;
		END_IF
		
		Selectenable := TRUE;
		IF  step01 THEN 
			step1 := FALSE;
			step10 := FALSE;
			step := 0.1;
			stepvisu := 0.1;
			Selectstep01 := TRUE;
			Selectstep1 := FALSE;
			Selectstep10 := FALSE;
		ELSIF step1 THEN
			step01 := FALSE;
			step10 := FALSE;
			step := 1;
			stepvisu := 1;
			Selectstep01 := FALSE;
			Selectstep1 := TRUE;
			Selectstep10 := FALSE;
		ELSIF step10 THEN
			step01 := FALSE;
			step1 := FALSE;
			step := 10;
			stepvisu := 10;
			Selectstep01 := FALSE;
			Selectstep1 := FALSE;
			Selectstep10 := TRUE;
		ELSE 
			Selectstep01 := FALSE;
			Selectstep1 := FALSE;
			Selectstep10 := FALSE;
			step := 0;
		END_IF
		trigP(CLK := gearup );
		trigN(CLK := gearlow);
		IF trigP.Q AND setvalueVisu < limitvisupos - stepvisu THEN (*Stepper *)
			setvalueVisu := setvalueVisu + stepvisu;
		ELSIF trigN.Q AND setvalueVisu > limitvisuneg + stepvisu THEN
			setvalueVisu := setvalueVisu - stepvisu;	
		END_IF 
		
		IF setvalueVisu < -maxcorrection THEN
			setvalueVisu := -maxcorrection;
		ELSIF setvalueVisu > maxcorrection THEN
			setvalueVisu := maxcorrection;
		END_IF
			
//		setvalueVisu := LIMIT (-maxcorrection, REAL_TO_UDINT(setvalueVisu) ,maxcorrection);
	ELSE 
		setvalueVisu := 0;
		
		Selectenable := FALSE;
	END_IF
	setOffset_o := REAL_TO_DINT(setvalueVisu * 1000);
	
END_FUNCTION_BLOCK