#include "rwmake.ch"
#include "protheus.ch"
#include "Topconn.ch"
#include "tbiconn.ch" 
#include "MSGRAPHI.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³AFINA001                                                    ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Selecao de Carteira		                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Acelerador                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  
*/

User Function AFINP001()  

Local _aBoleto := {}

if SuperGetMv("MV_XUSFPG")

	SE1->( DbSetOrder(1), DbSeek( xFilial("SF2")+SF2->F2_SERIE+SF2->F2_DOC ) )
	
	do while (xFilial("SF2")+SF2->F2_SERIE+SF2->F2_DOC) = (xFilial("SE1")+SE1->E1_SERIE+SE1->E1_NUM)
		
		RecLock("SE1",.F.)
		SE4->( DbSeek( xFilial("SE4")+SC5->C5_NUM) )
		SE1->E1_X_FORPG := 'BOL   '
		SE1->( MsUnLock() )
		SE1->( DbSkip() )
		
	enddo
endif


//
// Caso seja Boleto a venda chama tela de impressão
//
//if AllTrim( Upper(SCV->CV_FORMAPG) ) $ 'BOL/BK/BL/' .or. SE4->E4_FORMA $ 'BOL/BK/BL/'
	
	aadd( _aBoleto, space(3) )
	aadd( _aBoleto, "ZZZ" )
	
	aadd( _aBoleto, SF2->F2_DOC )
	aadd( _aBoleto, SF2->F2_DOC )
	
	aadd( _aBoleto, Space( Len(SE1->E1_PARCELA) )  )
	aadd( _aBoleto, Replicate("Z",Len(SE1->E1_PARCELA) ) )
	
	aadd( _aBoleto, Space( Len(SE1->E1_PORTADO) )  )
	aadd( _aBoleto, Replicate("Z",Len(SE1->E1_PORTADO) ) )
	
	aadd( _aBoleto, SF2->F2_CLIENTE )
	aadd( _aBoleto, SF2->F2_CLIENTE )
	
	aadd( _aBoleto, SF2->F2_LOJA )
	aadd( _aBoleto, SF2->F2_LOJA )
	
	aadd( _aBoleto, SF2->F2_EMISSAO )
	aadd( _aBoleto, SF2->F2_EMISSAO )
	
	aadd( _aBoleto, stod('20100101') )
	aadd( _aBoleto, stod('20250101') )
	
	aadd( _aBoleto, Space( Len(SE1->E1_NUMBOR) )  )
	aadd( _aBoleto, Replicate("Z",Len(SE1->E1_NUMBOR) ) )
	
	aadd( _aBoleto, Space( Len(SF2->F2_CARGA) )  )
	aadd( _aBoleto, Replicate("Z",Len(SF2->F2_CARGA) ) )
	
	aadd( _aBoleto, "" )
	aadd( _aBoleto, "" )
	
	u_AFINA002(_aBoleto)
	
//endif
                   
return
