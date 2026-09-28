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

Console behavior and execution as an installed Windows service have been checked locally. IDE debugging remains pending; see Step 4 below for installation scope and validation.

## Install the monitor as a Windows service (Step 4)

Publish with the .NET 10 SDK from the repository root:

```powershell
.\scripts\publish-monitor.ps1
```

This produces a framework-dependent Windows x64 executable at `artifacts/HelloWorldMonitor/win-x64/HelloWorldMonitor.exe`. Keep the whole published directory; the target needs the .NET 10 x64 runtime. Use `-OutputDir` to choose another publish directory.

Then open **64-bit Windows PowerShell 5.1 as Administrator** and run:

```powershell
.\scripts\deploy-monitor.ps1 -MonitorUrl 'https://localhost:8443/api/'
```

The URL must return HTTP 200 directly. The monitor does not follow redirects, so the IIS HTTP URL that returns 307 is unsuitable. For HTTPS, configure a certificate trusted by the service account before starting the service; the development self-signed certificate is not trusted automatically. The script does not bypass TLS validation.

The deployment copies the publish directory to `C:\Program Files\HelloWorldMonitor`, registers `HelloWorldMonitor` pointing directly to the quoted `.exe` path, sets Automatic startup and starts it. `status.log` is written beside the executable. Optional `-PublishDir` and `-DeploymentDir` parameters override the source and destination directories.

This initial installer uses **LocalSystem**, the Windows service default. Deployment under a specified user and 300-second recovery are separate, unfinished Step 4 tasks. An existing service or nonempty destination is rejected without overwriting it; in-place updates are not implemented. If startup fails, the installed service is retained for diagnosis; inspect `status.log` and the target URL/certificate.

```powershell
Get-Service HelloWorldMonitor
Get-CimInstance Win32_Service -Filter "Name='HelloWorldMonitor'" |
    Select-Object Name, State, StartMode, PathName, StartName
Get-Content 'C:\Program Files\HelloWorldMonitor\status.log' -Tail 10
```

Implementation and validation status: [Step 4 checklist](docs/requirements-criteria/step4.md).
