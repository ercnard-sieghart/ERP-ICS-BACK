#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'RestFul.ch'

User Function SE5Controller()	
Return

WSRESTFUL EXTRATOBANCARIO DESCRIPTION "Retorna informa��es do extrato banc�rio"

    WSMETHOD POST DESCRIPTION "Retorna informa��es do extrato banc�rio" WSSYNTAX ""
    WSMETHOD GET DESCRIPTION "Retorna lista de bancos dispon�veis" WSSYNTAX "/bancos"
    WSMETHOD POST GETByCOD DESCRIPTION "Retorna ag�ncias do banco especificado" WSSYNTAX "/bancos/agencias" PATH "/bancos/agencias"
    WSMETHOD POST GETByAGE DESCRIPTION "Retorna contas do banco especificado" WSSYNTAX "/bancos/agencias/contas" PATH "/bancos/agencias/contas"

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


WSMETHOD POST GETByCOD WSRECEIVE RECEIVE WSSERVICE EXTRATOBANCARIO
    Local oResponse := JsonObject():New()
    Local oBody  := JsonObject():New()

    ::SetContentType("application/json")
    oBody := ::GetContent()

    oResponse := SE5Service():GetAgencias(oBody)
    
    oRest:SetResponse(oResponse:toJson())

Return

WSMETHOD POST GETByAGE WSRECEIVE RECEIVE WSSERVICE EXTRATOBANCARIO
    Local oResponse := JsonObject():New()
    Local oBody  := JsonObject():New()

    ::SetContentType("application/json")
    oBody := ::GetContent()

    oResponse := SE5Service():GetContas(oBody)
    
    oRest:SetResponse(oResponse:toJson())

Return
