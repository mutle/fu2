var imageUpload, commentBox;

var FaveCounter = React.createClass({
  getInitialState: function() {
    return {faves: [], state: 0, postId: 0};
  },
  click: function(e) {
    e.preventDefault();
    if(this.state.postId > 0) {
      var c = this;
      $.ajax({url:"/posts/"+this.state.postId+"/fave", dataType: "json", type: "post"}).done(function(msg) {
        c.setState({state: msg.status ? 1 : 0, faves: msg.faves});
      });
    }
  },
  render: function() {
    var icon = <span className="octicon octicon-star" />;
    var inner = null;
    if(!this.state.faves || this.state.faves.length == 0) inner = <span>{icon}{'0'}</span>;
    else inner = <span>{icon}{this.state.faves.length}</span>;
    var className = "";
    if(this.state.faves.length > 0) className = "faved";
    if(this.state.state == 1) className = "on";
    return <a href="#" title={(this.state.faves ? this.state.faves : []).join(", ")} onClick={this.click} className={className}>{inner}</a>;
  }
});

var ImageUploader = React.createClass({
  getInitialState: function() {
    return {url: null, message: "", filename: null};
  },
  startUpload: function(filename, form) {
    var u = this;
    var xhr = new XMLHttpRequest();
    xhr.open('POST', this.state.url, true)
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
    }

    if(xhr.upload)
      xhr.upload.onprogress = function(e) {
        var percentage = Math.round((e.loaded / e.total) * 100);
        u.setState({message: "Uploading \""+filename+"\" ("+percentage+"%)", filename: filename})
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
    if(this.state.url)
      return <div>
        <input type='file' className='file' name='image[image_file]' />
        <button onClick={this.click} className="response-button content-button upload-image"><span className="octicon octicon-device-camera"></span></button>
        <span className="info">{this.state.message}</span>
      </div>;
    else
      return null;
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
    var data = {};
    data[this.state.valueName] = this.state.text;
    $.ajax({type: "POST", dataType: "json", url: $(this.getDOMNode()).parents("form").attr("action"), data: data,
      success: function(data) {
        var d = $(data.rendered)
        window.updateTimestamps(d.find(".update-ts"));
        if(!window.socket.active) $("#content .channel-posts").append(d)
        c.setState({text: ""})
      }, error: function() {
        $('.comment-box-form textarea').val(c.state.text)
        imageUpload.setState({message: "Error sending post. Please try again."})
      }
    });
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
      {autocompleter}
      <textarea onKeyDown={this.input} onKeyPress={this.input} onChange={this.change} className="comment-box" name={this.state.valueName} id="post_body" value={this.state.text}></textarea>
    </div>;
  }
});

Timestamp = React.createClass({
  getInitialState: function() {
    return {timestamp: ""};
  },
  shouldComponentUpdate: function() {
    if(!this.lastts) return true;
    if(this.lastts != formatTimestamp(this.state.timestamp)) return true;
    return false;
  },
  render: function() {
    if(this.state.timestamp == "") return null;
    this.lastts = formatTimestamp(this.state.timestamp)
    return <span className="ts">{this.lastts}</span>;
  }
});

$(function() {

  $(".channel-post .faves").each(function(i, fave) {
    var f = React.render(<FaveCounter />, fave);
    f.setState({faves: $(fave).data("faves"), state: parseInt($(fave).data("value")), postId: parseInt($(fave).parents(".channel-post").data("post-id"))});
  });

  var imageUploadE = $(".upload-image");
  if(imageUploadE.length > 0) {
    var image = imageUploadE[0];
    imageUpload = React.render(<ImageUploader />, image);
    imageUpload.setState({url: $(image).data("uploader-url")});
  }

  var commentBoxF = $(".channel-response form")
  var commentBoxE = $(".comment-box-container");
  if(commentBoxE.length > 0) {
    var comment = commentBoxE[0];
    var name = commentBoxE.find("textarea").attr("name");
    var value = commentBoxE.find("textarea").val();
    commentBox = React.render(<CommentBox />, comment);
    commentBox.setState({valueName: name, text: value});
    commentBoxF.on("submit", function(e) {
      commentBox.submit(e);
    })
  }

  var timestamps = []
  window.updateTimestamps = function(timestampE) {
    $.each(timestampE, function(i,e) {
     var t = parseInt($(e).data("timestamp")) * 1000;
     var ts = React.render(<Timestamp />, e);
     ts.setState({timestamp: t});
     timestamps.push(ts);
   });
  }
  var updateTs = function() {
    $.each(timestamps, function(i, ts) {
      ts.setState({});
    });
  }
  window.setInterval(updateTs, 1000);
  updateTimestamps($(".update-ts"));
});
