#INCLUDE "Protheus.ch"


User Function Caixa()
 
Local cPorta   := "LPT1"
Local cModelo  := "ZEBRA"
Local cDescr   := Alltrim(Z01->Z01_GRADE)
Local cDesc1   := SUBSTR(cDescr,1,26) 
Local cDesc2   := SUBSTR(cDescr,27,56) 
Local cDesc3   := SUBSTR(cDescr,57,70) 
Local cPares   := Alltrim(Z01->Z01_QTD)
Local cCodBar  := Alltrim(Z01->Z01_LOTE)
Local cQuery   := ""
Local cAliGrd  := GetNextAlias()
Local aTamNum  := Array(2,12)
Local nVlrTot  := 0
Local nVlrUni  := 0

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
cQuery += "WHERE  Z01_LOTE = '" + cCodBar + "' " 
cQuery += "AND Z02010.D_E_L_E_T_ = ' '" 
cQuery += "AND Z01010.D_E_L_E_T_ = ' '" 
cQuery += "ORDER  BY Z02_COD" 

cQuery := ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliGrd,.T.,.T.)

(cAliGrd)->(dbGoTop())

For nX := 1 To 12
	
	aTamNum[1][nX]:= Alltrim((cAliGrd)->Z02_NUM)
	aTamNum[2][nX]:= Alltrim((cAliGrd)->Z02_QTD)
	
	(cAliGrd)->(DbSkip()) 
		
Next

(cAliGrd)->(dbGoTop())

nVlrUni := (cAliGrd)->Z02_PRECO/Val((cAliGrd)->Z02_QTD)
nVlrUni := Alltrim(Str(nVlrUni))

Do While (cAliGrd)->(!Eof())
	
	nVlrTot += (cAliGrd)->Z02_PRECO / Val((cAliGrd)->Z02_QTD)
	
	(cAliGrd)->(DbSkip()) 
		
EndDo

nVlrTot := Alltrim(Str(nVlrTot))

(cAliGrd)->(DbCloseArea())

MSCBPrinter(cModelo, cPorta, NIL, NIL, .F., NIL, NIL, NIL, , NIL, .F.) // CONFIGURAÇÃO DA IMPRESSORA
MSCBChkStatus(.F.)    

MSCBBEGIN(1,6)

MSCBWRITE("ï»¿CT~~CD,~CC^~CT~")
MSCBWRITE("^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR2,2~SD15^JUS^LRN^CI0^XZ")
MSCBWRITE("^XA")
MSCBWRITE("^MMT")
MSCBWRITE("^PW799")
MSCBWRITE("^LL1199")
MSCBWRITE("^LS0")
MSCBWRITE("^FO353,52^GB149,1080,4^FS")
MSCBWRITE("^FO353,1039^GB149,0,3^FS")
MSCBWRITE("^FO352,956^GB148,0,3^FS")
MSCBWRITE("^FO353,873^GB149,0,2^FS")
MSCBWRITE("^FO352,790^GB148,0,2^FS")
MSCBWRITE("^FO353,710^GB149,0,2^FS")
MSCBWRITE("^FO353,625^GB149,0,2^FS")
MSCBWRITE("^FO352,539^GB148,0,3^FS")
MSCBWRITE("^FO352,459^GB148,0,3^FS")
MSCBWRITE("^FO352,375^GB148,0,2^FS")
MSCBWRITE("^FO353,292^GB148,0,3^FS")
MSCBWRITE("^FO354,209^GB149,0,2^FS")
MSCBWRITE("^FO353,124^GB148,0,3^FS")
MSCBWRITE("^FT533,20^A0R,56,55^FH\^FDTotal de pares: " + cPares + "^FS")
MSCBWRITE("^FT696,23^A0R,56,55^FH\^FD0" + cDesc1 + "^FS")
MSCBWRITE("^FT625,23^A0R,56,55^FH\^FD" + cDesc2 + "^FS")
MSCBWRITE("^FO424,54^GB0,1079,1^FS")
MSCBWRITE("^FT288,737^A0R,51,50^FH\^FDVLR GD: R$ " + nVlrTot + "^FS")
MSCBWRITE("^FT285,53^A0R,51,50^FH\^FDVLR NIT:  R$ " + nVlrUni + "^FS")
MSCBWRITE("^BY8,2,147^FT94,230^BER,,Y,N")
MSCBWRITE("^FD" + cCodBar + "^FS")
MSCBWRITE("^FT453,64^A0R,31,31^FH\^FDTAM  " + aTamNum[1][1] + "  " + aTamNum[1][2] + "  " + aTamNum[1][3] + " " + aTamNum[1][4] + " " + aTamNum[1][5] + " "+ aTamNum[1][6] +" "+ aTamNum[1][7] +"  "+ aTamNum[1][8] +"  "+ aTamNum[1][9] +" "+ aTamNum[1][10] +"  "+ aTamNum[1][11] +"  "+ aTamNum[1][12] +"^FS")
MSCBWRITE("^FT377,64^A0R,31,31^FH\^FDQTD    " + aTamNum[2][1] + "      " + aTamNum[2][2] + "       " + aTamNum[2][3] + "       " + aTamNum[2][4] + "        " + aTamNum[2][5] + "        " + aTamNum[2][6] + "        " + aTamNum[2][7] + "       " + aTamNum[2][8] + "       " + aTamNum[2][9] + "       " + aTamNum[2][10] + "       " + aTamNum[2][11] + "       " + aTamNum[2][12] + "^FS")
MSCBWRITE("^PQ1,0,1,Y^XZ")

MSCBEND()
MSCBCLOSEPRINTER()

Return