(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_MachineIOs.st
 * Autor: Awalz
 * Erstellt: 12. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_MachineIOs
	ampel(clk := panel.clk);
	CEEPlug_o := CEEPlugON;
END_FUNCTION_BLOCK