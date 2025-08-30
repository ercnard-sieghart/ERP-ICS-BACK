#include "protheus.ch"
#Include "RestFul.CH"
#include "topconn.ch"
#include "tbiconn.ch"

WSRESTFUL Login Description "Login"

    WSMETHOD POST Description "Valida os dados de login no portal" WSSYNTAX "/login"

End WSRESTFUL

WSMETHOD POST WSService Login

    Local oJsnBody  := JsonObject():New()
    Local cUserName := oJsnBody["username"]
    Local cPassword := oJsnBody["password"]
    Local aTokens   := {}
    Local oResp     := JsonObject():New()
    Local lRet      := .T.
    Local cMsg      := "Login realizado com sucesso."

    aTokens := authgettoken():Token(cUserName, cPassword)

    If aTokens[1] == "400"
        cMsg    := "JSON inválido ou credenciais ausentes."
        lRet    := .F.
    Elseif aTokens[1] == "403"
        nStatus := 403
        cMsg    := "Acesso negado."
        lRet    := .F.
    Elseif aTokens[1] == "200"
        cJsonText := '{' + CRLF
        cJsonText += '  "access_token": "' + aTokens[1] + '",' + CRLF
        cJsonText += '  "refresh_token": "' + aTokens[2] + '",' + CRLF
        cJsonText += '  "scope": "' + aTokens[3] + '",' + CRLF
        cJsonText += '  "token_type": "' + aTokens[4] + '",' + CRLF
        cJsonText += '  "expires_in": ' + AllTrim(Str(aTokens[5])) + ',' + CRLF
        cJsonText += '  "success": true,' + CRLF
        cJsonText += '  "message": "' + cMsg + '",' + CRLF
        cJsonText += '  "name": "' + aTokens[6] + '",' + CRLF
        cJsonText += '  "email": "' + aTokens[7] + '"' + CRLF
        cJsonText += '}' + CRLF
    EndIf

    If aTokens[1] == "200"
        ::SetResponse(cJsonText)
    Else
        oResp["success"] := lRet
        oResp["message"] := cMsg
        ::SetResponse(oResp:ToJson())
    EndIf
    ::SetStatus(aTokens[1])

Return lRet
