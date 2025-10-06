#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'RestFul.ch'

User Function SE5Controller()	
Return

WSRESTFUL EXTRATOBANCARIO DESCRIPTION "Retorna informa��es do extrato banc�rio"

    WSMETHOD POST DESCRIPTION "Retorna informa��es do extrato banc�rio" WSSYNTAX ""
    WSMETHOD GET DESCRIPTION "Retorna lista de bancos dispon�veis" WSSYNTAX "/bancos"
    WSMETHOD GET GETByCOD DESCRIPTION "Retorna ag�ncias do banco especificado" WSSYNTAX "/agencias/{id}" PATH "/agencias/{id}"

END WSRESTFUL


WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE EXTRATOBANCARIO
    Local oResponse := JsonObject():New()
    
    oResponse := SE5Service():GetExtratoBancario()
    
    oRest:SetResponse(oResponse:toJson())

Return

WSMETHOD GET WSRECEIVE RECEIVE WSSERVICE EXTRATOBANCARIO
    Local oResponse := JsonObject():New()

    oResponse := SE5Service():GetBancos()
    
    oRest:SetResponse(oResponse:toJson())
Return


WSMETHOD GET GETByCOD WSRECEIVE RECEIVE WSSERVICE EXTRATOBANCARIO
    Local oResponse := JsonObject():New()
    Local oBody  := JsonObject():New()

    ::SetContentType("application/json")
    oBody := ::GetContent()

    oResponse := SE5Service():GetAgencias(oBody)
    
    oRest:SetResponse(oResponse:toJson())

Return
