//Uygulamanın internette gideceği tüm URL adresleri bu dosyada tutulur.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://mobilab-task-api.vercel.app'; //sunucumuzun ana adresidir
  static const String categories = '$baseUrl/categories'; //(Hackathon, workshop vb. ) veren uç nokta
  static const String events = '$baseUrl/events'; //Etkinlik listesini veren uç nokta

  static String eventDetail(String id) => '$baseUrl/events/$id'; //Tek bir etkinliğin açıklamasını çekmek için içine ID alan fonksiyon
                                                                  //örn: eventDetail('evt-1') çağrıldığında 'https://mobilab-task-api.vercel.app/events/evt-1' üretir
}

