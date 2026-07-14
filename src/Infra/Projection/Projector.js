import pk from 'pg';
const { Client } = pk;

let lockClients = {};

export const _tryAdvisoryLock = (host) => (port) => (database) => (user) => (password) => (lockName) => async () => {
    const key = Buffer.from(JSON.stringify({host, port, database, user, lockName})).toString('base64');

    // If we already hold the lock in this process, another concurrent execution 
    // must be trying to acquire it. We cleanly return false to make it wait.
    if (lockClients[key]) {
       return false;
    }

    const client = new Client({
        host,
        port,
        database,
        user,
        password,
        // The dedicated client won't execute any SQL queries after acquiring the lock.
        // Without activity, routers or firewalls would eventually consider this 100% 
        // silent TCP connection as "dead" and prune the route.
        // If this happens, Postgres immediately releases the Lock.
        // The "keepAlive" flag forces the OS to send regular network micro-pulses 
        // to tell the network "The line is busy!" and tell Postgres "I'm still alive!".
        keepAlive: true
    });

    try {
        await client.connect();
        
        const res = await client.query('SELECT pg_try_advisory_lock(hashtext($1)) as locked', ['proj:' + lockName]);
        const locked = res.rows[0] && res.rows[0].locked;

        if (locked) {
            // Handle unexpected disconnects during lock-holding (crashes process to release and restart)
            client.on('error', (err) => {
                console.error('[ProjectorLock] Dedicated client error!', err);
                process.exit(1);
            });
            client.on('end', () => {
                console.error('[ProjectorLock] Dedicated client disconnected unexpectedly!');
                process.exit(1);
            });

            // Keep the client alive to hold the exclusive session lock
            lockClients[key] = client;
            
            return true;
        } else {
            // Did not get the lock, disconnect immediately to not leak clients
            await client.end();

            return false;
        }
    } catch (e) {
        // console.error('[ProjectorLock] Failed to acquire lock due to error:', e);
        try { 
            await client.end(); 
        } catch (e2) {}

        return false;
    }
};
