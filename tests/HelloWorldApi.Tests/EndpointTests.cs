using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;

namespace HelloWorldApi.Tests;

public class EndpointTests(WebApplicationFactory<Program> factory)
    : IClassFixture<WebApplicationFactory<Program>>
{
    [Theory]
    [InlineData("/", "Hello World!")]
    [InlineData("/health", "Healthy")]
    public async Task Get_ReturnsExpectedResponse(string path, string expectedBody)
    {
        using var client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            BaseAddress = new Uri("https://localhost"),
            AllowAutoRedirect = false
        });

        using var response = await client.GetAsync(path);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("text/plain", response.Content.Headers.ContentType?.MediaType);
        Assert.Equal(expectedBody, await response.Content.ReadAsStringAsync());
    }
}
