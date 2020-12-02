#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

User Function Avacy03()
Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('Z01')
	oBrowse:SetDescription('Cadastro de Grade')
	oBrowse:Activate()
Return

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar'  ACTION 'VIEWDEF.Avacy03' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'     ACTION 'VIEWDEF.Avacy03' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'     ACTION 'VIEWDEF.Avacy03' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'     ACTION 'VIEWDEF.Avacy03' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imp.Amostra' ACTION 'U_Amostra()' OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE 'Imp.Caixa'   ACTION 'U_Caixa()' OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar'      ACTION 'VIEWDEF.Avacy03' OPERATION 9 ACCESS 0

Return aRotina

Static Function ModelDef() 
Local oModel 
Local oStruZ01 := FWFormStruct(1,"Z01") 
Local oStruZ02 := FWFormStruct(1,"Z02") 
	 
oModel := MPFormModel():New("INC_GRADE",,{ |oModel| U_xGradeVld(oModel) })  

oModel:SetDescription("Cadastro de Grade Avacy")    

oModel:addFields('Z01MASTER',,oStruZ01)  

oModel:addGrid('Z02DETAIL','Z01MASTER',oStruZ02)  

oModel:SetPrimaryKey({'Z01_FILIAL', 'Z01_COD'})

oModel:SetRelation("Z02DETAIL", ;       
 					{{"Z02_FILIAL",'xFilial("Z02")'},;        
					{"Z02_CODGRD","Z01_LOTE"  }}, ;       
					Z02->(IndexKey(1)))         
 						
Return oModel 

Static Function ViewDef() 
Local oModel := ModelDef() 
Local oView 
Local oStrZB5:= FWFormStruct(2, 'Z01')   
Local oStrZB6:= FWFormStruct(2, 'Z02')   
    
	oView := FWFormView():New()  
	oView:SetModel(oModel)    
	oView:AddField('FORM_TURMA' , oStrZB5,'Z01MASTER' )  
	oView:AddGrid('FORM_ALUNOS' , oStrZB6,'Z02DETAIL')  
	
	oView:CreateHorizontalBox( 'BOX_FORM_TURMA', 30)  
	oView:CreateHorizontalBox( 'BOX_FORM_ALUNOS', 70)  
 	
 	oView:SetOwnerView('FORM_ALUNOS','BOX_FORM_ALUNOS')  
 	oView:SetOwnerView('FORM_TURMA','BOX_FORM_TURMA')   
 	 	
Return oView

//-------------------------------------------------------------------

/*/{Protheus.doc} GatSN3
Gatilho do objeto SN3
@since 02/08/2017
@version 12.17
/*/
//-------------------------------------------------------------------

User Function xGatZ02()

Local lRet      := .T.
Local oModel    := FWModelActive()
Local cLote     := oModel:GetValue('Z01MASTER','Z01_LOTE')
Local oAux      := oModel:GetModel( 'Z02DETAIL' )

cLote := Alltrim(cLote)

oAux:LoadValue("Z02_CODGRD",cLote)

Return lRet

//--------------------------------------------------------------------------------------------

User Function GatZ02()

Local lRet      := .T.
Local oModel    := FWModelActive()
Local cCod      := oModel:GetValue('Z02DETAIL','Z02_COD')
Local aArea     := GetArea() 
Local cTam      := ""

DbSelectArea("SB1")
DbSeek(xFilial("SB1") + cCod)
cTam := Alltrim(SB1->B1_XTAM)

oModel:SetValue('Z02DETAIL','Z02_NUM',cTam)

RestArea( aArea )

Return lRet

User Function xGradeVld()

Local lRet    := .F.
Local oModel  := FWModelActive()
Local cValTot := oModel:GetValue('Z01MASTER','Z01_QTD')
Local oAux    := oModel:GetModel( 'Z02DETAIL' )
Local nI      := 0
Local cValor  := ""
Local nValTot := 0
Local nValor  := 0
Local nPeso   := 0
Local nValGrd := 0
Local cProd   := 0
Local nOper	  := oModel:GetOperation()

