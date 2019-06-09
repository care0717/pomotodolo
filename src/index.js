require('./main.scss');

const { Elm } = require('./Main.elm');

const app = Elm.Main.init({
    node: document.getElementById('main')
});

document.addEventListener('DOMContentLoaded', function () {
    if (!Notification) {
        alert('Notification can not use.');
        return;
    }

    if (Notification.permission !== "granted") {
        Notification.requestPermission();
    }
});
function notifyUser() {
    if (Notification.permission !== "granted")
        Notification.requestPermission();
    else {
        const notification = new Notification('Time\'s up', {
            body: "timer end"
        });
        notification.onclose = () => {}
    }
    app.ports.notified.send(true)
}

app.ports.notifyUser.subscribe(_ => {
    notifyUser()
});