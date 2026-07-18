FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["src/Service/OngES-Worker/OngES-Worker.API/OngES-Worker.API.csproj", "OngES-Worker.API/"]
COPY ["src/Service/OngES-Worker/OngES-Worker.Core/OngES-Worker.Core.csproj", "OngES-Worker.Core/"]
COPY ["src/Service/OngES-Worker/OngES-Worker.Infra/OngES-Worker.Infra.csproj", "OngES-Worker.Infra/"]

RUN dotnet restore "OngES-Worker.API/OngES-Worker.API.csproj"

COPY src/Service/OngES-Worker/ .

WORKDIR "/src/OngES-Worker.API"

RUN dotnet publish \
    "OngES-Worker.API.csproj" \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "OngES-Worker.API.dll"]