var CommentBox = React.createClass({
  submit: function(e) {
    e.preventDefault();
    var c = this;
    var data = {body: this.editor.state.text};
    if(this.props.postId) {
      Data.action("update", "post", [this.props.channelId, this.props.postId], data, {error: function() {
        imageUpload.setState({message: "Error sending post. Please try again."});
      }, success: function(data) {
        Data.insert(data.post);
        Data.notify([data.post.type]);
        if(c.props.callback) {
          c.props.callback();
        }
      }});
    } else {
      Data.action("create", "post", [this.props.channelId], data, {error: function() {
        $('.comment-box-form textarea').val(c.editor.state.text);
        imageUpload.setState({message: "Error sending post. Please try again."});
      }, success: function(data) {
        Data.insert(data.post);
        Data.notify([data.post.type]);
        c.editor.setState({text: ""});
      }});
    }
  },
  uploadedImage: function(url) {
    if(this.editor) {
      this.editor.insertImage(url, "\n\n");
    }
  },
  render: function() {
    if(this.props.cancelCallback)
      var cancelButton = <button onClick={this.props.cancelCallback} className="response-button content-button" accessKey="c">Cancel</button>;
    var self = this;
    var refFunc = function(ref) { self.editor = ref; };
    return <div>
      <form className="comment-box-form" onSubmit={this.submit}>
        <div className="comment-box-container">
          <Editor ref={refFunc} initialText={this.props.initialText} textareaClass="comment-box" textareaId="post_body" valueName="post[body]" submit={this.submit} />
        </div>
        <div className="actions">
          {cancelButton}
          <input className="response-button content-button button-default" accessKey="s" value="Send" type="submit" />
        </div>
      </form>

      <div className="actions left">
        <form encType='multipart/form-data'>
          <div className="upload-image">
            <ImageUploader callback={this.uploadedImage} channelId={this.props.channelId} />
          </div>
        </form>
      </div>
    </div>;
  }
});

// module.exports = CommentBox;
window.CommentBox = CommentBox;
