(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_HandWheel.st
 * Autor: okrebs
 * Erstellt: 31. Juli 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_HandWheel
	IF safetyspeedrequest THEN	(* Safetyspeed ist quttiert Maschine kann schneller als 4.9m/min fahren*)
		IF (lastCounterValue < counterHandWheel) THEN
			setVelocity := (actualVelocity + velocityStep)/16666.67;
		ELSIF (lastCounterValue > counterHandWheel) THEN
			setVelocity := (actualVelocity - velocityStep)/16666.67;
		END_IF;
		setVelocity := LIMIT (1, setVelocity, limitspeed/16666.67);
		lastCounterValue := counterHandWheel;
		IF reset THEN
			setVelocity := 1;
			(*actualVelocity := 0;*)
			reset := FALSE;
		END_IF
	ELSE (* falls die Safetyspeed nicht quttiert war Geschwindkeit auf 3.9m/min begrenzen 3.9*16666,67=65000.67**)
		IF (lastCounterValue < counterHandWheel) THEN
			setVelocity := (actualVelocity + velocityStep)/16666.67;
		ELSIF (lastCounterValue > counterHandWheel) THEN
			setVelocity := (actualVelocity - velocityStep)/16666.67;
		END_IF;
		setVelocity := LIMIT (1, setVelocity,65000/16666.67); (*weil man davor so bescheident war und ständig umgerechnet hat muss es auch hier passieren*)
		lastCounterValue := counterHandWheel;
		IF reset THEN
			setVelocity := 1;
			(*actualVelocity := 0;*)
			reset := FALSE;
		END_IF
	END_IF
END_FUNCTION_BLOCK