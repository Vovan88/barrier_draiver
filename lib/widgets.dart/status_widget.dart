import 'package:barrier_drive/models/answer.dart';
import 'package:barrier_drive/services/service.dart';
import 'package:flutter/material.dart';

class StatusWidget extends StatefulWidget {
  const StatusWidget({Key? key, required this.token}) : super(key: key);

  final String token;
  @override
  State<StatusWidget> createState() => _StatusWidgetState();
}

class _StatusWidgetState extends State<StatusWidget> {
  final ValueNotifier<bool> _valueNotifierOpenStatus = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StreamBuilder<Status>(
            stream: checkStatustream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (snapshot.hasData) {
                return stateBarrier(snapshot.data as Status);
              }

              return const Text("Загрузка...");
            }),
        ValueListenableBuilder<bool>(
            valueListenable: _valueNotifierOpenStatus,
            builder: (_, value, __) {
              return TextButton(
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        value ? Colors.green : Colors.red)),
                onPressed: () {
                  setStatus(widget.token).then(((value) {
                    setState(() {});
                  }));
                },
                child: Text(value ? "Закрыть шлагбаум" : "Открыть шлагбаум"),
              );
            }),
      ],
    );
  }

  Stream<Status> checkStatustream() async* {
    Status status = await getStatus(widget.token);
    _valueNotifierOpenStatus.value = status.status;

    yield status;
    yield* Stream.periodic(
      const Duration(seconds: 10),
      (_) {
        return getStatus(widget.token);
      },
    ).asyncMap((event) async {
      try {
        return await event;
      } catch (e) {
        return Future.error(e);
      }
    });
  }

  Widget stateBarrier(Status status) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: status.status ? Colors.green : Colors.red,
      child: status.status
          ? const Text(
              "Шлагбаум открыт",
              style: TextStyle(color: Colors.white),
            )
          : const Text(
              "Шлагбаум закрыт",
              style: TextStyle(color: Colors.white),
            ),
    );
  }
}
