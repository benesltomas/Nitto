(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: csv_hndl
 * File: DefRecipe.st
 * Author: beutert
 * Created: August 24, 2012
 ********************************************************************
 * Implementation of program csv_hndl
 *
 * History:
 * 2012-08-24 /beutert/
 *		Task created
 * 2012-11-01 /schoenefeldr/
 *		use actual settings instead of general default values
 ********************************************************************) 

 (* sets default values to recipe struct *)
ACTION DefRecipe: 

	// 2012-11-01 /schoenefeldr/
	// Copy values for default application recipe from actual settings
	memcpy(ADR(tmpRecipe), ADR(gApplRecipe), SIZEOF(tmpRecipe));


(*	memset(ADR(tmpRecipe), 0, SIZEOF(tmpRecipe));

	// 2012-09-18 /schoenefeldr/
	// Set default values for special input values
	tmpRecipe.general.maxVelocity			:= DEFAULT_MASTER_MAX_VELO;
	tmpRecipe.general.masterAcceleration 	:= DEFAULT_MASTER_AUTO_MODE_ACC;
	// Set default values for modes
	tmpRecipe.cutUnit1.mode		:= OPM_CUT_SYNC_CUT;
	tmpRecipe.cutUnit2.mode		:= OPM_CUT_SYNC_CUT;
	tmpRecipe.endModule.mode	:= OPM_END_MODULE_BELTS;
	tmpRecipe.grid1.mode		:= OPM_WIND_WINDER;
	tmpRecipe.grid2.mode		:= OPM_WIND_WINDER;
	tmpRecipe.longCut.mode		:= OPM_LONG_CUT_ENABLED;
	tmpRecipe.markpoint1.mode	:= OPM_RM_SENSOR_CONTROL;
	tmpRecipe.markpoint2.mode	:= OPM_RM_SENSOR_CONTROL;
	tmpRecipe.spender1.mode		:= OPM_WIND_BRAKE;
	tmpRecipe.spender2.mode		:= OPM_WIND_BRAKE;
	tmpRecipe.spender3.mode		:= OPM_WIND_BRAKE;
	tmpRecipe.tensionMeas.mode	:= OPM_WEB_TENSION_ENABLED;
*)

END_ACTION