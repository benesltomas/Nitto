(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_StartStopbox.st
 * Autor: awalz
 * Erstellt: 27. Juni 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_StartStopbox
	start(clk:= clk);
	stop(clk := clk);
	jog(clk := clk);
	clk();
END_FUNCTION_BLOCK