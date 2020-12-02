#include "fileio.ch"

user function AVCR01()
 
Local cHtml   		:= ""
Local nHandle 		:= 0
Local cFile         := ""//'C:\html\picklist.html'
Local nCaminho      := MakeDir( "C:\html" )
Local xDataBase 	:= DTOC(dDataBase)
Local xHoraBase 	:= Time()
Local xNumPedido 	:= Alltrim(SL1->L1_NUM)
Local xDataHora 	:= DTOC(SL1->L1_EMISSAO) + "  " + Alltrim(SL1->L1_HORA)
Local xNomeCli 		:= xLojaCli(SL1->L1_CLIENTE, SL1->L1_LOJA)
Local xDocIdentif 	:= xInscCli(SL1->L1_CLIENTE, SL1->L1_LOJA)
Local xEndereco 	:= xLojaEnd(SL1->L1_CLIENTE, SL1->L1_LOJA)
Local xNumReg 		:= xLojaDoc(SL1->L1_CLIENTE, SL1->L1_LOJA)
Local xVendedor     := xBusVend(SL1->L1_VEND)
Local xConferente   := xBusConfe(SL1->L1_XCONFER)
Local xAju1         := xBusAju1(SL1->L1_XVEND1)
Local xAju2         := xBusAju2(SL1->L1_XVEND2)
Local xAju3         := xBusAju3(SL1->L1_XVEND3)
Local xFormEntrega 	:= ""
Local xValEntrega 	:= ""
Local xRefGtin14 	:= ""
Local xNomeProduto 	:= ""
Local xCor 			:= ""
Local xCorproduto 	:= ""
Local xQtdGrd 		:= ""
Local xPesoGrd 		:= ""
Local xSubTotal 	:= ""
Local xPesoTotal 	:= ""
Local xItensTotal	:= ""
Local xFrete 		:= ""
Local xDesconto 	:= ""
Local xSubTotal 	:= ""
Local xTotalPedido  := ""
Local xObservacoes  := ""
Local nHnd          := 0
Local cAliAux       := GetNextAlias()
Local cQuery        := ""
Local lFirst        := .F.
Local aDetGrd       := {}
Local cGrade        := ""
Local cCaixa        := ""
Local nQtdGrd       := 0
Local cValAcum      := 0
Local cQtdGrd       := ""
Local nSubTotal     := 0
Local cPeso         := ""
Local nQtdPares     := 0

Private nTotPeso   := 0
Private nTotItens  := 0
Private nTotSub    := 0
Private nTotPedido := 0
Private nTotFrete  := 0
Private nTotDesc   := 0

cFile := "C:\html\picklist.html"

nHnd := FCreate(cFile)

If nHnd == -1
  MsgStop("Falha ao criar arquivo ["+cFile+"]","FERROR "+cValToChar(fError()))
  Return
Else
	fclose(nHnd)
EndIf

cHtml := '<!doctype html>'
cHtml += '<html>'
cHtml += '<head>'
//cHtml += '<meta charset="utf-8">'
cHtml += '<title>Avacy Exclusiva</title>'
cHtml += '<style type="text/css">'
cHtml += 'tr td font {'
cHtml += 'color: #000000;'
cHtml += 'font-size: 14px;'
cHtml += 'font-style: normal;'
cHtml += 'font-weight: normal;'
cHtml += '}'
cHtml += '</style>'
cHtml += '</head>'

