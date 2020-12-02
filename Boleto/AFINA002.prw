#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "TOTVS.CH"
#include "protheus.ch"
#INCLUDE "TBICONN.CH"

#define DMPAPER_A4 9

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณAFINA002                               บ                    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRESSAO DO BOLETO COM CODIGO DE BARRAS      			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

E1_MULTA  = Vlr. da multa a cerca do recebimento
E1_JUROS  = Vlr. da taxa permanencia cobrada
E1_CORREC = vlr. da Correcao referente ao recebimento
E1_VALJUR = Taxa diaria, tem precedencia ao % juros
E1_PORCJUR = % juro atraso dia

Campos que devem ser criados
E1_DVNSNUM = C = 1
EE_XCART = C = 3
EE_DVCTA = C = 1
EE_DVAGE = C = 1

EE_TIPODAT = preencher com 4 a data da baixa sair correta

MV_TXPER = Indique o % da Taxa de Juros e colocado no E1_PORCJUR, ele ira calcular o E1_VALJUR
MV_LJMULTA = Percentual de multa para os titulos em atraso. Utilizado na rotina de recebimento de titulos.

********MELHORIA DIA 21/06/2018
Envio para todas as Situa็๕es do Protheus
NรO USAR --->>>> EE_XSIT = C = 1	==> Podendo Ser:
1-Cobran็a Simples
2-Cobran็a Descontada
3-Cobran็a Caucionada
4-Cobran็a Vinculada
7-Caucionada Descontada

*/

User Function AFINA002(_Exec, _cDef2Printer)

Local	aPergs     := {}
Local   _cQry := ""
Local  cTpNaoImp := SuperGetMv("MV_XTPNIMP",.F.,"")//FormatIn(cTpNaoImp,"/")
Private lJob := .F.
Private lUsaFormPg := SuperGetMv ( "MV_XUSFPG")
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPreparo o ambiente na qual sera executada a rotina de negocio      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


//Valida็ใo da Empresa INICIO NOME DA EMPRESA LOGADA
cCNPJ := alltrim(SM0->M0_CGC)
//if !U_ALIBE001('000010 - BOLETO',cCNPJ,"Processo de Impressใo de Boleto!")
//	Return
//endif


If Select("SX2") == 0 // Se via JOB
	lJob := .T.
	ConOut(DTOC(DATE())+"-"+Time()+" Iniciando rotina para emissใo de boletos...")
	
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" TABLES "SA3","SED","SEE","SE1","SEA"
else
	DbSelectArea("SA3")
	DbSelectArea("SED")
	DbSelectArea("SEE")
	DbSelectArea("SE1")
	DbSelectArea("SEA")
Endif

PRIVATE lExec      := .F.
PRIVATE cIndexName := ''
PRIVATE cIndexKey  := ''
PRIVATE cFilter    := ''
PRIVATE cNumBco    := ''
PRIVATE cMarca     := GetMark()
//PRIVATE cNroDoc  :=  ""   
PRIVATE Tamanho  := "M"
PRIVATE titulo   := "Impressao de Boleto com Codigo de Barras"
PRIVATE cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
PRIVATE cDesc2   := ""
PRIVATE cDesc3   := ""
PRIVATE cString  := "SE1"
PRIVATE wnrel    := "BOLETO LASER"
PRIVATE lEnd     := .F.
PRIVATE cPerg     :=Padr("AFINA002",10)
PRIVATE aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nLastKey := 0
PRIVATE aCampos :={}
PRIVATE _MsExec	:= .F.
Private _nSEE	:= 0

DEFAULT _Exec := {}

_MsExec	:= len(_Exec) > 0

AjustaSx1(cPerg)

Pergunte(cPerg, !_MsExec)

if LastKey() == 27
	Return
	
elseif Len(_Exec) <> 22 .and. _MsExec
	Aviso("ATENวรO","Informar ao Dept. T.I. diferen็a nos parametros vindo do Faturamento, o Boleto poderแ ser impresso pela op็ใo Relatorio->Personaliza็ใo-> Boleto Laser!",{"OK"})
	Return
	
elseif _MsExec
	MV_PAR01 := _Exec[01]	// Prefixo
	MV_PAR02 := _Exec[02]
	MV_PAR03 := _Exec[03]	// Nr.
	MV_PAR04 := _Exec[04]
	MV_PAR05 := _Exec[05]	// Parcela
	MV_PAR06 := _Exec[06]
	MV_PAR07 := _Exec[07]	// Portador
	MV_PAR08 := _Exec[08]
	MV_PAR09 := _Exec[09]	// Cliente
	MV_PAR10 := _Exec[10]
	MV_PAR11 := _Exec[11]	// Loja
	MV_PAR12 := _Exec[12]
	MV_PAR13 := _Exec[13]	// Emissใo
	MV_PAR14 := _Exec[14]
	MV_PAR15 := _Exec[15]	// Vencimento
	MV_PAR16 := _Exec[16]
	MV_PAR17 := _Exec[17]	// Nr. Bordero
	MV_PAR18 := _Exec[18]
	MV_PAR19 := _Exec[19]	// Nr. Carga
	MV_PAR20 := _Exec[20]
	MV_PAR21 := _Exec[21]	// Msg1
	MV_PAR22 := _Exec[22]	// Msg2
endif


_cQry := ""
_cQry += " SELECT DISTINCT"
_cQry += "    (SELECT "
_cQry += "       SUM(E1_VLCRUZ) "		//ISNULL(SUM(E1_VLCRUZ),0)
_cQry += "     FROM "
_cQry += "          "+RetSqlName("SE1")
_cQry += "     WHERE "
_cQry += "           D_E_L_E_T_ = ' ' "
_cQry += "       AND LTRIM(RTRIM(E1_TIPO)) = 'NCC'  "
_cQry += "       AND E1_CLIENTE = SE1.E1_CLIENTE  "
_cQry += "       AND E1_LOJA    = SE1.E1_LOJA "
_cQry += "     ) E1_NCC "
_cQry += "   ,(SELECT  "
_cQry += "       SUM(E1_VLCRUZ) "	// ISNULL(SUM(E1_VLCRUZ),0)
_cQry += "     FROM "
_cQry += "          "+RetSqlName("SE1")
_cQry += "     WHERE "
_cQry += "           D_E_L_E_T_ = ' ' "
_cQry += "       AND LTRIM(RTRIM(E1_TIPO)) = 'RA'  "
_cQry += "       AND E1_CLIENTE = SE1.E1_CLIENTE "
_cQry += "       AND E1_LOJA    = SE1.E1_LOJA "
_cQry += "     ) E1_RA "
_cQry += "   ,SE1.E1_TIPO "
_cQry += "   ,F2_CARGA E1_CARGA "
_cQry += "   ,E1_NUMBOR   "
if lUsaFormPg
	_cQry += "   ,E1_X_FORPG   "//Raony
endif
_cQry += "   ,E1_PREFIXO   "
_cQry += "   ,E1_NUM "
_cQry += "   ,E1_PARCELA "
_cQry += "   ,E1_TIPO "
_cQry += "   ,E1_NATUREZ  "
_cQry += "   ,E1_PORTADO  "
_cQry += "   ,E1_CLIENTE "
_cQry += "   ,A1_NOME E1_NOME"
_cQry += "   ,E1_LOJA  "
_cQry += "   ,E1_EMISSAO "
_cQry += "   ,E1_VENCTO  "
_cQry += "   ,E1_VENCREA "
_cQry += "   ,E1_VLCRUZ  "
_cQry += "   ,E1_FILIAL  "
_cQry += "   ,E1_VEND1 "
_cQry += "   ,E1_SALDO "
_cQry += "   ,E1_HIST "
_cQry += "   ,E1_SDDECRE "
_cQry += "   ,E1_DESCFIN "
_cQry += "   ,E1_SDACRES "
_cQry += " FROM "
_cQry += "    "+RetSqlName("SE1")+" SE1 "

// Nota fiscal de saida
_cQry += "    LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 "
_cQry += "    ON    SE1.E1_FILIAL  = SF2.F2_FILIAL "
_cQry += "      AND SE1.E1_NUM     = SF2.F2_DOC  "
_cQry += "      AND SE1.E1_PREFIXO = SF2.F2_SERIE "
_cQry += "      AND SE1.E1_CLIENTE = SF2.F2_CLIENTE "
_cQry += "      AND SE1.E1_LOJA    = SF2.F2_LOJA "
_cQry += "      AND SF2.D_E_L_E_T_ = ' ' "

// Bordero -         
// Foi relacionado a tabela de bordero para buscar os titulos cuja a emissao
_cQry += "    LEFT OUTER JOIN "+RetSqlName("SEA")+" SEA "
_cQry += "    ON    SE1.E1_FILIAL  = SEA.EA_FILIAL "
_cQry += "      AND SE1.E1_NUM     = SEA.EA_NUM  "
_cQry += "      AND SE1.E1_PREFIXO = SEA.EA_PREFIXO "
_cQry += "      AND SE1.E1_PARCELA = SEA.EA_PARCELA " 
_cQry += "      AND SEA.D_E_L_E_T_ = ' ' "
// Fim         

_cQry += "   ,"+RetSqlName("SA1")+" SA1 "
_cQry += " WHERE "
_cQry += 	"     SE1.D_E_L_E_T_ = ' ' "
_cQry += 	" AND SA1.D_E_L_E_T_ <> '*' " 
_cQry += 	" AND SA1.A1_FILIAL  = '"+xFilial("SA1") + "'     
_cQry += 	" AND SA1.A1_COD     = SE1.E1_CLIENTE "
_cQry += 	" AND SA1.A1_LOJA    = SE1.E1_LOJA "
_cQry += 	" AND LTRIM(RTRIM(SE1.E1_TIPO))  NOT IN ('NCC','RA','TX','AB-','DE')  "
_cQry += 	" AND E1_FILIAL           = '"+xFilial("SE1") + "'
_cQry += 	" AND E1_PREFIXO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
_cQry += 	" AND E1_NUM     BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
_cQry += 	" AND E1_PARCELA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
_cQry += 	" AND E1_PORTADO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
_cQry += 	" AND E1_CLIENTE BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
_cQry += 	" AND E1_LOJA    BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "

IF !Empty( AllTrim(MV_PAR19) )
	_cQry += " AND SF2.F2_CARGA BETWEEN '" + MV_PAR19+ "' AND '"+ MV_PAR20 + "' "
ENDIF

IF !Empty(MV_PAR17)
	_cQry += 	"   AND E1_NUMBOR BETWEEN '" + MV_PAR17 + "' AND '" + MV_PAR18 + "' "
ENDIF

if (MV_PAR13 <> CTOD("  /  /    ")) .AND. (MV_PAR14 <> CTOD("  /  /    "))
	_cQry += " AND E1_EMISSAO BETWEEN '"+DTOS(MV_PAR13)+"' AND '"+DTOS(MV_PAR14)+"' "
endif

if (MV_PAR15 <> CTOD("  /  /    ")) .AND. (MV_PAR16 <> CTOD("  /  /    "))
	_cQry += " AND E1_VENCREA BETWEEN '"+DTOS(MV_PAR15)+"' AND '"+DTOS(MV_PAR16)+"' "
endif

_cQry += " AND E1_SALDO > 0 AND E1_TIPO NOT IN ('CF-','CS-','IN-','IR-','PI-','IS-') "

If !Empty(cTpNaoImp)
	_cQry += " AND E1_TIPO NOT IN " + FormatIn(cTpNaoImp,"/")
EndIf
if lUsaFormPg
	_cQry += " AND RTRIM(LTRIM(E1_X_FORPG)) IN ('BOL','DP','DC') "
endif

if _MsExec
	if SA1->A1_XBOL == "2" //Nใo emitir Sair!
		return
	endif
else
	_cQry += " AND (A1_XBOL = '1' OR LTRIM(RTRIM(A1_XBOL)) = '')"
endif


_cQry += " ORDER BY E1_PREFIXO,E1_NUM,E1_PARCELA "

MemoWrite("C:\temp\AFINA002.txt",_cQry)
_cQry := ChangeQuery(_cQry)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbrir a Query ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampos := {}
aadd(aCampos,{ "E1_OK"		   	,"C",02,0 })
//if lUsaFormPg
aadd(aCampos,{ "E1_X_FORPG"   	,"C",len(SE1->E1_X_FORPG),0 })//Raony
//endif
aadd(aCampos,{ "E1_EMISSAO" 	,"D",08,0 })
aadd(aCampos,{ "E1_PREFIXO"		,"C",len(SE1->E1_PREFIXO),0})
aadd(aCampos,{ "E1_NUM"			,"C",len(SE1->E1_NUM),0 })
aadd(aCampos,{ "E1_PARCELA"		,"C",len(SE1->E1_PARCELA),0 })
aadd(aCampos,{ "E1_CLIENTE"		,"C",len(SE1->E1_CLIENTE),0 })
aadd(aCampos,{ "E1_LOJA"  		,"C",len(SE1->E1_LOJA),0 })
aadd(aCampos,{ "E1_NOME"		,"C",40,0 })
aadd(aCampos,{ "E1_VENCTO" 		,"D",08,0 })
aadd(aCampos,{ "E1_VENCREA"		,"D",08,0 })
aadd(aCampos,{ "E1_VLCRUZ"		,"N",15,2 })
aadd(aCampos,{ "E1_SALDO"		,"N",15,2 })
aadd(aCampos,{ "E1_NCC"	      	,"N",15,2 })
aadd(aCampos,{ "E1_RA"	      	,"N",15,2 })
aadd(aCampos,{ "E1_CARGA"		,"C",06,0})
aadd(aCampos,{ "E1_NUMBOR"		,"C",06,0})
aadd(aCampos,{ "E1_TIPO"		,"C",03,0})
aadd(aCampos,{ "E1_NATUREZ"		,"C",10,0 })
aadd(aCampos,{ "E1_PORTADO"		,"C",03,0})
aadd(aCampos,{ "E1_FILIAL"	   	,"C",03,0 })
aadd(aCampos,{ "E1_VEND1"	   	,"C",06,0 })
aadd(aCampos,{ "E1_DESCFIN"		,"N",06,2 })
aadd(aCampos,{ "E1_SDDECRE"		,"N",15,2 })
aadd(aCampos,{ "E1_SDACRES"		,"N",15,2 })

cArqSE1  := CriaTrab(aCampos, .T.)
cNtxSE1  := CriaTrab(nil,.f.)

dbUseArea(.T.,__LocalDriver,cArqSE1,"TSE1",.F.)

Processa({|| SqlToTrb(_cQry, aCampos, "TSE1")}) // Cria arquivo temporario
INDEX ON E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO TO &cNtxSE1

cMarca:=GetMark()
cMarca:=soma1(cMarca)
//if lUsaFormPg
aStruSE1	:= {		{"E1_OK" 				,""			,02,0},;
{"E1_X_FORPG" 				,"Tp.Doc"			,len(SE1->E1_X_FORPG),0},; //RAONY
{"E1_EMISSAO" 	,"Dt. Emissใo"		,08,0},;//	,"@D 99/99/9999"},;
{"E1_PREFIXO" 	,"Prefixo"	, len(SE1->E1_PREFIXO),0},;
{"E1_NUM" 		,"Titulo"	,len(SE1->E1_NUM),0},;
{"E1_PARCELA" 	,"Parcela"	,len(SE1->E1_PARCELA),0},;
{"E1_CLIENTE" 	,"Cliente"	,len(SE1->E1_CLIENTE),0},;
{"E1_LOJA" 		,"Loja"		,len(SE1->E1_LOJA),0},;
{"E1_NOME" 		,"Nome"		,40,0},;
{"E1_VENCTO" 	,"Dt. Vencto"		,08,0},;//	,"@D 99/99/9999"},;
{"E1_VENCREA"	,"Dt. Vencto Real"	,08,0},;
{"E1_VLCRUZ"	,"Valor"	,"@E 999,999,999.99"},;
{"E1_RA" 		,"RA"		,"@E 999,999,999.99"},;
{"E1_NCC" 		,"NCC"		,"@E 9,999,999,999,999.99"},;
{"E1_TIPO" 		,"Tipo"		,03,0},;
{"E1_CARGA" 	,"Carga"	,06,0},;
{"E1_NUMBOR" 	,"Bordero"	,06,0},;
{"E1_NATUREZ" 	,"Natureza"	,10,0},;
{"E1_VEND1" 	,"Vendedor"	,06,0},;
{"E1_PORTADO" 	,"Portado"	,03,0} }

