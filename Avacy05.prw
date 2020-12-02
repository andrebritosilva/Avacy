#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FWBROWSE.CH" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc}Avacy05
Tela de consulta ao estoque por grade - Avacy 
@author André Luiz Brito Silva
@since  25/07/2019
@version 12
/*/
//-------------------------------------------------------------------

User Function Avacy05(cProdDe,cGtin13 ,cGtin14 , nOpt) 

Private oProcess

oProcess := MsNewProcess():New( { || xConSldProd(cProdDe,cGtin13 ,cGtin14 , nOpt) } , "Realizando consulta de saldo em estoque" , "Aguarde..." , .F. )
oProcess:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}Avacy05
Tela de consulta ao estoque por grade - Avacy 
@author André Luiz Brito Silva
@since  25/07/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function xConSldProd(cProdDe,cGtin13 ,cGtin14 , nOpt) 

Local aCoors    := FWGetDialogSize( oMainWnd ) 
Local cQuery    := ""
Local cGrade    := ""
Local cAcuGrd   := 0
Local nAcuGrd   := 0
Local cTotGrd   := 0
Local cConCab   := GetNextAlias()
Local cConGrd1  := GetNextAlias()
Local cConGrd2  := GetNextAlias()
Local aColumns  := {}
Local aColGrd1  := {}
Local aColGrd2  := {}
Local nX        := 0
Local aCampos   := {}
Local aCpsGrd1  := {}
Local aCpsGrd2  := {}
Local aCpsGrd3  := {}
Local nTotGrd   := 0
Local _oConCab
Local _oConGrd1 
Local _oConGrd2
Local oBrowse
Local oBrowseSup
Local oBrowseInf

Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseDown, oRelacZA4, oRelacZA5 
//Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseDown, oBrowseRight,oRelacZA4, oRelacZA5 
Private oDlgPrinc 
Private aRotina 	:=	MenuDef()
Private nTotCxLt    := 0 

//nTotCxLt := xTotCx(cProdDe)

AADD(aCpsGrd1,{"COD"             ,"C",TamSX3("Z02_COD")[1]    ,0})
AADD(aCpsGrd1,{"DESCR"           ,"C",100                     ,0})
AADD(aCpsGrd1,{"CODGRD"          ,"C",TamSX3("Z02_CODGRD")[1] ,0})
AADD(aCpsGrd1,{"CAIXA"           ,"N",TamSX3("B8_SALDO")[1]   ,0})
AADD(aCpsGrd1,{"ESTOQUE"         ,"C",6                       ,0})
AADD(aCpsGrd1,{"SALDO"           ,"N",TamSX3("B8_SALDO")[1]   ,0})

AADD(aCpsGrd2,{"FILIAL"          ,"C",TamSX3("Z02_FILIAL")[1] ,0})
AADD(aCpsGrd2,{"CODGRD"          ,"C",TamSX3("Z02_CODGRD")[1] ,0})
AADD(aCpsGrd2,{"COD"             ,"C",TamSX3("Z02_COD")[1]    ,0})
AADD(aCpsGrd2,{"DESCR"           ,"C",100                     ,0})
AADD(aCpsGrd2,{"NUM"             ,"C",TamSX3("Z02_NUM")[1]    ,0})
AADD(aCpsGrd2,{"QUANTIDADE"      ,"C",TamSX3("Z02_QTD")[1]    ,0})

cQuery := "SELECT * FROM " + RetSqlName('Z02')
cQuery += " WHERE D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd2,.T.,.T.)

(cConGrd2)->(dbGoTop())

If _oConGrd2 <> Nil
	_oConGrd2:Delete() 
	_oConGrd2 := Nil
EndIf

// Criando o objeto do arquivo temporário
_oConGrd2 := FwTemporaryTable():New("cArqGrd2")

// Criando a estrutura do objeto  
_oConGrd2:SetFields(aCpsGrd2)

// Criando o indice da tabela
_oConGrd2:AddIndex("1",{"CODGRD"})

_oConGrd2:Create()

oProcess:SetRegua2( (cConGrd2)->(RecCount()) ) 

Do While (cConGrd2)->(!Eof())

	oProcess:IncRegua1("Processando consulta de saldo por lote")
	
	nAcuGrd += Val((cConGrd2)->Z02_QTD)
	
	RecLock("cArqGrd2",.T.)
	
	cArqGrd2->FILIAL      := (cConGrd2)->Z02_FILIAL 
	cArqGrd2->CODGRD      := (cConGrd2)->Z02_CODGRD  
	cArqGrd2->COD         := (cConGrd2)->Z02_COD
	cArqGrd2->DESCR       := xDescPro((cConGrd2)->Z02_COD) 
	cArqGrd2->NUM         := (cConGrd2)->Z02_NUM
	cArqGrd2->QUANTIDADE  := (cConGrd2)->Z02_QTD
	
	If Alltrim((cConGrd2)->Z02_COD) == Alltrim(cProdDe)
		nTotGrd += Val((cConGrd2)->Z02_QTD)
	EndIf
	
	MsUnLock()
	
	(cConGrd2)->(DbSkip())
		
EndDo

cAcuGrd := Str(nAcuGrd)

cArqGrd2->(dbGotop())

cQuery := "SELECT B8_PRODUTO, B8_LOTECTL, B8_SALDO, COUNT (*) AS CAIXA  FROM "
cQuery += RetSqlName("SB8") + "WHERE B8_PRODUTO = '" + cProdDe + "'  GROUP BY B8_PRODUTO, B8_LOTECTL, B8_SALDO

cQuery := ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cConGrd1,.T.,.T.)

(cConGrd1)->(dbGoTop())

oProcess:SetRegua1( (cConGrd1)->(RecCount()) ) 

If _oConGrd1 <> Nil
	_oConGrd1:Delete() 
	_oConGrd1 := Nil
EndIf

// Criando o objeto do arquivo temporário
_oConGrd1 := FwTemporaryTable():New("cArqGrd1")

// Criando a estrutura do objeto  
_oConGrd1:SetFields(aCpsGrd1)

// Criando o indice da tabela
_oConGrd1:AddIndex("1",{"CODGRD"})

_oConGrd1:Create()

//cTotGrd := (cConGrd1)->Z01_QTD

Do While (cConGrd1)->(!Eof())

	oProcess:IncRegua2("Consultando grades...")
		
	RecLock("cArqGrd1",.T.)
	
	cArqGrd1->COD         := (cConGrd1)->B8_PRODUTO 
	cArqGrd1->DESCR       := xDescPro((cConGrd1)->B8_PRODUTO ) 
	cArqGrd1->CODGRD      := (cConGrd1)->B8_LOTECTL 
	cArqGrd1->CAIXA       := (cConGrd1)->B8_SALDO / nTotGrd//Alltrim(Str((cConGrd1)->CAIXA))
	cArqGrd1->SALDO       := (cConGrd1)->B8_SALDO / nTotGrd //xRetMod((cConGrd1)->B8_PRODUTO,(cConGrd1)->B8_LOTECTL )
	
	MsUnLock()
	
	(cConGrd1)->(DbSkip())
		
EndDo

cArqGrd1->(dbGotop())

Define MsDialog oDlgPrinc Title 'Consulta Estoque Avacy' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel 

// 
// Cria o conteiner onde serão colocados os browses 

// 
oFWLayer := FWLayer():New() 
oFWLayer:Init( oDlgPrinc, .F., .T. ) 

// 
// Define Painel Superior 
// 
oFWLayer:AddLine( 'UP', 50, .F. ) 
// Cria uma "linha" com 50% da tela 
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' ) 
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela 
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' ) 
// Pego o objeto desse pedaço do container 

// 
// Painel Inferior 
// 
oFWLayer:AddLine( 'DOWN', 50, .F. ) 
oFWLayer:AddCollumn( 'LEFT' , 100, .T., 'DOWN' ) 
oPanelLeft := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' ) // Pego o objeto do pedaço esquerdo 

// 
// FWmBrowse Superior PB5 - Cabeçalho Consulta Nexxera 
// 
oBrowseUp:= FWmBrowse():New() 
oBrowseUp:DisableReport()
oBrowseUp:SetOwner( oPanelUp ) 
oBrowseUp:SetDescription( "Grades que constam o produto selecionado" ) 

oBrowseUp:SetAlias( 'cArqGrd1') 

oBrowseUp:AddLegend( "cArqGrd1->SALDO > 0"   , "GREEN" ,"Produto em estoque" ) 
oBrowseUp:AddLegend( "cArqGrd1->SALDO == 0"   , "RED"  ,"Produto sem estoque" ) 

//Detalhes das colunas que serão exibidas
	
oBrowseUp:SetColumns(MontaColunas("cArqGrd1->COD"		,"Codigo"		  ,01,"@!",0,010,0))
oBrowseUp:SetColumns(MontaColunas("cArqGrd1->DESCR"		,"Descricao"      ,01,"@!",0,050,0))
oBrowseUp:SetColumns(MontaColunas("cArqGrd1->CODGRD"	,"Cod. Grade"	  ,02,"@!",1,010,0))
oBrowseUp:SetColumns(MontaColunas("cArqGrd1->CAIXA"	    ,"Qtd. de Caixas",03,"@!",1,010,0))//Quantidade de caixa onde consta o produto
//oBrowseUp:SetColumns(MontaColunas("cArqGrd1->ESTOQUE"	,"Qtd. Prod. Grade",04,"@!",1,010,0))//Quantidade total do produto na grade

oBrowseUp:SetMenuDef( '' ) 
oBrowseUp:SetProfileID( '1' ) 
oBrowseUp:ForceQuitButton() 
oBrowseUp:Activate() 

// 
// FWmBrowse Inferior PB6 - Itens Consulta Nexxera 
// 
oBrowseDown:= FWMBrowse():New() 
oBrowseDown:DisableReport()
oBrowseDown:SetOwner( oPanelLeft ) 
oBrowseDown:SetDescription( 'Conteúdo da grade selecionada ' ) 

oBrowseDown:SetColumns(MontaColunas("cArqGrd2->FILIAL"		,"Filial"		      ,01,"@!",0,010,0))
oBrowseDown:SetColumns(MontaColunas("cArqGrd2->CODGRD"	    ,"Cod. Grade"	      ,02,"@!",1,010,0))
oBrowseDown:SetColumns(MontaColunas("cArqGrd2->COD"	        ,"Produto"	          ,03,"@!",1,010,0))
oBrowseDown:SetColumns(MontaColunas("cArqGrd2->DESCR"	    ,"Descricao"	      ,03,"@!",1,050,0))
oBrowseDown:SetColumns(MontaColunas("cArqGrd2->NUM"	        ,"Numero"	          ,04,"@!",1,010,0))
oBrowseDown:SetColumns(MontaColunas("cArqGrd2->QUANTIDADE"	,"Quantidade"	      ,04,"@!",1,010,0))

	
oBrowseDown:SetAlias( 'cArqGrd2' ) 

oBrowseDown:SetMenuDef( '' ) 
oBrowseDown:SetProfileID( '2' ) 
oBrowseUp:ForceQuitButton() 

oBrowseDown:Activate() 

// Relacionamento entre os Paineis 
oRelacZA4:= FWBrwRelation():New() 
oRelacZA4:AddRelation( oBrowseUp , oBrowseDown , { { 'cArqGrd2->FILIAL', 'xFilial( "Z02" )' }, {'cArqGrd2->CODGRD','cArqGrd1->CODGRD'} }) 
//oRelacZA4:AddRelation( oBrowseUp , oBrowseDown , { { 'Z02_FILIAL', 'xFilial( "Z02" )' }, {'Z02_CODGRD','cArqGrd1->COD'} }) 
oRelacZA4:Activate() 


Activate MsDialog oDlgPrinc Center 

cArqGrd1->(DbCloseArea())
cArqGrd2->(DbCloseArea())

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
MenuDef - Avacy 
@author André Luiz Brito Silva
@since  25/07/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

//ADD OPTION aRotina Title 'Visualizar'  Action 'VIEWDEF.Avacy05' OPERATION 2 ACCESS 0
//ADD OPTION aRotina Title 'Gerar Relatório'     Action 'VIEWDEF.Avacy05' OPERATION 3 ACCESS 0
//ADD OPTION aRotina Title 'Alterar'     Action 'VIEWDEF.Avacy05' OPERATION 4 ACCESS 0
//ADD OPTION aRotina Title 'Excluir'     Action 'VIEWDEF.Avacy05' OPERATION 5 ACCESS 0
//ADD OPTION aRotina Title 'Gerar Prod.' Action 'U_GERPROD'         OPERATION 3 ACCESS 0
//ADD OPTION aRotina Title 'Imprimir'    Action 'VIEWDEF.Avacy05' OPERATION 8 ACCESS 0
//ADD OPTION aRotina Title 'Copiar'      Action 'VIEWDEF.Avacy05' OPERATION 9 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}MontaColunas
Monta colunas a serem exibidas em tela - Avacy 
@author André Luiz Brito Silva
@since  25/07/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData 	 := {||}
	
	Default nAlign 	 := 1
	Default nSize 	 := 20
	Default nDecimal := 0
	Default nArrData := 0
	
	
	
	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf
	
	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}

//-------------------------------------------------------------------
/*/{Protheus.doc}xDescPro
Busca descrição do produto - Avacy 
@author André Luiz Brito Silva
@since  25/07/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function xDescPro(cCod)

