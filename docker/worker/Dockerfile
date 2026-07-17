FROM mcr.microsoft.com/dotnet/runtime:8.0 AS runtime
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["src/OngES-Worker-API.sln", "src/"]

COPY ["src/OngES-Worker.API/OngES-Worker.API.csproj", "src/OngES-Worker.API/"]
COPY ["src/OngES-Worker.Core/OngES-Worker.Core.csproj", "src/OngES-Worker.Core/"]
COPY ["src/OngES-Worker.Infra/OngES-Worker.Infra.csproj", "src/OngES-Worker.Infra/"]

RUN dotnet restore "src/OngES-Worker-API.sln"

COPY . .

RUN dotnet publish "src/OngES-Worker.API/OngES-Worker.API.csproj" \
    --configuration Release \
    --output /app/publish \
    --no-restore \
    /p:UseAppHost=false

FROM runtime AS final
WORKDIR /app

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "OngES-Worker.API.dll"]