class PlaceOpeningHours {
  final bool openNow;
  final List<dynamic> workingDays;


  PlaceOpeningHours({this.openNow, this.workingDays});


  factory PlaceOpeningHours.fromJson(Map<dynamic,dynamic> parsedJson){
    return PlaceOpeningHours(
      openNow : (parsedJson['open_now'] != null) ? parsedJson['open_now'] : false,
      workingDays : (parsedJson['weekday_text'] != null) ? parsedJson['weekday_text'] : null,

    );
  }

}