Local aArea     := GetArea() //Fiz backup

Default cCod      := ""

DbSelectArea("SB1")
If DbSeek(xFilial("SB1") + cCod)
	cCod := Alltrim(SB1->B1_DESC) + " " + Alltrim(SB1->B1_XMARCA)
Else
	Alert("Produto inexistente!")
EndIf

RestArea( aArea )//Restaurei backup

Return cCod

//-------------------------------------------------------------------
/*/{Protheus.doc}xDescPro
Busca descrição do produto - Avacy 
@author André Luiz Brito Silva
@since  25/07/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function xQtdGrd(cCodGrd, cProd )

Local aArea     := GetArea() 
Local cQuery    := ""
Local cTotCx    := GetNextAlias()
Local nQuanti   := 0
Local cQtd      := ""

Default cCodGrd    := ""
Default cProd      := ""

cQuery := "SELECT * FROM "
cQuery += RetSqlName("Z02") + "WHERE Z02_CODGRD = '" + cCodGrd + "' "
cQuery += "AND Z02_COD = '" + cProd + "' AND D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTotCx,.T.,.T.)

(cTotCx)->(dbGoTop())

Do While (cTotCx)->(!Eof())
	
	nQuanti += Val((cTotCx)->Z02_QTD)
	
	(cTotCx)->(DbSkip()) 
		
EndDo

cQtd := Alltrim(Str(nQuanti)) 

RestArea( aArea )

Return cQtd

//-------------------------------------------------------------------
/*/{Protheus.doc}xRetMod
Retorno o saldo de estoque do produto - Avacy 
@author André Luiz Brito Silva
@since  25/07/2019
@version 12
/*/
//-------------------------------------------------------------------

Static Function xRetMod(cProduto, cLote)

Local aArea     := GetArea() 
Local nRest     := 0

nRest := Mod(nSaldo, 2)

RestArea( aArea )

Return nRest


User Function AvcParamBox(aParametros,cTitle,aRet,bOk,aButtons,lCentered,nPosx,nPosy, oDlgWizard, cLoad, lCanSave,lUserSave)

Local nx
Local oDlg
Local cPath     := ""
Local oPanel
Local oPanelB
Local cTextSay
Local lOk			:= .F.
Local nLinha		:= 8
Local cArquivos := ""
Local nBottom
Local oFntVerdana
Local cOpcoes	:=	""
Local lWizard  := .F.
Local cBlkWhen2
Local nPos
Local cRotina
Local cAux
Local aOpcoes
Local cAlias
Local lServidor		:= .T.
Local cWhen	:= ""
Local cCodUsr := ""
Local lGrpAdm := .F.
Local loMainWnd := .F.
Local cFilAN7	:= xFilial("AN7")
Local c176 := "Selecione o Arquivo"
Local c175 := "Procurar"
Local c307 := "Grupo Administrador: Salvar configurações"
Local c308 := "Clique aqui para salvar as configuracöes de: "
Local c309 := "Grupo Administrador: Bloquear"
Local c310 := "Clique aqui para bloquear as configuracöes de: "
Local c311 := "Grupo Administrador: Desbloquear"
Local c312 := "Clique aqui para desbloquear as configuracöes de: "
Local c313 := "Bloqueio efetuado. Os parametros estaräo bloqueados a partir da proxima chamada."
Local c314 := "Desbloqueio efetuado. Os parametros estaräo desbloqueados a partir da proxima chamada."
Local c381 := "Editar"
Local c382 := "Range de "

DEFAULT bOk			:= {|| (.T.)}
DEFAULT aButtons	:= {}
DEFAULT lCentered	:= .T.
DEFAULT nPosX		:= 0
DEFAULT nPosY		:= 0
DEFAULT cLoad     := ProcName(1)
DEFAULT lCanSave	:= .T.
DEFAULT lUserSave	:= .F.
DEFAULT aButtons	:= {}

cRotina := PADR(cLoad,10)

If Type("cCadastro") == "U"
	cCadastro := ""
EndIf

If !lCanSave
	lUserSave	:= .F.
	cLoad := "99_NOSAVE_"
Else
	//Se nao esta bloqueado
	If ParamLoad(cLoad,aParametros,0,"1")== "2"
		lUserSave:= .F.
	//Se o usuario pode ter a sua propria configuracao
	ElseIf lUserSave
		cLoad	:=	__cUserID+"_"+cLoad
	Endif
Endif

DEFINE FONT oFntVerdana NAME "Verdana" SIZE 0, -10 BOLD

If oDlgWizard == NIL

	If Type("oMainWnd") == "U"
		DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+cTitle FROM nPosX,nPosY TO nPosX+300,nPosY+445 Pixel
		loMainWnd := .F.
	Else
		If IsInCallStack("Pms320Per") .OR. IsInCallStack("P320ExPer")
			DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+cTitle FROM nPosX,nPosY TO nPosX+300,nPosY+500 OF oMainWnd Pixel
		Else
			DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+cTitle FROM nPosX,nPosY TO nPosX+300,nPosY+445 OF oMainWnd Pixel
		EndIf
		loMainWnd := .T.
	EndIF
	lWizard := .F.
Else
	oDlg := oDlgWizard
	lWizard := .T.
EndIf

oPanel := TScrollBox():New( oDlg, 8,10,104,203)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

For nx := 1 to Len(aParametros)
	Do Case
		Case aParametros[nx,1]==1 // SAY + GET
			If ! lWizard
				SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
				&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx,3],Iif(Len(aParametros[nx])>9,aParametros[nx,10],.F.))
			EndIf
			if aParametros[nx,9] // Campo Obrigatorio
				cTextSay :="{||'<b>"+STRTRAN(aParametros[nx,2],"'",'"')+" ? "+ "<font color=red size=2 face=verdana,helvetica>*</font></b>"+"'}"
				TSay():New( nLinha, 15 , MontaBlock(cTextSay)  , oPanel , ,,,,,.T.,CLR_BLACK,,100,  ,,,,,,.T.)
			else
				cTextSay:= "{||'"+STRTRAN(aParametros[nx,2],"'",'"')+" ? "+"'}"
				TSay():New( nLinha, 15 , MontaBlock(cTextSay) , oPanel , ,,,,,.T.,CLR_BLACK,,100,,,,,,)
			endif	
			cWhen	:= Iif(Empty(aParametros[nx,7]),".T.",aParametros[nx,7])
			cValid	:=Iif(Empty(aParametros[nx,5]),".T.",aParametros[nx,5])
			cF3		:=Iif(Empty(aParametros[nx,6]),NIL,aParametros[nx,6])
			If ! lWizard
				cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			Else
				cBlkGet := "{ | u | If( PCount() == 0, "+"aRet["+AllTrim(STRZERO(nx,2,0))+"],"+"aRet["+AllTrim(STRZERO(nx,2,0))+"] := "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			EndIf
			cBlKVld := "{|| "+cValid+"}"
			cBlKWhen := "{|| "+cWhen+"}"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			//*****************************************************
			// Auto Ajusta da Get para Campos Caracter e Numerico *
			// Somente para o Modulo PCO - Acacio Egas            *
			//*****************************************************
			If Type("cModulo")=="C" .and. cModulo=="PCO" .and. !lWizard
				cType := Type("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
				If cType $ "C"
					nWidth	:= CalcFieldSize(cType,Len(aParametros[nx,3]),,aParametros[nx,4],"") + 10 + If(!Empty(cF3),10,0)
				ElseIf cType $ "N"
					nWidth	:= CalcFieldSize(cType,,,aParametros[nx,4],"") + 10
				Else
					nWidth	:= aParametros[nx,8]
				EndIf
			Else
				nWidth	:= aParametros[nx,8]
			EndIf
			// 'If' para corrigir um problema do campo get quando possui F3 (Lupa) em um panel do wizard. Quando campo menor que 50, a lupa some.
			If lWizard
				IF Type("nWidth")<> "U"
					TGet():New( nLinha,100,&cBlKGet,oPanel,If(nWidth<30,30,nWidth),,aParametros[nx,4], &(cBlkVld),,,, .T.,, .T.,, .T., &(cBlkWhen), .F., .F.,, .F., .F. ,cF3,"MV_PAR"+AllTrim(STRZERO(nx,2,0)),,,,.T.)
				Else
					cType := ValType(aRet[nx])
					nWidth := ParBGetSize(cType,aParametros,cF3,nx)
					TGet():New( nLinha,100,&cBlKGet,oPanel,nWidth,,aParametros[nx,4], &(cBlkVld),,,, .T.,, .T.,, .T., &(cBlkWhen), .F., .F.,, .F., .F. ,cF3,"MV_PAR"+AllTrim(STRZERO(nx,2,0)),,,,.T.)
				Endif
			Else
				TGet():New( nLinha,100,&cBlKGet,oPanel,nWidth,,aParametros[nx,4], &(cBlkVld),,,, .T.,, .T.,, .T., &(cBlkWhen), .F., .F.,, .F., .F. ,cF3,"MV_PAR"+AllTrim(STRZERO(nx,2,0)),,,,.T.)
			Endif
		Case aParametros[nx,1]==2 // SAY + COMBO
			If ! lWizard
				SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
				&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx,3])
			EndIf
			
    		if aParametros[nx,7] // Campo Obrigatorio
				cTextSay :="{||'<b>"+STRTRAN(aParametros[nx,2],"'",'"')+" ? "+ "<font color=red size=2 face=verdana,helvetica>*</font></b>"+"'}"
				TSay():New( nLinha, 15 , MontaBlock(cTextSay)  , oPanel , ,,,,,.T.,CLR_BLACK,,100,  ,,,,,,.T.)
			else
				cTextSay:= "{||'"+STRTRAN(aParametros[nx,2],"'",'"')+" ? "+"'}"
				TSay():New( nLinha, 15 , MontaBlock(cTextSay) , oPanel , ,,,,,.T.,CLR_BLACK,,100,,,,,,)
			endif	
			
			cWhen   := ".T."
			If Len(aParametros[nx]) > 7
				If aParametros[nx,8] != NIL .And. ValType(aParametros[nx,8])=="L"
					cWhen	:=If(aParametros[nx,8],".T.",".F.")
				Else
					cWhen	:= Iif(Len(aParametros[nx]) < 8 .Or. Empty(aParametros[nx,8]) .Or. aParametros[nx,8] == Nil,".T.",aParametros[nx,8])
				EndIf
			EndIf
			cValid	:=Iif(Empty(aParametros[nx,6]),".T.",aParametros[nx,6])
			cBlKVld := "{|| "+cValid+"}"
			If ! lWizard
				cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
         Else
				cBlkGet := "{ | u | If( PCount() == 0, "+"aRet["+AllTrim(STRZERO(nx,2,0))+"],"+"aRet["+AllTrim(STRZERO(nx,2,0))+"] := "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			EndIf
			cBlkWhen := "{|| "+cWhen+" }"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			TComboBox():New( nLinha,100, &cBlkGet,aParametros[nx,4], aParametros[nx,5], 10, oPanel, ,,       ,,,.T.,,,.F.,&(cBlkWhen),.T.,,,,"MV_PAR"+AllTrim(STRZERO(nx,2,0)))

		Case aParametros[nx,1]==3 // SAY + RADIO
			nLinha += 8
			If ! lWizard
				SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
				&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx,3])
			EndIf
			cTextSay:= "{||'"+aParametros[nx,2]+" ? "+"'}"
			TGroup():New( nLinha-8,15, nLinha+(Len(aParametros[nx,4])*9)+7,205,aParametros[nx,2]+ " ? ",oPanel,If(aParametros[nx,7],CLR_HBLUE,CLR_BLACK),,.T.)
			cWhen   := ".T."
			If Len(aParametros[nx]) > 7
				If aParametros[nx,8] != NIL .And. ValType(aParametros[nx,8])=="L"
					cWhen	:=If(aParametros[nx,8],".T.",".F.")
				Else
					cWhen	:= Iif(Len(aParametros[nx]) < 8 .Or. Empty(aParametros[nx,8]) .Or. aParametros[nx,8] == Nil,".T.",aParametros[nx,8])
				EndIf
			EndIf
			If ! lWizard
				cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
            Else
				cBlkGet := "{ | u | If( PCount() == 0, "+"aRet["+AllTrim(STRZERO(nx,2,0))+"],"+"aRet["+AllTrim(STRZERO(nx,2,0))+"] := "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			EndIf
			cBlkWhen := "{|| " + cWhen  +  "}"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			TRadMenu():New( nLinha, 30, aParametros[nx,4],&cBlkGet, oPanel,,,,,,,&(cBlkWhen),aParametros[nx,5],9, ,,,.T.)
			nLinha += (Len(aParametros[nx,4])*10)-3

		Case aParametros[nx,1]==4 // SAY + CheckBox
			If ! lWizard
				SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
				&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx,3])
			EndIf
			
			If ! lWizard
				cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			Else
				cBlkGet := "{ | u | If( PCount() == 0, "+"aRet["+AllTrim(STRZERO(nx,2,0))+"],"+"aRet["+AllTrim(STRZERO(nx,2,0))+"] := "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			EndIf
			if aParametros[nx,7] // Campo Obrigatorio
				cTextSay :="{||'<b>"+STRTRAN(aParametros[nx,2],"'",'"')+"  "+ "<font color=red size=2 face=verdana,helvetica>*</font></b>"+"'}"
				TSay():New( nLinha, 15 , MontaBlock(cTextSay)  , oPanel , ,,,,,.T.,CLR_BLACK,,100,  ,,,,,,.T.)
			else
				cTextSay:= "{||'"+STRTRAN(aParametros[nx,2],"'",'"')+"  "+"'}"
				TSay():New( nLinha, 15 , MontaBlock(cTextSay) , oPanel , ,,,,,.T.,CLR_BLACK,,100,,,,,,)
			endif	
			cBlkWhen := Iif(Len(aParametros[nx]) > 7 .And. !Empty(aParametros[nx,8]),aParametros[nx,8],"{|| .T. }")
			If (Len(aParametros[nx]) > 6 .And. aParametros[nx,7]).Or. ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			TCheckBox():New(nLinha,100,aParametros[nx,4], &cBlkGet,oPanel, aParametros[nx,5],10,,,,,,,,.T.,,,&(cBlkWhen))

		Case aParametros[nx,1]==5 // CheckBox Linha Inteira
			If ! lWizard
				SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
				&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx,3])
			EndIf
			If ! lWizard
				cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
            Else
				cBlkGet := "{ | u | If( PCount() == 0, "+"aRet["+AllTrim(STRZERO(nx,2,0))+"],"+"aRet["+AllTrim(STRZERO(nx,2,0))+"] := "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			EndIf
			cBlkWhen := "{|| .T. }"
			If (Len(aParametros[nx]) > 6 .And. aParametros[nx,7]) .Or. ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			TCheckBox():New(nLinha,15,aParametros[nx,2], &cBlkGet,oPanel, aParametros[nx,4],10,,,,,,,,.T.,,,&(cBlkWhen))

		Case aParametros[nx,1]==6 // File + Procura de Arquivo
			If ! lWizard
				SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
				&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx,3])
			EndIf
			
			if aParametros[nx,8] // Campo Obrigatorio
				cTextSay :="{||'<b>"+STRTRAN(aParametros[nx,2],"'",'"')+" ? "+ "<font color=red size=2 face=verdana,helvetica>*</font></b>"+"'}"
				TSay():New( nLinha, 15 , MontaBlock(cTextSay)  , oPanel , ,,,,,.T.,CLR_BLACK,,100,  ,,,,,,.T.)
			else
				cTextSay:= "{||'"+STRTRAN(aParametros[nx,2],"'",'"')+" ? "+"'}"
				TSay():New( nLinha, 15 , MontaBlock(cTextSay) , oPanel , ,,,,,.T.,CLR_BLACK,,100,,,,,,)
			endif	
			
			cWhen	    := Iif(Empty(aParametros[nx,6]),".T.",aParametros[nx,6])
			cValid	  := Iif(Empty(aParametros[nx,5]),".T.","("+aParametros[nx,5]+").Or.Vazio("+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+")")
			If ! lWizard
				cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
            Else
				cBlkGet := "{ | u | If( PCount() == 0, "+"aRet["+AllTrim(STRZERO(nx,2,0))+"],"+"aRet["+AllTrim(STRZERO(nx,2,0))+"] := "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			EndIf
			cBlKVld   := "{|| " + cValid + "}"
			cBlKWhen  := "{|| " + cWhen + "}"
			cArquivos := aParametros[nx,9]

			If Len(aParametros[nx]) >= 10
				cPath := aParametros[nx,10]
			EndIf

			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf

			If Len(aParametros[nX]) >= 11
				cOpcoes := AllTrim(Str(aParametros[nx,11]))
			Else
				cOpcoes := AllTrim(Str(GETF_LOCALHARD+GETF_LOCALFLOPPY))
			Endif

			If Len(aParametros[nX]) >= 12
				lServidor := aParametros[nx,12]
			Else
				lServidor := .T.
			Endif

			If lWizard
            cGetfile := "{|| aRet["+AllTrim(STRZERO(nx,2,0))+"] := MV_PAR"+AllTrim(STRZERO(nx,2,0))+" := cGetFile(cArquivos,'"+;
						c176+"',0,cPath,.T.,"+cOpcoes+;
			            ",lServidor)+SPACE(40), If(Empty(MV_PAR"+AllTrim(STRZERO(nx,2,0))+;
            			"), MV_PAR"+AllTrim(STRZERO(nx,2,0))+" := '"+;
		               aParametros[nx,3]+"',)  }"
		 	Else
				cGetfile := "{|| MV_PAR"+AllTrim(STRZERO(nx,2,0))+" := cGetFile(cArquivos,'"+;
									c176+"',0,cPath,.T.,"+cOpcoes+;
									",lServidor)+SPACE(40), If(Empty(MV_PAR"+AllTrim(STRZERO(nx,2,0))+;
									"), MV_PAR"+AllTrim(STRZERO(nx,2,0))+" := '"+;
									aParametros[nx,3]+"',)  }"
			EndIf

			TGet():New( nLinha,100 ,&cBlKGet,oPanel,aParametros[nx,7],,aParametros[nx,4], &(cBlkVld),,,, .T.,, .T.,, .T., &(cBlkWhen), .F., .F.,, .F., .F. ,,"MV_PAR"+AllTrim(STRZERO(nx,2,0)))
			TButton():New( nLinha,100+aParametros[nx,7], c175, oPanel,&(cGetFile), 29, 12, , oDlg:oFont, ,.T.,.F.,,.T., ,, .F.)

		Case aParametros[nx,1]==7 //.And. ! lWizard// Filtro de Arquivos
			nLinha += 8
			If !lWizard
				SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
				&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx,4])
				SetPrvt("MV_FIL"+AllTrim(STRZERO(nx,2,0)))
				&("MV_FIL"+AllTrim(STRZERO(nx,2,0))) := MontDescr(aParametros[nx,3],ParamLoad(cLoad,aParametros,nx,aParametros[nx,4]))
			EndIf
			TGroup():New( nLinha-8,15, nLinha+40,170,aParametros[nx,2]+ " ? ",oPanel,,,.T.)
			cWhen   := ".T."
			If Len(aParametros[nx]) > 4
				If aParametros[nx,5] != NIL .And. ValType(aParametros[nx,5])=="L"
					cWhen	:=If(aParametros[nx,5],".T.",".F.")
				Else
					cWhen	:= Iif(Len(aParametros[nx]) < 5 .Or. Empty(aParametros[nx,5]) .Or. aParametros[nx,5] == Nil,".T.",aParametros[nx,5])
				EndIf
			EndIf
			cValid	:=".T."
			If !lWizard
				cBlkGet := "{ | u | If( PCount() == 0, "+"MV_FIL"+AllTrim(STRZERO(nx,2,0))+","+"MV_FIL"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			Else
				cBlkGet := "{ | u | If( PCount() == 0, MontDescr('"+aParametros[nx,3]+"',aRet["+AllTrim(STRZERO(nx,2,0))+"]),"+;
																	" MV_FIL"+AllTrim(STRZERO(nx,2,0))+":= u ) }"

			EndIf
			cBlKVld := "{|| "+cValid+"}"
			cBlKWhen := "{|| "+cWhen+"}"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			If !lWizard
				cGetFilter := "{|| MV_PAR"+AllTrim(STRZERO(nx,2,0))+" := BuildExpr('"+aParametros[nx,3]+"',,MV_PAR"+AllTrim(STRZERO(nx,2,0))+"),MV_FIL"+AllTrim(STRZERO(nx,2,0))+":=MontDescr('"+aParametros[nx,3]+"',MV_PAR"+AllTrim(STRZERO(nx,2,0))+") }"
			Else
				cGetFilter := "{|| aRet["+AllTrim(STRZERO(nx,2,0))+"] := MV_PAR"+AllTrim(STRZERO(nx,2,0))+" := BuildExpr('"+aParametros[nx,3]+"',,aRet["+AllTrim(STRZERO(nx,2,0))+"]),MV_FIL"+AllTrim(STRZERO(nx,2,0))+":=MontDescr('"+aParametros[nx,3]+"',aRet["+AllTrim(STRZERO(nx,2,0))+"]) }"
			EndIf
			TButton():New( nLinha,18, "Editar", oPanel,&(cGetFilter), 35, 14, , oDlg:oFont, ,.T.,.F.,,.T.,&(cBlkWhen),, .F.)
			TMultiGet():New( nLinha, 55, &cBlKGet,oPanel,109,33,,,,,,.T.,,.T.,&(cBlkWhen),,,.T.,&(cBlkVld),,.T.,.F., )
			nLinha += 31
		Case aParametros[nx,1]==8 // SAY + GET PASSWORD
			If ! lWizard
				SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
				&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx,3])
			EndIf
			if aParametros[nx,9] // Campo Obrigatorio
				cTextSay :="{||'<b>"+STRTRAN(aParametros[nx,2],"'",'"')+" ? "+ "<font color=red size=2 face=verdana,helvetica>*</font></b>"+"'}"
				TSay():New( nLinha, 15 , MontaBlock(cTextSay)  , oPanel , ,,,,,.T.,CLR_BLACK,,100,  ,,,,,,.T.)
			else
				cTextSay:= "{||'"+STRTRAN(aParametros[nx,2],"'",'"')+" ? "+"'}"
				TSay():New( nLinha, 15 , MontaBlock(cTextSay) , oPanel , ,,,,,.T.,CLR_BLACK,,100,,,,,,)
			endif	
			
			cWhen	:= Iif(Empty(aParametros[nx,7]),".T.",aParametros[nx,7])
			cValid	:=Iif(Empty(aParametros[nx,5]),".T.",aParametros[nx,5])
			cF3		:=Iif(Empty(aParametros[nx,6]),NIL,aParametros[nx,6])
			If ! lWizard
				cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
            Else
				cBlkGet := "{ | u | If( PCount() == 0, "+"aRet["+AllTrim(STRZERO(nx,2,0))+"],"+"aRet["+AllTrim(STRZERO(nx,2,0))+"] := "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			EndIf
			cBlKVld := "{|| "+cValid+"}"
			cBlKWhen := "{|| "+cWhen+"}"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			TGet():New( nLinha,100 ,&cBlKGet,oPanel,aParametros[nx,8],,aParametros[nx,4], &(cBlkVld),,,, .T.,, .T.,, .T., &(cBlkWhen), .F., .F.,, .F., .T. ,cF3,"MV_PAR"+AllTrim(STRZERO(nx,2,0)),,,,.T.)
		Case aParametros[nx,1]==9 // SAY
            cTextSay:= "{||'"+STRTRAN(aParametros[nx,2],"'",'"')+"'}"
			If aParametros[nx,5]
				TSay():New( nLinha, 15 , MontaBlock(cTextSay) , oPanel , ,oFntVerdana,,,,.T.,CLR_BLACK,,aParametros[nx,3],aParametros[nx,4],,,,,)
			Else
				TSay():New( nLinha, 15 , MontaBlock(cTextSay) , oPanel , ,,,,,.T.,CLR_BLACK,,aParametros[nx,3],aParametros[nx,4],,,,,)
			EndIf
		Case aParametros[nx,1]==10 // Range (fase experimental)
			nLinha += 8
			SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
			&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx,3])
			SetPrvt("MV_RAN"+AllTrim(STRZERO(nx,2,0)))
			&("MV_RAN"+AllTrim(STRZERO(nx,2,0))) := PMSRangeDesc(	&("MV_PAR"+AllTrim(STRZERO(nx,2,0))),aParametros[nx,7])
			TGroup():New( nLinha-8,15, nLinha+40,170,c382+aParametros[nx,2],oPanel,,,.T.)		//"Range de "
			If Type(aParametros[nx,8])=="L" .And. !Empty(aParametros[nx,8])
				cWhen	:= aParametros[nx,8]
			Else
				cWhen	:= ".T."
			EndIf
			cValid	:=".T."
			cBlkGet := "{ | u | If( PCount() == 0, "+"MV_RAN"+AllTrim(STRZERO(nx,2,0))+","+"MV_RAN"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			cBlKWhen := "{|| "+cWhen+"}"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			cGetRange := "{|| MV_PAR"+AllTrim(STRZERO(nx,2,0))+" := PmsRange('"+aParametros[nx,2]+"','"+aParametros[nx,4]+"',"+Str(aParametros[nx,5])+",MV_PAR"+AllTrim(STRZERO(nx,2,0))+",'"+aParametros[nx,6]+"',"+Str(aParametros[nx,7])+"),	MV_RAN"+AllTrim(STRZERO(nx,2,0))+" := PMSRangeDesc( MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+Str(aParametros[nx,7])+") }"
	   		TButton():New( nLinha-2,18, c381, oPanel,MontaBlock(cGetRange), 35, 14, , oDlg:oFont, ,.T.,.F.,,.T.,&(cBlkWhen),, .F.) //"Editar"
			TMultiGet():New( nLinha, 55, &cBlKGet,oPanel,109,33,,,,,,.T.,,.T.,&(cBlkWhen),,,.T.,/*&(cBlkVld)*/,,.T.,.F., )
			nLinha += 31
		Case aParametros[nx,1]==11 // MULTIGET - campo memo
			nLinha += 10
			SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
			&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx,3])
			TGroup():New( nLinha-8,15, nLinha+40,170,"",oPanel,,,.T.)
			if aParametros[nx,6] // Campo Obrigatorio
				cTextSay :="{||'<b>"+STRTRAN(aParametros[nx,2],"'",'"')+" ? "+ "<font color=red size=2 face=verdana,helvetica>*</font></b>"+"'}"
				TSay():New( nLinha - 6, 23 , MontaBlock(cTextSay)  , oPanel , ,,,,,.T.,CLR_BLACK,,100,  ,,,,,,.T.)
			else
				cTextSay:= "{||'"+STRTRAN(aParametros[nx,2],"'",'"')+" ? "+"'}"
				TSay():New( nLinha - 6, 23 , MontaBlock(cTextSay) , oPanel , ,,,,,.T.,CLR_BLACK,,100,,,,,,)
			endif	
			
			cValid := Iif(Empty(aParametros[nx,4]),".T.",aParametros[nx,4])
			cWhen  := Iif(Empty(aParametros[nx,5]),".T.",aParametros[nx,5])
			cBlkGet  := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
			cBlkVld  := "{|| " + cValid + "}"
			cBlkWhen := "{|| " + cWhen + "}"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			Endif
			TMultiGet():New(nLinha+1,23,&cBlkGet,oPanel,140,33,/*oFont*/,/*lHScroll*/,/*nClrFore*/,/*nClrBack*/,/*oCursor*/,.T.,/*cMg*/,;
			.T.,&(cBlkWhen),/*lCenter*/,/*lRight*/,.F.,&(cBlkVld),/*bChange*/,.T.,.F.)
			nLinha += 31
		Case aParametros[nx,1]==12 // FILTROS DE USUARIO POR ROTINA
			nLinha += 8
			SetPrvt("MV_FIL"+AllTrim(STRZERO(nx,2,0)))
			If len(aParametros[nx])>3
				&("MV_FIL"+AllTrim(STRZERO(nx,2,0))) := ParamLoad(cLoad,aParametros,nx,aParametros[nx,4])
			Else
				&("MV_FIL"+AllTrim(STRZERO(nx,2,0))) := ""
			EndIf
			SetPrvt("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
			&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := ""
			cTextSay := ""
			If Len(aParametros[nx]) > 1
				If aParametros[nx,2] != Nil .And. ValType(aParametros[nx,2])=="C"
					cTextSay := aParametros[nx,2]
				EndIf
			Else
				AADD(aParametros[nx], "")
			EndIf
			cAlias := ""
			If Len(aParametros[nx]) > 2
				If aParametros[nx,3] != Nil .And. ValType(aParametros[nx,3])=="C"
					cAlias	:= aParametros[nx,3]
				EndIf
			Else
				AADD(aParametros[nx], "")
			EndIf
			If empty(cAlias)
				If PcoX2ConPad(cAlias)
					cAlias := PcoSX2Cons()
				Else
					cAlias := ALIAS()
				EndIf
			EndIf
			If empty(aParametros[nx,3])
				aParametros[nx,3] := cAlias
			EndIf
			cWhen   := ".T."
			If Len(aParametros[nx]) > 4
				If aParametros[nx,5] != Nil .And. ValType(aParametros[nx,5])=="L"
					cWhen	:= If(aParametros[nx,5],".T.",".F.")
				EndIf
			EndIf
			cBlkWhen := "{|| "+cWhen+" }"
			If ParamLoad(cLoad,aParametros,0,"1")=="2"
				cBlKWhen := "{|| .F. }"
			EndIf
			aOpcoes := {"Visualizar todos os registros"}
			cBlkWhen2:=cBlKWhen
			dbSelectArea("AN7")
			AN7->(dbSetOrder(1))
			AN7->(MsSeek(cFilAN7+oApp:cUserID+cRotina+cAlias))
			Do While !AN7->(Eof()) .And. AN7->(AN7_FILIAL+AN7_USER+AN7_FUNCAO+AN7_ALIAS)==cFilAN7+oApp:cUserID+cRotina+cAlias
				AADD(aOpcoes, AN7->AN7_FILTR)
				AN7->(dbSkip())
			EndDo
			TGroup():New( nLinha-8,15, nLinha+20,170, cTextSay,oPanel,,,.T.)
			cBlKVld := "{|| .T.}"
			cBlkGet := "{ | u | If( PCount() == 0, MV_FIL"+AllTrim(STRZERO(nx,2,0))+", MV_FIL"+AllTrim(STRZERO(nx,2,0))+":= u) }"
			SetPrvt("oCombo"+AllTrim(STRZERO(nx,2,0)))
			&("oCombo"+AllTrim(STRZERO(nx,2,0))) := TComboBox():New( nLinha+4, 20, &cBlkGet, aOpcoes, 100, 10, oPanel,,,,,,.T.,,,.F.,&(cBlkWhen),.T.,,,,"MV_FIL"+AllTrim(STRZERO(nx,2,0)))

			cAux := "{|| MV_PAR"+AllTrim(STRZERO(nx,2,0))+" := PmsGetFilt( oApp:cUserID, cRotina, '"+cAlias+"', MV_FIL"+AllTrim(STRZERO(nx,2,0))+" )}"
	   		TBtnBmp2():New( (nLinha+4)*2, 120*2, 25, 25, "FILTRO1"  , , , , &cAux , oPanel, "Aplicar filtro selecionado", &(cBlkWhen), )
			cAux := "{|| PmsIncFilt( aParametros, oApp:cUserID, cRotina, '"+cAlias+"' )}"
	   		TBtnBmp2():New( (nLinha+4)*2, 132*2, 25, 25, "BPMSDOCI" , , , , &cAux , oPanel, "Novo filtro", &(cBlkWhen2), )
			cAux := "{|| PmsAltFilt( aParametros, oCombo"+AllTrim(STRZERO(nx,2,0))+":nAt, oApp:cUserID, cRotina, '"+cAlias+"', MV_FIL"+AllTrim(STRZERO(nx,2,0))+" )}"
	   		TBtnBmp2():New( (nLinha+4)*2, 144*2, 25, 25, "BPMSDOCA" , , , , &cAux , oPanel, "Editar filtro selecionado", &(cBlkWhen2), )
			cAux := "{|| PmsExcFilt( aParametros, oCombo"+AllTrim(STRZERO(nx,2,0))+":nAt, oApp:cUserID, cRotina, '"+cAlias+"', MV_FIL"+AllTrim(STRZERO(nx,2,0))+" )}"
	   		TBtnBmp2():New( (nLinha+4)*2, 156*2, 25, 25, "BPMSDOCE" , , , , &cAux , oPanel, "Excluir o filtro selecionado", &(cBlkWhen2), )
			nLinha += 11
    EndCase
	nLinha += 17
Next


lGrpAdm := .F.
cCodUsr := RetCodUsr()
If !Empty(cCodUsr)
	lGrpAdm := PswAdmin( /*cUser*/, /*cPsw*/,cCodUsr)==0
EndIf

If !lWizard .And.  lGrpAdm .And. lCanSave
	@ nlinha+8,10 BUTTON oButton PROMPT "+" SIZE 10 ,7   ACTION {|| ParamSave(cLoad,aParametros,"1") } OF oPanel PIXEL
	@ nlinha+8,22 SAY c307 SIZE 120,7 Of oPanel FONT oFntVerdana COLOR RGB(80,80,80) PIXEL //"Administrador: Salvar configuações"
	oButton:cToolTip := c308 + cTitle //"Clique aqui para salvar as configurações de: "

	@ nlinha+15,10 BUTTON oButton PROMPT "+" SIZE 10 ,7   ACTION {|| ParamSave(cLoad,aParametros,"2"),Alert(c313) } OF oPanel PIXEL  //"Bloqueio efetuado. Os parametros estarão bloqueados a partir da próxima chamada."
	@ nlinha+15,22 SAY c309 SIZE 120,7 Of oPanel FONT oFntVerdana COLOR RGB(80,80,80) PIXEL //"Administrador: Bloquear"
	oButton:cToolTip := c310 + cTitle //"Clique aqui para bloquear as configurações de: "

	@ nlinha+22,10 BUTTON oButton PROMPT "+" SIZE 10 ,7   ACTION {|| ParamSave(cLoad,aParametros,"1"),Alert(c314)  } OF oPanel PIXEL  //"Desbloqueio efetuado. Os parametros estarão desbloqueados a partir da próxima chamada."
	@ nlinha+22,22 SAY c311 SIZE 120,7 Of oPanel FONT oFntVerdana COLOR RGB(80,80,80) PIXEL //"Administrador: Desbloquear"
	oButton:cToolTip := c312 + cTitle //"Clique aqui para desbloquear as configurações de: "
EndIf

If loMainWnd
	oMainWnd:CoorsUpdate()
EndIf

If ! lWizard
	oPanelB := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,40,20,.T.,.T. )
	oPanelB:Align := CONTROL_ALIGN_BOTTOM

	For nx := 1 to Len(aButtons)
		SButton():New( 4, 157-(nx*33), aButtons[nx,1],aButtons[nx,2],oPanelB,.T.,IIf(Len(aButtons[nx])==3,aButtons[nx,3],Nil),)
	Next
	//DEFINE SBUTTON FROM 4, 114   TYPE 4 ENABLE OF oDlg ACTION ParamSave(cLoad,aParametros)
	DEFINE SBUTTON FROM 4, 157   TYPE 4 ENABLE OF oPanelB ACTION (If(ParamOk(aParametros,@aRet).And.Eval(bOk),(oDlg:End(),lOk:=.T.),(lOk:=.F.)))
	DEFINE SBUTTON FROM 4, 190   TYPE 1 ENABLE OF oPanelB ACTION (lOk:=.F.,oDlg:End())
	
	If loMainWnd .AND. (nLinha*2) + 80 > oMainWnd:nBottom-oMainWnd:nTop
		nBottom  := oDLg:nTop + oMAinWnd:nBottom-oMAinWnd:nTop - 105
	Else
		nBottom := oDLg:nTop + (nLinha*2) + 80
	EndIf
	nBottom := MAX(310,nBottom)
	oDlg:nBottom := nBottom
EndIf
If ! lWizard
	ACTIVATE MSDIALOG oDlg CENTERED
	If lOk .And. lUserSave
		ParamSave(cLoad,aParametros,"1")
	Endif
EndIf
Return lOk