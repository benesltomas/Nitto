(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: dummy
 * Datei: dummyInit.st
 * Autor: awalz
 * Erstellt: 26. Juni 2014
 ********************************************************************
 * Implementierung des Programms dummy
 ********************************************************************)

PROGRAM _INIT


(* TODO : Code hier einfügen *)
	gUnwinder := gUnwinder;
	gMaster1 := gMaster1; (*Virtueller Master*)
	gCut1 := gCut1; (*Stanzstation 1*)
	gCut2 := gCut2; (*Stanzstation 2*)
	gGridLeft := gGridLeft; (*Gitteraufwickler 1*)
	gGridRight := gGridRight; (*Gitteraufwickler 2*)
	gPBS1 := gPBS1; (*Zugstation 1*)
	gPBS2 := gPBS2; (*Zugstation 1*)
	gCatchBelt := gCatchBelt; (*Fangband*)
	gConvBelt := gConvBelt; (*Auslageband*)
	gUnwOp := gUnwOp; (*Abwickler Operatorseite*)
	gUnwDrv := gUnwDrv; (*Abwickler Antriebsseite*)
	gBuffer := gBuffer; (*Bahnspeicher*)
	gGridFeeder := gGridFeeder; (*Drehvorrichtung Gitterturm*)
	gLongCut := gLongCut; (*Drehvorrichtung Gitterturm*)
	gUnwFeeder := gUnwFeeder;
	gUnwFeeder_HW := gUnwFeeder_HW;
	gUnwFeeder_DrvIf := gUnwFeeder_DrvIf;
	gUnwFeeder_DiDoIf := gUnwFeeder_DiDoIf;
	gUnwFeeder_ModuleOk := gUnwFeeder_ModuleOk;
	// neu // OKrebs // 23.11.16
	gPackBelt := gPackBelt;
	gPackBelt_HW := gPackBelt_HW;
	gPackBelt_DrvIf := gPackBelt_DrvIf;
	gPackBelt_DiDoIf := gPackBelt_DiDoIf;
	gPackBelt_ModuleOk := gPackBelt_ModuleOk;
	// ende neu 
END_PROGRAM

