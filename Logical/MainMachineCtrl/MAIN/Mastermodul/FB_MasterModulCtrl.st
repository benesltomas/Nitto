(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: UserSpilke
 * Datei: FB_MasterModulCtrl.st
 * Autor: Awalz
 * Erstellt: 25. März 2014
 ********************************************************************
 * Implementierung der Library UserSpilke
 ********************************************************************) 

(*<$Description$> Hier wird die MasterAchse in Bewegung gesetzt da die andere Module gekoppelt sind führen diese die gleiche Bewegung aus </$Description$>*)
FUNCTION_BLOCK FB_MasterModulCtrl
	unitsStatus( UnwinderUnit := UnwinderUnit, pullbreak := pullbreak, pullbreakSt := pullbreakSt,
				conveyor := conveyor, catchbelt := catchbelt, longcutter := longcutter, cuttingunit1 := cuttingunit1, cuttingunit2 := cuttingunit2, webbuffer := webbuffer, turngridwinder := turngridwinder); // OKrebs 09.12.15
	axis();
	IOs(panel := panel);
	safety();
	sprayCtrl(machineaxis := axis, length1 := data.lenght1, length2 := data.lenght2);
	IF buttonSprayVisu THEN
		sprayCtrl.valveout := TRUE;
	END_IF
	summerystartstop(clk := panel.clk, panel := panel);
	axis.BasicControl.Parameter.Deceleration	:= 80000.0; //only for initialization
	axis.BasicControl.Parameter.Acceleration	:= 80000.0;
//	axis.MC_ReadActualVelocity_0();
//	mastervelocity := axis.MC_ReadActualVelocity_0.Velocity;
	//	handWheel( actualVelocity := mastervelocity, limitspeed := data.maxSpeed, safetyspeedrequest := safety.RequestSLS);
	handWheel( actualVelocity := axis.MC_ReadActualVelocity_0.Velocity, limitspeed := data.maxSpeed, safetyspeedrequest := safety.RequestSLS);
	inlineVelocity( limitspeed := 0, setDancerpos := 500, maxMainVelocity := 20, speedToCycleWebturrit := data.speedToCycleWebturrit/16666.67); //OKrebs //28.06.17 // vorher maxMainVelocity := 10 

CASE StateCtrl OF
    CTRL_FIRST_START:
		busy := TRUE;
		StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
	
	CTRL_MANUAL_BEFORE:
		axis.BasicControl.Command.Power := TRUE;
		IF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			(*BetrStatus.set := TRUE;*)
			BetrStatus(set := TRUE, value := BetrCtrl.value);
			err(reset := TRUE);
		(*	axis.ctrl.setOverride();
			axis.ctrl.ref.PlcToNc.Override := 1000000;
			err.reset();*)
			busy := FALSE;
			state := ST_IDLE;
			IOs.ampel.Gelb.aktion := CONST.LAMP.OFF;
			panel.LDTRESET.LDT.aktion := CONST.LAMP.OFF;
			panel.LDTAutomatic.LDT.aktion := CONST.LAMP.OFF;
			StateCtrl := CTRL_MANUAL;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			StateCtrl := CTRL_AUTO_BEFORE;
		END_IF

	
	CTRL_MANUAL:
		err(reset := FALSE);
		ac_manualMaster;
		
	CTRL_MANUAL_AFTER:
		ac_setStateAfterMaster;
		
	CTRL_AUTO_BEFORE:
		IF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			BetrStatus(set := TRUE, value := BetrCtrl.value);
			err(reset := TRUE);
			busy := FALSE;
			state := ST_IDLE;
		(*	axis.ctrl.setOverride();*)
