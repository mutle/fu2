var UserSettingsData = {
  url: "/api/users/current.json",
  view: "user-settings",
  subscribe: []
};

var UserSettingEdit = React.createClass({
  save: function(e) {
    e.preventDefault();
    var values = {};
    values[this.props.name.replace(/-/, '_')] = $(".setting-"+this.props.name+" input").val();
    var editCallback = this.props.editCallback;
    this.props.settings.saveSettings(values, function(user) {
      editCallback();
    });
  },
  render: function() {
    var className = "setting edit setting-"+this.props.name;
    if(this.props.editCallback) {
      var edit = <span>
        <a onClick={this.props.editCallback} className="editLink" href="#">Cancel</a>
        <button onClick={this.save} className="settings-button content-button">Save</button>
      </span>;
    }
    return <p className={className}>
      <label>{this.props.title}:</label>
      <input type={this.props.inputType} className="setting-value" defaultValue={this.props.defaultValue} />
      {edit}
    </p>;
  }
});

var UserSettingValue = React.createClass({
  render: function() {
    var className = "setting "+this.props.name;
    return <p className={className}>
      <label>{this.props.title}:</label>
      <span className="value">{this.props.defaultValue}</span>
      <a onClick={this.props.editCallback} className="editLink" href="#">Edit</a>
    </p>;
  }
});

var UserSetting = React.createClass({
  render: function() {
    if(this.props.edit) {
      return <UserSettingEdit name={this.props.name} title={this.props.title} defaultValue={this.props.defaultValue} inputType={this.props.inputType} editCallback={this.props.editCallback} settings={this.props.settings} />;
    } else {
      return <UserSettingValue name={this.props.name} title={this.props.title} defaultValue={this.props.defaultValue} editCallback={this.props.editCallback} />;
    }
  }
});

var UserSettings = React.createClass({
  getInitialState: function() {
    return {user: null, edit: null, error: null};
  },
  componentDidMount: function() {
    Data.subscribe("user-settings", this, 0, {callback: this.updatedUser});
    Data.fetch(UserSettingsData);
  },
  updatedUser: function(objects, view) {
    this.setState({user: objects[0]});
  },
  changePassword: function(e) {
    if(e) e.preventDefault();

    if(this.state.edit == "password") {
      var values = {
        old_password: $(".setting-old-password input").val(),
        password: $(".setting-password input").val(),
        password_confirmation: $(".setting-password-confirmation input").val()
      };
      var self = this;
      this.saveSettings(values, function(user) {
        self.setState({edit: null});
      });
    } else {
      this.setState({edit: "password"});
    }
  },
  editEmail: function(e) {
    if(e) e.preventDefault();
    this.setState({edit: this.state.edit == "email" ? null: "email"});
  },
  editDisplayName: function(e) {
    if(e) e.preventDefault();
    this.setState({edit: this.state.edit == "display-name" ? null: "display-name"});
  },
  editAvatarUrl: function(e) {
    if(e) e.preventDefault();
    this.setState({edit: this.state.edit == "avatar-url" ? null: "avatar-url"});
  },
  showError: function(data) {
    console.log(data.error);
    var error = [];
    for(var e in data.error) {
      error.push(e.replace(/_/, ' ')+" "+data.error[e]);
    }
    this.setState({error: error});
  },
  saveSettings: function(values, callback) {
    var self = this;
    Data.action("update", "user", {}, values, {
      error: function(data) {
        self.showError(data.responseJSON);
      },
      success: function(data) {
        Data.insert(data);
        Data.notify([data.type]);
        callback(data);
        self.setState({error: null});
      }
    });
  },
  render: function() {
    var settings = <LoadingIndicator />;
    if(this.state.error) {
      var error = [];
      for(var i in this.state.error) {
        error.push(<p>{this.state.error[i]}</p>);
      }
    }
    if(this.state.user) {
      var password = <button className="content-button settings-button password-button" onClick={this.changePassword}>Change Password</button>;
      if(this.state.edit == "password") {
        password = <div className="change-password">
          <UserSettingEdit name="old-password" title="Old Password" inputType="password" />
          <UserSettingEdit name="password" title="New Password" inputType="password" />
          <UserSettingEdit name="password-confirmation" title="Repeat Password" inputType="password" />
          <a href="#" onClick={this.changePassword}>Cancel</a>
          <button className="content-button settings-button" onClick={this.changePassword}>Save Password</button>
        </div>;
      }
      settings = <div>
        {error}
        {password}

        <UserSetting name="email" title="Email" defaultValue={this.state.user.email} editCallback={this.editEmail} edit={this.state.edit == "email"} settings={this} />
        <UserSetting name="display-name" title="Display name" defaultValue={this.state.user.display_name} editCallback={this.editDisplayName} edit={this.state.edit == "display-name"} settings={this} />
        <UserSetting name="avatar-url" title="Custom Avatar URL" defaultValue={this.state.user.avatar_url} editCallback={this.editAvatarUrl} edit={this.state.edit == "avatar-url"} settings={this} />
      </div>;
    }
    return <div className="user-settings">
      <h2>Settings</h2>

      {settings}
    </div>;
  }
});
