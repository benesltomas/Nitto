(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * File: RCP_Glob.typ
 * Author: beutert
 * Created: September 07, 2012
 * 
 * History:
 * 2012-09-20 /schoenefeldr/
 * 		Added linearisation parameters for diameter sensors to recipe
 * 
 * 
 * 
 ********************************************************************
 * Global data types of project csv_bsp
 ********************************************************************)
(*======================================================================================================================================*)
(*GENERAL DATA*)
(*======================================================================================================================================*)

TYPE
	Button_typ : 	STRUCT 
		F1 : USINT;
		F2 : USINT;
		F3 : USINT;
		F4 : USINT;
		F5 : USINT;
		F6 : USINT;
		F7 : USINT;
		F8 : USINT;
		F9 : USINT;
		F10 : USINT;
		F11 : USINT;
		F12 : USINT;
		Status : ARRAY[0..12]OF UINT;
	END_STRUCT;
END_TYPE

(*======================================================================================================================================*)
(*MACHINE RECIPE DATA*)
(*======================================================================================================================================*)

TYPE
	rcp_machine_Wind_Type : 	STRUCT  (*Diameter offsets and additional sensor parameters*)
		DiamOffsMainUnw : REAL; (*Diameter offset value (distance from sensor to core) [mm]*)
		DiamOffsGrid1 : REAL; (*Diameter offset value (distance from sensor to core) [mm]*)
		DiamOffsGrid2 : REAL; (*Diameter offset value (distance from sensor to core) [mm]*)
		DiamOffsLaminator1 : REAL;
		DiamOffsLaminator2 : REAL;
		DiamOffsSpend1 : REAL; (*Diameter offset value (distance from sensor to core) [mm]*)
		DiamOffsSpend2 : REAL; (*Diameter offset value (distance from sensor to core) [mm]*)
		DiamOffsSpend3 : REAL; (*Diameter offset value (distance from sensor to core) [mm]*)
		DiamOffsSpend4 : REAL; (*Diameter offset value (distance from sensor to core) [mm]*)
		DiamOffsTopTWind : REAL; (*Diameter offset value (distance from sensor to core) [mm]*)
		DiamOffsBotTWind : REAL; (*Diameter offset value (distance from sensor to core) [mm]*)
		CoreDiam : REAL; (*Diameter of core [mm]*)
		CoreMaxDiamSensor : REAL; (*Maximum value for diameter sensor value [mm]*)
		CoreMinDiamSensor : REAL; (*Minimum value for diameter sensor value [mm]*)
		UseDiamLinearCorr : BOOL; (*Apply linear correction for diameter sensors*)
		DiamCorrGain : REAL; (*Gain for linear diameter correction [1]*)
		DiamCorrOffs : REAL; (*Offset for linear diameter correction [mm]*)
	END_STRUCT;
	rcp_machine_general_typ : 	STRUCT  (*General machine data*)
		max_diameter : REAL; (*maximum coil diameter*)
		model_type : INT; (*Machine model type 1=herpa_print*)
		MatPeriodMin : REAL;
		MatPeriodMax : REAL;
		spraygap	: REAL;
		spraytime	:REAL;
	END_STRUCT;
	rcp_machine_unwind_typ : 	STRUCT  (*Diameter values for winders*)
		coreDiam : USINT;
		frictionCompensation : USINT;
		velocityOverride : USINT;
		GEAR_RATIO : USINT;
		StopDiam : UDINT; (*Diameter value for stop [mm]*)
		WarnDiam : REAL; (*Diameter value for warning [mm]*)
		DistanceToRmSensor : REAL; (*Diameter value for warning [mm]*)
		DistanceToLabelSensor : REAL; (*Diameter value for warning [mm]*)
	END_STRUCT;
	rcp_machine_LaminatorReg_typ : 	STRUCT  (*Diameter values for winders*)
		WinderStopDiam : REAL; (*Diameter value for stop [mm]*)
		WinderWarnDiam : REAL; (*Diameter value for warning [mm]*)
		UnwinderStopDiam : REAL; (*Diameter value for stop [mm]*)
		UnwinderWarnDiam : REAL; (*Diameter value for warning [mm]*)
		DistanceToRmSensor : REAL; (*Diameter value for warning [mm]*)
		DistanceToLaminatprSensor : REAL; (*Diameter value for warning [mm]*)
	END_STRUCT;
	rcp_machine_twind_typ : 	STRUCT  (*machine recipe parameters for tandem winder*)
		StopDiam : REAL; (*Diameter value for stop [mm]*)
		WarnDiam : REAL; (*Diameter value for warning [mm]*)
		frictionCompensation : REAL; (*friction compensation [Nm] (on motor side)*)
		MinPressure : REAL; (*Valve pressure at minimum diameter [%]*)
		MaxPressure : REAL; (*Valve pressure at stop diameter [%]*)
		VelocityOverride : REAL; (*Velocity override [%]*)
	END_STRUCT;
	rcp_machine_markp_typ : 	STRUCT  (*machine parameters for markpoints (registration marks)*)
		position : DINT; (*markpoint sensor position [mm]*)
	END_STRUCT;
	rcp_machine_cutUnit_typ : 	STRUCT  (*machine parameters for cutting units*)
		position : DINT; (*cutting unit position [mm]*)
	END_STRUCT;
	rcp_machine_pullBrakeUnit_typ : 	STRUCT  (*machine parameters for pull brake unit*)
		gearOverride : REAL; (*gear ratio override [%]*)
	END_STRUCT;
	rcp_machine_typ : 	STRUCT  (*Machine description*)
		general : rcp_machine_general_typ; (*structure for general data and settings*)
		Winders : rcp_machine_Wind_Type; (*offset settings for diameter sensors*)
		UnwinderOpSide : rcp_machine_unwind_typ; (*settings for main unwinder*)
		mainUnwind : rcp_machine_unwind_typ; (*settings for main unwinder*)
		UnwinderDrvSide : rcp_machine_unwind_typ; (*settings for main unwinder*)
		laminatorReg : rcp_machine_LaminatorReg_typ;
		pbu : rcp_machine_pullBrakeUnit_typ; (*settings for pull brake unit*)
		cut1 : rcp_machine_cutUnit_typ; (*settings for cut unit 1*)
		cut2 : rcp_machine_cutUnit_typ; (*settings for cut unit 2*)
		cut3 : rcp_machine_cutUnit_typ; (*settings for cut unit 2*)
		markpoint1 : rcp_machine_markp_typ; (*settings for markpoint sensor 1*)
		markpoint2 : rcp_machine_markp_typ; (*settings for markpoint sensor 2*)
		markpoint3 : rcp_machine_markp_typ; (*settings for markpoint sensor 2*)
		grid1 : rcp_machine_unwind_typ; (*settings for grid winder 1*)
		grid2 : rcp_machine_unwind_typ; (*settings for grid winder 2*)
		gridwinderleft : rcp_machine_unwind_typ; (*settings for grid winder 2*)
		gridwinderright : rcp_machine_unwind_typ; (*settings for grid winder 2*)
		laminator1 : rcp_machine_unwind_typ; (*settings for grid winder 2*)
		laminator2 : rcp_machine_unwind_typ; (*settings for grid winder 2*)
		spender1 : rcp_machine_unwind_typ; (*settings for spender 1*)
		spender2 : rcp_machine_unwind_typ; (*settings for spender 2*)
		spender3 : rcp_machine_unwind_typ; (*settings for spender 3 (additional winder)*)
		topTandemWind : rcp_machine_twind_typ; (*settings for top tandem winder*)
		botTandemWind : rcp_machine_twind_typ; (*settings for bottom tandem winder*)
	END_STRUCT;
	rcp_cutting_typ : 	STRUCT 
		machdata : rcp_machine_cutUnit_typ;
		recipe : rcp_prog_cutUnit_typ;
	END_STRUCT;
END_TYPE

(*======================================================================================================================================*)
(*GENERAL RECIPE DATA STRUCTURES*)
(*======================================================================================================================================*)

TYPE
	CSV_Header_typ : 	STRUCT 
		CustomerName : STRING[80];
		MachineNumber : STRING[80];
		SW_Version : STRING[80];
	END_STRUCT;
END_TYPE
