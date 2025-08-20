const admin = require("firebase-admin");
const fs = require("fs");

// Service account anahtarını içe aktar
const serviceAccount = require("./serviceAccountKey.json");

// Firebase admin başlat
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// JSON dosyalarını oku
const categories = JSON.parse(fs.readFileSync("./categories.json", "utf8"));
const groups = JSON.parse(fs.readFileSync("./groups.json", "utf8"));

async function importData() {
  try {
    console.log("🚀 Starting import process...\n");
    
    // Groups'u import et
    console.log("📁 Importing groups...");
    for (const group of groups) {
      await db.collection("groups").doc(group.id).set({
        name: group.name,
        order: group.order
      });
      console.log(`  ✓ Group: ${group.id} - ${group.name}`);
    }
    console.log(`✅ ${groups.length} groups imported successfully!\n`);
    
    // Categories'i import et
    console.log("📂 Importing categories...");
    for (const category of categories) {
      await db.collection("categories").doc(category.id).set({
        name: category.name,
        icon: category.icon,
        color: category.color,
        groupId: category.groupId
      });
      console.log(`  ✓ Category: ${category.id} - ${category.name} (${category.groupId})`);
    }
    console.log(`✅ ${categories.length} categories imported successfully!\n`);
    
    console.log("🎉 All data imported successfully!");
    process.exit(0);
    
  } catch (error) {
    console.error("❌ Import failed:", error);
    process.exit(1);
  }
}

importData();

