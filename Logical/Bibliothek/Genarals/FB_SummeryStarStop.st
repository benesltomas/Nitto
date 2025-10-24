(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_SummeryStarStop.st
 * Autor: awalz
 * Erstellt: 27. Juni 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_SummeryStarStop
	IF 	boxunwinder.jog.LDT.button OR boxwebbuffer.jog.LDT.button OR boxcutting1.jog.LDT.button
		OR boxlongcutter.jog.LDT.button OR boxconveyor.jog.LDT.button OR panel.LDTJOG.LDT.button OR boxlongcutter.jog.LDT.button THEN
		jog := TRUE;
	ELSE 
		jog := FALSE;
	END_IF
	IF 	boxunwinder.start.LDT.button OR boxwebbuffer.start.LDT.button OR boxcutting1.start.LDT.button
		(*OR boxlongcutter.start.LDT.button*) OR boxconveyor.start.LDT.button OR panel.LDTAutomatic.LDT.button THEN
		start := TRUE;
	ELSE 
		start := FALSE;
	END_IF	
	IF boxunwinder.stop.LDT.button AND  boxwebbuffer.stop.LDT.button AND  boxcutting1.stop.LDT.button
		(*AND  boxlongcutter.stop.LDT.button *)AND  boxconveyor.stop.LDT.button AND  panel.LDTStop.LDT.button THEN
		stop := TRUE;
	ELSE 
		stop := FALSE;
	END_IF	
	panel();
	boxunwinder(clk := clk);
	boxwebbuffer(clk := clk);
	boxcutting1(clk := clk);
	boxlongcutter(clk := clk);
	boxconveyor(clk := clk);
	clk();
END_FUNCTION_BLOCK
