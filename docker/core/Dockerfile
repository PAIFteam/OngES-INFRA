FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
EXPOSE 8080

ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["src/OngES-Core-API.sln", "src/"]

COPY ["src/OngES-Core.API/OngES-Core.API.csproj", "src/OngES-Core.API/"]
COPY ["src/OngES-Core.Core/OngES-Core.Core.csproj", "src/OngES-Core.Core/"]
COPY ["src/OngES-Core.Infra/OngES-Core.Infra.csproj", "src/OngES-Core.Infra/"]

RUN dotnet restore "src/OngES-Core-API.sln"

COPY . .

RUN dotnet publish "src/OngES-Core.API/OngES-Core.API.csproj" \
    --configuration Release \
    --output /app/publish \
    --no-restore \
    /p:UseAppHost=false

FROM runtime AS final
WORKDIR /app

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "OngES-Core.API.dll"]