(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_Panel.st
 * Autor: Awalz
 * Erstellt: 12. Mai 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_Panel
		clk();
		Emergency (clk := clk);
		
		EMCY_Button_o.0 := EMCY_Button;
		LDTRESET(clk := clk);
		LDTStop (clk := clk);
		LDTAutomatic (clk := clk);
		LDTControlON(clk := clk);
		LDTControlOFF(clk := clk);
		LDTJOG(clk := clk);
END_FUNCTION_BLOCK