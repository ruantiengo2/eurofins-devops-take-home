# Eurofins DevOps Take-Home

Simple Hello World API built with .NET 10.

## Run locally

Install the .NET 10 SDK, then run these commands from the repository root:

```bash
dotnet restore
dotnet run --project src/HelloWorldApi --launch-profile http
```

The API runs at `http://localhost:5184`. Press `Ctrl+C` to stop it.

## Build and test

```bash
dotnet build --configuration Release
dotnet test --configuration Release
```

Tests start the API in memory, so you don't need to run it separately.

## Endpoints

| Method | Path | Response |
| --- | --- | --- |
| GET | `/` | `200 OK` — `Hello World!` |
| GET | `/health` | `200 OK` — `Healthy` |

## Download the package

Open the repository's **Actions** tab, select a successful **CI** run, and download **HelloWorldApi** from **Artifacts**. You need to be signed in to GitHub.

The ZIP contains the published API and its dependencies. The target server needs the ASP.NET Core 10 runtime.
