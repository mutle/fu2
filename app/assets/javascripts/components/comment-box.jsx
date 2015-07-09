// var React = require("react");

var imageUpload, commentBox;

var ImageUploader = React.createClass({
  getInitialState: function() {
    return {message: "", filename: null};
  },
  startUpload: function(filename, form) {
    var u = this;
    var xhr = new XMLHttpRequest();
    xhr.open('POST', Data.url.image.create(), true);
    var token = $('meta[name="csrf-token"]').attr('content');
    xhr.setRequestHeader('X_CSRF_TOKEN', token);

    xhr.onreadystatechange = function(e) {
      if(xhr.readyState == 4) {
        if(xhr.status == 201 || xhr.status == 202) {
          u.setState({message: "Finished uploading \""+filename+"\"", filename: filename});
          if(commentBox) {
            commentBox.insertImage(JSON.parse(xhr.responseText).url, "\n\n");
          }
        } else {
          u.setState({message: xhr.responseText, filename: filename});
        }
      }
    };
    xhr.onerror = function(e) {
      u.setState({message: "error", filename: filename});
    };

    if(xhr.upload)
      xhr.upload.onprogress = function(e) {
        var percentage = Math.round((e.loaded / e.total) * 100);
        u.setState({message: "Uploading \""+filename+"\" ("+percentage+"%)", filename: filename});
      };

    var f = new FormData(form[0]);
    xhr.send(f);
  },
  click: function(e) {
    e.preventDefault();
    var form = $(this.getDOMNode()).parents("form");
    var file = form.find("input.file");
    var u = this;
    file.off('change');
    file.on('change', function(e) {
      u.selectFile();
    });
    file.trigger("click");
  },
  selectFile: function(e) {
    var form = $(this.getDOMNode()).parents("form");
    var file = form.find("input.file");
    var f = file.val().split("\\");
    var filename = f[f.length - 1];
    this.startUpload(filename, form);
  },
  render: function() {
    return <div>
      <input type='file' className='file' name='image[image_file]' />
      <button onClick={this.click} className="response-button content-button upload-image"><span className="octicon octicon-device-camera"></span></button>
      <span className="info">{this.state.message}</span>
    </div>;
  }
})

var AutoCompleterResult = React.createClass({
  render: function() {
    var className = "result "+ (this.props.highlight ? "highlight" : "");
    var title = this.props.value.login ? this.props.value.login : this.props.value;
    var image = this.props.imageUrl ? this.props.imageUrl(this.props.value) : this.props.value.image ? this.props.value.image : null;
    return <li className={className} onClick={this.props.clickCallback} data-value={title}><img src={image} />{title}</li>;
  }
});

var AutoCompleter = React.createClass({
  render: function() {
    var input = this.props.input;
    var selection = this.props.selection;
    var imageUrl = this.props.imageUrl;
    var clickCallback = this.props.clickCallback;
    var n = 0;
    var results = this.props.objects.map(function(r, i) {
      var s = r;
      if(r.login) {
        s = r.login;
        imageUrl = function() { return r.avatar_url; };
      }
      var highlight = selection == i;
      return <AutoCompleterResult key={s} value={r} highlight={highlight} imageUrl={imageUrl} clickCallback={clickCallback} />;
    })
    return <ul className="autocompleter">
      {results}
    </ul>;
  }
});

