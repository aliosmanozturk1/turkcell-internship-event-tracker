# 🎉 Firestore Bulk Event Import (Spark Plan Compatible)

This toolkit lets you **bulk import realistic event data** into your Firebase Firestore – perfect for testing, demos, and MVP development!

Generate 100 Turkish events with realistic data, proper categories, and working images in seconds.

---

## ✨ What Does This Do?

- **Generates 100 realistic Turkish events** with proper Turkish names, locations, and descriptions
- **Uses your existing categories** from Firestore (no hardcoded categories!)
- **Real coordinates** for Istanbul, Ankara, Izmir, Bursa, and Antalya
- **Working images** via Lorem Picsum (no broken image links)
- **Batch operations** for fast import/delete
- **Dangerous delete script** with double confirmation for cleanup

---

## 📦 Files Included

- `mock-data-generator.js` - Main generator script
- `delete-all-events.js` - Dangerous cleanup script  
- `package.json` - Dependencies and npm scripts
- `README-mock-data.md` - Technical details
- `Instructions.md` - This file

---

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd firestore-bulk-event-import
npm install
```

### 2. Setup Firebase Service Account

* Go to [Firebase Console](https://console.firebase.google.com/)
* Select your project
* Click ⚙️ **Project Settings** > **Service accounts**
* Click **"Generate new private key"**
* Save as `service-account-key.json` in this folder

### 3. Generate Mock Data (Test First)

```bash
npm run generate
```

This creates `mock-events.json` for preview without touching Firebase.

### 4. Upload to Firestore

```bash
npm run upload
```

This will:
- Fetch your existing categories from Firestore
- Generate 100 events using those categories
- Batch upload to `events` collection

### 5. Clean Up (Optional)

**⚠️ DANGER: This deletes ALL events!**

```bash
npm run delete-all-events
```

- Shows scary warnings
- Requires typing "EVET" 
- Batch deletes all events

---

## 🎯 Generated Event Features

### Realistic Turkish Data
- **Titles**: "React Native Workshop", "Girişimcilik Zirvesi", "UI/UX Tasarım Atölyesi"
- **Locations**: Real venues in major Turkish cities
- **Coordinates**: Actual lat/lng for Istanbul, Ankara, Izmir, Bursa, Antalya
- **Organizers**: "Tech Istanbul", "Innovation Hub", "Startup Academy"

### Smart Randomization
- **60% free events**, 40% paid (realistic distribution)
- **Random dates** in next 90 days
- **Realistic participant counts** (20-200 max, 0-80% filled)
- **Age restrictions** on some events
- **Multiple categories** from your existing Firestore data

### Working Images
- **Lorem Picsum URLs**: `https://picsum.photos/800/600?random=X`
- **Thumbnails**: `https://picsum.photos/400/300?random=X`
- **Always load** (no broken image links)
- **Different images per event**

---

## 🏗️ Data Structure

Generated events match your `CreateEventModel.swift`:

```javascript
{
  title: "React Native Workshop",
  description: "Deneyimli eğitmenler eşliğinde...",
  categories: ["technology"], // From your Firestore
  location: {
    name: "İTÜ Teknokent",
    city: "İstanbul",
    district: "Beşiktaş",
    latitude: "41.0750",
    longitude: "29.0950"
  },
  participants: {
    maxParticipants: 50,
    currentParticipants: 23,
    showRemaining: true
  },
  pricing: {
    price: 0, // or random paid amount
    currency: "TL"
  },
  images: [
    {
      url: "https://picsum.photos/800/600?random=123",
      thumbnailUrl: "https://picsum.photos/400/300?random=123"
    }
  ]
  // ... all other CreateEventModel fields
}
```

---

## 🛠️ Customization

### Change Event Count
```javascript
// In mock-data-generator.js
function generateAllMockData() {
  const events = [];
  for (let i = 0; i < 50; i++) { // Change from 100 to 50
    events.push(generateMockEvent());
  }
  return events;
}
```

### Add More Cities
```javascript
const locations = [
  { city: 'İstanbul', districts: ['Beşiktaş', 'Şişli'] },
  { city: 'Ankara', districts: ['Çankaya', 'Keçiören'] },
  { city: 'Adana', districts: ['Seyhan', 'Yüreğir'] }, // Add new city
];
```

### Custom Event Titles
```javascript
const eventTitles = [
  'React Native Workshop',
  'Your Custom Event Name', // Add yours
  'Another Event Type'
];
```

---

## 🔧 Scripts Reference

| Command | Purpose |
|---------|---------|
| `npm run generate` | Create JSON file (test mode) |
| `npm run upload` | Upload to Firestore |
| `npm run delete-all-events` | 🔥 Delete ALL events (dangerous!) |

---

## ❓ Troubleshooting

**Q: Categories array is empty**  
A: Make sure you have categories in Firestore first. Run the category import script first.

**Q: Firebase initialization error**  
A: Check `service-account-key.json` path and permissions.

**Q: Images not loading**  
A: Lorem Picsum should always work. If not, check your internet connection.

**Q: Delete script won't run**  
A: Type exactly "EVET".

---

## 🚨 Important Notes

- **Always backup** your data before using delete script
- **Test with generate first** before uploading  
- **Categories must exist** in Firestore before running upload
- **Free Spark plan** compatible (no Blaze required)
- **Turkish locale** optimized (Turkish cities, names, descriptions)

---

Happy event importing! 🎉
