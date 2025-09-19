#ifdef SPANISH
	#define STR0001 "Empresa"
	#define STR0002 "Sucursal"
	#define STR0003 "Configuracion invalida de Sucursal"
	#define STR0004 "Verificar Empresa/Sucursal en los Jobs"
	#define STR0005 "Iniciando el Workflow"
	#define STR0006 "Fecha"
	#define STR0007 "Hora"
	#define STR0008 "Seleccionando Registros..."
	#define STR0009 "No se encontro el archivo"
	#define STR0010 "Solicitud"
	#define STR0011 "Solicitante"
	#define STR0012 "Ejecutante"
	#define STR0013 "Bien/Localizacion"
	#define STR0014 "Fecha Apertura"
	#define STR0015 "Hora Apertura"
	#define STR0016 "Tipo Servicio"
	#define STR0017 "Servicio"
	#define STR0018 "Solicitud de Servicio - "
	#define STR0019 "Solicitud de Servicio que se atendera"
	#define STR0020 "Aviso de la Distribucion de S.S. enviado para el ejecutante"
#else
	#ifdef ENGLISH
		#define STR0001 "Company"
		#define STR0002 "Branch"
		#define STR0003 "Invalid Branch Conficuration"
		#define STR0004 "Check Company/Branch in Jobs"
		#define STR0005 "Beginning Workflow"
		#define STR0006 "Date"
		#define STR0007 "Hour"
		#define STR0008 "Selecting Files..."
		#define STR0009 "File not found"
		#define STR0010 "Request"
		#define STR0011 "Requester"
		#define STR0012 "Executer"
		#define STR0013 "Asset/Location"
		#define STR0014 "Opening Date"
		#define STR0015 "Opening Hour"
		#define STR0016 "Service Type"
		#define STR0017 "Service"
		#define STR0018 "Service Order - "
		#define STR0019 "Service Order to be met"
		#define STR0020 "Notice of S.S. Distribution sent to the executer"
	#else
		#define STR0001  "Empresa"
		#define STR0002  "Filial"
		Static STR0003 := "Configuração invalida de Filial"
		Static STR0004 := "Verificar Empresa/Filial nos Jobs"
		Static STR0005 := "Iniciando o Workflow"
		#define STR0006  "Data"
		#define STR0007  "Hora"
		Static STR0008 := "Selecionando Registros..."
		Static STR0009 := "Nao foi encontrado o arquivo"
		#define STR0010  "Solicitação"
		#define STR0011  "Solicitante"
		#define STR0012  "Executante"
		#define STR0013  "Bem/Localização"
		Static STR0014 := "Data Abertura"
		Static STR0015 := "Hora Abertura"
		Static STR0016 := "Tipo Serviço"
		#define STR0017  "Serviço"
		Static STR0018 := "Solicitação de Serviço - "
		Static STR0019 := "Solicitação de Serviço a ser atendida"
		Static STR0020 := "Aviso da Distribuição de S.S. enviado para o executante"
	#endif
#endif

#ifndef SPANISH
#ifndef ENGLISH
	STATIC uInit := __InitFun()

	Static Function __InitFun()
	uInit := Nil
	If Type('cPaisLoc') == 'C'

		If cPaisLoc == "ANG"
			STR0003 := "Configuração inválida de filial"
			STR0004 := "Verificar empresa/filial nos jobs"
			STR0005 := "A iniciar Workflow"
			STR0008 := "A seleccionar registos ..."
			STR0009 := "Não foi encontrado o ficheiro"
			STR0014 := "Data abertura"
			STR0015 := "Hora abertura"
			STR0016 := "Tipo serviço"
			STR0018 := "Solicitação de serviço - "
			STR0019 := "Solicitação de serviço a ser atendida"
			STR0020 := "Aviso da distribuição de S.S. enviado para o executante"
		ElseIf cPaisLoc == "PTG"
			STR0003 := "Configuração inválida de filial"
			STR0004 := "Verificar empresa/filial nos jobs"
			STR0005 := "A iniciar Workflow"
			STR0008 := "A seleccionar registos ..."
			STR0009 := "Não foi encontrado o ficheiro"
			STR0014 := "Data abertura"
			STR0015 := "Hora abertura"
			STR0016 := "Tipo serviço"
			STR0018 := "Solicitação de serviço - "
			STR0019 := "Solicitação de serviço a ser atendida"
			STR0020 := "Aviso da distribuição de S.S. enviado para o executante"
		EndIf
		EndIf
	Return Nil
#ENDIF
#ENDIF
