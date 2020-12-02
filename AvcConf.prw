#Include 'Protheus.ch'

User Function AvcConf()

Local lStatus := SL1->L1_SITUA <> "OK" .AND. Empty(SL1->L1_RESERVA) .AND. dDataBase <=SL1->L1_DTLIM

If !lStatus
	MsgInfo( "Pedido já concluido", "Pedido" )
Else
	Janela()
EndIf

Return 

Static Function Janela()

Local oDlg
Local oBtn1,oBtn2,oSay1
 
DEFINE DIALOG oDlg TITLE "Conferência Automática" FROM 0,0 TO 150,250 COLOR CLR_BLACK,CLR_WHITE PIXEL
@ 25,10 SAY oSay1 PROMPT "Escolha uma ação na conferência de lote:" SIZE 120,24 OF oDlg PIXEL 
 
@ 50,10 BUTTON oBtn1 PROMPT 'Limpar Conf.'  ACTION ( AvcLimp() ) SIZE 50, 015 OF oDlg PIXEL
@ 50,65 BUTTON oBtn2 PROMPT 'Conferir Lote' ACTION ( AvcCfl() ) SIZE 50, 015 OF oDlg PIXEL

ACTIVATE DIALOG oDlg CENTER

Return

Static Function AvcLimp()

Local cAliSql := GetNextAlias()
Local cSql    := ""
Local aArea   := GetArea() 
Local cCod    := SL1->L1_NUM

If MSGYESNO( "Deseja realmente limpar a conferência já efetuada?", "Conferência" )

	cSql := "SELECT R_E_C_N_O_, * FROM "
	cSql += RetSqlName("SL2") + " SL2 "
	cSql += " WHERE "
	cSql += " L2_NUM = '" + cCod + "' " 
	cSql += " AND D_E_L_E_T_ = ' ' "
	
	cSql := ChangeQuery(cSql) 
	 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliSql,.T.,.T.)
	
	(cAliSql)->(dbGotop())
	
	Do While !(cAliSql)->(Eof())
		
		SL2->(dbGoto((cAliSql)->R_E_C_N_O_))
		
		RecLock("SL2",.F.)
		
			SL2->L2_XQTDC := ""
			SL2->L2_XCONF := ""
			
		MsUnLock()
		
		(cAliSql)->(DbSkip())	
	EndDo
	
	(cAliSql)->(dbCloseArea())	
	
	LimSl1(cCod)
	
EndIf

RestArea( aArea )

Return

Static Function LimSl1(cCod)

Local aArea := GetArea()

DbSelectArea("SL1")
DbSetOrder(1)

If SL1->(dbSeek( xFilial("SL1") + cCod))
	RecLock("SL1",.F.)
		SL1->L1_XCONF := ""
	MsUnLock()
EndIf

RestArea(aArea)

Return

Static Function AvcCfl()

Local cAliSql := GetNextAlias()
Local cSql    := ""
Local aArea   := GetArea() 
Local cCod    := SL1->L1_NUM

If MSGYESNO( "Deseja realmente conferir o pedido em sua totalidade?", "Conferência" )

	cSql := "SELECT R_E_C_N_O_, * FROM "
	cSql += RetSqlName("SL2") + " SL2 "
	cSql += " WHERE "
	cSql += " L2_NUM = '" + cCod + "' " 
	cSql += " AND D_E_L_E_T_ = ' ' "
	
	cSql := ChangeQuery(cSql) 
	 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliSql,.T.,.T.)
	
	(cAliSql)->(dbGotop())
	
	Do While !(cAliSql)->(Eof())
		
		SL2->(dbGoto((cAliSql)->R_E_C_N_O_))
		
		RecLock("SL2",.F.)
		
			SL2->L2_XQTDC := SL2->L2_XQTD
			SL2->L2_XCONF := "S"
			
		MsUnLock()
		
		(cAliSql)->(DbSkip())	
	EndDo
	
	(cAliSql)->(dbCloseArea())	
	
	GrvConf(cCod)
	
EndIf

RestArea( aArea )

Return

Static Function GrvConf(cCod)

Local aArea := GetArea()

DbSelectArea("SL1")
DbSetOrder(1)

If SL1->(dbSeek( xFilial("SL1") + cCod))
	RecLock("SL1",.F.)
		SL1->L1_XCONF := "S"
	MsUnLock()
EndIf

RestArea(aArea)

Return