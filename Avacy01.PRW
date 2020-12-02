#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} Avacy01

/*/
//-------------------------------------------------------------------

User Function Avacy01()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'ZY1' )
oBrowse:SetDescription( 'Produtos Avacy' )
oBrowse:AddLegend( "ZY1_FLAG == 'S'", "RED"    , "Facilitador utilizado"     )
oBrowse:AddLegend( "ZY1_FLAG != 'S'", "GREEN"  , "Facilitador não utilizado" )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar'  Action 'VIEWDEF.Avacy01' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     Action 'VIEWDEF.Avacy01' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     Action 'VIEWDEF.Avacy01' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     Action 'VIEWDEF.Avacy01' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Gerar Prod.' Action 'U_GERPROD'       OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    Action 'VIEWDEF.Avacy01' OPERATION 8 ACCESS 0
ADD OPTION aRotina Title 'Copiar'      Action 'VIEWDEF.Avacy01' OPERATION 9 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZY1 := FWFormStruct( 1, 'ZY1', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruZY2 := FWFormStruct( 1, 'ZY2', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruZY3 := FWFormStruct( 1, 'ZY3', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'AVC01', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZY1MASTER', /*cOwner*/, oStruZY1 )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'ZY2DETAIL', 'ZY1MASTER', oStruZY2, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//Exemplo de com Definicao do bloco de Carga
//oModel:AddGrid( 'ZA4DETAIL', 'ZA3MASTER', oStruZA4, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, { |oObj, lCopia| LoadZA4( oObj, lCopia )}/*BLoad*/ )

oModel:AddGrid( 'ZY3DETAIL', 'ZY2DETAIL', oStruZY3, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//Exemplo de com Definicao do bloco de Pre-Validacao
//oModel:AddGrid( 'ZA5DETAIL', 'ZA4DETAIL', oStruZA5, { |oMdlG,nLine,cAcao,cCampo| COMP023LPRE( oMdlG, nLine, cAcao, cCampo ) }, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetRelation( 'ZY2DETAIL', { { 'ZY2_FILIAL', 'xFilial( "ZY2" )' }, { 'ZY2_PROD' , 'ZY1_PROD'  } } , ZY2->( IndexKey( 1 ) )  )
oModel:SetRelation( 'ZY3DETAIL', { { 'ZY3_FILIAL', 'xFilial( "ZY3" )' }, { 'ZY3_PROD' , 'ZY1_PROD'  }, { 'ZY3_CODCOR', 'ZY2_CODCOR' } } , ZY3->( IndexKey( 1 ) )  )


// Liga o controle de nao repeticao de linha
oModel:GetModel( 'ZY2DETAIL' ):SetUniqueLine( { 'ZY2_PROD','ZY2_CODCOR' } )
oModel:GetModel( 'ZY3DETAIL' ):SetUniqueLine( { 'ZY3_PROD','ZY3_CODCOR','ZY3_TAM'  } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Avacy Produto' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZY1MASTER' ):SetDescription( 'Produto Principal' )
oModel:GetModel( 'ZY2DETAIL' ):SetDescription( 'Cores/Modelos'  )
oModel:GetModel( 'ZY3DETAIL' ):SetDescription( 'Tamanhos/Caracteristicas'  )

oModel:SetPrimaryKey({'ZY3_FILIAL', 'ZY3_PROD', 'ZY3_CODCOR','ZY3_TAM'})


Return oModel

//-------------------------------------------------------------------

Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruZY1 := FWFormStruct( 2, 'ZY1' )
Local oStruZY2 := FWFormStruct( 2, 'ZY2' )
Local oStruZY3 := FWFormStruct( 2, 'ZY3' )
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'AVACY01' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZY1', oStruZY1, 'ZY1MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_ZY2', oStruZY2, 'ZY2DETAIL' )
oView:AddGrid(  'VIEW_ZY3', oStruZY3, 'ZY3DETAIL' )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'EMCIMA' , 30 )
oView:CreateHorizontalBox( 'MEIO'   , 30 )
oView:CreateHorizontalBox( 'EMBAIXO', 40 )

// Criar "box" vertical para receber algum elemento da view
// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZY1', 'EMCIMA'   )
oView:SetOwnerView( 'VIEW_ZY2', 'MEIO'     )
oView:SetOwnerView( 'VIEW_ZY3', 'EMBAIXO'  )

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_ZY1' )
oView:EnableTitleView( 'VIEW_ZY2', "Cores/Modelos", RGB( 224, 30, 43 )  )
oView:EnableTitleView( 'VIEW_ZY3', "Tamanhos/Caracteristicas", 0 )

Return oView

//-------------------------------------------------------------------

