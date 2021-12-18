const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

const sls = require('serverless-http');

const express = require('express');
const app = express();

const multer = require('multer');
const upload = multer();

// for parsing application/json
app.use(express.json());

// for parsing application/x-www-form-urlencoded
app.use(express.urlencoded({extended: true}));

// for parsing multipart/form-data
app.use(upload.array());
app.use(express.static('public'));

app.get('/logkeeper/unfurl', async (req, res) => {
    try {
        const link = req.query.link;
        let result = await unfurlLogKeeperLink(link);
        res.status(200).send(result);
    } catch (e) {
        console.log(e);
        res.status(404).send();
    }
});

// Parses strings like: https://domain/#/details?id=zEVVt0ltW65vdoppV0Eg
async function unfurlLogKeeperLink(link) {
    const idStr = '?id=';
    const pos = link.indexOf(idStr);
    if (pos === -1) {
        throw `Invalid LogKeeper string. Cannot find ${idStr} position`;
    }

    const id = link.substring(pos + idStr.length);

    if ( id == null || id.length === 0) {
        throw 'Unable to find logKeeper id';
    }

    connectFirebase();

    const db = admin.firestore();

    const projects = await db.collection('projects').get();

    for (const doc of projects.docs) {
        let name = doc.get('name');
        name = replaceAll(name,' ', '_');
        name = name.toLowerCase() + '_logs';

        let logInfo = db.collection(name).doc(id);
        let logInfoQuery = await logInfo.get();

        if (logInfoQuery.exists) {
            const data = logInfoQuery.data();

            let result = new Unfurl();

            result.title = data['title'];
            result.createdAt = data['createdAt'].toDate().toDateString();
            result.author = data['author'];

            return result;
        }
    }

    throw 'Unable to find log info';
}

function connectFirebase() {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });

}

function replaceAll(str, find, replace) {
    return str.replace(new RegExp(find, 'g'), replace);
}

class Unfurl {
    title;
    createdAt;
    author;
}

module.exports.handler = sls(app);