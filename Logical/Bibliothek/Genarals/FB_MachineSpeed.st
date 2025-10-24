(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_MachineSpeed.st
 * Autor: awalz
 * Erstellt: 22. August 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_MachineSpeed
	lowPass.enable := TRUE;
	lowPass.x := INT_TO_REAL (dancepos);
	lowPass.t := 2;
	lowPass();
	lowPassSpeed.enable := TRUE;
	lowPassSpeed.x := INT_TO_REAL (ConveyerVelocity);
	lowPassSpeed.t := 2;
	lowPassSpeed();
//	lowPass.y_set := 0;
//	lowPass.set := TRUE;
//	rDancepos := INT_TO_REAL (dancepos) * SCALE_10V_TO_MM;
	rDancepos := lowPass.y * SCALE_10V_TO_MM;
	inc_to_volt := lowPassSpeed.y * SCALE_INC_TO_V;
	volt_to_speed := maxMainVelocity /10 * inc_to_volt; 
	TP_01( IN:= Start_timer,PT:= T#600ms);
	Start_timer := TRUE;
	rtrig(CLK:= TP_01.Q); (*Die Position geht von oben 400 bis Tänzer unten 830 *)
	IF rDancepos > (setDancerpos + 50)  AND volt_to_speed > 0 THEN (*Tänzer ist unterhalb der Sollpos Maschine soll schneller laufen*)
		velocityOffset := (velocityOffset + 0.1(*velocityStep*));
		test := 1;
		Start_timer := FALSE; (*timer reset *)
	ELSIF rDancepos < (setDancerpos - 50) AND volt_to_speed > 0 THEN (*Tänzer ist oberhalb der Sollpos Maschine soll langsamer laufen*)
		velocityOffset := (velocityOffset - 0.1(*velocityStep*));
		test := 2;
		Start_timer := FALSE;
	ELSIF ( rDancepos  = highlimitDancerpos OR rDancepos < highlimitDancerpos )AND volt_to_speed > 0THEN
		velocityOffset := 0; (*oberer Anschlag*)
		test := 3;
		Start_timer := FALSE;
	ELSIF (rDancepos  = lowlimitDancerpos OR rDancepos >  lowlimitDancerpos ) AND volt_to_speed > 0THEN
		velocityOffset := 1;  (*unterer Anschlag*)
		test := 4;
		Start_timer := FALSE;
	ELSIF (setDancerpos + 50) > rDancepos AND rDancepos > (setDancerpos - 50) AND volt_to_speed > 0 THEN (* Fenster in dem die Maschine richtige geschwindigkeit hat*)
		velocityOffset := velocityOffset;
		test := 5;
		Start_timer := FALSE;
	ELSIF volt_to_speed = 0 OR volt_to_speed < 0 THEN
		velocityOffset := 0;
		test := 6;
	END_IF  
	
	velocityramp.enable := TRUE;
	velocityramp.dy_down:= 0.1(* velocityStep*);
	velocityramp.dy_up	:= 0.1 (*velocityStep*);
	velocityramp.y_max := 1;
	velocityramp.y_min := -1;
	velocityramp.set := FALSE;
	velocityramp.x := velocityOffset;
	velocityramp();
	IF velocityramp.y <> 0 THEN
		tempvalue := floor(velocityramp.y* 10)/10; 
	END_IF
	velocityOffset := LIMIT (-1, velocityOffset, 1);
//	IF reset THEN
//		setVelocity := 0;
//		(*actualVelocity := 0;*)
//		reset := FALSE;
//	END_IF
	IF reset THEN
		setVelocity := LIMIT (0, volt_to_speed, 21); (*setVelocity;*) (*+ velocityOffset;*) (* Offset damit der Tänzer in der Mitte bleibt*) // OKrebs // statt 11 -> 21
	ELSE
		setVelocity := LIMIT (0,( volt_to_speed + tempvalue), 21); // OKrebs // statt 11 -> 21
	END_IF
	
END_FUNCTION_BLOCK