const mongoose = require("mongoose");

const PizzaSchema = new mongoose.Schema({
    Name: {
        type: String,
        required: true
    },
    S: {
        type: Number
    },
    M: {
        type: Number
    },
    L: {
        type: Number
    }
})

const Pizza = mongoose.model("Pizza", PizzaSchema)

module.exports = { Pizza }