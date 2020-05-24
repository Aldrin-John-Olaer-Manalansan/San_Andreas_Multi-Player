#SingleInstance force
gui,add,button,gbrowsefile,Browse
gui,add,edit,+readonly vlist w800
gui,show
return

browsefile:
FileSelectFile,file,3,,Select the File you want to scan,*.txt
if ErrorLevel or (file="")
	return
FileRead,file,%file%
available=
loop 32
{
	index:=A_Index-1
	if !(RegExMatch(file,"(?<=\D)" index "@"))
	{
		if (available="")
			available.=index "@"
		else
			available.="," index "@"
	}
}
guicontrol,text,list,%available%
return

GuiClose:
exitapp