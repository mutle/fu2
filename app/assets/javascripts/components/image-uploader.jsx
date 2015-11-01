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
          if(u.props.callback) {
            u.props.callback(JSON.parse(xhr.responseText).url);
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
});

// module.exports = ImageUploader;
window.ImageUploader = ImageUploader;
