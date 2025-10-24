<?xml version="1.0" encoding="utf-8"?>
<?AutomationStudio Version=4.0.18.71 SP?>
<SwConfiguration CpuAddress="SL1" xmlns="http://br-automation.co.at/AS/SwConfiguration">
  <TaskClass Name="Cyclic#1" />
  <TaskClass Name="Cyclic#2">
    <Task Name="MAIN" Source="MainMachineCtrl.MAIN.prg" Memory="UserROM" Language="IEC" Debugging="true" />
  </TaskClass>
  <TaskClass Name="Cyclic#3">
    <Task Name="csv_hdl" Source="pkgRecipe.csv_hdl.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="tool_hdl" Source="pkgRecipe.tool_hdl.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="al_hdl" Source="pkgRecipe.al_hdl.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="picctrl" Source="pkgRecipe.picctrl.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="save2USB" Source="pkgRecipe.save2USB.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="VisuRange" Source="Visualization.VisuCycl.VisuRange.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="VisuPages" Source="Visualization.VisuCycl.VisuPages.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="VisuTasks" Source="Visualization.VisuCycl.VisuTasks.prg" Memory="UserROM" Language="IEC" Debugging="true" />
  </TaskClass>
  <TaskClass Name="Cyclic#4" />
  <TaskClass Name="Cyclic#5" />
  <TaskClass Name="Cyclic#6" />
  <TaskClass Name="Cyclic#7" />
  <TaskClass Name="Cyclic#8" />
  <DataObjects>
    <DataObject Name="Acp10sys" Source="" Memory="UserROM" Language="Binary" />
  </DataObjects>
  <NcDataObjects />
  <VcDataObjects>
    <VcDataObject Name="Visu" Source="Visualization.VisuCycl.Visu.dob" Memory="UserROM" Language="Vc" WarningLevel="2" Compress="false" />
  </VcDataObjects>
  <Binaries>
    <BinaryObject Name="iomap" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="asfw" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="sysconf" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="arconfig" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="ashwd" Source="" Memory="SystemROM" Language="Binary" />
    <BinaryObject Name="acp10map" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="acp10cfg" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccovl" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="visvc" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcfntttf" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccpopup" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccshape" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcctext" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccddbox" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="arial" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vctcal" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccdt" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccbtn" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccnum" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpfar00" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcdsint" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Visu02" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpdvnc" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcpdsw" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcalarm" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcchspot" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcfile" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcmgr" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccstr" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcresman" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcgclass" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcdsloc" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="arialbd" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcnet" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Visu03" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcrt" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccalarm" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcclbox" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccbmp" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcbclass" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vcshared" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="vccline" Source="" Memory="UserROM" Language="Binary" />
    <BinaryObject Name="Visu01" Source="" Memory="UserROM" Language="Binary" />
  </Binaries>
  <Libraries>
    <LibraryObject Name="AsWndCon" Source="Libraries.AsWndCon.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="CSV_File" Source="Libraries.CSV_File.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="HlpStr" Source="Libraries.HlpStr.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="AsTime" Source="Libraries.AsTime.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsBrMath" Source="Libraries.AsBrMath.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsBrStr" Source="Libraries.AsBrStr.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsMem" Source="Libraries.AsMem.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="FileIO" Source="Libraries.FileIO.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="UserVC" Source="Libraries.UserVC.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="UserSpilke" Source="Libraries.UserSpilke.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="Acp10man" Source="Libraries.Acp10man.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Bibliothek" Source="Bibliothek.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="Acp10par" Source="Libraries.Acp10par.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="NcGlobal" Source="Libraries.NcGlobal.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Acp10_MC" Source="Libraries.Acp10_MC.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="AsMath" Source="Libraries.AsMath.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="SprRegMa" Source="Libraries.SprRegMa.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="SprGeneral" Source="Libraries.SprGeneral.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="TorqueCtrl" Source="Libraries.TorqueCtrl.lby" Memory="UserROM" Language="IEC" Debugging="true" />
    <LibraryObject Name="LoopConR" Source="Libraries.LoopConR.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="runtime" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="asstring" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="standard" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="sys_lib" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="asieccon" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="visapi" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="brsystem" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="powerlnk" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="asusb" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="dataobj" Source="" Memory="UserROM" Language="Binary" Debugging="true" />
  </Libraries>
</SwConfiguration>