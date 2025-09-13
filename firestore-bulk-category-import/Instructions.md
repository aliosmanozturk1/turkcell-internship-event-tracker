# 🔥 Firestore Bulk Category Import (Spark Plan)

This repo contains everything you need to **bulk import event categories** into your Firebase Firestore project – even if you’re on the free Spark plan!

Perfect for quickly setting up “lookup” collections (like event categories) in hackathons, MVPs, and production projects.

---

## ✨ What Does This Do?

- Imports a list of event categories into your Firestore database.
- Each category will have a **custom, readable document ID** (`music`, `sports`, etc.) for easy reference.
- Works **without** Blaze (paid) plan or any paid import tools.

---

## 📝 How to Use

### 1. Clone this repo or copy the files

```bash
git clone https://github.com/aliosmanozturk1/turkcell-internship-event-tracker.git
cd turkcell-internship-event-tracker
cd firestore-bulk-import
````

—or—
Just create `categories.json` and `importCategories.js` in your project folder.

---

### 2. Create your categories list

Edit (or keep) the provided `categories.json` file:

```json
[
  { "id": "music", "name": "Music" },
  { "id": "technology", "name": "Technology" },
  { "id": "art", "name": "Art" },
  { "id": "sports", "name": "Sports" },
  { "id": "business", "name": "Business" },
  { "id": "education", "name": "Education" },
  { "id": "networking", "name": "Networking" },
  { "id": "food_drink", "name": "Food & Drink" },
  { "id": "health_wellness", "name": "Health & Wellness" },
  { "id": "science", "name": "Science" },
  { "id": "film_media", "name": "Film & Media" },
  { "id": "literature", "name": "Literature" },
  { "id": "fashion", "name": "Fashion" },
  { "id": "gaming", "name": "Gaming" },
  { "id": "travel", "name": "Travel" },
  { "id": "community", "name": "Community" },
  { "id": "charity", "name": "Charity" },
  { "id": "workshop", "name": "Workshop" },
  { "id": "festival", "name": "Festival" },
  { "id": "party", "name": "Party" },
  { "id": "family", "name": "Family" },
  { "id": "outdoor", "name": "Outdoor" },
  { "id": "theater", "name": "Theater" },
  { "id": "religion_spirituality", "name": "Religion & Spirituality" },
  { "id": "politics", "name": "Politics" }
]
```

Feel free to modify or add your own categories!

---

### 3. Get Your Firebase Service Account Key

* Go to [Firebase Console](https://console.firebase.google.com/).
* Select your project.
* Click the ⚙️ **Project Settings** (gear icon) > **Service accounts** tab.
* Click **"Generate new private key"** and download the file.
* Save it as `serviceAccountKey.json` in your project folder (next to your script).

---

### 4. Install Dependencies

In your project directory, run:

```bash
npm install firebase-admin
```

---

### 5. Run the Import Script

The provided `importCategories.js` script will read your `categories.json` and add each category to your Firestore.

```js
const admin = require("firebase-admin");
const fs = require("fs");

// Import your service account
const serviceAccount = require("./serviceAccountKey.json");

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Load categories from JSON
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
```

**To run:**

```bash
node importCategories.js
```

---

### 6. Check Your Firestore

Go to [Firebase Console > Firestore Database](https://console.firebase.google.com/)
You should see a new collection named `categories` with all your category documents.

---

## 🛠️ Customization

* To add more fields (e.g. `icon`, `color`), just update your `categories.json` and the `set()` call in the script accordingly.

Example:

```json
{ "id": "music", "name": "Music", "icon": "music_note", "color": "#2196F3" }
```

```js
await db.collection("categories").doc(category.id).set({
  name: category.name,
  icon: category.icon,
  color: category.color
});
```

---

## ❓ FAQ

**Q: Can I use this on the free (Spark) plan?**
A: Yes! This method does not require Blaze/paid plan.

**Q: Can I import other types of data this way?**
A: Yes, just adjust your JSON and script for any Firestore collection.

**Q: What if I get an error about serviceAccountKey.json?**
A: Make sure the file is downloaded from Firebase Console, is named correctly, and is in your project folder.
