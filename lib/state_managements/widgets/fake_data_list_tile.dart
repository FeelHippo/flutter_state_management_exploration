part of '../../main.dart';

class FakeDataListTile extends StatelessWidget {
  const FakeDataListTile({
    super.key,
    required this.fakeData,
    required this.source,
  });

  final FakeData fakeData;
  final String source;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(source),
      ),
      title: Text(fakeData.person.name()),
      subtitle: Text(
          '${fakeData.vehicle.model()} is worth ${Random().nextInt(100000)} ${fakeData.currency.code()}'),
    );
  }
}
