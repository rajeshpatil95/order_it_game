import 'package:flutter/material.dart';
import 'package:order_it_game/components/orderable.dart';
import 'package:order_it_game/components/orderable_stack.dart';

class OrderIt extends StatefulWidget {
  bool isRotated;
  int gameLevel = 1;
  int iteration = 1;
  OrderIt({key, this.isRotated = false}) : super(key: key);

  // This widget is the root of your application.
  @override
  OrderItState createState() {
    return new OrderItState();
  }
}

class OrderItState extends State<OrderIt> with TickerProviderStateMixin {
  int points = 0;
  int _size = 12;
  int _maxSize = 4;
  List<String> _allLetters = [];
  List<String> _letters = [];
  bool _isLoading = true;
  int cnt = 0;
  int flag = 0;
  bool isUpdate = false;
  AnimationController controller, shakeController;
  Animation<double> animation;
  @override
  void initState() {
    super.initState();
    print('OrderItState:initState');

    if (widget.gameLevel < 4) {
      _maxSize = 5;
    } else if (widget.gameLevel < 7) {
      _maxSize = 7;
    } else {
      _maxSize = 12;
    }
    _initBoard();
  }

  void _initBoard() async {
    controller = new AnimationController(
        duration: new Duration(milliseconds: 800), vsync: this);
    animation = new CurvedAnimation(parent: controller, curve: Curves.easeIn)
      ..addStatusListener((state) {
        print("$state:${animation.value}");
        if (state == AnimationStatus.dismissed) {
          print('dismissed');
        }
      });
    controller.forward();
    flag = 0;
    setState(() => _isLoading = true);
    _allLetters.clear();
    _allLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
    if (_allLetters.length == 7) {
      _maxSize = 7;
    }
    if (_allLetters.length == 12) {
      _maxSize = 12;
    }
    print("Rajesh Patil Data ${_allLetters}");
    _letters = [];
    _letters = _allLetters.sublist(0, _maxSize);
    print("Rajesh Patil Sublisted Data ${_letters}");
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(OrderIt oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _showDialog() {
    points = _allLetters.length;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Hey...!! You Made It"),
          content: new Text("Points : ${points}"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                setState(() {
                  Navigator.of(context).pop();
                  if (widget.iteration == 1) {
                    widget.iteration = 0;
                  } else {
                    widget.iteration = 1;
                  }

                  _initBoard();
                });
              },
            ),
          ],
        );
      },
    );
  }

  ValueNotifier<String> orderNotifier = new ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    print("OrderItState.build");
    if (_isLoading) {
      return new SizedBox(
        width: 20.0,
        height: 20.0,
        child: new CircularProgressIndicator(),
      );
    }

    var hgt = 0.78 * (1 / _letters.length);

    OrderPreview preview = new OrderPreview(orderNotifier: orderNotifier);
    Size gSize = MediaQuery.of(context).size;
    print("Rajesh MediaQuery: ${gSize}");
    return new LayoutBuilder(builder: (context, constraints) {
      print(
          "Constraints.Width:${constraints.maxWidth} Constraints.Height:${constraints.maxHeight}");
      return new Container(
        child:
            new Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          preview,
          new OrderableStack<String>(
              iteration: widget.iteration,
              direction: OrderItDirection.Vertical,
              isRotated: widget.isRotated,
              items: _letters,
              itemSize: constraints.maxWidth > 410.0 &&
                      constraints.maxHeight > 570.0
                  ? new Size(
                      constraints.maxWidth * 0.6, constraints.maxHeight * hgt)
                  : new Size(constraints.maxWidth * 0.4,
                      constraints.maxHeight * hgt * 0.8),
              itemBuilder: itemBuilder,
              onChange: (List<String> orderedList) =>
                  orderNotifier.value = orderedList.toString()),
        ]),
      );
    });
  }

  Widget itemBuilder({Orderable<dynamic> data, Size itemSize}) {
    print("DataIndex: ${data.dataIndex}");
    print("Selected: ${data.selected}");
    print("VisibleIndex: ${data.visibleIndex}");
    print("Value: ${data.value}");
    print("OrderPreview: ${orderNotifier.value}");
    print("flag: $flag");

    if ((orderNotifier.value.compareTo(_letters.toString()) == 0) &&
        flag == 0) {
      flag = 1;
      new Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          _showDialog();
        });
      });
    }

    return new ScaleTransition(
      scale: animation,
      child: new Container(
        key: new Key("orderableDataWidget${data.dataIndex}"),
        decoration: new BoxDecoration(
          border: new Border.all(color: Color(0xffe66796), width: 3.0),
          boxShadow: [
            new BoxShadow(
              color: const Color(0x44000000),
              spreadRadius: 2.0,
              offset: const Offset(0.0, 1.0),
            )
          ],
          borderRadius: new BorderRadius.circular(12.0),
          color: data != null && !data.selected
              ? data.dataIndex == data.visibleIndex ? Colors.lime : Colors.white
              : Colors.orange,
        ),
        width: itemSize.width,
        height: itemSize.height,
        child: new Center(
            child: new Column(children: [
          new Text(
            "${data.value}",
            style: new TextStyle(
                fontSize: itemSize.height * 0.569, color: Color(0xffe66796)),
          )
        ])),
      ),
    );
  }
}

class OrderPreview extends StatefulWidget {
  final ValueNotifier orderNotifier;

  OrderPreview({this.orderNotifier});

  @override
  State<StatefulWidget> createState() => new OrderPreviewState();
}

class OrderPreviewState extends State<OrderPreview> {
  String data = '';

  OrderPreviewState();

  @override
  void initState() {
    super.initState();
    widget.orderNotifier
        .addListener(() => setState(() => data = widget.orderNotifier.value));
  }

  @override
  Widget build(BuildContext context) => new Text(" ");
}
