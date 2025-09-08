class GoogleBookModel {
  final String title;
  final List<String>? authors;
  final String? description;
  final int? pageCount;
  final String? thumbnail;
  final List<String>? genres;
  final String? publisher;

  GoogleBookModel({
    required this.title,
    this.authors,
    this.description,
    this.pageCount,
    this.thumbnail,
    this.genres,
    this.publisher,
  });

  factory GoogleBookModel.fromJson(Map<String, dynamic> json) {
    return GoogleBookModel(
      title: json['title'] ?? 'No Title',
      authors: (json['authors'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      description: json['description'],
      pageCount: json['pageCount'],
      thumbnail: json['imageLinks'] != null ? json['imageLinks']['thumbnail'] : null,
      genres: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      publisher:json['publisher'],
    );
  }
}
