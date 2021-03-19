import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String contactTable = 'contactTable';
const String idColumn = 'idColumn';
const String nameColumn = 'nameColumn';
const String emailColumn = 'emailColumn';
const String phoneColumn = 'phoneColumn';
const String imgColumn = 'imgColumn';

class ContactHelper {
  factory ContactHelper() => _instance;
  ContactHelper.internal();

  static final ContactHelper _instance = ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'contactsnew.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          'CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)');
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    final Database dbContact = await db;

    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    final Database dbContact = await db;

    final List<Map<String, dynamic>> maps = await dbContact.query(contactTable,
        columns: <String>[
          idColumn,
          nameColumn,
          emailColumn,
          phoneColumn,
          imgColumn
        ],
        where: '$idColumn = ?',
        whereArgs: <int>[id]);

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    }

    return null;
  }

  Future<int> deleteContact(int id) async {
    final Database dbContact = await db;

    return await dbContact.delete(
      contactTable,
      where: '$idColumn = ?',
      whereArgs: <int>[id],
    );
  }

  Future<int> updateContact(Contact contact) async {
    final Database dbContact = await db;

    return await dbContact.update(
      contactTable,
      contact.toMap(),
      where: '$idColumn = ?',
      whereArgs: <int>[contact.id],
    );
  }

  Future<List<Contact>> getAllContacts() async {
    final Database dbContact = await db;

    final List<Map<String, dynamic>> listMap =
        await dbContact.rawQuery('SELECT * from $contactTable');

    final List<Contact> listContact = [];
    for (final Map<String, dynamic> m in listMap) {
      listContact.add(Contact.fromMap(m));
    }

    return listContact;
  }

  Future<int> getNumber() async {
    final Database dbContact = await db;

    return Sqflite.firstIntValue(
        await dbContact.rawQuery('SELECT COUNT(*) FROM $contactTable'));
  }

  Future<void> close() async {
    final Database dbContact = await db;
    await dbContact.close();
  }
}

class Contact {
  Contact();

  Contact.fromMap(Map<String, dynamic> map) {
    id = map[idColumn] as int;
    name = map[nameColumn] as String;
    email = map[emailColumn] as String;
    phone = map[phoneColumn] as String;
    img = map[imgColumn] as String;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };

    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)';
  }

  int id;
  String name;
  String email;
  String phone;
  String img;
}
