﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

CoordMode,ToolTip,Screen
CoordMode,Mouse,Screen
mypassword=aldrinjohnom
basevariation:=40
randomizermode:=0 ; name spoofing

gosub,updatenicknamedatabase
SetTimer,updatenicknamedatabase,60000,-1

return

~end::
ExitApp

~^F10::
if (randomizermode<2)
	randomizermode+=1
else randomizermode := 0
if (randomizermode = 0)
	ToolTip,Name Randomizer Mode: Name Spoofer,%A_ScreenWidth%,0
else if (randomizermode = 1)
	ToolTip,Name Randomizer Mode: Characters Generator,%A_ScreenWidth%,0
else if (randomizermode = 2)
	ToolTip,Name Randomizer Mode: Name Generator,%A_ScreenWidth%,0
settimer,removetooltip,-2000
return

removetooltip:
tooltip
return

~F10::
;if GetKeyState("Ctrl","P")
;{
;	if (randomizermode<2)
;		randomizermode+=1
;	else randomizermode := 0
;	if (randomizermode = 0)
;		ToolTip,Name Randomizer Mode: Name Spoofer
;	else if (randomizermode = 1)
;		ToolTip,Name Randomizer Mode: Characters Generator
;	else if (randomizermode = 2)
;		ToolTip,Name Randomizer Mode: Name Generator
;	msgbox %randomizermode%
;	return
;}
send,t
sleep 250
send,^a/changename{Enter}

insertpassword:
timer:=A_TickCount
while true
{
	variation:=A_Index+basevariation
	ImageSearch, OutputVarX, OutputVarY, 556, 308, 820, 471,*%variation% %A_ScriptDir%\inspass.png
	if (ErrorLevel=0) or (A_TickCount-timer>=5000)
	{
		tooltip,password sent at index %variation%,1,1
		send,%mypassword%{Enter}
		break
	}
	tooltip,stuck at loop 13 with index %A_Index%,1,1
}

if (randomizermode=0) and (nickname.Count()>0) ; name spoofing method
	randomizedname:=namespoofer(nickname) ; passed parameter must be an array
else if (randomizermode=1) ; random character method
	randomizedname:=randomizedcharacters()
else ;if (randomizermode=2)
	randomizedname:=RandomName(6,18) ; random name generator method

reinsertname:
timer:=A_TickCount
while true
{
	variation:=A_Index+basevariation
	ImageSearch, OutputVarX, OutputVarY, 556, 308, 820, 471,*%variation% %A_ScriptDir%\insname.png
	if (ErrorLevel=0) or (A_TickCount-timer>=5000)
	{
		tooltip,name sent at index %variation%,1,1
		send,%randomizedname%{Enter}
		break
	}
	else
	{
		ImageSearch, OutputVarX, OutputVarY, 556, 308, 820, 471,*%variation% %A_ScriptDir%\inspass.png
		if (ErrorLevel=0) ;or (A_TickCount-timer>5000)
			goto,insertpassword
	}
	tooltip,stuck at loop 12 with index %A_Index%,1,1
}
timer:=A_TickCount
while (A_TickCount-timer<1000)
{
	ImageSearch, OutputVarX, OutputVarY, 556, 308, 820, 471,*%variation% %A_ScriptDir%\insname.png
	if (ErrorLevel=0)
		goto,reinsertname
}

clipboard:=savename:=randomizedname
tooltip
return

~F11::
clipboard:=savename
return

