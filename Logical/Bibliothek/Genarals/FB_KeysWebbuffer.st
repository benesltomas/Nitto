(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_KeysWebbuffer.st
 * Autor: awalz
 * Erstellt: 7. August 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_KeysWebbuffer
	up(clk:= clk);
	down(clk := clk);
	home(clk := clk);
	clk();
END_FUNCTION_BLOCK