TSE1->( dbGotop() )

if !_MsExec
	@ 001,001 TO 400,700 DIALOG oDlg TITLE "Sele็ใo de Titulos"
	@ 001,001 TO 170,350 BROWSE "TSE1" FIELDS aStruSE1 MARK "E1_OK"  Object oBrowIncPed
	
	oBtn1 := tButton():New(180,050,"Desmarca Todos   " ,oDlg,{|| fMarTudo(cMarca,.t.)},060,015,,,,.T.)
	oBtn2 := tButton():New(180,110,"Marca Todos      " ,oDlg,{|| fMarTudo(cMarca,.f.)},060,015,,,,.T.)
	oBtn3 := tButton():New(180,170,"Inverte Sele็ใo  " ,oDlg,{|| fMarTudo(cMarca,nil)},060,015,,,,.T.)
	oBtn4 := tButton():New(180,230,"Imprimir Boletos " ,oDlg,{|| lExec := .T.,MontaRel(),Close(oDlg)},060,015,,,,.T.)
	oBtn4 := tButton():New(180,290,"    Cancelar     " ,oDlg,{|| lExec := .F.,Close(oDlg)},060,015,,,,.T.)
	
	ACTIVATE DIALOG oDlg CENTERED
	
else
	lExec := .T.
	fMarTudo(cMarca,.F.)
	MontaRel(_cDef2Printer)
	
endif

TSE1->( dbCloseArea() )
fErase(cArqSE1 + ".DBF")
fErase(cNtxSE1 + ordBagExt())
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMarTudo                                                    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static Function fMarTudo(cMarca, ltudo)
Local aArea := TSE1->(GetArea())

TSE1->( dbGoTop() )

While !TSE1->( Eof() )
	
	RecLock("TSE1",.F.)
	if lTudo        // Marca todos os Itens
		TSE1->E1_OK := cMarca
		
	elseIf !lTudo   // Desmarca todos os itens
		TSE1->E1_OK := "  "
		
	else                   // Inverte a Sele็ใo
		
		if TSE1->E1_OK == cMarca
			TSE1->E1_OK := "  "
		else
			TSE1->E1_OK := cMarca
		endif
		
	endIf
	
	TSE1->( MsUnLock() )
	TSE1->( dbSkip() )
	
Enddo

RestArea(aArea)
if !_MsExec
	oDlg:Refresh()
endif
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMontaRel  บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MontaRel(_cDef2Printer)
RptStatus({|lEnd| ImpDet(_cDef2Printer) },"Processando Impressใo Boletos...") //"Processando"
Return


