(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_PowerBridge.st
 * Autor: Awalz
 * Erstellt: 2. Juni 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_PowerBridge
	toggle(clk:= clk);
	movebutton(clk := clk);
	bridgedownbutton(clk := clk);
	KNpressureOperside := INT_TO_REAL (pressureOperside) * SCALE_10V_TO_KN;
	KNpressuredrvside  := INT_TO_REAL (pressuredrvside) * SCALE_10V_TO_KN;
	IF withpressureSensor THEN 
		 IF KNpressuredrvside > pressurereference OR KNpressureOperside >  pressurereference THEN   (**)
			pressurepresent := TRUE;
		ELSE 
			pressurepresent := FALSE;
		END_IF 
	ELSE 
		IF button THEN 
			pressurepresent := TRUE;
			valveOut := TRUE;
		ELSE 
			pressurepresent := FALSE;
			valveOut := FALSE;
		END_IF
	END_IF
	
END_FUNCTION_BLOCK