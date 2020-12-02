#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*
�����������������������������������������������������������������������������
���Programa  �M460FIM   �                                                 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para gravar a Forma de Pagamento na SE1   ���
���          � e Imprimir Boleto Laser			                          ���        
�������������������������������������������������������������������������͹��
���Uso       � Acelerador                                                 ���
�����������������������������������������������������������������������������  
*/

User Function LJ087()

	Local aArea	:= GetArea()

	RestArea(aArea)

Return .T.

