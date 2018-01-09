const fs = require('fs');
const {Etcd3} = require('etcd3');

const client = new Etcd3({
    hosts: 'https://localhost:2379',
    credentials: {
        rootCertificate: fs.readFileSync(`${__dirname}/certs/etcd/ca.pem`)
    },
    auth: {
        username: process.env.ETCD_USER,
        password: process.env.ETCD_PASS
    }
});

client.put('foo').value('bar')
    .then(() => client.getAll())
    .then(console.log, console.error);
