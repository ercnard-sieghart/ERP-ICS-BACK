#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'RestFul.ch'

User Function PATENTES_CONTROLLER()	
Return

WSRESTFUL PATENTES DESCRIPTION "Webservice para gerenciamento de patentes e menus"

    WSMETHOD GET           DESCRIPTION "Retorna lista de todas as patentes"          WSSYNTAX ""
    WSMETHOD GET ACESSOS   DESCRIPTION "Retorna acessos de uma patente espec�fica"   WSSYNTAX "/acessos/{patente}" PATH "/acessos"
    WSMETHOD GET MENUS     DESCRIPTION "Retorna lista de todos os menus"            WSSYNTAX "/menus" PATH "/menus"
    WSMETHOD POST VALIDAR  DESCRIPTION "Valida acesso de usu�rio a menu"            WSSYNTAX "/validar" PATH "/validar"
    WSMETHOD POST ROTAS    DESCRIPTION "Retorna rotas/menus do usu�rio logado"      WSSYNTAX "/rotas" PATH "/rotas"

END WSRESTFUL


WSMETHOD GET WSRECEIVE RECEIVE WSSERVICE PATENTES
    Local oResponse := JsonObject():New()

    ::SetContentType("application/json")
    
    oResponse := PatenteService():GetAllPatentes()
    
    oRest:SetResponse(oResponse:toJson())

Return .T.

WSMETHOD GET ACESSOS WSRECEIVE RECEIVE WSSERVICE PATENTES
    Local oResponse := JsonObject():New()
    Local cPatente := ""

    ::SetContentType("application/json")
    
    // Pega o par�metro da URL (patente)
    cPatente := ::aURLParms[1]
    
    If Empty(cPatente)
        oResponse["success"] := .F.
        oResponse["message"] := "C�digo da patente � obrigat�rio"
    oRest:SetResponse(oResponse:toJson())
        Return .T.
    EndIf
    
    oResponse := PatenteService():GetAcessosPatente(cPatente)
    
    oRest:SetResponse(oResponse:toJson())

Return .T.

WSMETHOD GET MENUS WSRECEIVE RECEIVE WSSERVICE PATENTES
    Local oResponse := JsonObject():New()

    ::SetContentType("application/json")
    
    oResponse := PatenteService():GetAllMenus()
    
    oRest:SetResponse(oResponse:toJson())

Return .T.

WSMETHOD POST VALIDAR WSRECEIVE RECEIVE WSSERVICE PATENTES
    Local oResponse := JsonObject():New()
    Local oBody := JsonObject():New()

    ::SetContentType("application/json")
    oBody := ::GetContent()
    
    If Empty(oBody) .Or. Empty(oBody["usuario"]) .Or. Empty(oBody["menu"])
        oResponse["success"] := .F.
        oResponse["message"] := "Usu�rio e menu s�o obrigat�rios"
    oRest:SetResponse(oResponse:toJson())
        Return .T.
    EndIf
    
    oResponse := PatenteService():ValidarAcesso(oBody)
    
    oRest:SetResponse(oResponse:toJson())

Return .T.

WSMETHOD POST ROTAS WSRECEIVE RECEIVE WSSERVICE PATENTES
    Local oResponse := JsonObject():New()
    Local oBody := JsonObject():New()

    ::SetContentType("application/json")
    oBody := ::GetContent()
    
    If Empty(oBody) .Or. Empty(oBody["usuario"])
        oResponse["success"] := .F.
        oResponse["message"] := "C�digo do usu�rio � obrigat�rio"
    oRest:SetResponse(oResponse:toJson())
        Return .T.
    EndIf
    
    oResponse := PatenteService():GetRotasUsuario(oBody)
    
    oRest:SetResponse(oResponse:toJson())

Return .T.
