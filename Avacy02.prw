#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} Avacy02
Montagem de Kit(Caixa) - Avacy02

@author André Brito
@since 04/06/2019
@version P12
/*/
//-------------------------------------------------------------------

User Function Avacy02()

Local oBrowse
Local _oConMan      
Local aPWiz     := {}
Local aRetWiz   := {}
Local cQuery    := ""
Local cFilDe  	:= ""
Local cFilAte 	:= "" 
Local cConci  	:= "" 
Local cHist   	:= "" 
Local dDtDe   	:= CTOD("//") 
Local dDtAte  	:= CTOD("//")
Local cArqTrb   := GetNextAlias()
Local aCampos   := {}
Local cFiltro   := ""

Private oMark
Private nTotDeb   := 0
Private nTotCre   := 0
Private nTotSal   := 0
Private nValDeb   := 0
Private nValCre   := 0
Private nValSal   := 0
Private cProdDe   := "" 
Private cProdAte  := "" 
Private nCont     := 0
Private aRecno    := {}
Private cIdLanc   := ""
Private lMudaId   := .T.
Private lCarga    := .T.
Private cUltId    := ""
Private cMark     := GetMark()   

aAdd(aPWiz,{ 1,"Filial de: "                 ,Space(TamSX3("B1_FILIAL")[1])  ,"","","SM0","",9   ,.F.})
aAdd(aPWiz,{ 1,"Filial ate: "                ,Space(TamSX3("B1_FILIAL")[1])  ,"","","SM0","",9   ,.F.})
aAdd(aPWiz,{ 1,"Produto De: "                ,Space(TamSX3("B1_COD")[1])     ,"","","SB1","",    ,.F.})
aAdd(aPWiz,{ 1,"Produto Ate: "               ,Space(TamSX3("B1_COD")[1])     ,"","","SB1",  ,    ,.F.})
aAdd(aPWiz,{ 1,"Data De: "                   ,Ctod("")                       ,"","",""   ,  ,60  ,.F.})
aAdd(aPWiz,{ 1,"Data Ate: "                  ,Ctod("")                       ,"","",""   ,  ,60  ,.F.})

aAdd(aRetWiz,Space(TamSX3("B1_FILIAL")[1]))
aAdd(aRetWiz,Space(TamSX3("B1_FILIAL")[1]))
aAdd(aRetWiz,Space(TamSX3("B1_COD")[1]))
aAdd(aRetWiz,Space(TamSX3("B1_COD")[1]))
aAdd(aRetWiz,Ctod(""))
aAdd(aRetWiz,Ctod(""))

ParamBox(aPWiz,"***** Montagem de Kit - Avacy Distribuidora *****",@aRetWiz,,,,,,) 

cFilDe    := aRetWiz[1]
cFilAte   := aRetWiz[2] 
cProdDe   := aRetWiz[3]
cProdAt   := aRetWiz[4] 
dDtDe     := aRetWiz[5] 
dDtAte    := aRetWiz[6] 

oProcess := MsNewProcess():New( { || xProcKit(cFilde, cFilAte, cProdDe, cProdAt, dDtDe, dDtAte) } , "Carregando tabela temporária" , "Aguarde..." , .F. )
oProcess:Activate()

//-------------------------------------------------------------------

Static Function xProcKit(cFilde, cFilAte, cProdDe, cProdAt, dDtDe, dDtAte)
 
Local aCpoBro     := {} 
Local oDlgLocal 
Local aCores      := {}
Local aSize       := {} 
Local oPanel 
Local oSay1	
Local cArqTrb     := GetNextAlias()
Local cAliAux     := GetNextAlias()
Local oConta
Local cPictCta    := PesqPict("CT2","CT2_DEBITO")
Local cPictVlr    := PesqPict("CT2","CT2_VALOR")
Local aCampos     := {}
Local cQuery      := ""
Local _oConMan
Local oCheck1 
Local lCheck      := .F.
Local oChk

Private oTotDeb
Private oTotCre
Private oTotSal
Private nTotDeb   := 0
Private nTotCre   := 0
Private nTotSal   := 0
Private cConta    := ""
Private oVlrDeb
Private oVlrCre
Private oVlrSal
Private nVlrDeb   := 0 
Private nVlrCre   := 0
Private nVlrSal   := 0
Private cVlrSal   := "0"

AADD(aCampos,{"B1_XOK"      ,"C",TamSX3("B1_XOK")[1]    ,0})
AADD(aCampos,{"B1_FILIAL"   ,"C",TamSX3("B1_FILIAL")[1] ,0})
AADD(aCampos,{"B1_COD"      ,"C",TamSX3("B1_COD")[1]    ,0})
AADD(aCampos,{"B1_DESC"     ,"C",TamSX3("B1_DESC")[1]   ,0})
AADD(aCampos,{"B1_TIPO"     ,"C",TamSX3("B1_TIPO")[1]   ,0})
AADD(aCampos,{"B1_UM"       ,"C",TamSX3("B1_UM")[1]     ,0})

cQuery := "SELECT R_E_C_N_O_, * FROM "
cQuery += RetSqlName("SB1") + " SB1 "
cQuery += " WHERE "
cQuery += " B1_FILIAL   Between '" + cFilDe    + "' AND '" + cFilAte  + "' " 
cQuery += " AND B1_COD   Between '" + cProdDe    + "' AND '" + cProdAt  + "' " 
cQuery += " AND B1_DATREF   >= '" + Dtos(dDtDe)  + "' AND B1_DATREF <= '" + Dtos(dDtAte) + "' " 
cQuery += " AND D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

If _oConMan <> Nil
	_oConMan:Delete() 
	_oConMan := Nil
EndIf

// Criando o objeto do arquivo temporário
_oConMan := FwTemporaryTable():New("cArqTrb")

// Criando a estrutura do objeto  
_oConMan:SetFields(aCampos)

// Criando o indice da tabela
_oConMan:AddIndex("1",{"B1_COD"})

_oConMan:Create()

(cAliAux)->(dbGoTop())

Do While (cAliAux)->(!Eof())
	
	RecLock("cArqTrb",.T.)
	
	AADD(aCampos,{"B1_XOK"      ,"C",TamSX3("B1_XOK")[1]   ,0})
	AADD(aCampos,{"B1_FILIAL"   ,"C",TamSX3("B1_FILIAL")[1],0})
	AADD(aCampos,{"B1_COD"      ,"C",TamSX3("B1_COD"  )[1] ,0})
	AADD(aCampos,{"B1_DESC"     ,"C",TamSX3("B1_DESC"  )[1],0})
	AADD(aCampos,{"B1_TIPO"     ,"C",TamSX3("B1_TIPO")[1]  ,0})
	AADD(aCampos,{"B1_UM"       ,"C",TamSX3("B1_UM"   )[1] ,0})
	
	cArqTrb->B1_XOK      := (cAliAux)->B1_XOK
	cArqTrb->B1_FILIAL   := (cAliAux)->B1_FILIAL
	cArqTrb->B1_COD      := (cAliAux)->B1_COD
	cArqTrb->B1_DESC     := (cAliAux)->B1_DESC
	cArqTrb->B1_TIPO     := (cAliAux)->B1_TIPO
	cArqTrb->B1_UM       := (cAliAux)->B1_UM

	MsUnLock()
	
	(cAliAux)->(DbSkip())
		
EndDo

DbGoTop() 

aCpoBro     := {{ "B1_XOK"      ,, "Marcacao"          ,"@!"},;                
               {  "B1_FILIAL"   ,, "Filial"            ,PesqPict("SB1","B1_FILIAL")},;              
               {  "B1_COD"      ,, "Código Produto"    ,PesqPict("SB1","B1_COD")},; 
               {  "B1_DESC"     ,, "Descrição"         ,PesqPict("SB1","B1_DESC")},;              
               {  "B1_TIPO"     ,, "Tipo"              ,PesqPict("SB1","B1_TIPO")},;
               {  "B1_UM"       ,, "UM"                ,PesqPict("SB1","B1_UM")}}
               
aSize := MSADVSIZE()

DEFINE MSDIALOG oDlg TITLE "*** Montagem de Kit Avacy Distribuidora ***" From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL 

oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,35,35,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_TOP

@0.70,01 	Say "Produto:" Of oPanel // "Valor Total Bens Fiscais :"
@0.70,10 	Say oConta 	VAR cConta 	Picture cPictCta Of oPanel

@25,10 CHECKBOX oChk VAR lCheck PROMPT "Selecionar Todos" SIZE 60,007 PIXEL OF oPanel ON CLICK XConInv(lCheck, cConDe) 

@0.70,20	Say "Descrição:" Of oPanel 
@0.70,25 	Say oTotDeb VAR nTotDeb Picture cPictVlr Of oPanel

@1.4,20 	Say "Cor:" Of oPanel 
@1.4,25 	Say oTotCre VAR nTotCre Picture cPictVlr Of oPanel

@2.10,20 	Say "Valor Unitário:" Of oPanel 
@2.10,25 	Say oTotSal VAR nTotSal Picture cPictVlr Of oPanel

@0.70,40 	Say "Valor Grade:" Of oPanel 
@0.70,45 	Say oVlrDeb VAR nVlrDeb Picture cPictVlr Of oPanel

@15,500 button "Gerar Kit" size 45,11 pixel of oPanel action XGrvVin()

@15,550 button "Sair" size 45,11 pixel of oPanel action oDlg:End()

aCores := {} 

oMark := MsSelect():New("cArqTrb","B1_XOK","",aCpoBro,,@cMark,{40,oDlg:nLeft+1,oDlg:nBottom-335,oDlg:nRight-660},,,,,aCores) 
oMark:bMark := {| | Disp(cMark)} 

ACTIVATE MSDIALOG oDlg CENTERED

If _oConMan <> Nil
	_oConMan:Delete() 
	_oConMan := Nil
EndIf
 

Return 

//Funcao executada ao Marcar/Desmarcar um registro.    

Static Function Disp(cMark) 

Local cMarca := cMark

RecLock("cArqTrb",.F.) 

If Marked("CT2_XOK")    

	cArqTrb->CT2_XOK := cMarca  
	
	If Alltrim(cArqTrb->CT2_DEBITO) == cConta 
		nVlrDeb += cArqTrb->CT2_VALOR
	EndIf
	If Alltrim(cArqTrb->CT2_CREDIT) == cConta 
		nVlrCre += cArqTrb->CT2_VALOR
	EndIf
	nCont += 1
Else 

	cArqTrb->CT2_XOK := "" 
	
	If Alltrim(cArqTrb->CT2_DEBITO) == cConta 
		nVlrDeb -= cArqTrb->CT2_VALOR
	EndIf
	If Alltrim(cArqTrb->CT2_CREDIT) == cConta 
		nVlrCre -= cArqTrb->CT2_VALOR
	EndIf
	
	nCont -= 1

EndIf

MSUNLOCK() 


nVlrSal := (nVlrDeb - nVlrCre)

If nVlrSal < 0
	nVlrSal := ABS(nVlrSal)
	cVlrSal := STR(nVlrSal) + " C"
ElseIf nVlrSal > 0
	cVlrSal := STR(nVlrSal) + " D" 
ElseIf nVlrSal == 0
	cVlrSal := STR(nVlrSal)
EndIf

oVlrCre:Refresh()
oVlrDeb:Refresh()
oVlrSal:Refresh()

oMark:oBrowse:Refresh() 

Return 


Static Function XGrvVin() 

MsAguarde( { || XGrvCon() },,"Verificando os números de IDs para não repeti-los!")

Return

Static Function XGrvCon()

Local cIdDeb   := ""
Local cIdCre   := ""
Local nIdDeb   := 0
Local nIdCre   := 0
Local cStatus  := ""
Local lVinc    := .F.
Local cIdAux   := ""

If lCarga
	cIdDeb   := XIdDeb()
	cIdCre   := XIdCre()
EndIf

If lCarga
	If cIdDeb > cIdCre
		cIdLanc := cIdDeb
	Else
		cIdLanc := cIdCre
	EndIf
	lCarga   := .F.
EndIf

If !Empty(cUltId)
	cIdAux  := cIdLanc
	cIdLanc := Soma1(cUltId)
Else
	cIdAux  := cIdLanc
	cIdLanc := __cUserID + Soma1(cIdLanc)
EndIf
    
DbSelectArea("cArqTrb") 
DbGotop()

BEGIN TRANSACTION

Do While ("cArqTrb")->(!Eof()) //.And. nCont >0
	
	
	If !Empty(cArqTrb->CT2_XOK) 
		If nVlrSal == 0 
			nRecno := cArqTrb->CT2_RECNO
			
			CT2->(DbGoto(nRecno))
			
			If Empty(CT2->CT2_XFLCRE) .And. !Empty(CT2->CT2_XFLDEB)
				MsgInfo("Esse registro já possui conciliação a Debito! O ID não será modificado: " + CT2_XIDDEB ,"ID Debito!")
			EndIf
			
			If Empty(CT2->CT2_XFLDEB) .And. !Empty(CT2->CT2_XFLCRE)
				MsgInfo("Esse registro já possui conciliação a Crédito! O ID não será modificado: " + CT2_XIDCRE,"ID Crédito!")
			EndIf
			
			
			If Empty(CT2->CT2_XFLCRE) .And. Alltrim(CT2_CREDIT) == Alltrim(cConta) 
				
				RecLock("CT2",.F.)
				
				CT2->CT2_XIDCRE   := cIdLanc //ID sequencial da conciliação contábil – vinculo de lançamentos a crédito
				CT2->CT2_XTPCRE   := "M" //Identifica se o lançamento foi conciliado de forma automática (A) ou manual (M).
				CT2->CT2_XFLCRE   := cArqTrb->CT2_CREDIT //Flag de conciliação contábil, identifica se o registro já foi conciliado.
				CT2->CT2_XAUXCR   := RIGHT(cIdLanc, 20)
				
				cUltId := cIdLanc
				lVinc := .T.
				
				If Empty(CT2->CT2_XOK)
					CT2->CT2_XOK   := cMark
				EndIf
				
				If Empty(CT2->CT2_XSTAT)
					cStatus  := "1"
					CT2->CT2_XSTAT    := "1"
				EndIf
				
				MsUnLock()
				
				RecLock("cArqTrb",.F.)
				
				cArqTrb->CT2_XIDCRE := cIdLanc
				cArqTrb->CT2_XTPCRE := 'M'
				
				MsUnLock()
				
			EndIf
					
			If Empty(CT2->CT2_XFLDEB) .And. Alltrim(CT2_DEBITO) == Alltrim(cConta)
			
				RecLock("CT2",.F.)
				
				CT2->CT2_XIDDEB   := cIdLanc//ID sequencial da conciliação contábil – vinculo de lançamentos a débito
				CT2->CT2_XTPDEB   := "M" //Identifica se o lançamento foi conciliado de forma automática (A) ou manual (M).
				CT2->CT2_XFLDEB   := cArqTrb->CT2_DEBITO //Flag de conciliação contábil, identifica se o registro já foi conciliado.
				CT2->CT2_XAUXDE   := RIGHT(cIdLanc, 20)
				
				lVinc  := .T.
				cUltId := cIdLanc
				
				If Empty(CT2->CT2_XOK)
					CT2->CT2_XOK   := cMark
				EndIf
				
				If Empty(CT2->CT2_XSTAT)
					cStatus          := "1"
					CT2->CT2_XSTAT   := "1"
				EndIf
				
				MsUnLock()
				
				RecLock("cArqTrb",.F.)
				
				cArqTrb->CT2_XIDDEB := cIdLanc
				cArqTrb->CT2_XTPDEB := 'M'
				
				MsUnLock()
				
			EndIf
					
			If ( !Empty(CT2->CT2_XFLCRE) .And. !Empty(CT2->CT2_XFLDEB) )
				RecLock("CT2",.F.)
				
				CT2->CT2_XCTBFL   := "S"
				CT2->CT2_XSTAT    := "2"
				cStatus           := "2"
				
				MsUnLock()
			EndIf
			
			nCont -= 1

		Else
			MsgAlert( "O saldo não está zerado para conciliar!", "Saldo" )
			cIdLanc := cIdAux
			Exit
		EndIf
	EndIf
	
	If lVinc .And. !Empty(cArqTrb->CT2_XOK)
		RecLock("cArqTrb",.F.)
			cArqTrb->CT2_XSTAT  := cStatus
			cArqTrb->CT2_XOK    := ""
		MsUnLock()
	Else	
		//cArqTrb->CT2_XOK   := ""
	EndIf
	If lVinc
		nVlrDeb := 0 
		nVlrCre := 0
		nVlrSal := 0
	EndIf

	("cArqTrb")->(DbSkip())
		
EndDo

END TRANSACTION

DbSelectArea("cArqTrb") 
DbGotop()


oVlrCre:Refresh()
oVlrDeb:Refresh()
oVlrSal:Refresh()

oMark:oBrowse:Refresh() 

Return


Static Function XDesVin() 
	MsAguarde( { || XDesCon() },,"Verificando os números de IDs para não repeti-los!")
Return

Static Function XDesCon()

Local lVinc := .F.

DbSelectArea("cArqTrb") 
DbGotop()

BEGIN TRANSACTION

Do While ("cArqTrb")->(!Eof()) //.And. nCont >0
	
	If !Empty(cArqTrb->CT2_XOK) //.And. (!Empty(CT2->CT2_XFLCRE) .Or. !Empty(CT2->CT2_XFLDEB))
	
		If nVlrSal == 0 
	
			nRecno := cArqTrb->CT2_RECNO
			
			CT2->(DbGoto(nRecno))
			
			RecLock("CT2",.F.)
			
			lVinc := .T.
			
			CT2->CT2_XIDCRE := '' 
			CT2->CT2_XIDDEB := '' 
			CT2->CT2_XFLCRE := '' 
			CT2->CT2_XFLDEB := '' 
			CT2->CT2_XTPCRE := ''
			CT2->CT2_XTPDEB := ''
			CT2->CT2_XCTBFL := ''
			CT2->CT2_XSTAT  := ''
			CT2->CT2_XAUXCR := ''
			CT2->CT2_XAUXDE := ''
			CT2->CT2_XOK    := ''
			cStatus         := ""
			nCont -= 1
			MsUnLock()
		Else
			MsgAlert( "O saldo não está zerado para desconciliar!", "Saldo" )
			Exit
		EndIf
	ElseIf !Empty(cArqTrb->CT2_XOK)
		MsgInfo("Foi selecionado um registro não conciliado: " + cArqTrb->CT2_DOC,"Não Conciliado")
		Exit
	EndIf
	
	If lVinc .And. cArqTrb->CT2_XOK != " "
		RecLock("cArqTrb",.F.)
			cArqTrb->CT2_XSTAT    := ""
			cArqTrb->CT2_XOK      := ""
			cArqTrb->CT2_XIDCRE   := ""
			cArqTrb->CT2_XIDDEB   := ""
			cArqTrb->CT2_XTPCRE   := ""
			cArqTrb->CT2_XTPDEB   := ""
		MsUnLock()
	EndIf
	
	If lVinc
		nVlrDeb := 0 
		nVlrCre := 0
		nVlrSal := 0
	EndIf

	("cArqTrb")->(DbSkip())
		
EndDo

END TRANSACTION

DbSelectArea("cArqTrb") 
DbGotop()

cIdLanc   := ""
lCarga    := .T.
cUltId    := ""

oVlrCre:Refresh()
oVlrDeb:Refresh()
oVlrSal:Refresh()

oMark:oBrowse:Refresh() 

	
Return


Static Function XConInv(lCheck, cConDe)

Local aArea := GetArea()

dbSelectArea( "cArqTrb" ) 
dbGotop() 

Do While !EoF() 
    If lCheck
		If RecLock( "cArqTrb", .F. ) 
		
			cArqTrb->CT2_XOK  := cMark 
			
			MsUnLock() 
		
		EndIf 
		If !Empty(cArqTrb->CT2_XOK)
			If Alltrim(cArqTrb->CT2_CREDIT) == Alltrim(cConDe)
				nVlrCre += cArqTrb->CT2_VALOR
			EndIf
			If Alltrim(cArqTrb->CT2_DEBITO) == Alltrim(cConDe)
				nVlrDeb += cArqTrb->CT2_VALOR
			EndIf
		EndIf
	Else
		If RecLock( "cArqTrb", .F. ) 
		
			cArqTrb->CT2_XOK  := '' 
			
			MsUnLock() 
		
		EndIf 
		If Empty(cArqTrb->CT2_XOK)
			If Alltrim(cArqTrb->CT2_CREDIT) == Alltrim(cConDe)
				nVlrCre -= cArqTrb->CT2_VALOR
			EndIf
			If Alltrim(cArqTrb->CT2_DEBITO) == Alltrim(cConDe)
				nVlrDeb -= cArqTrb->CT2_VALOR
			EndIf
		EndIf
	
	EndIf
	

	dbSkip() 

EndDo 

nVlrSal := (nVlrDeb - nVlrCre)

If nVlrSal < 0

	nVlrSal  := ABS(nVlrSal)
	cVlrSal  := STR(nVlrSal) + " C"

ElseIf nVlrSal > 0

	cVlrSal  := STR(nVlrSal) + " D" 
	
ElseIf nVlrSal == 0

	cVlrSal := STR(nVlrSal)

EndIf

RestArea(aArea)

oVlrCre:Refresh()
oVlrDeb:Refresh()
oVlrSal:Refresh()

oMark:oBrowse:Refresh() 

Return 


Static Function xMovDeb(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cConci)

Local cQuery  := ""
Local cAliDeb := GetNextAlias()
Local nDebito := 0

cQuery := " SELECT SUM (CT2_VALOR) AS DEBITO FROM  "
cQuery += RetSqlName("CT2") + " CT2 "
cQuery += " WHERE "
cQuery += " CT2_DEBITO = '" + cConDe + "' "
cQuery += " AND CT2_FILIAL   Between '" + cFilDe    + "' AND '" + cFilAte  + "' " 
cQuery += " AND CT2_DATA   >= '" + Dtos(dDtDe)  + "' AND CT2_DATA <= '" + Dtos(dDtAte) + "' " 

If Valtype(cConci) == "N"
	cConci := "Não conciliados"
EndIf

If cConci == "Não conciliados" //Não conciliados
	cQuery += " AND (CT2_XFLDEB = ' ' AND CT2_XFLCRE = ' ') "
EndIf

If cConci == "Conciliados" //Conciliados
	cQuery += " AND (CT2_XFLDEB != ' ' OR CT2_XFLCRE != ' ') "
EndIf

cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliDeb,.T.,.T.)

nDebito := (cAliDeb)->DEBITO

(cAliDeb)->(DbCloseArea())

Return nDebito
 
 
Static Function xMovCre(cFilde, cFilAte, cConDe, dDtDe, dDtAte, cConci)

Local cQuery   := ""
Local cAliCre  := GetNextAlias()
Local nCredito := 0

cQuery := " SELECT SUM (CT2_VALOR) AS CREDITO FROM  "
cQuery += RetSqlName("CT2") + " CT2 "
cQuery += " WHERE "
cQuery += " CT2_CREDIT = '" + cConDe + "' "
cQuery += " AND CT2_FILIAL   Between '" + cFilDe    + "' AND '" + cFilAte  + "' " 
cQuery += " AND CT2_DATA   >= '" + Dtos(dDtDe)  + "' AND CT2_DATA <= '" + Dtos(dDtAte) + "' " 

If Valtype(cConci) == "N"
	cConci := "Não conciliados"
EndIf

If cConci == "Não conciliados" //Não conciliados
	cQuery += " AND (CT2_XFLDEB = ' ' AND CT2_XFLCRE = ' ') "
EndIf

If cConci == "Conciliados" //Conciliados
	cQuery += " AND (CT2_XFLDEB != ' ' OR CT2_XFLCRE != ' ') "
EndIf

cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliCre,.T.,.T.)

nCredito := (cAliCre)->CREDITO

(cAliCre)->(DbCloseArea())

Return nCredito


Static Function XIdDeb()

Local cIdDeb    := ""
Local cQuery    := ""
Local cAliAux   := GetNextAlias()

cQuery := "SELECT MAX(CT2_XAUXDE) AS IDDEB FROM"
cQuery += RetSqlName("CT2") + " CT2 "
cQuery += " WHERE "
cQuery += " D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

cIdDeb := (cAliAux)->IDDEB

Return cIdDeb


Static Function XIdCre()

Local cIdCre    := ""
Local cQuery    := ""
Local cAliAux   := GetNextAlias()

cQuery := "SELECT MAX(CT2_XAUXCR) AS IDCRE FROM"
cQuery += RetSqlName("CT2") + " CT2 "
cQuery += " WHERE "
cQuery += " D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

cIdCre := (cAliAux)->IDCRE

Return cIdCre