If nOper != 5
	FOR nI := 1 TO oAux:Length() 
	     oAux:GoLine(nI) 
	     IF !oAux:IsDeleted() // Linha não deletada 
	          cValor   := oAux:GetValue("Z02_QTD") // Pegar um valor do GRID 
	          cProd    := oAux:GetValue("Z02_COD") 
	          nPeso    += u_xBusPeso(cProd)
	          nValGrd  += u_xBusValGrd(cProd)
	          nValor   += Val(cValor)
	     ENDIF 
	NEXT nI 
	
	nValTot := Val(cValTot)
	
	If nValor != nValTot
		Help("",1,"Quantidade",,"Total de pares incorreto!",1)
		lRet    := .F.
		nPeso   := 0
		nValGrd := 0
	Else
		oModel:SetValue('Z01MASTER' ,'Z01_PESO'  ,nPeso)
		oModel:SetValue('Z01MASTER' ,'Z01_PRECO' ,nValGrd)
		lRet := .T.
	EndIf
Else
	lRet := .T.
EndIf	

Return lRet

User Function xValLote()

Local lRet      := .F.
Local aArea     := GetArea() 
Local cLote     := Alltrim(M->Z01_LOTE)
Local nTamLote  := 0

nTamLote := Len(cLote)

If nTamLote < 14
	Help("",1,"GTIN",,"Codigo GTIN menor que 14 caracteres",1,0, NIL, NIL, NIL, NIL, NIL, {"Digite 14 caracteres válidos para o GTIN"})
	lRet := .F.
Else
	lRet := .T.
EndIf

RestArea( aArea )

Return lRet


User Function xNumVal()

Local lRet      := .F.
Local aArea     := GetArea() 
Local cLote     := Alltrim(M->Z01_QTD)
Local nTamLote  := 0

If !IsNumeric( cLote )
	Help("",1,"Número",,"Digite apenas números",1,0, NIL, NIL, NIL, NIL, NIL, {"Digite um valor numérico"})
	lRet := .F.
Else
	lRet := .T.
EndIf

RestArea( aArea )

Return lRet

User Function xValZ02Num()

Local lRet      := .F.
Local aArea     := GetArea() 
Local cNum      := Alltrim(M->Z02_NUM)
Local nTamLote  := 0

If !IsNumeric( cNum )
	Help("",1,"Número Calçado",,"Digite apenas números",1,0, NIL, NIL, NIL, NIL, NIL, {"Digite um número de calçado válido"})
	lRet := .F.
Else
	lRet := .T.
EndIf

RestArea( aArea )

Return lRet


User Function xValZ02Qtd()

Local lRet      := .F.
Local aArea     := GetArea() 
Local cQtd      := Alltrim(M->Z02_QTD)
Local nTamLote  := 0

If !IsNumeric( cQtd )
	Help("",1,"Quantidade Inválida",,"Digite apenas números",1,0, NIL, NIL, NIL, NIL, NIL, {"Digite apenas números na quantidade"})
	lRet := .F.
Else
	lRet := .T.
EndIf

RestArea( aArea )

Return lRet

User Function xBusPeso(cProd)

Local oModel    := FWModelActive()
Local aArea     := GetArea() 
Local nPeso     := 0

DbSelectArea("SB1")
If DbSeek(xFilial("SB1") + cProd)
	nPeso := SB1->B1_PESO
Else
	MsgInfo( "Produto não encontrado", "Produto" )
EndIf

RestArea( aArea )

Return nPeso


User Function xBusValGrd(cProd)

Local oModel    := FWModelActive()
Local aArea     := GetArea() 
Local nValor    := 0

DbSelectArea("SB1")
If DbSeek(xFilial("SB1") + cProd)
	nValor := SB1->B1_PRV1
Else
	MsgInfo( "Produto não encontrado", "Produto" )
EndIf

RestArea( aArea )

Return nValor

User Function xGatPeso()

Local lRet       := .T.
Local oModel     := FWModelActive()
Local oAux2      := oModel:GetModel('Z02DETAIL' )
Local cCodPro    := oModel:GetValue('Z02DETAIL','Z02_COD')
Local cQtd       := oModel:GetValue('Z02DETAIL','Z02_QTD')
Local nPeso      := 0
Local nPreco     := 0
Local aArea      := GetArea()
 
DbSelectArea("SB1")
DbSeek(xFilial("SB1") + cCodPro)
nPeso   := SB1->B1_PESO
nPeso   := nPeso * Val(cQtd)
nPreco  := SB1->B1_PRV1
nPreco  := nPreco * Val(cQtd)

oModel:SetValue('Z02DETAIL','Z02_PESO',nPeso)
oModel:SetValue('Z02DETAIL','Z02_PRECO',nPreco)

RestArea( aArea )

Return lRet
