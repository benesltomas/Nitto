(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserRegMa
 * File: UserRegMa.typ
 * Author: knausenbergl
 * Created: October 19, 2012
 ********************************************************************
 * Data types of library UserRegMa
 ********************************************************************)

TYPE
	emuSprRmState : 
		(
		SPRRM_FIFO_DISABLED,
		SPRRM_FIFO_EMPTY,
		SPRRM_FIFO_EVALUATION_BUSY,
		SPRRM_FIFO_EVALUATION_DONE
		);
	SPR_RMCAPTURE_IS_TYP : 	STRUCT 
		MC_BR_TouchProbe_0 : MC_BR_TouchProbe;
		SPR_RmCalcPosError_0 : SPR_RmCalcPosError;
		R_TRIG_Enable : R_TRIG;
		R_TRIG_SearchRM : R_TRIG;
		ProbeCounter_1 : UDINT;
	END_STRUCT;
END_TYPE
