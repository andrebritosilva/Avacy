#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} Avacy04
Consulta Estoque Produtos x Grade

@author Andr� Brito
@since 18/07/2019
@version P12
/*/
//-------------------------------------------------------------------

User Function Avacy04()

	Local aArea    := GetArea()
	Local oDlg
	Local oRadio
	Local nRadio   := 1
	Local nOpca    := 1

	While nOpca == 1

		DEFINE MSDIALOG oDlg FROM  94,1 TO 300,293 TITLE "Painel de Consulta Estoque - Avacy Cal�ados" PIXEL 

		@ 05,17 Say "Consulta estoque por: " SIZE 150,7 OF oDlg PIXEL  

		@ 17,07 TO 82, 140 OF oDlg  PIXEL

		@ 25,10 Radio 	oRadio VAR nRadio;
		ITEMS 	"Produto",;
		SIZE 110,10 OF oDlg PIXEL

		DEFINE SBUTTON FROM 85,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
		//DEFINE SBUTTON FROM 85,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
		//DEFINE SBUTTON FROM 85,145 TYPE 3 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso
		//	para saida com ESC

		If nOpca == 1
			If nRadio == 1
				XCONPRO()//Consulta por produto
			//ElseIf nRadio == 2
				//XCNGT14()//Consulta por GTIN14	
			EndIf
		EndIf

	EndDo

	RestArea(aArea)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} XCONPRO
Consulta por produto

@author Andr� Brito
@since 18/07/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function XCONPRO()

	Local aArea     := GetArea() 
	Local aPWiz     := {}
	Local aRetWiz   := {}
	Local cProdDe   := ""
	Local cProdAte  := ""
	Local nOpt      := 1
	Local aCopy     := aClone(aRotina)
	
	aRotina := {}
	
	aAdd(aPWiz,{ 1,"Produto: "  ,Space(15) ,"","","SB1","", ,.T.})
	
	aAdd(aRetWiz,Space(15))

	ParamBox(aPWiz,"Consulta Estoque por Produto",@aRetWiz,,,,,,,,.T.,.T.) 
	
	cProdDe   := Alltrim(aRetWiz[1])

	U_Avacy05(cProdDe, , , nOpt)
	
	aRotina := aClone(aCopy)
	
	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XCNGT13
Consulta por c�digo GTIN13

@author Andr� Brito
@since 18/07/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function XCNGT13()

	Local aArea     := GetArea()
	Local aPWiz     := {}
	Local aRetWiz   := {} 
	Local cGtin13   := ""
	Local nOpt      := 2
	
	aAdd(aPWiz,{ 1,"Digite o c�digo GTIN13: "  ,Space(13) ,"","","","", ,.T.})
	
	aAdd(aRetWiz,Space(13))

	ParamBox(aPWiz,"Consulta Estoque por C�digo GTIN13",@aRetWiz,,,,,,,,.T.,.T.) 
	
	cGtin13   := Alltrim(aRetWiz[1])
	
	U_Avacy05(, cGtin13, , nOpt)

	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XCNGT14
Consulta por c�digo GTIN14

@author Andr� Brito
@since 18/07/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function XCNGT14()

	Local aArea     := GetArea() 
	Local aPWiz     := {}
	Local aRetWiz   := {}
	Local cGtin14   := ""
	Local nOpt      := 3

	aAdd(aPWiz,{ 1,"Digite o c�digo GTIN14: "  ,Space(14) ,"","","","", ,.T.})
	
	aAdd(aRetWiz,Space(14))

	ParamBox(aPWiz,"Consulta Estoque por C�digo GTIN14",@aRetWiz,,,,,,,,.T.,.T.) 
	
	cGtin14   := Alltrim(aRetWiz[1])
	
	U_Avacy05(,, cGtin14, nOpt)

	RestArea(aArea)

Return