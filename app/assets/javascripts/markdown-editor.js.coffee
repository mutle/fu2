toolbarTemplate = () ->
  "
<div class=\"markdown\">
  <div class=\"editor-toolbar\">
    <a href=\"http://en.wikipedia.org/wiki/Markdown#Example\" class=\"reference\"><span class=\"octicon octicon-markdown\"></span></a>
    <a href=\"#\" class=\"quote\"><span class=\"octicon octicon-quote\"></span></a>
    <a href=\"#\" class=\"link\"><span class=\"octicon octicon-link\"></span></a>
    <a href=\"#\" class=\"image\"><span class=\"octicon octicon-file-media\"></span></a>
    <span class=\"divider\"></span>
    <a href=\"#\" class=\"bold\" >B</a>
    <a href=\"#\" class=\"italic\">I</a>
    <a href=\"#\" class=\"underline\">U</a>
    <span class=\"divider\"></span>
  </div>
</div>"

class MarkdownEditor
  constructor: (t) ->
    $t = $(t)
    @t = $t
    @toolbar = $(toolbarTemplate())
    $t.before @toolbar
    @cm = CodeMirror.fromTextArea $t.get(0),
      mode: "markdown"
      lineWrapping: true
      theme: "redcursor"

    editor = this
    @toolbar.find("a").click ->
      return true if $(this).hasClass("reference")
      action = $(this).attr("class")
      editor["action_#{action}"]?()
      return false

  selectedText: () ->
     text = @cm.getSelection()

  wrapSelectedText: (pre, post) ->
    post ?= pre
    c = @cursor()
    @cm.replaceSelection pre + @selectedText() + post
    c[0].ch += pre.length
    c[1].ch += pre.length
    @setCursor c

  toggleLine: (type) ->
    toggles =
      quote:
        pattern: /^\s*>\s*/
        insert: "> "
    c = @cursor()
    toggle = toggles[type]
    return if !toggle
    for line in [c[0].line..c[1].line]
      text = @cm.getLine line
      @cm.replaceRange toggle.insert, new CodeMirror.Pos(line, 0)
    c[0].ch = 0
    c[1].ch += toggle.insert.length
    @setCursor c

  cursor: () ->
     [ @cm.getCursor('start'), @cm.getCursor('end') ]

  setCursor: (c) ->
    @cm.setSelection c[0], c[1]
    @cm.focus()

  state: () ->
    # @cm.getState()

  clear: () ->
    @setText ""

  setText: (text) ->
    @cm.setValue text
    @cm.clearHistory()

  sync: () ->
    @t.val @cm.getValue()

  action_quote: => @toggleLine('quote')
  action_link: => @wrapSelectedText("[", "](http://)")
  action_image: => @wrapSelectedText("![](", ")")
  action_bold: => @wrapSelectedText("**")
  action_italic: => @wrapSelectedText("*")
  action_strike: => @wrapSelectedText("~~")

window.MarkdownEditor = MarkdownEditor
