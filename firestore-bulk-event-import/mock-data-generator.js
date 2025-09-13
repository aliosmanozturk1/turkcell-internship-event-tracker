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

// Turkish event titles and descriptions - Çeşitli kategorilerden
const eventTitles = [
  // Teknoloji
  'React Native Workshop', 'iOS Geliştirme Bootcamp', 'Yapay Zeka Semineri',
  'Blockchain ve Kripto', 'UI/UX Tasarım Atölyesi', 'Siber Güvenlik Eğitimi',
  
  // Sanat & Kültür
  'Yağlıboya Resim Atölyesi', 'Seramik Yapım Workshop', 'Heykel Sanatı Sergisi',
  'Karakalem Portre Eğitimi', 'Grafik Tasarım Sergi Açılışı', 'Modern Sanat Fuarı',
  'Fotoğrafçılık Workshop', 'El Sanatları Atölyesi', 'Kaligrafi Kursu',
  
  // Müzik & Konser  
  'Caz Konseri - Nardis', 'Akustik Gitar Workshop', 'Sokak Müziği Festivali',
  'Piano Resitali', 'Rock Konseri - Barış Manço Anısına', 'Türk Halk Müziği Gecesi',
  'Elektronik Müzik Workshop', 'Flüt Kursu Başlangıç', 'Indie Rock Festivali',
  
  // Doğa & Açık Hava
  'Belgrad Ormanı Doğa Yürüyüşü', 'Boğaziçi Sahil Bisiklet Turu', 'Karma Ormanı Kampa',
  'Botanik Park Fotoğraf Safari', 'Adalar Tekne Turu', 'Polonezköy Piknik',
  'Dağcılık ve Tırmanış', 'Kuş Gözlemi Etkinliği', 'Şile Sahil Yürüyüşü',
  
  // Spor & Fitness
  'Yoga Sabah Dersleri', 'Pilates Workshop', 'Koşu Grubu Antrenmanı',
  'Plaj Voleybolu Turnuvası', 'Tenis Kursu', 'Yüzme Eğitimi',
  'Bisiklet Tamiri Workshop', 'Outdoor Fitness Bootcamp', 'Masa Tenisi Turnuvası',
  
  // Sosyal & Networking
  'Girişimcilik Zirvesi', 'Kadın Girişimciler Buluşması', 'Freelancer Networking',
  'Startup Pitch Gecesi', 'Kariyer Planlama Semineri', 'Dijital Nomad Buluşması',
  
  // Yemek & Gastronomi
  'İtalyan Mutfağı Workshop', 'Kahve Demleme Sanatı', 'Vegan Yemek Atölyesi',
  'Şarap Tadımı Gecesi', 'Sushi Yapım Kursu', 'Türk Tatlıları Atölyesi',
  
  // Eğitim & Kişisel Gelişim  
  'Halkla Konuşma Kursu', 'Zaman Yönetimi Semineri', 'Liderlik Geliştirme Workshop',
  'Dil Öğrenme Teknikleri', 'Kitap Okuma Kulübü', 'Meditasyon ve Mindfulness'
];

const eventDescriptions = [
  'Bu etkinlikte yeni beceriler öğrenecek ve keyifli vakit geçireceksiniz.',
  'Deneyimli eğitmenler eşliğinde pratik uygulamalar yaparak ilerleme kaydedeceksiniz.',
  'Alanında uzman kişilerden öğrenecek ve yeni insanlarla tanışacaksınız.',
  'İnteraktif aktiviteler ve grup çalışmalarıyla eğlenceli bir deneyim yaşayacaksınız.',
  'Gerçek uygulamalar üzerinde çalışarak deneyim kazanacaksınız.',
  'Doğayla iç içe nefes alacak ve stresi atacaksınız.',
  'Sanatın büyülü dünyasında kendinizi keşfedeceksiniz.',
  'Müziğin evrensel dilinde buluşacak ve coşkuyu paylaşacaksınız.',
  'Lezzetli tarifler öğrenecek ve damak tadınızı geliştireceksiniz.',
  'Sporun verdiği enerji ile kendini yenileme fırsatı bulacaksınız.',
  'Kendinizi geliştirirken yeni arkadaşlıklar kuracaksınız.'
];

const organizerNames = [
  'Tech Istanbul', 'Startup Academy', 'Sanat Atölyesi', 'Doğa Severler Kulübü',
  'Müzik Merkezi', 'Spor Kulübü', 'Yaratıcı Atölye', 'Outdoor Adventures',
  'Kültür Sanat Derneği', 'Fit Life Community', 'Gastronomi Kulübü', 'Yeşil İstanbul',
  'Rock Kulübü', 'Yoga Studio', 'Bisiklet Topluluğu', 'Fotoğraf Derneği',
  'Jazz Corner', 'Lezzet Akademisi', 'Sahil Sporları', 'Halk Oyunları Derneği'
];

const venues = [
  'İTÜ Teknokent', 'Kozyatağı Kültür Merkezi', 'Şişli Belediyesi Konferans Salonu',
  'Boğaziçi Üniversitesi', 'Bilgi Üniversitesi', 'Sabancı Üniversitesi',
  'Belgrad Ormanı', 'Emirgan Korusu', 'Boğaziçi Sahil Yolu', 'Adalar İskelesi',
  'Caddebostan Sahili', 'Maçka Parkı', 'Gülhane Parkı', 'Yıldız Parkı',
  'Jazz Café', 'Nardis Jazz Club', 'Babylon', 'Zorlu Center PSM',
  'Akbank Sanat', 'Pera Müzesi', 'İstanbul Modern', 'Santral İstanbul',
  'Fenerbahçe Parkı', 'Küçüksu Mesire Alanı', 'Atatürk Orman Çiftliği'
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
      thumbnailUrl: `https://picsum.photos/${thumbnailWidth}/${thumbnailHeight}?random=${imageId}`,
      order: 0
    },
    {
      id: `img_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      url: `https://picsum.photos/${width}/${height}?random=${imageId + 1}`,
      thumbnailUrl: `https://picsum.photos/${thumbnailWidth}/${thumbnailHeight}?random=${imageId + 1}`,
      order: 1
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