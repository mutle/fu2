module Fu2
  REACT_ROUTES = [
    ["", :root],
    ["/channels/new", :new_channel],
    "/channels/tags/:id",
    ["/channels/:id", :channel, :channel],
    "/channels",
    "/settings",
    "/users/:id",
    "/users",
    "/search",
    "/search/:query/:sort",
    "/search/:query",
    "/notifications/list",
    ["/notifications/:id", :notification],
    "/notifications",
  ]
end
