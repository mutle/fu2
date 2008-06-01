var toolbar = null;
var lite_toolbar = null;

function add_editor(id) {
  toolbar = new Control.TextArea.ToolBar.Blogage(id);
}

Control.TextArea.ToolBar.Blogage = Class.create();
Object.extend(Control.TextArea.ToolBar.Blogage.prototype,{
	textarea: false,
	toolbar: false,
	options: {},
  // insertMedia: '',
	selection_begin: 0,
	selection_end: 0,
  insertMedia: function(code){
    this.textarea.restoreSelection();
    this.textarea.insertAfterSelection(code);
  },
	initialize: function(textarea,options){
		this.textarea = new Control.TextArea(textarea);
		this.toolbar = new Control.TextArea.ToolBar(this.textarea);
		this.toolbar.container.addClassName("editor");
		this.converter = (typeof(Showdown) != 'undefined') ? new Showdown.converter : false;
		this.options = {
			preview: false,
			afterPreview: Prototype.emptyFunction
		};
		Object.extend(this.options,options || {});
		if(this.options.preview){
			this.textarea.observe('change',function(textarea){
				if(this.converter){
					$(this.options.preview).update(this.converter.makeHtml(textarea.getValue()));
					this.options.afterPreview();
				}
			}.bind(this));
		}

		//buttons    
    this.toolbar.addButton('Fett',function(){
     this.wrapSelection('<strong>','</strong>');
    },{
     id: 'bold_button'
    });
		
    this.toolbar.addButton('Kursiv',function(){
     this.wrapSelection('<em>','</em>');
    },{
     id: 'italics_button'
    });
    
    this.toolbar.addButton('Unterstrichen',function(){
     this.wrapSelection('<span class="underline">','</span>');
    },{
     id: 'underline_button'
    });
    
    this.toolbar.addButton('Durchgestrichen',function(){
     this.wrapSelection('<span class="strike_through">','</span>');
    },{
     id: 'strikethrough_button'
    });
    
    this.toolbar.addButton('Überschrift 1',function(){
      this.wrapSelection('<h1>', '</h1>');
    },{
     id: 'heading_1_button'
    });
    
    this.toolbar.addButton('Überschrift 2',function(){
      this.wrapSelection('<h2>', '</h2>');
    },{
     id: 'heading_2_button'
    });
    
    this.toolbar.addButton('Überschrift 3',function(){
      this.wrapSelection('<h3>', '</h3>');
    },{
     id: 'heading_3_button'
    });
    
    this.toolbar.addDivider();
    
    this.toolbar.addButton('Link',function(){
     var selection = this.getSelection();
     var response = prompt('Link-URL eingeben:','');
     if(response == null)
       return;
     this.wrapSelection('<a href="'+(response == '' ? 'http://link_url/' : response).replace(/^(?!(f|ht)tps?:\/\/)/,'http://')+'">', '</a>');
     // this.replaceSelection('[' + (selection == '' ? 'Link Text' : selection) + '](' + (response == '' ? 'http://link_url/' : response).replace(/^(?!(f|ht)tps?:\/\/)/,'http://') + ')');
    },{
     id: 'link_button'
    });
    
   this.toolbar.addButton('Zitat',function(event){
     this.wrapSelection('<blockquote>\n', '\n</blockquote>');
    },{
     id: 'blockquote_button'
    });    
    
    this.toolbar.addDivider();
    
    this.toolbar.addButton('Formatierung löschen',function(){
      this.replaceSelection(this.getSelection().replace(/<[^>]*>/g, ''));
    },{
     id: 'unformat_button'
    });
	}
});