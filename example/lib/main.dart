import 'package:flutter/material.dart';
import 'package:scrollable_list_tabview/scrollable_list_tabview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter ScrollableListTabView Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ScrollableListTabView(
        tabHeight: 48,
        bodyAnimationDuration: const Duration(milliseconds: 150),
        tabAnimationCurve: Curves.easeOut,
        withLabel: false,
        tabAnimationDuration: const Duration(milliseconds: 200),
        tabs: [
          ScrollableListTab(
              tab: ListTab(
                  label: Text('Label 1'),
                  icon: Icon(Icons.group),
                  showIconOnList: false,
                  inactiveLabel: Text('Label 1')),
              body: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (_, index) => ListTile(
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey),
                    alignment: Alignment.center,
                    child: Text(index.toString()),
                  ),
                  title: Text('List element $index'),
                ),
              )),
          ScrollableListTab(
              tab: ListTab(
                  label: Text('Label 2'),
                  icon: Icon(Icons.subject),
                  inactiveLabel: Text('Label 2')),
              body: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (_, index) => Card(
                  child: Center(child: Text('Card element $index')),
                ),
              )),
          ScrollableListTab(
              tab: ListTab(
                  label: Text('Label 3'),
                  icon: Icon(Icons.subject),
                  showIconOnList: true,
                  inactiveLabel: Text('Label 3')),
              body: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                physics: NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (_, index) => Card(
                  child: Center(child: Text('Card element $index')),
                ),
              )),
          ScrollableListTab(
              tab: ListTab(
                  label: Text('Label 4'),
                  icon: Icon(Icons.add),
                  inactiveLabel: Text('Label 4')),
              body: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (_, index) => ListTile(
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey),
                    alignment: Alignment.center,
                    child: Text(index.toString()),
                  ),
                  title: Text('List element $index'),
                ),
              )),
          ScrollableListTab(
              tab: ListTab(
                  label: Text('Label 5'),
                  icon: Icon(Icons.group),
                  inactiveLabel: Text('Label 5')),
              body: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (_, index) => ListTile(
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey),
                    alignment: Alignment.center,
                    child: Text(index.toString()),
                  ),
                  title: Text('List element $index'),
                ),
              )),
          ScrollableListTab(
              tab: ListTab(
                  label: Text('Label 6'),
                  icon: Icon(Icons.subject),
                  inactiveLabel: Text('Label 6')),
              body: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                physics: NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (_, index) => Card(
                  child: Center(child: Text('Card element $index')),
                ),
              )),
          ScrollableListTab(
              tab: ListTab(
                  label: Text('Label 7'),
                  icon: Icon(Icons.subject),
                  showIconOnList: true,
                  inactiveLabel: Text('Label 7')),
              body: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                physics: NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (_, index) => Card(
                  child: Center(child: Text('Card element $index')),
                ),
              )),
          ScrollableListTab(
              tab: ListTab(
                  label: Text('Label 8'),
                  icon: Icon(Icons.add),
                  inactiveLabel: Text('Label 8')),
              body: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 15,
                itemBuilder: (_, index) => ListTile(
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey),
                    alignment: Alignment.center,
                    child: Text(index.toString()),
                  ),
                  title: Text('List element $index'),
                ),
              ))
        ],
      ),
    );
  }
}
