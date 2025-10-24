(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_WebGuiding.st
 * Autor: awalz
 * Erstellt: 27. Juni 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_WebGuiding

	hardwareActive := hardwareOK; // Meldund für Visu Bahnkantenregelung ok

	IF enable THEN
		active := 1;
	ELSE
		active := 0;
	END_IF;
	
	handtrigg(CLK:= hand);
	centertrigg(CLK:=center);
	autotrigg(CLK := auto);
	IF centertrigg.Q(*center*) AND NOT TP_01.Q THEN
		manual := FALSE;
		neutral := TRUE;
		automatic:= FALSE;
		Start_timer := TRUE;
		centerSelect := TRUE;
		handSelect := FALSE;
		autoSelect := FALSE;

	ELSIF handtrigg.Q	(*hand*) AND NOT TP_01.Q THEN	
		manual := TRUE;
		automatic:= FALSE;
		neutral := FALSE;
		centerSelect:= FALSE;
		handSelect := TRUE;
		autoSelect := FALSE;
		Start_timer := TRUE;
		
	ELSIF autotrigg.Q	(*auto*) AND  NOT TP_01.Q THEN
		neutral  := FALSE;
		manual := FALSE;
		automatic:= TRUE;
		Start_timer := TRUE;
		centerSelect:= FALSE;
		handSelect := FALSE;
		autoSelect := TRUE;
	ELSE	

	END_IF;

	TP_01( IN:= Start_timer,PT:= T#1100ms);
	Start_timer := FALSE;
	IF NOT  TP_01.Q THEN
		neutral  := FALSE;
		manual := FALSE;
		automatic:= FALSE;
		
	END_IF;

	IF handSelect  THEN
		IF moveRight THEN
			arrowLeft  := TRUE;
		ELSE
			arrowLeft  := FALSE;	
		END_IF;
		IF	moveLeft THEN
			arrowRight := TRUE;
		ELSE
			arrowRight:= FALSE;	
		END_IF
			

	END_IF
END_FUNCTION_BLOCK