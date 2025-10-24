(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * File: Glob_IO.typ
 * Author: schoenefeldr
 * Created: July 10, 2012
 ********************************************************************
 * Global data types of project 120706_hp_001
 ********************************************************************)

TYPE
	MachineIoDi_Type : 	STRUCT 
		FuseFanUnwind : DiDo_Type; (*Sicherung Lüfter Abwicklung*)
		FusePlug1 : DiDo_Type; (*Sicherung OK Schukosteckdose 1*)
		FusePlug2 : DiDo_Type; (*Sicherung OK Schukosteckdose 2*)
		FusePlugCEE : DiDo_Type; (*Sicherung OK CEE-Steckdose*)
		FuseBTS : DiDo_Type; (*Sicherung OK Bahnkantensteuerung*)
		FuseQW258_262 : DiDo_Type; (*Sicherung OK QW258 - QW262*)
		FuseQW264_268 : DiDo_Type; (*Sicherung OK QW264 - QW268*)
		FuseBookletFeeder : DiDo_Type; (*Sicherung OK Booklet Feeder*)
		FuseHydraulicPump : DiDo_Type; (*Sicherung OK Hydraulikpumpe*)
		HighVoltageGenerator : DiDo_Type; (*Hochspannungsgenerator Anti-Statik OK / Ein-Aus*)
		BST_OK : DiDo_Type; (*BST OK*)
		RFK_EmcyStop_undelayed : DiDo_Type; (*RFK Not - Halt - Schütze unverzögert*)
		RFK_EmcyStop_delayed : DiDo_Type; (*RFK Not - Halt - Schütze verzögert*)
		LDT_Reset : DiDo_Type; (*LDT Reset / Steuerung Ein*)
		LDT_CtrlOff : DiDo_Type; (*LDT Steuerung Aus*)
		LDT_AutoStart_End : DiDo_Type; (*LDT Automatik Start Maschinenende*)
		LDT_AutoStart_Middle : DiDo_Type; (*LDT Automatik Start Maschinenmitte*)
		LDT_AutoStart_Unwind : DiDo_Type; (*LDT Automatik Start am Abwickler*)
		LDT_AutoStart : DiDo_Type; (*LDT Automatik Start*)
		LDT_AutoStop : DiDo_Type; (*LDT Automatik Stopp*)
		LDT_AutoStop_End : DiDo_Type; (*LDT Automatik Stopp Maschinenende*)
		LDT_AutoStop_Middle : DiDo_Type; (*LDT Automatik Stopp Maschinenmitte*)
		LDT_AutoStop_Unwind : DiDo_Type; (*LDT Automatik Stopp am Abwickler*)
		LDT_Reserve2 : DiDo_Type;
		LDT_Jog_Machine : DiDo_Type; (*LDT Jog-Mode*)
		LDT_Jog_Machine_End : DiDo_Type; (*LDT Jog-Mode Maschinenende*)
		LDT_Jog_Machine_Middle : DiDo_Type; (*LDT Jog-Mode Maschinenmitte*)
		LDT_Jog_Machine_Unwind : DiDo_Type; (*LDT Jog-Mode am Abwickler*)
		LDT_Reserve1 : DiDo_Type;
		LDT_FaultReset : DiDo_Type; (*LDT Störung quittieren*)
		LDT_UnwindMoveUp : DiDo_Type; (*LDT Abwickler heben*)
		LDT_Laminator_UpDn : DiDo_Type;
		LDT_LabelDisp_UpDn : DiDo_Type;
		LDT_UnwindMoveDown : DiDo_Type; (*LDT Abwickler senken*)
		LDT_PBS2_upDn : DiDo_Type; (*LDT Zugeinheit heben / senken*)
		LDT_LongCUTsetKnife : DiDo_Type; (*Taster zum Einsetzen der Messer*)
		LDT_PBU_upDn : DiDo_Type; (*LDT Zugstation 3 heben / senken*)
		LDT_CutTabInfeed : DiDo_Type; (*LDT Schneidetisch heben / senken Einlaufseite*)
		LDT_CutTabOutfeed : DiDo_Type; (*LDT Schneidetisch heben / senken Auslaufseite*)
		LDT_PBS1_upDn : DiDo_Type; (*LDT Zugstation 1 heben / senken*)
		LDT_LongCutUpDn : DiDo_Type; (*LDT Längsschneider heben / senken*)
		RD_UnwindTopPos : DiDo_Type; (*RD Abwickler oben*)
		RD_UnwindBotPos : DiDo_Type; (*RD Abwickler unten*)
		RD_PBS1_topPos : DiDo_Type; (*RD Zugstation 1 oben*)
		RD_PBS1_botPos : DiDo_Type; (*RD Zugstation 1 unten*)
		RD_PBU_topPos : DiDo_Type; (*RD Zugstation 3 oben*)
		RD_PBU_botPos : DiDo_Type; (*RD Zugstation 3 unten*)
		Cut1_Ref : DiDo_Type; (*Stanze 1 Referenzpunkt*)
		Cut2_Ref : DiDo_Type; (*Stanze 2 Referenzpunkt*)
		Cut3_Ref : DiDo_Type; (*Stanze 2 Referenzpunkt*)
		RD_PBS2_topPos : DiDo_Type; (*RD Zugeinheit oben*)
		RD_PBS2_botPos : DiDo_Type; (*RD Zugeinheit unten*)
		RD_LongCutTopPos : DiDo_Type; (*RD Längsschneider oben*)
		RD_LongCutBotPos : DiDo_Type; (*RD Längsschneider unten*)
		PressureCtrl : DiDo_Type; (*Druckwächter*)
		SafetyDoorInfeedCut1 : DiDo_Type; (*Safety Door Stanze 1 Infeed*)
		SafetyDoorOutfeedCut1 : DiDo_Type; (*Safety Door Stanze 1 Outfeed*)
		SafetyDoorInfeedCut2 : DiDo_Type; (*Safety Door Stanze 2 Infeed*)
		SafetyDoorOutfeedCut2 : DiDo_Type; (*Safety Door Stanze 2 Outfeed*)
		SafetyDoorInfeedCut3 : DiDo_Type; (*Safety Door Stanze 3 Infeed*)
		SafetyDoorOutfeedCut3 : DiDo_Type; (*Safety Door Stanze 3 Outfeed*)
		SafetyDoorLongCut : DiDo_Type; (*Safety Door Long cut unit*)
		SafetyDoorBooklet : DiDo_Type; (*Safety Door Long cut unit*)
		EmergencyStopCabinet : DiDo_Type; (*Not-Aus-Schalter am Schaltschrank*)
		EmergencyStopPanel : DiDo_Type; (*Not-Aus-Schalter am Panel*)
		EmergencyStopUnwinder : DiDo_Type; (*Not-Aus-Schalter am Abwickler*)
		EmergencyStopBooklet : DiDo_Type; (*Not-Aus-Schalter am Schaltschrank*)
		EmergencyStopLongCut : DiDo_Type; (*Not-Aus-Schalter am Längsschneider*)
		EmergencyStopPullWire : DiDo_Type; (*Not-Aus-Schalter am Längsschneider*)
		LightSensorConvBelt : DiDo_Type; (*Lichttaster Auslageband*)
		EmergencyStopTandemWinder : DiDo_Type; (*Not-Aus-Schalter am Tandemwickler*)
		EmergencyStopEndModule : DiDo_Type; (*Not-Aus-Schalter am Ende der Maschine*)
		EmergencyStopMiddle : DiDo_Type; (*Not-Aus-Schalter in der Mitte der Maschine*)
		RD_LaminatorTopPos : DiDo_Type;
		RD_LaminatorBotPos : DiDo_Type;
		LT_LabelDisp_LoopUnwinder : DiDo_Type;
		LT_LabelDisp_LoopWinder : DiDo_Type;
		LT_LabelDisp_WebBreak1 : DiDo_Type;
		LT_LabelDisp_WebBreak2 : DiDo_Type;
		LabelDisp_RegMark1 : DiDo_Type;
		LabelDisp_RegMark2 : DiDo_Type;
		Fuse_Laminator1 : DiDo_Type;
		Fuse_Laminator2 : DiDo_Type;
		Fuse_GridWinder1 : DiDo_Type;
		Fuse_LabelDisp1 : DiDo_Type;
		Fuse_LabelDisp2 : DiDo_Type;
		TopWindSpikeSuppClosed : DiDo_Type;
		Liner_detekce : DiDo_Type;
		BotWindSpikeSuppClosed : DiDo_Type;
	END_STRUCT;
	MachineIo_Type : 	STRUCT 
		DIn : MachineIoDi_Type;
		DOut : MachineIoDo_Type;
		AIn : MachineIoAi_Type;
		AOut : MachineIoAo_Type;
	END_STRUCT;
	MachineIoDo_Type : 	STRUCT 
		CtrlPowerEmcyUndel : DiDo_Type; (*24V DC Versorgung nach Not-Halt*)
		CtrlPowerEmcyDel : DiDo_Type; (*24V DC Versorgung nach Not-Halt zeitverzögert*)
		EnabDrives : DiDo_Type; (*Enable ACOPOS-Multi*)
		ContactSuction : DiDo_Type; (*potentialfreier Kontakt Absaugung Ein*)
		Plug1_OnOff : DiDo_Type; (*Schukosteckdose 1 Ein / Aus*)
		Plug2_OnOff : DiDo_Type; (*Schukosteckdose 2 Ein / Aus*)
		PlugCEE_OnOff : DiDo_Type; (*CEE-Steckdose 16A Ein / Aus*)
		HydraulicPumpOn : DiDo_Type; (*Schütz Hydraulikpumpe ein*)
		BST_Enable : DiDo_Type; (*BST Freigabe*)
		BST_Manual : DiDo_Type; (*BST Handbetrieb*)
		BST_Neutral : DiDo_Type; (*BST Mittenstellung*)
		BST_Automatic : DiDo_Type; (*BST Mittenstellung*)
		BST_ArrowLeft : DiDo_Type; (*BST Pfeil links BST Tastatursperre*)
		BST_ArrowRight : DiDo_Type; (*BST Pfeil rechts BST Tastatursperre*)
		LampGreen : DiDo_Type; (*Turmleuchte grün*)
		LampYellow : DiDo_Type; (*Turmleuchte gelb*)
		LampRed : DiDo_Type; (*Turmleuchte rot*)
		TowerHorn : DiDo_Type; (*Turmleuchte Hupe*)
		VentLabelDisp : DiDo_Type; (*Ventil Label Dispenser Up Down*)
		VentLaminatorMoveUp : DiDo_Type; (*Ventil Abwickler heben*)
		VentLaminatorMoveDown : DiDo_Type; (*Ventil Abwickler heben*)
		VentUnwindMoveUp : DiDo_Type; (*Ventil Laminierer heben*)
		VentUnwindMoveDown : DiDo_Type; (*Ventil Laminierer senken*)
		VentCutTabInfeedMoveUpDn : DiDo_Type; (*Ventil Schneidetisch heben / senken Einlaufseite*)
		VentCutTabOutfeedMoveUpDn : DiDo_Type; (*Ventil Schneidetisch heben / senken Auslaufseite*)
		Vent1Dancer : DiDo_Type; (*Ventil 1 Tänzer*)
		VentAirSupply : DiDo_Type; (*Hauptventil*)
		VentPBS1_MoveDown : DiDo_Type; (*Ventil Zugstation 1 senken*)
		VentPBS1_MoveUp : DiDo_Type; (*Ventil Zugstation 1 heben*)
		VentPBU_MoveUP : DiDo_Type; (*Ventil Zugstation 3 heben*)
		VentPBU_MoveDown : DiDo_Type; (*Ventil Zugstation 3 senken*)
		VentPBS2_MoveDown : DiDo_Type; (*Ventil Zugeinheit senken*)
		VentLongCutMoveUp : DiDo_Type; (*Ventil Längsschneider heben*)
		VentLongCutSetKnifeIn : DiDo_Type; (*Ventil Längsschneider Messer setzen*)
		VentLongCutSetKnifeOut : DiDo_Type; (*Ventil Längsschneider Messer setzen*)
		VentLongCutMoveDown : DiDo_Type; (*Ventil Längsschneider senken *)
		ValveCuttingUnitToolUp : DiDo_Type; (*Ventil Stanzstation Werkzeug heben*)
		ValveCut1BridgeDown : DiDo_Type; (*Ventil Stanzstation1 Brücke senken*)
		ValveCut2BridgeDown : DiDo_Type; (*Ventil Stanzstation 2 Brücke senken*)
		ValveCut3BridgeDown : DiDo_Type; (*Ventil Stanzstation 3 Brücke senken*)
		BookletFeederREG : DiDo_Type; (*Ventil Stanzstation 3 Brücke senken*)
		BookletFeederON : DiDo_Type; (*Ventil Stanzstation 3 Brücke senken*)
	END_STRUCT;
	MachineIoAo_Type : 	STRUCT 
		MagBrakeUnwind : AiAo_Type; (*Ansteuerung Magnetpulverbremse Abwickler*)
		VentDancer : AiAo_Type; (*Proportionalventil Tänzerspannung (Festo)*)
		VentClutchSpend1 : AiAo_Type; (*Proportionalventil Rutschkupplung Abwickler 1*)
		VentClutchSpend2 : AiAo_Type; (*Proportionalventil Rutschkupplung Abwickler 2*)
		VentClutchSpend3 : AiAo_Type; (*Proportionalventil Rutschkupplung Abwickler 3*)
		VentClutchLaminator1 : AiAo_Type; (*Proportionalventil Rutschkupplung Abwickler 3*)
		VentClutchLaminator2 : AiAo_Type; (*Proportionalventil Rutschkupplung Abwickler 3*)
		VentClutchGrid1 : AiAo_Type; (*Proportionalventil Rutschkupplung Gitteraufwickler 1*)
		VentClutchGrid2 : AiAo_Type; (*Proportionalventil Rutschkupplung Gitteraufwickler 2*)
		VentOptClutchTUnwindTop : AiAo_Type; (*Option Proportionalventil Rutschkupplung Tandemwickler oben*)
		VentOptClutchTUnwindBot : AiAo_Type; (*Option Proportionalventil Rutschkupplung Tandemwickler unten*)
	END_STRUCT;
	MachineIoAi_Type : 	STRUCT 
		FlengeDMS : AiAo_Type; (*Flanschkraftaufnehmer*)
		FDriveSideCut1 : AiAo_Type; (*Stanze 1 Druckkraftaufnehmer Antriebsseite*)
		FOperatorSideCut1 : AiAo_Type; (*Stanze 1 Druckkraftaufnehmer Bedienerseite*)
		FDriveSideCut2 : AiAo_Type; (*Stanze 2 Druckkraftaufnehmer Antriebsseite*)
		FOperatorSideCut2 : AiAo_Type; (*Stanze 2 Druckkraftaufnehmer Bedienerseite*)
		FDriveSideCut3 : AiAo_Type; (*Stanze 3 Druckkraftaufnehmer Antriebsseite*)
		FOperatorSideCut3 : AiAo_Type; (*Stanze 3 Druckkraftaufnehmer Bedienerseite*)
		DiamMainUnwind : AiAo_Type; (*Durchmesserabfrage Abwicklung*)
		DiamSpend1 : AiAo_Type; (*Durchmesserabfrage Abwickler 1*)
		DiamSpend2 : AiAo_Type; (*Durchmesserabfrage Abwickler 2*)
		DiamLaminator1 : AiAo_Type; (*Durchmesserabfrage Laminierer 1*)
		DiamLaminator2 : AiAo_Type; (*Durchmesserabfrage Laminierer 2*)
		DiamGrid1 : AiAo_Type; (*Durchmesserabfrage Gitteraufwickler 1*)
		DiamGrid2 : AiAo_Type; (*Durchmesserabfrage Gitteraufwickler 2*)
		DancerPos : AiAo_Type; (*Tänzerlage*)
		DiamTUnwindTop : AiAo_Type; (*Durchmesserabfrage Tandemwickler oben*)
		DiamTUnwindBot : AiAo_Type; (*Durchmesserabfrage Tandemwickler unten*)
		Dancer_position : AiAo_Type; (*pozice danceru optický senzor*)
		TestSensor : AiAo_Type; (*Durchmesserabfrage Tandemwickler unten*)
	END_STRUCT;
END_TYPE
