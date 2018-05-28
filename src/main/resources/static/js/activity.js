var stompClient = null;
$(document).ready(function () {
    connect();
});

function setConnected(connected) {
    $("#connect").prop("disabled", connected);
    $("#disconnect").prop("disabled", !connected);
    if (connected) {
        $("#conversation").show();
    }
    else {
        $("#conversation").hide();
    }
    $("#greetings").html("");
}

function connect() {
    // создаем объект SockJs
    var socket = new SockJS('/activity');
    // создаем stomp-клиент поверх sockjs
    stompClient = Stomp.over(socket);
    // при подключении
    stompClient.connect({}, function (frame) {
        setConnected(true);
        console.log('Connected: ' + frame);
        var userId = $("#login").val();
        // подписываемся на url
        // stompClient.subscribe('/topic/chat'+userId, function (greeting) {
        stompClient.subscribe('/activity/'+userId, function (greeting) {
            console.log("User [" + login + "] subscribed for notifications.")
        });
    });
}

function disconnect() {
    if (stompClient !== null) {
        stompClient.disconnect();
    }
    setConnected(false);
    console.log("Disconnected");
}

// отправка
function sendName() {
    var login = $("#login").val();
    // отправляем на определенный url
    stompClient.send("/activity/"+4, {"login": 4}, "hey!");
    console.log(stompClient.message);
}

$(function () {
    $("form").on('submit', function (e) {
        e.preventDefault();
    });
    $( "#connect" ).click(function() { connect(); });
    $( "#disconnect" ).click(function() { disconnect(); });
    $( "#do-smth" ).click(function() { sendName(); });
});