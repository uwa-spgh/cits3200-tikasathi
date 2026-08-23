typedef GeneratedDue = ({
  String vaccineCode,
  int doseNumber,
  DateTime dueDate,
});

typedef AdministeredDose = ({
  String vaccineCode,
  int doseNumber,
  DateTime administeredDate,
});

typedef GenerateDues = List<GeneratedDue> Function(
  DateTime dob,
  DateTime today,
  List<AdministeredDose> records,
);

List<GeneratedDue> generate(
  DateTime dob,
  DateTime today,
  List<AdministeredDose> records,
) {
  throw UnimplementedError('generate has not been implemented yet');
}
