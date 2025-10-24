<?xml version="1.0" encoding="utf-8"?>
<?AutomationStudio Version=4.0.18.71 SP?>
<SwConfiguration CpuAddress="SL1" xmlns="http://br-automation.co.at/AS/SwConfiguration">
  <TaskClass Name="Cyclic#1">
    <Task Name="ncsdcctrl" Source="MainMachineCtrl.ncsdcctrl.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="WebControl" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
  </TaskClass>
  <TaskClass Name="Cyclic#2">
    <Task Name="dummy" Source="MainMachineCtrl.dummy.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="MAIN" Source="MainMachineCtrl.MAIN.prg" Memory="UserROM" Language="IEC" Debugging="true" />
  </TaskClass>
  <TaskClass Name="Cyclic#3" />
  <TaskClass Name="Cyclic#4">
    <Task Name="VisuTasks" Source="Visualization.VisuCycl.VisuTasks.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="VisuPages" Source="Visualization.VisuCycl.VisuPages.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="VisuRange" Source="Visualization.VisuCycl.VisuRange.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="GeneralAla" Source="Alarme.GeneralAlarms.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="al_hdl" Source="pkgRecipe.al_hdl.prg" Memory="UserROM" Language="IEC" Debugging="true" />
  </TaskClass>
  <TaskClass Name="Cyclic#5" />
  <TaskClass Name="Cyclic#6" />
  <TaskClass Name="Cyclic#7" />
  <TaskClass Name="Cyclic#8">
    <Task Name="picctrl" Source="pkgRecipe.picctrl.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="tool_hdl" Source="pkgRecipe.tool_hdl.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="csv_hdl" Source="pkgRecipe.csv_hdl.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="save2USB" Source="pkgRecipe.save2USB.prg" Memory="UserROM" Language="IEC" Debugging="true" />
  </TaskClass>
  <DataObjects>
    <DataObject Name="Acp10sys" Source="" Memory="UserROM" Language="Binary" />
  </DataObjects>
  <NcDataObjects>
    <NcDataObject Name="acp10etxde" Source="acp10etxde.dob" Memory="UserROM" Language="Ett" />
    <NcDataObject Name="gunwfeedi" Source="AxisObj.gunwfeedi.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="gunwfeeda" Source="AxisObj.gunwfeeda.dob" Memory="UserROM" Language="Apt" />
    <NcDataObject Name="gmasteri" Source="AxisObj.gmasteri.dob" Memory="UserROM" Language="Vax" />
    <NcDataObject Name="gpbs1i" Source="AxisObj.gpbs1i.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="gpbs2i" Source="AxisObj.gpbs2i.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="gcut1i" Source="AxisObj.gcut1i.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="gcut2i" Source="AxisObj.gcut2i.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="gunwopi" Source="AxisObj.gunwopi.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="gunwdrvi" Source="AxisObj.gunwdrvi.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="ggrid1i" Source="AxisObj.ggrid1i.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="ggrid2i" Source="AxisObj.ggrid2i.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="gbufferi" Source="AxisObj.gbufferi.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="glongcuti" Source="AxisObj.glongcuti.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="gcatchbi" Source="AxisObj.gcatchbi.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="ggridfeedi" Source="AxisObj.ggridfeedi.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="gconvbi" Source="AxisObj.gconvbi.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="gbuffera" Source="AxisObj.gbuffera.dob" Memory="UserROM" Language="Apt" />
    <NcDataObject Name="ggrida" Source="AxisObj.ggrida.dob" Memory="UserROM" Language="Apt" />
    <NcDataObject Name="gunwa" Source="AxisObj.gunwa.dob" Memory="UserROM" Language="Apt" />
    <NcDataObject Name="gpbs1a" Source="AxisObj.gpbs1a.dob" Memory="UserROM" Language="Apt" />
    <NcDataObject Name="gpbs2a" Source="AxisObj.gpbs2a.dob" Memory="UserROM" Language="Apt" />
    <NcDataObject Name="gcatchba" Source="AxisObj.gcatchba.dob" Memory="UserROM" Language="Apt" />
    <NcDataObject Name="gsafetya" Source="AxisObj.gsafetya.dob" Memory="UserROM" Language="Apt" />
    <NcDataObject Name="gconvbelta" Source="AxisObj.gconvbelta.dob" Memory="UserROM" Language="Apt" />
    <NcDataObject Name="acp10etxd1" Source="acp10etxde.dob" Memory="UserROM" Language="Ett" />
    <NcDataObject Name="gPackBelta" Source="AxisObj.gPackBelta.dob" Memory="UserROM" Language="Apt" />
    <NcDataObject Name="gPackBelti" Source="AxisObj.gPackBelti.dob" Memory="UserROM" Language="Ax" />
    <NcDataObject Name="gCut1" Source="" Memory="DRAM" Language="Binary" />
    <NcDataObject Name="gCut2" Source="" Memory="DRAM" Language="Binary" />
    <NcDataObject Name="ggridfeede" Source="" Memory="UserROM" Language="Binary" />
  </NcDataObjects>
  <VcDataObjects>
    <VcDataObject Name="Visu" Source="Visualization.VisuCycl.Visu.dob" Memory="UserROM" Language="Vc" WarningLevel="2" Compress="false" />
    <VcDataObject Name="Visu1" Source="Visualization.VisuCycl.Visu1.dob" Memory="UserROM" Language="Vc" WarningLevel="2" Compress="false" />
    <VcDataObject Name="Visu2" Source="Visualization.VisuCycl.Visu2.dob" Memory="UserROM" Language="Vc" WarningLevel="2" Compress="false" />
  </VcDataObjects>
  <Binaries>
    <BinaryObject Name="vcpkat" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcnet" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpdvnc" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccpopup" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcclbox" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcctext" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccovl" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccalarm" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Visu03" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccnum" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcchspot" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="arialbd" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccline" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccbtn" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccstr" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccddbox" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccbmp" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccshape" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccdt" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcfile" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="arial" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vctcal" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcshared" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcrt" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcmgr" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcbclass" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Visu02" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcgclass" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcdsint" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcptelo" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Visu01" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpdsw" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpfapc" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcresman" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpdi855" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpdi815" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcfntttf" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcalarm" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcdsloc" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpfmtcx" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="visvc" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Visu103" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpdihd" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Visu102" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpfpp50" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Visu101" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcvisapi" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Visu202" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcchtml" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Visu201" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccurl" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcxml" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Visu203" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="acp10cfg" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="acp10map" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="asfw" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="iomap" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="arconfig" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="sysconf" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="ashwd" Source="" Memory="SystemROM" Language="Binary" />
  </Binaries>
  <Libraries>
    <LibraryObject Name="Acp10man" Source="Libraries.Acp10man.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Acp10par" Source="Libraries.Acp10par.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="NcGlobal" Source="Libraries.NcGlobal.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="UtilTyp" Source="Libraries.UtilTyp.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="AsARCfg" Source="Libraries.AsARCfg.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsBrMath" Source="Libraries.AsBrMath.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsBrStr" Source="Libraries.AsBrStr.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsMem" Source="Libraries.AsMem.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="asstring" Source="Libraries.asstring.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsUSB" Source="Libraries.AsUSB.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="brsystem" Source="Libraries.brsystem.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="FileIO" Source="Libraries.FileIO.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="LoopConR" Source="Libraries.LoopConR.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="powerlnk" Source="Libraries.powerlnk.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="standard" Source="Libraries.standard.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="sys_lib" Source="Libraries.sys_lib.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Visapi" Source="Libraries.Visapi.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="CSV_File" Source="Libraries.CSV_File.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="HlpStr" Source="Libraries.HlpStr.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="SwitchConf" Source="Libraries.SwitchConf.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="TorqueCtrl" Source="Libraries.TorqueCtrl.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="UserVC" Source="Libraries.UserVC.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="Acp10_MC" Source="Libraries.Acp10_MC.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Acp10sdc" Source="Libraries.Acp10sdc.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="SafeMC" Source="Libraries.SafeMC.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="MC_RegMa" Source="Libraries.MC_RegMa.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsMath" Source="Libraries.AsMath.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Acp10sim" Source="Libraries.Acp10sim.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsWndCon" Source="Libraries.AsWndCon.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="UserSpilke" Source="Libraries.UserSpilke.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="SprMachine" Source="Libraries.SprMachine.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="SprManual" Source="Libraries.SprManual.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="SprSetup" Source="Libraries.SprSetup.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="SprRegMa" Source="Libraries.SprRegMa.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="SprGeneral" Source="Libraries.SprGeneral.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="Runtime" Source="Libraries.Runtime.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsTime" Source="Libraries.AsTime.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Bibliothek" Source="Bibliothek.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="dataobj" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="asieccon" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
  </Libraries>
</SwConfiguration>