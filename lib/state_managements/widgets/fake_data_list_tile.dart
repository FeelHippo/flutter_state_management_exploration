part of '../../main.dart';

class FakeDataListTile extends StatelessWidget {
  const FakeDataListTile({
    super.key,
    required this.fakeData,
  });

  final FakeData fakeData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(fakeData.person.name()),
      subtitle: Text(
          '${fakeData.vehicle.model()} is worth ${Random().nextInt(100000)} ${fakeData.currency.code()}'),
    );
  }
}
