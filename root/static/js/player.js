QuizBowl = {
    player: {
        session_id: undefined,
        name: undefined,
        socket: undefined,
    }
};

function init_player(session_id){

    QuizBowl.player.session_id = session_id;
    
    var socket = io.connect();
    QuizBowl.player.socket = socket;
    
    _init_socketio(socket);
    
    _init_socket_events(socket);
    
    socket.emit('register', session_id, function(res){
        if (res.success) {
            QuizBowl.player.name = res.name;
            $.growl('Welcome, ' + res.name + '!<br />You are connected.');
            // Resume a question that is in progress
            if (res.round_started) {
                round_started(res.round_data);
            }
        }
        else {
            socket.disconnect();
            $.growl('Registration failed, please login again.');
            setTimeout(function(){
                window.location.href = '/logout';
            }, 1500);
        }
    });
    
    _init_page(socket);
}

function _init_socketio(socket){
    socket.on('connect', function(){
        $('#chat').addClass('connected');
    });
    
    socket.on('disconnect', function(){
        $.growl('Disconnected! Hold on...');
    });
    
    socket.on('reconnect', function(){
        $.growl('Reconnected! Woohoo!');
        socket.emit('register', QuizBowl.player.session_id);
    });
    
    socket.on('reconnecting', function(){
        $.growl('Whoops, trying to reconnect...');
    });
    
    socket.on('error', function(e){
        $.growl('Uh oh!<br/>' + (e ? e : 'A unknown error occurred'));
    });
}

function _init_socket_events(socket){
	socket.on('roll call requested', function(){
		$('.panel').hide();
		$('#waiting_panel').show();
		$('#round_number').text('Roll Call');
		$('#question_level').text('Press Ready');
	});
	
    socket.on('user list updated', user_list_updated);
    
    socket.on('round started', round_started);
	
	socket.on('answer submitted', answer_submitted);
    
    socket.on('round closed', function(data){
        $('#answer input').blur(); // prevent hitting enter to submit
        init_results_panel('Waiting for results...');
    });
    
    socket.on('results revealed', results_revealed);
    
    socket.on('growl', function(msg){
        $.growl(msg);
    });
}

////////////////////////////////////////
// EVENTS

function user_list_updated(data){
    $('#roll_call tbody').empty();
    var users = data.users;
	var users_by_score = data.users_by_score;
    
	for ( var i = 0; i < users_by_score.length; i++ ) {
		var user = users[users_by_score[i]];
        if (user.is_admin) {
            continue;
        }
        // Roll call
        var status = $('<td>');
        if (user.roll_call_ackd) {
            status.text('OK').addClass('ready');
        }
        else 
            if (user.connected) {
                status.text('Waiting... ').addClass('waiting');
                if (user.session_id == QuizBowl.player.session_id) {
                    status.append($('<button>').attr('id', 'ack_roll_call').text('Ready'));
                }
            }
            else {
                status.text('Disconnected').addClass('disconnected');
            }
        var tr = $('<tr>').append($('<td>').text(user.name), $('<td>').text(user.score), status);
        $('#roll_call tbody').append(tr);
    }
}

function round_started(data){
    $('#round_number').text('Round #' + data.round_number);
	var grade = data.level_id == "team" ? "Team"
		: data.level_id == "practice" ? "Practice"
		: "Grade " + data.level_id;
    var level = grade + " Question";
    $('#question_level').text(level);
    
    $('#question_text').html(data.question);
    
    // Redraw equations
    MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
    
	$('#results_list').empty();
    $('.panel').hide();
    $('#question_panel').show();
	$('#results_list').empty().show();
    $('#answer input').val('').focus();
}

function answer_submitted(data){
    var user_id = data.user_id;
	// Delete any existing
	$('#results_list div#user_' + user_id).remove();
	// Add to list
    $('#results_list').append(
		$('<div>').attr('id', 'user_' + user_id).html(data.users[user_id].name).fadeIn()
	);
}

function results_revealed(data){
	$('#round_number').text('Round #' + data.round_number + ' Results');
    var grade = data.level_id == "team" ? "Team"
		: data.level_id == "practice" ? "Practice"
		: "Grade " + data.level_id;
    var level = grade + " Question";
    $('#question_level').text(level);
	$('#results_message').html('<strong>Answer</strong><br/>' + data.question.answer);

	$('#results_panel table').hide().find('tbody').empty();
	for (var i in data.results) {
        var tr = $('<tr>').append(
			$('<td>').text(data.results[i].team)
				.addClass(data.results[i].is_correct ? 'correct' : 'incorrect'),
			$('<td>').text(seconds_display(data.results[i].time_to_answer)),
			$('<td>').text(data.results[i].points)
		);
		$('#results_panel tbody').append(tr);
    }
	$('#results_panel table').fadeIn();
    
    $('.panel, #results_list').hide();
    $('#results_panel').show();
    
    // Redraw equations
    MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
}

function init_results_panel(msg) {
	$('#results_panel table').hide().find('tbody').empty();
	$('#results_panel #results_message').show().text(msg || 'Waiting...');
	$('.panel').hide();
    $('#results_panel').show();
}

function _init_page(socket){
    $('#question_panel').hide();
    
    $('#ack_roll_call').live('click', function(){
		$('#question_level').text('Thank you');
        socket.emit('ack roll call', 1);
    });
    
    $('#submit_button').live('click', submit_answer);
    $('#answer_form').live('submit', submit_answer);
}

function submit_answer(){
    QuizBowl.player.socket.emit('submit answer', $('#answer_text').val());
	init_results_panel('Waiting for submissions...');
    return false;
}

function seconds_display(total) {
	var minutes = Math.floor(total / 60);
	var seconds = Math.floor( total - minutes * 60 );
	if ( seconds < 10 ) {
		seconds = "0" + seconds;
	}
	var tenths = Math.floor( ( total - Math.floor(total) ) * 10, 0 );
	return minutes + ":" + seconds + "." + tenths;
}

// why not?
window.onerror = function(msg, url, linenumber){
    $.growl('Internal error: ' + msg + ' (player.js:' + linenumber + ')');
};
