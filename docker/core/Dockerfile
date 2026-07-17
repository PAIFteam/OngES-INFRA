FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

EXPOSE 8080

ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["src/Service/OngES-Core/OngES-Core.API/OngES-Core.API.csproj", "src/Service/OngES-Core/OngES-Core.API/"]
COPY ["src/Service/OngES-Core/OngES-Core.Core/OngES-Core.Core.csproj", "src/Service/OngES-Core/OngES-Core.Core/"]
COPY ["src/Service/OngES-Core/OngES-Core.Infra/OngES-Core.Infra.csproj", "src/Service/OngES-Core/OngES-Core.Infra/"]

RUN dotnet restore "src/Service/OngES-Core/OngES-Core.API/OngES-Core.API.csproj"

COPY . .

RUN dotnet publish "src/Service/OngES-Core/OngES-Core.API/OngES-Core.API.csproj" \
    --configuration Release \
    --output /app/publish \
    --no-restore \
    /p:UseAppHost=false

FROM runtime AS final
WORKDIR /app

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "OngES-Core.API.dll"]