Static Function ImpDet(_cDef2Printer)
LOCAL oPrint
LOCAL nX      := 0
LOCAL aDadosEmp    := {	SM0->M0_NOMECOM                                    ,; //[1]Nome da Empresa
SM0->M0_ENDCOB                                     ,; //[2]Endere็o
AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+              ; //[6]
Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E


LOCAL aDadosTit                       
LOCAL aDadosBanco
LOCAL aDatSacado
LOCAL aBolText     := {SuperGetMv("MV_MENBOL1",,"  ")   ,;    // Primeiro texto para comentario
SuperGetMv("MV_MENBOL2",,"  ")   ,;    // Segundo texto para comentario
SuperGetMv("MV_MENBOL3",,"  ")   ,;
" ",;
" ",;
" ",;
" ",;
" " }    // Terceiro texto para comentario

LOCAL nI           := 1
LOCAL aCB_RN_NN    := {}
LOCAL nVlrAbat	   := 0
LOCAL cNosso       := ""
LOCAL _aVlrNF	   := {}
LOCAL cFilePrint   := ""
Local nVlrBol	   := 0
Local nAcrescimo   := 0
Local nPorcBol	   := 0       
Local nMulta	   := SuperGetMV("MV_XLJMULT",,0)
Local nMora        := SuperGetMV("MV_XTXPER",,0)
Local lSCV		   := SuperGetMV("MV_XCONSCV",.F.,.T.) // Se considera o percentual da SCV
Local lVencto      := SuperGetMV("MV_XVCTREA",.F.,.T.) // Se considera Vencimento real ou Vencimento.
Local cCliente     := ""
Private _cConvenio := ""
Private _cCarteira := ""
Private dVento
Private cString  := "SE1"
Private wnrel    := "BOLETO BANCARIO"
//Private cPerg     :="BOLETOBB  "
Private titulo   := "Impressao de Boleto com Codigo de Barras"
Private cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
Private cDesc2   := ""
Private cDesc3   := ""
Private Tamanho  := "G"
Private cDigNosso := ""
Private aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private nLastKey := 0
Private lPergBol	   := SuperGetMV("MV_XPERGBL",,.T.)// Se vai ou nao perguntar se imprime pelo cadastro de clientes

Public lImpBanCli	:= .F. 

cCliente := xCliSearch(TSE1->E1_CLIENTE , TSE1->E1_LOJA)

cFilePrint := "BOLETO" + cCliente + cFilAnt + Str( Year( date() ),4) + StrZero( Month( date() ), 2) +;
StrZero( Day( date() ),2) + Left(Time(),2) + Substr(Time(),4,2) + Right(Time(),2)

If lPergBol
	oPrint := FWMSPrinter():New(cFilePrint /*1-Arq. Spool*/, /*2-Spool/PDF*/, .T. /*3-Legado*/,;
	/*4-Dir. Salvar*/, !Type("_cDef2Printer")=="U" /*5-Nใo Exibe Setup*/, /*6-Classe TReport*/,;
	/*7-oPrintSetup*/, iif(Type("_cDef2Printer")=="U","",_cDef2Printer) /*8-Impressora For็ada*/ ) 
Else
	If !ExistDir("c:\Boletos")// verifica se existe o diretorio
   		MakeDir("c:\Boletos")// cria o diretorio
	EndIf
	oPrint := FWMSPrinter():New(cFilePrint,6,.T.,,.T.,,,,.T.,.F.,,.F.)
	oPrint:cPathPDF:= "C:\Boletos\"
EndIf		

oPrint:SetResolution(78) //Tamanho estipulado para a Danfe
oPrint:SetPortrait()
oPrint:SetPaperSize(DMPAPER_A4)
oPrint:SetMargin(60,60,60,60)

If nLastKey == 27
	Set Filter to
	Return
Endif

//imprimindo agora a duplicada
TSE1->( dbGoTop() )
SetRegua( TSE1->( LastRec() ) )

while !TSE1->( Eof() )
	
	if lUsaFormPg
		if upper(alltrim(TSE1->E1_X_FORPG)) != "BOL"
			if TSE1->E1_OK = '  '
				//U_IMPDUP(TSE1->E1_NUM)
			endif
		endif
	else
		if TSE1->E1_OK = '  '
			//U_IMPDUP(TSE1->E1_NUM)
		endif
	endif
	TSE1->( dbSkip() )
	IncProc()
	nI += 1
enddo


lEntPeloMenosVez := .F.

TSE1->( dbGoTop() )
SetRegua( TSE1->( LastRec() ) )

while !TSE1->( Eof() )
	
	IncRegua()
	nVlrBol	   	:= 0
	nAcrescimo  := 0
	nPorcBol	:= 0
	
	if upper(alltrim(TSE1->E1_X_FORPG)) == "BOL" .OR. !lUsaFormPg
		
		If TSE1->E1_OK = '  '
			
			if !lEntPeloMenosVez
				//INICIO AJUSTE
				If lPergBol // Se nใo for perguntar imprime pelo cadastro de clientes
					if MsgYesNo("Preparando para Imprimir Boletos! Deseja imprimir pelo Cadastro do Cliente?")
						lImpBanCli	:= .T.
					else
						U_AFINA001()  //SELECIONA A CARTEIRA QUE SERม IMPRESSO O BOLETO
					endif
					//FIM 
				Else
					lImpBanCli	:= .T.
				EndIf		
				lEntPeloMenosVez := .T.
			endif
			
			
			SE1->( DbSetOrder(2), DbSeek( xFilial("SE1") + TSE1->E1_CLIENTE + TSE1->E1_LOJA + TSE1->E1_PREFIXO + TSE1->E1_NUM + TSE1->E1_PARCELA + TSE1->E1_TIPO ) )
			cNroDoc    :=  ""
			
			
			IF !SuperGetMv("MV_XGRABOR",.F.,.T.)// Se Gera bordero
				SA6->( DbSetOrder(1) )
				if !SA6->( DbSeek(xFilial("SA6")+SEE->(EE_CODIGO+EE_AGENCIA+EE_CONTA) ,.T.) )
					Aviso("ATENวรO","Banco ("+Alltrim(SEA->EA_PORTADO)+" - "+Alltrim(SEA->EA_AGEDEP)+" - "+Alltrim(SEA->EA_NUMCON)+") nao localizado no cadastro de Bancos.",{"OK"})
					Return
				endif
				
			Else
				//Posiciona na Tabela do bordero.
				SEA->( DBSetOrder(1) )
				if !SEA->( DBSeek( xFilial("SEA") + SE1->E1_NUMBOR + TSE1->E1_PREFIXO + TSE1->E1_NUM + TSE1->E1_PARCELA + TSE1->E1_TIPO ) )
					Aviso("ATENวรO","Titulo nao localizado no bordero selecionado. Pref. "+Alltrim(TSE1->E1_PREFIXO)+" Tit. "+Alltrim(TSE1->E1_NUM)+" Prc."+TSE1->E1_PARCELA+" Tipo"+TSE1->E1_TIPO,{"OK"})
					Return
				endif
				
				//Posiciona na Arq de Parametros CNAB 
				//SEE->( DbSetOrder(1) )
				//if !SEE->( DbSeek(xFilial("SEE")+SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON)+"001",.T.) )
				  //	Aviso("ATENวรO","Erro na leitura dos parametros do banco do bordero gerado (Sub-conta diferente de 001),",{"OK"})
					//return
				//EndIf
				
				//Posiciona o SA6 (Bancos)
				SA6->( DbSetOrder(1) )
				if !SA6->( DbSeek(xFilial("SA6")+SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON) ,.T.) )
					Aviso("ATENวรO","Banco do bordero ("+Alltrim(SEA->EA_PORTADO)+" - "+Alltrim(SEA->EA_AGEDEP)+" - "+Alltrim(SEA->EA_NUMCON)+") nao localizado no cadastro de Bancos.",{"OK"})
					Return
				endif		
			EndIf
				
			if Empty(SEE->EE_CODEMP)
				Aviso("ATENวรO","Informar o convenio do banco no cadastro de parametros do banco (EE_CODEMP)!",{"OK"})
				return nil
			endif
			
			if Empty(SEE->EE_TABELA)
				Aviso("ATENวรO","Informar a tabela do banco no cadastro de parametros do banco (EE_TABELA)!",{"OK"})
				return nil
			endif
			
			_cConvenio := AllTrim(SEE->EE_CODEMP) // Tamanho de 7.
			_cCarteira := Alltrim(SEE->EE_XCART)
			
			if empty(SEE->EE_XCART)
				Aviso("ATENวรO","Favor informe o n๚mero da Carteira (EE_XCART)!",{"OK"})
				return nil
			endif
			//Posiciona o SA1 (Cliente)
			SA1->( DbSetOrder(1) )
			SA1->( DbSeek(xFilial("SA1")+TSE1->E1_CLIENTE+TSE1->E1_LOJA,.T.) )
			
			//Posiciona SCV (Pedidos X Formas de Pagamento)
			DbSelectArea("SCV")
			DbSetOrder(1)
			If SCV->(DbSeek(xFilial("SCV")+SE1->E1_PEDIDO+"BOL")) .AND. lSCV
				nPorcBol := SCV->CV_RATFOR
				nVlrBol := (TSE1->E1_SALDO *(nPorcBol/100))
			Else
				nVlrBol := TSE1->E1_SALDO
			EndIf 
			If TSE1->E1_SDACRES > 0
				nAcrescimo := 	TSE1->E1_SDACRES
			EndIf
			If SEE->EE_CODIGO == '001'  // Banco do Brasil
				aDadosBanco  := {SEE->EE_CODIGO          ,;	// [1]Numero do Banco
				"Banco do Brasil SA"     ,; //  era "BANCO BRASIL"     ,; // [2]Nome do Banco
				Substr(SEE->EE_AGENCIA,1,4)   ,;	// [3]Ag๊ncia
				Alltrim(SEE->EE_CONTA),; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA),; 	// [5]Dํgito da conta corrente
				_cCarteira ,; // [6]Codigo da Carteira
				"9" ,; // [7] Digito do Banco
				"Pagแvel em qualquer banco at้ o vencimento." ,; // [8] Local de Pagamento1
				"Ap๓s, atualize o boleto no site bb.com.br",; // [9] Local de Pagamento2
				SEE->EE_DVAGE,; 	//[10] Digito Verificador da agencia
				_cConvenio,;     //[11] C๓digo Cedente fornecido pelo Banco
				iif( SEE->(FieldPos("EE_CODEMP"))>0,SEE->EE_CODEMP, SEE->EE_CODEMP) }	//[12] C๓digo Cedente fornecido pelo Banco
				
			ElseIf SEE->EE_CODIGO == '341'  // Itau
				aDadosBanco  := {SEE->EE_CODIGO          ,;	// [1]Numero do Banco
				"Banco Ita๚ S.A."     ,; // [2]Nome do Banco
				Substr(SEE->EE_AGENCIA,1,4)   ,;	// [3]Ag๊ncia
				Alltrim(SEE->EE_CONTA),; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA),; 	// [5]Dํgito da conta corrente
				_cCarteira ,; // [6]Codigo da Carteira
				"7" ,; // [7] Digito do Banco
				"ATษ O VENCIMENTO, PREFERENCIALMENTE NO ITAฺ" ,; // [8] Local de Pagamento1
				"APำS O VENCIMENTO, SOMENTE NAS AGสNCIAS DO ITAฺ",; // [9] Local de Pagamento2
				SEE->EE_DVAGE,;//[10] Digito Verificador da agencia
				_cConvenio}	//[11] C๓digo Cedente fornecido pelo Banco
				
			ElseIf SEE->EE_CODIGO == '237'  // Bradesco
				aDadosBanco  := {SEE->EE_CODIGO          ,;	// [1]Numero do Banco
				"BRADESCO S.A."     ,; // [2]Nome do Banco
				Substr(SEE->EE_AGENCIA,1,4)   ,;	// [3]Ag๊ncia
				Alltrim(SEE->EE_CONTA),; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA),; 	// [5]Dํgito da conta corrente
				_cCarteira ,; // [6]Codigo da Carteira
				"2" ,; // [7] Digito do Banco
				"ATษ O VENCIMENTO, PREFERENCIALMENTE NAS AGสNCIAS BRADESCO" ,; // [8] Local de Pagamento1
				"APำS O VENCIMENTO, NAS AGสNCIAS DO BRADESCO",; // [9] Local de Pagamento2
				SEE->EE_DVAGE,;	//[10] Digito Verificador da agencia
				_cConvenio}	//[11] C๓digo Cedente fornecido pelo Banco
				
			ElseIf SEE->EE_CODIGO == '033'  				// Santander
				aDadosBanco  := {SEE->EE_CODIGO          	,;	// [1]Numero do Banco
				"SANTANDER S.A."     		,; // [2]Nome do Banco
				AllTrim(SEE->EE_AGENCIA)   ,;	// [3]Ag๊ncia
				Alltrim(SEE->EE_CONTA),; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA),; 	// [5]Dํgito da conta corrente ( e para ser vazio )
				"101"/*_cCarteira*/ ,; // [6]Codigo da Carteira
				"7" ,; // [7] Digito do Banco
				"PAGAR PREFERENCIALMENTE NO GRUPO SANTANDER - GC" ,; // [8] Local de Pagamento1
				""/*"APำS O VENCIMENTO, SOMENTE NAS AGสNCIAS DO SANTANDER"*/,; // [9] Local de Pagamento2
				SEE->EE_DVAGE,;	//[10] Digito Verificador da agencia
				_cConvenio}	//[11] C๓digo Cedente fornecido pelo Banco
				
			ElseIf SEE->EE_CODIGO == '756'  // Banco Sicoob
				aDadosBanco  := {SEE->EE_CODIGO          ,;		// [1]Numero do Banco
				"SICOOB"     ,; 				// [2]Nome do Banco
				AllTrim(SubStr(SEE->EE_AGENCIA,1,4)) ,;	// [3]Ag๊ncia
				AllTrim(SEE->EE_CONTA),; 		// [4]Conta Corrente -2
				AllTrim(SEE->EE_DVCTA),; 		// [5]Dํgito da conta corrente
				_cCarteira ,; 					// [6]Codigo da Carteira
				"0" ,; 						// [7] Digito do Banco
				"Pagแvel em qualquer banco at้ a data de vencimento." ,; // [8] Local de Pagamento1
				"",; // [9] Local de Pagamento2
				"",; 	//[10] Digito Verificador da agencia
				_cConvenio}	//[11] C๓digo Cedente fornecido pelo Banco
				
				
			elseif SEE->EE_CODIGO = "104" // Caixa 
				
				aDadosBanco  := {SEE->EE_CODIGO          ,;		// [1]Numero do Banco
				"CAIXA"     ,; 				// [2]Nome do Banco
				AllTrim(SubStr(SEE->EE_AGENCIA,1,4)) ,;	// [3]Ag๊ncia
				AllTrim(SEE->EE_CONTA),; 		// [4]Conta Corrente -2
				AllTrim(SEE->EE_DVCTA),; 		// [5]Dํgito da conta corrente
				_cCarteira ,; 					// [6]Codigo da Carteira
				"0" ,; 						// [7] Digito do Banco
				"PREFERENCIALMENTE NAS CASAS LOTษRICAS ATษ O VALOR LIMITE." ,; // [8] Local de Pagamento1
				"",; // [9] Local de Pagamento2
				SEE->EE_DVAGE,; 	//[10] Digito Verificador da agencia
				_cConvenio}	//[11] C๓digo Cedente fornecido pelo Banco
				
			elseif SEE->EE_CODIGO = "653" .OR. SEE->EE_CODIGO = "320" // Indusval e Bicbanco 
				
				//aDadosBanco  := {SEE->EE_CODIGO          ,;		// [1]Numero do Banco
				aDadosBanco  := {iif(SEE->EE_CODIGO="320","237",SEE->EE_CODIGO)          ,;		// [1]Numero do Banco. Foi
				"BRADESCO"     ,; 				// [2]Nome do Banco
				AllTrim(SubStr(SEE->EE_AGENCIA,1,4)) ,;	// [3]Ag๊ncia
				AllTrim(SEE->EE_CONTA),; 		// [4]Conta Corrente -2
				AllTrim(SEE->EE_DVCTA),; 		// [5]Dํgito da conta corrente
				_cCarteira ,; 					// [6]Codigo da Carteira
				"2" ,; 						// [7] Digito do Banco
				"ATษ O VENCIMENTO, PREFERENCIALMENTE NAS AGสNCIAS BRADESCO" ,; // [8] Local de Pagamento1
				"APำS O VENCIMENTO, NAS AGสNCIAS DO BRADESCO",; // [9] Local de Pagamento2
				SEE->EE_DVAGE,; 	//[10] Digito Verificador da agencia
				_cConvenio}	//[11] C๓digo Cedente fornecido pelo Banco
				
				
			ElseIf SEE->EE_CODIGO = "399"                                     
			
				aDadosBanco  := {"399"                                          ,; // [1]Numero do Banco
				"HSBC"             	                                            ,; // [2]Nome do Banco
				Alltrim(SEE->EE_AGENCIA)                                        ,; // [3]Ag๊ncia
				Alltrim(SEE->EE_CONTA) 											,; // [4]Conta Corrente
				AllTrim(SEE->EE_DVCTA)										   	,; // [5]Dํgito da conta corrente
				_cCarteira														,; // [6]Codigo da Carteira
				"9"                                                             ,; // [7]Digito do banco
				"PAGAR EM QUALQUER AGสNCIA BANCARIA ATษ O VENCIMENTO OU CANAIS ELETRONICOS DO HSBC" 		,; // [8]local de pagamento
				""																,; // [9]Local de Pagamento2
				SEE->EE_DVAGE													,; //[10] Digito Verificador da agencia	
				_cConvenio														}  //[11] C๓digo Cedente fornecido pelo Banco 
				
			ElseIf 	SEE->EE_CODIGO = "389"									 	
				aDadosBanco  := { "389"											,; // [1]Numero do Banco 
				"MERCANTIL DO BRASIL"                                           ,; // [2]Nome do Banco
				Alltrim(SEE->EE_AGENCIA)                                        ,; // [3]Ag๊ncia
				Alltrim(SEE->EE_CONTA) 											,; // [4]Conta Corrente
				AllTrim(SEE->EE_DVCTA)										   	,; // [5]Dํgito da conta corrente
				_cCarteira														,; // [6]Codigo da Carteira
				"9"                                                             ,; // [7]Digito do banco
				"ATษ O VENCIMENTO, PREFERENCIALMENTE NAS AGสNCIAS MERCANTIL" ,; // [8]local de pagamento
				""																,; // [9]Local de Pagamento2
				SEE->EE_DVAGE													,; //[10] Digito Verificador da agencia	
				_cConvenio														}  //[11] C๓digo Cedente fornecido pelo Banco
				
				
				
			Endif
			
			If Empty(SA1->A1_ENDCOB)
				aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Razใo Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      	// [2]C๓digo
				AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endere็o
				AllTrim(SA1->A1_MUN )                            ,;  		// [4]Cidade
				SA1->A1_EST                                      ,;     	// [5]Estado
				SA1->A1_CEP                                      ,;      	// [6]CEP
				SA1->A1_CGC										 ,;  		// [7]CGC
				SA1->A1_PESSOA									 ,;     	// [8]PESSOA
				SA1->A1_CXPOSTA                                  ,;         // [9]CAIXA POSTAL
				SA1->A1_COMPLEM                                  }			// [10] COMPLEMENTO
			Else
				aDatSacado   := {AllTrim(SA1->A1_NOME)            	,;   	// [1]Razใo Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;   	// [2]C๓digo
				AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endere็o
				AllTrim(SA1->A1_MUNC )	                            ,;   	// [4]Cidade
				SA1->A1_ESTC	                                    ,;   	// [5]Estado
				SA1->A1_CEPC                                        ,;   	// [6]CEP
				SA1->A1_CGC											,;		// [7]CGC
				SA1->A1_PESSOA										,;      // [8]PESSOA
				SA1->A1_CXPOSTA                                  	,;      // [9]CAIXA POSTAL
				SA1->A1_COMPLEM                                  	}		// [10] COMPLEMENTO
			Endif
			
			If lVencto // Se considera Vencimento Real
				dVencto := TSE1->E1_VENCREA
			Else	
			    dVencto := TSE1->E1_VENCTO
			EndIf 
			
			//nVlrAbat   :=  SomaAbat(TSE1->E1_PREFIXO,TSE1->E1_NUM,TSE1->E1_PARCELA,"R",1,,TSE1->E1_CLIENTE,TSE1->E1_LOJA,)
			nVlrAbat   	:=  SomaAbat(TSE1->E1_PREFIXO,TSE1->E1_NUM,TSE1->E1_PARCELA,"R",1,,TSE1->E1_CLIENTE,TSE1->E1_LOJA,cFilAnt,,TSE1->E1_TIPO)
			If TSE1->E1_SDDECRE > 0 
				nVlrAbat += TSE1->E1_SDDECRE
			EndIf
			//
			// Incrementa sequencia do nosso numero no parametro banco
			//
			_cont:=0
			DbSelectArea("SE1")
			SE1->( DBSetOrder(1) )
			SE1->(dbgotop())
			If SE1->( DBSeek(XFILIAL("SE1")+TSE1->E1_PREFIXO+TSE1->E1_NUM+TSE1->E1_PARCELA+TSE1->E1_TIPO) )
				
				If !Empty(SE1->E1_NUMBCO)
					cNroDoc 	:= Alltrim(SE1->E1_NUMBCO)
					cDigNosso 	:= SE1->E1_XDVNNUM
					_cont:=1
				Endif
				
			EndIf
			
			If Empty(cNroDoc)
				
				Begin Transaction 
				
				RecLock("SEE")	// Evitar Duplicidade
				
				If SEE->EE_CODIGO == '001'
					if Len( AllTrim(SEE->EE_CODEMP) ) < 7
						cNroDoc   := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),5)
						cDigNosso := Dig11BB(AllTrim(SEE->EE_CODEMP)+cNroDoc )		//CALC_di9(SEE->EE_CODEMP+cNosso)
					elseif Len( AllTrim(SEE->EE_CODEMP) ) == 7
						cNroDoc   := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),10)
						cDigNosso := ""	//DigitoBB(cNosso) Nao existe para este convenio
					else
						Aviso("ATENวรO","A quantidade de caracteres do Conv๊nio do Banco do Brasil tem que ser 6 ou 7!" +;
						" Conv๊nio encontrado: "+AllTrim(_cConvenio) +" quantidade de caracteres: "+ alltrim(str(len( AllTrim(_cConvenio))))  ,{"OK"})
						cNroDoc :=  ""
						cDigNosso := ""
						Return
					endif
					
				elseIf SEE->EE_CODIGO == '341'
					cNroDoc := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),8)
					
					//
					//  IDENTIFICAR PQ RETIRARAM A CARTEIRA PARA CALCULAR O DAC
					//
					cTexto    := aDadosBanco[03] + aDadosBanco[04] + aDadosBanco[6] + cNroDoc
					//cTexto    := Alltrim(aDadosBanco[03]) + Alltrim(aDadosBanco[04]) + cNroDoc
					cDigNosso := Modu10(cTexto)
					
				elseIf SEE->EE_CODIGO == '237'
					cNroDoc   := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),11)
					if aDadosBanco[6] == "02"
						cDigNosso := Modu11(Alltrim(aDadosBanco[6]) + cNroDoc , 7 )
					else
						cDigNosso := BradMod11(Alltrim(aDadosBanco[6]) + cNroDoc)
					endif
					
				elseIf SEE->EE_CODIGO $ '033'	// Santander nosso nr tem o tamanho fixo 12 + digito
					cNroDoc := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),12)
					cDigNosso := Dig11Santander(@cNroDoc)
					
					
				elseIf SEE->EE_CODIGO $ '756'	// SICOOB nosso nr tem o tamanho fixo 07
					cNroDoc   := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),7)
					cDigNosso := DigNNSicoob(cNroDoc,AllTrim(SEE->EE_CODEMP),AllTrim(SEE->EE_AGENCIA))
					
				elseIf SEE->EE_CODIGO $ '104'	//CAIXA nosso nr tem o tamanho fixo 07 
					
					If Empty(SE1->E1_NUMBCO)
						cNroDoc	  := "14"+STRZERO((VAL(ALLTRIM(SEE->EE_FAXATU))+1),15)//RetNN_CX()
						cDigNosso := Modu11(cNroDoc,,"CX")
					Else
						cNroDoc	 := TRANSFORM(SE1->E1_NUMBCO,'@R 99999999999999999-9')
						cDigNosso := Modu11(cNroDoc,,"CX")
					EndIf
					
				elseIf SEE->EE_CODIGO = "653" .OR. SEE->EE_CODIGO = "320" // Indusval e Bicbanco nosso nr tem o tamanho fixo  07 
					
					cNroDoc := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1),11)
					if SEE->EE_CODIGO = "320" //especifico do bicbanco valida็ใo Disbral
						cNroDoc := '18' + '335' + substr(cNroDoc,6,11)
					endif
					if aDadosBanco[6] == "02"
						cDigNosso := Modu11(Alltrim(aDadosBanco[6]) + cNroDoc , 7 )
					else
						cDigNosso := BradMod11(Alltrim(aDadosBanco[6]) + cNroDoc)
					endif
				 
				ElseIf SEE->EE_CODIGO = "399"
				
					cNroDoc := StrZero((Val(Alltrim(Left(SEE->EE_FAXATU,10)))+1), 10)//Codigo do convenio 5 digitos fornecido pelo banco + sequencial de 5 digitos
					cDigNosso := DIGITHSBC(cNroDoc)
						
				ElseIf SEE->EE_CODIGO = "389"
					cNroDoc := StrZero((Val(Alltrim(SEE->EE_FAXATU))+1), 11)
					cDigNosso := Modu10(cNroDoc)
				Else	
					cNroDoc := '9999999999'
				EndIf
				
			
				RecLock("SE1",.F.)
				SE1->E1_NUMBCO  := cNroDoc //aNossoN   // Nosso n๚mero (Ver f๓rmula para calculo)
				SE1->E1_XDVNNUM := cDigNosso // incluํda para gravar digito verificador do nosso n๚mero
				SE1->( MsUnlock() )
				
				If SEE->EE_CODIGO $ '104' // Tratamento para CAIXA tamanho 17
					// atuliza a faixa atual do parametro banco
					RecLock("SEE",.F.)
					SEE->EE_FAXATU := STRZERO((VAL(ALLTRIM(SEE->EE_FAXATU))+1),12)
					SEE->( MsUnlock() )
				Else
					RecLock("SEE",.F.)
					SEE->EE_FAXATU := cNroDoc
					SEE->( MsUnlock() )		
				EndIf
				
				End Transaction 
				//Fim
				
			Endif
			
			//
			//Monta codigo de barras
			//
			If SEE->EE_CODIGO = "399"                      
				aCB_RN_NN    := RetBarraHS(TSE1->E1_PREFIXO,TSE1->E1_NUM,TSE1->E1_PARCELA,TSE1->E1_TIPO,;
				Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4] ,aDadosBanco[5],;
				cNroDoc,(nVlrBol - nVlrAbat + nAcrescimo)	, aDadosBanco[6] ,"9"	)
			Else
				aCB_RN_NN    := Ret_cBarra(TSE1->E1_PREFIXO,TSE1->E1_NUM,TSE1->E1_PARCELA,TSE1->E1_TIPO,;
				Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4] ,aDadosBanco[5],;
				cNroDoc,(nVlrBol - nVlrAbat + nAcrescimo)	, aDadosBanco[6] ,"9"	)
			EndIf
			
			if len(aCB_RN_NN) == 0
				return nil
			endif
			   
			aDadosTit	:= {  	TSE1->E1_NUM + AllTrim(TSE1->E1_PARCELA)	,;  // [1] N๚mero do tํtulo
			TSE1->E1_EMISSAO                         	,; 	// [2] Data da emissใo do tํtulo
			dDataBase          							,;	// [3] Data da emissใo do boleto
			dVencto			                          	,; 	// [4] Data do vencimento
			(nVlrBol - nVlrAbat + nAcrescimo)			,;  // [5] Valor do tํtulo
			aCB_RN_NN[3]                       			,;  // [6] Nosso n๚mero (Ver f๓rmula para calculo) // de 3 coloquei 9
			TSE1->E1_PREFIXO							,;  // [7] Prefixo da NF
			IIf(SEE->EE_CODIGO = "399","PD","DM")		,;	// [8] Tipo do Titulo
			nVlrBol * (TSE1->E1_DESCFIN/100)  }		// [9] Desconto financeiro
			
			
			//------------------------------------------------------------------------------------------------------------------------------
			//				TEXTO PADRAO PARA MSG NO CORPO DO BOLETO
			//------------------------------------------------------------------------------------------------------------------------------
			
			aBolText[1] := iif( Empty(aBolText[1]),"", aBolText[1])
			
			
		   	if GetMV("MV_LJMULTA") > 0 .OR. nMulta > 0
		   		IF GetMV("MV_LJMULTA") > 0
					aBolText[8] := "Ap๓s Vencimento, Multa de "+ Transform(GetMV("MV_LJMULTA"),"@R 99.99%") +" no Valor de R$ "+AllTrim(Transform(((nVlrBol - nVlrAbat + nAcrescimo)*(GetMV("MV_LJMULTA")/100)),"@E 99,999.99"))
				ELSE
					aBolText[8] := "Ap๓s Vencimento, Multa de "+ Transform(nMulta,"@R 99.99%") +" no Valor de R$ "+AllTrim(Transform(((nVlrBol - nVlrAbat + nAcrescimo)*(nMulta/100)),"@E 99,999.99"))
				EndIf	
			endif
			
			if GetMV("MV_TXPER") > 0  .OR. nMora > 0
				If GetMV("MV_TXPER") > 0
			  		aBolText[4] := "Ap๓s Vencimento, Mora Diแria de "+ Transform(GetMV("MV_TXPER"),"@R 99.99%") +" no valor de R$ "+AllTrim(Transform(( ( (nVlrBol - nVlrAbat + nAcrescimo)*GetMV("MV_TXPER") )/100),"@E 99,999.99"))+"."
				Else
					aBolText[4] := "Ap๓s Vencimento, Mora Diแria de "+ Transform(nMora,"@R 99.99%") +" no valor de R$ "+AllTrim(Transform(( ( (nVlrBol - nVlrAbat + nAcrescimo)*nMora )/100),"@E 99,999.99"))+"."
				EndIf
			endif
			
			if aDadosTit[9] > 0  .and. aDadosTit[4] >= dDataBase
				aBolText[5] := "Desconto concedido de R$ "+AllTrim(Transform(aDadosTit[9] ,"@E 99,999.99"))+" para pagamento at้ a data de vencimento."
			else
				aBolText[5] := ""
			endif
			
			
			cProtesar := ""
			
			if SEE->EE_CODIGO == '001'
				cProtesar :=  SuperGetMv("MV_XPRO001") //"Protestar  5 dias ap๓s o Vencimento"
			ElseIf SEE->EE_CODIGO == '341' // Itau
				cProtesar :=  SuperGetMv("MV_XPRO341") //"Protestar  5 dias ap๓s o Vencimento"
			ElseIf SEE->EE_CODIGO == '237'  // Bradesco
				cProtesar :=  SuperGetMv("MV_XPRO237") //"Protestar  5 dias ap๓s o Vencimento"
			ElseIf SEE->EE_CODIGO == '033'  // Santander
				cProtesar :=  SuperGetMv("MV_XPRO033") //"Protestar  5 dias ap๓s o Vencimento"
			elseif SEE->EE_CODIGO = "104"  // Caixa
				cProtesar :=  SuperGetMv("MV_XPRO104") //"Protestar  5 dias ap๓s o Vencimento"
			elseif SEE->EE_CODIGO = "653" // Indusval
				cProtesar :=  SuperGetMv("MV_XPRO653") //"Protestar  5 dias ap๓s o Vencimento"
			elseif SEE->EE_CODIGO = "320" //Bicbanco
				cProtesar :=  SuperGetMv("MV_XPRO320") //"Protestar  5 dias ap๓s o Vencimento"
			elseif SEE->EE_CODIGO = "320" .OR. SEE->EE_CODIGO = "399"
				cProtesar :=  SuperGetMv("MV_XPRO399",,"Protestar  5 dias ap๓s o Vencimento") //"Protestar  5 dias ap๓s o Vencimento"	
			endif
			
			aBolText[6]	:= cProtesar
			
			if SEE->EE_CODIGO == '320'//ou seja bic banco
				aBolText[7]	:= "TITULO CEDIDO FIDUCIARIAMENTE, NรO PAGAR DIRETAMENTE AO SACADOR/ AVALISTA"
			endif
			//------------------------------------------------------------------------------------------------------------------------------
			
			Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,cNroDoc)
			nX := nX + 1
		EndIf
		
		TSE1->( dbSkip() )
		IncProc()
		nI += 1
	else
		TSE1->( dbSkip() )
		IncProc()
		nI += 1
	endif
