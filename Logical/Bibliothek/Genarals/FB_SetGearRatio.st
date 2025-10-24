(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_SetGearRatio.st
 * Autor: awalz
 * Erstellt: 2. Juli 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_SetGearRatio
	IF enable THEN
		Selectenable := TRUE;
		
		IF UpdateRecipe THEN
			UpdateRecipe := FALSE;
			setvalueVisu := setvalueVisuRecipe;
		END_IF
		offsetrecipe := setvalueVisuRecipe * 10;
		IF step1 THEN 
			step10 := FALSE;
			step := 1;
			stepvisu :=0.1;
			Selectstep1 := TRUE;
			Selectstep10 := FALSE;
			Selectstep100 := FALSE;
		ELSIF step10 THEN
			step1 := FALSE;
			step := 10;
			stepvisu := 1;
			Selectstep1 := FALSE;
			Selectstep10 := TRUE;
			Selectstep100 := FALSE;
		ELSIF step100 THEN
			step1 := FALSE;	
			stepvisu := 100;
			step := 100;
			Selectstep1 := FALSE;
			Selectstep10 := FALSE;
			Selectstep100 := TRUE;
		ELSE 
			Selectstep1 := FALSE;
			Selectstep10 := FALSE;
			step := 0;
		END_IF
		trigP(CLK := gearup );
		trigN(CLK := gearlow);
		IF trigP.Q THEN (*Stepper *)
		 	ratio := ratio + step;
			setvalueVisu := setvalueVisu + stepvisu;
			Start_timer := TRUE;
			trigger := TRUE;
		ELSIF trigN.Q THEN
			ratio := ratio - step;
			setvalueVisu := setvalueVisu - stepvisu;
			Start_timer := TRUE;
			trigger := TRUE;
	 	END_IF 
		(*ratioNumeratorOut:= LIMIT (800, ratio + REAL_TO_INT(offsetrecipe) ,1500) ;*)
		ratioNumeratorOut:= LIMIT (limitrationeg, ratio + REAL_TO_INT(offsetrecipe) ,limitratiopos);
		(*setvalueVisu := LIMIT (-20, setvalueVisu ,50);*)
		setvalueVisu := LIMIT (limitvisuneg, setvalueVisu ,limitvisupos);
		IF ratioNumeratorOut > ratioDenominator THEN
			ratio_inProcent_visu := (INT_TO_REAL(ratioNumeratorOut) - DINT_TO_REAL(ratioDenominator))/DINT_TO_REAL(ratioDenominator) *100;
		ELSE
			ratio_inProcent_visu := (INT_TO_REAL(ratioDenominator) - DINT_TO_REAL(ratioNumeratorOut))/DINT_TO_REAL(ratioDenominator) * -100;
		END_IF
		IF init THEN
			Start_timer := TRUE;
			trigger := TRUE;		// OKrebs 09.12.15
			init := FALSE;
		END_IF
		TP_01( IN:= Start_timer,PT:= T#1100ms);
		Start_timer := FALSE;
		IF NOT  TP_01.Q THEN
			trigger := FALSE;	
		END_IF
	ELSE 
		setvalueVisu := 0;
		ratioNumeratorOut := 1000;
		Selectenable := FALSE;
	END_IF
END_FUNCTION_BLOCK