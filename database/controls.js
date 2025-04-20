const { MongoClient } = require("mongodb");

const uri = "mongodb+srv://edagl0321:E8237lurn29@cluster0.sfedg5w.mongodb.net/Libratech?authSource=admin&retryWrites=true&w=majority&appName=Cluster0"; // Kendi MongoDB URI'nı buraya yaz
const dbName = "Libratech";
const collectionName = "books"; // kitap koleksiyonunun adı

async function cleanDuplicateBooks() {
  const client = new MongoClient(uri);

  try {
    await client.connect();
    console.log("Veritabanına bağlanıldı");

    const db = client.db(dbName);
    const collection = db.collection(collectionName);

    // Kitap başlığına göre tekrar edenleri bul
    const duplicates = await collection.aggregate([
      {
        $group: {
          _id: "$title",            // Kitap başlığına göre grupla
          count: { $sum: 1 },
          ids: { $push: "$_id" }
        }
      },
      { $match: { count: { $gt: 1 } } } // Sadece tekrarlayanlar
    ]).toArray();

    // Tekrar edenleri sil (ilkini bırak)
    for (const group of duplicates) {
      console.log(`Silinecek kitaplar: ${group._id} (Toplam: ${group.count} kayıt)`);

      const idsToDelete = group.ids.slice(1);

      for (const id of idsToDelete) {
        const deleteResult = await collection.deleteOne({ _id: id });
        if (deleteResult.deletedCount === 1) {
          console.log(`Silindi: ${id}`);
        } else {
          console.log(`Silinemedi: ${id}`);
        }
      }
    }

    console.log("Tekrarlayan kitap kayıtları silindi.");
  } catch (err) {
    console.error("Hata oluştu:", err);
  } finally {
    await client.close();
  }
}

cleanDuplicateBooks();
