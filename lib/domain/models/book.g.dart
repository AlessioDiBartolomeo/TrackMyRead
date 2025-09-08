// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 0;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      bookName: fields[0] as String,
      authorName: (fields[1] as List).cast<String>(),
      isbn: fields[3] as String,
      description: fields[2] as String?,
      currentPage: fields[4] as int,
      totalPages: fields[5] as int,
      startDate: fields[6] as DateTime?,
      imagePath: fields[7] as String,
      status: fields[8] as String,
      lastReadDate: fields[9] as DateTime?,
      endDate: fields[10] as DateTime?,
      readCount: fields[11] as int,
      readHistory: (fields[12] as Map?)?.cast<String, int>(),
      genres: (fields[13] as List).cast<String>(),
      publisher: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.bookName)
      ..writeByte(1)
      ..write(obj.authorName)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isbn)
      ..writeByte(4)
      ..write(obj.currentPage)
      ..writeByte(5)
      ..write(obj.totalPages)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.imagePath)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.lastReadDate)
      ..writeByte(10)
      ..write(obj.endDate)
      ..writeByte(11)
      ..write(obj.readCount)
      ..writeByte(12)
      ..write(obj.readHistory)
      ..writeByte(13)
      ..write(obj.genres)
      ..writeByte(14)
      ..write(obj.publisher);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
