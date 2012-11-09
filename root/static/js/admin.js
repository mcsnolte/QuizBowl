Ext.onReady(function(){
    Ext.QuickTips.init();
    //Ext.state.Manager.setProvider(new Ext.state.CookieProvider());
    var northPanel = new Ext.BoxComponent({
        region: 'north',
        height: 50,
        autoEl: {
            tag: 'div',
            style: 'padding: 5px',
            html: '<h1>GMLSAL Quiz Bowl 2011</h1><h3>Administration Screen</h3>'
        }
    });
	
	/*
	var userList = new Ext.list.ListView({
        id: 'user-list',
        store: new Ext.data.ArrayStore({
			id: 'user-list-store',
			data: [
				{
					name: 'Steve',
					score: 10,
					roll_call_ackd: 1
				}
			],
	        fields: [
				'name',
				'session_id',
				'connected',
				'roll_call_ackd',
				'is_admin',
				'answer',
				'score'
			],
	    }),
        singleSelect: true,
        emptyText: 'No players registered',
        reserveScrollOffset: true,
        columns: [{
            header: 'Team',
            width: 0.4,
            dataIndex: 'name'
        }, {
            header: 'Score',
            width: 0.2,
            dataIndex: 'score'
        }, {
            header: 'Status',
            width: 0.4,
			dataIndex: 'roll_call_ackd'
        }],
        tpl: new Ext.XTemplate('<tpl for="rows">', '<dl class="x-grid3-row {[xindex % 2 === 0 ? "" :  "x-grid3-row-alt"]}">', '<tpl for="parent.columns">', '<dt style="width:{[values.width*100]}%;text-align:{align};">', '<em unselectable="on"<tpl if="cls">  class="{cls}"</tpl>> {[values.tpl.apply(parent)]}</em>', '</dt>', '</tpl>', '<div class="x-clear"></div>', '</dl>', '</tpl>'),
    });
    */
	
    var centerPanel = new Ext.TabPanel({
        region: 'center',
        padding: '5',
        deferredRender: false,
        activeTab: 0,
        enableTabScroll: true,
        defaults: {
            closable: true
        },
        items: [{
            id: 'roll-call-tab',
            title: 'Roll Call (?)',
            closable: false,
            autoScroll: true,
            layout: 'border',
            items: [new Ext.Panel({
                region: 'center',
                border: false,
                autoScroll: true,
				//items: userList,
                html: '<div id="roll_call"></div>'
            }), new Ext.form.FormPanel({
                region: 'east',
                width: 200,
                align: 'right',
                border: false,
                labelWidth: 118,
                items: [{
                    xtype: 'fieldset',
                    title: 'Controls',
                    items: [{
                        xtype: 'button',
                        text: 'Request Roll Call',
                        width: 100,
                        handler: function(){
                            socket.emit('request roll call');
                        },
                    }]
                }]
            })]
        }]
    });
    var southPanel = new Ext.Panel({
        title: 'Slides',
        region: 'south',
        split: true,
        height: 100,
        minSize: 100,
        maxSize: 200,
        collapsible: true,
        margins: '0',
        items: [new Ext.DataView({
            store: new Ext.data.JsonStore({
                autoLoad: true,
                root: 'data',
                url: '/api/slide',
                fields: ['slide_id', 'name', 'url']
            }),
            tpl: new Ext.XTemplate('<tpl for=".">', '<div class="thumb-wrap" id="slide-{slide_id}">', '<div class="thumb"><img src="{url}" title="{name}"></div>', '</div>', '</tpl>'),
            singleSelect: true,
            overClass: 'x-view-over',
            itemSelector: 'div.thumb-wrap',
            emptyText: 'No slides to display'
        })]
    });
    var questionList = new Ext.list.ListView({
        id: 'question-list',
        store: new Ext.data.JsonStore({
            autoLoad: true,
            root: 'data',
            url: '/api/event/1/questions',
            fields: ['event_question_id', 'question_id', 'round_number', 'sequence', 'start_timestamp', 'close_timestamp', {
                name: 'question',
                mapping: 'question.question'
            }, {
                name: 'explanation',
                mapping: 'question.explanation'
            }, {
                name: 'answer',
                mapping: 'question.answer'
            }, {
                name: 'points',
                mapping: 'question.points'
            }, {
                name: 'level_id',
                mapping: 'question.level_id'
            }],
            listeners: {
                load: function(obj, records){
                    MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
                }
            }
        }),
        singleSelect: true,
        emptyText: 'No questions to display',
        reserveScrollOffset: true,
        columns: [{
            header: 'Seq',
            width: 0.1,
            dataIndex: 'sequence'
        }, {
            header: 'Rnd',
            width: 0.1,
            dataIndex: 'round_number'
        }, {
            header: 'Question',
            width: 0.7,
            dataIndex: 'question',
            tpl: '<p style="white-space:normal">{question}</p>'
        }, {
            header: 'Level',
            width: 0.1,
            dataIndex: 'level_id',
        }],
        tpl: new Ext.XTemplate('<tpl for="rows">', '<dl class="x-grid3-row {[xindex % 2 === 0 ? "" :  "x-grid3-row-alt"]}">', '<tpl for="parent.columns">', '<dt style="width:{[values.width*100]}%;text-align:{align};">', '<em unselectable="on"<tpl if="cls">  class="{cls}"</tpl>> {[values.tpl.apply(parent)]}</em>', '</dt>', '</tpl>', '<div class="x-clear"></div>', '</dl>', '</tpl>'),
        listeners: {
            render: function(view){
            },
            dblclick: function(view, idx, node, e){
                var rec = view.store.getAt(idx);
                var id = 'event-question-' + rec.get('event_question_id');
                if (centerPanel.findById(id)) {
                    centerPanel.setActiveTab(id);
                }
                else {
                    var p = centerPanel.add(buildPanel(rec, id));
                    centerPanel.setActiveTab(p);
                    centerPanel.doLayout();
                    MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
                }
            }
        }
    });
    var westPanel = new Ext.Panel({
        title: 'Questions',
        region: 'west',
        split: true,
        width: 400,
        minSize: 200,
        maxSize: 400,
        margins: '0',
        layout: 'fit',
        collapsible: true,
        items: questionList
    });
    var viewport = new Ext.Viewport({
        layout: 'border',
        items: [northPanel, southPanel, westPanel, centerPanel]
    });
    viewport.render('main');
    
    var updateCountdown = function(id, event_question_id, total, deadline){
        var now = new Date().getTime() / 1000;
        var countdown = Math.round(deadline - now);
        // First time or every 10 seconds
        if (countdown === total || countdown % 10 === 0) {
            socket.emit('close round', {
                event_question_id: event_question_id,
                seconds_to_close: countdown
            });
        }
        if (countdown >= 1) {
            Ext.fly(id).update('Closing in ' + countdown + ' ' + (countdown > 1 ? 'seconds' : 'second'));
        }
        else {
            socket.emit('close round', {
                event_question_id: event_question_id,
                seconds_to_close: 0
            });
            Ext.fly(id).update('Closed at ' + new Date().format('m/d/Y g:i:s A'));
            return false;
        }
    }
    var buildPanel = function(rec, id){
        var question = '<h1>Question:</h1><p>' + rec.get('question') + '</p>';
        var answer = '<h1>Answer:</h1><p>' + rec.get('answer') + '</p>';
        var properties = '<h1>Properties:</h1><p>'
			+ "Points: " + (rec.get('points') ? rec.get('points') : '0')
			+ "; Level: " + rec.get('level_id')
			 + '</p>';
        var event_question_id = rec.get('event_question_id');
        var col_id = Ext.id();
        var countdown = new Ext.ux.form.SpinnerField({
            minValue: 0,
            maxValue: 3600,
            allowDecimals: false,
            accelerate: true,
            width: 50,
            value: 30
        });
        var submissions_store = new Ext.data.JsonStore({
            autoLoad: true,
            root: 'data',
            idProperty: 'submission_id',
            restful: true,
            proxy: new Ext.data.HttpProxy({
                url: '/api/submission?event_question_id=' + event_question_id,
				api: {
                    update: '/api/submission'
                }
            }),
            writer: new Ext.data.JsonWriter({
                encode: false,
                //writeAllFields: true // write all fields, not just those that changed
            }),
            sortInfo: {
                field: "time_to_answer",
                direction: "ASC"
            },
            fields: ['submission_id', 'answer', {
                name: 'time_to_answer',
                type: 'float'
            }, 'is_correct', {
                name: 'first_name',
                mapping: 'create_user.first_name',
                type: 'string'
            }, {
                name: 'last_name',
                mapping: 'create_user.last_name',
                type: 'string'
            }, {
                name: 'points',
                type: 'int'
            }, {
                name: 'create_date',
                type: 'time'
            }]
        });
        var runner = new Ext.util.TaskRunner();
        var panel = new Ext.Panel({
            id: id,
            title: 'Question ' + rec.get('sequence'),
            layout: 'border',
            items: [new Ext.Panel({
                region: 'center',
                border: false,
                autoScroll: true,
                html: question + answer + properties
            }), new Ext.form.FormPanel({
                region: 'east',
                width: 300,
                align: 'right',
                border: false,
                labelWidth: 20,
                items: [{
                    xtype: 'fieldset',
                    title: '<div id="start_' + id + '">' +
                    (rec.get('start_timestamp') ? "Started at " + rec.get('start_timestamp') : "Not started yet") +
                    '</div>',
                    items: [new Ext.form.CompositeField({
                        items: [{
                            xtype: 'displayfield',
                            width: 10
                        }, {
                            xtype: 'button',
                            text: 'Start',
							tooltip: "Show the question and collect submissions.",
                            width: 60,
                            handler: function(){
                                Ext.fly('close_' + id).update('Not closed yet');
                                socket.emit('start round', rec.get('event_question_id'), function(data){
                                    Ext.fly('start_' + id).update('Started at ' + data.start_timestamp);
                                });
                            }
                        }, {
                            xtype: 'button',
                            text: 'Points',
                            width: 60,
							tooltip: "Auto assign points based on correct answers and the points multiplier.",
                            handler: function(){
								var eq_id = rec.get('event_question_id');
                                socket.emit('calc points', eq_id, function(data){
									refresh_submission_grid(eq_id);
								} );
                            }
                        }, {
                            xtype: 'button',
                            text: 'Results',
							tooltip: "Show the answer and points to everyone.",
                            width: 60,
                            handler: function(){
                                socket.emit('reveal results', rec.get('event_question_id') );
                            }
                        }]
                    })]
                }, {
                    xtype: 'fieldset',
                    title: '<div id="close_' + id + '">' +
                    (rec.get('close_timestamp') ? "Closed at " + rec.get('close_timestamp') : "Not closed yet") +
                    '</div>',
                    items: [new Ext.form.CompositeField({
                        items: [countdown, {
                            xtype: 'button',
                            text: 'Close',
							tooltip: "Close the round after the desired number of seconds.",
                            width: 80,
                            handler: function(){
                                var total = countdown.getValue();
                                var deadline = new Date().getTime() / 1000 + total;
                                var task = {
                                    run: updateCountdown,
                                    interval: 1000,
                                    args: ['close_' + id, event_question_id, total, deadline],
                                    duration: (countdown.getValue() + 1) * 1000
                                }
                                runner.stopAll();
                                runner.start(task);
                            }
                        }, {
                            xtype: 'button',
                            text: 'Cancel',
							tooltip: "Cancel the round from closing.",
                            width: 80,
                            handler: function(){
                                runner.stopAll();
                            }
                        }]
                    })]
                }]
            }), new Ext.grid.EditorGridPanel({
                id: 'submission-grid-' + event_question_id,
                region: 'south',
                height: 300,
                clicksToEdit: 1,
                store: submissions_store,
                autoExpandColumn: col_id,
                cm: new Ext.grid.ColumnModel({
                    defaults: {
                        sortable: true,
                        width: 80
                    },
                    columns: [{
                        id: col_id,
                        header: 'Name',
                        renderer: function(v, meta, rec){
                            return rec.get('first_name') + ' ' + rec.get('last_name');
                        }
                    }, {
                        header: 'Submitted on',
                        dataIndex: 'create_date',
                        width: 200
                    }, {
                        header: 'Seconds',
                        dataIndex: 'time_to_answer'
                    }, {
                        header: 'Answer',
                        dataIndex: 'answer',
                        width: 200,
                    }, {
                        xtype: 'checkcolumn',
                        header: 'Correct?',
                        dataIndex: 'is_correct',
                    }, {
                        header: 'Points',
                        dataIndex: 'points',
                        editor: new Ext.ux.form.SpinnerField({
                            minValue: 0,
                            maxValue: 100,
                            allowDecimals: false,
                            accelerate: true
                        })
                    }]
                }),
                bbar: new Ext.PagingToolbar({
                    pageSize: 25,
                    store: submissions_store,
                    displayInfo: true,
                    displayMsg: 'Displaying submissions {0} - {1} of {2}',
                    emptyMsg: "No submissions to display"
                })
            })]
        });
        return panel;
    }
});