cHtml += '<body>'
cHtml += '<table width="692" height="90" border="0">'
cHtml += '<tbody>'
cHtml += '<tr>'
cHtml += '<td width="686" height="50"><img src="Logo.png" align = "center" width="166" height="96" alt=""/></td>'
cHtml += '</tr>'
cHtml += '</tbody>'
cHtml += '</table>'
cHtml += '<table width="693" border="0">'
cHtml += '<tbody>'
cHtml += '<tr>'
cHtml += '<td bgcolor="#100440" style="font-family: Arial; font-weight: bold; font-style: normal; font-size: 14px; color: #F9F9F9;">PEDIDO '+ xDataBase + ' ' + xHoraBase + '</td>'
cHtml += '</tr>'
cHtml += '</tbody>'
cHtml += '</table>'
cHtml += '<table width="692" height="60" border="0">'
cHtml += '<tbody>'
cHtml += '<tr>'
cHtml += '<td width="176" style="font-family: aRIAL; font-size: 12px;">N° VENDA / N° PEDIDO:<br>'
cHtml += ' ' + xNumPedido + '</td>'
cHtml += '<td width="128"><p style="font-family: Arial; font-style: 11; font-size: 12px;">DATA/HORA:<br>'
cHtml += ' ' + xDataHora + '</p></td>'
cHtml += '<td width="169" style="font-family: aRIAL; font-size: 12px;">SITUAÇÃO: LOJA<br>VENDEDOR:' + xVendedor + '<br></td>'
cHtml += '<td width="230" style="font-family: aRIAL; font-size: 12px;">CONFERENTE:' + Alltrim(xConferente) + '<br> AJUDANTES:' + Alltrim(xAju1) + ' ' + Alltrim(xAju2) + ' '  + Alltrim(xAju3) +  '</td>'
cHtml += '</tr>'
cHtml += '</tbody>'
cHtml += '</table>'
cHtml += '<table width="693" border="0">'
cHtml += '<tbody>'
cHtml += '<tr>'
cHtml += '<td bgcolor="#100440" style="font-family: Arial; font-weight: bold; font-style: normal; font-size: 14px; color: #F9F9F9;">CLIENTE</td>'
cHtml += '</tr>'
cHtml += '</tbody>'
cHtml += '</table>'
cHtml += '<table width="692" border="0">'
cHtml += '<tbody>'
cHtml += '<tr>'
cHtml += '<td width="192" style="font-family: aRIAL; font-style: 11; font-size: 12px;">Nome: ' + xNomeCli + '</td>'
cHtml += '<td width="490"><table width="492" border="0">'
cHtml += '<tbody>'
cHtml += '<tr>'
cHtml += '<td width="272" style="font-family: aRIAL; font-size: 12px;">IE/RG: ' + xDocIdentif + '</td>'
cHtml += '<td width="208" style="font-size: 12px; font-family: aRIAL;">CNPJ/CPF: ' + xNumReg + '</td>'
cHtml += '</tr>'
cHtml += '<tr>'
cHtml += '<td colspan="2" style="font-family: aRIAL; font-size: 12px;">Endereço: ' + xEndereco + '</td>'
cHtml += '</tr>'
cHtml += '</tbody>'
cHtml += '</table></td>'
cHtml += '</tr>'
cHtml += '</tbody>'
cHtml += '</table><br>'
cHtml += '<table width="693" border="0">'
cHtml += '<tbody>'
cHtml += '<tr>'
cHtml += '<td bgcolor="#100440" style="font-family: Arial; font-weight: bold; font-style: normal; font-size: 14px; color: #F9F9F9;">ENTREGA</td>'
cHtml += '</tr>'
cHtml += '</tbody>'
cHtml += '</table>'
cHtml += '<table width="692" border="0">'
cHtml += '<tbody>'
cHtml += '<tr>'
cHtml += '<td width="344" style="font-family: aRIAL; font-size: 12px;">'
cHtml += ' FORMA DE ENTREGA: ' + xFormEntrega + '</td>'
cHtml += '<td width="342" style="font-family: aRIAL; font-size: 12px;">'
cHtml += 'VALOR: ' + xValEntrega + '<br></td>'
cHtml += '</tr>'
cHtml += '</tbody>'
cHtml += '</table>'
cHtml += '<br>'
cHtml += '<table width="693" border="0">'
cHtml += '<tbody>'
cHtml += '<tr>'
cHtml += '<td bgcolor="#100440" style="font-family: Arial; font-weight: bold; font-style: normal; font-size: 14px; color: #F9F9F9;">PRODUTOS</td>'
cHtml += '</tr>'
 cHtml += '</tbody>'
cHtml += '</table>'
cHtml += '<br>'

