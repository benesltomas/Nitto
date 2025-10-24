(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_SPLICETABLE.st
 * Autor: Awalz
 * Erstellt: 5. Juni 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_SPLICETABLE	
	clampBefore(clk := clk, disable := disable);
	clampAfter(clk := clk, disable := disable);
	ready := NOT clampBefore.toDown_o AND NOT clampAfter.toDown_o;

END_FUNCTION_BLOCK