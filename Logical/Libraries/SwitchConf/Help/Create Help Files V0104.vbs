'*****************************************************************************
'*   Copyright:  2002  B&R - Perfection in Automation                        *
'*---------------------------------------------------------------------------*
'*   Identification:                                                         *
'*       Filename  Create Help Files.vbs                                     *
'*                                                                           *
'*---------------------------------------------------------------------------*
'*   Description:                                                            *
'*     This script creates all hhx-files, which are ready for compiling to   *
'*     chm-Help files of Automation Studio libraries                         *
'*                                                                           *
'*---------------------------------------------------------------------------*
'*   History                                                                 *
'*   Version     Datum       Autor                                           *
'*   01.00       19.06.02    Th. Enzinger   created                          *
'*   01.01       21.06.02    W.  Paulin     additional meta tag string       *
'*                                          WEPA20020621                     *
'*   01.02       27.07.02    W.  Paulin     hhp-file: keyword "Language"     *
'*                                          added in order that keyword      *
'*                                          "Title" will be recognized by the*
'*                                          compiler                         *
'*                                          Version of script in MsgBox title*
'*                                          WEPA20020727                     *
'*   01.03       29.07.02    Th. Enzinger   Old Versions of Frontpage replace*
'*                                          the string <META ORDER=1> with   *
'*                                          <META ORDER="1"> automatically   *
'*                                          Because of this the sort         *
'*                                          algorythm did not work properly  *
'*                                          (0"100" was smaller than 000"1" )*
'*   01.04       07.08.02    W.  Paulin     Meta Tags "INDEX" for index file *
'*                                          *.hhk implented every value will *
'*                                          added to index list WEPA20020807 *
'* DON'T FORGET TO UPDATE CONSTANT SCRIPT_VERSION_STRING !!!                 *
'*****************************************************************************
Option Explicit

Const SCRIPT_VERSION_STRING = "VBScript V1.04"	' WEPA20020727		
Const CHM_DIR = "\Doc\CHTML"

Dim fso, localFolder, fileHHP, fileHHK, fileHHC
Dim basePath, libName, fileName
Dim i,fileNotFound

Set fso = CreateObject("Scripting.FileSystemObject")
Set localFolder = fso.GetFolder(".")             ' get the current path

fileNotFound = "ERROR :" & vbCrLf & vbCrLf & "File not found : "

'----------------------------------------------------------------------
' search for the directory name
'----------------------------------------------------------------------

basePath = localFolder.Path

if (right(basePath ,len(CHM_DIR)) <> CHM_DIR) then
	MsgBox "Directory structure wrong, " & vbCrLf & "path should end with """ & CHM_DIR & """", vbOK, SCRIPT_VERSION_STRING  ' WEPA20020727
	WScript.Quit
end if

basePath = left(basePath,len(basePath)-len(CHM_DIR))  ' make "....\user_lib"
libName  = mid(basePath, InStrRev(basePath,"\")+1 )   ' make "user_lib"

' warning to user
if ( MsgBox("The files " & libName & ".hhp, " & libName & ".hhk and " & libName & ".hhc" & " will be overwritten !",vbOKCancel, SCRIPT_VERSION_STRING) = 2 ) Then   ' WEPA20020727
	WScript.Quit
end if

'----------------------------------------------------------------------
' Prepare output files
'----------------------------------------------------------------------
Set fileHHP = fso.CreateTextFile( libName & ".hhp")	' prepare HHP file (Project File)
fileHHP.WriteLine "[OPTIONS]"
fileHHP.WriteLine "Auto Index=Yes"
fileHHP.WriteLine "Binary TOC=No"
fileHHP.WriteLine "Binary Index=Yes"
fileHHP.WriteLine "Compatibility=1.1"
fileHHP.WriteLine "Compiled file=Lib" & libName & ".chm"
fileHHP.WriteLine "Contents file=" & libName & ".hhc"
fileHHP.WriteLine "Default topic=" & libName & ".html"
fileHHP.WriteLine "Index file="    & libName & ".hhk"
fileHHP.WriteLine "Language=0x409 English (United States)"					' WEPA20020727
fileHHP.WriteLine "Title="         & libName
fileHHP.WriteLine "Full-text search=Yes"
fileHHP.WriteLine "Default window=main"
fileHHP.WriteLine "[WINDOWS]"
fileHHP.WriteLine "main=,""" & libName & ".hhc"",""" & libName & ".hhk"",""" & libName & ".html"",""" & libName & ".html"",,,,,0x23520,222,0x1046,[10,10,780,560],0xB0000,,,,,,0"
fileHHP.WriteLine "[FILES]"
fileHHP.WriteLine "styles.css"
fileHHP.WriteLine libName & ".html"

