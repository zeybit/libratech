const { MongoClient } = require("mongodb");

const uri = "mongodb+srv://edagl0321:E8237lurn29@cluster0.sfedg5w.mongodb.net/Libratech?authSource=admin&retryWrites=true&w=majority&appName=Cluster0";
const dbName = "Libratech"; 
const collectionName = "users";

async function cleanDuplicates() {
  const client = new MongoClient(uri);

  try {
    await client.connect();
    console.log("Veritabanına bağlanıldı");

    const db = client.db(dbName);
    const collection = db.collection(collectionName);

    const duplicates = await collection.aggregate([
      {
        $group: {
          _id: "$email",
          count: { $sum: 1 },
          ids: { $push: "$_id" }
        }
      },
      { $match: { count: { $gt: 1 } } }
    ]).toArray();

    for (const group of duplicates) {
      console.log(`Silinecek veriler: ${group._id} (Toplam: ${group.count} kullanıcı)`);

      // İlk kaydı tut, geri kalanları sil
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

    console.log("Tekrarlayan kullanıcılar silindi");
  } catch (err) {
    console.error("Hata oluştu:", err);
  } finally {
    await client.close();
  }
}

cleanDuplicates();