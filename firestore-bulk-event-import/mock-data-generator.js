const admin = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase Admin SDK
const serviceAccount = require('/Users/aliosmanozturk/Desktop/Developer/GitHub/turkcell-internship-event-tracker/service-account-key.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Will fetch categories from Firebase
let categories = [];

// Turkish cities and districts
const locations = [
  { city: 'İstanbul', districts: ['Beşiktaş', 'Şişli', 'Kadıköy', 'Beyoğlu', 'Üsküdar', 'Bakırköy', 'Levent'] },
  { city: 'Ankara', districts: ['Çankaya', 'Keçiören', 'Yenimahalle', 'Mamak', 'Etimesgut'] },
  { city: 'İzmir', districts: ['Konak', 'Karşıyaka', 'Bornova', 'Buca', 'Çiğli'] },
  { city: 'Bursa', districts: ['Osmangazi', 'Nilüfer', 'Yıldırım', 'Mudanya'] },
  { city: 'Antalya', districts: ['Muratpaşa', 'Konyaaltı', 'Kepez', 'Aksu'] }
];

// Turkish event titles and descriptions
const eventTitles = [
  'React Native Workshop', 'iOS Geliştirme Bootcamp', 'Yapay Zeka Semineri',
  'Girişimcilik Zirvesi', 'Dijital Pazarlama Eğitimi', 'Mobil Uygulama Geliştirme',
  'Blockchain ve Kripto', 'UI/UX Tasarım Atölyesi', 'Swift Programlama',
  'Flutter ile Uygulama Geliştirme', 'Veri Bilimi Workshop', 'Siber Güvenlik Eğitimi',
  'Startup Pitch Event', 'Tech Talk: Gelecek Teknolojiler', 'Hackathon İstanbul',
  'Kadın Girişimciler Buluşması', 'Fintech Konferansı', 'E-ticaret Stratejileri',
  'Sosyal Medya Marketing', 'Yazılım Test Eğitimi', 'DevOps Workshop',
  'Cloud Computing Semineri', 'API Geliştirme Workshop', 'Database Optimizasyon',
  'Game Development Bootcamp', 'AR/VR Teknolojileri', 'Machine Learning 101',
  'Python ile Web Development', 'JavaScript Framework Karşılaştırması', 'Agile Metodolojileri'
];

const eventDescriptions = [
  'Bu etkinlikte en güncel teknolojileri öğrenecek ve sektör uzmanlarıyla networking yapma fırsatı bulacaksınız.',
  'Deneyimli eğitmenler eşliğinde pratik uygulamalar yaparak yeni beceriler kazanacaksınız.',
  'Sektörün önde gelen isimlerinden ilham alıcı sunumlar dinleyecek ve değerli bağlantılar kuracaksınız.',
  'İnteraktif workshoplar ve grup çalışmalarıyla bilgilerinizi pekiştireceksiniz.',
  'Gerçek projeler üzerinde çalışarak deneyim kazanacak ve portföyünüzü güçlendireceksiniz.',
];

const organizerNames = [
  'Tech Istanbul', 'Startup Academy', 'Digital Minds', 'Innovation Hub',
  'Code Academy', 'Future Tech', 'Smart Solutions', 'Next Generation',
  'Tech Leaders', 'Innovation Lab', 'Developer Community', 'Startup Network'
];

const venues = [
  'İTÜ Teknokent', 'Kozyatağı Kültür Merkezi', 'Şişli Belediyesi Konferans Salonu',
  'Boğaziçi Üniversitesi', 'Bilgi Üniversitesi', 'Sabancı Üniversitesi',
  'İstanbul Kongre Merkezi', 'Ankara Atatürk Kültür Merkezi', 'İzmir Kültürpark',
  'Bursa Merinos Kültür Merkezi', 'Antalya Kültür Merkezi'
];

// Function to generate random coordinates for Turkish cities
function getRandomCoordinates(city) {
  const coords = {
    'İstanbul': { lat: [41.0082, 41.0750], lng: [28.9784, 29.0950] },
    'Ankara': { lat: [39.8667, 39.9667], lng: [32.8000, 32.9000] },
    'İzmir': { lat: [38.4000, 38.4500], lng: [27.1000, 27.2000] },
    'Bursa': { lat: [40.1800, 40.2200], lng: [29.0500, 29.1000] },
    'Antalya': { lat: [36.8800, 36.9200], lng: [30.6500, 30.7500] }
  };
  
  const cityCoords = coords[city];
  return {
    latitude: (Math.random() * (cityCoords.lat[1] - cityCoords.lat[0]) + cityCoords.lat[0]).toFixed(6),
    longitude: (Math.random() * (cityCoords.lng[1] - cityCoords.lng[0]) + cityCoords.lng[0]).toFixed(6)
  };
}

// Function to generate event images using Lorem Picsum
function generateEventImages() {
  const imageId = Math.floor(Math.random() * 1000) + 1;
  const width = 800;
  const height = 600;
  const thumbnailWidth = 400;
  const thumbnailHeight = 300;
  
  return [
    {
      id: `img_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      url: `https://picsum.photos/${width}/${height}?random=${imageId}`,
      thumbnailUrl: `https://picsum.photos/${thumbnailWidth}/${thumbnailHeight}?random=${imageId}`
    },
    {
      id: `img_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      url: `https://picsum.photos/${width}/${height}?random=${imageId + 1}`,
      thumbnailUrl: `https://picsum.photos/${thumbnailWidth}/${thumbnailHeight}?random=${imageId + 1}`
    }
  ];
}

// Function to generate a single mock event
function generateMockEvent() {
  const location = locations[Math.floor(Math.random() * locations.length)];
  const district = location.districts[Math.floor(Math.random() * location.districts.length)];
  const coordinates = getRandomCoordinates(location.city);
  
  const startDate = new Date(Date.now() + Math.random() * 90 * 24 * 60 * 60 * 1000); // Random date in next 90 days
  const endDate = new Date(startDate.getTime() + (2 + Math.random() * 6) * 60 * 60 * 1000); // 2-8 hours later
  const registrationDeadline = new Date(startDate.getTime() - Math.random() * 7 * 24 * 60 * 60 * 1000); // 0-7 days before
  
  const maxParticipants = [20, 30, 50, 100, 200][Math.floor(Math.random() * 5)];
  const currentParticipants = Math.floor(Math.random() * maxParticipants * 0.8);
  
  const price = Math.random() > 0.4 ? 0 : Math.floor(Math.random() * 500) * 10; // 40% free events
  
  return {
    title: eventTitles[Math.floor(Math.random() * eventTitles.length)],
    description: eventDescriptions[Math.floor(Math.random() * eventDescriptions.length)],
    categories: [categories[Math.floor(Math.random() * categories.length)]],
    whatToExpected: "Etkinlikte güncel konular ele alınacak, networking fırsatları sunulacak ve soru-cevap oturumları düzenlenecektir.",
    startDate: startDate,
    endDate: endDate,
    registrationDeadline: registrationDeadline,
    location: {
      name: venues[Math.floor(Math.random() * venues.length)],
      address1: `${Math.floor(Math.random() * 200) + 1}. Sokak No: ${Math.floor(Math.random() * 50) + 1}`,
      address2: `Kat: ${Math.floor(Math.random() * 10) + 1}`,
      city: location.city,
      district: district,
      latitude: coordinates.latitude,
      longitude: coordinates.longitude
    },
    participants: {
      maxParticipants: maxParticipants,
      currentParticipants: currentParticipants,
      showRemaining: Math.random() > 0.3
    },
    ageRestriction: {
      minAge: Math.random() > 0.7 ? Math.floor(Math.random() * 10) + 16 : null,
      maxAge: Math.random() > 0.9 ? Math.floor(Math.random() * 20) + 40 : null
    },
    language: Math.random() > 0.8 ? 'en' : 'tr',
    requirements: Math.random() > 0.6 ? "Temel bilgisayar kullanımı yeterlidir" : "",
    organizer: {
      name: organizerNames[Math.floor(Math.random() * organizerNames.length)],
      email: `info@${organizerNames[Math.floor(Math.random() * organizerNames.length)].toLowerCase().replace(/\s+/g, '')}.com`,
      phone: `+90 ${Math.floor(Math.random() * 900) + 500} ${Math.floor(Math.random() * 900) + 100} ${Math.floor(Math.random() * 90) + 10} ${Math.floor(Math.random() * 90) + 10}`,
      website: `https://www.${organizerNames[Math.floor(Math.random() * organizerNames.length)].toLowerCase().replace(/\s+/g, '')}.com`
    },
    pricing: {
      price: price,
      currency: "TL"
    },
    socialLinks: `@${organizerNames[Math.floor(Math.random() * organizerNames.length)].toLowerCase().replace(/\s+/g, '')}`,
    contactInfo: `WhatsApp: +90 5${Math.floor(Math.random() * 9)}${Math.floor(Math.random() * 9)} ${Math.floor(Math.random() * 900) + 100} ${Math.floor(Math.random() * 90) + 10} ${Math.floor(Math.random() * 90) + 10}`,
    images: generateEventImages(),
    createdAt: new Date(),
    updatedAt: new Date(),
    createdBy: "mock_user_" + Math.floor(Math.random() * 10)
  };
}

// Generate 100 mock events
function generateAllMockData() {
  const events = [];
  for (let i = 0; i < 100; i++) {
    events.push(generateMockEvent());
  }
  return events;
}

// Save to JSON file (with fallback categories for testing)
function saveToFile() {
  // Use fallback categories if Firebase not available
  if (categories.length === 0) {
    categories = ['technology', 'art', 'music', 'business', 'education', 'health_wellness', 'sports'];
  }
  
  const events = generateAllMockData();
  fs.writeFileSync('mock-events.json', JSON.stringify(events, null, 2), 'utf8');
  console.log('✅ 100 mock events generated and saved to mock-events.json');
}

// Fetch categories from Firebase
async function fetchCategories() {
  const categoriesSnapshot = await db.collection('categories').get();
  return categoriesSnapshot.docs.map(doc => doc.id);
}

// Upload to Firestore (uncomment when ready)
async function uploadToFirestore() {
  // Fetch categories first
  categories = await fetchCategories();
  console.log(`📋 Fetched ${categories.length} categories from Firebase`);
  
  const events = generateAllMockData();
  const batch = db.batch();
  
  events.forEach((event) => {
    const docRef = db.collection('events').doc();
    batch.set(docRef, event);
  });
  
  try {
    await batch.commit();
    console.log('✅ Successfully uploaded 100 events to Firestore');
  } catch (error) {
    console.error('❌ Error uploading to Firestore:', error);
  }
}

// Export functions
module.exports = {
  generateMockEvent,
  generateAllMockData,
  saveToFile,
  uploadToFirestore
};

// Run if called directly
if (require.main === module) {
  console.log('🚀 Generating mock events...');
  saveToFile();
  
  // Uncomment to upload to Firestore:
  // uploadToFirestore().then(() => process.exit(0));
}