Set fileHHK = fso.CreateTextFile( libName & ".hhk")	' prepare HHK file (Index File)
fileHHK.WriteLine "<!DOCTYPE HTML PUBLIC ""-//IETF//DTD HTML//EN"">"
fileHHK.WriteLine "<HTML>"
fileHHK.WriteLine "<HEAD>"
fileHHK.WriteLine "<meta name=""GENERATOR"" content=""VB Script TE"">"
fileHHK.WriteLine "<!-- Sitemap 1.0 -->"
fileHHK.WriteLine "</HEAD>"
fileHHK.WriteLine "<BODY>"
fileHHK.WriteLine "<OBJECT type=""text/site properties""></OBJECT>"
fileHHK.WriteLine "<UL>"

Set fileHHC = fso.CreateTextFile( libName & ".hhc")	' prepare HHC file (Content File)
fileHHC.WriteLine "<!DOCTYPE HTML PUBLIC ""-//IETF//DTD HTML//EN"">"
fileHHC.WriteLine "<HTML>"
fileHHC.WriteLine "<HEAD>"
fileHHC.WriteLine "<meta name=""GENERATOR"" content=""VB Script TE"">"
fileHHC.WriteLine "<!-- Sitemap 1.0 -->"
fileHHC.WriteLine "</HEAD>"
fileHHC.WriteLine "<BODY>"
fileHHC.WriteLine "   <OBJECT type=""text/site properties"">"
fileHHC.WriteLine "     <param name=""Window Styles"" value=""0x800025"">"
fileHHC.WriteLine "     <param name=""comment"" value=""title:Online Help"">"
fileHHC.WriteLine "     <param name=""comment"" value=""base:index.htm"">"
fileHHC.WriteLine "   </OBJECT>"
fileHHC.WriteLine "   <UL>"
fileHHC.WriteLine "      <LI><OBJECT type=""text/sitemap"">"
fileHHC.WriteLine "            <param name=""Name"" value=""" & ReadTitle(libName &".html") & """>"
fileHHC.WriteLine "            <param name=""Local"" value=""" & libName & ".html"">"
fileHHC.WriteLine "            <param name=""ImageNumber"" value=""1"">"
fileHHC.WriteLine "          </OBJECT>"
fileHHC.WriteLine "      <UL>"

'----------------------------------------------------------------------
' Generate list of all files (except in _* directories)
'----------------------------------------------------------------------
TreeSearch "", localFolder, FALSE

'----------------------------------------------------------------------
' Finish output files
'----------------------------------------------------------------------
fileHHK.WriteLine "</UL>"
fileHHK.WriteLine "</BODY>"
fileHHK.WriteLine "</HTML>"

fileHHC.WriteLine "      </UL>"
fileHHC.WriteLine "   </UL>"
fileHHC.WriteLine "</BODY>"
fileHHC.WriteLine "</HTML>"

MsgBox "Help files created, now you can compile them to .chm !", vbOK, SCRIPT_VERSION_STRING  ' WEPA20020727

'----------------------------------------------------------------------
' TreeSearch : Recoursive function to build up the output files
'----------------------------------------------------------------------

