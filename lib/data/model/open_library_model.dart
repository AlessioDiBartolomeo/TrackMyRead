class OpenLibraryBookModel {
  final String? description;
  final int? pageCount;

  OpenLibraryBookModel({this.description, this.pageCount});

  factory OpenLibraryBookModel.fromJson(Map<String, dynamic> json) {
    String? desc;
    if (json['description'] != null) {
      if (json['description'] is String) {
        desc = json['description'];
      } else if (json['description'] is Map) {
        desc = json['description']['value'];
      }
    }
    return OpenLibraryBookModel(
      description: desc,
      pageCount: json['number_of_pages'] as int?,
    );
  }
}
