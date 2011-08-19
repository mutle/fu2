$ = jQuery
Channel = Backbone.Model.extend
  initialize: ->
    @set
      selected: false

Post = Backbone.Model.extend
  initialize: ->
  user: ->
    window.users.get @get "user_id"

User = Backbone.Model.extend

Channels = Backbone.Collection.extend
  model: Channel
  url: '/channels'

Posts = Backbone.Collection.extend
  model: Post
  url: ->
    if @channel
      '/channels/'+@channel.id+'/posts'

Users = Backbone.Collection.extend
  model: Users
  url: '/users'

ChannelView = Backbone.View.extend
  tagName: "div"
  id: "channel"
  className: "grid_9"
  events:
    'click .add_comment': 'comment_field'
    'submit .comment form': 'comment'
  initialize: ->
    _.bindAll this, 'render'
    _.bindAll this, 'comment'
    _.bindAll this, 'comment_field'
    @model.bind 'change', this.render
    templateCode = $("#channel_template").html()
    @template = _.template templateCode
    @collection = new Posts
    @collection.channel = @model
    @collection.bind 'reset', this.render
    @collection.fetch()
  render: ->
    $el = $ @el
    content = @template @model
    $el.html content
    $posts = $el.find ".posts"
    collection = @collection
    if collection.length > 0
      $posts.empty()
    @collection.each (item) ->
      view = new PostView
        model: item
        collection: collection
      $posts.append view.render().el
    this
  comment: ->
    window.console.log $($(@el).find(".message").get(0)).html()
    false
  comment_field: ->


PostView = Backbone.View.extend
  className: "post"
  initialize: ->
    _.bindAll this, 'render'
    @model.bind 'change', this.render
    templateCode = $("#post_template").html()
    @template = _.template templateCode
  render: ->
    $el = $ @el
    user = @model.user()
    if user
      user = user.toJSON()
    else
      user = {}
    $el.html @template _.extend @model.toJSON(), {date: new Date(@model.get("created_at")), user: user}
    this

ChannelListView = Backbone.View.extend
  id: "channel_list"
  className: "grid_3"
  initialize: ->
    _.bindAll this, 'render'
    _.bindAll this, 'select'
    @collection.bind 'reset', this.render
    @collection.bind 'select', this.select
    templateCode = $("#channel_list_template").html()
    @template = _.template templateCode
  render: ->
    $el = $ @el
    $el.html @template
    channels = $el.find ".channels"
    collection = @collection
    @collection.each (item) ->
      view = new ChannelListItemView
        model: item
        collection: collection
      channels.append view.render().el
    this
  select: (selection) ->
    @collection.each (item) ->
      item.set
        selected: false
    selection.set
      selected: true

ChannelListItemView = Backbone.View.extend
  tagName: "li"
  events:
    'click .channel': 'select'
  initialize: ->
    _.bindAll this, 'render'
    @model.bind 'change', this.render
    templateCode = $("#channel_list_item_template").html()
    @template = _.template templateCode
  render: ->
    content = @template @model.toJSON()
    $(@el).html content
    this
  select: ->
    @collection.trigger "select", @model
    window.App.showChannel @model
  

Fu2App = Backbone.Router.extend
  routes:
    '': 'home'
  initialize: ->
    @channelListView = new ChannelListView
      collection: window.channels
  home: ->
    content = $ "#content"
    content.empty()
    content.append @channelListView.render().el
  showChannel: (channel) ->
    $("#content #channel").remove()
    @channelView = new ChannelView
      model: channel
    $("#content").append @channelView.render().el

window.channels = new Channels
window.users = new Users

$(document).ready ->
  window.users.fetch()
  window.channels.fetch()
  window.App = new Fu2App
  Backbone.history.start()

