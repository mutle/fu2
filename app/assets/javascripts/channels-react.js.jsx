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
    var token = $('meta[name="_csrf"]').attr('content');
    xhr.setRequestHeader('X_CSRF_TOKEN', token);

    xhr.onreadystatechange = function(e) {
      if(xhr.readyState == 4) {
        if(xhr.status == 201 || xhr.status == 202) {
          u.setState({message: "Finished uploading \""+filename+"\"", filename: filename})
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
    console.log(f);
    xhr.send(f);
  },
  click: function(e) {
    e.preventDefault();
    var form = $(this.getDOMNode()).parents("form");
    var file = form.find("input.file");
    file.on('change', function(e) {
      u.selectFile();
    })
    file.trigger("click");
  },
  selectFile: function(e) {
    console.log('select');
    var form = $(this.getDOMNode()).parents("form");
    var file = form.find("input.file");
    var f = file.val().split("\\");
    var filename = f[f.length - 1];
    console.log(filename);
    u.startUpload(filename, form);
  },
  render: function() {
    if(this.state.url)
      return <div>
          <input type='file' className='file' name='image[image_file]' />
        <button onClick={this.click} className="response-button upload-image"><span className="octicon octicon-device-camera"></span></button>
        <span className="info">{this.state.message}</span>
      </div>;
    else
      return null;
  }
})

$(function() {
  $(".channel-post .faves").each(function(i, fave) {
    var f = React.render(<FaveCounter />, fave);
    f.setState({faves: $(fave).data("faves"), state: parseInt($(fave).data("value")), postId: parseInt($(fave).parents(".channel-post").data("post-id"))});
  });

  $(".upload-image").each(function(i, image) {
    var f = React.render(<ImageUploader />, image);
    f.setState({url: $(image).data("uploader-url")});
  });
});
