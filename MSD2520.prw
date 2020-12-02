#include "rwmake.ch"

/*
Funcao      : MSD2520
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. para exclusão da NF de Saida (Item a Item), da tabela de Complementos de Exportaçao (CDL).
Autor       : GRAZIELE CAETANO
Data/Hora   : 09/08/2019
Obs         : 
TDN         : 
Revisão     : GRAZIELE CAETANO
Data/Hora   : 09/08/2019
Obs         : 
Módulo      : Fiscal.
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
		RecLock("CDL",.F.) // Define que será realizada uma alteração no registro posicionado
			DbDelete() // Efetua a exclusão lógica do registro posicionado.
		MsUnLock()
	EndIf
EndIf

RestArea(_aAreaS)
	
Return()