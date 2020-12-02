#include 'protheus.ch'
#include 'parmtype.ch'

User function LJ7001()
	
	Local nOpcRotina  := PARAMIXB[1]
	Local lRet        := .T.
	Local aArea       := GetArea() 

	//Validação na Venda do Tipo "Entrega" para que o Operador nao esqueça de Informar os dados do Frete.
	If nOpcRotina == 2 // Venda                   		
		If M->LQ_XENTREG == '2' .And. M->LQ_TPFRET =='0'.OR. M->LQ_TPFRET = ' '
			MsgStop("Nao é possivel Finalizar Venda do Tipo Entrega sem Definir os Dados do Frete","Venda Assistida")	
			lRet := .F.
		Endif
		//Validação na Venda do Tipo "Retira" 
		If M->LQ_XENTREG == '1' .And. M->LQ_TPFRET =='0'.OR. M->LQ_TPFRET = ' '
			lRet := MsgYesNo("Entrega definida como RETIRA,Deseja Continuar ?","Venda Assistida")
		Endif

		//Validação na Venda Para cliente Consumidor Final para Fora dmo Estado. 
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))

		If M->LQ_XENTREG == '1' .And. M->LQ_TPFRET =='0'
			If SA1->( DbSeek( xFilial("SA1") + M->LQ_CLIENTE+M->LQ_LOJA ))
				If  SA1->A1_PESSOA =='F' .AND. SA1->A1_EST <> 'SP' .AND. SA1->A1_TIPO =='F'		  										
					lRet := MsgYesNo("Venda para Pessoa Fisica e Consumidor Final de Fora do Estado Presencial, Continuar ?","Venda Assistida")
				Endif	 
			Endif
		Endif 
	Endif     
RestArea( aArea )         		 
Return lRet