Enddo
if lEntPeloMenosVez .AND. lPergBol
	oPrint:Preview()		// Visualiza antes de imprimir 
ElseIf !lPergBol	
	oPrint:Print()	
endif


Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณImpress   บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,aNossoN)
LOCAL oFont8
LOCAL oFont11c
LOCAL oFont10
LOCAL oFont14
LOCAL oFont16n
LOCAL oFont15
LOCAL oFont14n
LOCAL oFont24
LOCAL nI := 0

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)

oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)

oFont8   := TFont():New("Arial",9, 8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10n := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11n := TFont():New("Arial",9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12n := TFont():New("Arial",9,12,.T.,.f.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont19  := TFont():New("Arial",9,19,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova pแgina

/******************/
/* PRIMEIRA PARTE */
/******************/
nRow1	:= 0
nRowSay := 035

oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
oPrint:Line (nRow1+0150,710,nRow1+0070, 710)

oPrint:Say(nRowSay+0095,513,aDadosBanco[1]+"-"+aDadosBanco[7] ,oFont20 )	// [1]Numero do Banco   + [7] DV Banco

if ALLTRIM(SEE->EE_CODIGO) == "033"
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow1+0070,100,cStartPath+"santander.bmp",400,075)
ElseIf ALLTRIM(SEE->EE_CODIGO) == "399"
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow1+0070,90,cStartPath+"hsbc.bmp",400,075)
ElseIf ALLTRIM(SEE->EE_CODIGO) == "104"
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow1+0070,90,cStartPath+"caixa.bmp",400,075)
ElseIf ALLTRIM(SEE->EE_CODIGO) == "001"
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow1+0070,90,cStartPath+"bb.bmp",400,075)		
else
	oPrint:Say(nRowSay+0095,100,aDadosBanco[2],oFont12 )					// [2]Nome do Banco	
endif

oPrint:Say(nRowSay+0084,1900,"Comprovante de Entrega",oFont10n)
oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

oPrint:Say(nRowSay+0150,100 ,"Beneficiแrio",oFont8)

if ALLTRIM(SEE->EE_CODIGO) != "320" //diferente de bicbanco 
	oPrint:Say(nRowSay+0200,100 ,aDadosEmp[1],oFont10n)				//Nome + CNPJ
else
	oPrint:Say(nRowSay+0200,100 ,"Banco Industrial e Comercial (BICBANCO) CNPJ: 07.450.604/0001-89",oFont10n)				//Nome + CNPJ
endif


oPrint:Say(nRowSay+0150,1060,"Ag๊ncia\Codigo do Beneficiแrio",oFont8)

If aDadosBanco[1] == '001' .OR. aDadosBanco[1] == '399' 
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[04]+'-'+aDadosBanco[05]))
ElseIF aDadosBanco[1] == '104'
	cString := Alltrim(aDadosBanco[3]+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]))
ElseIf aDadosBanco[1] == '237'
	cString := Alltrim(StrZero(Val(aDadosBanco[3]),4)+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+IIF(!EMPTY(aDadosBanco[5]),StrZero(Val(aDadosBanco[4]),7)+"-"+aDadosBanco[5],StrZero(Val(Left(aDadosBanco[4],len(aDadosBanco[4])-1)),7)+"-"+Right(aDadosBanco[4],1)))	
Else
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]))
EndIf

oPrint:Say(nRowSay+0150,1510,"Nro.Documento",oFont8)
oPrint:Say(nRowSay+0200,1510,aDadosTit[7]+aDadosTit[1],oFont10n) //Prefixo +Numero+Parcela



oPrint:Say(nRowSay+0250,100 ,"Pagador",oFont8)

oPrint:Say(nRowSay+0300,100 ,aDatSacado[1],oFont10n)				//Nome

oPrint:Say(nRowSay+0250,1060,"Vencimento",oFont8)
oPrint:Say(nRowSay+0300,1060,StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4),oFont10n)

oPrint:Say(nRowSay+0250,1510,"Valor do Documento",oFont8)
oPrint:Say(nRowSay+0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10n)

oPrint:Say(nRowSay+0400,0100,"Recebi(emos) o bloqueto/tํtulo",oFont10)
oPrint:Say(nRowSay+0430,0100,"com as caracterํsticas acima.",oFont10)

oPrint:Say(nRowSay+0350,1060,"Data",oFont8)
oPrint:Say(nRowSay+0350,1410,"Assinatura",oFont8)
oPrint:Say(nRowSay+0450,1060,"Data",oFont8)
oPrint:Say(nRowSay+0450,1410,"Entregador",oFont8)

oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 ) //---
oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 ) //--
oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

oPrint:Say(nRowSay+0165,1910,"(  )Mudou-se"               ,oFont10n)
oPrint:Say(nRowSay+0195,1910,"(  )Ausente"                ,oFont10n)
oPrint:Say(nRowSay+0225,1910,"(  )Nใo existe nบ indicado" ,oFont10n)
oPrint:Say(nRowSay+0255,1910,"(  )Recusado"               ,oFont10n)
oPrint:Say(nRowSay+0285,1910,"(  )Nใo procurado"          ,oFont10n)
oPrint:Say(nRowSay+0315,1910,"(  )Endere็o insuficiente"  ,oFont10n)
oPrint:Say(nRowSay+0345,1910,"(  )Desconhecido"           ,oFont10n)
oPrint:Say(nRowSay+0375,1910,"(  )Falecido"               ,oFont10n)
oPrint:Say(nRowSay+0405,1910,"(  )Outros(anotar no verso)",oFont10n)


/*****************/
/* SEGUNDA PARTE */
/*****************/
nRow2  := 000
nRowSay:= 035

//Pontilhado separador
For nI := 100 to 2300 step 50
	oPrint:Line(nRow2+0590, nI,nRow2+0590, nI+30)
Next nI

oPrint:Line (nRow2+0710,100,nRow2+0710,2300)
oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

oPrint:Say(nRowSay+0660,518,aDadosBanco[1]+"-"+aDadosBanco[7],oFont20 )	// [1]Numero do Banco

if ALLTRIM(SEE->EE_CODIGO) == "033"
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow2+0630,100,cStartPath+"santander.bmp",400,075)
ElseIf ALLTRIM(SEE->EE_CODIGO) == "399"
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow2+0630,90,cStartPath+"hsbc.bmp",400,075)
ElseIf aDadosBanco[1] == '104'	
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow2+0630,90,cStartPath+"caixa.bmp",400,075)
ElseIf aDadosBanco[1] == '001'	
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow2+0630,90,cStartPath+"bb.bmp",400,075)	
else
	oPrint:Say(nRowSay+0660,100,aDadosBanco[2],oFont12 )					// [2]Nome do Banco	
endif
                            
//oPrint:Say(nRowSay+0660,100,aDadosBanco[2],oFont12 )		// [2]Nome do Banco

//oPrint:SayBitmap(nRow2+0630,100,"\BBrasil.bmp",400,075)	// Figura do Banco do Brasil
oPrint:Say(nRowSay+0644,1800,"Recibo do Pagador",oFont10n)

oPrint:Line (nRow2+0810,100,nRow2+0810,2300 )
oPrint:Line (nRow2+0910,100,nRow2+0910,2300 )
oPrint:Line (nRow2+0980,100,nRow2+0980,2300 )
oPrint:Line (nRow2+1050,100,nRow2+1050,2300 )

oPrint:Line (nRow2+0910,500,nRow2+1050,500)
oPrint:Line (nRow2+0980,750,nRow2+1050,750)
oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

oPrint:Say(nRowSay+0710,100 ,"Local de Pagamento",oFont8)
oPrint:Say(nRowSay+0730,400 ,aDadosBanco[8] ,oFont10n)
oPrint:Say(nRowSay+0760,400 ,aDadosBanco[9] ,oFont10n)

oPrint:Say(nRowSay+0710,1810,"Vencimento"                                     ,oFont8)
cString	:= StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4)
nCol := 1930+(374-(len(cString)*22))
oPrint:Say(nRowSay+0750,nCol,cString,oFont12)


oPrint:Say(nRowSay+0805,100 ,"Beneficiแrio"                                   ,oFont8)


if ALLTRIM(SEE->EE_CODIGO) != "320" //diferente de bicbanco
	oPrint:Say(nRowSay+0835,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10n) //Nome + CNPJ
	oPrint:Say(nRowSay+0870,100 ,Alltrim(aDadosEmp[2])+", "+aDadosEmp[4]+" - "+aDadosEmp[3]	,oFont10n) //Ende็o + CEP
else
	oPrint:Say(nRowSay+0870,100 ,"Banco Industrial e Comercial (BICBANCO)",oFont10n)				//Nome + CNPJ
endif

oPrint:Say(nRowSay+0810,1810,"Ag๊ncia\Codigo do Beneficiแrio",oFont8)


If aDadosBanco[1] == '001' .or. aDadosBanco[1] == '399' 
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[04]+'-'+aDadosBanco[05]))
ElseIf aDadosBanco[1] == '104'
	cString := Alltrim(aDadosBanco[3]+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]))
ElseIf aDadosBanco[1] == '237'
	cString := Alltrim(StrZero(Val(aDadosBanco[3]),4)+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+IIF(!EMPTY(aDadosBanco[5]),StrZero(Val(aDadosBanco[4]),7)+"-"+aDadosBanco[5],StrZero(Val(Left(aDadosBanco[4],len(aDadosBanco[4])-1)),7)+"-"+Right(aDadosBanco[4],1)))	
Else
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]))
EndIf

nCol := 1883+(374-(len(cString)*22))
oPrint:Say(nRowSay+0865,nCol,cString,oFont11c)

