using System.Net;

namespace HelloWorldMonitor;

public class Worker(
    HttpClient client,
    Uri endpoint,
    ILogger<Worker> logger,
    IHostApplicationLifetime lifetime) : BackgroundService
{
    private readonly string logPath = Path.Combine(AppContext.BaseDirectory, "status.log");

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TimeSpan.FromSeconds(60));

        try
        {
            // Check immediately, then every 60 seconds.
            do
            {
                if (!await CheckWebsiteAsync(stoppingToken))
                {
                    Environment.ExitCode = 1;
                    lifetime.StopApplication();
                    return;
                }
            }
            while (await timer.WaitForNextTickAsync(stoppingToken));
        }
        catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
        {
            // Normal shutdown from the console or Windows Service Manager.
        }
    }

    private async Task<bool> CheckWebsiteAsync(CancellationToken cancellationToken)
    {
        try
        {
            using var response = await client.GetAsync(endpoint, cancellationToken);
            await WriteLogAsync($"HTTP {(int)response.StatusCode} {response.ReasonPhrase}", cancellationToken);

            logger.LogInformation("{Url}: HTTP {StatusCode} {Message}",
                endpoint, (int)response.StatusCode, response.ReasonPhrase);

            return response.StatusCode == HttpStatusCode.OK;
        }
        catch (HttpRequestException exception)
        {
            await WriteLogAsync($"Connection error (no HTTP response): {exception.Message}", cancellationToken);
            logger.LogError(exception, "Could not reach {Url}", endpoint);
            return false;
        }
        catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested)
        {
            await WriteLogAsync("Request timed out (no complete HTTP response)", cancellationToken);
            logger.LogError("Request to {Url} timed out", endpoint);
            return false;
        }
    }

    private Task WriteLogAsync(string message, CancellationToken cancellationToken)
    {
        var entry = $"{DateTimeOffset.Now:O} {endpoint}: {message}";
        return File.AppendAllTextAsync(logPath, entry + Environment.NewLine, cancellationToken);
    }
}
