(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_GetNextCuttPos.st
 * Autor: awalz
 * Erstellt: 14. Juli 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_GetNextCuttPos
		(* füllen der Arrayliste*)
		markpoints();
		markpoints.markpointlist();
		setCutOffset.enable := TRUE;  (*Setzen des Korrekturwertes in der Visu*)
		setCutOffset();
		
		IF markpoints.reset OR reset THEN
			PositionError := 0;
		END_IF
	CASE State OF
		//FIFO is disabled, waiting for Enable
		ST_IDLE:
			PositionErrorValid	:= FALSE;
			PositionError		:= 0;
			indx := 0;	
			IF Enable THEN
				State	:= ST_READ_POS;				
			END_IF;
		
		//FIFO is enabled and empty
		ST_READ_POS:
			IF Enable THEN 
			(*	IF *)
			(*	masterposMod := REAL_TO_DINT(machinemaster.MC_ReadActualPosition_0.Position);*)
				markposMod :=  (actmarkpos MOD scalePerimeter.ToolSegmentPeriod);
				nextsyncpos := (CutPosition(*(masterposMod - actmarkpos)*) MOD scalePerimeter.ToolSegmentPeriod);(* für die Aufsynchronisierung in Config*)
//				IF ProductLength > 0 THEN 
//					markpoints.markpointlist.offset_posIdent := DINT_TO_USINT (DistanceToSensor / ProductLength);
//				END_IF
				IF ProductLength > 0 AND DistanceToSensor < ProductLength THEN 
					markpoints.markpointlist.offset_posIdent := DINT_TO_USINT (DistanceToSensor / ProductLength); 
				ELSIF DistanceToSensor > ProductLength THEN
					markpoints.markpointlist.offset_posIdent := 0;
				END_IF
				IncompensatinFtrig(CLK := donecut);(*Compensation Ende*)
				IF IncompensatinFtrig.Q THEN 
					oldCutPosition := CutPosition;
				END_IF 
				IncompensatinRtrig(CLK := donecut);(*Compensation Anfang*)
				IF IncompensatinRtrig.Q THEN 
					actCutPosition := CutPosition;
				END_IF
				IF 	IncompensatinRtrig.Q AND newdata <> indx THEN (*CorrectedCutPosition soll nur einmal gespeichert werden und nicht permanent sich ändern*)
				 	 (* wenn TRiggerereignes schon geschenen*)
					tmpCutPosition := actCutPosition;
					newdata := indx;
				ELSIF IncompensatinRtrig.Q AND newdata = indx THEN 
					tmpCutPosition := oldCutPosition; (* TRiggerereignes ist nocht nicht geschehen*)
					newdata := indx;
				END_IF
				CorrectedCutPosition	:= markpoints.markpointlist.lastpos + DistanceToSensor +  REAL_TO_DINT (setCutOffset.setOffset_o); (*RegMarkPosition*)
			(*	actmarkpos				:= markpoints.markpointlist.actpos + DistanceToSensor + REAL_TO_DINT (setCutOffset.setOffset_o); (*RegMarkPosition;*)
				IncompensatinRtrig(CLK := donecut);
				IF markpoints.ProbeCounter > 0 AND indx <> markpoints.ProbeCounter (*AND IncompensatinRtrig.Q *) THEN
					indx 				:= markpoints.ProbeCounter;
				END_IF
					IF markpoints.markpointlist.valid THEN (* Wert größer als NULL*) 
						(*Position für die Aufsynchronisierung des Querschneiders mit der Annahme das das Messer auf der 0 Position des Zylinders ist*)
						PositionErrorTemp		:=	CorrectedCutPosition  - (*tmpCutPosition;*)CutPosition;
					(*	PositionError			:= markpoints.markpointlist.actpos - markpoints.markpointlist.lastpos - ProductLength;*)(*tatsächliche Abweichung der Marken*)
				(*		newdata := 	indx;*)					
						counter := counter + 1;
						IF ABS (PositionErrorTemp) > ProductLength THEN (*Fängt den Überlauf des MC_Touchprobes ab*)
							PositionError := 0; 
						ELSE
							IF (PositionErrorTemp < (- ProductLength / 2) ) THEN
								PositionError := PositionErrorTemp + ProductLength;
							ELSIF (PositionErrorTemp > (ProductLength / 2) ) THEN
								PositionError := PositionErrorTemp - ProductLength;
							ELSE
								PositionErrorValid	:= TRUE;
								PositionError := PositionErrorTemp;
							END_IF
						END_IF
						PositionErrorValid	:= FALSE;
					(*	State			:= ST_READ_POS_DONE;*)
					END_IF
			(*	END_IF*)
			ELSE
				State	:= 	ST_IDLE;
			END_IF;
			
		ST_READ_POS_DONE:
			IF Enable THEN
				IF markpoints.ProbeCounter = indx AND markpoints.ProbeCounter > 0 THEN
					donecounter := donecounter + 1;
				(*	markpoints.new_Ident	:= FALSE;*)
					PositionErrorValid	:= FALSE;
					State	:= ST_READ_POS;
				ELSIF markpoints.ProbeCounter = 0 THEN
					State	:= ST_READ_POS;
				END_IF
			ELSE 
				State	:= 	ST_IDLE;
			END_IF
	END_CASE
END_FUNCTION_BLOCK