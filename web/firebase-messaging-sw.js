importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBXyJWg0hQhr88MeeqRPiiDHGG4KM23KwI",
  authDomain: "brawl-tcg-database.firebaseapp.com",
  projectId: "brawl-tcg-database",
  storageBucket: "brawl-tcg-database.firebasestorage.app",
  messagingSenderId: "922934256876",
  appId: "1:922934256876:web:11de0bd30a3544c21631c9",
});

const messaging = firebase.messaging();

// Muestra la notificación push cuando Chrome está en segundo plano o cerrado
messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification ?? {};
  if (!title) return;
  self.registration.showNotification(title, {
    body,
    icon: "/icons/Icon-192.png",
    badge: "/icons/Icon-192.png",
    data: payload.data ?? {},
  });
});