//			IF data.recipe.startSpeed < 0.01 THEN
//				tmpStartOverride :=	(1*1000/60) / STARTVELO;
//			ELSIF data.recipe.startSpeed > 20 THEN
//				tmpStartOverride :=	(20*1000/60) / STARTVELO;
//			ELSE
//				tmpStartOverride :=	(data.recipe.startSpeed*1000/60) / STARTVELO;
//			END_IF
//			startOverride := LREAL_TO_UDINT(tmpStartOverride * 1000000);
//
//			IF data.recipe.startSpeed > data.recipe.maxSpeed THEN
//				tmpEndOverride :=	(data.recipe.startSpeed*1000/60) / STARTVELO;
//(* 30 ist zu viel, geändert J.H. 31.01.11
//			IF data.recipe.maxSpeed < 30 THEN  
//				tmpEndOverride :=	(30*1000/60) / STARTVELO;
//*)			ELSIF data.recipe.maxSpeed > 180 THEN
//				tmpEndOverride :=	(180*1000/60) / STARTVELO;
//			ELSE
//				tmpEndOverride :=	(data.recipe.maxSpeed*1000/60) / STARTVELO;
//			END_IF

			StateCtrl := CTRL_AUTO;
		axis.BasicControl.Command.Power := TRUE;
		BetrStatus(set := TRUE, value := CONST.MACHINEMODES.EMERGENCYSTOP);
			StateCtrl := CTRL_AUTO;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			StateCtrl := CTRL_MANUAL_BEFORE;
		END_IF
		
	CTRL_AUTO:
		IF NOT IOs.inline AND NOT mainconvoyerrun THEN
			ac_automaticMaster;	
		ELSIF IOs.inline(* inline AND mainconvoyerrun*) THEN
			ac_inline;
		END_IF 
	
	CTRL_AUTO_AFTER: 
		ac_setStateAfterMaster;
		panel.LDTAutomatic.LDT.aktion := CONST.LAMP.BLINK500;

	CTRL_STOP:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			state := ST_IDLE;
			StateCtrl := CTRL_STOP_AFTER;
		END_IF

	CTRL_STOP_AFTER:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			StateCtrl := CTRL_MANUAL_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			StateCtrl := CTRL_AUTO_BEFORE;
		END_IF
		
	CTRL_RESET_START:
		BetrStatus (set := TRUE, value := CONST.MACHINEMODES.RESET);
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			StateCtrl := CTRL_RESET;
		END_IF	
		
	CTRL_RESET:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			StateCtrl := CTRL_SAFETYSTOP_BEFORE;
		ELSE
			StateCtrl := CTRL_RESET_AFTER;
		END_IF
		
	CTRL_RESET_AFTER:
		IF BetrCtrl.value = CONST.MACHINEMODES.RESET THEN
			busy := FALSE;
		ELSE
			busy := TRUE;
			err(reset := FALSE);
			IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
				StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
				StateCtrl := CTRL_SAFETYSTOP_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
				axis.cmd := CONST.AXIS.POWER_ON; (* Regler EInschalten *)
				StateCtrl := CTRL_MANUAL_BEFORE;
			ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
				axis.cmd := CONST.AXIS.POWER_ON; (* Regler EInschalten *)
				StateCtrl := CTRL_AUTO_BEFORE;
			END_IF
		END_IF
(****neu 30.04***)
	CTRL_SAFETYSTOP_BEFORE:			(* Runter Rampen *)
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
			axis.verzoegerung:= CONST.AXIS.EMERGENCY_DECELERATION; (* von 200m/min in 3 sek*)
			axis.cmd := CONST.AXIS.STOP;
			state := ST_IDLE;
			StateCtrl := CTRL_SAFETYSTOP;
		END_IF
 
	CTRL_SAFETYSTOP:
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
//			CASE state OF
//			ST_IDLE:
//				IF axis.BasicControl.AxisState.StandStill OR axis.BasicControl.AxisState.StandStill  THEN
//				
//					state := ST_QUIT;
//				END_IF
//
//			ST_QUIT:
//				state := ST_QUIT;
//				BetrStatus(set := TRUE,value := CONST.MACHINEMODES.SAFETYSTOP);
//				StateCtrl := CTRL_SAFETYSTOP_AFTER;
				//			END_CASE
			BetrStatus(set := TRUE,value := CONST.MACHINEMODES.SAFETYSTOP);
			IF axis.MC_ReadStatus_0.StandStill THEN 
				axis.cmd := CONST.AXIS.NOACTION;//da virtuelle Achse
				StateCtrl := CTRL_SAFETYSTOP_AFTER;
			END_IF
		END_IF
	 
	CTRL_SAFETYSTOP_AFTER:
		busy := FALSE;
		(*axis(cmd := CONST.AXIS.VAXIS_ON);*)
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			busy := TRUE;
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			busy := TRUE;
			StateCtrl := CTRL_MANUAL_BEFORE;
		ELSIF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			busy := TRUE;
			StateCtrl := CTRL_AUTO_BEFORE;
		END_IF
(******)	

	CTRL_EMERGENCYSTOP_BEFORE:
		BetrStatus(set := TRUE, value := CONST.MACHINEMODES.EMERGENCYSTOP);
		IF  axis.MC_ReadStatus_0.ContinuousMotion OR axis.MC_ReadStatus_0.DiscreteMotion
			OR axis.MC_ReadStatus_0.SynchronizedMotion  THEN
			axis.verzoegerung:= CONST.AXIS.EMERGENCY_DECELERATION;// 1111111;//11.03.15 1111111; (*200m/min = 3333334/3 in 3 sek*)
			axis.cmd := CONST.AXIS.STOP;
			state := ST_IDLE;
			StateCtrl := CTRL_EMERGENCYSTOP;
		ELSE //wenn die Maschine eingeschaltet wird
			axis.cmd := CONST.AXIS.NOACTION;
			state := ST_IDLE;
			StateCtrl := CTRL_EMERGENCYSTOP;
		END_IF
		
		CTRL_EMERGENCYSTOP:
		panel.LDTAutomatic.LDT.aktion :=  CONST.LAMP.OFF;
		IF BetrCtrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			IF axis.MC_ReadStatus_0.StandStill THEN 
				axis.cmd := CONST.AXIS.NOACTION;//da bei B&R eine virtulle Achse nicht ausgeschalten werden kann
				busy := FALSE;
			ELSIF axis.MC_ReadStatus_0.Disabled THEN
				axis.cmd := CONST.AXIS.NOACTION;
				busy := FALSE;
			END_IF
		ELSE
			err.reset := TRUE;
			busy := TRUE;
			StateCtrl := CTRL_RESET_START;
		END_IF
END_CASE

END_FUNCTION_BLOCK

