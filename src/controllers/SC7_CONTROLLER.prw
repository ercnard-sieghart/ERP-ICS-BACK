#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'RestFul.ch'

User Function SC7Controller
Return

WSRESTFUL PEDIDOCOMPRAS DESCRIPTION "WS PEDIDO DE COMPRAS"
	
	WSMETHOD GET DESCRIPTION "Retorna pedidos de compra (SC7)" WSSYNTAX ""
    WSMETHOD POST DESCRIPTION "Duplica um pedido de compra existente" WSSYNTAX "/duplicate"

END WSRESTFUL

WSMETHOD GET WSRECEIVE RECEIVE WSSERVICE PEDIDOCOMPRAS
	Local oSC7Service

  	oSC7Service := SC7Service():GetPedidos()
    oRest:SetResponse(oSC7Service:toJson())
Return

WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE PEDIDOCOMPRAS
    Local oJsonRequest := JsonObject():New()
    Local cBody := oRest:GetBodyRequest()
    Local oResponse := JsonObject():New()
    
    oJsonRequest:FromJson(cBody)
    
    If Empty(oJsonRequest["sourceNum"]) .Or. Empty(oJsonRequest["sourceItem"])
        oResponse["success"] := .F.
        oResponse["message"] := "Número e item do pedido origem são obrigatórios"
        oRest:SetResponse(oResponse:toJson())
        Return
    EndIf
    
    oResponse := SC7Service():DuplicatePedido(oJsonRequest["sourceNum"], oJsonRequest["sourceItem"], oJsonRequest)
    
    oRest:SetResponse(oResponse:toJson())
Return