updatenicknamedatabase:
Random, fakequery , 0, 100
UrlDownloadToFile,https://monitor.sacnr.com/server-1872899.html?fakeParam=%fakequery% , %A_Temp%\ref.html
FileRead,content1,%A_Temp%\ref.html
UrlDownloadToFile,https://monitor.teamshrimp.com/server-11976.html?fakeParam=%fakequery% , %A_Temp%\ref.html
FileRead,content2,%A_Temp%\ref.html
FileDelete,%A_Temp%\ref.html
;get last update time lapse in seconds format for SACNR
pos1:=instr(content1,"Last Update:</th><td>")+21
pos2:=instr(content1,":",,pos1)
oldhour:=substr(content1,pos1,pos2-pos1)+0
pos2+=1
pos1:=instr(content1,":",,pos2)
oldminute:=substr(content1,pos2,pos1-pos2)+0
pos1+=1
pos2:=instr(content1,",",,pos1)
oldsecond:=substr(content1,pos1,pos2-pos1)+0
newhour := (A_Hour<6?24:A_Hour) - 6 ;gmt -6 respect to philippines
SACNRupdatetime:=((newhour-oldhour)*3600)+((A_Min-oldminute)*60)+A_Sec-oldsecond
;
;get last update time lapse in seconds format for teamshrimp
pos1:=instr(content2,"Last Update</th></b><td>")+24
pos2:=instr(content2," days",,pos1)
oldday:=substr(content2,pos1,pos2-pos1)+0
pos2+=7
pos1:=instr(content2," hours",,pos2)
oldhour:=substr(content2,pos2,pos1-pos2)+0
pos1+=8
pos2:=instr(content2," minutes",,pos1)
oldminute:=substr(content2,pos1,pos2-pos1)+0
pos2+=10
pos1:=instr(content2," seconds",,pos2)
oldsecond:=substr(content2,pos2,pos1-pos2)+0
teamshrimpupdatetime:=(oldday*86400)+(oldhour*3600)+(oldminute*60)+oldsecond
;
if (teamshrimpupdatetime<SACNRupdatetime)
{ ; do teamshrimp parse
	pos1:=instr(content2,"<tr><td><b>Player ID</b></td><td><b>Nickname</b></td><td><b>Score</b></td><td><b>Ping</b></td></tr>")+99
	pos2:=instr(content2,"</table></div>",,pos1)
	content2:=substr(content2,pos1,pos2-pos1)
	nickname:=[]
	strreplace(content2,"</td><td>","</td><td>",count)
	loop % count/3
	{
		pos1:=instr(content2,"</td><td>",,,(A_Index*3)-2)+9
		pos2:=instr(content2,"</td><td>",,,(A_Index*3)-1)
		nickname[A_Index]:=substr(content2,pos1,pos2-pos1)
	}
}
else ; do sacnr parse
{
	pos1:=instr(content1,"/>Players Online</h2>")
	pos2:=instr(content1,"</table></div></div>",,pos1)
	content1:=substr(content1,pos1,pos2-pos1)
	strreplace(content1,"</td>`n				<td>",,count)
	nickname:=[]
	loop % count/3
	{
		pos1:=instr(content1,"</td>`n				<td>",,,(A_Index*3)-2)+14
		pos2:=instr(content1,"</td>`n				<td>",,,(A_Index*3)-1)
		nickname[A_Index]:=substr(content1,pos1,pos2-pos1)
	}
}
return

