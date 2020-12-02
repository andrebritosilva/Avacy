#Include "Protheus.ch"

Static axCopy := {}

User Function xGerProds()
	
	Local aArea     := GetArea()
	Local aAreaPara := GetArea()
	Local aPWiz     := {}
	Local aRetWiz   := {}
	Local lContinua := .F.
	Local lProd     := .T.
	Local cCodGrd   := ""
	Local cQtd      := ""
	Local cPreco    := 0
	Local nQtd      := 0 
	Local nPreco    := 0
	Local nLinha    := 0
	Local nCont     := 0
	Local nPreco    := 0
	
	If cPaisLoc != "BRA"
		aTam[2] := MsDecimais(nMoedaPed)
	EndIf

	aAdd(aPWiz,{ 1,"Selecione a grade: "   ,Space(14) ,"","","Z01P","", ,.T.})
	aAdd(aPWiz,{ 1,"Quantidade: "          ,Space(3)  ,"","","","", ,.T.})
	aAdd(aPWiz,{ 1,"Preço: "               ,Space(14) ,"","","","", ,.T.})

	aAdd(aRetWiz,Space(14))
	aAdd(aRetWiz,Space(6))
	aAdd(aRetWiz,Space(6))

	lContinua := ParamBox(aPWiz,"Inclusão Grade",aRetWiz,,,,,,) 

	RestArea(aAreaPara)

	If !lContinua 
		Return
	EndIf

	cCodGrd   := Alltrim(aRetWiz[1])
	cQtd      := Alltrim(aRetWiz[2])
	cPreco    := Alltrim(aRetWiz[3])
	nPreco    := Val(cPreco)
	nQtd      := Val(cQtd)

	lProd := U_xVldGrade(cCodGrd)
	
	If nQtd <= 0
		MsgInfo("O campo quantidade deve ser maior que zero!","Quantidade inválida!")
		Return
	EndIf

	If !lProd
		MsgInfo("Grade inexistente, informe o código corretamente!","Grade não existe")
		Return
	EndIf

	RptStatus({|| xDigiAvacy(cCodGrd,cQtd,cPreco,nPreco,nQtd,lContinua)}, "Aguarde...", "Estou digitando seus produtos...")

Return

Static Function xDigiAvacy(cCodGrd,cQtd,cPreco,nPreco,nQtd,lContinua)
	
	Local aArea	      := GetArea()
	Local aAreaPara   := GetArea()
	Local cArqTrb     := GetNextAlias()
	Local cQuery      := ""
	Local aRefImpos   := MaFisRelImp('MT100',{"SC7"})
	Local aRefImpSC7  := MaFisRelImp('MT100',{"SC7"})
	Local lTrbGen     := IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SC7","C7_IDTRIB"), .F.)
	Local nPosTotal   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_TOTAL"})
	Local nPosDescri  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_DESCRI"})
	Local nPosProd    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
	Local nPosVDesc   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_VLDESC"})
	Local nPosQtd     := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_QUANT"})
	Local nPosPrc     := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"})
	Local nPosItem    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEM"})
	Local nPosDini    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_DINICOM"})
	Local nPosDinTra  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_DINITRA"})
	Local nPosDtPrf   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_DATPRF"})
	Local nPosDinCq   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_DINICQ"})
	Local nPosArm     := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_LOCAL"})
	Local nPosFluxo   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_FLUXO"})
	Local nQuantidade := 0
	Local aTam        := TamSX3("C7_TOTAL")
	Local aAux        := aClone(aCols)
	Local nAcols      := 0
	Local nAtual      := 0
    Local nTotal      := 0
	Local nX          := 0

	If lContinua
	
		cQuery := "SELECT R_E_C_N_O_, * FROM "
		cQuery += RetSqlName("Z02") + " Z02 "
		cQuery += " WHERE "
		cQuery += " Z02_CODGRD = '" + cCodGrd + "' " 
		cQuery += " AND D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery) 
		 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqTrb,.T.,.T.)

		Count To nTotal
    	SetRegua(nTotal)
		
		(cArqTrb)->(dbGoTop())
		
		nAcols := Len(aCols)

		If nAcols == 1
			axCopy := aCols
			aCols := {}
		EndIf

		Do While (cArqTrb)->(!Eof())
		
			nAtual++
       		IncRegua()

			MaFisIni(ca120Forn,ca120Loj,"F","N",Nil,aRefImpSC7,,.T.,,,,,,,,,,,,,,,,,,,,,,,,,lTrbGen)

			nLinha := Len(aCols) + 1

			Aadd(aCols,Array(Len(aHeader)+1))

			For nx := 1 To Len(aHeader)
				aCols[nLinha][nX] := axCopy[1][nx]
			Next

			nQuantidade := nQtd * Val((cArqTrb)->Z02_QTD)

			aCols[nLinha][nPosProd]    := (cArqTrb)->Z02_COD
			aCols[nLinha][nPosDescri]  := BuscaDes((cArqTrb)->Z02_COD)
			aCols[nLinha][nPosItem]    := StrZero( nLinha, 4 )
			aCols[nLinha][nPosQtd]     := nQuantidade
			aCols[nLinha][nPosPrc]     := NoRound(nPreco,aTam[2])
			aCols[nLinha][nPosTotal]   := NoRound(nPreco * nQuantidade, aTam[2])
			aCols[nLinha][nPosDini]    := MonthSum( dDataBase , 1 )
			aCols[nLinha][nPosDinTra]  := MonthSum( dDataBase , 1 )
			aCols[nLinha][nPosDtPrf]   := MonthSum( dDataBase , 1 )
			aCols[nLinha][nPosDinCq]   := MonthSum( dDataBase , 1 )
			aCols[nLinha][nPosArm]     := "01"
			aCols[nLinha][nPosFluxo]   := "S"

			aValores[6] +=  NoRound(nPreco * (nQuantidade * Val((cArqTrb)->Z02_QTD)), aTam[2])
			aValores[1] +=  NoRound(nPreco * (nQuantidade * Val((cArqTrb)->Z02_QTD)), aTam[2])

			MaFisAlt("NF_TOTAL",aValores[6],nLinha)
			MaColsToFis(aHeader,aCols)		
			
			A120LinOk()

			(cArqTrb)->(DbSkip())

		EndDo
		
	Else
		Return
	EndIf
	
	U_xGerProds()

	Eval(bTgRefresh)
	Eval(bGDRefresh)
	RestArea(aArea)

Return .T.

User Function xVldGrade(cCodGrd)

Local aArea      := GetArea()
Local lRet       := .T.

cCodGrd  := Alltrim(cCodGrd)

DbSelectArea("Z01")
Z01->(DbSetOrder(1))

If !DbSeek( xFilial("Z01") + cCodGrd )
	//MsgInfo("Código de grade inexistente","Código de grade")
	lRet := .F.
EndIf

RestArea( aArea )

Return lRet

Static Function BuscaDes( cCod )

Local aArea     := GetArea() 
Local cDescri   := ""

DbSelectArea("SB1")
DbSeek(xFilial("SB1") + cCod)
cDescri := Alltrim(SB1->B1_DESC)

RestArea( aArea )

Return cDescri

Static Function BuscaPre( cCod )

Local aArea       := GetArea() 
Local nPreco      := ""
Local nQuantidade := 0

DbSelectArea("SB1")
DbSeek(xFilial("SB1") + cCod)
nPreco := SB1->B1_PRV1

RestArea( aArea )

Return nPreco