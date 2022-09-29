importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: 'AIzaSyD2AWdZaGet1YvVgck5gZ3mww9-6NDozek',
  appId: '1:714311873087:web:7ff97d63debd5b364dbe8a',
  messagingSenderId: '714311873087',
  projectId: 'nonsuckingshoppinglist',
  authDomain: 'nonsuckingshoppinglist.firebaseapp.com',
  databaseURL: 'https://nonsuckingshoppinglist.firebaseio.com',
  storageBucket: 'nonsuckingshoppinglist.appspot.com',
  measurementId: 'G-55C6JSXQK6',
});

// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});