Static Function COMP23BUT( oPanel )

Local lOk := .F.

@ 10, 10 Button 'Processar'   Size 36, 13 Message 'Processar' Pixel Action COMP23ACAO( 'ZA2DETAIL', 'Existem na Grid de Produtos'     ) of oPanel
@ 30, 10 Button 'Produtos Avacy'  Size 36, 13 Message 'Inclui Produtos Avacy' Pixel Action FWExecView('Inclusao por FWExecView','COMP011_MVC', MODEL_OPERATION_INSERT, , { || .T. } ) of oPanel

Return NIL

//-------------------------------------------------------------------

Static Function COMP23ACAO( cIdGrid, cMsg )

Local oModel       := FWModelActive()
Local oModelFilho  := oModel:GetModel( cIdGrid )
Local nI           := 0
Local nCtInc       := 0
Local nCtAlt       := 0
Local nCtDel       := 0
Local aSaveLines   := FWSaveRows()

For nI := 1 To oModelFilho:Length()
	
	oModelFilho:GoLine( nI )

	If oModelFilho:IsDeleted()
		nCtDel++
	ElseIf oModelFilho:IsInserted()
		nCtInc++
	ElseIf oModelFilho:IsUpdated()
		nCtAlt++
	EndIf

Next


Help( ,, 'HELP',, cMsg + CRLF + ;
Alltrim( Str( nCtInc ) ) + ' linhas incluidas' + CRLF + ;
Alltrim( Str( nCtAlt ) ) + ' linhas alteradas' + CRLF + ;
Alltrim( Str( nCtDel ) ) + ' linhas deletadas' + CRLF   ;
, 1, 0)

FWRestRows( aSaveLines )

Return NIL

//-------------------------------------------------------------------

Static Function COMP023LPRE( oModelGrid, nLinha, cAcao, cCampo )

Local lRet       := .T.
Local oModel     := oModelGrid:GetModel()
Local nOperation := oModel:GetOperation()

// Valida se pode ou nao deletar uma linha do Grid
If cAcao == 'DELETE' .AND. nOperation == MODEL_OPERATION_UPDATE
	lRet := .F.
	Help( ,, 'Help',, 'Nao permitido apagar linhas na alteracao.' + CRLF + ;
	'Voce esta na linha ' + Alltrim( Str( nLinha ) ), 1, 0 )
EndIf

Return lRet

//-------------------------------------------------------------------

User Function GERPROD()

MsAguarde({|lFim| xProdAva()},"Processamento","Aguarde a finalização da gravação dos produtos...")

Return

Static Function xProdAva()

Local lRet    := .T.
Local cQuery  := ""
Local cAliAux := GetNextAlias()
Local aVetor  := {}
Local nVezes  := 0
Local lGrv    := .F.
Local ni      := 0
Local nQtd    := 0
Local nAliCof := GETMV("MV_XPCOFIN")
Local nAliPis := GETMV("MV_XPPIS")
Local cCodCab := ZY1->ZY1_PROD

Private lMsErroAuto := .F.

If ZY1->ZY1_FLAG == 'S'
	MsgInfo("Facilitador já utilizado!","Registro Inválido")
	lRet := .F.
EndIf

