import 'package:helphub/core/services/Services.dart';
import 'package:helphub/core/services/StorageServices.dart';
import 'package:helphub/imports.dart';

class DeveloperProfileServices extends Services {
  StorageServices storageServices = locator<StorageServices>();
  StreamController<Developer> loggedInDeveloperStream =
      StreamController.broadcast(sync: true);

  List<Developer> developers = [];
  DeveloperProfileServices() {
    getUser();
  }

  setProfileData(Developer developer) async {
    if (developer.photoUrl.contains('https')) {
      /*  developer.photoUrl =
          await storageServices.setProfilePhoto(developer.photoUrl); */
    } else if (developer.photoUrl == 'default') {
      developer.photoUrl = developer.photoUrl;
    } else {
      developer.photoUrl =
          await storageServices.setProfilePhoto(developer.photoUrl);
    }

    developer.id = await sharedPreferencesHelper.getDevelopersId();

    Map profileData = developer.toJson(developer);

    var body = json.encode(
      profileData,
    );

    print("success");
    final jsonData = await json.decode(body);
    developer = Developer.fromJson(jsonData);
    sharedPreferencesHelper.setDeveloper(body);
    loggedInDeveloperStream.add(developer);
  }

  Future<Developer> getDeveloper() async {
    Developer developer;
    String id = await sharedPreferencesHelper.getDevelopersId();
    //  if (dev == "N.A") {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc('Profile')
        .collection('Developers')
        .doc(id)
        .get();
    developer = Developer.fromSnapshot(documentSnapshot);
    await sharedPreferencesHelper.setCurrentProject(developer.currentProject);

    Map developerData = developer.toJson(developer);
    var body = json.encode(developerData);
    loggedInDeveloperStream.add(developer);
    await sharedPreferencesHelper.setDeveloper(body);
    return developer;
  }

  Future<Developer> getDeveloperLocal() async {
    Developer developer;
    String body = await sharedPreferencesHelper.getDeveloper();
    if (body != 'N.A') {
      final data = json.decode(body);
      if (data()['displayName'] != null && data()['displayName'] != "") {
        developer = Developer.fromJson(data());
        loggedInDeveloperStream.add(developer);
      } else {
        developer = await getDeveloper();
        loggedInDeveloperStream.add(developer);
      }
    } else {
      developer = await getDeveloper();
    }
    return developer;
  }

  Future<Developer> isDeveloperLoggedin() async {
    Developer developer = await getDeveloperLocal();
    developer.toString();
    return developer;
  }
  /* 

  Future<Developer> getDeveloperProfileDataById(String uid) async {
    DocumentReference profielRef = await _getDeveloperProfileRef(uid);
    try {
      Developer developer = Developer.fromSnapshot(
          await profielRef.get(source: Source.serverAndCache));
      return developer;
    } catch (e) {
      print(e);
      return Developer(id: uid);
    }
  }

  Future<Developer> getUserDataFromReference(
      DocumentReference reference) async {
    Developer developer = Developer.fromSnapshot(await reference.get());
    return developer;
  }

  getDevelopers() async {
    String developers = await sharedPreferencesHelper.getDevelopersId();
    if (developers == 'N.A') {
      this.developers = [];
      return developers;
    }
    Map<String, String> developersId = Map.from(
      jsonDecode(developers).map(
        (key, values) {
          String value = values.toString();
          return MapEntry(key, value);
        },
      ),
    );
    await _getDevelopersData(developersId);
  }

  _getDevelopersData(Map<String, String> id) async {
    List<Developer> developersData = [];
    for (String id in id.values) {
      developersData.add(await getDeveloperProfileDataById(id));
    }
    developers = developers;
  }

  Future<DocumentReference> _getDeveloperProfileRef(String uid) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc('Profile')
        .collection('Developer')
        .doc(uid);
  }
 */
}
