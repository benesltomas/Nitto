(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: TorqueCtrl
 * File: TorqueCtrl.typ
 * Author: knausenbergl
 * Created: October 29, 2012
 ********************************************************************
 * Data types of library TorqueCtrl
 ********************************************************************)

TYPE
	TC_WINDER_IS_TYP : 	STRUCT 
		RefTension : ARRAY[0..1]OF REAL;
		RefDiameter : ARRAY[0..1]OF REAL;
		SetLineSpeed : REAL;
		ActDiameter : REAL;
		SetWndSpeed : REAL;
		SetMotorTorque : REAL;
		LineUnits : REAL;
		LCRLimScal_Tension : LCRLimScal; (*scale tension force depending on actual diameter*)
		GearRatio : REAL;
		EncoderIf : ACP10ENCPA_typ;
		WndUnitsPerLoadRev : REAL; (*winder units per load revolution [Slave Units]*)
		SetTorqueRaw : REAL; (*raw, unlimited set torque [Nm]*)
		SetTension : REAL;
	END_STRUCT;
END_TYPE
