#Include "protheus.ch"

Class SecurityService
	Data cID As Char
	Method New() As Object
    Static Method IsAdmin() As Logical
    Method HasFullAccess() As Logical
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
    Local nRet := 0

    cQuery := "SELECT ZE_PATENTE FROM " + RetSqlName("SZE") + " D "
    cQuery += "WHERE D_E_L_E_T_ = ' ' "
    cQuery += "  AND D.ZE_USR = '" + Self:cID + "'"
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .T.)
    
    If !(cAlias)->(Eof())
        nRet := Val( (cAlias)->(ZE_PATENTE) )
        If nRet == 101
            lFull := .T.
        EndIf
    EndIf

    (cAlias)->(dbCloseArea())

    Return lFull
Return
