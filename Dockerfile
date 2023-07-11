# create the build instance 
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

WORKDIR /src                                                                    
COPY ./src ./

# restore solution # --disable-parallel
RUN dotnet restore NopCommerce.sln 

WORKDIR /src/Presentation/Nop.Web   

# build project   
RUN dotnet build Nop.Web.csproj -c Release

# build plugins
WORKDIR /src/Plugins/Nop.Plugin.DiscountRules.CustomerRoles
RUN dotnet build Nop.Plugin.DiscountRules.CustomerRoles.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.ExchangeRate.EcbExchange
RUN dotnet build Nop.Plugin.ExchangeRate.EcbExchange.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.ExternalAuth.Facebook
RUN dotnet build Nop.Plugin.ExternalAuth.Facebook.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Misc.Sendinblue
RUN dotnet build Nop.Plugin.Misc.Sendinblue.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Misc.WebApi.Frontend
RUN dotnet build Nop.Plugin.Misc.WebApi.Frontend.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.MultiFactorAuth.GoogleAuthenticator
RUN dotnet build Nop.Plugin.MultiFactorAuth.GoogleAuthenticator.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Payments.CheckMoneyOrder
RUN dotnet build Nop.Plugin.Payments.CheckMoneyOrder.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Payments.Manual
RUN dotnet build Nop.Plugin.Payments.Manual.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Payments.PayPalCommerce
RUN dotnet build Nop.Plugin.Payments.PayPalCommerce.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Payments.PayPalStandard
RUN dotnet build Nop.Plugin.Payments.PayPalStandard.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Pickup.PickupInStore
RUN dotnet build Nop.Plugin.Pickup.PickupInStore.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Shipping.EasyPost
RUN dotnet build Nop.Plugin.Shipping.EasyPost.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Shipping.FixedByWeightByTotal
RUN dotnet build Nop.Plugin.Shipping.FixedByWeightByTotal.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Shipping.ShipStation
RUN dotnet build Nop.Plugin.Shipping.ShipStation.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Shipping.UPS
RUN dotnet build Nop.Plugin.Shipping.UPS.csproj -c Release
# WORKDIR /src/Plugins/Nop.Plugin.Tax.Avalara
# RUN dotnet build Nop.Plugin.Tax.Avalara.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Tax.FixedOrByCountryStateZip
RUN dotnet build Nop.Plugin.Tax.FixedOrByCountryStateZip.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Widgets.AccessiBe
RUN dotnet build Nop.Plugin.Widgets.AccessiBe.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Widgets.FacebookPixel
RUN dotnet build Nop.Plugin.Widgets.FacebookPixel.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Widgets.GoogleAnalytics
RUN dotnet build Nop.Plugin.Widgets.GoogleAnalytics.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Widgets.NivoSlider
RUN dotnet build Nop.Plugin.Widgets.NivoSlider.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Widgets.What3words
RUN dotnet build Nop.Plugin.Widgets.What3words.csproj -c Release

# publish project
WORKDIR /src/Presentation/Nop.Web   
RUN dotnet publish Nop.Web.csproj -c Release -o /app/published

# create the runtime instance 
FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine AS runtime 

# add globalization support
RUN apk add --no-cache icu-libs
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# installs required packages
RUN apk add libgdiplus --no-cache --repository https://dl-3.alpinelinux.org/alpine/edge/main/ --allow-untrusted
RUN apk add libc-dev --no-cache
RUN apk add tzdata --no-cache

# copy entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

WORKDIR /app 
# EXPOSE the port to the Host OS
EXPOSE 3000 
#EXPOSE 6379
#EXPOSE 14

RUN mkdir bin
RUN mkdir logs 
RUN mkdir App_Data/
RUN mkdir App_Data/DataProtectionKeys
RUN mkdir Plugins
RUN mkdir wwwroot
RUN mkdir wwwroot/bundles
RUN mkdir wwwroot/db_backups
RUN mkdir wwwroot/files
RUN mkdir wwwroot/files/exportimport
RUN mkdir wwwroot/icons
RUN mkdir wwwroot/images
RUN mkdir wwwroot/images/thumbs
RUN mkdir wwwroot/images/uploaded

RUN chmod 775 App_Data/
RUN chmod 775 App_Data/DataProtectionKeys
RUN chmod 775 bin
RUN chmod 775 logs
RUN chmod 775 Plugins
RUN chmod 775 wwwroot/bundles
RUN chmod 775 wwwroot/db_backups
RUN chmod 775 wwwroot/files/exportimport
RUN chmod 775 wwwroot/icons
RUN chmod 775 wwwroot/images
RUN chmod 775 wwwroot/images/thumbs
RUN chmod 775 wwwroot/images/uploaded

COPY --from=build /app/published .
                            
ENTRYPOINT "/entrypoint.sh"