Private Function TreeSearch(pathName, baseFolder, fileEnable)
	Dim folderList, folder
	Dim fileList, file, title,i
	Dim topicText
	Dim listOrder(), listObj()
	
	
	'---- get file list -----
	if (fileEnable = TRUE) then
		Set fileList = baseFolder.Files
		
		ReDim listOrder(fileList.count)
		ReDim listObj(fileList.count)
		
		' fill ORDER-Tag and objects in arrays for sorting
		i=1
		For Each file in fileList
			On Error Resume Next	' ignore error in case file to this folder does not exist
			listOrder(i) = ReadOrder( file.Path )
			On Error Goto 0
			
			set listObj(i)  = file
			i=i+1
		Next

		SortArray fileList.count, listOrder, listObj	' sort object list by order array
		
		For i=1 To fileList.count
			set file = listObj(i)
			
			' add file to project file
			fileHHP.WriteLine pathName & file.Name

	
			' extended keywords of html-files for index file /Begin						WEPA20020807
			If (right(file.Name,5) = ".html") then
				ReadIndex file.Path, pathName, file.Name, fileHHK
			End If
			' extended keywords of html-files for index file /End						


			' only take .html files (but not these with the same name as the folder
			If (right(file.Name,5) = ".html" and file.Name <> (baseFolder.name & ".html")  ) then
				' open html file to get title
				title = ReadTitle(file.Path)
			
				' add entry to index file
				fileHHK.WriteLine vbTab & "<LI><OBJECT type=""text/sitemap"">"
				fileHHK.WriteLine vbTab & vbTab & "<param name=""Name"" value=""" & title & """>"
				fileHHK.WriteLine vbTab & vbTab & "<param name=""Local"" value=""" & pathName & file.Name & """>"
				fileHHK.WriteLine vbTab & "</OBJECT>"
				
				' add entry to content file
				fileHHC.WriteLine "<LI><OBJECT type=""text/sitemap"">"
				fileHHC.WriteLine "      <param name=""Name"" value=""" & title & """>"
				fileHHC.WriteLine "      <param name=""Local"" value=""" & pathName & file.Name & """>"
				fileHHC.WriteLine "      <param name=""ImageNumber"" value=""11"">"
				fileHHC.WriteLine "    </OBJECT>"
			end if
		Next
	end if
	
	' call this function recursive for all folders
	Set folderList = baseFolder.SubFolders

	ReDim listOrder(folderList.count)
	ReDim listObj(folderList.count)
	
	' fill ORDER-Tag and objects in arrays for sorting
	i=1
	For Each folder in folderList
		On Error Resume Next	' ignore error in case file to this folder does not exist
		listOrder(i) = ReadOrder( folder.Path & "\" & folder.name & ".html" )
		On Error Goto 0
		
		set listObj(i)  = folder
		i=i+1
	Next

	SortArray folderList.count, listOrder, listObj	' sort object list by order array
		

	For i=1 To folderList.count
		Set folder = listObj(i)
		
		if (left(folder.name,1) <> "_"  and folder.name <> "images" ) then
			
			' replace 'FBKs' with 'Functions and Function Blocks'
			topicText = folder.name
			if (topicText = "FBKs") then topicText = "Functions and Function Blocks"
			
			' put folder-information to HHC file
			fileHHC.WriteLine "<LI><OBJECT type=""text/sitemap"">"
			fileHHC.WriteLine "      <param name=""Name"" value=""" & topicText & """>"
			fileHHC.WriteLine "      <param name=""Local"" value=""" & pathName & folder.name & "\" & folder.name & ".html"">"
			fileHHC.WriteLine "      <param name=""ImageNumber"" value=""1"">"
			fileHHC.WriteLine "    </OBJECT>"
			fileHHC.WriteLine "<UL>"
			
			TreeSearch pathName & folder.name & "\", fso.GetFolder(folder.Path) , TRUE
			
			fileHHC.WriteLine "</UL>"	' end of folder
			
		end if
	Next
End Function


'----------------------------------------------------------------------
' Sort the array 'obj' by the order in the array 'order'
'----------------------------------------------------------------------
Private Function SortArray(nbElements, ByRef order, ByRef obj)
	Dim sortAgain,i, temp

	Do 
		sortAgain = 0
		For i=1 To nbElements-1
			' exchange entries if necessary
			If (order(i) > order(i+1)) Then
				temp         = order(i)
				order(i)     = order(i+1)
				order(i+1)   = temp
				
				set temp     = obj(i)
				set obj(i)   = obj(i+1)
				set obj(i+1) = temp
				sortAgain = 1
			End If
		Next
	Loop Until (sortAgain=0)
End Function

