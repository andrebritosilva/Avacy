#INCLUDE "Protheus.ch"
#INCLUDE "COLORS.CH"        
#INCLUDE "TOPCONN.CH"          
#INCLUDE "TOTVS.CH"
#Include "RwMake.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TRANSPOR  ºAutor  ³Marcelo - Ethosx    º Data ³  24/10/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Emissao de Etiqueta para Transportadora                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Avacy                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function Transpor()   // imagem de etiqueta de volume temporaria

Local aArea    := GetArea() 
Local cPorta   := "LPT1"
Local cModelo  := "ZEBRA"
Local cNfde	   := ""
Local cNfAt	   := ""
//Local cSerie   := ""
Local cQuery   := ""
Local cAliGrd  := GetNextAlias()
Local nVol	   := 1
Local aPWiz    := {}
Local aRetWiz  := {}   
Local oVol
Local oVolIni
Local lRet	   := .T.


aAdd(aPWiz,{ 1,"Nota De: "                ,Space(TamSX3("F2_DOC")[1])     ,"","","SF2","",    ,.T.})
aAdd(aPWiz,{ 1,"Nota Ate: "               ,Space(TamSX3("F2_DOC")[1])     ,"","","SF2",  ,    ,.T.})
//aAdd(aPWiz,{ 1,"Série: "                  ,Space(TamSX3("F2_SERIE")[1])     ,"","","",  ,    ,.T.})

aAdd(aRetWiz,Space(TamSX3("F2_FILIAL")[1]))
aAdd(aRetWiz,Space(TamSX3("F2_FILIAL")[1]))
//aAdd(aRetWiz,Space(TamSX3("F2_FILIAL")[1]))

lRet:= ParamBox(aPWiz,"Impressão Transportadora",@aRetWiz,,,,,,) 

If !lRet
	RestArea( aArea )
	Return
EndIf

cNfde   := Alltrim(aRetWiz[1])
cNfAt   := Alltrim(aRetWiz[2]) 
//cSerie	:= Alltrim(aRetWiz[3]) 

cQuery := "SELECT F2_FILIAL," 
cQuery += " F2_DOC," 
cQuery += " F2_SERIE," 
cQuery += " F2_CLIENTE," 
cQuery += " F2_LOJA," 
cQuery += " F2_VOLUME1," 
cQuery += " F2_TRANSP" 
cQuery += "FROM " + RetSqlName("SF2") + " SF2 "
cQuery += "WHERE SF2.F2_DOC >= '" 	+ cNfde 	+ "' " 
cQuery += "AND SF2.F2_DOC < = '" 	+ cNfAt 	+ "' " 
//cQuery += "AND SF2.F2_SERIE = '" 	+ cSerie 	+ "' " 
cQuery += "AND SF2.D_E_L_E_T_ = ' '" 
cQuery += "ORDER  BY F2_FILIAL, F2_DOC" 

cQuery := ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliGrd,.T.,.T.)

(cAliGrd)->(DbGoTop())

MSCBPrinter(cModelo, cPorta, NIL, NIL, .F., NIL, NIL, NIL, , NIL, .F.) // CONFIGURAÇÃO DA IMPRESSORA
MSCBChkStatus(.F.)    
MSCBBEGIN(1,6)

