'use strict';

require('dotenv').config();

const { WebClient } = require('@slack/client');
const keyBy = require('lodash.keyby');
const omit = require('lodash.omit');
const mapValues = require('lodash.mapvalues');

const token = process.env.SLACK_VERIFICATION_TOKEN,
    accessToken = process.env.SLACK_CLIENT_TOKEN;

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

// An API for Slack
app.post("/logkeeper-app-unfurl", async (req, res) => {
    if (!req.body) {
        return res.sendStatus(400);
    }

    try {
        const payload = req.body;

        // verify necessary tokens are set in environment variables
        if (!token || !accessToken) {
            res.status(500).send('Tokens not set');
            return;
        }

        // Verification Token validation to make sure that the request comes from Slack
        if (token && token !== payload.token) {
            res.status(401).send('Auth failed');
            return;
        }

        console.log('type: ' + payload.type);

        if (payload.type === "event_callback") {
            const slack = new WebClient(accessToken);
            const event = payload.event;

            console.log(event);

            try {
                onLinkShared(slack, event)
                    .then(r => res.status(200).send())
                    .catch(e => {
                        console.error(e);
                        res.status(500).send(e);
                    });
            } catch (e) {
                console.error(e);
                res.status(500).send(e);
                return;
            }


        }
        // challenge sent by Slack when you first configure Events API
        else if (payload.type === "url_verification") {
            console.log('verification');
            res.status(200).send(payload.challenge);
        } else {
            console.error("An unknown event type received.");
            res.status(200).send("Unknown event type received.");
        }
    } catch (e) {
        console.error(e);
        res.status(500).send(e);
    }
});

function onLinkShared(slack, event) {
    return Promise.allSettled(event.links.map(messageUnfurlFromLink))
        .then(results => {
            const filtered = results.filter(r => r.status === "fulfilled");
            return Promise.all(filtered.map(x => x.value)).then(x => keyBy(x, 'url'))
                .then(unfurls => mapValues(unfurls, x => omit(x, 'url')))
                .then(unfurls => {
                    const args = {
                        ts: event.message_ts,
                        channel: event.channel,
                        unfurls: unfurls
                    };

                    console.log('args: ' + JSON.stringify(args));

                    return slack.chat.unfurl(args).then(r => console.log(JSON.stringify(r)))
                        .catch(e => console.error("Error:\n" + JSON.stringify(e)));
                })
                .catch((e) => console.error(e));
        });
}

function messageUnfurlFromLink(link) {
    return getLogKeeperUrlData(link.url)
        .then((data) => {
            if (!data) {
                throw 'Unable to retrieve link data';
            }

            return {
                url: link.url,
                blocks: [
                    {
                        type: 'section',
                        text: {
                            type: 'plain_text',
                            text: data.title
                        }
                    },
                    {
                        type: 'section',
                        text: {
                            type: 'mrkdwn',
                            text: "*Author:*\n" + data.author + "\n*Date:*\n" + data.createdAt
                        },
                        accessory: {
                            type: "image",
                            image_url: "https://api.slack.com/img/blocks/bkb_template_images/approvalsNewDevice.png",
                            alt_text: "Log"
                        }
                    }
                ],
            };
        });
}

function getLogKeeperUrlData(url) {
    return unfurlLogKeeperLink(url).then(function(data) {
        return data;
    }).catch(e => {
        console.error(e);
        return null;
    });
}

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

class Unfurl {
    title;
    createdAt;
    author;
}

module.exports.handler = sls(app);