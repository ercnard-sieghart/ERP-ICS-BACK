#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'RestFul.ch'

User Function USER_CONTROLLER()	
Return

WSRESTFUL LOGIN DESCRIPTION "Retorna informações do usuário"
	
	WSMETHOD POST 	DESCRIPTION "Retorna informações do usuário" WSSYNTAX ""

END WSRESTFUL


WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE LOGIN
    Local oUSERService 

    oUSERService := LoginService():Login()
    oRest:SetResponse(oUSERService:toJson())

Return