cQuery := "SELECT L2_ITEM," 
cQuery += " L2_XCAIXA,"
cQuery += " Z02_CODGRD," 
cQuery += " Z02_NUM," 
cQuery += " Z02_QTD" 
cQuery += " FROM " +   RetSqlName("Z02") + " " 
cQuery += " INNER JOIN " + RetSqlName("SL2") + " " 
cQuery += " ON SL2010.L2_PRODUTO = Z02010.Z02_COD " 
cQuery += " WHERE  L2_NUM ='" + Alltrim(SL1->L1_NUM) + "' " 
cQuery += " AND SL2010.D_E_L_E_T_ = ' '" 
cQuery += " AND Z02010.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY L2_ITEM,L2_XCAIXA,Z02_CODGRD,Z02_NUM,Z02_QTD"

cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

(cAliAux)->(dbGoTop())

Do While !(cAliAux)->(Eof())
	aadd(aDetGrd, {(cAliAux)->Z02_CODGRD, (cAliAux)->Z02_NUM,(cAliAux)->Z02_QTD, Alltrim((cAliAux)->Z02_CODGRD) + Alltrim((cAliAux)->L2_XCAIXA)  } )
	(cAliAux)->(dbskip())
EndDo

(cAliAux)->(dbGoTop())

Do While !(cAliAux)->(Eof()) 

	cQtdGrd   := xBusQuanti(xNumPedido, (cAliAux)->Z02_CODGRD,Alltrim((cAliAux)->L2_XCAIXA))
    cValUnit  := xValUnit (xNumPedido, (cAliAux)->Z02_CODGRD,cQtdGrd,Alltrim((cAliAux)->L2_XCAIXA))
    nSubTotal := Val(cQtdGrd) * cValUnit
