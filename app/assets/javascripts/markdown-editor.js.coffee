toolbarTemplate = () ->
  "
<div class=\"markdown\">
  <div class=\"editor-toolbar\">
    <a href=\"http://en.wikipedia.org/wiki/Markdown#Example\" class=\"reference\"><span class=\"octicon octicon-markdown\"></span></a>
    <a href=\"#\" class=\"quote\"><span class=\"octicon octicon-quote\"></span></a>
    <a href=\"#\" class=\"link\"><span class=\"octicon octicon-link\"></span></a>
    <span class=\"divider\"></span>
    <a href=\"#\" class=\"bold\">B</a>
    <a href=\"#\" class=\"italic\">I</a>
    <a href=\"#\" class=\"underline\">U</a>
    <a href=\"#\" class=\"strike\">S</a>
    <span class=\"divider\"></span>
  </div>
</div>"

class MarkdownEditor
  constructor: (t) ->
    $t = $(t)
    @toolbar = $(toolbarTemplate())
    $t.before @toolbar
    CodeMirror.fromTextArea $t.get(0),
      mode: "markdown"
      lineWrapping: true
      theme: "redcursor"

    editor = this
    @toolbar.find("a").click ->
      return true if $(this).hasClass("reference")
      action = $(this).attr("class")
      editor["action_#{action}"]?()
      return false

  action_quote: => console.log('quote')
  action_link: => console.log('link')
  action_bold: => console.log('bold')
  action_italic: => console.log('italic')
  action_underline: => console.log('underline')
  action_strike: => console.log('strike')

window.MarkdownEditor = MarkdownEditor
