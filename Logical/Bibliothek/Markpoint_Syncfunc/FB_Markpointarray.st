(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_Markpointarray.st
 * Autor: awalz
 * Erstellt: 16. Juli 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_Markpointarray
	bufferRtrig(CLK := new_Ident);
	IF  bufferRtrig.Q THEN (*Arraylist füllen*)
		poslist [ in_posIdent] := rdpos;
		out_posIdent:= in_posIdent - offset_posIdent; (* Berechnung des Offsets für den Druckmarkensensors verschiebung um X Marken zurück*)
		in_posIdent  := in_posIdent + 1;
		// Position Ausgangszeiger vor dem Weitersetzen berechnen
		//		actIdent	:= in_posIdent;
		
		points[visuIndex].pos := rdpos;
		points[visuIndex].lenght := points[visuIndex].pos - points[visuIndex - 1].pos;
		points[visuIndex].indx := in_posIdent;
		visuIndex := visuIndex + 1;
	END_IF
	
	maxposIdent := (SIZEOF (poslist) / SIZEOF (poslist[0])) - 1; (* Grpöße der Liste bestimmen*)
	IF in_posIdent > maxposIdent THEN
		in_posIdent := 0;
	END_IF
//		out_posIdent:= in_posIdent - offset_posIdent; (* Berechnung des Offsets für den Druckmarkensensor*)
	IF out_posIdent > maxposIdent THEN
			out_posIdent := out_posIdent + maxposIdent + 1;
	END_IF
//// Abfangen des out_lastIdent INdexes//////////////////////// 
	out_actIdent := in_posIdent - 1;
	IF out_actIdent > maxposIdent THEN
			out_actIdent := out_actIdent + maxposIdent + 1;	
	END_IF
	actpos := poslist [out_actIdent];(* aktulle Markenposition*)
	lastpos:= poslist [ out_posIdent];(*vorletzte bzw Markenposition mit einem Offset von X Markenlängen*)

	IF (in_posIdent > offset_posIdent) AND NOT valid THEN
		valid := TRUE;
	END_IF
	IF reset THEN
		valid := FALSE;
		in_posIdent := 0;
		visuIndex := 0;
		memset(ADR(points), 0, SIZEOF(points));
		reset := FALSE;
	END_IF
	IF visuIndex > maxVisuIndex THEN
		visuIndex := visuIndex - maxVisuIndex - 1;
	END_IF
END_FUNCTION_BLOCK
//
//	VAR_INPUT
//		index :  UDINT;  (**)
//		inpos :  REAL;  (**)
//		new_pos: BOOL
//	END_VAR
//	VAR 
//		index :  ARRAY[0..10] OF UDINT;  (**)
//		pos :   ARRAY [0..10] OF REAL;  (**)
//		in_pointer :USINT;
//		out_pointer:USINT;
//		maxpointer: USINT;
//	END_VAR
//	VAR_OUTPUT
//		actpos :REAL;
//		index_out: UDINT;
//	END_VAR