oPrint:Say(nRowSay+0910,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say(nRowSay+0940,100, StrZero(Day((aDadosTit[2])),2) +"/"+ StrZero(Month((aDadosTit[2])),2) +"/"+ Right(Str(Year((aDadosTit[2]))),4),oFont10n)

oPrint:Say(nRowSay+0910,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say(nRowSay+0940,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10n) //Prefixo +Numero+Parcela

oPrint:Say(nRowSay+0910,1005,"Esp้cie Doc."                                   ,oFont8)
oPrint:Say(nRowSay+0940,1050,aDadosTit[8]										,oFont10n) //Tipo do Titulo

oPrint:Say(nRowSay+0910,1305,"Aceite"                                         ,oFont8)
oPrint:Say(nRowSay+0940,1400,"N"                                             ,oFont10n)

oPrint:Say(nRowSay+0910,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say(nRowSay+0940,1550,StrZero(Day((aDadosTit[3])),2) +"/"+ StrZero(Month((aDadosTit[3])),2) +"/"+ Right(Str(Year((aDadosTit[3]))),4),oFont10n) // Data impressao

oPrint:Say(nRowSay+0910,1810,"Nosso N๚mero"                                   ,oFont8)

If aDadosBanco[1] == '001'
	cString := Substr(aDadosTit[6],1,3) + Substr(aDadosTit[6],4) + iif( Len(AllTrim(SEE->EE_CODEMP))>=7,"", "-" + SE1->E1_XDVNNUM)
else
	cString := Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)
Endif

nCol := 1870+(374-(len(cString)*22))
oPrint:Say(nRowSay+0940,nCol,' '+cString,oFont11c)

oPrint:Say(nRowSay+0980,100 ,"Uso do Banco"                                   ,oFont8)

if aDadosBanco[4] == '0000320' //ou seja bicbanco
	oPrint:Say(nRowSay+1010,105 ,"Expressa"                                   ,oFont8)
	oPrint:Say(nRowSay+0980,450 ,"CIP"		                                   ,oFont8)
	oPrint:Say(nRowSay+1010,455 ,"521"                                   	   ,oFont8)
endif

oPrint:Say(nRowSay+0980,505 ,"Carteira"                                       ,oFont8)
oPrint:Say(nRowSay+1010,555 ,aDadosBanco[6]                                  	,oFont10n)

If aDadosBanco[1] == '104'
oPrint:Say(nRowSay+0980,755 ,"Esp้cie Moeda"                                  ,oFont8) // Altera็ใo nome do campo
Else
oPrint:Say(nRowSay+0980,755 ,"Esp้cie" 		                                  ,oFont8) 
EndIf

oPrint:Say(nRowSay+1010,805 ,"R$"                                             ,oFont10n)


If aDadosBanco[1] == '104'
oPrint:Say(nRowSay+0980,1005,"Quantidade Moeda"                               ,oFont8) // Altera็ใo nome do campo
Else
oPrint:Say(nRowSay+0980,1005,"Quantidade"                                     ,oFont8)
EndIf

oPrint:Say(nRowSay+0980,1485,"Valor"                                          ,oFont8)


If aDadosBanco[1] == '104'
oPrint:Say(nRowSay+0980,1810,"(=)Valor do Documento"                          ,oFont8) // Altera็ใo nome do campo
Else
oPrint:Say(nRowSay+0980,1810,"Valor do Documento"                          	  ,oFont8)
EndIf

cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol := 1863+(374-(len(cString)*22))
oPrint:Say(nRowSay+1010,nCol,cString ,oFont11c)

oPrint:Say(nRowSay+1035,100 ,"Instru็๕es (Todas informa็๕es deste bloqueto sใo de exclusiva responsabilidade do Beneficiแrio)",oFont8)
oPrint:Say(nRowSay+1080,100 ,"ATENวรO SR. CAIXA:",oFont10n)
oPrint:Say(nRowSay+1110,100 ,aBolText[1],oFont10n)
oPrint:Say(nRowSay+1140,100 ,aBolText[2],oFont10n)
oPrint:Say(nRowSay+1170,100 ,aBolText[3],oFont10n)
oPrint:Say(nRowSay+1200,100 ,aBolText[4],oFont10n)
oPrint:Say(nRowSay+1230,100 ,aBolText[5],oFont10n)
oPrint:Say(nRowSay+1260,100 ,aBolText[6],oFont10n)
oPrint:Say(nRowSay+1300,100 ,aBolText[8],oFont10n)

if aDadosBanco[4] == '0000320' //ou seja bicbanco
	oPrint:Say(nRowSay+1340,100 ,aBolText[7],oFont10n)
endif

// MSG dos Parametros
if !Empty(MV_PAR21)
	oPrint:Say(nRowSay+1360,100, AllTrim(MV_PAR21) + " - " + AllTrim(MV_PAR22),oFont10n)
endif

oPrint:Say(nRowSay+1050,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say(nRowSay+1120,1810,"(-)Outras Dedu็๕es"                             ,oFont8)

If aDadosBanco[1] == '104'
oPrint:Say(nRowSay+1190,1810,"(+)Mora/Multa/Juros"                            ,oFont8) // Altera็ใo nome do campo
Else
oPrint:Say(nRowSay+1190,1810,"(+)Mora/Multa"                                  ,oFont8)
EndIf

oPrint:Say(nRowSay+1260,1810,"(+)Outros Acr้scimos"                           ,oFont8)
oPrint:Say(nRowSay+1330,1810,"(=)Valor Cobrado"                               ,oFont8)

if aDadosTit[9] > 0 .and. aDadosTit[4] >= dDataBase
	cString := Alltrim(Transform( aDadosTit[9],"@E 999,999,999.99"))
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say(nRowSay+1080,nCol,cString,oFont11c)
endif


oPrint:Say(nRowSay+1400,100 ,"Pagador",oFont8)
oPrint:Say(nRowSay+1530,100 ,"Caixa Postal",oFont8)

If aDadosBanco[1] == '104' // Ajuste no posicionamento
oPrint:Say(nRowSay+1405,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10n)
oPrint:Say(nRowSay+1465,400 ,aDatSacado[3]                                    ,oFont10n)
oPrint:Say(nRowSay+1495,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10n) // CEP+Cidade+Estado
oPrint:Say(nRowSay+1525,400 ,aDatSacado[10]                                    ,oFont10n)
oPrint:Say(nRowSay+1555,400 ,aDatSacado[9]                                    ,oFont10n) 
Else
oPrint:Say(nRowSay+1405,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10n)
oPrint:Say(nRowSay+1445,400 ,aDatSacado[3]                                    ,oFont10n)
oPrint:Say(nRowSay+1470,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10n) // CEP+Cidade+Estado
oPrint:Say(nRowSay+1500,400 ,aDatSacado[10]                                    ,oFont10n)
oPrint:Say(nRowSay+1535,400 ,aDatSacado[9]                                    ,oFont10n) 
EndIf

if aDadosBanco[4] != '0000320' //ou seja bicbanco  ou seja diferente de bicbanco
	if aDatSacado[8] = "J"
		If aDadosBanco[1] == '104'
		oPrint:Say(nRowSay+1405,1810 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n) // CGC Ajuste no posicionamento
		Else
		oPrint:Say(nRowSay+1580,400 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n) // CGC
		EndIf
	Else
		If aDadosBanco[1] == '104'
		oPrint:Say(nRowSay+1405,1810 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10n) 	// CPF Ajuste no posicionamento
		Else
		oPrint:Say(nRowSay+1580,400 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10n) 	// CPF
		EndIf
	EndIf
else   //bicbanco No campo sacador/avalista, favor informar a razใo social e CNPJ da Disbral
	oPrint:Say(nRowSay+1580,400 ,ALLTRIM(aDadosEmp[1])+" - "+alltrim(aDadosEmp[6]),oFont10n) 	// CPF
endif

oPrint:Say(nRowSay+1560,100 ,"Sacador/Avalista",oFont8)

// Solicitado no Layout CEF (este campo deve estar em branco). 
If aDadosBanco[1] == '104'
	oPrint:Say(nRowSay+1560,1810 ,"CPF/CNPJ:",oFont8) 
EndIf

If aDadosBanco[1] == '104' 
oPrint:Say(nRowSay+1620,100 ,"SAC CAIXA: 0800 726 0101 (informa็๕es, reclama็๕es, sugest๕es e elogios)",oFont8)
oPrint:Say(nRowSay+1645,100 ,"Para pessoas com defici๊ncia auditiva ou de fala: 0800 726 2492",oFont8)
oPrint:Say(nRowSay+1670,100 ,"Ouvidoria: 0800 725 7474",oFont8)
oPrint:Say(nRowSay+1695,100 ,"caixa.gov.br",oFont8)
EndIf

oPrint:Say(nRowSay+1620,1550,"Autentica็ใo Mecโnica",oFont8)


oPrint:Line (nRow2+0710,1800,nRow2+1400,1800 )
oPrint:Line (nRow2+1120,1800,nRow2+1120,2300 )
oPrint:Line (nRow2+1190,1800,nRow2+1190,2300 )
oPrint:Line (nRow2+1260,1800,nRow2+1260,2300 )
oPrint:Line (nRow2+1330,1800,nRow2+1330,2300 )
oPrint:Line (nRow2+1400,100 ,nRow2+1400,2300 )
oPrint:Line (nRow2+1640,100 ,nRow2+1640,2300 )


/******************/
/* TERCEIRA PARTE */
/******************/

nRow3   := -80

For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+1860, nI, nRow3+1860, nI+30)
Next nI

nRowSay := -85
nRow3   := -110

oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

//oPrint:SayBitmap(nRow3+1922,100,"\BBrasil.bmp",400,075)			// [2]Nome do Banco

if ALLTRIM(SEE->EE_CODIGO) == "033"
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow3+1922,100,cStartPath+"santander.bmp",400,075)
ElseIf ALLTRIM(SEE->EE_CODIGO) == "399"
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow3+1920,90,cStartPath+"hsbc.bmp",400,075)
ElseIf aDadosBanco[1] == '104'	
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow3+1920,90,cStartPath+"caixa.bmp",400,075)
ElseIf aDadosBanco[1] == '001'	
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow3+1920,90,cStartPath+"bb.bmp",400,075)	
else
	oPrint:Say(nRowSay+1945,100,aDadosBanco[2],oFont12 )					// [2]Nome do Banco	
endif

//oPrint:Say(nRowSay+1945,100,aDadosBanco[2],oFont12 )		// 	[2]Nome do Banco

oPrint:Say(nRowSay+1945,518,aDadosBanco[1]+"-"+aDadosBanco[7],oFont20 )	// 	[1]Numero do Banco
oPrint:Say(nRowSay+1945,730,aCB_RN_NN[2],oFont19)			//	Linha Digitavel do Codigo de Barras 
//oPrint:Say(nRowSay+1945,755,aCB_RN_NN[2],oFont20)			//	Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

oPrint:Say(nRowSay+2000,100 ,"Local de Pagamento",oFont8)
oPrint:Say(nRowSay+2020,400 ,aDadosBanco[8],oFont10n)
oPrint:Say(nRowSay+2055,400 ,aDadosBanco[9],oFont10n)

oPrint:Say(nRowSay+2000,1810,"Vencimento",oFont8)

cString := StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4)
nCol	 	 := 1930+(374-(len(cString)*22))
oPrint:Say(nRowSay+2045,nCol,cString,oFont12)



oPrint:Say(nRowSay+2100,100 ,"Beneficiแrio",oFont8)

if ALLTRIM(SEE->EE_CODIGO) != "320" //diferente de bicbanco
	oPrint:Say(nRowSay+2150,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10n) //Nome + CNPJ
else
	oPrint:Say(nRowSay+2150,100 ,"Banco Industrial e Comercial (BICBANCO)",oFont10n)				//Nome + CNPJ
endif

oPrint:Say(nRowSay+2100,1810,"Ag๊ncia\Codigo do Beneficiแrio",oFont8)

If aDadosBanco[1] == '001' .or. aDadosBanco[1] == '399' 
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[04]+'-'+aDadosBanco[05]))
ElseIf aDadosBanco[1] == '104'  
	cString := Alltrim(aDadosBanco[3]+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5],aDadosBanco[11]))
ElseIf aDadosBanco[1] == '237'
	cString := Alltrim(StrZero(Val(aDadosBanco[3]),4)+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+IIF(!EMPTY(aDadosBanco[5]),StrZero(Val(aDadosBanco[4]),7)+"-"+aDadosBanco[5],StrZero(Val(Left(aDadosBanco[4],len(aDadosBanco[4])-1)),7)+"-"+Right(aDadosBanco[4],1)))
Else
	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5],aDadosBanco[11]))
EndIf

nCol 	 := 1883+(374-(len(cString)*22))
oPrint:Say(nRowSay+2150,nCol,cString ,oFont11c)

