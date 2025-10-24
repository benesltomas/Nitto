(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_Ampel.st
 * Autor: Awalz
 * Erstellt: 12. Mai 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_Ampel
	rtrig(CLK := horn);
	hornPuls(clk := clk);
	Rot(clk := clk);
	Gelb(clk := clk);
	Gruen(clk := clk);
	timer_TOF(IN := rtrig.Q, PT := ondelay);
//	horn_o := timer_TOF.Q;
	horn_o := SEL (timer_TOF.Q, hornPuls.led, timer_TOF.Q); (* pulsierendes Hupen zu erzeugen das Signal wird durch hornPuls von Aussen getaktet*)
END_FUNCTION_BLOCK