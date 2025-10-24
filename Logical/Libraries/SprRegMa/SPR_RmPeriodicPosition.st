(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprRegMa
 * File: SPR_RmPeriodicPosition.st
 * Author: knausenbergl
 * Created: January 25, 2013
 ********************************************************************
 * Implementation of library SprRegMa
 ********************************************************************) 

(*<$Description$> Converts a DINT RegMark position into a periodic REAL RegMark position </$Description$>*)
FUNCTION_BLOCK SPR_RmPeriodicPosition
	IF (MasterPeriod > 0) THEN
		MasterModuloOffset	:= MasterPosition - REAL_TO_DINT(MasterPeriodicPosition);
		IF ( (RecordedValue - MasterModuloOffset) < 0) THEN
			DeltaPeriods	:= ( (RecordedValue - MasterModuloOffset) / MasterPeriod) - 1;
		ELSE
			DeltaPeriods	:= (RecordedValue - MasterModuloOffset) / MasterPeriod;
		END_IF;
		RmModuloOffset		:= MasterModuloOffset + (DeltaPeriods * MasterPeriod);
		Out					:= DINT_TO_REAL(RecordedValue - RmModuloOffset);
	ELSE
		Out	:= DINT_TO_REAL(RecordedValue);
	END_IF;	
END_FUNCTION_BLOCK