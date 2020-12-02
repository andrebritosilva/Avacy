#Include "Protheus.ch"

User Function MA410MNU() 

SetKey(VK_F2, {||U_M410INIC()})

aadd(aRotina,{'Grade Avacy','U_M410INIC()' , 0 , 3,0,NIL})   

Return (aRotina)