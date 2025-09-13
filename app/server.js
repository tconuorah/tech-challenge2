// ESM version
import express from 'express';

const app = express();
const PORT = process.env.PORT || 8080;

app.get('/', (_req, res) => {
  res.json({ message: 'Hello, World!' });
});

app.listen(PORT, () => {
  console.log(`Server listening on ${PORT}`);
});