//	cCaixa    := Alltrim((cAliAux)->Z02_CODGRD) + Alltrim((cAliAux)->L2_XCAIXA) 

	If (cValUnit > 0 .Or. nSubTotal > 0)
		If cCaixa != Alltrim((cAliAux)->Z02_CODGRD) + Alltrim((cAliAux)->L2_XCAIXA) //cGrade != Alltrim((cAliAux)->Z02_CODGRD) 
			//cGrade  := Alltrim((cAliAux)->Z02_CODGRD) 
			cCaixa    := Alltrim((cAliAux)->Z02_CODGRD) + Alltrim((cAliAux)->L2_XCAIXA) 
			nQtdGrd := nQtdGrd + 1
		
			cHtml += '<table width="692" height="21" border="0" align="left">'
			  cHtml += '<tbody>'
		 	    cHtml += '<tr>'
			      cHtml += '<td width="88" bgcolor="#CCD7F9" style="font-family: aRIAL; font-size: 12px;"><b>CÓDIGO</b></td>'
			      cHtml += '<td width="240" bgcolor="#CCD7F9" style="font-family: aRIAL; font-size: 12px;"><b>NOME</b></td>'
			      cHtml += '<td width="56" bgcolor="#CCD7F9" style="font-family: aRIAL; font-size: 12px;"><b>QTD:</b></td>'
			      cHtml += '<td width="100" bgcolor="#CCD7F9" style="font-family: aRIAL; font-size: 12px;"><b>PESO TOTAL</b></td>'
			      cHtml += '<td width="98" bgcolor="#CCD7F9" style="font-family: aRIAL; font-size: 12px;"><b>VL UNIT</b></td>'
			      cHtml += '<td width="84" bgcolor="#CCD7F9" style="font-family: aRIAL; font-size: 12px;"><b>SUBTOTAL</b></td>'
			    cHtml += '</tr>'
			  cHtml += '</tbody>'
			cHtml += '</table>'
			cHtml += '<p>'
			cHtml += '</p>'
			cHtml += '<table width="691" height="45" border="0" align="left">'
			  cHtml += '<tbody>'
			    cHtml += '<tr>'
			     cHtml += '<td width="88" bgcolor="#EFF4FF" style="font-family: aRIAL; font-size: 11px;"><p><b>' + xGtin14((cAliAux)->Z02_CODGRD) + '</b><b></b>'
			      cHtml += '</p></td>'
			      cHtml += '<td width="240" bgcolor="#EFF4FF" style="font-family: aRIAL; font-size: 11px;"><b>' + xNomeProduto + '</b><br>'
			
			       // cHtml += '<b>' + xCor + ':</b>' + xCorproduto + '<br>'
			        cHtml += '<b>' + xDesGrade((cAliAux)->Z02_CODGRD) + '</b> <br>'
			        cHtml += '<br>'
			        cHtml += '<table width="200" border="0" align="left">'
			          cHtml += '<tbody>'
			            cHtml += '<tr>'
			              cHtml += '<td><b>TAM</b></td>'
			              For nTam := 1 To Len(aDetGrd)
			              	If  Alltrim(aDetGrd[nTam][1]) ==  Alltrim((cAliAux)->Z02_CODGRD) .And. aDetGrd[nTam][4] ==  Alltrim((cAliAux)->Z02_CODGRD) + Alltrim((cAliAux)->L2_XCAIXA)
			              		cHtml += '<td>' + aDetGrd[nTam][2] + '</td>'
			              	EndIf
			              Next
			            cHtml += '</tr>'
			            cHtml += '<tr>'
			              cHtml += '<td><b>QTD</b></td>'
			              For nTam := 1 To Len(aDetGrd)
			              	If  Alltrim(aDetGrd[nTam][1]) ==  Alltrim((cAliAux)->Z02_CODGRD).And. aDetGrd[nTam][4] ==  Alltrim((cAliAux)->Z02_CODGRD) + Alltrim((cAliAux)->L2_XCAIXA)
			              		cHtml += '<td>' + aDetGrd[nTam][3] + '</td>'
			              	EndIf
			              Next
			            cHtml += '</tr>'
			          cHtml += '</tbody>'
			        cHtml += '</table></td>'
			        
			        For nTam := 1 To Len(aDetGrd)
			        	If  Alltrim(aDetGrd[nTam][1]) ==  Alltrim((cAliAux)->Z02_CODGRD) .And. aDetGrd[nTam][4] ==  Alltrim((cAliAux)->Z02_CODGRD) + Alltrim((cAliAux)->L2_XCAIXA)
			        		nQtdPares += Val(aDetGrd[nTam][3]) 
			            EndIf
			        Next
			        
			        cQtdGrd   := xBusQuanti(xNumPedido, (cAliAux)->Z02_CODGRD,Alltrim((cAliAux)->L2_XCAIXA))
			        cValUnit  := xValUnit (xNumPedido, (cAliAux)->Z02_CODGRD,cQtdGrd, Alltrim((cAliAux)->L2_XCAIXA))
			        nSubTotal := Val(cQtdGrd) * cValUnit
			        cPeso     := xValPeso(xNumPedido, (cAliAux)->Z02_CODGRD,nQtdPares, Val(cQtdGrd),Alltrim((cAliAux)->L2_XCAIXA))
			        
			        
					nTotPeso   += 0
					nTotItens  += Val(cQtdGrd)
					nTotSub    += cValUnit
					nTotPedido += nSubTotal
					
			      cHtml += '<td width="57" bgcolor="#EFF4FF" style="font-family: aRIAL; font-size: 12px;">' + Alltrim(cQtdGrd) + '</td>'
			      cHtml += '<td width="101" bgcolor="#EFF4FF" style="font-family: aRIAL; font-size:12px;">' + Str(cPeso) + '</td>'
			      cHtml += '<td width="97" bgcolor="#EFF4FF" style="font-family: aRIAL; font-size: 12px;">' + Str(cValUnit) + '</td>'
			      cHtml += '<td width="83" bgcolor="#EFF4FF" style="font-family: aRIAL; font-size: 12px;">' + Str(nSubTotal) + '</td>'
			    cHtml += '</tr>'
			  cHtml += '</tbody>'
			cHtml += '</table>'
			cHtml += '<p>&nbsp;</p>'
			cHtml += '<p>&nbsp; </p>'
		EndIf
	EndIf
	
	(cAliAux)->(dbskip())

