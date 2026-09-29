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
$credential = Get-Credential -UserName "$env:COMPUTERNAME\HelloWorldUser" -Message 'Existing account for the monitor service'
.\scripts\deploy-monitor.ps1 -MonitorUrl 'https://localhost:8443/api/' -Credential $credential
```

The URL must return HTTP 200 directly. The monitor does not follow redirects, so the IIS HTTP URL that returns 307 is unsuitable. For HTTPS, configure a certificate trusted by the service account before starting the service; the development self-signed certificate is not trusted automatically. The script does not bypass TLS validation.

The deployment copies the publish directory to `C:\Program Files\HelloWorldMonitor`, registers `HelloWorldMonitor` pointing directly to the quoted `.exe` path, sets Automatic startup and starts it. `status.log` is written beside the executable. Optional `-PublishDir` and `-DeploymentDir` parameters override the source and destination directories.

Use an existing enabled local or domain account. The mandatory `-Credential` parameter accepts a `PSCredential` from `Get-Credential`; the password is passed directly to Windows service registration and is not written to a file, command-line argument or source control. Windows stores the service credential. Do not put a plaintext password into a script.

The installer grants `SeServiceLogonRight` to that account through the local Windows LSA API without replacing other policy assignments. Keep `scripts/ServiceLogonRight.cs` beside the deployment script. Domain policy or a deny-logon policy can override this grant; resolve those policies if startup reports a logon failure.

The fresh deployment directory gives Administrators and SYSTEM full control and the service account inherited read/execute access. The installer pre-creates `status.log` and grants the account Modify on that file only, so logging does not require write access to the application binaries. It also registers the monitor's Windows Event Log source while elevated.

The installer configures the first, second and subsequent failures to restart the service after **300 seconds** (300000 milliseconds), with the failure count reset after 24 hours without failures. The monitor finishes writing the failure to `status.log` before exiting with code 1. When hosted as a Windows service it terminates the process so the Service Control Manager recognizes the failure and performs recovery; console execution still uses normal host shutdown with exit code 1. An intentional `Stop-Service` uses normal cancellation, not this failure-exit path.

An existing service or nonempty destination is rejected without overwriting it; in-place updates are not implemented. If startup fails, the installed service, recovery configuration and assigned rights are retained for diagnosis; inspect `status.log`, the target URL/certificate and account credentials. Disable the service while diagnosing if automatic retries are unwanted. Removing the service does not automatically revoke account rights; review them when decommissioning a dedicated account.

```powershell
Get-Service HelloWorldMonitor
Get-CimInstance Win32_Service -Filter "Name='HelloWorldMonitor'" |
    Select-Object Name, State, StartMode, PathName, StartName
Get-Content 'C:\Program Files\HelloWorldMonitor\status.log' -Tail 10
sc.exe qfailure HelloWorldMonitor
sc.exe qfailureflag HelloWorldMonitor
```

For an end-to-end recovery check, first observe two healthy IIS log entries 60 seconds apart. Make the monitored endpoint return a non-200 response, confirm the result is logged and the monitor stops, then restore the endpoint. Do not manually start the monitor: Windows should restart it after 300 seconds and a new HTTP 200 entry should appear. Service-hosted failure handling follows [Microsoft's Windows service recovery guidance](https://learn.microsoft.com/en-us/dotnet/core/extensions/windows-service#service-recovery-options-and-net-backgroundservice-instances).

Implementation and validation status: [Step 4 checklist](docs/requirements-criteria/step4.md).

## Docker image (Step 5)

The pipeline targets the Linux amd64 image at `ghcr.io/ruantiengo/eurofins-devops-takehome`. Each successful main CI publication pushes `sha-<full-commit-SHA>` and updates `latest`. Use the commit tag or the digest recorded in the CI image job summary for reproducible deployment; `latest` moves. Pull requests build and test the image without publishing.

The multi-stage Dockerfile publishes the API with the .NET 10 SDK and ships the ASP.NET Core 10 runtime. It runs as the image's non-root app user and listens on **HTTP port 8080**. Its routes are `/` and `/health`; the IIS `/api` prefix does not apply. TLS should be terminated by the hosting platform or reverse proxy.

Install Docker Engine, or Docker Desktop using **Linux containers** on Windows. From the repository root:

```sh
docker build --pull -t helloworld-api:local .
docker run --rm --name helloworld-api -p 8080:8080 helloworld-api:local
```

In another terminal, check `http://localhost:8080/` (HTTP 200, `Hello World!`) and `http://localhost:8080/health` (HTTP 200, `Healthy`). Choose another host port, such as `-p 18080:8080`, if IIS already uses 8080.

To run a published version, replace the example tag with a full commit SHA from a successful CI run:

```sh
docker pull ghcr.io/ruantiengo/eurofins-devops-takehome:sha-<full-commit-SHA>
docker run --rm -p 18080:8080 ghcr.io/ruantiengo/eurofins-devops-takehome:sha-<full-commit-SHA>
```

GHCR packages are private by default. Private pulls require an account with package read access and a personal access token (classic) with `read:packages`; use `docker login ghcr.io -u YOUR_GITHUB_USERNAME` and enter the token at the password prompt. Never put tokens in files or commit them. Public packages allow anonymous pulls. The owner can manage visibility and access in the GitHub package settings.

CI authenticates with the short-lived `GITHUB_TOKEN` and job-scoped `packages: write`; no personal token or registry password is stored in source control. The package is associated with this repository through its OCI source label. Repository or organization policy must allow package creation and workflow writes; an existing package must grant this repository Actions access.

CI retains the solution build, integration tests and downloadable `HelloWorldApi` package. The image job waits for those checks, builds the image, verifies both endpoint status codes and bodies, publishes both tags, pulls the commit tag and runs the pulled digest through the same checks. Build, push, pull or smoke-test errors fail the workflow. On Linux with Docker and curl, repeat the smoke test with `bash scripts/test-container.sh IMAGE_REFERENCE`.

Validation evidence and completion status: [Step 5 checklist](docs/requirements-criteria/step5.md).
