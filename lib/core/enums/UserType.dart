enum UserType { STUDENT, DEVELOPERS, UNKNOWN }

class UserTypeHelper {
  static String getValue(UserType userType) {
    switch (userType) {
      case UserType.STUDENT:
        return "STUDENT";
      case UserType.DEVELOPERS:
        return "DEVELOPER";
      case UserType.UNKNOWN:
        return "UNKNOWN";
      default:
        return 'UNKNOWN';
    }
  }

  static UserType getEnum(String userType) {
 if (userType == getValue(UserType.STUDENT)) {
      return UserType.STUDENT;
    } else if (userType == getValue(UserType.DEVELOPERS)) {
      return UserType.DEVELOPERS;
    } else {
      return UserType.UNKNOWN;
    }
  }
}
