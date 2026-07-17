FROM mcr.microsoft.com/dotnet/runtime:8.0 AS runtime
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["OngES-Worker.sln", "./"]
COPY ["OngES-Worker.API/OngES-Worker.API.csproj", "OngES-Worker.API/"]
COPY ["OngES-Worker.Core/OngES-Worker.Core.csproj", "OngES-Worker.Core/"]
COPY ["OngES-Worker.Infra/OngES-Worker.Infra.csproj", "OngES-Worker.Infra/"]
RUN dotnet restore "OngES-Worker.sln"
COPY . .
RUN dotnet publish "OngES-Worker.API/OngES-Worker.API.csproj" --configuration Release --output /app/publish --no-restore /p:UseAppHost=false

FROM runtime AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "OngES-Worker.API.dll"]
