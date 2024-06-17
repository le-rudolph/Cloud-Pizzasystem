const express = require('express')
const mongoose = require("mongoose");
const { Pizza } = require('./model');
const app = express()
const port = 3000

app.use(express.json())
app.use(express.urlencoded({extended:true}))

app.use(express.static('public'))

app.get('/pizza', async (req, res) => {
  const allPizza = await Pizza.find()
  console.log(allPizza)
  return res.status(200).json(allPizza)
})

app.post("/create_produkt", async (req, res) => {
    console.log(req.body)
    const newPizza = new Pizza({...req.body})
    const insertedPizza = await newPizza.save()
    res.status(200).json(insertedPizza)
})

const start = async () => {
  await mongoose.connect('mongodb://mongo:27017/pizza')

  app.listen(port, () => {
    console.log(`Produktservice listening on port ${port}`)
  })
}

start()
