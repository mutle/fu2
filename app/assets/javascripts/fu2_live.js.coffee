Channel = Backbone.Model.extend
  initialize: ->
    @set
      selected: false

Post = Backbone.Model.extend
  initialize: ->
  user: ->
    # window.users.get @get "user_id"
  url: ->
    if @channel?
      '/channels/'+@channel.id+'/posts'
  forTemplate: ->
    attrs = @toJSON()
    attrs.body = @render @get "body"
    attrs
  render: (text) ->
    # text.replace /\n/, '<br />\n'
    if @get "markdown"
      markdown.toHTML text
    else
      text

User = Backbone.Model.extend
  initialized: ->

Channels = Backbone.Collection.extend
  model: Channel
  url: '/channels'

Posts = Backbone.Collection.extend
  model: Post
  url: ->
    if @channel?
      '/channels/'+@channel.id+'/posts'

Users = Backbone.Collection.extend
  model: Users
  url: '/users'

$ ->
  LiveView = Backbone.View.extend
    el: 'body'
    id: 'live-view'
    channels: []
    selectedChannel: null
    initialize: () ->
      _.bindAll this, 'render'
      @collection.bind 'reset', @render
      @render()
    render: () ->
      $el = $ @el
      $el.html ""
      channels = @channels
      _.each @collection.toArray().reverse(), (o) ->
        collection = new Posts
        collection.channel = o
        collection.fetch()
        view = new ChannelView
          model: o
          collection: collection
        $el.append view.render()
        channels.push view
      $el
    replyToPost: () ->
      if @selectedChannel? and @selectedChannel.selectedPost?
        window.console.log 'reply'
        @selectedChannel.selectedPost.respond()
    select: (channel) ->
      if channel?
        @selectedChannel = channel
        channel.select()
    selectNextChannel: () ->
      index = @channelIndex(@selectedChannel)
      if index == -1
        window.console.log 'no channel'
      channel = @channels[index + 1]
      if channel?
        window.console.log 'channel'
        @select channel
    selectNextPost: () ->
      if @selectedChannel?
        if !@selectedChannel.selectNextPost() 
          window.console.log 'next channel'
          @selectNextChannel()
      else
        window.console.log 'next channel'
        @selectNextChannel()
    previousPost: () ->
      @selectedChannel.selectPreviousPost() if @selectedChannel?
    selectChannel: (channel) ->
    channelIndex: (channel) ->
      return -1 if !channel?
      for p in @channels
        index = _i if p.model.get('id') == channel.model.get('id')
      -1


  ChannelView = Backbone.View.extend
    tagName: 'channel'
    events:
      'click button.respond': 'showResponseView'
    selectedPost: null
    views: []
    initialize: () ->
      _.bindAll this, 'render'
      _.bindAll this, 'renderPost'
      _.bindAll this, 'showResponseView'
      _.bindAll this, 'selectPost'
      _.bindAll this, 'addViewForPost'
      @collection.bind 'reset', @render
      @collection.bind 'add', @renderPost
    render: () ->
      channelView = this
      $el = $ @el
      template = Handlebars.compile $('#channel-view').html()
      $el.html template(@model.toJSON())
      @collection.each (o) ->
        channelView.addViewForPost o
      $(@el).find('bubble').hide()
      $(@el).find('bubble').last().show()
      $el
    renderPost: (model,collection,options) ->
      @addViewForPost model
      @responseView.remove() if @responseView?
      $(@el).find('button.respond').show()
    addViewForPost: (post) ->
      view = new PostView
        model: post
      view.channelView = this
      @views.push view
      $(@el).find('content').append view.render()
    showResponseView: () ->
      @showResponse null
    showResponse: (model) ->
      $el = $ @el
      $el.find('button.respond').hide()
      $el.find('bubble.response').remove()
      response = new ResponseView
      response.model = model if model?
      response.channel = @model
      response.channelView = this
      $el.find('response').append response.render()
      response.select()
      @responseView = response
    postAdded: (post, view) ->
      @collection.add post
    showAllPosts: () ->
      $(@el).find('bubble').show()
    select: (post) ->
      if post?
        post.select()
    selectPost: (post) ->
      @selectedPost = post
    selectNextPost: () ->
      if !@selectedPost?
        window.console.log 'no selection'
        index = -1
      else
        index = @viewIndex @selectedPost
        return false if index == -1
      view = @views[index + 1]
      window.console.log 'next '+ (index+1)
      window.console.log view
      if view?
        @select view
        @selectedPost = view
        return true
      false
    selectPreviousPost:() ->
    viewIndex: (view) ->
      return -1 if !view? or !@posts?
      for p in @posts
        return _i if view.model.get('id') == p.model.get('id')
      -1

  PostView = Backbone.View.extend
    tagName: 'bubble'
    events:
      'click': 'select'
      'click action.respond': 'respond'
      'click action.star': 'star'
    initialize: () ->
      _.bindAll this, 'render'
      _.bindAll this, 'select'
      _.bindAll this, 'respond'
      _.bindAll this, 'star'
    render: () ->
      $el = $ @el
      template = Handlebars.compile $('#post-view').html()
      if @model?
        $el.html template(@model.forTemplate())
      $el
    select: () ->
      $el = $ @el
      $("bubble").removeClass "selected"
      $el.addClass "selected"
      @channelView.selectPost this
      @channelView.showAllPosts()
    respond: () ->
      @channelView.showResponse @model
    star: () ->

  ResponseView = Backbone.View.extend
    # events:
    # 'focus input.response_text': 'showLongResponse'
    events:
      'click .submit': 'addComment'
    tagName: 'bubble'
    className: 'response'
    initialize: () ->
      _.bindAll this, 'render'
      _.bindAll this, 'addComment'
      # _.bindAll this, 'showLongResponse'
    text: () ->
      @textarea().val()
    textarea:() ->
      $(@el).find(".response_text_long")
    render: () ->
      $el = $ @el
      template = Handlebars.compile $('#response-view').html()
      $el.html template()
      if @model?
        @textarea().html @quote @model.get "body" 
      $el
    quote: (text) ->
      text.replace(/(^|\n)/g, '$1> ') + "\n\n"
    select: () ->
      @textarea().select()
    addComment: () ->
      $el = $ @el
      # $el.find("button").select()
      post = new Post
        body: @text()
      post.channel = @channel
      channelView = @channelView
      post.save {},
        success: () ->
          channelView.postAdded post
    # showLongResponse: () ->
    #   window.console.log 'event'
    #   $el = $ @el
    #   $el.find(".response_text").hide()
    #   $el.find(".response_text_long").show().select()

  Fu2Live = Backbone.Router.extend
    routes:
      "": "index"
    index: () ->
      @view = new LiveView
        collection: window.channels
  
  window.users = new Users
  # window.users.fetch()
  window.channels = new Channels
  window.channels.fetch()
  window.App = new Fu2Live
  Backbone.history.start()

  $(window).keypress (event) ->
    char = String.fromCharCode event.charCode
    app = window.App
    window.console.log char
    unhandled = false
    switch char
      when 'j' then app.view.selectNextPost()
      when 'k' then app.view.selectPreviousPost()
      when 'r' then app.view.replyToPost()
      else
        unhandled = true
    unhandled

