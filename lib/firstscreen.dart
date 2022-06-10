import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testrum/secondscreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
//Step 3
  _HomeScreenState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  final TextEditingController _filter = new TextEditingController();
  final dio = new Dio();
  String _searchText = "";
  List names = [];
  List filteredNames = [];
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Search here');

  void _getNames() async {
    final response = await dio
        .get('https://thecocktaildb.com/api/json/v1/1/search.php?s=rum');
    print(response.data);
    List tempList = [];
    for (int i = 0; i < response.data['drinks'].length; i++) {
      tempList.add(response.data['drinks'][i]);
    }
    setState(() {
      names = tempList;
      filteredNames = names;
    });
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextField(
          controller: _filter,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'Search...'),
        );
      } else {
        this._searchIcon = Icon(Icons.search);
        this._appBarTitle = new Text('Search Example');
        filteredNames = names;
        _filter.clear();
      }
    });
  }

  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List tempList = [];
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i]["strDrink"]
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }
    return ListView.builder(
      itemCount: names == null ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: ListTile(
            leading: Image.network(filteredNames[index]["strDrinkThumb"]),
            title: Text(filteredNames[index]["strDrink"]),
            onTap: () {
              Get.to(secondpage(), arguments: [
                filteredNames[index]['idDrink'],
                filteredNames[index]['strDrink'],
                filteredNames[index]['strCategory'],
                filteredNames[index]['strGlass'],
                filteredNames[index]['strInstructions'],
                filteredNames[index]['strDrinkThumb'],
              ]);
            },
          ),
        );
      },
    );
  }

  Widget _buildBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: _appBarTitle,
      leading: IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,
      ),
    );
  }

  @override
  void initState() {
    _getNames();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100), child: _buildBar(context)),
      body: Container(
        child: _buildList(),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
