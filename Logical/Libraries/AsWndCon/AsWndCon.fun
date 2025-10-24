(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: AsPrintCon
 * File: AsPrintCon.fun
 * Author: staudeckerm
 * Created: April 16, 2009
 ********************************************************************
 * Functions and function blocks of library AsPrintCon
 ********************************************************************)

FUNCTION_BLOCK WNCProcessCtrl
	VAR_INPUT
		enable : BOOL; (*Enable function block.*)
		pSysPara : REFERENCE TO wnc_sysPara_typ; (*System parameters.*)
		pPidPara : REFERENCE TO wnc_pidPara_typ; (*Pid parameters.*)
		update : BOOL; (*Parameter update.*)
		actProcVar : REAL; (*Actual process variable.*)
		setProcVar : REAL; (*Set process variable.*)
		actDiam : REAL; (*Actual winder diameter. Units: [mm].*)
		filterTime : REAL; (*Filter time of input filter. Units: [s].*)
		gain : REAL; (*Gain scheduling parameter. Units: [1].*)
		hold : BOOL; (*Hold outputs*)
		reset : BOOL; (*Reset integrator state to zero.*)
	END_VAR
	VAR_OUTPUT
		actSpeedCorr : REAL; (*Correction speed. Units: [units/s].*)
		status : UINT; (*Function block status message.*)
	END_VAR
	VAR
		internal : pctrl_internal_typ; (*Data for internal use.*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK WNCPidCtrl
	VAR_INPUT
		enable : BOOL; (*Enable function block.*)
		pPidPara : REFERENCE TO wnc_pidPara_typ; (*Pid parameters.*)
		update : BOOL; (*Parameter update.*)
		err : REAL; (*Control error.*)
		hold_yi : BOOL; (*Hold integration part only.*)
		hold_y : BOOL; (*Hold controller output.*)
		reset : BOOL; (*Reset of integrator state.*)
	END_VAR
	VAR_OUTPUT
		y : REAL; (*Controller output.*)
		yp : REAL; (*Proportional part.*)
		yi : REAL; (*Integration part.*)
		ydt1 : REAL; (*Differential part.*)
		status : UINT; (*Function block status message.*)
	END_VAR
	VAR
		internal : pid_internal_typ; (*Data for internal use.*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK WNCCalcFFCtrl
	VAR_INPUT
		enable : BOOL; (*Enable function block.*)
		pSysPara : REFERENCE TO wnc_sysPara_typ; (*System parameters.*)
		update : BOOL; (*Parameter update.*)
		sync : BOOL; (*Command to start axis syncronization.*)
		syncTime : REAL; (*Time for syncronization. Units: [s].*)
		setLineSpeed : REAL; (*Line speed. Units: [units/s].*)
		actDiam : REAL; (*Actual winder diameter. Units: [mm].*)
		actDiamCngRate : REAL; (*Actual change rate of diameter. Units: [mm/s].*)
		actInertia : REAL; (*Actual moment of inertia of winder. Units: [kgm²].*)
		actInertiaCngRate : REAL; (*Actual change rate of moment of inertia. Units: [kgm²/s].*)
		setMatTension : REAL; (*Set value of material tension. Units: [N].*)
		uppTrqLimit : REAL; (*Upper torque limit. Units: [Nm].*)
		lowTrqLimit : REAL; (*Lower torque limit. Units: [Nm].*)
	END_VAR
	VAR_OUTPUT
		setWndSpeed : REAL; (*Winder speed feed forward. Units: [units/s].*)
		setMotorTrq : REAL; (*Motor torque feed forward. Units: [Nm].*)
		status : UINT; (*Function block status message.*)
	END_VAR
	VAR
		internal : wcff_internal_typ; (*Data for internal use.*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK WNCLipSctrlPara
	VAR_INPUT
		enable : BOOL; (*Enable function block.*)
		pSysPara : REFERENCE TO wnc_sysPara_typ; (*System parameters.*)
		update : BOOL; (*Parameter update.*)
		actDiam : REAL; (*Actual diameter, only mode 0. Units: [mm].*)
		pVecSctrlKV : REFERENCE TO REAL; (*Pointer to KV vector.*)
		pVecSctrlTN : REFERENCE TO REAL; (*Pointer to TN vector.*)
		pVecDiam : REFERENCE TO REAL; (*Pointer to Diam vector.*)
		numPoints : UINT; (*Number of points specified above.*)
	END_VAR
	VAR_OUTPUT
		actSctrlKV : REAL; (*Actual SCTRL_KV. Units: [As].*)
		actSctrlTN : REAL; (*Actual SCTRL_TN. Units: [s].*)
		status : UINT; (*Function block status message.*)
	END_VAR
	VAR
		internal : lsp_internal_typ; (*Data for internal use.*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK WNCCalcSctrlPara
	VAR_INPUT
		enable : BOOL; (*Enable function block.*)
		pMotPara : REFERENCE TO wnc_motPara_typ; (*Motor parameters.*)
		update : BOOL; (*Parameter update.*)
		actInertia : REAL; (*Actual moment of inertia. Units: [kgm²].*)
		kvTorque : REAL; (*Velocity prop. friction coefficient. Units: [Nms].*)
		TiFilter : REAL; (*Speed filter constant. Units: [s].*)
		riseTime : REAL; (*Rise time of closed loop step response. Units: [s].*)
		overshoot : REAL; (*Overshoot of closed loop step response. Units: [%].*)
		simStepResponse : BOOL; (*Start simulation of closed loop step response.*)
	END_VAR
	VAR_OUTPUT
		SctrlKV : REAL; (*Proportional gain. Units: [As].*)
		SctrlTN : REAL; (*Integral action gain. Units: [s].*)
		stepResponse : REAL; (*Simulation of closed loop step response.*)
		status : UINT; (*Function block status message.*)
	END_VAR
	VAR
		internal : wcsp_internal_typ; (*Data for internal use.*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK WNCSimModel
	VAR_INPUT
		enable : BOOL; (*Enable function block.*)
		pSimPara : REFERENCE TO wnc_simPara_typ; (*Simulation parameters.*)
		lineSpeed : REAL; (*Desired line speed. Units: [m/min].*)
		cyclicVelocity : REAL; (*Input of MC_BR_VelocityControl. Units: [units/s].*)
		cyclicVelocityCorrection : REAL; (*Input of MC_BR_VelocityControl. Units: [units/s].*)
		cyclicTorque : REAL; (*Input of MC_BR_VelocityControl. Units: [Nm].*)
		sctrlKV : REAL; (*Input of MC_BR_VelocityControl. Units: [As].*)
		sctrlTN : REAL; (*Input of MC_BR_VelocityControl. Units: [s].*)
		dcrTorque : REAL; (*Torque acting on dancer arm. Units: [Nm].*)
		matBreak : BOOL; (*Trigger input to simulate material break.*)
	END_VAR
	VAR_OUTPUT
		setLineSpeed : REAL; (*Set line speed. Units: [units/s].*)
		actMatTension : REAL; (*Actual material tension. Units: [N].*)
		actDcrPos : REAL; (*Actual dancer position. Units: [mm].*)
		actWndPos : DINT; (*Actual winder position. Units: [units].*)
		actWndSpeed : REAL; (*Actual winder speed. Units: [units/s].*)
		actLinePos : DINT; (*Actual line position. Units: [units].*)
		actLineSpeed : REAL; (*Actual line speed. Units: [units/s].*)
		actMotorTrq : REAL; (*Actual motor torque. Units: [Nm].*)
		actDiam : REAL; (*Actual diameter. Units: [mm].*)
		status : UINT; (*Function block status message.*)
	END_VAR
	VAR
		internal : sim_internal_typ; (*Data for internal use.*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK WNCCalcDiam
	VAR_INPUT
		enable : BOOL; (*Enable function block.*)
		pSysPara : REFERENCE TO wnc_sysPara_typ; (*System parameters.*)
		pEstPara : REFERENCE TO wnc_estPara_typ; (*Estimation parameters.*)
		update : BOOL; (*Parameter update.*)
		mode : USINT; (*Mode (0: manual, 1: cyc. position, 2: cyc. velocity).*)
		actLinePos : DINT; (*Actual line position. Units: [units].*)
		actLineSpeed : REAL; (*Actual line speed. Units: [units/s].*)
		actWndPos : DINT; (*Actual motor axis position. Units: [units].*)
		actWndSpeed : REAL; (*Actual motor axis speed. Units: [units/s].*)
		actDcrPos : REAL; (*Actual dancer position. Units: [mm].*)
		startDiam : REAL; (*Start diameter. Units: [mm].*)
		setStartDiam : BOOL; (*Set actual diameter output to startDiam.*)
		manEstTrig : BOOL; (*Manual estimation trigger, mode=0.*)
		hold : BOOL; (*Hold outputs.*)
	END_VAR
	VAR_OUTPUT
		actDiam : REAL; (*Actual estimated diameter. Units: [mm].*)
		actDiamCngRate : REAL; (*Actual change rate of diameter. Units: [mm/s].*)
		avgMatThickness : REAL; (*Average material thickness. Units: [µm].*)
		actInertia : REAL; (*Actual moment of inertia of winder. Units: [kgm²].*)
		actInertiaCngRate : REAL; (*Actual change rate of moment of inertia. Units: [kgm²/s].*)
		avgMatDensity : REAL; (*Average material density. Units: [kg/m³].*)
		status : UINT; (*Function block status message.*)
	END_VAR
	VAR
		internal : wcd_internal_typ; (*Data for internal use.*)
	END_VAR
END_FUNCTION_BLOCK
