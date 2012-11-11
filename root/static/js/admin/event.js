/*jshint laxcomma: true, smarttabs: true*/
/*globals Ext*/

Ext.onReady(function() {
	var eventForm,
		questionList,
		questionStore,
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
		sortInfo: { field: 'last_mod_date', direction: 'DESC' }
	});

	questionList = new Ext.Panel({
		title: 'Existing Questions',
		region: 'west',
		layout: 'fit',
		margins: '10px 0 10px 10px',
		width: 400,
		split: true,
		items: [
			new Ext.list.ListView({
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
					}
				}
			})
		],
		tbar: [{
			text: 'Add New'
		}, {
			text: 'Filter'
		}],
		bbar: new Ext.PagingToolbar({
			pageSize: 25,
			store: questionStore,
			displayInfo: true
		})
	});

	roundView = new Ext.DataView({});

	eventForm = new Ext.form.FormPanel({
		title: '&nbsp;',
		region: 'center',
		margins: '10',
		padding: '10',
		buttonAlign: 'left',
		monitorValid: true,
		items: [{
			xtype: 'fieldset',
			title: 'Properties',
			items: [{
				xtype: 'textfield',
				fieldLabel: 'Name',
				width: 300
			}, {
				xtype: 'datefield',
				fieldLabel: 'Start'
			}, {
				xtype: 'datefield',
				fieldLabel: 'End'
			}]
		}, {
			xtype: 'fieldset',
			title: 'Questions',
			height: 300,
			items: [{
				xtype: 'container',
				layout: 'hbox',
				layoutConfig: {
					align:'stretch'
				},
				defaults: {
					flex: 1
				},
				items: [questionList, roundView]
			}]
		}],
		buttons: {
			items: [{
				text: 'Save',
				formBind: true
			}, {
				text: 'Cancel'
			}]
		}
	});

	viewport = new Ext.Viewport({
		layout: 'fit',
		renderTo: 'main',
		items: [eventForm]
	});
});