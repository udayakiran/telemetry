var jugClient;
var clientUid;
var minCritical = 0;
var maxCritical = 10;
var genFunction = "increment";
var genFunctionStep = 1;
var hbSender;
var payload = 0;
var channelPrefix = "tele_";

TELE_CLIENT = function () {

    var connect = function () {
        clientUid = jugClient.sessionID;
        startListeningToServer();
        startHeartbeatStream();
        $("#showHB").attr("href", "/heartbeat?client_uid=" + clientUid);
    };

    var startListeningToServer = function () {
        jugClient.subscribe({channel: channelPrefix + jugClient.sessionID,
            onMessageReceived: function (data) {
                if (data.generation_function !== undefined) {
                    logInfo("Received generation_function from server: " + data.generation_function);
                    setGenerationFunction(data.generation_function);
                    stopHeartbeatStream();
                    //resetMinMax();
                    startHeartbeatStream();
                } else if (data.critical_limits !== undefined) {
                    minCritical = parseInt(data.critical_limits[0]);
                    maxCritical = parseInt(data.critical_limits[1]);
                    logInfo("Received critical values from server: " + minCritical + ", " + maxCritical);
                    stopHeartbeatStream();
                    resetMinMax();
                    startHeartbeatStream();
                }
            }
        });

        $("#client_message").html("Connected - Id: " + clientUid);
        $("#disconnect").show();
    };

    var disconnect = function () {
        stopHeartbeatStream();
        jugClient.unsubscribe(channelPrefix + jugClient.sessionID);
        $("#client_message").html("Disconnected - Id: " + clientUid);
        logInfo("Client disconnected.");
    };

    var resume = function () {
        startHeartbeatStream();
        logInfo("Client resumes...");
    };

    var setGenerationFunction = function (gen_func) {
        console.log("setGenerationFunction");
        var gen_func_split = gen_func.split(" by ");
        genFunction = gen_func_split[0];
        genFunctionStep = parseInt(gen_func_split[1]);
    };

    var startHeartbeatStream = function () {
        hbSender = setInterval(function () {
            sendHeartbeat();

            if (payload > maxCritical || payload < minCritical) {
                stopHeartbeatStream();
            }
        }, 1000);
    };

    var resetMinMax = function () {
        if (payload <= minCritical) {
            payload = minCritical;
            logInfo("Adjusting the payload to stay within critical limit: minCritical - " + payload);

        } else if (payload >= maxCritical) {
            payload = maxCritical;
            logInfo("Adjusting the payload to stay within critical limit: maxCritical - " + payload);
        }
    };

    var stopHeartbeatStream = function () {
        clearInterval(hbSender);
    };

    var sendHeartbeat = function () {
        console.log("sendHeartBeat");
        calculatePayload();

        logInfo("sending heartbeat: " + payload);
        // debugger;
        $.ajax({
            type: "POST",
            url: "/heartbeat",
            data: {payload: payload, client_uid: clientUid},
            success: null
        });
    };

    var calculatePayload = function () {
        if (genFunction === "increment") {
            payload += genFunctionStep;
        } else {
            payload -= genFunctionStep;
        }
    };

    var getHeartbeat = function () {
        console.log("getHeartBeat");
    };

    var pause = function () {
        stopHeartbeatStream();
        logInfo("Client Paused.");
    };

    var setCriticalLimits = function () {
        console.log("setCriticalLimits");
    };

    var getClient = function () {
        return this.jugClient;
    };

    var showHB = function () {

    };

    var showLog = function () {
        $("#client_log").toggle();
    };

    var showGenFunc = function () {
        $("#gen_func").html(genFunction + " by " + genFunctionStep);
        $("#gen_func").show();
    };


    var logInfo = function (text) {
        $("#client_log").append("</br>" + text);
    };

    return {
        connect: connect,
        disconnect: disconnect,
        sendHeartbeat: sendHeartbeat,
        setGenerationFunction: setGenerationFunction,
        setCriticalLimits: setCriticalLimits,
        getHeartbeat: getHeartbeat,
        startHeartbeatStream: startHeartbeatStream,
        stopHeartbeatStream: stopHeartbeatStream,
        pause: pause,
        resume: resume,
        client: getClient,
        showGenFunc: showGenFunc,
        showLog: showLog,
        showHB: showHB
    };
}();

// Events
jQuery(document).ready(function () {
    jugClient = new Juggernaut;
});