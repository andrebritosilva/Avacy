#INCLUDE "Protheus.ch"


User Function Amostra()   // imagem de etiqueta de volume temporaria

Local aArea    := GetArea() 
Local cPorta   := "LPT1"
Local cModelo  := "ZEBRA"
Local cCodGd   := ""
Local cCodGd2  := ""
Local cQuery   := ""
Local cAliGrd  := GetNextAlias()
Local cAliGrd2 := GetNextAlias()
Local cDesGrd  := ""
Local cDesc1   := ""
Local cDesc2   := ""
Local cDesc3   := ""
Local cQtd     := ""
Local aTamNum  := Array(2,12)
Local cDesGrds := ""
Local cDesc1s  := ""
Local cDesc2s  := ""
Local cDesc3s  := ""
Local cQtds    := ""
Local aTamNum2 := Array(2,12)
Local nX       := 0
Local aPWiz    := {}
Local aRetWiz  := {}
Local cLote    := ""
Local cLote2   := ""
Local nVlrUni  := 0
Local nVlrUni2 := 0
Local nVlrTot  := 0
Local nVlrTot2 := 0
Local lRet	   := .T.

aAdd(aPWiz,{ 1,"Grade De: "                ,Space(TamSX3("Z01_LOTE")[1])     ,"","","Z01A","",    ,.T.})
aAdd(aPWiz,{ 1,"Grade Ate: "               ,Space(TamSX3("Z01_LOTE")[1])     ,"","","Z01A",  ,    ,.T.})

aAdd(aRetWiz,Space(TamSX3("B1_FILIAL")[1]))
aAdd(aRetWiz,Space(TamSX3("B1_FILIAL")[1]))

lRet:= ParamBox(aPWiz,"Impressão Amostra - Grade Avacy",@aRetWiz,,,,,,) 

If !lRet
	RestArea( aArea )
	Return
EndIf

cCodGd    := Alltrim(aRetWiz[1])
cCodGd2   := Alltrim(aRetWiz[2]) 

cQuery := "SELECT Z01_GRADE," 
cQuery += " Z01_QTD," 
cQuery += " Z01_LOTE," 
cQuery += " Z02_CODGRD," 
cQuery += " Z02_PRECO," 
cQuery += " Z02_QTD," 
cQuery += " Z02_NUM" 
cQuery += "FROM " + RetSqlName("Z02")+ " "
cQuery += "INNER JOIN " + RetSqlName("Z01")+ " "
cQuery += "ON Z01_LOTE = Z02_CODGRD" 
cQuery += "WHERE  Z01_LOTE = '" + cCodGd + "' " 
cQuery += "AND Z02010.D_E_L_E_T_ = ' '" 
cQuery += "AND Z01010.D_E_L_E_T_ = ' '" 
cQuery += "ORDER  BY Z02_COD" 

cQuery := ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliGrd,.T.,.T.)

(cAliGrd)->(dbGoTop())

cDesGrd := Alltrim((cAliGrd)->Z01_GRADE)
cLote   := Alltrim((cAliGrd)->Z01_LOTE)
cDesc1  := SUBSTR(cDesGrd,1,26) 
cDesc2  := SUBSTR(cDesGrd,27,56) 
cDesc3  := SUBSTR(cDesGrd,57,70) 
cQtd    := Alltrim((cAliGrd)->Z01_QTD)
nVlrUni := (cAliGrd)->Z02_PRECO/Val((cAliGrd)->Z02_QTD)
nVlrUni := Alltrim(Str(nVlrUni))

For nX := 1 To 12
	
	aTamNum[1][nX]:= Alltrim((cAliGrd)->Z02_NUM)
	aTamNum[2][nX]:= Alltrim((cAliGrd)->Z02_QTD)
	
	(cAliGrd)->(DbSkip()) 
		
Next

(cAliGrd)->(dbGoTop())

Do While (cAliGrd)->(!Eof())
	
	nVlrTot += (cAliGrd)->Z02_PRECO / Val((cAliGrd)->Z02_QTD)
	
	(cAliGrd)->(DbSkip()) 
		
EndDo

nVlrTot := Alltrim(Str(nVlrTot))

(cAliGrd)->(DbCloseArea())

//Inicio a segunda query para a segunda etiqueta

cQuery := "SELECT Z01_GRADE," 
cQuery += " Z01_QTD," 
cQuery += " Z01_LOTE,"
cQuery += " Z02_CODGRD," 
cQuery += " Z02_PRECO," 
cQuery += " Z02_QTD," 
cQuery += " Z02_NUM" 
cQuery += "FROM " + RetSqlName("Z02")+ " "
cQuery += "INNER JOIN " + RetSqlName("Z01")+ " "
cQuery += "ON Z01_LOTE = Z02_CODGRD" 
cQuery += "WHERE  Z01_LOTE = '" + cCodGd2 + "' " 
cQuery += "AND Z02010.D_E_L_E_T_ = ' '" 
cQuery += "AND Z01010.D_E_L_E_T_ = ' '" 
cQuery += "ORDER  BY Z02_COD" 

