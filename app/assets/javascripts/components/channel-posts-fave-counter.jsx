var FaveCounter = React.createClass({
  getInitialState: function() {
    return {state: 0, add: false};
  },
  click: function(e) {
    e.preventDefault();
    if(this.props.postId > 0) {
      var c = this;
      var t = $(e.target);
      if(t.hasClass("fave-emoji") || t.get(0).className == "") t = t.parents("button");
      var emoji = t.attr("class").replace(/^emoji-/, '').split(" ")[0];
      $.ajax({url:"/api/posts/"+this.props.postId+"/fave?emoji="+encodeURIComponent(emoji), dataType: "json", type: "post"}).done(function(data) {
        Data.update(data.post.type, c.props.postId, data.post);
      });
    }
  },
  addNew: function(e) {
    e.preventDefault();
    this.setState({add:true, input: "", selection: 0});
  },
  fave: function(emoji) {
    if(this.props.postId > 0) {
      var c = this;
      $.ajax({url:"/api/posts/"+this.props.postId+"/fave?emoji="+encodeURIComponent(emoji), dataType: "json", type: "post"}).done(function(data) {
        Data.update(data.post.type, c.props.postId, data.post);
      });
    }
  },
  autocompleteClick: function(e) {
    e.preventDefault();
    var emoji = $(e.target).parents(".result").data("value");
    this.fave(emoji);
    this.setState({add:false});
  },
  autocompleteMount: function(auto) {
    $(this.getDOMNode()).find("input").get(0).select();
  },
  input: function(e) {
    var cursorE = $(this.getDOMNode()).find("input").get(0).selectionEnd;
    var cursorS = $(this.getDOMNode()).find("input").get(0).selectionStart;
    var key = e.key;
    if(key == "Escape") {
      this.setState({add: false});
      return;
    }
    if(key == "Enter") {
      e.preventDefault();
      if(this.filteredEmojis) {
        var emoji = this.filteredEmojis[this.state.selection];
        if(emoji) {
          var valid = false;
          for(var i in window.Emojis) {
            if(window.Emojis[i] == emoji) {
              valid = true;
              break;
            }
          }
        }
        if(valid) {
          this.fave(emoji);
          this.setState({add: false});
        }
        return;
      }
    }
    if(key == "ArrowDown") {
      e.preventDefault();
      if(this.state.selection < 10)
        this.setState({selection: this.state.selection + 1});
    }
    if(key == "ArrowUp") {
      e.preventDefault();
      if(this.state.selection > 0)
        this.setState({selection: this.state.selection - 1});
    }
    if(key == "Backspace") {
      cursorE -= 2;
      key = "";
    }
    if(key.length <= 1) {
      var input = e.target.value.slice(0, cursorE+1) + key;
      this.setState({input: input});
    }
  },
  render: function() {
    var icon = <span className="octicon octicon-star" />;
    var inner = null;
    var emojis = {star: []};
    var emojinames = ["star"]
    for(var i in this.props.faves) {
      var f = this.props.faves[i];
      if(emojinames.indexOf(f[1]) < 0) emojinames.push(f[1]);
      if(!emojis[f[1]]) emojis[f[1]] = [];
      emojis[f[1]].push(f[0]);
    }
    var user = this.props.user;
    var self = this;
    var buttons = emojinames.map(function(emoji, i) {
      var className = "emoji-"+emoji;
      if(user && emojis[emoji].indexOf(user) >= 0) className += " on"
      return <button key={emoji} className={className} onClick={self.click}>
        <img className="fave-emoji" src={"/images/emoji/"+emoji+".png"} title={emoji+": "+emojis[emoji].join(", ")} />
        {emojis[emoji].length}
      </button>;
    });
    if(this.state.add) {
      var imageUrl = function(s) { return "/images/emoji/"+s+".png"; };
      var filteredEmojis = [];
      var input = this.state.input;
      var n = 0;
      window.Emojis.map(function(r, i) {
        if(n < 10 && (input.length < 1 || r.indexOf(input) == 0)) {
          n++;
          filteredEmojis.push(r);
        }
      });
      this.filteredEmojis = filteredEmojis;
      var newText = <div className="add-emoji">
        <AutoCompleter objects={filteredEmojis} imageUrl={imageUrl} selection={this.state.selection} clickCallback={this.autocompleteClick} mountCallback={this.autocompleteMount} />
        <input onKeyDown={this.input} onKeyPress={this.input} />
      </div>;
    }
    var addNew = <button className="add-emoji-button" onClick={this.addNew}><img className="fave-emoji" src="/images/emoji/heavy_plus_sign.png" /></button>;
    // if(!this.props.faves || this.props.faves.length == 0) inner = <span>{icon}{'0'}</span>;
    // else inner = <span>{icon}{this.props.faves.length}</span>;
    // var className = "";
    // if(this.props.faves.length > 0) className = "faved";
    // if(this.state.state == 1) className = "on";
    return <div className="faves">
      {newText}
      {addNew}
      {buttons}
    </div>;
    // return <a href="#" title={(this.props.faves ? this.props.faves : []).join(", ")} onClick={this.click} className={className}>{inner}</a>;
  }
});

// module.exports = FaveCounter;
window.FaveCounter = FaveCounter;
