const express = require('express');
const AWS = require('aws-sdk');

// Configure AWS SDK with your credentials and region
AWS.config.update({
  accessKeyId: process.env.ACCESS_KEY_ID,
  secretAccessKey: process.env.SECRET_KEY,
  region: 'ap-northeast-2'
});

const dynamodb = new AWS.DynamoDB.DocumentClient();
const tableName = 'my-table';

const app = express();
app.use(express.json());

// Create a new item
app.post('/items', (req, res) => {
  const { id, name } = req.body;

  const params = {
    TableName: tableName,
    Item: {
      id: id,
      name: name
    }
  };

  dynamodb.put(params, (error) => {
    if (error) {
      console.error('Error creating item:', error);
      res.status(500).json({ error: 'Could not create item' });
    } else {
      res.status(200).json({ message: 'Item created successfully' });
    }
  });
});

// Get an item by ID
app.get('/items/:id', (req, res) => {
  const { id } = req.params;

  const params = {
    TableName: tableName,
    Key: {
      id: id
    }
  };

  dynamodb.get(params, (error, data) => {
    if (error) {
      console.error('Error retrieving item:', error);
      res.status(500).json({ error: 'Could not retrieve item' });
    } else {
      if (data.Item) {
        res.status(200).json(data.Item);
      } else {
        res.status(404).json({ error: 'Item not found' });
      }
    }
  });
});

// Update an item
app.put('/items/:id', (req, res) => {
  const { id } = req.params;
  const { name } = req.body;

  const params = {
    TableName: tableName,
    Key: {
      id: id
    },
    UpdateExpression: 'set #n = :name',
    ExpressionAttributeNames: {
      '#n': 'name'
    },
    ExpressionAttributeValues: {
      ':name': name
    }
  };

  dynamodb.update(params, (error) => {
    if (error) {
      console.error('Error updating item:', error);
      res.status(500).json({ error: 'Could not update item' });
    } else {
      res.status(200).json({ message: 'Item updated successfully' });
    }
  });
});

// Delete an item
app.delete('/items/:id', (req, res) => {
  const { id } = req.params;

  const params = {
    TableName: tableName,
    Key: {
      id: id
    }
  };

  dynamodb.delete(params, (error) => {
    if (error) {
      console.error('Error deleting item:', error);
      res.status(500).json({ error: 'Could not delete item' });
    } else {
      res.status(200).json({ message: 'Item deleted successfully' });
    }
  });
});

app.get('/', (req, res) => {
  res.send('Test success');
});

// Start the server
app.listen(3000, () => {
  console.log('Server started on port 3000');
});