While (cAliGrd)->(!EOF())
	
	//Perguntar a partir de qual Volume vai Imprimir

	Define MsDialog oVol Title "Volumes" From C(230),C(300) To C(330),C(600) Pixel
	
		@ C(015),C(005) Say "Volume Inicial:" 		Size C(040),C(008) Pixel Of oVol
		@ C(015),C(035) MsGet oVolIni 	Var nVol 	Valid (nVol>0) Picture "999" Size C(030),C(005) Pixel Of oVol
		@ C(015),C(070) Say "Volume Total: " + Strzero((cAliGrd)->F2_VOLUME1,3)	Size C(050),C(008) Pixel Of oVol

		@ C(030),C(020) Button "Ok"	 Size C(030),C(008) Pixel Action oVol:End()
	
	Activate MsDialog oVol Centered
	
	If nVol <= 0
		Return()
	EndIf

	For nVol:=nVol to (cAliGrd)->F2_VOLUME1
	
		MSCBWRITE("CT~~CD,~CC^~CT~")
		MSCBWRITE("^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR2,2~SD15^JUS^LRN^CI0^XZ")
		MSCBWRITE("^XA")
		MSCBWRITE("^MMT")
		MSCBWRITE("^PW799")		
		MSCBWRITE("^LL1199")
		MSCBWRITE("^LS0")
		MSCBWRITE("^FT729,1103^A0I,45,45^FH\^FDNF: " + (cAliGrd)->F2_DOC + "^FS	")
		MSCBWRITE("^FO37,226^GB702,441,4^FS")
		MSCBWRITE("^FO42,47^GB698,152,4^FS")
		MSCBWRITE("^FO85,982^GB137,145,4^FS")
		MSCBWRITE("^FT192,1067^A0I,39,38^FH\^FDVOL:^FS")
		MSCBWRITE("^FT192,1019^A0I,39,38^FH\^FD" + AllTrim(Str(nVol))+ "/" + AllTrim(Str((cAliGrd)->F2_VOLUME1)) + "^FS")
		MSCBWRITE("^FT736,801^A0I,28,28^FH\^FDTRANSPORTADORA:^FS")
		MSCBWRITE("^FT742,716^A0I,45,45^FH\^FD" + SubStr(Upper(Posicione("SA4",1,xFilial("SA4") + (cAliGrd)->F2_TRANSP,"A4_NOME")),1,30) + "^FS")
		MSCBWRITE("^FT714,611^A0I,34,33^FH\^FDDestinat\A0rio:^FS")
		MSCBWRITE("^FT714,522^A0I,34,33^FH\^FD" + Upper(AllTrim(SubStr(Posicione("SA1",1,xFilial("SA1") + (cAliGrd)->F2_CLIENTE + (cAliGrd)->F2_LOJA,"A1_NOME"),1,40))) + "^FS")

		If !Empty(AllTrim(SubStr(SA1->A1_NOME,41)) )
			MSCBWRITE("^FT714,480^A0I,34,33^FH\^FD" + Upper(AllTrim(SubStr(SA1->A1_NOME,41,40))) + "^FS" )
		EndIf
		
		MSCBWRITE("^FT714,438^A0I,34,33^FH\^FD" + Upper(AllTrim(SubStr(SA1->A1_END,1,40))) + "^FS" )
		
		If !Empty(AllTrim(SubStr(SA1->A1_END,41)) )
			MSCBWRITE("^FT714,396^A0I,34,33^FH\^FD" + Upper(AllTrim(SubStr(SA1->A1_END,41))) + "^FS" )
		EndIf
		
		MSCBWRITE("^FT714,354^A0I,34,33^FH\^FD" + AllTrim(Upper(SubStr(SA1->A1_BAIRRO,1,40))) + "^FS")
		
		MSCBWRITE("^FT714,312^A0I,34,33^FH\^FD" + SubStr(SA1->A1_CEP,1,2) + "." + SubStr(SA1->A1_CEP,3,3) + "-" + SubStr(SA1->A1_CEP,6,3) + " - " + Upper(AllTrim(SA1->A1_MUN)) + " - " + SA1->A1_EST + "^FS")
		MSCBWRITE("^FT730,145^A0I,28,28^FH\^FDRemetente:                      CNPJ: " + SubStr(SM0->M0_CGC,1,2) + "." + SubStr(SM0->M0_CGC,3,3) + "." + SubStr(SM0->M0_CGC,6,3) + "/" + SubStr(SM0->M0_CGC,9,4) + "-" + SubStr(SM0->M0_CGC,13,2) + "^FS")

		MSCBWRITE("^FT730,111^A0I,28,28^FH\^FD" + StrTran(AllTrim(Upper(SubStr(SM0->M0_NOMECOM,1,40))),"Ç","C") + " - " + AllTrim(Upper(SubStr(SM0->M0_ENDCOB,1,40))) + "^FS")
		MSCBWRITE("^FT730,77^A0I,28,28^FH\^FD"	+ AllTrim(Upper(SM0->M0_BAIRCOB)) + " - " + SubStr(SM0->M0_CEPCOB,1,2) + "." + SubStr(SM0->M0_CEPCOB,3,3) + "-" + SubStr(SM0->M0_CEPCOB,6,3) + " - " + Upper(AllTrim(SM0->M0_CIDCOB)) + " - " + SM0->M0_ESTCOB + "^FS")
		MSCBWRITE("^BY4,3,160^FT689,904^BCI,,Y,N")
		
		MSCBWRITE("^FD>;" + SubStr((cAliGrd)->F2_DOC,1,8) + ">6" + SubStr((cAliGrd)->F2_DOC,9,1) + "^FS")
		MSCBWRITE("^PQ1,0,1,Y^XZ")
	
	Next
	
	(cAliGrd)->(!DbSkip())

End

MSCBEND()
MSCBCLOSEPRINTER()

(cAliGrd)->(DbCloseArea())

/*
Usar esse comando para utilizar impressoras com cabo USB
C:\Users\andre>net use LPT1 \\LAPTOP-OQ8QM9NU\GC420t
*/

RestArea( aArea )

Return