function init_admin(session_id){

    // socket.io specific code
    socket = io.connect();
    
    socket.on('answer submitted', answer_submitted);
    
    socket.on('user list updated', user_list_updated);
    
    socket.emit('register', session_id, function(res){
        if (!res.success) {
            alert('Not connected successfully!');
        }
        else 
            if (res.round_started) {
                Ext.Msg.alert('In Progress Notification', 'Question #' + res.round_data.sequence + ' is already in progress.');
            }
    });
}

function answer_submitted(data){
	refresh_submission_grid(data.event_question_id);
}

function refresh_submission_grid(event_question_id) {
    var grid = Ext.ComponentMgr.get('submission-grid-' + event_question_id);
    if (grid == undefined) 
        return;
    grid.store.reload();
}

function user_list_updated(data){
    var not_ready = 0;
    var user_list = '<table><tr><th>Team</th><th>Score</th><th>Status</th></tr>';
    var users = data.users;
	var users_by_score = data.users_by_score;
	var user_data = [];
    for ( var i = 0; i < users_by_score.length; i++ ) {
		var user = users[users_by_score[i]];
        if (user.is_admin) {
            continue;
        }

		user_data.push(user);
        
        if (!user.roll_call_ackd) {
            not_ready++;
        }
        
        user_list += '<tr><td>' + user.name + '</td><td>' + user.score + '</td><td>';
        if (user.roll_call_ackd) {
            user_list += 'OK';
        }
        else {
            if (user.connected) {
                user_list += 'Waiting...';
            }
            else {
                user_list += 'Disconnected';
            }
        }
        user_list += '</td></tr>';
    }
    user_list += '</table>';
    Ext.ComponentMgr.get('roll-call-tab').setTitle('Roll Call (' + not_ready + ')');
    Ext.fly('roll_call').update(user_list);
	
	//var userStore = Ext.StoreMgr.get('user-list-store');
	//userStore.loadData(user_data);
}
