(********************************************************************
 * COPYRIGHT -- Nitto
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_SprayCtrl.st
 * Autor: s_spilker
 * Erstellt: 11. September 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_SprayCtrl
	machineaxis();

	IF machineaxis.MC_ReadActualVelocity_0.Velocity > 100 THEN // 25.07.18 //OKrebs damit Sprueanlage nicht im Stand spruet
		
	time1.PT :=	REAL_TO_TIME (length1*1000 (*length1*1000*1000 / machineaxis.MC_ReadActualVelocity_0.Velocity*));
	time2.PT := REAL_TO_TIME (length2*1000*1000 / machineaxis.MC_ReadActualVelocity_0.Velocity);	
	END_IF
	
//	R_TRIG_0(CLK := machineaxis.MC_ReadStatus_0.ContinuousMotion);
//	IF R_TRIG_0.Q THEN
//		time1.IN := FALSE;
//		time2.IN := FALSE;
//	END_IF;
	
//	time1.PT := T#1s;
//	time2.PT := T#2s;
	time1();
	time2();
	F_TRIG_1(CLK := time1.Q);
	F_TRIG_2(CLK := time2.Q);
	//	time_tof := REAL_TO_TIME(spraytime);
//	timer_tof(PT := time_tof);
//	test :=  fmod(machineaxis.MC_ReadActualPosition_0.Position,lenght);
	//	test1 := modf(machineaxis.MC_ReadActualPosition_0.Position,lenght);
	(*test1 := machineaxis.MC_ReadActualPosition_0.Position;*)
//	rtrig();
	IF length1 = 0 THEN
		valveout := FALSE;
	ELSE
		IF machineaxis.MC_ReadStatus_0.ContinuousMotion THEN 
	
			
			CASE pulse OF
			
				1: (*AN*)
				time1.IN := TRUE;
				valveout := TRUE;
					IF F_TRIG_1.Q THEN
					time1.IN := FALSE;	
					pulse := 2;
					END_IF
				
				
				2: (*AUS*)
				time2.IN := TRUE;
				valveout := FALSE;
					IF F_TRIG_2.Q THEN
					time2.IN := FALSE;
					pulse := 1;
					END_IF
				
			END_CASE
			
			
//			IF lenght - 80 < fmod(machineaxis.MC_ReadActualPosition_0.Position,lenght ) THEN 
//				rtrig.CLK := TRUE;
//			END_IF
//			
//		
//			IF rtrig.Q THEN	
//				timer_tof.IN := TRUE;
//				test1 := test1 + 1;
//				(*rtrig.CLK := FALSE;*)
//			END_IF
//			IF timer_tof.Q THEN 
//				rtrig.CLK := FALSE;
//				timer_tof.IN := FALSE;
//			END_IF	
//			valveout :=	timer_tof.Q;
		ELSE
			valveout := FALSE;
			time1.IN := FALSE;
			time2.IN := FALSE;
		END_IF
	END_IF
END_FUNCTION_BLOCK