var app = {
    views: {},
    models: {},
    routers: {},
    utils: {},
    adapters: {},
    dao: {},
    // Application Constructor
    initialize: function () {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function () {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicity call 'app.receivedEvent(...);'
    onDeviceReady: function () {
        app.appRootDirName = 'xiangnimei';
        app.receivedEvent('deviceready');
        // Overwrite the default behavior of the device back button
        document.addEventListener('backbutton', app.onBackPress, false);
    },
    onBackPress: function (e) {
        if (window.location.hash === '#home' || window.location.hash === '') {
            e.preventDefault();
            navigator.app.exitApp();
        }
        else {
            navigator.app.backHistory();
        }
    },
    // Update DOM on a Received Event
    receivedEvent: function (id) {
        console.log('Received Event: ' + id);
        window.requestFileSystem = window.requestFileSystem || window.webkitRequestFileSystem;
        window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, app.gotFS, app.failFS);
    },
    gotFS: function (fileSystem) {
        console.log("got filesystem");

        fileSystem.root.getDirectory(app.appRootDirName, {
            create: true,
            exclusive: false
        }, app.dirReady, app.failFS);
    },
    dirReady: function (entry) {
        app.appRootDir = entry;
        console.log(JSON.stringify(app.appRootDir));
    },
    failFS: function () {
        console.log("failed to get filesystem");
    }
};

app.baseUrl = 'http://10.0.0.4:3000/';

Zepto(function($){
    Deferred.installInto(Zepto);
    app.db = window.openDatabase("MissYouDB", "1.0", "Miss You DB", 200000);
    baseDAO = new app.dao.BaseDAO(app.db);
    baseDAO.initialize(function () {
        app.utils.templates.load(["HomeView", "SettingsView", "SignInView", "CollectionView", "CollectionListItemView",
            "TopicListItemView", "TopicView", "SaveView", "UserView", "UserChangeNickNameView", "UserChangePasswordView",
            "CardsView", "CardListItemView", "CardView"],
            function () {
                app.router = new app.routers.AppRouter();
                Backbone.history.start();
            });
    });
});
