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

    @toolbar.find("a").click ->
      return true if $(this).hasClass("reference")
      return false

window.MarkdownEditor = MarkdownEditor
