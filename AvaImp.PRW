#INCLUDE "FileIO.CH"
#INCLUDE "PROTHEUS.CH"   
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH

//--------------------------------------------------
/*/{Protheus.doc} AvaImp
Importação de Planilha de Produtos Avacy

@author André Brito
@since 29/11/2019
@version P12.1.17
 
@return 
/*/
//--------------------------------------------------

User Function AvaImp()

	Local aRet			:= {}
	Local aAreaCT1		:= CT1->(GetArea())
	Local aAreaCVD		:= CVD->(GetArea())
	Local aCfg			:= {}
	Local cCampos		:= ""
	Local lContinua		:= .T.
	Local oModCT1Imp	:= Nil

	Private oProcess   

	SaveInter()

	oModCT1Imp	:= FWLoadModel("CTBA020")

	aCfg := { { "SB1", cCampos, {|| FWMVCRotAuto(oModCT1Imp, "SB1", 3, { {"SB1MASTER",xAutoCab} }, , .T.) } }, {"SB5",,} }

	If ParamBox({	{6,"Selecione Arquivo",PadR("",150),"",,"", 90 ,.T.,"Importação Produtos","",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},;
					"Importar Estrutura de Produtos",@aRet) 

		oProcess:= MsNewProcess():New( {|lEnd| AvaImpCSV( lEnd, oProcess, aRet[1], aCfg )} )
		oProcess:Activate()

	EndIf

	oModCT1Imp:Destroy()
	oModCT1Imp := Nil

	RestInter()

RestArea(aAreaCVD)
RestArea(aAreaCT1)

Return Nil

RestInter()

Return .T.


//--------------------------------------------------
/*/{Protheus.doc} AvaImpCSV
Importa registros da planilha para a tabela SB1

@author André Brito
@since 02/12/2019
@version P12.1.17
 
@return 
/*/
//--------------------------------------------------

Static Function AvaImpCSV(lEnd, oProcess, cArq, aCfg , lProc)

Local cLinha      := ""
Local lPrim       := .T.
Local aCampos     := {}
Local aDados      := {}
Local aProds      := {}
Local i           := 0
Local x           := 0
Local lMsErroAuto := .F.
Local nAtual      := 0
Local nTotal      := 0
Local nTot2       := 0
Local nNumProd    := 0
Local aCab        := {}
Local oModel      := Nil
Local aArea       := GetArea()
Local aAreaSb1    := GetArea()
Local lRet        := .T.
Local cCofins     := ""
Local cPis        := ""
Local aProdutos   := {}
Local nInclu      := 0

Private aErro := {}
 
If !File(cArq)
	MsgStop("O arquivo "  + cArq + " não foi encontrado. A importação será abortada!","ATENCAO")
	Return
EndIf
 
FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()

nTot2 := FT_FLASTREC()
oProcess:SetRegua1(nTot2)

While !FT_FEOF()
	

	oProcess:IncRegua1("Totais de produtos lidos: " + cValToChar(nNumProd))

	nNumProd := nNumProd + 1

	cLinha := FT_FREADLN()
 
	If lPrim
		aCampos := Separa(cLinha,";",.T.)
		lPrim := .F.
	Else
		If cLinha $ ";;;;;;;;;;;;;;;;;"
			Exit
		EndIf
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf
 
	FT_FSKIP()
EndDo

nTotal := Len(aDados)

Count To nTotal
oProcess:SetRegua2(nTotal)


For i := 1 to Len(aDados)


	oProcess:IncRegua2("Incluindo o produto: " + aDados[i][1])
	
	oModel := FWLoadModel("MATA010")
	oModel:SetOperation(3)
	oModel:Activate()
	
	cCofins := StrTran( aDados[i][10], ",", "." )
	cPis    := StrTran( aDados[i][11], ",", "." )
	
	//Pegando o model e setando os campos
	oSB1Mod := oModel:GetModel("SB1MASTER")
	oSB1Mod:SetValue(aCampos[1]    , aDados[i][1]      ) 
	oSB1Mod:SetValue(aCampos[2]    , aDados[i][2]      ) 
	oSB1Mod:SetValue(aCampos[3]    , aDados[i][3]      ) 
	oSB1Mod:SetValue(aCampos[4]    , aDados[i][4]      ) 
	oSB1Mod:SetValue(aCampos[5]    , aDados[i][5]      ) 
	oSB1Mod:SetValue(aCampos[6]    , aDados[i][6]      )
	oSB1Mod:SetValue(aCampos[7]    , aDados[i][7]      ) 
	oSB1Mod:SetValue(aCampos[8]    , aDados[i][8]      ) 
	oSB1Mod:SetValue(aCampos[9]    , aDados[i][9]      ) 
	oSB1Mod:SetValue(aCampos[10]   , Val(cCofins)      ) 
	oSB1Mod:SetValue(aCampos[11]   , Val(cPis)         )
	oSB1Mod:SetValue(aCampos[12]   , aDados[i][12]     )
	oSB1Mod:SetValue(aCampos[13]   , aDados[i][13]     ) 
	oSB1Mod:SetValue(aCampos[14]   , aDados[i][14]     )    
	//Setando o complemento do produto
	oSB5Mod := oModel:GetModel("SB5DETAIL")
	If oSB5Mod != Nil
	    oSB5Mod:SetValue(aCampos[15]  , aDados[i][15]   )
	    oSB5Mod:SetValue(aCampos[16]  , Alltrim(aDados[i][16])   )
	    oSB5Mod:SetValue(aCampos[17]  , Val(aDados[i][17])   )
	    oSB5Mod:SetValue(aCampos[18]  , aDados[i][18]   )
	EndIf
	  
	//Se conseguir validar as informações
	If oModel:VldData()
	       
	    //Tenta realizar o Commit
	    If oModel:CommitData()
	    	
	    	nInclu ++
	        lOk := .T.
	           
	    //Se não deu certo, altera a variável para false
	    Else
	        lOk := .F.
	    EndIf
	       
	//Se não conseguir validar as informações, altera a variável para false
	Else
		lRet := .F.
	    lOk  := .F.
	    //ApMsgInfo("Erro ao incluir o produto " + Alltrim(aDados[i][2]),"ERRO")
	    AADD(aProdutos, { Alltrim(aDados[i][1]),Alltrim(aDados[i][2]) })
	EndIf
	
	oModel:DeActivate()
	
	oModel:Destroy()
	
	oModel  := Nil

Next

U_AvcMsg(Len(aDados), nInclu, aProdutos)
 
FT_FUSE()

If lRet
	ApMsgInfo("Importação dos Produtos concluída com sucesso!","SUCESSO")
Else
	ApMsgInfo("Aconteceram erros na sua importação, verifique!","Conferência")
EndIf

RestArea(aArea)

Return


User Function AvcMsg(nDados, nInclu, aProdutos)

	Local lRetMens             := .F.
	Local oDlgMens
	Local oBtnOk, cTxtConf     := ""
	Local oBtnCnc, cTxtCancel  := ""
	Local oBtnSlv
	Local oFntTxt              := TFont():New("Verdana",,-011,,.F.,,,,,.F.,.F.)
	Local oMsg
	Local nIni                 := 1
	Local nFim                 := 50
	Local cMsg                 := ""
	Local cTitulo              := "Produtos importados"
	Local cQuebra              := CRLF + CRLF
	Local nTipo                := 1 // 1=Ok; 2= Confirmar e Cancelar
	Local lEdit                := .F.
    Local nX                   := 0

    cMsg  := "Total de produtos processados: " + Alltrim(Str(nDados)) + CRLF
    cMsg  += "Total de produtos inclusos: " + Alltrim(Str(nInclu))
    
	cTexto := "Função   - " + FunName()       + CRLF
	cTexto += "Usuário  - " + cUserName       + CRLF
	cTexto += "Data     - " + dToC(dDataBase) + CRLF
	cTexto += "Hora     - " + Time()          + CRLF
	cTexto += "Mensagem - " + cTitulo + cQuebra  + cMsg + " " + cQuebra
	cTexto += CRLF

	If nInclu != nDados
		cTexto += "Registros não inclusos:" + CRLF + CRLF
	EndIf

	For nX := 1 To Len(aProdutos)
		cTexto += "Código Produto: " + Alltrim(aProdutos[nX][1]) + CRLF
		cTexto += "Descrição Pedido: " + Alltrim(aProdutos[nX][2]) + CRLF
	Next
    
    //Definindo os textos dos botões
	If(nTipo == 1)
		cTxtConf:='Ok'
	Else
		cTxtConf:='Confirmar'
		cTxtCancel:='Cancelar'
	EndIf
 
    //Criando a janela centralizada com os botões
	DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL
        //Get com o Log
	@ 002, 004 GET oMsg VAR cTexto OF oDlgMens MULTILINE SIZE 191, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
	If !lEdit
		oMsg:lReadOnly := .T.
	EndIf
         
        //Se for Tipo 1, cria somente o botão OK
	If (nTipo==1)
		@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
         
        //Senão, cria os botões OK e Cancelar
	ElseIf(nTipo==2)
		@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
		@ 137, 144 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
	EndIf
         
        //Botão de Salvar em Txt
	@ 127, 004 BUTTON oBtnSlv PROMPT "&Salvar em .txt" SIZE 051, 019 ACTION (SalvaArq(cMsg, cTitulo, Alltrim(Str(nDados)),cTexto)) OF oDlgMens PIXEL
	ACTIVATE MSDIALOG oDlgMens CENTERED
 
Return lRetMens

//--------------------------------------------------
 
Static Function SalvaArq(cMsg, cTitulo, cQtdDados, cTxt)

	Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
	Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
	Local lOk      := .T.
	Local cTexto   := ""
     
    //Pegando o caminho do arquivo
	cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)
 
    //Se o nome não estiver em branco    
	If !Empty(cFileNom)
        //Teste de existência do diretório
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
			Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		EndIf

		cTexto := cTxt
         
        //Testando se o arquivo já existe
		If File(cFileNom)
			lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
		EndIf
         
		If lOk
			MemoWrite(cFileNom, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
		EndIf
	EndIf
Return