oPrint:Say (nRowSay+2200,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say (nRowSay+2230,100, StrZero(Day((aDadosTit[2])),2) +"/"+ StrZero(Month((aDadosTit[2])),2) +"/"+ Right(Str(Year((aDadosTit[2]))),4), oFont10n)

oPrint:Say(nRowSay+2200,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say(nRowSay+2230,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10n) //Prefixo +Numero+Parcela

oPrint:Say(nRowSay+2200,1005,"Esp้cie Doc."                                   ,oFont8)
oPrint:Say(nRowSay+2230,1050,aDadosTit[8]										,oFont10n) //Tipo do Titulo

oPrint:Say(nRowSay+2200,1305,"Aceite"                                         ,oFont8)
oPrint:Say(nRowSay+2230,1400,"N"                                             ,oFont10n)

oPrint:Say(nRowSay+2200,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say(nRowSay+2230,1550,StrZero(Day((aDadosTit[3])),2) +"/"+ StrZero(Month((aDadosTit[3])),2) +"/"+ Right(Str(Year((aDadosTit[3]))),4)                               ,oFont10n) // Data impressao

oPrint:Say(nRowSay+2200,1810,"Nosso N๚mero"                                   ,oFont8)

If aDadosBanco[1] == '001'
	cString := Substr(aDadosTit[6],1,3) + Substr(aDadosTit[6],4) + iif( Len(AllTrim(SEE->EE_CODEMP))>=7,"", "-" + SE1->E1_XDVNNUM)
else
	cString := Alltrim(Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4))
Endif

nCol 	 := 1870+(374-(len(cString)*22))
oPrint:Say(nRowSay+2230,nCol,' '+cString,oFont11c)

oPrint:Say(nRowSay+2270,100 ,"Uso do Banco"                                   ,oFont8)

if aDadosBanco[4] == '0000320' //ou seja bicbanco
	oPrint:Say(nRowSay+2300,105 ,"Expressa"                                   ,oFont8)
	oPrint:Say(nRowSay+2270,450 ,"CIP"		                                   ,oFont8)
	oPrint:Say(nRowSay+2300,455 ,"521"                                   	   ,oFont8)
endif

oPrint:Say(nRowSay+2270,505 ,"Carteira"                                       ,oFont8)
oPrint:Say(nRowSay+2300,555 ,aDadosBanco[6]                                  	,oFont10n)


If aDadosBanco[1] == '104'
oPrint:Say(nRowSay+2270,755 ,"Esp้cie Moeda"                                  ,oFont8) // Altera็ใo nome do campo
Else
oPrint:Say(nRowSay+2270,755 ,"Esp้cie"                                        ,oFont8)
EndIf

oPrint:Say(nRowSay+2300,805 ,"R$"                                             ,oFont10n)

If aDadosBanco[1] == '104'
oPrint:Say(nRowSay+2270,1005,"Quantidade Moeda"                               ,oFont8) // Altera็ใo nome do campo
Else
oPrint:Say(nRowSay+2270,1005,"Quantidade"                                     ,oFont8)
EndIf

oPrint:Say(nRowSay+2270,1485,"Valor"                                          ,oFont8)


If aDadosBanco[1] == '104'
oPrint:Say(nRowSay+2270,1810,"(=)Valor do Documento"                          	,oFont8) // Altera็ใo nome do campo
Else
oPrint:Say(nRowSay+2270,1810,"Valor do Documento"                          	,oFont8)
EndIf

cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol 	 := 1884+(374-(len(cString)*22))
oPrint:Say(nRowSay+2300,nCol-20,cString,oFont11c)
//oPrint:Say(nRowSay+2300,nCol,cString,oFont11c) 

oPrint:Say(nRowSay+2340,100 ,"Instru็๕es (Todas informa็๕es deste bloqueto sใo de exclusiva responsabilidade do Beneficiแrio)",oFont8)
oPrint:Say(nRowSay+2380,100 ,"ATENวรO SR. CAIXA:",oFont10n)
oPrint:Say(nRowSay+2410,100 ,aBolText[1],oFont10n)
oPrint:Say(nRowSay+2440,100 ,aBolText[2],oFont10n)
oPrint:Say(nRowSay+2470,100 ,aBolText[3],oFont10n)
oPrint:Say(nRowSay+2500,100 ,aBolText[4],oFont10n)
oPrint:Say(nRowSay+2530,100 ,aBolText[5],oFont10n)
oPrint:Say(nRowSay+2560,100 ,aBolText[6],oFont10n)
oPrint:Say(nRowSay+2590,100 ,aBolText[8],oFont10n)
if aDadosBanco[4] == '0000320' //ou seja bicbanco
	oPrint:Say(nRowSay+2620,100 ,aBolText[7],oFont10n)
endif



If _cont = 1 .and. Empty(aBolText[4]+aBolText[5])
	oPrint:Say(nRowSay+2590,100 ,"/////ATENวรO/////--> SEGUNDA VIA",oFont10n)
EndIf

if !Empty(MV_PAR21)
	oPrint:Say(nRowSay+2640,100 ,AllTrim(MV_PAR21) + " - " + AllTrim(MV_PAR22),oFont10n)
endif

oPrint:Say(nRowSay+2340,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say(nRowSay+2410,1810,"(-)Outras Dedu็๕es"                             ,oFont8)

If aDadosBanco[1] == '104'
oPrint:Say(nRowSay+2480,1810,"(+)Mora/Multa/Juros"                            ,oFont8) // Altera็ใo nome do campo
Else
oPrint:Say(nRowSay+2480,1810,"(+)Mora/Multa"                                  ,oFont8)
EndIf

oPrint:Say(nRowSay+2550,1810,"(+)Outros Acr้scimos"                           ,oFont8)
oPrint:Say(nRowSay+2620,1810,"(=)Valor Cobrado"                               ,oFont8)


oPrint:Say(nRowSay+2690,100 ,"Pagador",oFont8)

If aDadosBanco[1] == '104' // Ajuste no posicionamento
oPrint:Say(nRowSay+2700,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10n)
oPrint:Say(nRowSay+2753,400 ,aDatSacado[3]                                    ,oFont10n)
oPrint:Say(nRowSay+2783,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10n) // CEP+Cidade+Estado
Else
oPrint:Say(nRowSay+2700,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10n)
oPrint:Say(nRowSay+2743,400 ,aDatSacado[3]                                    ,oFont10n)
oPrint:Say(nRowSay+2786,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10n) // CEP+Cidade+Estado
EndIf

if aDadosTit[9] > 0  .and. aDadosTit[4] >= dDataBase
	cString := Alltrim(Transform(aDadosTit[9],"@E 999,999,999.99"))
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say(nRowSay+2370,nCol,cString,oFont11c)
endif

//nRow3 -= 015
oPrint:Say  (nRow3+2875,100 ,"Sacador/Avalista"                               ,oFont8) 

// Solicitado no Layout CEF (este campo deve estar em branco). 
If aDadosBanco[1] == '104'
	oPrint:Say(nRow3+2875,1810 ,"CPF/CNPJ:",oFont8) 
EndIf

if aDadosBanco[4] != '0000320' //ou seja diferente de bicbanco
	if aDatSacado[8] = "J"
		If aDadosBanco[1] == '104'
		oPrint:Say(nRowSay+2700,1810 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n) // CGC - Ajuste no posicionamento
		Else
		oPrint:Say(nRowSay+2870,400 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n) // CGC
		EndIf
	Else
		If aDadosBanco[1] == '104'
		oPrint:Say(nRowSay+2700,1810 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10n) 	// CPF - Ajuste no posicionamento
		Else
		oPrint:Say(nRowSay+2870,400 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10n) 	// CPF
		EndIf		
	EndIf
else   //bicbanco - No campo sacador/avalista, favor informar a razใo social e CNPJ da Disbral
	oPrint:Say(nRowSay+2870,400 ,ALLTRIM(aDadosEmp[1])+" - "+alltrim(aDadosEmp[6]),oFont10n) // CGC
endif
oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )
oPrint:Line (nRow3+2920,100,nRow3+2920,2300  )

oPrint:Say(nRowSay+2915,1820,"Autentica็ใo Mecโnica - Ficha de Compensa็ใo"   ,oFont8)

// FWMsBar(cTypeBar, nRow, nCol, cCode,oPrint,lCheck,Color,lHorz, nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)-->
if aDadosBanco[4] != '0000320' //ou seja bicbanco
	
	oPrint:FwMsBar("INT25" /*cTypeBar*/, 66 /*nRow*/, 2.40 /*nCol*/,;
	aCB_RN_NN[1] /*cCode*/, oPrint, .F. /*Calc6. Digito Verif*/,;
	/*Color*/, /*Imp. na Horz*/, 0.025 /*Tamanho*/, 0.85 /*Altura*/, , , ,.F. )
else //se bicbanco
	
	oPrint:FwMsBar("INT25" /*cTypeBar*/, 66.5 /*nRow*/, 2.40 /*nCol*/,;
	aCB_RN_NN[1] /*cCode*/, oPrint, .F. /*Calc6. Digito Verif*/,;
	/*Color*/, /*Imp. na Horz*/, 0.025 /*Tamanho*/, 0.85 /*Altura*/, , , ,.F. )
	
endif
oPrint:EndPage() // Finaliza a pแgina
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณRet_cBarraบ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ret_cBarra(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
cBanco		,cAgencia	,cConta		,cDacCC	,;
cNroDoc		,nValor		,cCart		,cMoeda	)

Local cNosso		:= ""
Local NNUM			:= ""
Local cCampoL		:= ""
Local cFatorValor	:= ""
Local cLivre		:= ""
Local cDigBarra		:= ""
Local cBarra		:= ""
Local cParte1		:= ""
Local cDig1			:= ""
Local cParte2		:= ""
Local cDig2			:= ""
Local cParte3		:= ""
Local cDig3			:= ""
Local cParte4		:= ""
Local cParte5		:= ""
Local cDigital		:= ""
Local cTexto        := ""
Local aRet			:= {}
Local cFatVencto	:= "" 
Local _cConta      	:= ""
//Local cDigNosso     := ""	//CALC_di9(cNosso) - Nao existe para este convenio



//DEFAULT nValor := 0
cAgencia   := StrZero(Val(Right(cAgencia,4)),4)
cNosso     := ""

cEOL := CHR(10)

if cBanco == '001'
	if (len( AllTrim(_cConvenio) ) != 6) .and. len( AllTrim(_cConvenio) ) != 7
		Aviso("ATENวรO","A quantidade de caracteres do Conv๊nio do Banco do Brasil tem que ser 6 ou 7!" +;
		" Conv๊nio encontrado: "+AllTrim(_cConvenio) +" quantidade de caracteres: "+ alltrim(str(len( AllTrim(_cConvenio))))  ,{"OK"})
		Return
	endif
endif

If cBanco == '001' .and. len( AllTrim(_cConvenio) ) == 6 	// Banco do Brasil
	//
	// CONVENIO 6 POSICOES
	//
	
	cConta	   := StrZero( val(cConta),8)
	cNosso     := _cConvenio + cNroDoc
	cDigNosso  := CALC_di9(cNosso)
	cCart      := cCart
	
	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
	Endif
	
	// campo livre
	cCampoL    := _cConvenio + cNroDoc + cAgencia + cConta + cCart
	
	// campo do digito verificador do codigo de barra
	cLivre := cBanco+cMoeda+cFatorValor+cCampoL
	cDigBarra := CALC_5p( cLivre )
	
	// campo do codigo de barra
	cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)
	
	// composicao da linha digitavel
	cParte1  := cBanco + cMoeda + Substr(_cConvenio,1,5)
	cDig1    := DIGIT001( cParte1 )
	cParte1  := cParte1 + cDig1
	
	cParte2  := SUBSTR(cCampoL,6,10)	//cNroDoc + cAgencia
	cDig2    := DIGIT001( cParte2 )
	cParte2  := cParte2 + cDig2
	
	cParte3  := SUBSTR(cCampoL,16,10)
	cDig3    := DIGIT001( cParte3 )
	cParte3  := cParte3 + cDig3
	
	cParte4  := cDigBarra
	cParte5  := cFatorValor
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+;
	cParte5
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
	
	
elseif cBanco == '001' .and. len( AllTrim(_cConvenio) ) == 7
	//
	// CONVENIO 7 POSICOES
	//
	
	cNosso     := StrZero(Val(_cConvenio),7)+StrZero(Val(cNroDoc),10)
	cDigNosso  := ""	//CALC_di9(cNosso) - Nao existe para este convenio
	cCart      := cCart
	
	// campo livre
	cCampoL    := StrZero(Val(_cConvenio),13)+strzero(Val(cNroDoc),10)+cCart
	
	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
	Endif
	
	// campo do digito verificador do codigo de barra
	cLivre := cBanco+cMoeda+cFatorValor+cCampoL
	cDigBarra := CALC_5p( cLivre )
	
	// campo do codigo de barra
	cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)
	
	// composicao da linha digitavel
	cParte1  := cBanco+cMoeda+Strzero(val(Substr(cBarra,4,1)),6)
	cDig1    := DIGIT001( cParte1 )
	
	cParte2  := SUBSTR(cCampoL,6,10) // alterado aqui cParte2  := SUBSTR(cCampoL,7,10)
	cDig2    := DIGIT001( cParte2 )
	cParte2  := cParte2 + cDig2
	
	cParte3  := SUBSTR(cCampoL,16,10)
	cDig3    := DIGIT001( cParte3 )
	cParte3  := cParte3 + cDig3
	
	cParte4  := cDigBarra
	cParte5  := cFatorValor
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+;
	cParte5
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
	
ElseIf cBanco == '341' // Itau
	
	If cCart $ '126/131/146/150/168'
		cTexto := cCart + cNroDoc
	Else
		cTexto := cAgencia + cConta + cCart + cNroDoc
	EndIf
	
	cTexto2 := cAgencia + cConta
	
	cDigCC  := Modu10(cTexto2)
	
	cNosso    := cCart + '/' + cNroDoc + '-' + cDigNosso
	cCart     := cCart
	
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
	Endif
	
	cValor:= StrZero(nValor * 100, 10)
	
	/* Calculo do codigo de barras */
	cCdBarra:= cBanco + cMoeda + cFatorValor + cCart + cNroDoc + cDigNosso +;
	cAgencia + cConta + cDigCC + "000"
	
	cDigCdBarra:= Modu11(cCdBarra,9)
	
	cCdBarra := Left(cCdBarra,4) + cDigCdBarra + Substr(cCdBarra,5,40)
	
	/* Calculo da representacao numerica */
	//	cCampo1:= "341" + "9" + cCart + Substr(cNosso, 5, 2)
	//	cCampo2:= Substr(cNosso, 7, 6) + Substr(cNosso, 14, 1) + Substr(cAgencia, 1, 3)
	//	cCampo3:= Substr(cAgencia, 4, 1) + cConta + cDacCC + "000"
	cCampo1:= cBanco+cMoeda+Substr(cCdBarra,20,5)
	cCampo2:= Substr(cCdBarra,25,10)
	cCampo3:= Substr(cCdBarra,35,10)
	
	cCampo4:= Substr(cCdBarra, 5, 1)
	cCampo5:= cFatorValor
	
	/* Calculando os DACs dos campos 1, 2 e 3 */
	cCampo1:= cCampo1 + Modu10(cCampo1)
	cCampo2:= cCampo2 + Modu10(cCampo2)
	cCampo3:= cCampo3 + Modu10(cCampo3)
	
	cRepNum := Substr(cCampo1, 1, 5) + "." + Substr(cCampo1, 6, 5) + "  "
	cRepNum += Substr(cCampo2, 1, 5) + "." + Substr(cCampo2, 6, 6) + "  "
	cRepNum += Substr(cCampo3, 1, 5) + "." + Substr(cCampo3, 6, 6) + "  "
	cRepNum += cCampo4 + "  "
	cRepNum += cCampo5
	
	Aadd(aRet,cCdBarra)
	Aadd(aRet,cRepNum)
	Aadd(aRet,cNosso)
	
ElseIf cBanco == '237' // Bradesco
	cNosso     := cCart + '/' + cNroDoc + '-' + cDigNosso
	
	_cConta := AllTrim(cConta)+AllTrim(cDacCC)
	_cConta := Left(_cConta,len(_cConta)-1)
	
	// campo livre
	cCampoL    := cAgencia+cCart+cNroDoc+StrZero(Val(_cConta),7)+'0'
	
	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
	Endif
	
	// campo do digito verificador do codigo de barra
	cLivre := cBanco+cMoeda+cFatorValor+cCampoL
	
	cDigBarra := CALC_5p( cLivre )
	
	// campo do codigo de barra
	cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)
	
	// composicao da linha digitavel
	cParte1  := cBanco+cMoeda+Substr(cBarra,20,5)
	cDig1    :=  Modu10( cParte1 )
	cParte1  := cParte1 + cDig1
	
	cParte2  := SUBSTR(cBarra,25,10) // alterado aqui cParte2  := SUBSTR(cCampoL,7,10)
	cDig2    :=  Modu10( cParte2 )
	cParte2  := cParte2 + cDig2
	
	cParte3  := SUBSTR(cBarra,35,10)
	cDig3    :=  Modu10( cParte3 )
	cParte3  := cParte3 + cDig3
	
	cParte4  := cDigBarra
	cParte5  := cFatorValor
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+;
	cParte5
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
	
ElseIf cBanco == '033' 	// Santander
	cNosso    := cNroDoc + '-' + cDigNosso
	
	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
	Endif
	
	cBarra := cBanco 										//Codigo do banco na camara de compensacao
	cBarra += cMoeda  										//Codigo da Moeda
	cBarra += Fator()						  	    		//Fator Vencimento
	cBarra += strzero(nValor*100,10)						//Strzero(Round(SE1->E1_SALDO,2)*100,10)		//Valor (ALTERADO PARA PEGAR O SALDO DO TITULO E NรO O VALOR)
	cBarra += "9"                                           //Sistema - Fixo
	cBarra += _cConvenio									//C๓digo Cedente
	cBarra += cNroDoc + cDigNosso							//Nosso numero
	cBarra += "0"											//IOS
	cBarra += "101"/*_cCarteira*/					     			//Tipo de Cobran็a
	
	cDigBarra := Modu11(cBarra)								//DAC codigo de barras
	
	cBarra := SubStr(cBarra,1,4) + cDigBarra + SubStr(cBarra,5,39)
	
	
	// composicao da linha digitavel  1 PARTE DE 1
	cParte1 := cBanco 		 				     	//Codigo do banco na camara de compensacao
	cParte1 += cMoeda								//Cod. Moeda
	cParte1 += "9"									//Fixo "9" conforme manual Santander
	cParte1 += Substr(_cConvenio,1,4)				//C๓digo do Cedente (Posi็ใo 1 a 4)
	
	cDig1 := Substr(cParte1,1,9)                  //Pega variavel sem o '.'
	
	cParte1 += Modu10(cDig1)				  	    //Digito verificador do campo
	
	
	// composicao da linha digitavel 1 PARTE DE 2
	cParte2 := Substr(_cConvenio,5,3)			//C๓digo do Cedente (Posi็ใo 5 a 7)
	cParte2 += Substr(cNroDoc + cDigNosso,1,7)			//Nosso Numero (Posi็ใo 1 a 7)
	
	cDig2 := Substr(cParte2,1,10)					//Pega variavel sem o '.'
	
	cParte2 += Modu10(cDig2)					    //Digito verificador do campo
	
	
	// composicao da linha digitavel 2 PARTE DE 1
	cParte3 := SubStr(cNroDoc + cDigNosso,8,6)  		//Nosso Numero (Posi็ใo 8 a 13)
	cParte3 +="0"									//IOS (Fixo "0")
	cParte3 +="101"/*_cCarteira*/							//Tipo Cobran็a (101-Cobran็a Simples Rแpida Com Registro)
	
	cDig3 := Substr(cParte3,1,10) 			        //Pega variavel sem o '.'
	
	cParte3 += Modu10(cDig3)				     	//Digito verificador do campo
	
	
	// composicao da linha digitavel 4 PARTE
	cParte4 := SubStr(cBarra,5,1)				//Digito Verificador do C๓digo de Barras
	
	
	// composicao da linha digitavel 5 PARTE
	cParte5 := Fator()							//Fator de vencimento
	cParte5 += strzero(nValor*100,10)			//Valor do titulo (Saldo no E1)
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+cParte5
	
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
	
	
ElseIf cBanco == '756' // Sicoob
	
	cConta	   := StrZero( val(cConta),8)
	cNosso    := cNroDoc + '-' + cDigNosso
	cCart      := cCart
	
	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
	Endif
	
	// campo livre
	cCampoL    := Right(cCart,1) + cAgencia + Right(cCart,2) + StrZero( Val(_cConvenio),7) + cNroDoc + cDigNosso + StrZero( Val(se1->e1_parcela),3)
	
	// campo do digito verificador do codigo de barra
	cLivre := cBanco + cMoeda + cFatorValor + cCampoL
	cDigBarra := Modu11(cLivre)//CALC_5p( cLivre )
	
	// campo do codigo de barra
	cBarra    := SubStr(cLivre,1,4) + cDigBarra + SubStr(cLivre,5,39)
	
	// composicao da linha digitavel
	cParte1  := cBanco + cMoeda + RIGHT(cCart,1) + cAgencia
	cDig1    := DIGIT001( cParte1 )
	cParte1  := cParte1 + cDig1
	
	cParte2  := Right(cCart,2) + StrZero( Val(see->ee_codemp), 7) +	Left(cNroDoc,1)
	cDig2    := DIGIT001( cParte2 )
	cParte2  := cParte2 + cDig2
	
	cParte3  := Right(cNroDoc,6) + cDigNosso + StrZero( Val(se1->e1_parcela),3)
	cDig3    := DIGIT001( cParte3 )		//DigitoLinhaDigitavel(cParte3)	//
	cParte3  := cParte3 + cDig3
	
	cParte4  := cDigBarra
	cParte5  := cFatorValor
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+;
	cParte5
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
	
