// Please see this file for the latest firebase-js-sdk version:
// https://github.com/firebase/flutterfire/blob/master/packages/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyCgw9G-FzV1rfirxmL7ozr7q-UQRCGPOks",
    authDomain: "catch-cat.firebaseapp.com",
    projectId: "catch-cat",
    storageBucket: "catch-cat.appspot.com",
    messagingSenderId: "48239046101",
    appId: "1:48239046101:web:b761bade0f83575927e15c",
    measurementId: "G-W5QFQ64NJ5"
  });

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});