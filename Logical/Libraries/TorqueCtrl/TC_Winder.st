(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: TorqueCtrl
 * File: TC_Winder.st
 * Author: knausenbergl
 * Created: October 29, 2012
 ********************************************************************
 * Implementation of library TorqueCtrl
 *
 * History:
 * 2012-10-29 /knausenbergl/
 *		Task created
 * 2012-10-31 /schoenefeldr/
 *		Removed unused dynamic adaptation of force
 * 2012-11-01 /schoenefeldr/
 *		Removed unused inputs
 ********************************************************************) 

(* Calculate velocity and torque depending on force setpoint and diameter *)
FUNCTION_BLOCK TC_Winder
	
	//UPDATE FUB INPUTS
	IS.RefTension		:= RefTension;
	IS.RefDiameter		:= RefDiameter;
	IS.SetLineSpeed		:= SetLineSpeed;
	IS.ActDiameter		:= ActDiameter;
	IS.EncoderIf		:= EncoderIf;
	IS.GearRatio		:= GearRatio;
	IS.LineUnits		:= LineUnits;
	
	IS.WndUnitsPerLoadRev	:= UDINT_TO_REAL(IS.EncoderIf.scaling.load.units) * IS.GearRatio / UDINT_TO_REAL(IS.EncoderIf.scaling.load.rev_motor);
	
	//calculate set winder speed
	IF (IS.ActDiameter > 0.0) THEN
		IS.SetWndSpeed	:= IS.SetLineSpeed / (MATH_PI * IS.ActDiameter) * IS.WndUnitsPerLoadRev;
	ELSE
		IS.SetWndSpeed	:= 0.0;
	END_IF;	
	
	//calculate set tension depending on actual diameter
	IS.LCRLimScal_Tension.x		:= IS.ActDiameter;
	IS.LCRLimScal_Tension.x1	:= IS.RefDiameter[0];
	IS.LCRLimScal_Tension.y1	:= IS.RefTension[0];
	IS.LCRLimScal_Tension.x2	:= IS.RefDiameter[1];
	IS.LCRLimScal_Tension.y2	:= IS.RefTension[1];
	IS.LCRLimScal_Tension();
	IS.SetTension	:= IS.LCRLimScal_Tension.y;
	IS.SetTorqueRaw	:= IS.LCRLimScal_Tension.y * IS.ActDiameter / (2.0 * IS.GearRatio * IS.LineUnits);

	//UPDATE FUB OUTPUTS
	SetWndSpeed		:= IS.SetWndSpeed;
	SetMotorTorque	:= IS.SetTorqueRaw;	
	SetTension		:= IS.SetTension;

END_FUNCTION_BLOCK