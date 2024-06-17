const mongoose = require("mongoose");

const PizzaSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    spreis: {
        type: Number
    },
    mpreis: {
        type: Number
    },
    lpreis: {
        type: Number
    }
})

const Pizza = mongoose.model("Pizza", PizzaSchema)

module.exports = { Pizza }