EndDo
//------------------------------------------------------


cHtml += '<table width="693" border="0">'
cHtml += '<tbody>'
cHtml += '<tr>'
cHtml += '<td bgcolor="#100440" style="font-family: Arial; font-weight: bold; font-style: normal; font-size: 14px; color: #F9F9F9;">VALORES FINAIS</td>'
cHtml += '</tr>'
cHtml += '</tbody>'
cHtml += '</table>'
cHtml += '<table width="692" height="50" border="0">'
cHtml += '<tbody>'
cHtml += '<tr>'
cHtml += '<td width="115" bgcolor="#EFF4FF" style="font-family: Arial; font-size: 12px;"><p><b>PESO TOTAL</b><br>'            
cHtml += '' + Str(nTotPeso)  + ''
cHtml += '</p></td>'
cHtml += '<td width="115" bgcolor="#EFF4FF" style="font-family: Arial; font-size: 12px;"><b>VOLUMES</b><br>'
cHtml += '' + Str(nTotItens) + '</td>'
  cHtml += '<td width="115" bgcolor="#EFF4FF" style="font-family: Arial; font-size: 12px;"><B>FRETE</B><br>'
  cHtml += '' + Str(nTotFrete) + '</td>'
  cHtml += '<td width="115" bgcolor="#EFF4FF" style="font-family: Arial; font-size: 12px;"><B>DESCONTO</B><br>'
  cHtml += '' + Str(nTotDesc) + '</td>'
  cHtml += '<td width="115" bgcolor="#EFF4FF" style="font-family: Arial; font-size: 12px;"><B>SUBTOTAL</B><br>'
  cHtml += '' + Str(nTotSub)  + '</td>'
  cHtml += '<td width="91" bgcolor="#EFF4FF" style="font-family: Arial; font-size: 12px;"><B>TOTAL PEDIDO</B><br>'
  cHtml += '' + Str(nTotPedido) + '</td>'
    cHtml += '</tr>'
  cHtml += '</tbody>'
cHtml += '</table>'
cHtml += '<table width="692" height="100" border="0">'
cHtml += '</table>'
cHtml += '<table width="692" height="40" border="0">'
cHtml += '</table>'
cHtml += '<p>&nbsp; </p>'
cHtml += '<p>&nbsp;</p>'
//cHtml += '<body onload="self.print();self.close();">'
cHtml += '</body>'
cHtml += '</html>'

nHandle := fopen('C:\html\picklist.html' , FO_READWRITE + FO_SHARED )
If nHandle == -1
	MsgStop('Erro de abertura : FERROR '+str(ferror(),4))
