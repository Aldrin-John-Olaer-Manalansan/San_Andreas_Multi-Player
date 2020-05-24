#SingleInstance force
gui,add,button,gbrowsefile,Browse
gui,add,edit,+readonly vlist w800
gui,show
return

browsefile:
FileSelectFile,filedir,3,,Select the File you want to scan,*.txt
if ErrorLevel or (filedir="")
	return
FileRead,file,%filedir%

available=
array:=[]
offset:=1
while offset:=RegExMatch(file,"\$(?=\d)\d*",match,offset+strlen(match))
{
	if ((!instr(available,"," match) and !instr(available,match ",") and instr(available,",")) or (!instr(available,",") and !instr(available,match)))
	{
		if (available="")
			available.=match
		else
			available.="," match
		array[array.Count()+1]:=match
	}
}
guicontrol,text,list,%available%
loop % array.Count()
{
	Random,randomvar,5000,16383
	file := RegExReplace(file,"\" array[A_Index] "(?=\D)","$$" randomvar)
}
FileDelete,%filedir%.txt
FileAppend,%file%,%filedir%.txt
return

GuiClose:
exitapp