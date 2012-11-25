# Sets up a Webmock stub request for the given request (method, path) and
# returning the given response.
def api_stub(method, path, response)
  base_url = "https://test.mite.yo.lk"
  stub_request(
    method,
    File.join(base_url, path)
  ).to_return(
    :body => response
  )
end
