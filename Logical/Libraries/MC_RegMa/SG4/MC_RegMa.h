#ifdef __cplusplus
extern "C" {
#endif

/* Automation Studio generated header file */
/* Do not edit ! */

#ifndef _MC_REGMA_
#define _MC_REGMA_

#include <bur/plctypes.h>

#ifndef _IEC_CONST
#define _IEC_CONST _WEAK const
#endif

/* Datatypes and datatypes of function blocks */
typedef struct MC_BR_RMTRIGGER_REF
{
	unsigned short EventSourceParID;
	unsigned char PosSource;
	unsigned char Edge;
	float MinWidth;
	float MaxWidth;
	float WindowNegative;
	float WindowPositive;
	float MasterInterval;
	unsigned short IntervalSourceParID;
	float IntervalLevel;
	unsigned short IntervalCompareMode;
	signed long SensorDelay;
} MC_BR_RMTRIGGER_REF;

typedef struct MC_BR_PRODUCT_REF
{
	float Length;
	float LengthChange;
	float LengthTolerance;
	float StartOffset;
	float RegMarkPosition;
	float DistanceToSensor;
	unsigned short SearchMode;
	unsigned short MissedTriggerCount;
} MC_BR_PRODUCT_REF;

typedef struct MC_BR_RMIMG_REF
{
	float Length;
	float LengthChange;
	float RegMarkPosition;
	float LengthTolerance;
	unsigned short SearchMode;
	unsigned short MissedTriggerCount;
	unsigned short EventSourceParID;
	unsigned char PosSource;
	unsigned char Edge;
	float MinWidth;
	float MaxWidth;
	float WindowNegative;
	float WindowPositive;
	float MasterInterval;
	unsigned short IntervalSourceParID;
	float IntervalLevel;
	unsigned short IntervalCompareMode;
	signed long SensorDelay;
	unsigned short LatchPM_Mode;
	unsigned short Camcon_InParID;
	unsigned short Capture_InParID;
	float IntervalStartDelay;
} MC_BR_RMIMG_REF;

typedef struct MC_0066_IS_TYP
{
	plcbit SearchTrigger;
	plcbit SearchTrigger_executed;
	plcbit InitData;
	plcbit Active;
	plcbit Valid;
	plcbit Busy;
	plcbit Error;
	unsigned short ErrorID;
	plcbit DataInitialized;
	unsigned short MasterParID;
	unsigned short Mode;
	struct MC_BR_RMTRIGGER_REF TriggerInput;
	struct MC_BR_PRODUCT_REF ProductParameters;
	plcbit SearchActive;
	unsigned short MissedTriggers;
	unsigned long ValidTriggers;
	float ActLength;
	float ActIntervalLength;
	float ActPosition;
	plcbit SearchDone;
	float LengthError;
	float PositionError;
	float AverageProductLength;
	float ArrayProductLength[51];
	unsigned char cntProductLengths;
	unsigned char cnt_Average;
	unsigned short state;
	unsigned short LastState;
	unsigned short NextState;
	unsigned short CAMCONID;
	unsigned short CMPID;
	unsigned short DelayID;
	unsigned short LatchID;
	plcbit new_LatchIVPos;
	signed long LatchIVPos;
	signed long LatchIVPos_old;
	plcbit new_LatchPMPos;
	unsigned char SptID;
	unsigned char LockIDSend;
	unsigned char LockIDReceive;
	signed long LatchPMPos;
	signed long LatchPMPos_old;
	unsigned char LatchPMErrCount;
	unsigned char LatchPMErrCount_old;
	plcbit Skip_LengthCalculation;
	unsigned char LatchPMStatusCount;
	plcbit LatchPM_reconfiguredtoSearch;
	unsigned short sendSlot;
	unsigned short readSlot;
	unsigned short LatchPMValueOffset;
	unsigned char LatchPMRecIndex;
	unsigned char LatchPMParIndex;
	unsigned short LatchIVValueOffset;
	unsigned char LatchIVRecIndex;
	unsigned char LockID;
	unsigned short LatchPMEOffset;
	unsigned char LatchPMERecIndex;
	unsigned char LockIDPar;
	unsigned short LatchPMSCOffset;
	unsigned char LatchPMSCRecIndex;
	unsigned char LockIDMa;
	struct MC_BR_RMIMG_REF IMG;
	plcbit InitDataCMP;
	plcbit InitDataCAMCON;
	plcbit InitDataLatchPM;
	plcbit InitDataInternal;
	plcbit ReInitializeMasterInterval;
	plcbit FUBModeChanged;
	plcbit Wait_for_valid_PM;
	unsigned short Wait_for_which_telegrams;
	unsigned char SavedFrDrvCnt;
	unsigned char Wait_for_telegrams;
	float IntervalStartDelay;
	signed long Latch_Init_value;
} MC_0066_IS_TYP;

typedef struct MC_RMCALC001_REF
{
	unsigned short Mode;
	float MaxDistanceCorrection;
	float MaxShiftCorrection;
	plcbit DistanceCorrectionClamp;
	plcbit AutoParamIntegrator;
	float DistanceGain;
	float DistanceIntegralTime;
	float ShiftGain;
	float ShiftIntegralTime;
	unsigned char ValuesForAveraging;
	unsigned char ValuesForQueuing;
} MC_RMCALC001_REF;

typedef struct MC_ADDINFO001_REF
{
	float LengthErrorFiltered;
	float DistancePAction;
	float DistanceIAction;
	float DistanceIntegralTime;
	float PositionErrorFiltered;
	float ShiftPAction;
	float ShiftIAction;
	float ShiftIntegralTime;
	float TimeBetweenRMs;
	float Reserve1;
	float Reserve2;
	float Reserve3;
	float Reserve4;
	float Reserve5;
} MC_ADDINFO001_REF;

typedef struct MC_0091_IS_TYP
{
	plcbit InitData;
	plcbit Reset;
	plcbit Calculate;
	float LengthError;
	float PositionError;
	struct MC_RMCALC001_REF ControllerParameters;
	plcbit Valid;
	plcbit Busy;
	plcbit Error;
	unsigned short ErrorID;
	plcbit DataInitialized;
	unsigned long ValidCorrections;
	float Distance;
	float Shift;
	plcbit LimiterActive;
	plcbit ShiftLimiterActive;
	plcbit DistanceLimiterActive;
	float LengthErrorQ[51];
	float PositionErrorQ[51];
	unsigned char QLength;
	unsigned char WriteIndex;
	plcbit FirstAfterEnable;
	unsigned long TickCountOld;
	unsigned short state;
} MC_0091_IS_TYP;

typedef struct MC_BR_RegMarkCapture001
{
	/* VAR_INPUT (analog) */
	unsigned long Master;
	unsigned long Axis;
	struct MC_BR_RMTRIGGER_REF TriggerInput;
	struct MC_BR_PRODUCT_REF ProductParameters;
	unsigned short Mode;
	unsigned short MasterParID;
	/* VAR_OUTPUT (analog) */
	unsigned short ErrorID;
	unsigned long ValidTriggers;
	unsigned short MissedTriggers;
	float ActLength;
	float ActIntervalLength;
	float ActPosition;
	float LengthError;
	float PositionError;
	float AverageProductLength;
	/* VAR (analog) */
	unsigned long C_Master;
	unsigned long C_Axis;
	struct MC_0066_IS_TYP IS;
	/* VAR_INPUT (digital) */
	plcbit Enable;
	plcbit SearchTrigger;
	plcbit InitData;
	/* VAR_OUTPUT (digital) */
	plcbit Active;
	plcbit Valid;
	plcbit Busy;
	plcbit Error;
	plcbit DataInitialized;
	plcbit SearchActive;
	plcbit SearchDone;
} MC_BR_RegMarkCapture001_typ;

typedef struct MC_BR_RegMarkCalc001
{
	/* VAR_INPUT (analog) */
	unsigned long Axis;
	float LengthError;
	float PositionError;
	struct MC_RMCALC001_REF ControllerParameters;
	/* VAR_OUTPUT (analog) */
	unsigned short ErrorID;
	unsigned long ValidCorrections;
	float Distance;
	float Shift;
	struct MC_ADDINFO001_REF AdditionalInfo;
	/* VAR (analog) */
	unsigned long C_Axis;
	struct MC_0091_IS_TYP IS;
	/* VAR_INPUT (digital) */
	plcbit Enable;
	plcbit InitData;
	plcbit Reset;
	plcbit Calculate;
	/* VAR_OUTPUT (digital) */
	plcbit Valid;
	plcbit Busy;
	plcbit Error;
	plcbit DataInitialized;
	plcbit ResetDone;
	plcbit DistanceLimiterActive;
	plcbit ShiftLimiterActive;
} MC_BR_RegMarkCalc001_typ;



/* Prototyping of functions and function blocks */
void MC_BR_RegMarkCapture001(struct MC_BR_RegMarkCapture001* inst);
void MC_BR_RegMarkCalc001(struct MC_BR_RegMarkCalc001* inst);



#endif /* _MC_REGMA_ */

#ifdef __cplusplus
};
#endif

