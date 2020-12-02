#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³M460FIM   º                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para gravar a Forma de Pagamento na SE1   º±±
±±º          ³ e Imprimir Boleto Laser			                          º±±        
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Acelerador                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  
*/

User Function M460FIM()

	Local aArea	:= GetArea()
	Local aSCV := SCV->( GetArea() )
	Local aSEA := SEA->( GetArea() )
	Local aSE1 := SE1->( GetArea() )
	Local aSF2 := SF2->( GetArea() )
	Local aSD2 := SD2->( GetArea() )
	Local aDAK := DAK->( GetArea() )
	Local aDAI := DAI->( GetArea() )
	Local aDAJ := DAJ->( GetArea() )
	Local aSA1 := SA1->( GetArea() )
	Local aSC5 := SC5->( GetArea() )
	Local aSC6 := SC6->( GetArea() )
	Local aSC9 := SC9->( GetArea() )
	Local aDCF := DCF->( GetArea() )
	Local aDAU := DAU->( GetArea() )
	Local aDA3 := DA3->( GetArea() )
	Local aDA4 := DA4->( GetArea() )
	Local aDB0 := DB0->( GetArea() )
	Local aDA5 := DA5->( GetArea() )
	Local aDA6 := DA6->( GetArea() )
	Local aDA7 := DA7->( GetArea() )
	Local aDA8 := DA8->( GetArea() )
	Local aDA9 := DA9->( GetArea() )
	Local aSB1 := SB1->( GetArea() )
	Local aSB2 := SB1->( GetArea() )
	Local aSB6 := SB1->( GetArea() )
	Local aSC9 := SB1->( GetArea() )
	Local aSED := SB1->( GetArea() )
	Local aSEE := SB1->( GetArea() )
	Local aSA6 := SB1->( GetArea() )
	Local aSX5 := SX5->( GetArea() )
	Local aMVs := { M->MV_PAR01, M->MV_PAR02, M->MV_PAR03, M->MV_PAR04, M->MV_PAR05, M->MV_PAR06,;
	M->MV_PAR07, M->MV_PAR08, M->MV_PAR09, M->MV_PAR10, M->MV_PAR11, M->MV_PAR12,;
	M->MV_PAR13, M->MV_PAR14, M->MV_PAR15, M->MV_PAR16, M->MV_PAR17, M->MV_PAR18,;
	M->MV_PAR19, M->MV_PAR20, M->MV_PAR21, M->MV_PAR22, M->MV_PAR23, M->MV_PAR24,;
	M->MV_PAR25 }
	Local nWorkArea := Select()  
	Local _aVencto := {}
	Local _nValTitulos := 0
	Local _nValTitST   := 0
	Local _dNovaData  := ''   //calcula a data do vencimento do ICMS
	//Local cEstTilImp  := AllTrim(GetMV("MV_XUFTIST"))
	//Local cPrxTilImp  := AllTrim(GetMV("MV_XPRTIST"))
	Local  _aDados  := {} 

	Local cMV_1DUPREF := &(GetMV("MV_1DUPREF") )

	If SE4->E4_FORMA=='BOL   '
		U_AFINP001()  //chamada do Acelerador 
	Else
		Aviso("Aviso","Não foi gerado boleto esse documento!",{"Ok"})
	Endif
	
	RestArea(aSEA)
	RestArea(aSCV )
	RestArea(aSE1 )
	RestArea(aSF2 )
	RestArea(aSD2 )
	RestArea(aDAK )
	RestArea(aDAI )
	RestArea(aDAJ )
	RestArea(aSA1 )
	RestArea(aSC5 )
	RestArea(aSC6 )
	RestArea(aSC9 )
	RestArea(aDCF )
	RestArea(aDAU )
	RestArea(aDA3 )
	RestArea(aDA4 )
	RestArea(aDB0 )
	RestArea(aDA5 )
	RestArea(aDA6 )
	RestArea(aDA7 )
	RestArea(aDA8 )
	RestArea(aDA9 )
	RestArea(aSB1 )
	RestArea(aSB2 )
	RestArea(aSB6 )
	RestArea(aSC9 )
	RestArea(aSED )
	RestArea(aSEE )
	RestArea(aSA6 )
	RestArea(aSX5 )

	MV_PAR01 := aMVs[01]
	MV_PAR02 := aMVs[02]
	MV_PAR03 := aMVs[03]
	MV_PAR04 := aMVs[04]
	MV_PAR05 := aMVs[05]
	MV_PAR06 := aMVs[06]
	MV_PAR07 := aMVs[07]
	MV_PAR08 := aMVs[08]
	MV_PAR09 := aMVs[09]
	MV_PAR10 := aMVs[10]
	MV_PAR11 := aMVs[11]
	MV_PAR12 := aMVs[12]
	MV_PAR13 := aMVs[13]
	MV_PAR14 := aMVs[14]
	MV_PAR15 := aMVs[15]
	MV_PAR16 := aMVs[16]
	MV_PAR17 := aMVs[17]
	MV_PAR18 := aMVs[18]
	MV_PAR19 := aMVs[19]
	MV_PAR20 := aMVs[20]
	MV_PAR21 := aMVs[21]
	MV_PAR22 := aMVs[22]
	MV_PAR23 := aMVs[23]
	MV_PAR24 := aMVs[24]
	MV_PAR25 := aMVs[25]

	SELECT(nWorkArea)
	RestArea(aArea)

Return .T.

