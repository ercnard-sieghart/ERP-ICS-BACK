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
    Local lRet      := .T.
    Local nStatus   := 200
    Local cMsg      := "Login realizado com sucesso."

    If ValType(cRetJson) == "C" .Or. Empty(cUserName) .Or. Empty(cPassword)
        nStatus := 400
        cMsg    := "JSON inválido ou credenciais ausentes."
        lRet    := .F.
    Else
        aTokens := authgettoken():Token(cUserName, cPassword)
        If Empty(aTokens[1])
            nStatus := 401
            cMsg    := "Usuário ou senha inválidos."
            lRet    := .F.
        Else
            cJsonText := '{' + CRLF
            cJsonText += '  "access_token": "' + aTokens[1] + '",' + CRLF
            cJsonText += '  "refresh_token": "' + aTokens[2] + '",' + CRLF
            cJsonText += '  "scope": "' + aTokens[3] + '",' + CRLF
            cJsonText += '  "token_type": "' + aTokens[4] + '",' + CRLF
            cJsonText += '  "expires_in": ' + AllTrim(Str(aTokens[5])) + ',' + CRLF
            cJsonText += '  "success": true,' + CRLF
            cJsonText += '  "message": "' + cMsg + '"' + CRLF
            cJsonText += '}' + CRLF
        EndIf
    EndIf

    If lRet .And. !Empty(aTokens[1])
        ::SetResponse(cJsonText)
    Else
        oResp["success"] := lRet
        oResp["message"] := cMsg
        ::SetResponse(oResp:ToJson())
    EndIf
    ::SetStatus(nStatus)

Return lRet