If lRet
	If MsgYesNo( "Deseja gerar os produtos a partir desse cadastro?", "Gerar Pedidos" )
	
		cQuery := "SELECT * FROM "
		cQuery += RetSqlName("ZY1") + " AS PRODUTO "
		cQuery += " INNER JOIN "
		cQuery += RetSqlName("ZY2") + " AS COR"
		cQuery += " ON PRODUTO.ZY1_PROD = COR.ZY2_PROD  "
		cQuery += " INNER JOIN "
		cQuery += RetSqlName("ZY3") + " AS TAMANHO "
		cQuery += " ON COR.ZY2_PROD = TAMANHO.ZY3_PROD AND COR.ZY2_CODCOR = TAMANHO.ZY3_CODCOR "
		cQuery += " WHERE ZY1_PROD = '" + cCodCab + "' AND COR.D_E_L_E_T_ = ' ' AND PRODUTO.D_E_L_E_T_ = ' ' AND TAMANHO.D_E_L_E_T_ = ' '"
			
		cQuery := ChangeQuery(cQuery) 
		 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)
		
		(cAliAux)->(dbGotop())
		
		Do While !(cAliAux)->(Eof())
			
			//nQtd := Val((cAliAux)->ZY3_QTD)
			
			//For ni := 1 To nQtd
			
				nVezes ++
				
				aVetor:= { {"B1_COD" ,Alltrim((cAliAux)->ZY3_CODPRO)                        ,NIL},;
				 {"B1_DESC"          ,Alltrim((cAliAux)->ZY1_DESCRI)+ " " + Alltrim((cAliAux)->ZY2_CODCOR) + " " + Alltrim((cAliAux)->ZY2_COR) + " " + Alltrim((cAliAux)->ZY3_TAM),NIL},;
				 {"B1_TIPO"          ,"ME"                                                  ,Nil},;
				 {"B1_UM"            ,"UN"                                                  ,Nil},;
				 {"B1_LOCPAD"        ,"01"                                                  ,Nil},;
				 {"B1_PICM"          ,0                                                     ,Nil},;
				 {"B1_IPI"           ,0                                                     ,Nil},;
				 {"B1_CONTRAT"       ,"N"                                                   ,Nil},;
				 {"B1_SEGUM"         ,"CX"                                                  ,Nil},;
				 {"B1_GRUPO"         ,"0007"                                                ,Nil},;
				 {"B1_GRUPO"         ,"0007"                                                ,Nil},;
				 {"B1_CODGTIN"       ,Alltrim((cAliAux)->ZY3_CODGTI)                        ,Nil},;
				 {"B1_PPIS"          ,nAliPis                                               ,Nil},;
				 {"B1_PCOFINS"       ,nAliCof                                               ,Nil},;
				 {"B1_POSIPI"        ,Alltrim((cAliAux)->ZY1_POSIPI)                        ,Nil},;
				 {"B1_CODBAR"        ,Alltrim((cAliAux)->ZY3_CODBAR)                        ,Nil},;
				 {"B1_XCODINT"       ,Alltrim((cAliAux)->ZY1_CODINT)                        ,Nil},;
				 {"B1_XTAM"          ,Alltrim((cAliAux)->ZY3_TAM)                           ,Nil},;
				 {"B1_XMARCA"        ,Alltrim((cAliAux)->ZY1_MARCA)                         ,Nil},;
				 {"B1_PRV1"          ,(cAliAux)->ZY1_PRCUNI                                 ,Nil},;
				 {"B1_CUSTD"         ,(cAliAux)->ZY1_CUSTD                                  ,Nil},;
				 {"B1_ORIGEM"        ,"0"                                                   ,Nil},;
				 {"B1_RASTRO"        ,"L"                                                   ,Nil},;
				 {"B1_PESO"          ,(cAliAux)->ZY1_PESO                                   ,Nil},;
				 {"B1_LOCALIZ"       ,"N"                                                   ,Nil}}
				 
				 //{"B1_LOJPROC"       ,"01"                                                  ,Nil}}
				 
				 MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)
				 
				 If lMsErroAuto
					MostraErro()
					lGrv := .F.
					Exit
				Else
			 		lGrv := .T.
				Endif
			//Next
			
			(cAliAux)->(dbskip())
			
		EndDo
		
		If lGrv
			MsgInfo("Produtos gravados com sucesso","Gravação de Produtos")
			
			RecLock("ZY1",.F.)
				ZY1->ZY1_FLAG := 'S'
			ZY1->(MsUnlock())
		EndIf
		
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------

Static Function LoadZA4( oGrid, lCopy ) 
Local aArea   := GetArea() 
Local aFields := {}
Local aRet    := {} 
Local cFields := 'R_E_C_N_O_'
Local cTmp    := ''
Local cQuery  := ''

// Pega campos que fazem parte da estrutura do objeto, para otimizar retorno da query
aFields := oGrid:GetStruct():GetFields()
aEval( aFields, { |aX| IIf( !aX[MODEL_FIELD_VIRTUAL], cFields += ',' + aX[MODEL_FIELD_IDFIELD],) } )

cTmp   := GetNextAlias() 
cQuery := ""
cQuery += "SELECT " + cFields + " FROM " + RetSqlName( 'ZA4' ) + " ZA4"
cQuery += " WHERE ZA4_FILIAL='" + xFilial( 'ZA4' ) + "'"
cQuery += " AND ZA4_ALBUM='" + oGrid:GetModel():GetModel( 'ZA3MASTER' ):GetValue( 'ZA3_ALBUM' ) + "'"
cQuery += " AND ZA4.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. ) 

aRet := FWLoadByAlias( oGrid, cTmp ) 

(cTmp)->( dbCloseArea() ) 

RestArea( aArea ) 

Return aRet  


Static Function xGatZY2()

Local lRet      := .T.
Local oModel    := FWModelActive()
Local cCod      := oModel:GetValue('ZY1MASTER','ZY1_PROD')

oModel:SetValue('ZY2DETAIL','ZY2_PROD',cCod)
oModel:SetValue('ZY3DETAIL','ZY3_PROD',cCod)

Return lRet

