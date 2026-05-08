const express = require('express');
const app = express();
app.get('/express', (req, res) => {
    res.send('Express is running in ECS at /express!');
});

app.listen(3000, '0.0.0.0');