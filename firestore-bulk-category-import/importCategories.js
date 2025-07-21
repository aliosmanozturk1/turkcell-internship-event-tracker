const admin = require("firebase-admin");
const fs = require("fs");

// Service account anahtarını içe aktar
const serviceAccount = require("./serviceAccountKey.json");

// Firebase admin başlat
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Kategorileri oku
const categories = JSON.parse(fs.readFileSync("./categories.json", "utf8"));

async function importCategories() {
  for (const category of categories) {
    await db.collection("categories").doc(category.id).set({
      name: category.name
    });
    console.log(`Imported: ${category.id}`);
  }
  console.log("✅ All categories imported!");
  process.exit(0);
}

importCategories();

