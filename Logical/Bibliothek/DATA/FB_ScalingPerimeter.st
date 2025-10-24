(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_FB_CuttingCalcScalingFactor.st
 * Autor: Awalz
 * Erstellt: 19. Mai 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_ScalingPerimeter
		IF (NumberToolSegments > 0) THEN
		Remainder	:= REAL_TO_DINT(floor(realperimeter) ) MOD USINT_TO_DINT(NumberToolSegments); (* Anzahl der Nutzen ohne den Restwert*)
		
		IF (Remainder > USINT_TO_DINT(NumberToolSegments / 2) ) THEN
			Remainder	:= Remainder - USINT_TO_DINT(NumberToolSegments);
		END_IF;
		
		Scaledperimeter	:= DINT_TO_UDINT(REAL_TO_DINT(floor(realperimeter) ) - Remainder);
		ToolSegmentPeriod	:= Scaledperimeter / NumberToolSegments;
	ELSE
		Scaledperimeter	:= 0;
		ToolSegmentPeriod	:= 0;
	END_IF;	
END_FUNCTION_BLOCK