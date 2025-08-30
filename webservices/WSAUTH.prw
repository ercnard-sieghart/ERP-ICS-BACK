#include "protheus.ch"
#Include "RestFul.CH"
#include "topconn.ch"
#include "tbiconn.ch"

WSRESTFUL Login Description "Login"

    WSMETHOD POST Description "Valida os dados de login no portal" WSSYNTAX "/login"

End WSRESTFUL

WSMETHOD POST WSService Login

    Local oJsnBody  := JsonObject():New()
    Local cJSON     := Self:GetContent()
    Local cRetJson  := oJsnBody:FromJson(cJSON)
    Local cUserName := oJsnBody["username"]
    Local cPassword := oJsnBody["password"]
    Local aTokens   := {}
    Local oResp     := JsonObject():New()
    Local cMsg      := "Login realizado com sucesso."

    aTokens := authgettoken():Token(cUserName, cPassword)

    If aTokens[1] == "400"
        cMsg    := "JSON inválido ou credenciais ausentes."
    Elseif aTokens[1] == "401"
        nStatus := 401
        cMsg    := "Usuário ou senha inválidos."
    Elseif aTokens[1] == "403"
        nStatus := 403
        cMsg    := "Acesso negado."
    Elseif aTokens[1] == "201"
        cJsonText := '{' + CRLF
        cJsonText += '  "access_token": "' + aTokens[2] + '",' + CRLF
        cJsonText += '  "refresh_token": "' + aTokens[3] + '",' + CRLF
        cJsonText += '  "scope": "' + aTokens[4] + '",' + CRLF
        cJsonText += '  "token_type": "' + aTokens[5] + '",' + CRLF
        cJsonText += '  "expires_in": ' + AllTrim(Str(aTokens[6])) + ',' + CRLF
        cJsonText += '  "success": true,' + CRLF
        cJsonText += '  "message": "' + cMsg + '",' + CRLF
        cJsonText += '  "name": "' + aTokens[7] + '",' + CRLF
        cJsonText += '  "email": "' + aTokens[8] + '"' + CRLF
        cJsonText += '}' + CRLF
    EndIf

    If aTokens[1] == "201"
        ::SetResponse(cJsonText)
    Else
        oResp["message"] := cMsg
        ::SetResponse(oResp:ToJson())
    EndIf
    ::SetStatus(val(aTokens[1]))

Return 