ElseIf cBanco == '104' // CAIXA
	
	cConta	   := StrZero( val(cConta),8)              
	cNosso    := cNroDoc + '-' + cDigNosso
	cCart      := cCart
	
	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero((SE1->E1_SALDO +SE1->E1_ACRESC)*100,10)
	Endif
	
	
	// campo livre
	//cCampoL    := Left(cCart,1) + cAgencia + Right(cCart,2) + StrZero( Val(_cConvenio),6)+"9" + cNroDoc + cDigNosso + StrZero( Val(se1->e1_parcela),3)
	DvConv :=""
	If ALLTRIM(_cConvenio) == "338294" // nao sei por que estแ chumbado 			
		DvConv := "0"
	ElseIf Len(ALLTRIM(_cConvenio)) > 6
		DvConv := subStr(_cConvenio,Len(ALLTRIM(_cConvenio)))  		
	else
		DvConv := "9" //Criado para assumir o dv do Cedente. para caixa economica.
	Endif
	cCampoL    := StrZero( Val(_cConvenio),6)+DvConv+subStr(cNroDoc,3,3)+"1"+subStr(cNroDoc,6,3)+"4"+subStr(cNroDoc,9,9)
	DvCampoL	:= Modu11(cCampoL,,"CX")
	cCampoL	   := cCampoL+DvCampoL
	// campo do digito verificador do codigo de barra
	cLivre := cBanco + cMoeda + cFatorValor + cCampoL
	cDigBarra := CALC_5p( cLivre )
	
	// campo do codigo de barra
	cBarra    := SubStr(cLivre,1,4) + cDigBarra + SubStr(cLivre,5,39)
	
	// composicao da linha digitavel
	cParte1  := cBanco + cMoeda + Substr(_cConvenio,1,5)//Left(cCart,1) + cAgencia
	cDig1    := CaixaMod10( cParte1 ) // DIGIT001( cParte1 ) // DIGIT001 substituida pela CaixaMod10
	cParte1  := cParte1 + cDig1
	
	cParte2  := Substr(_cConvenio,6,1)+DvConv+subStr(cNroDoc,3,3)+"1"+subStr(cNroDoc,6,3)+"4"//Right(cCart,2) + StrZero( Val(see->ee_codemp), 6)+"9" +	Left(cNroDoc,1)
	cDig2    := CaixaMod10( cParte2 ) // DIGIT001( cParte2 ) // DIGIT001 substituida pela CaixaMod10
	cParte2  := cParte2 + cDig2
	
	cParte3  := subStr(cNroDoc,9,9)+DvCampoL//Right(cNroDoc,6) + cDigNosso + StrZero( Val(se1->e1_parcela),3)
	cDig3    := CaixaMod10( cParte3 ) // DIGIT001( cParte3 ) // DIGIT001 substituida pela CaixaMod10		//DigitoLinhaDigitavel(cParte3)	//
	cParte3  := cParte3 + cDig3
	
	cParte4  := cDigBarra
	cParte5  := cFatorValor
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+;
	cParte5
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
	
ElseIf cBanco == '653' .or. cBanco == '320' // Indusval e Bic Banco
	
	/*cNosso     := cCart + '/' + cNroDoc + '-' + cDigNosso
	
	// campo livre
	if len(cConta) > 7
	
	cEOL := CHR(10)
	Aviso("ATENวรO","Para Bancos igual a 320 e/ou 620 ้ necessแrio que a Conta nใo ultrapasse 7 caraceters!" +cEOL+;
	" Conta encontrado: "+AllTrim(cConta) +" quantidade de caracteres: "+ alltrim(str(len( AllTrim(cConta))))+cEOL+;
	"O processo serแ abortado!"  ,{"OK"})
	return
	
	
	endif
	cCampoL    := cAgencia+cCart+cNroDoc+StrZero(Val(cConta),7)+'0'
	
	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
	cFatorValor  := fator()+strzero(nValor*100,10)
	Else
	cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
	Endif
	
	// campo do digito verificador do codigo de barra
	cLivre := cBanco+cMoeda+cFatorValor+cCampoL
	
	cDigBarra := CALC_5p( cLivre )
	
	// campo do codigo de barra
	cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)
	
	// composicao da linha digitavel
	cParte1  := cBanco+cMoeda+Substr(cBarra,20,5)
	cDig1    :=  Modu10( cParte1 )
	cParte1  := cParte1 + cDig1
	
	cParte2  := SUBSTR(cBarra,25,10) // alterado aqui cParte2  := SUBSTR(cCampoL,7,10)
	cDig2    :=  Modu10( cParte2 )
	cParte2  := cParte2 + cDig2
	
	cParte3  := SUBSTR(cBarra,35,10)
	cDig3    :=  Modu10( cParte3 )
	cParte3  := cParte3 + cDig3
	
	cParte4  := cDigBarra
	cParte5  := cFatorValor
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+;
	cParte5
	
	//Aadd(aRet,cBarra) 
	Aadd(aRet,replace(REPLACE(cDigital,".","")," ",""))
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)*/
	
	
	cNosso     := cCart + '/' + cNroDoc + '-' + cDigNosso
	
	// campo livre
	cCampoL    := cAgencia+cCart+cNroDoc+StrZero(Val(cConta),7)+'0'
	if len(cConta) > 7
		
		cEOL := CHR(10)
		Aviso("ATENวรO","Para Bancos igual a 320 e/ou 620 ้ necessแrio que a Conta nใo ultrapasse 7 caraceters!" +cEOL+;
		" Conta encontrado: "+AllTrim(cConta) +" quantidade de caracteres: "+ alltrim(str(len( AllTrim(cConta))))+cEOL+;
		"O processo serแ abortado!"  ,{"OK"})
		return
	endif
	
	//campo livre do codigo de barra                   // verificar a conta
	//If nValor > 0 por sangelles Disbral 05/09/2013
	//	cFatorValor  := fator()+strzero(nValor*100,10)
	//Else
	cFatorValor  := fator()+strzero((SE1->E1_SALDO +SE1->E1_ACRESC)*100,10)
	//Endif
	
	// campo do digito verificador do codigo de barra
	cLivre := cBanco+cMoeda+cFatorValor+cCampoL
	
	cDigBarra := CALC_5p( cLivre )
	
	// campo do codigo de barra
	cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)
	
	// composicao da linha digitavel
	cParte1  := cBanco+cMoeda+Substr(cBarra,20,5)
	cDig1    :=  Modu10( cParte1 )
	cParte1  := cParte1 + cDig1
	
	cParte2  := SUBSTR(cBarra,25,10) // alterado aqui cParte2  := SUBSTR(cCampoL,7,10)
	cDig2    :=  Modu10( cParte2 )
	cParte2  := cParte2 + cDig2
	
	cParte3  := SUBSTR(cBarra,35,10)
	cDig3    :=  Modu10( cParte3 )
	cParte3  := cParte3 + cDig3
	
	cParte4  := cDigBarra
	cParte5  := cFatorValor
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+;
	cParte5
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
	
ElseIf cBanco == '389' // Mercantil
	
	cNosso     := ALLTRIM(SE1->E1_NUMBCO)
	cDigNosso  := ALLTRIM(SE1->E1_XDVNNUM)
	cCart      := cCart
	
	
	cFatVencto:= StrZero(dVencto - CTOD('07/10/1997'),4)
	// campo livre
	cCampoL    := StrZero(Val(cAgencia),4)+strzero(Val(cNroDoc),11)+StrZero(Val(Right(_cConvenio,9)),9)+"2"
	
	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := strzero(nValor*100,10)
	Else
		cFatorValor  := strzero(SE1->E1_SALDO*100,10)
	Endif
	
	// campo do digito verificador do codigo de barra
	cLivre := cBanco+cMoeda+cFatVencto+cFatorValor+cCampoL
	cDigBarra := Modu11(cLivre)
	
	// campo do codigo de barra
	cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,44)
	
	// composicao da linha digitavel
	cParte1  := cBanco+cMoeda+Substr(cBarra,20,5)
	cDig1    := Modu10(cParte1)
	cParte1  := cParte1+cDig1
	
	cParte2  := SUBSTR(cCampoL,6,10) 
	cDig2    := Modu10( cParte2 )
	cParte2  := cParte2 + cDig2
	
	cParte3  := SUBSTR(cCampoL,16,10)
	cDig3    := Modu10( cParte3 )
	cParte3  := cParte3 + cDig3
	
	cParte4  := cDigBarra
	cParte5  := Substr(cBarra,6,14)
	
	cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
	substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
	substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
	cParte4+" "+;
	cParte5
	
	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)
		
EndIf
if len(aRet) ==0
	cEOL := CHR(10)
	AVISO("Aten็ใo", "Banco ou Conv๊nio invalido, favor revise o cadastro de parametro de bancos!"+cEOL+ "Banco: "+alltrim(cBanco)+" Conv๊nio: "+alltrim(AllTrim(_cConvenio))  , {"Ok"})
	return nil
endif

Return aRet

//***************************************************************************
// Codigo de Barras HSBC													*
//***************************************************************************

Static Function RetBarraHS(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
cBanco		,cAgencia	,cConta		,cDacCC	,;
cNroDoc		,nValor		,cCart		,cMoeda )

Local cNosso		:= ""
Local cDigNosso		:= ""
Local cDigCdBarra
Local cFatVencto:= ""
Local cValor
Local cCampo1:= ""
Local cCampo2:= ""
Local cCampo3:= ""
Local cCampo4:= ""
Local cCampo5:= ""
Local aRet	 := {}

cAgencia   := StrZero(Val(cAgencia),4)

cNossoNum:= alltrim(SE1->E1_NUMBCO)+Alltrim(SE1->E1_XDVNNUM)


//cFatVencto:= StrZero(Val(cFatVenc), 4)
cFatVencto:= StrZero(dVencto - CTOD('07/10/1997'),4)


If nValor = 0
	nValor  := SE1->E1_SALDO
Endif
cValor:= StrZero(nValor * 100, 10)

cCdBarra := "399"  + "9" + cFatVencto
cCdBarra := cCdBarra + cValor
cCdBarra := cCdBarra + cNossoNum + cAgencia + cConta + CDacCc + "001"

//Calculo do Digito do Codigo de Barras
cDigCdBarra:= Modu11(cCdBarra)

//Compor a barra com o Digito verificador
cCdBarra := "399"  + "9" + cDigCdBarra + cFatVencto
cCdBarra := cCdBarra + StrZero((nValor*100),10)
cCdBarra := cCdBarra + cNossoNum + cAgencia + cConta + CDacCC + "001"

/*##################################*/


/* ######Calculo da representacao numerica -- Linha Digitแvel #######*/
cCampo1:= "399" + "9" + Substr(cNossoNum, 1, 5)
cCampo2:= Substr(cNossoNum, 6, 6) + cAgencia
cCampo3:= cConta + CDacCC + "001"
cCampo4:= Substr(cCdBarra, 5, 1)
cCampo5:= cFatVencto + cValor

/* Calculando os DACs dos campos 1, 2 e 3 */
cCampo1:= cCampo1 + Modu10(cCampo1)
cCampo2:= cCampo2 + Modu10(cCampo2)
cCampo3:= cCampo3 + Modu10(cCampo3)

cRepNum := Substr(cCampo1, 1, 5) + "." + Substr(cCampo1, 6, 5) + "  "
cRepNum += Substr(cCampo2, 1, 5) + "." + Substr(cCampo2, 6, 6) + "  "
cRepNum += Substr(cCampo3, 1, 5) + "." + Substr(cCampo3, 6, 6) + "  "
cRepNum += cCampo4 + "  "
cRepNum += cCampo5

Aadd(aRet,cCdBarra)
Aadd(aRet,cRepNum)
Aadd(aRet,cNossoNum)