cQuery := ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliGrd2,.T.,.T.)

(cAliGrd2)->(dbGoTop())

cDesGrds := Alltrim((cAliGrd2)->Z01_GRADE)
cLote2   := Alltrim((cAliGrd2)->Z01_LOTE)
cDesc1s  := SUBSTR(cDesGrds,1,26) 
cDesc2s  := SUBSTR(cDesGrds,27,56) 
cDesc3s  := SUBSTR(cDesGrds,57,70) 
cQtds    := Alltrim((cAliGrd2)->Z01_QTD)
nVlrUni2 := (cAliGrd2)->Z02_PRECO/Val((cAliGrd2)->Z02_QTD)
nVlrUni2 := Alltrim(Str(nVlrUni2))

For nX := 1 To 12
	
	aTamNum2[1][nX]:= Alltrim((cAliGrd2)->Z02_NUM)
	aTamNum2[2][nX]:= Alltrim((cAliGrd2)->Z02_QTD)
	
	(cAliGrd2)->(DbSkip()) 
		
Next

Do While (cAliGrd2)->(!Eof())
	
	nVlrTot2 += (cAliGrd2)->Z02_PRECO / Val((cAliGrd2)->Z02_QTD)
	
	(cAliGrd2)->(DbSkip()) 
		
EndDo

nVlrTot2 := Alltrim(Str(nVlrTot2))

(cAliGrd2)->(DbCloseArea())
/*
Usar esse comando para utilizar impressoras com cabo USB
C:\Users\andre>net use LPT1 \\LAPTOP-OQ8QM9NU\GC420t
*/
MSCBPrinter(cModelo, cPorta, NIL, NIL, .F., NIL, NIL, NIL, , NIL, .F.) // CONFIGURAÇÃO DA IMPRESSORA
MSCBChkStatus(.F.)    

MSCBBEGIN(1,6)

