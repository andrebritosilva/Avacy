#include "rwmake.ch"

/*
Funcao      : MSD2460
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. na gravacao da NF de Saida (Item a Item),efetuando a gravacao dos Complementos de Exporta��o (CDL)
Autor       : Graziele Caetano
Data/Hora   : 09/08/2019
Obs         : 
TDN         : 
Revis�o     : Graziele Caetano
Data/Hora   : 09/08/2019
Obs         : 
M�dulo      : Fiscal.
Cliente     : Avacy
*/

*-----------------------*
 User Function MSD2460()
*-----------------------*

Local _aAreaSD2 := GetArea()   
Local _aAreaSF2 := GetArea()   
Local _aAreaSM0 := GetArea()

If cEmpAnt $ "01"
	//If EMPTY(SD2->D2_TES) == "504"
	If (SD2->D2_TES) == "504"
	
			// Posicionando CDL
			DbSelectArea("CDL")
			// Efetuamos a gravacao da tabela CDL (Complemento Documento de Exporta��o),
			RecLock("CDL",.T.)
			
			REPLACE CDL->CDL_FILIAL   with SD2->D2_FILIAL
			REPLACE CDL->CDL_DOC      with SD2->D2_DOC
			REPLACE CDL->CDL_SERIE    with SD2->D2_SERIE
			REPLACE CDL->CDL_ESPEC    with SF2->F2_ESPECIE
			REPLACE CDL->CDL_CLIENT   with SD2->D2_CLIENTE
			REPLACE CDL->CDL_LOJA     with SD2->D2_LOJA
			REPLACE CDL->CDL_UFEMB    with SM0->M0_ESTCOB
			REPLACE CDL->CDL_LOCEMB   with SM0->M0_ENDCOB
			REPLACE CDL->CDL_ITEMNF   with SD2->D2_ITEM
			REPLACE CDL->CDL_PRODNF   with SD2->D2_COD
			REPLACE CDL->CDL_SDOC     with SD2->D2_SERIE

			EndIf
			                 
			MSUNLOCK()
		
EndIf

RestArea(_aAreaSD2)

Return()