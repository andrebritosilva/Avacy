#include "rwmake.ch"

/*
Funcao      : MSD2520
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. para exclus�o da NF de Saida (Item a Item), da tabela de Complementos de Exporta�ao (CDL).
Autor       : GRAZIELE CAETANO
Data/Hora   : 09/08/2019
Obs         : 
TDN         : 
Revis�o     : GRAZIELE CAETANO
Data/Hora   : 09/08/2019
Obs         : 
M�dulo      : Fiscal.
Cliente     : Todos
*/

*-------------------------*
 User Function MSD2520()
*-------------------------*
LOCAL _aAreaS := GetArea()              

If cEmpAnt $ "01"
	DbSelectArea("CDL")
	DbSetOrder(1)
	If DbSeek(xFilial("SF2")+"S"+SF2->F2_SERIE+SF2->F2_DOC,.T.)
		RecLock("CDL",.F.) // Define que ser� realizada uma altera��o no registro posicionado
			DbDelete() // Efetua a exclus�o l�gica do registro posicionado.
		MsUnLock()
	EndIf
EndIf

RestArea(_aAreaS)
	
Return()