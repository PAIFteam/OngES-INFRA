FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["OngES-Core.sln", "./"]
COPY ["OngES-Core.API/OngES-Core.API.csproj", "OngES-Core.API/"]
COPY ["OngES-Core.Core/OngES-Core.Core.csproj", "OngES-Core.Core/"]
COPY ["OngES-Core.Infra/OngES-Core.Infra.csproj", "OngES-Core.Infra/"]
RUN dotnet restore "OngES-Core.sln"
COPY . .
RUN dotnet publish "OngES-Core.API/OngES-Core.API.csproj" --configuration Release --output /app/publish --no-restore /p:UseAppHost=false

FROM runtime AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "OngES-Core.API.dll"]
