namespace HelloWorldApi.Tests;

public class EndpointTests
{
    [Theory(Skip = "Endpoint assertions will be implemented in the next commit.")]
    [InlineData("/", "Hello World!")]
    [InlineData("/health", "Healthy")]
    public void Get_ReturnsExpectedResponse(string path, string expectedBody)
    {
        throw new NotImplementedException();
    }
}