namespoofer(nicknamelist) ; nicknamelist must be an digit indexed array
{
	if !(nicknamelist.Count()>0)
		return
	
	;static array declaration
	Static usednamelist
	if !IsObject(usednamelist)
		usednamelist:=[]
	
revalidatename:
	if (usednamelist.Count()>=nicknamelist.Count()) ; this avoids the "all names are used" possibility
	{
		while usednamelist.Count()>=nicknamelist.Count()
		{
			tooltip,%A_Index% at 10,0,0
			usednamelist.Pop()
		}
	}
	
	loop ; picks a name that was not yet used before
	{
		tooltip,%A_Index% at 11,0,0
		Random,pos1,1,% nicknamelist.Count()
		spoofedname:=nicknamelist[pos1]
		if !namewasused(usednamelist,spoofedname)
			break
	}
	
	usednamelist.InsertAt(1,spoofedname) ; register the name to the used name lists
	
	if instr(spoofedname,"I",true) or instr(spoofedname,"l",true) ; the most deceiving name spoofing interchanging I into l and vice versa
	{
		StringCaseSense, On
		savespoofedname:=spoofedname
		
		pos1:=1
		while pos1:=RegExMatch(spoofedname,"[Il]",,pos1) ; if a I or l exist
		{
			tooltip,name:%savespoofedname%`pos1:%pos1% at 9,0,0
			random,pos2,0,1
			spoofedname := substr(spoofedname,1,pos1-1) . (pos2!=0?"I":"l") . substr(spoofedname,pos1+1)
			pos1+=1 ; skip the found character
		}
		
		if (savespoofedname=spoofedname)
		{
			; random offset generator stage
			loop
			{
				tooltip,name:%savespoofedname%`nindex:%A_Index% at 8,0,0
				Random,pos1,1,% strlen(spoofedname) ; random character offset of the nickname
				if RegExMatch(substr(spoofedname,pos1,1),"[Il]") ; it should be either "I or l"!
					break
			}
			charvar := substr(spoofedname,pos1,1) ; get the character
			;primary name spoofing stage
			spoofedname:= substr(spoofedname,1,pos1-1) . (charvar!="I"?"I":"l") . substr(spoofedname,pos1+1)
		}
		StringCaseSense, Off
	}
	else if pos1:=RegExMatch(spoofedname,"\d") ; if a digit exist
	{ ; then change a digit
		; random offset generator stage
		loop
		{
			tooltip,name:%spoofedname%`nindex:%A_Index% at 1,0,0
			Random,pos1,1,% strlen(spoofedname) ; random character offset of the nickname
			if RegExMatch(substr(spoofedname,pos1,1),"\d") ; it should be a digit!
				break
		}
		; random character generator stage
		charvar := substr(spoofedname,pos1,1) ; get the matched character from the regex
		pos2 := ""
		loop
		{
			tooltip,name:%spoofedname%`nindex:%A_Index% at 2,0,0
			random,pos2,0,9
			if (pos2 != charvar)
				break
		}
		;name spoofing stage
		spoofedname:= substr(spoofedname,1,pos1-1) . pos2 . substr(spoofedname,pos1+1)
	}
	else if pos1:=RegExMatch(spoofedname,"(?=\w)[^AaEeIiOoUu]") ; if a non-consonant exist
	{ ; then change a non-consonant character
		; random offset generator stage
		loop
		{
			tooltip,name:%spoofedname%`nindex:%A_Index% at 3,0,0
			Random,pos1,1,% strlen(spoofedname) ; random character offset of the nickname
			if RegExMatch(substr(spoofedname,pos1,1),"(?=\w)[^AaEeIiOoUu]") ; it should be a non-consonant!
				break
		}
		; random character generator stage
		charvar := substr(spoofedname,pos1,1) ; get the matched character from the regex
		pos2 := ""
		loop
		{
			tooltip,name:%spoofedname%`nindex:%A_Index% at 4,0,0
			Random,pos2,65,122 ; ascii nondigit randomizer
			if !RegExMatch(chr(pos2),"(?=\w)[AaEeIiOoUu]") and (charvar!=chr(pos2)) ; if its a non-consonant character and the random character is not equal to the original character
			{
				if charvar is upper ; if uppercase then the randomized character must be uppercase too
				{
					if (pos2<=90)
						break
				}
				else if charvar is lower ; if lowercase then the randomized character must be lowercasee too
				{
					if (pos2>=97)
						break
				}
			}
		}
		;name spoofing stage
		spoofedname:= substr(spoofedname,1,pos1-1) . chr(pos2) . substr(spoofedname,pos1+1)
	}
	else if pos1:=RegExMatch(spoofedname,"(?=\w)[AaEeIiOoUu]") ; if a consonant exist
	{ ; then change a consonant character
		; random offset generator stage
		loop
		{
			tooltip,name:%spoofedname%`nindex:%A_Index% at 5,0,0
			Random,pos1,1,% strlen(spoofedname) ; random character offset of the nickname
			if RegExMatch(substr(spoofedname,pos1,1),"(?=\w)[AaEeIiOoUu]") ; it should be a consonant!
				break
		}
		; random character generator stage
		charvar := substr(spoofedname,pos1,1) ; get the picked character
		loop
		{
			tooltip,name:%spoofedname%`nindex:%A_Index% at 6,0,0
			Random,pos2,1,5 ; 1-5 = five consonants (a/A e/E i/I o/O u/U)
			if charvar is upper ; if uppercase then the randomized character must be uppercase too
			{
				randchar := substr("AEIOU",pos2,1)
				if (randchar!=charvar)
					break
			}
			else if charvar is lower ; if lowercase then the randomized character must be lowercasee too
			{
				randchar := substr("aeiou",pos2,1)
				if (randchar!=charvar)
					break
			}
		}
		;name spoofing stage
		spoofedname := substr(spoofedname,1,pos1-1) . randchar . substr(spoofedname,pos1+1)
	}
	else ; force replace a random character
	{
		; random offset generator stage
		Random,pos1,2,% strlen(spoofedname)-1 ; between second character and the second to the last character
		charvar := substr(spoofedname,pos1,1) ; get the picked character
		; random character generator stage
		loop
		{
			;tooltip,name:%spoofedname%`nindex:%A_Index% at 7,0,0
			Random,pos2,48,122
			if ((pos2<=57) or ((pos2>=65) and (pos2<=90)) or (pos2>=97)) and (charvar!=chr(pos2))
				break
		}
		;name spoofing stage
		spoofedname := substr(spoofedname,1,pos1-1) . chr(pos2) . substr(spoofedname,pos1+1)
	}
	
	loop % nicknamelist.Count() ; nickname collision checker
	{
		if (spoofedname=nicknamelist[A_Index])
			goto,revalidatename
			break
	}
	
	return spoofedname
}

randomizedcharacters(MinLength:=10, MaxLength:=18)
{
	MinLength:=Format("{:d}", MinLength)
	MaxLength:=Format("{:d}", MaxLength)
	if (MinLength<MaxLength)
		MaxLength:=MinLength
	
	Random,charcount,%MinLength%,%MinLength%
	
	randomizedcharname:=""
	loop %charcount%
	{
		loop
		{
			Random,asciinumber,48,122
			if ((asciinumber<=57) and (randomizedcharname!="")) or ((asciinumber>=65) and (asciinumber<=90)) or (asciinumber>=97)
				break
		}
		randomizedcharname.=Chr(asciinumber)
	}
	return randomizedcharname
}

RandomName(MinLength:=4, MaxLength:=0)
{	

	;This is a table of probabilities of given letter combinations.
	;Each list is the probability of any letter coming after the letter that is the variable name.
	;The 27th value is the probability that the word ends with the current letter.

	A=0.005129|0.020532|0.038276|0.031753|0.005903|0.009913|0.027038|0.014457|0.023527|0.003511|0.021702|0.086397|0.045315|0.192551|0.002685|0.014491|0.001136|0.142056|0.059445|0.043698|0.041322|0.018312|0.010774|0.001824|0.020584|0.010240|0.107428
	B=0.184518|0.021072|0.000500|0.002564|0.243982|0.000125|0.000188|0.002564|0.076033|0.001313|0.001563|0.055274|0.000875|0.002376|0.132933|0.000063|0.000000|0.133683|0.009192|0.000313|0.090977|0.000188|0.000125|0.000000|0.022447|0.000313|0.016820
	C=0.131713|0.001253|0.042204|0.003536|0.053348|0.001566|0.008727|0.275689|0.051557|0.000090|0.154493|0.028375|0.003849|0.004117|0.123255|0.001343|0.002954|0.036744|0.002506|0.003043|0.028419|0.000806|0.001343|0.000000|0.004699|0.017678|0.016694
	D=0.103809|0.005881|0.001079|0.024765|0.256609|0.003345|0.017266|0.006367|0.102029|0.000701|0.002968|0.027085|0.008849|0.007985|0.107424|0.000432|0.000432|0.046833|0.019208|0.017427|0.044783|0.001619|0.007068|0.000000|0.020557|0.005288|0.160192
	E=0.031341|0.012931|0.019802|0.020976|0.022773|0.007726|0.014163|0.010930|0.034414|0.002392|0.012409|0.104894|0.023455|0.108561|0.004291|0.007973|0.000464|0.239084|0.062957|0.042633|0.006958|0.011727|0.010582|0.001363|0.039371|0.008379|0.137452
	F=0.111275|0.000369|0.000985|0.000246|0.170236|0.139463|0.000985|0.000985|0.112752|0.000492|0.003570|0.058961|0.004677|0.004677|0.114476|0.000246|0.000123|0.100197|0.011324|0.021295|0.041113|0.000369|0.000246|0.000000|0.003570|0.000862|0.096504
	G=0.140257|0.004596|0.000919|0.003493|0.199694|0.002145|0.030944|0.064951|0.064767|0.000551|0.000919|0.053922|0.006311|0.020282|0.084191|0.000551|0.000368|0.083027|0.019179|0.012316|0.063725|0.000797|0.004718|0.000245|0.003309|0.000123|0.133701
	H=0.214954|0.004703|0.001599|0.001035|0.189466|0.002116|0.000564|0.002069|0.102610|0.000658|0.003621|0.037903|0.020973|0.022384|0.124759|0.000329|0.000000|0.032683|0.006207|0.021067|0.054221|0.000517|0.009358|0.000000|0.009828|0.000141|0.136233
	I=0.044717|0.012847|0.076362|0.026840|0.088736|0.009884|0.035604|0.003560|0.000896|0.001320|0.015511|0.082586|0.027886|0.216811|0.031571|0.012474|0.001270|0.031247|0.081889|0.054502|0.004158|0.011802|0.001494|0.002938|0.001245|0.009262|0.112588
	J=0.333844|0.000510|0.012251|0.006126|0.211843|0.000000|0.001021|0.003063|0.059214|0.001021|0.010720|0.002552|0.003063|0.009188|0.197550|0.000000|0.000000|0.000000|0.002552|0.007657|0.110260|0.000000|0.001021|0.000000|0.000510|0.001531|0.024502
	K=0.105301|0.002453|0.000239|0.000658|0.194089|0.001615|0.000120|0.013522|0.166507|0.000838|0.003889|0.046787|0.009633|0.017470|0.101412|0.000299|0.000060|0.036078|0.023932|0.001137|0.039069|0.000897|0.004786|0.000239|0.025009|0.000179|0.203781
	L=0.142144|0.012700|0.007785|0.033484|0.190748|0.007136|0.004641|0.004666|0.115222|0.000499|0.010554|0.157140|0.017815|0.003019|0.079568|0.004042|0.000549|0.002146|0.023429|0.022031|0.025599|0.007884|0.002770|0.000075|0.015320|0.004292|0.104743
	M=0.313971|0.039109|0.071357|0.001102|0.144316|0.001552|0.001502|0.001252|0.093991|0.000300|0.003756|0.007561|0.032849|0.001753|0.110366|0.030796|0.000451|0.004507|0.016475|0.000701|0.039509|0.000150|0.001052|0.000000|0.007161|0.000801|0.073660
	N=0.061413|0.016703|0.021091|0.069684|0.122481|0.004871|0.078736|0.008455|0.062562|0.000942|0.020976|0.004802|0.002481|0.042114|0.058036|0.001011|0.000712|0.003538|0.053877|0.050017|0.007168|0.001746|0.003331|0.000000|0.007099|0.011970|0.284182
	O=0.008524|0.017299|0.028237|0.027181|0.024717|0.015061|0.013377|0.013477|0.008725|0.002338|0.011843|0.083101|0.033291|0.169068|0.030248|0.016394|0.000654|0.114958|0.060421|0.038018|0.047975|0.020140|0.041337|0.002791|0.010611|0.008725|0.151492
	P=0.176699|0.000875|0.001459|0.000972|0.201984|0.015365|0.000292|0.038802|0.113099|0.000097|0.010503|0.051055|0.002334|0.003209|0.103958|0.076145|0.000000|0.074492|0.021103|0.010114|0.033064|0.000194|0.000875|0.000000|0.007002|0.000097|0.056209
	Q=0.006831|0.001366|0.000000|0.001366|0.000000|0.000000|0.000000|0.000000|0.005464|0.000000|0.000000|0.000000|0.000000|0.000000|0.000000|0.000000|0.000000|0.001366|0.000000|0.000000|0.968579|0.001366|0.000000|0.000000|0.000000|0.000000|0.013661
	R=0.107889|0.012734|0.012774|0.039466|0.114066|0.005515|0.027955|0.005334|0.100509|0.000762|0.014499|0.017507|0.018449|0.029038|0.095937|0.004171|0.001043|0.037882|0.037180|0.049252|0.031785|0.005475|0.003068|0.000160|0.020154|0.005715|0.201681
	S=0.063337|0.009701|0.073814|0.002910|0.097763|0.001774|0.001525|0.060925|0.050808|0.000554|0.061286|0.020318|0.015134|0.008482|0.067384|0.021426|0.002328|0.001663|0.053885|0.132300|0.016797|0.001247|0.011808|0.000000|0.003964|0.007429|0.211437
	T=0.091587|0.001630|0.012519|0.000347|0.159384|0.001595|0.001769|0.072652|0.074005|0.001283|0.006208|0.018484|0.009294|0.007352|0.110522|0.000555|0.000069|0.065543|0.026564|0.109169|0.024691|0.000763|0.005098|0.000000|0.013525|0.036447|0.148946
	U=0.021849|0.032911|0.052449|0.040176|0.074243|0.017281|0.047056|0.012163|0.041827|0.002862|0.015190|0.084205|0.058118|0.084810|0.006219|0.021354|0.001101|0.136984|0.111833|0.065658|0.000881|0.005449|0.002367|0.008806|0.007320|0.013979|0.032911
	V=0.281558|0.000162|0.000647|0.001293|0.327461|0.000162|0.000323|0.000162|0.251657|0.000485|0.001616|0.010991|0.000162|0.003071|0.078390|0.000000|0.000000|0.012769|0.007435|0.000323|0.004687|0.000162|0.000323|0.000000|0.007112|0.000485|0.008566
	W=0.204323|0.006032|0.003770|0.009801|0.191380|0.000880|0.001131|0.037824|0.200804|0.000000|0.005278|0.018472|0.003644|0.016210|0.092109|0.000377|0.000126|0.013948|0.074265|0.004398|0.007665|0.000628|0.000628|0.000000|0.015582|0.000628|0.090098
	X=0.063694|0.022293|0.004777|0.001592|0.081210|0.012739|0.000000|0.011146|0.065287|0.000000|0.001592|0.039809|0.014331|0.014331|0.044586|0.001592|0.000000|0.004777|0.033439|0.078025|0.007962|0.000000|0.014331|0.003185|0.004777|0.001592|0.472930
	Y=0.061443|0.012165|0.011753|0.016289|0.072062|0.003505|0.004845|0.004845|0.003505|0.000206|0.016907|0.026495|0.018763|0.042268|0.032680|0.003711|0.000206|0.014330|0.026186|0.011856|0.008763|0.001443|0.004021|0.000206|0.000412|0.002887|0.598247
	Z=0.165246|0.006787|0.005366|0.004261|0.174085|0.000947|0.004261|0.003946|0.121370|0.000000|0.014205|0.018466|0.017045|0.009154|0.066761|0.000789|0.001578|0.001578|0.004104|0.000631|0.035827|0.000631|0.008996|0.000000|0.034722|0.058396|0.240846
	Start=0.037129|0.091544|0.068008|0.055260|0.020789|0.036464|0.052670|0.058435|0.006802|0.012894|0.051228|0.053638|0.085992|0.020597|0.016318|0.052275|0.002725|0.047647|0.109494|0.038852|0.004460|0.023480|0.036127|0.000180|0.006261|0.010732
	

	;This allows numerical values to easily be converted to letters.
	Alphabet = ABCDEFGHIJKLMNOPQRSTUVWXYZ
	
	Loop
	{
		;Checks for the previous letter to determine which set of probabilities to use.
		If (!Word)
			Previous = Start
		Else
			Previous := SubStr(Word, 0, 1)


		;Randomly chooses the next letter, based on the probabilities listed above.
		Random, rand, 0.0, 1.0
		Sum = 0
		Next =
		Loop, parse, %Previous%, |
		{
			Sum += A_LoopField
			If (rand<Sum)
			{
				Next := SubStr(Alphabet, A_Index, 1)
				Break
			}
		}


		;Finishes the word if the word randomly ends or reaches the maximum length.
		If ((!Next AND StrLen(Word)>=MinLength) OR (MaxLength AND StrLen(Word)=MaxLength))
			Break
	
		Word .= Next
	}
	
	StringLower, Word, Word, T
	Return, Word
}

namewasused(namelist,searchname)
{
	loop % namelist.Count()
	{
		if (namelist[A_Index]=searchname)
			return true
	}
	return false
}