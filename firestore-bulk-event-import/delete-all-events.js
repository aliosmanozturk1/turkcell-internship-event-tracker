const admin = require('firebase-admin');
const readline = require('readline');

// Initialize Firebase Admin SDK
const serviceAccount = require('/Users/aliosmanozturk/Desktop/Developer/GitHub/turkcell-internship-event-tracker/service-account-key.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Create readline interface for user input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function askQuestion(question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer.toLowerCase().trim());
    });
  });
}

async function deleteAllEvents() {
  console.log('\n🚨🚨🚨 DANGER ZONE 🚨🚨🚨');
  console.log('❗️❗️❗️ UYARI: TÜM ETKİNLİKLER SİLİNECEK ❗️❗️❗️');
  console.log('⚠️  Bu işlem GERİ ALINAMAZ!');
  console.log('⚠️  Firestore\'daki TÜM events collection\'ı silinecek');
  console.log('⚠️  Bu işlem KALICI olarak veri kaybına neden olacak');
  console.log('🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨');
  console.log('');

  // First confirmation
  const firstConfirm = await askQuestion('⚠️  GERÇEKTEN tüm etkinlikleri silmek istiyor musun? (EVET/hayır): ');
  
  if (firstConfirm !== 'evet') {
    console.log('✅ İşlem iptal edildi. Hiçbir şey silinmedi.');
    rl.close();
    process.exit(0);
  }

  console.log('');
  console.log('🔥 SİLME İŞLEMİ BAŞLIYOR...');
  console.log('⏳ Mevcut etkinlikler getiriliyor...');

  try {
    // Get all events
    const eventsSnapshot = await db.collection('events').get();
    const totalEvents = eventsSnapshot.docs.length;

    if (totalEvents === 0) {
      console.log('📭 Silinecek etkinlik bulunamadı.');
      rl.close();
      process.exit(0);
    }

    console.log(`📊 Toplam ${totalEvents} etkinlik bulundu.`);
    console.log('🔥 Silme işlemi başlıyor...');

    // Delete in batches (Firestore batch limit is 500)
    const batchSize = 500;
    let deletedCount = 0;

    for (let i = 0; i < eventsSnapshot.docs.length; i += batchSize) {
      const batch = db.batch();
      const batchDocs = eventsSnapshot.docs.slice(i, i + batchSize);

      batchDocs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      deletedCount += batchDocs.length;
      
      console.log(`🗑️  ${deletedCount}/${totalEvents} etkinlik silindi...`);
    }

    console.log('');
    console.log('✅ BAŞARILI!');
    console.log(`🗑️  Toplam ${totalEvents} etkinlik silindi.`);
    console.log('💀 events collection tamamen temizlendi.');
    console.log('');

  } catch (error) {
    console.error('❌ Hata oluştu:', error);
    console.log('⚠️  Bazı etkinlikler silinememiş olabilir.');
  } finally {
    rl.close();
    process.exit(0);
  }
}

// Run the deletion process
deleteAllEvents();