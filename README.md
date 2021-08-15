# LogKeeper (Flutter Firebase)

This is a Flutter log snapshot management solution used to save and share log snapshots within the development team.
Supports iOS/Android/Web and utilizes Dart backend API (with client-server shared code). 
Logs stored in Firestore and Firebase Auth used to access some parts of the data.

## Usage

* QA engineer or someone from the team finds an error in the app
* Whether it is an error popup or just a suspicious behaviour there should always be a button to upload logs to the LogKeeper
* This button reads log file and makes POST request which saves the log on the server, analyzes it and returns a link to it
* Now a person has the link to the uploaded log which they can share to the Bug report or just post it to the chat.\
The link looks something like: [https://[your_hosting_url]/#/details?id=[log_id]]()  \
Link redirects to this log like this:\

| Log Contents  | Log Contents in Web view |
| ------------- | ------------- |
| ![image](screenshots/screenshot_log.png) | ![image](screenshots/screenshot_log.png)  |

All logs later can be found on the home screen which is accessible only for authorized users:\

| Auth Screen  | Home Screen |
| ------------- | ------------- |
| ![image](screenshots/screenshot_main.png) | ![image](screenshots/screenshot_main.png)  |
| Settings Screen  | Upload Log screen  |
| ![image](screenshots/screenshot_main.png) | ![image](screenshots/screenshot_main.png)  |
 
## Description

This tool uses:
* [Flutter Bloc](https://pub.dev/packages/flutter_bloc)
* [Firebase Firestore](https://firebase.google.com/docs/firestore) & [Firestore cache](https://pub.dev/packages/firestore_cache)
* [Firebase Auth](https://firebase.google.com/docs/auth)
* Dart backend (with [shelf](https://pub.dev/packages/shelf) and Firebase)
* shared Dart code project usage with [Docker](https://www.docker.com/)
* [Firebase Flutter app hosting](https://firebase.google.com/docs/hosting)
* Conditional rendering with [proviso](https://pub.dev/packages/proviso)
* Embed [Web browser](https://pub.dev/packages/web_browser)
* Themes and their dynamic switching, drawer, [fading edge scroll view](https://pub.dev/packages/fading_edge_scrollview),
 ModelBinding, [Hive](https://pub.dev/packages/hive), streams, service locator [getIt](https://pub.dev/packages/get_it) etc

Consists of the following parts:
- log_keep_back (an API to upload logs and to retrieve links to share them)
- log_keep (client part to view logs or upload them manually)
- log_keep_shared (code shared between other two projects)
- code to send logs to an API from your apps (an example for Unity C# is given below)

Folders structure is based on https://hub.docker.com/r/google/dart-runtime-base
in order to use shared code in log_keep_shared both on the client and server sides.

## How to set it up

### Firebase Account

* Create one at https://firebase.google.com/
* Add apps that you need (iOS/Android/Web)
* Enable Firestore and create empty collections ("projects" and "logs")

### Attach Firebase to your local copy

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

For a backend to run you need a Google Service Account https://cloud.google.com/iam/docs/service-accounts. 

Service account credentials could be passed to log_keep_back via .env file:
* private_key_id
* client_email
* client_id
* private_key
* databaseParentPath="projects/[PROJECT_ID]/databases/(default)/documents"
* serverLogUrlFormat="https://[PROJECT_ID].web.app/#/details?id={0}"	

Instructions on how to build & deploy server can also be found here https://hub.docker.com/r/google/dart-runtime-base

## To build and host Web client use
* cd log_keep
* flutter build web 
* init and login using Firebase CLI 
* firebase deploy --only hosting

## Notes

### TODO
* Mock data repository
* Null safety
* Get rid of project specific parsing code in some base classes

#### Known issues and limitations
* The [Web browser](https://pub.dev/packages/web_browser) forces all widgets above it to ignore all clicks on them.
As a temporary solution in such cases, the browser becomes hidden.
* Firestore limits its entities to 2mb so this is the limitation for log files uploaded. 
The plan is to use Firebase Storage to keep logs there.
* Generally Flutter Web performance in case of rendering text has problems sometimes. That is some this to R&D. For now, in extreme cases, [Web browser](https://pub.dev/packages/web_browser) can be used to view log contents instead. 

### Example code of sending request to the LogKeeper

Unity, C#:

```csharp
var form = new WWWForm();

// Prepare log data
form.AddField("title", title);
form.AddField("author", author);
form.AddField("project", project);
form.AddField("contents", contents); // the log contents

// Send
var uwr = UnityWebRequest.Post("your_url" + "/save", form);
yield return uwr.SendWebRequest();
if (uwr.isNetworkError || uwr.isHttpError)
{
    // error
    return;
}

// Read result
var raw = Encoding.UTF8.GetString(uwr.downloadHandler.data);
var id = JSON.Parse(raw)["body"]["id"].Value;
var urlFormat = JSON.Parse(raw)["body"]["url_format"].Value;

// Get the link to the log
var link = string.Format(urlFormat, id);
_clipboardService.SetText(link);
ShowNotifications("Report link copied to clipboard");
```