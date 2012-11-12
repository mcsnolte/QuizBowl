/*jshint laxcomma: true, smarttabs: true*/
/*globals Ext*/

Ext.onReady(function() {
	var questionForm,
		questionList,
		questionStore,
		saveFn,
		viewport;

	Ext.QuickTips.init();

	questionStore = new Ext.data.JsonStore({
		autoLoad: true,
		root: 'data',
		idProperty: 'question_id',
		totalProperty: 'total',
		url: '/api/question',
		fields: [
			'answer_value',
			{
				name: 'last_mod_date'
			},
			'options',
			'answer',
			'points',
			{
				name: 'create_date'
			},
			'question',
			'explanation',
			'question_type_value',
			'question_id',
			'level_id',
			'create_user_id',
			'last_mod_user_id'
		],
		restful: true,
		baseParams: { start: 0, limit: 25 },
		remoteSort: true,
		sortInfo: { field: 'last_mod_date', direction: 'DESC' },
		listeners: {
			load: function(obj, records){
				MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
			}
		}
	});

	questionList = new Ext.Panel({
		title: 'Questions',
		region: 'west',
		layout: 'fit',
		margins: '10px 0 10px 10px',
		width: 400,
		split: true,
		items: [
			new Ext.list.ListView({
				ref: 'list',
				store: questionStore,
				singleSelect: true,
				emptyText: 'No questions to display',
				reserveScrollOffset: true,
				columns: [{
					header: 'ID',
					dataIndex: 'question_id'
				}, {
					header: 'Question',
					dataIndex: 'question',
					tpl: '<p style="white-space:normal">{question}</p>',
					width: 0.7
				}, {
					header: 'Last Modified',
					dataIndex: 'last_mod_date',
					width: 0.2
				}],
				tpl: new Ext.XTemplate(
					'<tpl for="rows">',
						'<dl class="x-grid3-row {[xindex % 2 === 0 ? "" :  "x-grid3-row-alt"]}">',
							'<tpl for="parent.columns">',
								'<dt style="width:{[values.width*100]}%;text-align:{align};">',
									'<em unselectable="on"<tpl if="cls">  class="{cls}"</tpl>> {[values.tpl.apply(parent)]}</em>',
								'</dt>',
							'</tpl>',
							'<div class="x-clear"></div>',
						'</dl>',
					'</tpl>'
				),
				listeners: {
					click: function(view, idx, node, e) {
						var rec = view.store.getAt(idx);
						questionForm.setTitle('Editing Question #' + rec.get('question_id'));
						questionForm.form.reset().setValues(rec.data);
					}
				}
			})
		],
		tbar: [{
			text: 'Add New Question',
			handler: function() {
				questionList.list.clearSelections();
				questionForm.setTitle('Adding New Question');
				questionForm.form.reset();
			}
		}, '-', {
			text: 'Filter'
		}],
		bbar: new Ext.PagingToolbar({
			pageSize: 25,
			store: questionStore,
			displayInfo: true
		})
	});

	questionForm = new Ext.form.FormPanel({
		title: '&nbsp;',
		region: 'center',
		margins: '10px 10px 10px 0',
		padding: '10',
		buttonAlign: 'left',
		monitorValid: true,
		defaults: {
			xtype: 'textarea',
			anchor: '100%',
			allowBlank: false
		},
		items: [{
			xtype: 'textfield',
			fieldLabel: 'Level',
			name: 'level_id',
			anchor: '25%'
		}, {
			xtype: 'spinnerfield',
			fieldLabel: 'Points',
			name: 'points',
			minValue: 0,
			maxValue: 100,
			allowDecimals: false,
			accelerate: true,
			anchor: '25%'
		}, {
			fieldLabel: 'Question',
			name: 'question',
			allowBlank: false
		}, {
			fieldLabel: 'Answer',
			name: 'answer'
		}, {
			xtype: 'textfield',
			fieldLabel: 'Answer Value',
			name: 'answer_value',
			allowBlank: true
		}, {
			fieldLabel: 'Explanation',
			name: 'explanation',
			allowBlank: true
		}],
		buttons: {
			items: [{
				text: 'Save',
				formBind: true,
				handler: function() {
					var recs = questionList.list.getSelectedRecords();
					if (recs.length) {
						saveFn('PUT', recs[0].get('question_id'));
					} else {
						saveFn('POST', '');
					}
				}
			}, {
				text: 'Reset',
				handler: function() {
					questionForm.form.reset();
				}
			}]
		}
	});

	viewport = new Ext.Viewport({
		layout: 'border',
		renderTo: 'main',
		items: [questionList, questionForm]
	});

	saveFn = function(method, id) {
		var data = questionForm.form.getValues();
		Ext.Ajax.request({
			url: '/api/question/' + id,
			method: method,
			headers : {
				'Accept': 'application/json',
				'Content-Type': 'application/json'
			},
			jsonData: data,
			success: function() {
				Ext.Msg.alert('Success', 'Question saved successfully!');
				questionForm.form.reset();
				questionList.list.store.reload();
			}
		});
	};
});