memowrit('c:\tmp\barra.txt',cCdBarra+"-"+cRepNum)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCALC_di9  บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CALC_di9(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 9
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 1
		base := 9
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base - 1
	iDig   := iDig-1
EndDo
auxi := mod(Sumdig,11)
If auxi == 10
	auxi := "X"
Else
	auxi := str(auxi,1,0)
EndIf
Return(auxi)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณDig11BB   บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Dig11BB(cData)
Local Auxi := 0, sumdig := 0

cbase  := cData
lbase  := LEN(cBase)
base   := 9	//7
sumdig := 0
Auxi   := 0
iDig   := lBase

while iDig >= 1
	If base == 1
		base := 9
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base - 1
	iDig   := iDig-1
endDo

auxi := mod(Sumdig,11)
If auxi == 10
	auxi := "X"
Else
	auxi := str(auxi,1,0)
EndIf

Return(auxi)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณDIGIT001  บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DIGIT001(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
cValor:=AllTrim(STR(sumdig,12))

if sumdig == 9
	nDezena := VAL(ALLTRIM(STR(VAL(SUBSTR(cvalor,1,1))+1,12)))
else
	nDezena := VAL(ALLTRIM(STR(VAL(SUBSTR(cvalor,1,1))+1,12))+"0")
endif

auxi := nDezena - sumdig

If auxi >= 10
	auxi := 0
EndIf
Return(str(auxi,1,0))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFATOR     บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function Fator()
If Len( ALLTRIM( SUBSTR( dtos(dVencto),7,4) ) ) = 4
	cData := SUBSTR( dtos(dVencto),7,4)+SUBSTR( dtos(dVencto),4,2)+SUBSTR( dtos(dVencto),1,2)
Else
	cData := "20"+SUBSTR( dtos(dVencto),7,2)+SUBSTR( dtos(dVencto),4,2)+SUBSTR( dtos(dVencto),1,2)
EndIf

cFator := STR(1000+(dVencto-STOD("20000703")),4)
Return(cFator)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCALC_5p   บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CALC_5p(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base >= 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 1 .or. auxi >= 10
	auxi := 1
Else
	auxi := 11 - auxi
EndIf
Return(str(auxi,1,0))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCdBarra_Itauบ                                               บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณAJUSTASX1 บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao auxiliar chamada para criar os parametros do        บฑฑ
ฑฑบ          ณ relatorio na tabela de parametros.						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ajustasx1()

putSx1(cPerg,"01","De Prefixo"      ,"De Prefixo"      ,"De Prefixo"      ,"mv_ch1","C",03,0,0,"G","","","","","MV_PAR01","","","",""        ,"","","","","","","","","","","","")
putSx1(cPerg,"02","Ate Prefixo"     ,"Ate Prefixo"     ,"Ate Prefixo"     ,"mv_ch2","C",03,0,0,"G","","","","","MV_PAR02","","","","ZZZ"     ,"","","","","","","","","","","","")
putSx1(cPerg,"03","De Numero"       ,"De Numero"       ,"De Numero"       ,"mv_ch3","C",09,0,0,"G","","","","","MV_PAR03","","","",""        ,"","","","","","","","","","","","")
putSx1(cPerg,"04","Ate Numero"      ,"Ate Numero"      ,"Ate Numero"      ,"mv_ch4","C",09,0,0,"G","","","","","MV_PAR04","","","","ZZZZZZ"  ,"","","","","","","","","","","","")
putSx1(cPerg,"05","De Parcela"      ,"De Parcela"      ,"De Parcela"      ,"mv_ch5","C",03,0,0,"G","","","","","MV_PAR05","","","",""        ,"","","","","","","","","","","","")
putSx1(cPerg,"06","Ate Parcela"     ,"Ate Parcela"     ,"Ate Parcela"     ,"mv_ch6","C",03,0,0,"G","","","","","MV_PAR06","","","","Z"       ,"","","","","","","","","","","","")
putSx1(cPerg,"07","De Portador"     ,"De Portador"     ,"De Portador"     ,"mv_ch7","C",03,0,0,"G","","SA6","","","MV_PAR07","","","","001"     ,"","","","","","","","","","","","")
putSx1(cPerg,"08","Ate Portador"    ,"Ate Portador"    ,"Ate Portador"    ,"mv_ch8","C",03,0,0,"G","","SA6","","","MV_PAR08","","","","001"     ,"","","","","","","","","","","","")
putSx1(cPerg,"09","De Cliente"      ,"De Cliente"      ,"De Cliente"      ,"mv_ch9","C",TamSx3("E1_CLIENTE")[1],0,0,"G","","SA1","","","MV_PAR09","","","",""        ,"","","","","","","","","","","","")
putSx1(cPerg,"10","Ate Cliente"     ,"Ate Cliente"     ,"Ate Cliente"     ,"mv_cha","C",TamSx3("E1_CLIENTE")[1],0,0,"G","","SA1","","","MV_PAR10","","","","ZZZZZZ"  ,"","","","","","","","","","","","")
putSx1(cPerg,"11","De Loja"         ,"De Loja"         ,"De Loja"         ,"mv_chb","C",02,0,0,"G","","","","","MV_PAR11","","","",""        ,"","","","","","","","","","","","")
putSx1(cPerg,"12","Ate Loja"        ,"Ate Loja"        ,"Ate Loja"        ,"mv_chc","C",02,0,0,"G","","","","","MV_PAR12","","","","ZZ"      ,"","","","","","","","","","","","")
putSx1(cPerg,"13","De Emissao"      ,"De Emissao"      ,"De Emissao"      ,"mv_chd","D",08,0,0,"G","","","","","MV_PAR13","","","","01/01/01","","","","","","","","","","","","")
putSx1(cPerg,"14","Ate Emissao"     ,"Ate Emissao"     ,"Ate Emissao"     ,"mv_che","D",08,0,0,"G","","","","","MV_PAR14","","","","31/12/10","","","","","","","","","","","","")
putSx1(cPerg,"15","De Vencimento"   ,"De Vencimento"   ,"De Vencimento"   ,"mv_chf","D",08,0,0,"G","","","","","MV_PAR15","","","","01/01/01","","","","","","","","","","","","")
putSx1(cPerg,"16","Ate Vencimento"  ,"Ate Vencimento"  ,"Ate Vencimento"  ,"mv_chg","D",08,0,0,"G","","","","","MV_PAR16","","","","31/12/10","","","","","","","","","","","","")
putSx1(cPerg,"17","Do Bordero"      ,"Do Bordero"      ,"Do Bordero"      ,"mv_chh","C",06,0,0,"G","","","","","MV_PAR17","","","",""        ,"","","","","","","","","","","","")
putSx1(cPerg,"18","Ate Bordero"     ,"Ate Bordero"     ,"Ate Bordero"     ,"mv_chi","C",06,0,0,"G","","","","","MV_PAR18","","","","ZZZZZZ"  ,"","","","","","","","","","","","")
putSx1(cPerg,"19","Da Carga"        ,"Da Carga"        ,"Da Carga"        ,"mv_chj","C",06,0,0,"G","","DAK","","","MV_PAR19","","","",""        ,"","","","","","","","","","","","")
putSx1(cPerg,"20","Ate Carga"       ,"Ate Carga"       ,"Ate Carga"       ,"mv_chl","C",06,0,0,"G","","DAK","","","MV_PAR20",""   ,""   ,"","ZZZZZZ"  ,"","","","","","","","","","")
putSx1(cPerg,"21","Mensagem 1"      ,"Mensagem 1"      ,"Mensagem 1"      ,"mv_chm","C",50,0,0,"G","","","","","MV_PAR21","","","",""        ,"","","","","","","","","","","","")
putSx1(cPerg,"22","Mensagem 2"      ,"Mensagem 2"      ,"Mensagem 2"      ,"mv_chn","C",50,0,0,"G","","","","","MV_PAR22","","","",""        ,"","","","","","","","","","","","")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณModulo10  บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao auxiliar chamada para criar os parametros do        บฑฑ
ฑฑบ          ณ relatorio na tabela de parametros.						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Modu10(cLinha)

Local nSoma:= 0
Local nResto
Local nCont
Local cDigRet
Local nResult
Local lDobra:= .f.
Local cValor
Local nAux
Local cUnidad

For nCont:= Len(cLinha) To 1 Step -1
	lDobra:= !lDobra
	
	If lDobra
		cValor:= AllTrim(Str(Val(Substr(cLinha, nCont, 1)) * 2))
	Else
		cValor:= AllTrim(Str(Val(Substr(cLinha, nCont, 1))))
	EndIf
	If SEE->EE_CODIGO = "389" .OR. SEE->EE_CODIGO = "399"
		If Len(cValor) > 1
	    	nSoma += (Val(Substr(cValor,1,1)) + Val(Substr(cValor,2,1)))
	    Else
	        nSoma += Val(cValor)
	    EndIf	
	Else
		For nAux:= 1 To Len(cValor)
			nSoma += Val(Substr(cValor, nAux, 1))
		Next nAux
	EndIf	
Next nCont



If SEE->EE_CODIGO = "389"   
    cUnidad := cValToChar(nSoma)
    cUnidad := SubStr(cUnidad,Len(cUnidad),1)
	If Val(cUnidad) == 0 // Verifica se a unidade ้ 0 
		cDigRet := cUnidad
	Else
		cDigRet := cValToChar(10-Val(cUnidad))	
	EndIf

Else
	nResto:= MOD(nSoma, 10)
	
	nResult:= 10 - nResto
	
	If nResult == 10
		cDigRet:= "0"
	Else
		cDigRet:= StrZero(10 - nResto, 1)
	EndIf
EndIf
	
Return cDigRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณModulo11  บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ	Dados Adicionais de Alteracao/Ajustes do Fonte                        บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Modu11(cLinha,cBase,cTipo)
/******************************************************************************************************************/
Local cDigRet
Local nSoma:= 0
Local nResto
Local nCont
Local nFator:= 9
Local nResult
Local _cBase := If( cBase = Nil , 9 , cBase )
Local _cTipo := If( cTipo = Nil , '' , cTipo )

For nCont:= Len(cLinha) TO 1 Step -1
	nFator++
	If nFator > _cBase
		nFator:= 2
	EndIf
	
	nSoma += Val(Substr(cLinha, nCont, 1)) * nFator
Next nCont

nResto:= Mod(nSoma, 11)

nResult:= 11 - nResto

If _cTipo = 'P'   // Bradesco
	If nResto == 0
		cDigRet:= "0"
	ElseIf  nResto == 1
		cDigRet:= "P"
	Else
		cDigRet:= StrZero(11 - nResto, 1)
	EndIf

ElseIf _cTipo == "CX"	// Ajuste na l๓gica, seguindo documenta็ใo da Caixa, quando o resultado for maior que 9, assume-se 0
	If nResult > 9
		cDigRet := "0"
	Else	
		cDigRet := StrZero(11 - nResto, 1)
	EndIf

Else
	If nResult == 0 .Or. nResult == 1 .Or. nResult == 10 .Or. nResult == 11
		cDigRet:= "1"
	Else
		cDigRet:= StrZero(11 - nResto, 1)
	EndIf
EndIf
Return cDigRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณNrBordero บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ	Dados Adicionais de Alteracao/Ajustes do Fonte                        บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Procedure NrBordero()

Local nBordero := ""
Local lFindSEA := .F.
Local nPos := 0
Local aBanco := { {"001","B"},{"237","R"},{"033","S"},{"756","C"},{"341","I"},{"104","X"},{"320","V"},{"653","A"},{"399","H"},{"389","M"} }
Local cDia	:= IIF(day( dDataBase ) < 9,cValtoChar( day( dDataBase )),Upper(chr( 55+Day( dDataBase ) ) ))// digito do dia, de 1 a 9 e A a V

//
// Verifica se cliente tem preferencia por banco
//

SA1->( dbSetOrder(1), DbSeek( xFilial("SA1") + TSE1->E1_CLIENTE + TSE1->E1_LOJA ) )

If !Empty(SE1->E1_PORTADO)

	SEE->(dbSeek( xFilial("SEE") + SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA) ))
	_nSEE := SEE->(recno())
	
ElseIf lImpBanCli //imprime pelo cliente
	
		SA1->(dbSetOrder(1))
		if SA1->(dbSeek( xFilial("SA1") + TSE1->E1_CLIENTE + TSE1->E1_LOJA ))
			if !empty(SA1->A1_BCO1)
				SEE->(dbSetOrder(1))
				if SEE->(dbSeek( xFilial("SEE") + SA1->(A1_BCO1+A1_XAGENC1+A1_XCONTA1+A1_XSCONT1) ))
					_nSEE := SEE->(recno())
				Else
					MsgStop("Verifique os campos 'Banco 01', 'Agencia 01', 'Conta 01' e 'Sub Conta 01' no cadastro do cliente","ERRO")
					Return .F.	
				endif
			else 
				If lPergBol
					cEOL := CHR(10)
					AVISO("Aten็ใo", "O Cliente C๓digo: "+TSE1->E1_CLIENTE+" Loja: "+TSE1->E1_LOJA+" nใo possui banco vinculado ao seu cadastro!";
					+cEOL+"Serแ impresso o boleto conforme configura็ใo da Rotina 'Configura็ใo Boleto'"  , {"Ok"})
				Endif	
				_nSEE := GetMv("MV_XSEE")
			endif
		endIf
else
	_nSEE := GetMv("MV_XSEE")
endif
	
//FIM AJUSTE

SEE->( DbGoTo(_nSEE) )
nPos := AScan ( aBanco, {|x| x[1] == SEE->EE_CODIGO } )

if nPos == 0 .or. _nSEE == 0
	Return .F.
	
elseif !Empty(SE1->E1_PORTADO)

	Return .T.
	
endif


If !SuperGetMv("MV_XGRABOR",.F.,.T.)// Se Gera bordero
	Return .T.
EndIf

// X - Codigo Banco
// X - Sub Conta
// XX - Ano Bordero
// X - Codigo Mes
// X - Dias


nBordero := aBanco[nPos,2]+ Right(SEE->EE_SUBCTA,1)+ Right( Str( Year( date() ),4 ), 2 )  + Upper(chr( 64+Month( dDataBase ) ) ) + cDia 

//Posiciona na Agencia/Conta e Configuracoes bancarias
//SEE->( DbSeek( xFilial("SEE")+aBanco[nPos,1] ) )
SA6->( DbSeek( xFilial("SA6")+SEE->EE_CODIGO+SEE->EE_AGENCIA+SEE->EE_CONTA) )

RecLock("SE1")

SE1->E1_PORTADO := SEE->EE_CODIGO
SE1->E1_AGEDEP	:= SEE->EE_AGENCIA
SE1->E1_CONTA	:= SEE->EE_CONTA
SE1->E1_SITUACA	:= '1'
SE1->E1_OCORREN	:= '01'
SE1->E1_NUMBOR	:= M->nBordero
SE1->E1_DATABOR	:= dDataBase

SE1->( MsUnlock() )
SE1->( DbCommit() )

//
//	Coloca o titulo no bordero
//
SEA->( dbSetOrder( 1 ) )

lFindSEA := SEA->( DbSeek( xFilial( "SEA" )+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,.F. ) )

RecLock( "SEA",!lFindSEA )

if !lFindSEA
	
	SEA->EA_FILIAL  := xFilial( "SEA" )
	SEA->EA_PREFIXO := SE1->E1_PREFIXO
	SEA->EA_NUM     := SE1->E1_NUM
	SEA->EA_PARCELA := SE1->E1_PARCELA
	SEA->EA_FILORIG := cFilAnt
	
endif

SEA->EA_NUMBOR  := SE1->E1_NUMBOR
SEA->EA_TIPO    := SE1->E1_TIPO
SEA->EA_CART    := "R"
SEA->EA_PORTADO := SE1->E1_PORTADO
SEA->EA_AGEDEP  := SE1->E1_AGEDEP
SEA->EA_DATABOR := SE1->E1_DATABOR
SEA->EA_NUMCON  := SE1->E1_CONTA
SEA->EA_SITUACA := SE1->E1_SITUACA
SEA->EA_TRANSF  := ' '
SEA->EA_SITUANT := '0'

SEA->( msUnLock() )
SEA->( dbCommit() )
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณBradMod11 บ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function BradMod11(NumBoleta)
Local Modulo   := 11
Local strmult  := "2765432765432"
Local BaseDac  := M->NumBoleta  //Carteira + N Nro
Local VarDac   := 0, idac := 0

// Calculo do numero bancario + digito e valor do juros

For idac := 1 To 13
	VarDac := VarDac + Val(Subs(BaseDac, idac, 1)) * Val (Subs (strmult, idac, 1))
Next idac

VarDac  := Modulo - VarDac % Modulo
VarDac  := Iif (VarDac == 10, "P", Iif (VarDac == 11, "0", Str (VarDac, 1)))
Return VarDac


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณDigBarSiCoobบ                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



Static Function DigNNSicoob(cNNum,cCodEmp,cCodCoop,cParcela)
Local cCoop   := cCodCoop
Local cClie   := StrZero(Val(cCodEmp),10)
Local nMod    := 11
Local nSoma   := 0

Default cNNum 	:= '0000001'
Default cParcela:= '001'

aCons := {3,1,9,7,3,1,9,7,3,1,9,7,3,1,9,7,3,1,9,7,3,3}

cSeq := cCoop+cClie+cNNum
For nI := 1 to Len(cSeq)
	nSoma += Val(SubStr(cSeq,nI,1))*aCons[nI]
Next

nDigit := (nSoma % nMod)
//cDigit := AllTrim(Str( iif( nDigit <= 1,0, iif(nDigit >= 10,1,nDigit)) ) )

if nDigit <= 1
	cDigit := '0'
else
	cDigit := AllTrim(Str(nMod - nDigit))
endif

Return cDigit



/******************************************************************************************************************/
//CONVENIO SANTANDER
/******************************************************************************************************************/
Static Function Dig11Santander(cData)
Local Auxi := 0, sumdig := 0

cbase  := cData
lbase  := Len(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase

for iDig:=len(cBase) to 1 Step -1
	
	if base == 9
		base := 2
	endIf
	
	auxi   := Val(SubStr(cBase, iDig, 1)) * base
	sumdig := SumDig+auxi
	base   += 1
	
next iDig

auxi := mod(Sumdig,11)
If auxi == 10
	auxi := "1"
ElseIf auxi == 1 .or. auxi == 0
	auxi := "0"
Else
	auxi := str(11-auxi,1,0)
EndIf

Return(auxi)



//*****************************************
//  DIGITO NNUM HSBC                      *
//*****************************************
Static Function DIGITHSBC(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase

While iDig >= 1
	
	If base > 7
		base := 2
	EndIf
	
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
	
EndDo

auxi := mod(sumdig,11)

If auxi == 0 .OR. auxi == 1
	auxi := 0
else
	auxi := 11 - auxi
EndIf
Return cValToChar(auxi)
                                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCaixaMod10  บ                                               บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Modulo10 para digito verificador da Caixa                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Acelerador                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CaixaMod10(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
cValor:=AllTrim(STR(sumdig,12)) 

If sumdig < 10
	Auxi := 10 - sumdig
Else
	Auxi := Mod(sumdig,10) 
	Auxi := 10 - Auxi
EndIf

Return(str(auxi,1,0))

Static Function xCliSearch(cCod, cLoja)

Local aArea     := GetArea() 
Local cCli      := ""

DbSelectArea("SA1")

SA1->( DbSetOrder(1) )

If DbSeek(xFilial("SA1") + cCod + cLoja)
	cCli := Alltrim(SA1->A1_NOME)
Else
	cCli := ""
EndIf

RestArea( aArea )

Return cCli