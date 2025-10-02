#INCLUDE "Protheus.ch"
#INCLUDE "Parmtype.ch"
#INCLUDE "FWMVCDef.ch"

User Function MVCSZ2()

	Local oBrowser 
	Local aRotina :=  Nil 

	DbSelectArea("SZ2")
	SetFunName("MVCSZ2")

	aRotina := MenuDef()

	oBrowser := FWMBrowse():New()
	oBrowser:SetAlias("SZ2")
	oBrowser:SetDescription("SZ2 - Orçamentos")
	oBrowser:Activate()
	
Return(Nil)

Static Function MenuDef()

	aRotina := {} 

	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.MVCSZ2' 		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.MVCSZ2' 		OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir' 	  ACTION 'VIEWDEF.MVCSZ2' 		OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.MVCSZ2' 		OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Copia' 	  ACTION 'u_CopiarRegistroSZ2'	OPERATION 3 ACCESS 0

Return aRotina

Static Function ModelDef()

	Local oModel as object
	Local oStMaster as object

	oStMaster := FWFormStruct(1, 'SZ2')
	oModel    := MPFormModel():New("MVCSZ2MODEL")
	oModel:AddFields("SZ2MASTER", /*cOwner*/, oStMaster)
	oModel:SetPrimaryKey({"Z2_FILIAL", "Z2_COD"})

Return oModel

Static Function ViewDef()

	Local oView 	:= FwFormView():New()
	Local oModel 	:= ModelDef()
	Local oStMaster := FWFormStruct(2, 'SZ2')

	oView:SetModel(oModel)
	oView:AddField("VIEW_SZ2", oStMaster, "SZ2MASTER")
	oView:CreateHorizontalBox('BOX_SZ2', 100)
	oView:SetOwnerView("VIEW_SZ2", 'BOX_SZ2')

Return oView
