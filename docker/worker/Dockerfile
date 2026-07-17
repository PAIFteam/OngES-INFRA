FROM mcr.microsoft.com/dotnet/runtime:8.0 AS runtime
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["src/Service/OngES-Worker/OngES-Worker.API/OngES-Worker.API.csproj", "src/Service/OngES-Worker/OngES-Worker.API/"]
COPY ["src/Service/OngES-Worker/OngES-Worker.Core/OngES-Worker.Core.csproj", "src/Service/OngES-Worker/OngES-Worker.Core/"]
COPY ["src/Service/OngES-Worker/OngES-Worker.Infra/OngES-Worker.Infra.csproj", "src/Service/OngES-Worker/OngES-Worker.Infra/"]

RUN dotnet restore "src/Service/OngES-Worker/OngES-Worker.API/OngES-Worker.API.csproj"

COPY . .

RUN dotnet publish "src/Service/OngES-Worker/OngES-Worker.API/OngES-Worker.API.csproj" \
    --configuration Release \
    --output /app/publish \
    --no-restore \
    /p:UseAppHost=false

FROM runtime AS final
WORKDIR /app

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "OngES-Worker.API.dll"]