const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const userSchema = new mongoose.Schema({
  name: String,
  email: {
    type: String,
    unique: true,
    required: true
  },
  sifre: {
    type: String,
    required: true
  }
});

// Şifreyi kaydetmeden önce hashle
userSchema.pre("save", async function (next) {
  if (!this.isModified("sifre")) return next();
  try {
    const salt = await bcrypt.genSalt(10);
    this.sifre = await bcrypt.hash(this.sifre, salt);
    next();
  } catch (err) {
    next(err);
  }
});

module.exports = mongoose.model("User", userSchema);

