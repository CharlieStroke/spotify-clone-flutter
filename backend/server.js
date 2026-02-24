require('dotenv').config();
const app = require('./src/App');

app.listen(process.env.PORT, '0.0.0.0', () => {
   console.log(`Server running on port ${process.env.PORT}`);
});
