(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_Liftcrtl.st
 * Autor: awalz
 * Erstellt: 7. Oktober 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_Liftcrtl


buttomToggle(clk := clk);
	IF enable THEN 
		IF buttomToggle.LDT.button AND NOT isdown THEN
			toUp_o := FALSE; (* wenn die Taste gedrück ist und unterer Ini noch nicht gekommen ist*)
			toDown_o := TRUE;
		ELSIF NOT isup AND NOT isdown AND NOT buttomToggle.LDT.button THEN (* soweit die Tatse los gelassen wird fährt die Zugstation nach oben*)
			toDown_o := FALSE;
			toUp_o := TRUE;
//		ELSIF  buttomToggle.LDT.button AND  isdown THEN (* soweit der untere Ini gekommen ist dauerhaft unten halten*)
//			toDown_o := FALSE;
//			toUp_o := TRUE;
		ELSIF buttomToggle.LDT.rtrig.Q AND isdown THEN (*einmalige Betätigung um die Zugstation hoch fahren lassen*)
			toDown_o :=FALSE;
			toUp_o := TRUE;
		END_IF
	END_IF
		IF init THEN
		toUp_o := TRUE;
		init := FALSE;
	END_IF

END_FUNCTION_BLOCK