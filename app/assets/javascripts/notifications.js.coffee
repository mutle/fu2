# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

templateUser = "
<<%= typeof(tag) == \"undefined\" ? 'div' : tag %> class=\"user user-<%= id %>\" data-user-id=\"<%= id %>\">
  <% if(typeof(showIndicator) !== \"undefined\" && showIndicator) { %>
  <div class=\"indicator message\">0</div>
  <div class=\"indicator mention\">0</div>
  <% } else { %>
    <a href=\"/users/<%= id %>\">
  <% } %>
  <img class=\"avatar\" src=\"<%= avatar_url %>\" />
  <span class=\"name\"><%= display_name_html %></span>
  <% if(typeof(showIndicator) == \"undefined\" || !showIndicator) { %>
    </a>
  <% } %>
</<%= typeof(tag) == \"undefined\" ? 'div' : tag %>>
"

templateMessage = "
<message<% if (typeof(own) !== \"undefined\" && own) { %> class=\"own\"<% } %>>
  <from class=\"user\">
    <%= avatar %>
  </from>
  <div class=\"body\">
    <div class=\"content\">
      <%= message %>
    </div>
  </div>
</message>
"

$ ->
  return if $(".notifications").length == 0
  user_id = parseInt($(".notifications").data("user-id"))
  show_user_id = 0
  users = {}
  unread_counts = {}
  unread_mention_counts = {}
  notifications = {}
  user_notifications = {}
  loadedParts = 0
  last_id = 0
  notify_new = false
  update_view = false
  first_run = true
  pause_polling = false
  send_button = $(".messages .response .send")
  messages = $(".messages .message-list")
  month_names = ["January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"]
  this_year = (new Date()).getFullYear()

  send_button.attr("disabled", true)

  resize = () ->
    input_height = 0
    if $(".input-text").hasClass("active")
      input_height = parseInt($(".notifications .input-text").css("height")) - parseInt($(".notifications .input").css("height"))
    response_height = parseInt($(".notifications .response").css("height")) + 44 + input_height
    console.log response_height
    height = $(window).height() - $(".notifications").get(0).offsetTop - response_height - 30
    $(".notifications .users").css("height", "#{height}px")
    messages.css("height", "#{height}px")
    $(".notifications .empty").css("height", "#{height}px")
    $(".notifications .welcome").css("height", "#{height}px")
    scrollMessages()
  $(window).resize -> resize()

  scrollMessages = () ->
    messages.scrollTop(messages[0].scrollHeight)

  inputValue = () ->
    if $(".input-text").hasClass("active")
      $(".input-text").val()
    else
      $(".input").val()

  resetInput = () ->
    $(".input-text").val("").removeClass("active")
    $(".messages .response .input").val("").show()
    resize()

  $(".input").keydown (e) ->
    if e.which == 13
      $(this).hide()
      $(".input-text").addClass("active").focus().val($(this).val()+"\n")
      resize()
      return false
    true

  updateUsers = () ->
    $(".users .indicator").hide()
    for id,n of user_notifications
      unread = _.filter n, (notif) -> notif.read == false && notif.notification_type == "message"
      unread_counts[id] = (unread || {}).length
      unread_mention = _.filter n, (notif) -> notif.read == false && notif.notification_type == "mention"
      unread_mention_counts[id] = (unread_mention || {}).length
      user = $("li.user-#{id}").addClass("active").removeClass("activity")
      indicator = user.find(" .indicator.message").show()
      indicator_mention = user.find(" .indicator.mention").show()
      last_count = parseInt(indicator.text())
      if last_count < unread_counts[id]
        user.addClass("activity")
      last_count = parseInt(indicator_mention.text())
      if last_count < unread_mention_counts[id]
        user.addClass("activity")
      indicator.text(unread_counts[id])
      indicator_mention.text(unread_mention_counts[id])
      indicator.hide() if unread_counts[id] == 0
      indicator_mention.hide() if unread_mention_counts[id] == 0
    $(".users .user.active").prependTo($(".users"))
    $(".users .divider-top").prependTo($(".users"))

  displayUserId = (n) ->
    if n.notification_type == "response" then n.user_id else n.created_by_id

  timestampText = (ts) ->
    d = new Date(ts)
    today = new Date()
    minutes = Math.round(d.getMinutes() / 5.0) * 5
    if minutes < 10
      minutes = "0#{minutes}"
    year = if d.getFullYear() != this_year then " #{d.getFullYear()}" else ""
    date = if today.getFullYear() == d.getFullYear() && today.getMonth() == d.getMonth() && today.getDate() == d.getDate() then ""
    else "#{month_names[d.getMonth()-1]} #{d.getDate()}#{year} - "
    "#{date}#{d.getHours()}:#{minutes}"

  createTimestamp = (n) ->
    date = timestampText(n.created_at)
    found = false
    messages.find("timestamp").each (i,ts) ->
      if $(ts).text() == date
        found = true
        return false
    return "" if found
    $("<timestamp>").data("timestamp", n.created_at).text(date)

  showMessage = (n) ->
    n.avatar_id ?= displayUserId(n)
    n.avatar ?= _.template(templateUser, _.extend(_.clone(users[n.avatar_id]), {tag: "div"}))
    message = _.template(templateMessage, _.extend(_.clone(n), {own: (n.avatar_id == user_id)}))
    messages.append createTimestamp(n)
    messages.append $(message)
    scrollMessages()

  addUserNotification = (n) ->
    last_id = parseInt(n.id) if n.id > last_id
    user_notifications[n.created_by_id] ?= []
    if notify_new
      user_notifications[n.created_by_id].push(n)
      if n.created_by_id == show_user_id
        update_view = true
      console.log ['new message', n]
    else
      user_notifications[n.created_by_id].unshift(n)

  addNotifications = (data) ->
    for n in data
      if n.created_by_id?
        addUserNotification(n)

  refreshNotifications = () ->
    return if pause_polling
    $.ajax
      dataType: "json",
      url: "/notifications.json?last_id=#{last_id}&cache=#{(new Date()).getTime()}",
      error: (xhr, status, error) ->
        console.log [xhr, status, error]
        console.log error.stack
      success: (data) ->
        return if pause_polling
        addNotifications(data)
        updateUsers()
        if first_run
          if match = window.location.hash.match(/^#([0-9]+)$/)
            showUser(parseInt(match[1]))
          notify_new = true
          first_run = false
          update_view = false
          window.setInterval refreshNotifications, 8 * 1000
        else if update_view
          update_view = false
          showUser(show_user_id)

  showUser = (id) ->
    show_user_id = id
    $(".messages .empty").hide()
    $(".messages .welcome").hide()
    $(".messages").addClass("active")
    notifications = user_notifications[id]
    messages.empty()
    if notifications?
      for n in notifications
        showMessage(n)
      messages.show()
    else
      $(".messages .empty").show().find(".username").html(users[id].display_name_html)
      messages.hide()
    send_button.attr("disabled", false)
    scrollMessages()
    hash = "##{id}"
    $(".users .user").removeClass("selected")
    $(".users .user-#{id}").addClass("selected")
    window.location.hash = hash if window.location.hash != hash
    if unread_counts[id] > 0 || unread_mention_counts[id] > 0
      updateCount(id)

  updateCount = (id) ->
    $.ajax
      dataType: "json",
      type: "POST",
      url: "/notifications/#{id}/read.json",
      success: (data) ->
        _.each user_notifications[id], (n) ->
          n.read = true
        unread_counts[id] = 0
        unread_mention_counts[id] = 0
        updateUsers()

  postMessage = (user, message, cb) ->
    if user?
      $.post "/notifications.json", {user_id: user.id, message: message}, cb

  send_button.click ->
    pause_polling = true
    postMessage users[show_user_id], inputValue(), (data) ->
      addUserNotification(data)
      showMessage(data)
      messages.show()
      $(".messages .empty").hide()
      resetInput()
      pause_polling = false

  $.getJSON "/users.json", (data) ->
    data = _.sortBy data, (u) ->
      u.display_name
    for user in data
      continue if user.login.match(/-disabled/) || (user.id == 40 && user_id != 1)
      users[user.id] = user
      continue if user.id == user_id
      item = _.template templateUser, _.extend(_.clone(user), showIndicator: true, tag: 'li')
      $(".users").append $(item)

    $(".users .user").click ->
      showUser parseInt($(this).data("user-id"))

    refreshNotifications()
  resize()
