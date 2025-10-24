(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: VisuTasks
 * File: CalibrDiam.st
 * Author: schoenefeldr
 * Created: August 01, 2012
 *
 * History:
 * 2012-09-20 /schoenefeldr/
 * 		core diameter is not considered any more here. The offset
 *		has to be (best) identical to the real distance
 *
 ********************************************************************
 * Implementation of program VisuTasks
 ********************************************************************) 

(* Calibrate diameter sensor offset for machine recipe *)
FUNCTION CalibrDiam
	IF adr_AinData.Value.Scaled < adr_diamRecipe.CoreMinDiamSensor THEN
		// Actual sensor value outside range (too low)
		adr_diamOffs 	:= 0.0;
		CalibrDiam		:= CALIB_OFFSET_UNDERFLOW_ERROR;
	ELSIF adr_AinData.Value.Scaled > adr_diamRecipe.CoreMaxDiamSensor THEN
		// Actual sensor value outside range (too high)
		adr_diamOffs 	:= 0.0;
		CalibrDiam		:= CALIB_OFFSET_OVERFLOW_ERROR;
	ELSE
		// Actual sensor value in valid range
		adr_diamOffs 	:= adr_AinData.Value.Scaled;
		CalibrDiam		:= CALIB_OK;
	END_IF
END_FUNCTION