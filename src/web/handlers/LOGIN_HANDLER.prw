#include "protheus.ch"
#include "RestFul.CH"
#include "topconn.ch"
#include "tbiconn.ch"

WSRESTFUL Login DESCRIPTION "Login"
    WSMETHOD POST DESCRIPTION "Valida os dados de login no portal" WSSYNTAX "/login"
End WSRESTFUL

WSMETHOD POST WSRESTFUL Login
    Local cContent := Self:GetContent()
    Local aResponse := LoginService():Login(cContent)

    ::SetStatus(aResponse[1])
    ::SetResponse(aResponse[2])
Return

