(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_MarkPoints.st
 * Autor: awalz
 * Erstellt: 8. Juli 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_MarkPoints
	
	IF Enable(* (R_TRIG_Enable.Q)*) THEN
		MC_BR_TouchProbe_0.Axis				:= Axis;
		MC_BR_TouchProbe_0.Period			:= ProductLength;
		MC_BR_TouchProbe_0.PeriodChange		:= 0.0;
		MC_BR_TouchProbe_0.ExpectedValue	:= ProductLength;
		MC_BR_TouchProbe_0.Mode				:= mcSHIFT_FROM_RESULT + mcUSE_FIRST_TRIGGER_POS;
		MC_BR_TouchProbe_0.TriggerInput		:= TriggerInput;
		MC_BR_TouchProbe_0.WindowNegative	:= WindowNegative;
		MC_BR_TouchProbe_0.WindowPositive	:= WindowPositive;
//		GetNextCuttPos.DistanceToSensor		:= DistanceToSensor;
//		GetNextCuttPos.ProductLength		:= REAL_TO_DINT(ProductLength);
		
	//SearchRM positive edge	
	ELSIF Enable AND SearchRM (* R_TRIG_SearchRM.Q*) THEN
		MC_BR_TouchProbe_0.Axis				:= Axis;
		MC_BR_TouchProbe_0.Period			:= ProductLength;
		MC_BR_TouchProbe_0.PeriodChange		:= 0.0;
		MC_BR_TouchProbe_0.ExpectedValue	:= 0.0;
		MC_BR_TouchProbe_0.Mode				:= mcSHIFT_FROM_RESULT + mcUSE_FIRST_TRIGGER_POS;
		MC_BR_TouchProbe_0.TriggerInput		:= TriggerInput;
		MC_BR_TouchProbe_0.WindowNegative	:= WindowNegative;
		MC_BR_TouchProbe_0.WindowPositive	:= WindowPositive;
//		GetNextCuttPos.DistanceToSensor		:= DistanceToSensor;
//		GetNextCuttPos.ProductLength		:= REAL_TO_DINT(ProductLength);
	END_IF

	IF NOT reset THEN
		IF Enable THEN
			MC_BR_TouchProbe_0.Enable	:= TRUE;
		ELSE 
			MC_BR_TouchProbe_0.Enable	:= FALSE;
		END_IF
	ELSE 
			MC_BR_TouchProbe_0.Enable	:= FALSE;
			ProbeCounter				:= 0;
			MissedTriggers				:= 0;
			reset := FALSE;
			markpointlist.reset := TRUE;
	END_IF
	(* füllen der Arrayliste*)
	MC_BR_TouchProbe_0();

	IF MC_BR_TouchProbe_0.ProbeCounter <> ProbeCounter THEN
		markpointlist.rdpos := MC_BR_TouchProbe_0.RecordedValue;
		lastrecocordedValue := MC_BR_TouchProbe_0.RecordedValue;
		markpointlist.new_Ident := TRUE;
		ProbeCounter := MC_BR_TouchProbe_0.ProbeCounter;
		RecordedValue		:= MC_BR_TouchProbe_0.RecordedValue;
	END_IF
//	markpointlist();
//	markpointlist.new_Ident := FALSE;
	IF MC_BR_TouchProbe_0.MissedTriggers <> MissedTriggers AND MC_BR_TouchProbe_0.ProbeCounter = ProbeCounter THEN (* soweit eine Marke verloren gegangen ist, wird feste Länge jedesmal dazu addiert*)
		markpointlist.rdpos := lastrecocordedValue + REAL_TO_DINT (ProductLength);(*(ActProductLength);*)
	(*	markpointlist.rdpos := MC_BR_TouchProbe_0.RecordedValue;*)
		lastrecocordedValue := markpointlist.rdpos;
		markpointlist.new_Ident := TRUE;
		MissedTriggers := MC_BR_TouchProbe_0.MissedTriggers;
		RecordedValue		:= markpointlist.rdpos;
	END_IF
	markpointlist();
	markpointlist.new_Ident := FALSE;
	//update FUB outputs
//	RecordedValue		:= MC_BR_TouchProbe_0.RecordedValue;
//	ProbeCounter		:= MC_BR_TouchProbe_0.ProbeCounter;
	(*MissedTriggers		:= MC_BR_TouchProbe_0.MissedTriggers;*)
	Busy				:= Enable OR MC_BR_TouchProbe_0.Busy;
	Active				:= MC_BR_TouchProbe_0.Active;
	
	IF MC_BR_TouchProbe_0.Active THEN
		ActProductLength	:= MC_BR_TouchProbe_0.Period + MC_BR_TouchProbe_0.DeltaExpectedValue;
	ELSE
		ActProductLength	:= 0.0;
	END_IF;
	
	IF MC_BR_TouchProbe_0.Enable THEN
		Error	:= MC_BR_TouchProbe_0.Error;
		ErrorID	:= MC_BR_TouchProbe_0.ErrorID;
	ELSIF NOT Enable THEN
		Error	:= FALSE;
		ErrorID	:= FALSE;
	END_IF;
END_FUNCTION_BLOCK