//MSCBWRITE("ï»¿CT~~CD,~CC^~CT~")
MSCBWRITE("CT~~CD,~CC^~CT~")
MSCBWRITE("^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR2,2~SD15^JUS^LRN^CI0^XZ")
MSCBWRITE("^XA")
MSCBWRITE("^MMT")
MSCBWRITE("^PW831")
MSCBWRITE("^LL0599")
MSCBWRITE("^LS0") 
MSCBWRITE("^FO12,251^GB383,100,4^FS")
MSCBWRITE("^FO410,250^GB383,100,4^FS")
MSCBWRITE("^FO11,371^GB383,100,4^FS")
MSCBWRITE("^FO409,369^GB383,101,4^FS")
MSCBWRITE("^FO17,300^GB373,0,1^FS")   
MSCBWRITE("^FO415,299^GB373,0,1^FS")
MSCBWRITE("^FT395,484^A0I,23,24^FH\^FDTotal de pares: " +  cQtd + "^FS")
MSCBWRITE("^FT394,555^A0I,23,24^FH\^FD" + cDesc1 + "^FS")
MSCBWRITE("^FT394,527^A0I,23,24^FH\^FD" + cDesc2 + "^FS")
MSCBWRITE("^FT385,317^A0I,20,19^FH\^FDTAM  "+ aTamNum[1][7] + "  " + aTamNum[1][8] + "  " + aTamNum[1][9] + "  " + aTamNum[1][10] + "  " + aTamNum[1][11] + "  "+ aTamNum[1][12] +"^FS")
MSCBWRITE("^FT385,269^A0I,20,19^FH\^FDQTD    " + aTamNum[2][7] + "       "+ aTamNum[2][8] +"       "+ aTamNum[2][9] +"         "+ aTamNum[2][10] +"        "+ aTamNum[2][11] +"        "+ aTamNum[2][12] +"^FS")
MSCBWRITE("^FO16,420^GB373,0,1^FS") 
MSCBWRITE("^FT384,436^A0I,20,19^FH\^FDTAM  "+ aTamNum[1][1] + "  " + aTamNum[1][2] + "  " + aTamNum[1][3] + "  " + aTamNum[1][4] + "  " + aTamNum[1][5] + "  "+ aTamNum[1][6] +"^FS")
MSCBWRITE("^FT384,388^A0I,20,19^FH\^FDQTD    " + aTamNum[2][1] + "       "+ aTamNum[2][2] +"       "+ aTamNum[2][3] +"         "+ aTamNum[2][4] +"        "+ aTamNum[2][5] +"        "+ aTamNum[2][6] +"^FS")
MSCBWRITE("^FO414,419^GB373,0,1^FS")
MSCBWRITE("^FT793,483^A0I,23,24^FH\^FDTotal de pares: "+ cQtds + "^FS")
MSCBWRITE("^FT792,554^A0I,23,24^FH\^FD" + cDesc1s + "^FS")
MSCBWRITE("^FT792,526^A0I,23,24^FH\^FD" + cDesc2s + "^FS")
MSCBWRITE("^FT388,214^A0I,20,19^FH\^FDVLR NIT:  R$ " + nVlrUni + "^FS")
MSCBWRITE("^FT388,190^A0I,20,19^FH\^FDVLR GD: R$ " + nVlrTot + "^FS")
MSCBWRITE("^FT783,316^A0I,20,19^FH\^FDTAM  " + aTamNum2[1][1] + "  " + aTamNum2[1][2] + "  " + aTamNum2[1][3] + "  " + aTamNum2[1][4] + "  " + aTamNum2[1][5] + "   "+ aTamNum2[1][6] +"^FS")
MSCBWRITE("^FT783,268^A0I,20,19^FH\^FDQTD    " + aTamNum2[2][1] + "       "+ aTamNum2[2][2] +"       "+ aTamNum2[2][3] +"         "+ aTamNum2[2][4] +"        "+ aTamNum2[2][5] +"        "+ aTamNum2[2][6] +"^FS")
MSCBWRITE("^FT782,435^A0I,20,19^FH\^FDTAM  "+ aTamNum2[1][7] + "    " + aTamNum2[1][8] + "   " + aTamNum2[1][9] + "   " + aTamNum2[1][10] + "   " + aTamNum2[1][11] + "   "+ aTamNum2[1][12] +"^FS")
MSCBWRITE("^FT782,387^A0I,20,19^FH\^FDQTD    " + aTamNum2[2][7] + "       "+ aTamNum2[2][8] +"       "+ aTamNum2[2][9] +"         "+ aTamNum2[2][10] +"        "+ aTamNum2[2][11] +"        "+ aTamNum2[2][12] +"^FS")
MSCBWRITE("^BY2,3,96^FT742,70^BCI,,Y,N")
MSCBWRITE("^FD>;>8" + cLote + "^FS")
MSCBWRITE("^BY2,3,96^FT357,72^BCI,,Y,N")
MSCBWRITE("^FD>;>8" + cLote2 + "^FS")
MSCBWRITE("^FT786,213^A0I,20,19^FH\^FDVLR NIT:  R$ " + nVlrUni2 +"^FS")
MSCBWRITE("^FT786,189^A0I,20,19^FH\^FDVLR GD: R$ " + nVlrTot + "^FS")
MSCBWRITE("^FO72,257^GB0,95,2^FS")
MSCBWRITE("^FO470,255^GB0,96,1^FS")
MSCBWRITE("^FO71,376^GB0,95,1^FS")
MSCBWRITE("^FO123,253^GB0,96,1^FS")
MSCBWRITE("^FO469,375^GB0,95,1^FS")
MSCBWRITE("^FO521,252^GB0,95,1^FS")
MSCBWRITE("^FO179,252^GB0,96,1^FS")
MSCBWRITE("^FO122,373^GB0,95,1^FS")
MSCBWRITE("^FO520,372^GB0,95,1^FS")
MSCBWRITE("^FO234,253^GB0,95,1^FS")
MSCBWRITE("^FO577,251^GB0,95,1^FS")

MSCBWRITE("^FO177,372^GB0,95,1^FS")
MSCBWRITE("^FO287,253^GB0,95,1^FS")
MSCBWRITE("^FO575,371^GB0,95,1^FS")
MSCBWRITE("^FO631,252^GB0,95,1^FS")
MSCBWRITE("^FO341,252^GB0,96,2^FS")
MSCBWRITE("^FO232,372^GB0,96,1^FS")
MSCBWRITE("^FO630,371^GB0,95,1^FS")
MSCBWRITE("^FO685,252^GB0,95,1^FS")
MSCBWRITE("^FO286,373^GB0,95,1^FS")
MSCBWRITE("^FO684,371^GB0,96,1^FS")
MSCBWRITE("^FO739,251^GB0,95,1^FS")
MSCBWRITE("^FO340,372^GB0,95,1^FS")
MSCBWRITE("^FO738,371^GB0,95,1^FS")
MSCBWRITE("^PQ1,0,1,Y^XZ")
MSCBEND()
MSCBCLOSEPRINTER()

RestArea( aArea )

Return