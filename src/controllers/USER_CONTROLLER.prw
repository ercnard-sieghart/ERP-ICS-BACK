#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'RestFul.ch'

User Function USER_CONTROLLER()	
Return

WSRESTFUL LOGIN DESCRIPTION "Retorna informa��es do usu�rio"
	
	WSMETHOD POST 	DESCRIPTION "Retorna informa��es do usu�rio" WSSYNTAX ""

END WSRESTFUL


WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE LOGIN
    Local oUSERService 

    oUSERService := LoginService():Login()
    oRest:SetResponse(oUSERService:toJson())

Return
