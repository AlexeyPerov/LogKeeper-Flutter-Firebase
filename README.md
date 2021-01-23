# LogKeep

This is a tool (iOS/Android/Web) written in Dart lang for logs share.

We use it in production to help QA and other people to attach and retrieve logs easier.
Hope it will help someone too.

It is also an example of:
* Flutter Bloc pattern usage
* Firebase & Firestore usage
* simple Dart backend (with shelf and Firebase)
* shared Dart code project usage (and how to use Docker with it)

So this repository contains 3 projects:
- log_keep
- log_keep_back
- log_keep_shared

Backend part log_keep_back provides an API to upload logs and to retrieve links to share them.  
Client part log_keep is used to view logs.

Storage is based on Firestore (but anything else can be used too).

Folders structure is based on https://hub.docker.com/r/google/dart-runtime-base
in order to use shared code in log_keep_shared both on client and server sides.

## How to use

### Firebase Account

* Create one at https://firebase.google.com/
* Add apps that you need (iOS/Android/Web)

### Setup it up in your project

in log_keep:
* add google-services.json for Android
* add GoogleService-Info.plist for iOS
* add firebaseConfig.js near index.html which should contain code like this:

```javascript
var firebaseConfig = {
    apiKey: "..",
    authDomain: "..",
    projectId: "..",
    storageBucket: ".",
    messagingSenderId: "..",
    appId: "..",
    measurementId: ".."
};

firebase.initializeApp(firebaseConfig);
```

### Google Service Account

For a backend to run you will need a Google Service Account https://cloud.google.com/iam/docs/service-accounts. 

Service account credentials could be passed to log_keep_back via .env file:
* private_key_id
* client_email
* client_id
* private_key
* databaseParentPath="projects/[PROJECT_ID]/databases/(default)/documents"
* serverLogUrlFormat="https://[PROJECT_ID].web.app/#/details?id={0}"	

Instructions on how to build & deploy server can also be found here https://hub.docker.com/r/google/dart-runtime-base

## To build and host client use
cd log_keep
flutter build web  
firebase deploy --only hosting

## Screenshots
* https://monosnap.com/file/lsKyrrDvDedPPyPkIufYu9sxZZrq3M
* https://monosnap.com/file/a78x0Rjkt0OHkp9G63E3G3o4azg6ys