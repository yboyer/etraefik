const fs = require('fs');
const {Etcd3} = require('etcd3');

const client = new Etcd3({
    hosts: 'https://127.0.0.1:2379',
    credentials: {
        rootCertificate: fs.readFileSync(`${__dirname}/certs/etcd/ca.pem`)
    },
    auth: {
        username: 'root',
        password: 'test'
    }
});

client.put('foo').value('bar')
    .then(() => client.getAll())
    .then(console.log, console.error);
