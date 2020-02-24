import 'package:flutter/material.dart';
import 'package:notodo_app/model/notodo_item.dart';
import 'package:notodo_app/utils/database_client.dart';
import 'package:notodo_app/utils/date_formatter.dart';

class NoToDoScreen extends StatefulWidget {
  @override
  _NoToDoScreenState createState() => _NoToDoScreenState();
}

class _NoToDoScreenState extends State<NoToDoScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  var db = DatabaseHelper();
  final List<NoToDoItem> _itemList = <NoToDoItem>[];

  @override
  void initState() {
    super.initState();
    _readNoDoList();
  }

  void _handleSubmitted(String text) async {
    _textEditingController.clear();
    NoToDoItem noToDoItem = NoToDoItem(text, dateFormatted());
    int savedItemId = await db.saveItem(noToDoItem);

    NoToDoItem addedItem = await db.getItem(savedItemId);

    setState(() {
      _itemList.insert(0, addedItem);
    });

    print("Item saved id: $savedItemId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: <Widget>[
          Flexible(
              child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  reverse: false,
                  itemCount: _itemList.length,
                  itemBuilder: (_, int index) {
                    return Card(
                      color: Colors.white10,
                      child: ListTile(
                        title: _itemList[index],
                        onLongPress: () => _updateNoToDo(_itemList[index], index),
                        trailing: Listener(
                          key: Key(_itemList[index].itemName),
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.redAccent,
                          ),
                          onPointerDown: (pointerEvent) => _removeNoToDoItem(_itemList[index].id, index),
                        ),
                      ),
                    );
                  })),
          Divider(
            height: 1.0,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: "Add item",
          backgroundColor: Colors.redAccent,
          child: ListTile(
            title: Icon(Icons.add),
          ),
          onPressed: _showFormDialog),
    );
  }

  void _showFormDialog() {
    var alert = AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: InputDecoration(
                labelText: "Item",
                hintText: "Eg. Don't buy stuffs",
                icon: Icon(Icons.note_add)),
          ))
        ],
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              _handleSubmitted(_textEditingController.text);
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text("Save")),
        FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel"))
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  _readNoDoList() async {
    List items = await db.getItems();
    items.forEach((item) {
      setState(() {
        _itemList.add(NoToDoItem.map(item));
      });
//      NoToDoItem noToDoItem = NoToDoItem.map(item);
//      print("Database has items: ${noToDoItem.itemName}");
    });
  }

  _removeNoToDoItem(int id, int index) async {
    debugPrint("Item deleted!");
    await db.deleteItem(id);
    setState(() {
      _itemList.removeAt(index);
    });
  }

  _updateNoToDo(NoToDoItem item, int index) {
    var alert = AlertDialog (
      title: Text("Update item"),
      content: Row(
        children: <Widget>[
          Expanded(
              child: TextField(
                controller: _textEditingController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Item",
                  hintText: "Eg. Don't buy stuffs",
                  icon: Icon(Icons.update)
                ),
              ))
        ],
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () async {
              NoToDoItem newItemUpdated = NoToDoItem.fromMap(
                  {"itemName" : _textEditingController.text,
                    "dateCreated" : dateFormatted(),
                    "id" : item.id
                  } );
              _handleSubmittedUpdated(index, item);
              await db.updateItem(newItemUpdated);
              setState(() {
                _readNoDoList();
              });
              Navigator.pop(context);
            },
            child: Text("Update")
        ),
        FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel")
        )
      ],
    );
    showDialog(context: context, builder: (_){
      return alert;
    });
  }

  void _handleSubmittedUpdated(int index, NoToDoItem item) {
    setState(() {
      _itemList.removeWhere((element){
        _itemList[index].itemName == item.itemName;
      });
    });
  }
}