var CommentBox = React.createClass({
  getInitialState: function() {
    var syntax = $('#syntax').val();
    if(!syntax || syntax.length == 0) syntax = "md"
    return {text: "", valueName: "post[body]", syntax: syntax, autocomplete: null, autocompleteobjects: [], autocompleteinput: "", autocompletestart: null, autocompleteselection: 0};
  },
  insertImage: function(url, prefix) {
    if(this.state.syntax == "html") {
      this.insert("<img src=\""+url+"\" />");
    } else {
      this.insert("![]("+url+")");
    }
  },
  insert: function(text, prefix) {
    var s = this.state.text;
    if(this.state.syntax == "html") {
      $.markItUp({target: $('.comment-box'), placeHolder: text})
      this.setState({text: $('.comment-box').val()});
    } else {
      if(prefix && s.length > 0) s += prefix;
      s += text;
      this.setState({text: s});
      $(this.getDOMNode()).find(".comment-box").focus();
    }
  },
  submit: function(e) {
    e.preventDefault();
    var c = this;
    var data = {body: this.state.text};
    Data.create("post", [this.props.channelId], data, {error: function() {
      $('.comment-box-form textarea').val(c.state.text)
      imageUpload.setState({message: "Error sending post. Please try again."})
    }, success: function() {
      c.setState({text: ""})
    }});
    // $.ajax({type: "POST", dataType: "json", url: $(this.getDOMNode()).parents("form").attr("action"), data: data,
    //   success: function(data) {
    //     var d = $(data.rendered)
    //     window.updateTimestamps(d.find(".update-ts"));
    //     if(!window.socket.active) $("#content .channel-posts").append(d)
    //     c.setState({text: ""})
    //   }, error: function() {
    //     $('.comment-box-form textarea').val(c.state.text)
    //     imageUpload.setState({message: "Error sending post. Please try again."})
    //   }
    // });
  },
  blur: function(e) {
    this.setState({autocomplete: null});
  },
  input: function(e) {
    var cursorE = $(this.getDOMNode()).find(".comment-box").get(0).selectionEnd;
    var cursorS = $(this.getDOMNode()).find(".comment-box").get(0).selectionStart;

    if(this.state.autocomplete && cursorE < this.state.autocompletestart) {
      this.setState({autocomplete: null});
    }
    switch(e.key) {
      case "Escape":
      case " ":
        this.setState({autocomplete: null});
        break;
      case "Enter":
        if(this.state.autocomplete) {
          e.preventDefault();
          var result = this.state.autocompleteobjectsfiltered[this.state.autocompleteselection];
          if(result) {
            if(result.login) result = result.login;
            var input = e.target.value.slice(0, this.state.autocompletestart) + result + (this.state.autocomplete == "emoji" ? ":" : "") + e.target.value.slice(cursorE, e.target.value.length);
            e.target.value = input;
            this.setState({autocomplete: null, text: input});
          } else {
            this.setState({autocomplete: null});
          }
        }
        break;
      case "ArrowUp":
        if(this.state.autocomplete) {
          e.preventDefault();
          var v = this.state.autocompleteselection - 1;
          if(v < 0) v = 0;
          this.setState({autocompleteselection: v});
        }
        break;
      case "ArrowDown":
        if(this.state.autocomplete) {
          e.preventDefault();
          var v = this.state.autocompleteselection + 1;
          if(v >= this.state.autocompleteobjectsfiltered.length) v = this.state.autocompleteobjectsfiltered.length - 1;
          this.setState({autocompleteselection: v});
        }
        break;
      case ":":
        if(this.state.autocomplete)
          this.setState({autocomplete: null});
        else
          this.setState({autocomplete: "emoji", autocompleteselection: 0, autocompleteobjects: window.Emojis, autocompleteobjectsfiltered: this.filterObjects("", window.Emojis), autocompleteinput: "", autocompletestart: cursorE+1});
        break;
      case "@":
        this.setState({autocomplete: "users", autocompleteselection: 0, autocompleteobjects: window.Users, autocompleteobjectsfiltered: this.filterObjects("", window.Users), autocompleteinput: "", autocompletestart: cursorE+1});
        break;
    }
    if(this.state.autocomplete) {
      var key = e.key;
      if(key == "Backspace") {
        cursorE -= 2;
        key = "";
      }
      if(key.length <= 1) {
        var input = e.target.value.slice(this.state.autocompletestart, cursorE+1) + key;
        this.setState({autocompleteinput: input, autocompleteobjectsfiltered: this.filterObjects(input), autocompleteselection: 0});
      }
    }
  },
  filterObjects: function(input, objects) {
    var n = 0;
    if(!objects) objects = this.state.autocompleteobjects;
    var filtered = [];
    objects.map(function(r, i) {
      var s = r;
      if(r.login) s = r.login;
      if(n < 10 && (input.length < 1 || s.indexOf(input) == 0)) {
        n++;
        filtered.push(r);
      }
    });
    return filtered;
  },
  change: function(e) {
    this.setState({text: e.target.value});
  },
  autocompleteClick: function(e) {
    if(this.state.autocomplete) {
      var text = $(this.getDOMNode()).find(".comment-box");
      var cursorE = text.get(0).selectionEnd;
      var s = text.val();
      var value = $(e.target).parents(".result").data("value");
      var input = s.slice(0, this.state.autocompletestart) + value + (this.state.autocomplete == "emoji" ? ":" : "") + s.slice(cursorE, s.length);
      e.target.value = input;
      this.setState({autocomplete: null, text: input});
      text.focus();
    }
  },
  componentDidMount: function() {
    if(this.state.syntax == "html")
      $('.comment-box').markItUp(mySettings)
  },
  render: function() {
    var autocompleter = null;
    var imageUrl;
    if(this.state.autocomplete) {
      if(this.state.autocomplete == "emoji") imageUrl = function(s) { return "/images/emoji/"+s+".png"; };
      autocompleter = <AutoCompleter objects={this.state.autocompleteobjectsfiltered} selection={this.state.autocompleteselection} imageUrl={imageUrl} clickCallback={this.autocompleteClick} />;
    }
    return <div>
      <form className="comment-box-form" onSubmit={this.submit}>
        <div className="comment-box-container">
          {autocompleter}
          <textarea onBlur={this.blur} onKeyDown={this.input} onKeyPress={this.input} onChange={this.change} className="comment-box" name={this.state.valueName} id="post_body" value={this.state.text}></textarea>
        </div>
        <div className="actions">
          <button className="response-button content-button markdown-help"><span className="octicon octicon-markdown"></span></button>
          <input className="response-button content-button" accessKey="s" type="submit" />
        </div>
      </form>

      <div className="actions left">
        <form encType='multipart/form-data'>
          <div className="upload-image">
            <ImageUploader channelId={this.props.channelId} />
          </div>
        </form>
      </div>
    </div>;
  }
});

// module.exports = CommentBox;
window.CommentBox = CommentBox;
