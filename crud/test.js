const express = require('express');

const app = express();
const port = 3000; // You can change the port number if desired

app.get('/', (req, res) => {
  res.send('Test success');
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});