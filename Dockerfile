FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /source
COPY src/HelloWorldApi/HelloWorldApi.csproj src/HelloWorldApi/
RUN dotnet restore src/HelloWorldApi/HelloWorldApi.csproj
COPY src/HelloWorldApi/ src/HelloWorldApi/
RUN dotnet publish src/HelloWorldApi/HelloWorldApi.csproj --configuration Release --no-restore --output /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
COPY --from=build /app/publish .
USER $APP_UID
ENTRYPOINT ["dotnet", "HelloWorldApi.dll"]
