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

## Website monitor

`HelloWorldMonitor` checks the website immediately, then every 60 seconds. The default URL is `http://localhost:8080/api/`, set in `src/HelloWorldMonitor/appsettings.json` under `Monitor:Url`.

For local testing, start the API using the command above, then open another terminal:

```bash
dotnet run --project src/HelloWorldMonitor -- --Monitor:Url http://localhost:5184/
```

In the IDE, select `HelloWorldMonitor` as the startup project and set `Monitor:Url` to the URL you want to check before running or debugging it.

Results are appended to `status.log` beside the monitor executable, with a timestamp, URL, HTTP code and message. For a default local build, the file is in `src/HelloWorldMonitor/bin/Debug/net10.0/`. The service account must have write permission in that directory.

To check the behavior:

- Leave the API running for over a minute: two `HTTP 200 OK` entries should appear and the monitor should stay running.
- Run the monitor with `http://localhost:5184/does-not-exist`: it should log `404` and exit with code 1.
- Stop the API and run the monitor again: it should log a connection error and exit with code 1.
- Requests taking longer than 10 seconds are logged as timeouts and also stop the monitor.

Redirects are not followed: only HTTP 200 keeps the monitor running. For the IIS HTTPS endpoint, use `https://localhost:8443/api/` with a certificate trusted by the machine running the monitor.

Console behavior has been checked locally. IDE debugging and execution as an installed Windows service still need validation on the target environment.
