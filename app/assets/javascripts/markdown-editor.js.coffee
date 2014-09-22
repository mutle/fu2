toolbarTemplate = () ->
  "
<div class=\"markdown\">
  <div class=\"editor-toolbar\">
    <a class=\"bold\">B</a>
    <a class=\"italic\">I</a>
    <a class=\"underline\">U</a>
    <a class=\"strike\">S</a>
    <span class=\"divider\"></span>
    <a class=\"quote\"><span class=\"octicon octicon-quote\"></span></a>
    <a class=\"link\"><span class=\"octicon octicon-link\"></span></a>
    <span class=\"divider\"></span>
    <a class=\"list-ordered\"><span class=\"octicon octicon-list-ordered\"></span></a>
    <a class=\"list-unordered\"><span class=\"octicon octicon-list-unordered\"></span></a>
  </div>
</div>"


class MarkdownEditor
  constructor: (t) ->
    $t = $(t)
    $t.before toolbarTemplate()
    CodeMirror.fromTextArea $t.get(0),
      mode: "markdown"
      lineWrapping: true
      theme: "redcursor"

window.MarkdownEditor = MarkdownEditor
