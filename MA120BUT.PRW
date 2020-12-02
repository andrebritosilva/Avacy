#Include "Protheus.ch"

User Function MA120BUT() 

Local aButtons := {} 

SetKey(VK_F10, {||U_xGerProds()})

aadd(aButtons,{'BUDGETY',{|| U_xGerProds()},'Consulta Aprovacao','Grade Avacy'}) 

Return (aButtons )