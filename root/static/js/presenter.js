QuizBowl = {
    session_id: undefined,
    event_id: undefined,
    name: undefined,
    socket: undefined
};

function user_list_updated(data){
    $('#scores tbody').empty();
	var users = data.users;
	var users_by_score = data.users_by_score;
	console.log(users);
	console.log(users_by_score);
    
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
            }
            else {
                status.text('Disconnected').addClass('disconnected');
            }
        var tr = $('<tr>').append(
			$('<td>').append(
				$('<img>').attr('src', user.gravatar_url)
			),
			$('<td>').text(user.name),
			$('<td>').text(user.score),
			status
		);
        $('#scores tbody').append(tr);
    }
}

function round_started(data){
    $('.screen').hide();
	var snd = new Audio("/static/audio/news-ting.mp3");

    $('.round_title').text(data.round_number);
	var level = data.level_id == "team" ? "Team"
		: data.level_id == "practice" ? "Practice"
		: "Level " + data.level_id;
    level += " Question";
    $('.question_level').text(level);
    $('#question_text').html(data.question);

	$('#results_list').empty();

    $('#game_board').fadeIn();
	snd.play();

    // Redraw equations
    MathJax.Hub.Queue(["Typeset", MathJax.Hub]);

	// Redraw code
	$('pre code').each(function(i, e) {hljs.highlightBlock(e)});
}

function answer_submitted(data){
    var user_id = data.user_id;

	var snd = new Audio("/static/audio/dee-doo.mp3");
	snd.play();

	// Delete any existing
	$('#results_list div#user_' + user_id).remove();
	// Add to list
    $('#results_list').append(
		$('<div>').attr('id', 'user_' + user_id).html(
		'<img src="'+data.users[user_id].gravatar_url+'"/> '+data.users[user_id].name).fadeIn()
	);
}

function results_revealed(data){
	$('.screen').hide();

	$('.round_title').text(data.round_number);
    var level = data.level_id == "team" ? "Team"
		: data.level_id == "practice" ? "Practice"
		: "Level " + data.level_id;
    level += " Question";
    $('.question_level').text(level);
	//$('#results_question').html(data.question.question);
	$('#results_answer').html(data.question.answer);

	$('#results_panel table#points tbody').empty();
	for (var i in data.results) {
        var tr = $('<tr>').append(
			$('<td>').append(
				$('<img>').attr('src', data.results[i].gravatar_url)
			),
			$('<td>').text(data.results[i].name)
				.addClass(data.results[i].is_correct ? 'correct' : 'incorrect'),
			$('<td>').addClass('time').text(seconds_display(data.results[i].time_to_answer)),
			$('<td>').text(data.results[i].points)
		);
		$('#results_panel table#points tbody').append(tr);
    }

	$('#results_panel').fadeIn();

    // Redraw equations
    MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
}

//////////////////////////////////////
// SETUP

function init_presenter(args) {

    var socket = io.connect();
    _init_socketio(socket, args);
    
    socket.emit('register', 'presenter', args.event_id, function(res){
        if (res.success) {
            $.growl('Presenter connected');
        }
        else {
            socket.disconnect();
            $.growl('Could not register presenter :(<br/>Reloading...');
            setTimeout(function(){
                window.location.reload();
            }, 3000);
        }
    });

    _init_socket_events(socket);
    _init_page(socket);
};

function _init_page(){
    $('.screen').hide();
    $('#score_board').show();
}

function _init_socketio(socket, args){
    socket.on('connect', function(){
        $('#chat').addClass('connected');
    });

    socket.on('disconnect', function(){
        $.growl('Disconnected! Hold on...');
    });

    socket.on('reconnect', function(){
        $.growl('Reconnected! Woohoo!');
        socket.emit('register', 'presenter', QuizBowl.event_id );
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
		$('.screen').hide();
		$('#score_board').fadeIn();
	});
    socket.on('round started', round_started);
    socket.on('user list updated', user_list_updated);
    socket.on('answer submitted', answer_submitted);
	socket.on('results revealed', results_revealed);
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

