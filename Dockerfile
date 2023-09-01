ARG __base_image=sxw4acr.azurecr.io/msr-1015-lean-original-recipe:Fixes_23-08-30
FROM ${__base_image}

COPY ./code/is-packages/MyMailService ${SAG_HOME}/IntegrationServer/packages/MyMailService
COPY ./code/is-packages/MyNewsService ${SAG_HOME}/IntegrationServer/packages/MyNewsService