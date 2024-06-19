const express = require('express');
const mongoose = require("mongoose");
const { Pizza } = require('./model');
const app = express();
const port = 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(express.static('public'));

const HOST = process.env.MONGO_HOST
const PORT = process.env.MONGO_PORT
const USER = process.env.MONGO_USER
const PASS = process.env.MONGO_PASS

app.get('/pizza', async (req, res) => {
  const allPizza = await Pizza.find();
  console.log(allPizza);
  const mappedPizza = {};
  allPizza.forEach((pizza) => {
    mappedPizza[pizza.Name] = {
    };

    pizza.S && (mappedPizza[pizza.Name].S = pizza.S);
    pizza.M && (mappedPizza[pizza.Name].M = pizza.M);
    pizza.L && (mappedPizza[pizza.Name].L = pizza.L);
  });

  console.log(mappedPizza);

  return res.status(200).json(mappedPizza);
});

app.post("/create_produkt", async (req, res) => {
  console.log(req.body);
  const newPizza = new Pizza({ ...req.body });
  const insertedPizza = await newPizza.save();
  res.status(200).json(insertedPizza);
});

const start = async () => {
  await mongoose.connect('mongodb://' + HOST + ':' + PORT + '/pizza');

  app.listen(port, () => {
    console.log(`Produktservice listening on port ${port}`);
  });
};

start();
