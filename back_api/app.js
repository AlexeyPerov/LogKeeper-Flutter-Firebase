'use strict';

require('dotenv').config();

const token = process.env.VERIFICATION_TOKEN;
const urlFormat = process.env.URL_FORMAT;

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

const express = require('express');
const app = express();

const multer = require('multer');
const upload = multer();

// for parsing application/json
app.use(express.json({limit: '10mb'}));

// for parsing application/x-www-form-urlencoded
app.use(express.urlencoded({extended: true, limit: '10mb'}));

// for parsing multipart/form-data
app.use(upload.array());
app.use(express.static('public'));

// An API for Slack
app.post("/keeper-save", async (req, res) => {
    if (!req.body) {
        return res.sendStatus(400);
    }

    try {
        const payload = req.body;

        if (!token) {
            res.status(500).send('Tokens not set');
            return;
        }

        if (token && token !== payload.token) {
            res.status(401).send('Auth failed');
            return;
        }

        console.log('Saving log');

        try {
            let logId = await saveLog(payload);
            res.status(200).send({
                id: logId,
                url_format: urlFormat
            });
        } catch (e) {
            console.error(e);
            res.status(500).send(e);
            return;
        }

    } catch (e) {
        console.error(e);
        res.status(500).send(e);
    }
});

async function saveLog(logParams) {
    let logProject = logParams.project;
    let logTitle = logParams.title;
    let logAuthor = logParams.author;
    let logContents = logParams.contents;

    if (!logProject) throw 'Project name is not set';
    if (!logTitle) throw 'Log title is not set';
    if (!logAuthor) throw 'Log author is not set';
    if (!logContents) throw 'Log contents is not set';

    connectFirebase();
    const db = admin.firestore();

    const projects = await db.collection('projects').get();

    var projectFound = false;

    for (const doc of projects.docs) {        
        let name = doc.get('name');

        if (name === logProject) {
            projectFound = true;
        }
    }

    if (!projectFound) {
        await db.collection('projects').add({
            name: logProject
          });

        console.log('project created');
    } else {
        console.log('project already exists');
    }

    let createdLogContents = await db.collection('logs').add({
        contents: logContents
    });

    console.log('saved log contents with id: ' + createdLogContents.id);

    let projectCollectionName = logProject;
    projectCollectionName = replaceAll(projectCollectionName,' ', '_');
    projectCollectionName = projectCollectionName.toLowerCase() + '_logs';

    let now = new Date();
    let timestamp = admin.firestore.Timestamp.fromDate(now);

    let document = {
        author: logAuthor,
        title: logTitle,
        createdAt: timestamp,
        contentsId: createdLogContents.id
    };

    let createdLog = await db.collection('logs_info_all').add(document);

    await db.collection(projectCollectionName).doc(createdLog.id).set(document);

    console.log('created log: ' + createdLog.id);

    return createdLog.id;
}

let firebaseApp = null;

function connectFirebase() {
    if (firebaseApp)
        return;

    firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });

}

function replaceAll(str, find, replace) {
    return str.replace(new RegExp(find, 'g'), replace);
}

app.listen(3000, function () {
    console.log('App listening');
  });