Static Function xGatZY3()

Local lRet      := .T.
Local oModel    := FWModelActive()
Local cCodCor   := oModel:GetValue('ZY2DETAIL','ZY2_CODCOR')

cCodCor := Alltrim(cCodCor)
oModel:SetValue('ZY3DETAIL','ZY3_CODCOR',cCodCor)

Return lRet

User Function xValProd()

Local lRet       := .T.
Local oModel     := FWModelActive()
Local cCodProd   := oModel:GetValue('ZY2DETAIL','ZY2_PROD')
Local CodZY3     := oModel:GetValue('ZY3DETAIL','ZY3_PROD')

cCodProd := Alltrim(cCodProd)
CodZY3   := Alltrim(CodZY3)

If cCodProd != CodZY3
	MsgInfo("Digite o mesmo código do produto do cabeçalho!","Código de produto inválido")
	lRet := .F.
EndIf

Return lRet


User Function xValCor()

Local lRet       := .T.
Local oModel     := FWModelActive()
Local cCodCor    := oModel:GetValue('ZY2DETAIL','ZY2_CODCOR')
Local CodZY3     := oModel:GetValue('ZY3DETAIL','ZY3_CODCOR')

cCodCor  := Alltrim(cCodCor)
CodZY3   := Alltrim(CodZY3)

If cCodCor != CodZY3
	MsgInfo("Digite o mesmo código da cor do grid Cores/Modelos!","Código de cor inválido")
	lRet := .F.
EndIf

Return lRet

User Function xValZy2()

Local lRet       := .T.
Local oModel     := FWModelActive()
Local cCodPro    := oModel:GetValue('ZY1MASTER','ZY1_PROD')
Local CodZY2     := oModel:GetValue('ZY2DETAIL','ZY2_PROD')

cCodPro  := Alltrim(cCodPro)
CodZY2   := Alltrim(CodZY2)

If cCodPro != CodZY2
	MsgInfo("Digite o mesmo código do produto do cabeçalho!","Código de produto inválido")
	lRet := .F.
EndIf

Return lRet

User Function xCodSb1()

Local aArea      := GetArea()
Local lRet       := .T.
Local oModel     := FWModelActive()
Local cCodPro    := oModel:GetValue('ZY3DETAIL','ZY3_CODPRO')

cCodPro  := Alltrim(cCodPro)

DbSelectArea("SB1")
SB1->(DbSetOrder(1))

If DbSeek( xFilial("SB1") + cCodPro )
	MsgInfo("Código de produto já existente na SB1","Código de produto")
	lRet := .F.
EndIf

RestArea( aArea )

Return lRet

Static Function xMaxZy1()

Local cMaxZY1    := ""
Local cQuery     := ""
Local cAliAux    := GetNextAlias()

cQuery := "SELECT MAX(ZY1_PROD) AS IDMAX FROM"
cQuery += RetSqlName("ZY1") + " ZY1 "
cQuery += " WHERE "
cQuery += " D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery) 
 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliAux,.T.,.T.)

cMaxZY1 := (cAliAux)->IDMAX

(cAliAux)->(dbCloseArea())

cMaxZY1 := Soma1(cMaxZY1)

Return cMaxZY1

User Function xGatCod()

Local lRet       := .T.
Local oModel     := FWModelActive()
Local cCod       := oModel:GetValue('ZY1MASTER','ZY1_PROD')
Local oAux2      := oModel:GetModel( 'ZY2DETAIL' )
Local oAux3      := oModel:GetModel( 'ZY3DETAIL' )

cCod := Alltrim(cCod)

//oModel:SetValue('Z02DETAIL','Z02_CODGRD',cLote)
oAux2:LoadValue("ZY2_PROD",cCod)

Return lRet

User Function xGatCor()

Local lRet       := .T.
Local oModel     := FWModelActive()
Local oAux2      := oModel:GetModel( 'ZY2DETAIL' )
Local oAux3      := oModel:GetModel( 'ZY3DETAIL' )
Local cCor       := oModel:GetValue('ZY2DETAIL','ZY2_CODCOR')

cCor := Alltrim(cCor)

oAux3:LoadValue("ZY3_CODCOR",cCor)

Return lRet

User Function xValZY3Tam()

Local lRet      := .F.
Local aArea     := GetArea() 
Local cTam      := Alltrim(M->ZY3_TAM)
Local nTamLote  := 0

If !IsNumeric( cTam )
	Help("",1,"Tamanho invalido",,"Digite apenas números",1,0, NIL, NIL, NIL, NIL, NIL, {"Digite um tamanho inválido"})
	lRet := .F.
Else
	lRet := .T.
EndIf

RestArea( aArea )

Return lRet