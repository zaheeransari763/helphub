import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  String photo;
  String name;
  String price;
  DocumentReference developerProfile;
  DocumentReference studentProfile;
  DocumentReference projectReference;
  Map<dynamic, dynamic> projectInfo = Map<dynamic, dynamic>();
  Map<String, dynamic> progress = Map<String, dynamic>();
  Timestamp completion;
  bool completed;
  bool current;
  bool rejected;
  bool requested;

  Project(
      {this.photo = 'default',
      this.completed,
      this.price,
      this.name,
      this.developerProfile,
      this.studentProfile,
      this.projectInfo,
      this.progress,
      this.completion,
      this.current,
      this.rejected,
      this.projectReference,
      this.requested = false});

  Project.fromSnapshot(DocumentSnapshot snapshot) {
    fromJson(snapshot.data());
  }

  fromJson(Map<dynamic, dynamic> json) {
    this.name = json['name'];
    this.price = json['Project Price'];
    this.photo = json['image'];
    this.completion = json['Completion Date'];
    this.projectInfo = json['Project Information'];
    this.progress = json['Progress'];
    this.developerProfile = json['Developer Profile'];
    this.studentProfile = json['StudentProfile'];
    this.current = json['current'];
    this.rejected = json['rejected'];
    this.requested = json['requested'];
    this.projectReference = json['project'];
  }

  Project.fromJson(Map<dynamic, dynamic> json) {
    fromJson(json);
  }

  Map<String, dynamic> setRef(Project project) {
    Map<String, dynamic> data = Map<String, dynamic>();
    data['requested'] = project.requested;
    data['StudentProfile'] = project.studentProfile;
    return data;
  }

  Project.fromMap(Map<String, dynamic> data)
      : this(
            name: data['name'],
            price: data['Project Price'],
            photo: data['image'],
            completion: data['Completion Date'],
            projectInfo: Map.from(data['Project Information']),
            progress: Map.from(data['Progress']),
            developerProfile: data['Developer Profile'],
            studentProfile: data['StudentProfile'],
            current: data['current'],
            rejected: data['rejected'],
            completed: data['completed'],
            requested: data['requested'],
            projectReference: data['project']);

  Map<String, dynamic> toMap(Project project) {
    Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = project.name;
    data['Project Price'] = project.price;
    data['image'] = project.photo;
    data['Completion Date'] = project.completion;
    data['Project Information'] = project.projectInfo;
    data['Progress'] = project.progress;
    data['Developer Profile'] = project.developerProfile;
    data['StudentProfile'] = project.studentProfile;
    data['current'] = project.current;
    data['rejected'] = project.rejected;
    data['requested'] = project.requested ?? false;
    data['project'] = project.projectReference;
    return data;
  }
}