Else
	FSeek(nHandle, 0, FS_END)         // Posiciona no fim do arquivo
	FWrite(nHandle, cHtml) // Insere texto no arquivo
	fclose(nHandle)                   // Fecha arquivo
	ShellExecute( "Open", "C:\html\picklist.html", "", "C:\", 1 )
Endif

return

Static Function xLojaCli(cCod,cLoja)

Local aArea     := GetArea() 
Local cNome     := ""

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek(xFilial("SA1") + cCod + cLoja)
	cNome := Alltrim(SA1->A1_NOME)
Else
	Alert("Cliente inexistente!")
EndIf

RestArea( aArea )

Return cNome

Static Function xLojaEnd(cCod,cLoja)

Local aArea     := GetArea() 
Local cEnd      := ""

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek(xFilial("SA1") + cCod + cLoja)
	cEnd := Alltrim(SA1->A1_END) + " " +  Alltrim(SA1->A1_MUN) + " " + Alltrim(SA1->A1_EST) 
Else
	Alert("Cliente inexistente!")
EndIf

RestArea( aArea )

Return cEnd


Static Function xLojaDoc(cCod,cLoja)

Local aArea     := GetArea() 
Local cDoc      := ""

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek(xFilial("SA1") + cCod + cLoja)
	cDoc := SA1->A1_CGC
	If SA1->A1_PESSOA == "F" 
		cDoc := TRANSFORM(cDoc, "@R 999.999.999-99" ) 
	Else
		cDoc := TRANSFORM(cDoc, "@R 99.999.999/9999-99")
	EndIf
Else
	Alert("Cliente inexistente!")
EndIf

RestArea( aArea )

Return cDoc


Static Function xLojaIdent(cCod,cLoja)

Local aArea     := GetArea() 
Local cIdenti   := ""

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek(xFilial("SA1") + cCod + cLoja)
	
	If SA1->A1_PESSOA == "F" 
		cIdenti := SA1->A1_PFISICA
	Else
		cIdenti := SA1->A1_INSCR
	EndIf
Else
	Alert("Cliente inexistente!")
EndIf

RestArea( aArea )

Return cIdenti

Static Function xDesGrade(cCod)

Local aArea     := GetArea() 
Local cDescr    := ""

DbSelectArea("Z01")
DbSetOrder(1)
If DbSeek(xFilial("Z01") + cCod)
	
	cDescr := Z01->Z01_GRADE

Else
	Alert("Grade inexistente!")
EndIf

RestArea( aArea )

Return cDescr

Static Function xGtin14(cCod)

Local aArea     := GetArea() 
Local cGtin     := ""

DbSelectArea("Z01")
DbSetOrder(1)
If DbSeek(xFilial("Z01") + cCod)
	
	cGtin := Z01->Z01_LOTE

Else
	Alert("Grade inexistente!")
EndIf

RestArea( aArea )

Return cGtin

Static Function xBusQuanti(cOrcamento, cGrade, cCaixa)

Local aArea     := GetArea() 
Local cSql      := ""
Local cAliSql   := GetNextAlias()
Local cQuantid  := ""

// WHERE L2_NUM = '000255' AND L2_XGRADE = '97909510511180'  
cSql := "SELECT L2_XGRADE, L2_XQTD, L2_XCAIXA " 
cSql += " FROM " + RetSqlName("SL2") + " " 
cSql += " WHERE  L2_NUM ='" + Alltrim(cOrcamento) + "' " 
cSql += " AND L2_XGRADE = '" + cGrade + "' "
cSql += " AND L2_XCAIXA = '" + cCaixa + "' "
cSql += " AND D_E_L_E_T_ = ' '" 
cSql += " GROUP BY L2_XGRADE, L2_XQTD, L2_XCAIXA"

cSql := ChangeQuery(cSql) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliSql,.T.,.T.)

(cAliSql)->(dbGoTop())

cQuantid := (cAliSql)->L2_XQTD

RestArea( aArea )

Return cQuantid

Static Function xBusPreco(cOrcamento, cGrade, cQtdGrd)

Local aArea       := GetArea() 
Local cSql        := ""
Local cAliSql     := GetNextAlias()
Local cQuantid    := ""
Local nQuantidade := Val(cQtdGrd)

// WHERE L2_NUM = '000255' AND L2_XGRADE = '97909510511180'  
cSql := "SELECT L2_XGRADE, L2_XQTD, L2_XCAIXA " 
cSql += " FROM " + RetSqlName("SL2") + " " 
cSql += " WHERE  L2_NUM ='" + Alltrim(cOrcamento) + "' " 
cSql += " AND L2_XGRADE = '" + cGrade + "' "
cSql += " AND D_E_L_E_T_ = ' '" 
cSql += " GROUP BY L2_XGRADE, L2_XQTD, L2_XCAIXA"

cSql := ChangeQuery(cSql) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliSql,.T.,.T.)

(cAliSql)->(dbGoTop())

cQuantid := (cAliSql)->L2_XQTD

(cAliSql)->(DbCloseArea())

RestArea( aArea )

Return cQuantid


Static Function xValUnit(cNumPedido, cCodGrade, cQtdGrd,cCaixa)

Local aArea       := GetArea() 
Local cSql        := ""
Local cAliSql     := GetNextAlias()
Local nVlrGrade   := 0

