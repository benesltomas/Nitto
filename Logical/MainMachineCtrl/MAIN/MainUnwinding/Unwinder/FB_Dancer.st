(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: UserSpilke
 * Datei: FB_Dancer.st
 * Autor: Awalz
 * Erstellt: 25. März 2014
 ********************************************************************
 * Implementierung der Library UserSpilke
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einzufügen *)
FUNCTION_BLOCK FB_Dancer
//((DINT_TO_REAL (DMS_In )) - offset) * SCALE_DINT_TO_400N) das ist die tasächliche Kraft was auf die Messwalze wirkt.Die Kraft wurde mit Hilfe einer ZUgwaage validiert*)
// da auf jede Seite der Bahn nur die Hälfte der Kraft wirkt muss um richtigkeitshalber die Auflösung halbiert werden
	pos_out := INT_TO_REAL (Pos) *SCALE_INT_TO_200MM;
	tension_output := REAL_TO_INT (setTension /(SCALE_100N_TO_INT));
	tension_scaled := (((DINT_TO_REAL (DMS_In )) - offset) * SCALE_DINT_TO_400N) /2;  
	
	FlengeDMS := CFG_FLENGE_DMS_AIN;
END_FUNCTION_BLOCK