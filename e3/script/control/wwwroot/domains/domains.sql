select DOMAIN, AUTH, AUTH_TYPE, DIRECTORY, ACCEPT_NEU, FORWARD_NEU from [LocalDomains.txt], [AuthSources.txt] where AUTH=SOURCE_NAME