// WHERE L2_NUM = '000255' AND L2_XGRADE = '97909510511180'  
cSql := "SELECT L2_XGRADE, L2_XQTD, L2_VLRITEM " 
cSql += " FROM " + RetSqlName("SL2") + " " 
cSql += " WHERE  L2_NUM ='" + Alltrim(cNumPedido) + "' " 
cSql += " AND L2_XGRADE = '" + cCodGrade + "' "
cSql += " AND L2_XCAIXA= '" + cCaixa + "' "
cSql += " AND D_E_L_E_T_ = ' '" 

cSql := ChangeQuery(cSql) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliSql,.T.,.T.)

(cAliSql)->(dbGoTop())

Do While !(cAliSql)->(Eof())

	nVlrGrade += (cAliSql)->L2_VLRITEM
	(cAliSql)->(dbskip())
	
EndDo

(cAliSql)->(DbCloseArea())

nVlrGrade := nVlrGrade / Val(cQtdGrd)

RestArea( aArea )

Return nVlrGrade



Static Function xValPeso(cNumPedido, cCodGrade, nQtdPares, nQtdCompra, cCaixa)

Local aArea       := GetArea() 
Local cSql        := ""
Local cAliSql     := GetNextAlias()
Local nPesoGrade  := 0

// WHERE L2_NUM = '000255' AND L2_XGRADE = '97909510511180'  
cSql := "SELECT L2_QUANT, L2_XGRADE, L2_XQTD, L2_XPESO " 
cSql += " FROM " + RetSqlName("SL2") + " " 
cSql += " WHERE  L2_NUM ='" + Alltrim(cNumPedido) + "' " 
cSql += " AND L2_XGRADE = '" + cCodGrade + "' "
cSql += " AND L2_XCAIXA = '" + cCaixa + "' "
cSql += " AND D_E_L_E_T_ = ' '" 

cSql := ChangeQuery(cSql) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliSql,.T.,.T.)

(cAliSql)->(dbGoTop())

Do While !(cAliSql)->(Eof())

	nPesoGrade += (cAliSql)->L2_XPESO  * (cAliSql)->L2_QUANT
	(cAliSql)->(dbskip())
	
EndDo

(cAliSql)->(DbCloseArea())

RestArea( aArea )

nTotPeso += nPesoGrade

Return nPesoGrade

Static Function xInscCli(cCod,cLoja)

Local aArea     := GetArea() 
Local cInscr    := ""

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek(xFilial("SA1") + cCod + cLoja)
	cInscr := Alltrim(SA1->A1_INSCR)
EndIf

RestArea( aArea )

Return cInscr

Static Function xBusVend(cCod)

Local aArea     := GetArea() 
Local cNome     := ""

DbSelectArea("SA3")
DbSetOrder(1)
If DbSeek(xFilial("SA3") + cCod)
	cNome := Alltrim(SA3->A3_NOME)
EndIf

RestArea( aArea )

Return cNome

Static Function xBusConfe(cCod)

Local aArea     := GetArea() 
Local cNome     := ""

DbSelectArea("ZZC")
DbSetOrder(1)
If DbSeek(xFilial("ZZC") + cCod)
	cNome := Alltrim(ZZC->ZZC_NOME)
EndIf

RestArea( aArea )

Return cNome

Static Function xBusAju1(cCod)

Local aArea     := GetArea() 
Local cNome     := ""

DbSelectArea("ZZA")
DbSetOrder(1)
If DbSeek(xFilial("ZZA") + cCod)
	cNome := Alltrim(ZZA->ZZA_NOME)
EndIf

RestArea( aArea )

Return cNome

Static Function xBusAju2(cCod)

Local aArea     := GetArea() 
Local cNome     := ""

DbSelectArea("ZZA")
DbSetOrder(1)
If DbSeek(xFilial("ZZA") + cCod)
	cNome := Alltrim(ZZA->ZZA_NOME)
EndIf

RestArea( aArea )

Return cNome

Static Function xBusAju3(cCod)

Local aArea     := GetArea() 
Local cNome     := ""

DbSelectArea("ZZA")
DbSetOrder(1)
If DbSeek(xFilial("ZZA") + cCod)
	cNome := Alltrim(ZZA->ZZA_NOME)
EndIf

RestArea( aArea )

Return cNome