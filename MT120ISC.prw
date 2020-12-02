#Include "Protheus.ch"

User Function MT120AVA()

	Local aPWiz     := {}
	Local aRetWiz   := {}
	Local cArqTrb   := GetNextAlias()
	Local cQuery    := ""
	Local lContinua := .F.
	Local lProd     := .T.
	Local cCodGrd   := ""
	Local cQtd      := ""
	Local cPreco    := 0
	Local nQtd      := 0 
	Local nPreco    := 0
	Local n         := 0
	Local nCont     := 0
	Local nPreco    := 0
	
	aAdd(aPWiz,{ 1,"Selecione a grade: "   ,Space(14) ,"","","Z01P","", ,.T.})
	aAdd(aPWiz,{ 1,"Quantidade: "          ,Space(3)  ,"","","","", ,.T.})
	aAdd(aPWiz,{ 1,"Preço: "               ,Space(14) ,"","","","", ,.T.})

	aAdd(aRetWiz,Space(14))
	aAdd(aRetWiz,Space(6))
	aAdd(aRetWiz,Space(6))

	lContinua := ParamBox(aPWiz,"Inclusão Grade",@aRetWiz,,,,,,) 

	cCodGrd   := Alltrim(aRetWiz[1])
	cQtd      := Alltrim(aRetWiz[2])
	cPreco    := Alltrim(aRetWiz[3])
	nPreco    := Val(cPreco)
	nQtd      := Val(cQtd)

	lProd := U_xVdGrade(cCodGrd)
	
	If nQtd <= 0
		MsgInfo("O campo quantidade deve ser maior que zero!","Quantidade inválida!")
		Return
	EndIf

	If !lProd
		MsgInfo("Grade inexistente, informe o código corretamente!","Grade não existe")
		Return
	EndIf
	
	If lContinua
	
		cQuery := "SELECT R_E_C_N_O_, * FROM "
		cQuery += RetSqlName("Z02") + " Z02 "
		cQuery += " WHERE "
		cQuery += " Z02_CODGRD = '" + cCodGrd + "' " 
		cQuery += " AND D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery) 
		 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqTrb,.T.,.T.)
		
		(cArqTrb)->(dbGoTop())
		
		Do While (cArqTrb)->(!Eof())
			
			n += 1 
			
			//nPreco := BuscaPre((cArqTrb)->Z02_COD)

			If n = 1
				aCols[n][2]                         := (cArqTrb)->Z02_COD
				aCols[n][gdFieldPos("C7_DESCRI")]   := BuscaDes((cArqTrb)->Z02_COD)
				aCols[n][gdFieldPos("C7_ITEM")]     := StrZero( n, 4 )
				aCols[n][gdFieldPos("C7_QUANT")]    := Val((cArqTrb)->Z02_QTD)
				aCols[n][gdFieldPos("C7_PRECO")]    := nPreco
				A120Preco(nPreco) 
				MaFisRef("IT_PRCUNI","MT120",nPreco)
				MTA121TROP(n)
				aCols[n][gdFieldPos("C7_LOCAL")]    := "01"
				//aCols[n][gdFieldPos("C7_TOTAL")]    := nPreco * Val((cArqTrb)->Z02_QTD) 
			Else
				Aadd(aCols,Array(Len(aHeader)+1))

				For nCont := 1 To Len(aHeader) + 1

					aCols [n][nCont] := aCols[1][nCont] 

				Next	

				aCols[n][2]                         := (cArqTrb)->Z02_COD
				aCols[n][gdFieldPos("C7_DESCRI")]   := BuscaDes((cArqTrb)->Z02_COD)
				aCols[n][gdFieldPos("C7_ITEM")]     := StrZero( n, 4 )
				aCols[n][gdFieldPos("C7_QUANT")]    := Val((cArqTrb)->Z02_QTD)
				aCols[n][gdFieldPos("C7_PRECO")]    := nPreco
				A120Preco(nPreco) 
				MaFisRef("IT_PRCUNI","MT120",nPreco)
				MTA121TROP(n)
				aCols[n][gdFieldPos("C7_LOCAL")]    := "01"
				//aCols[n][gdFieldPos("C7_TOTAL")]    := nPreco * Val((cArqTrb)->Z02_QTD)


			EndIf

			(cArqTrb)->(DbSkip())
			
		EndDo
		
	Else
		Return
	EndIf

Return (Nil)

User Function xVdGrade(cCodGrd)

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