'----------------------------------------------------------------------
' Read <title> information of html file
'----------------------------------------------------------------------
Private Function ReadTitle(filePath)
	Dim htmlFile, titleBeg, titleEnd, text
	
	titleBeg = 0
	titleEnd = 0
	
	ReadTitle = "<TITLE> not found !"
	
	Set htmlFile = fso.OpenTextFile(filePath)	' open file for reading
	
	text = htmlFile.ReadAll						' read complete file in 'text'
	
	titleBeg = Instr(1,text,"<TITLE>",1)
	
	if (titleBeg > 0) then
		titleBeg = titleBeg + len("<TITLE>")
		titleEnd = Instr(titleBeg,text,"</TITLE>",1)
		
		if (titleEnd > titleBeg) then
			ReadTitle = mid(text,titleBeg, titleEnd-titleBeg)
		else
			MsgBox "</TITLE> in file '" & filePath & "' not found !", vbOK, SCRIPT_VERSION_STRING  ' WEPA20020727
		end if
	else
		MsgBox "<TITLE> in file '" & filePath & "' not found !", vbOK, SCRIPT_VERSION_STRING  ' WEPA20020727
	end if
End Function


'----------------------------------------------------------------------
' Read <ORDER> information of html file
'----------------------------------------------------------------------
Private Function ReadOrder(filePath)
	Dim htmlFile, metaBeg, metaEnd, text
	
	ReadOrder = "999999"

	Set htmlFile = fso.OpenTextFile(filePath)	' open file for reading

	text = htmlFile.ReadAll						' read complete file in 'text'
	
	metaBeg = Instr(1,text,"<META ORDER=",1)
	
	If (metaBeg > 0) Then
		metaBeg = metaBeg + len("<META ORDER=")
		metaEnd = Instr(metaBeg,text,">",1)

		if (metaEnd > metaBeg) then
			ReadOrder = mid(text,metaBeg, metaEnd-metaBeg)
			
			' TE 20020729  -  cut " at the beginning and at the end away
			If (Left(ReadOrder,1) = """") Then ReadOrder = Mid(ReadOrder,2,Len(ReadOrder)-1)
			If (Right(ReadOrder,1) = """") Then ReadOrder = Mid(ReadOrder,1,Len(ReadOrder)-1)
			
			' add 0 at the front to avoid that 2 is bigger than 10 at the string compare
			ReadOrder = left("00000", 6-len(ReadOrder)) & ReadOrder
		end if
   	
   	' WEPA20020621
	Else										' meta tag could also look like that <meta name="ORDER" content="1"> (M$ Frontpage)
		metaBeg = Instr(1,text,"<meta name=""ORDER"" content=""",1)	' find <meta name="ORDER" content="

		If (metaBeg > 0) Then
			metaBeg = metaBeg + len("<meta name=""ORDER"" content=""")
			metaEnd = Instr(metaBeg,text,"""",1)

			if (metaEnd > metaBeg) then
				ReadOrder = mid(text,metaBeg, metaEnd-metaBeg)

				' add 0 at the front to avoid that 2 is bigger than 10 at the string compare
				ReadOrder = left("00000", 6-len(ReadOrder)) & ReadOrder
			end if
		end if

	End If

End Function



'----------------------------------------------------------------------
' Read <INDEX> information of html file 				WEPA20020807
'----------------------------------------------------------------------
Private Sub ReadIndex(filePath, relFilePath, fileName, fileHHK)
	Dim htmlFile, metaBeg, metaEnd, text, indexMetaValue

    Set htmlFile = fso.OpenTextFile(filePath)									' open file for reading
	text = htmlFile.ReadAll														' read complete file in 'text'
		
	metaEnd = 1																	' start loop at first character
	
	' read out every keyword listet as INDEX
	Do
		metaBeg = Instr(metaEnd,text,"<meta name=""INDEX"" content=""",1)		' find <meta name="INDEX" content="

		If (metaBeg > 0) Then
			metaBeg = metaBeg + len("<meta name=""INDEX"" content=""")
			metaEnd = Instr(metaBeg,text,"""",1)

			If (metaEnd > metaBeg) then
				indexMetaValue = mid(text,metaBeg, metaEnd-metaBeg)

				If (indexMetaValue <> "") Then
					fileHHK.WriteLine vbTab & "<LI><OBJECT type=""text/sitemap"">"
					fileHHK.WriteLine vbTab & vbTab & "<param name=""Name"" value=""" & indexMetaValue & """>"
					fileHHK.WriteLine vbTab & vbTab & "<param name=""Local"" value=""" & relFilePath & fileName & """>"
					fileHHK.WriteLine vbTab & "</OBJECT>"
				Else
					Exit Do
				End If	
			Else
				Exit Do
			End If	
		Else
			Exit Do
		End If 
	Loop
End Sub

