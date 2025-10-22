#Include "protheus.ch"

Class SecurityService
	Data cID As Char
	Method New() As Object
    Static Method IsAdmin() As Logical
    Static Method HasFullAccess() As Logical
EndClass

Static Method New() Class SecurityService As Object
	
	Self:cID := __cUserID

Return Self

Method IsAdmin() Class SecurityService As Logical
    Return FWIsAdmin()
Return

Method HasFullAccess() Class SecurityService As Logical
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local lFull := .F.

    cQuery := "SELECT 1 FROM " + RetSqlName("SZD") + " D "
    cQuery += "WHERE D_E_L_E_T_ = ' ' "
    cQuery += "  AND D.ZD_MENU = '999999' "
    cQuery += "  AND D.ZD_PATENTE = " + __cUserID
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    If !(cAlias)->(Eof())
        lFull := .T.
    EndIf
    (cAlias)->(dbCloseArea())

    Return lFull
Return
