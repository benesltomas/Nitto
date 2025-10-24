(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: TorqueCtrl
 * File: TorqueCtrl.fun
 * Author: knausenbergl
 * Created: October 29, 2012
 ********************************************************************
 * Functions and function blocks of library TorqueCtrl
 ********************************************************************)

FUNCTION_BLOCK TC_Winder
	VAR_INPUT
		RefTension : ARRAY[0..1] OF REAL; (*reference material tension [N]*)
		RefDiameter : ARRAY[0..1] OF REAL; (*reference diameters corresponding to RefTension [Master Units]*)
		SetLineSpeed : REAL; (*line speed [Master Units / s]*)
		ActDiameter : REAL; (*actual winder diameter [Master Units]*)
		EncoderIf : ACP10ENCPA_typ; (*winder encoder interface*)
		GearRatio : REAL; (*motor rev. / winder rev. []*)
		LineUnits : REAL; (*line position scaling [Master Units / m]*)
	END_VAR
	VAR_OUTPUT
		SetWndSpeed : REAL; (*set winder speed [Slave Units / s]*)
		SetMotorTorque : REAL; (*set motor torque [Nm]*)
		SetTension : REAL; (*set material tension [N]*)
	END_VAR
	VAR
		IS : TC_WINDER_IS_TYP; (*internal data*)
	END_VAR
END_FUNCTION_BLOCK
