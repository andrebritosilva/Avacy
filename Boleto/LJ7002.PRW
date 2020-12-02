#INCLUDE "PROTHEUS.CH"
#INCLUDE "ACADEF.CH"
#INCLUDE "FWMVCDEF.CH"

User Function LJ7002()

Local nParTipo      := PARAMIXB[1] //(1-orcamento  2-venda  3-pedido)

If nParTipo == 2
	U_AFINP001()
EndIf
 
Return .T.