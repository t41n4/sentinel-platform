import 'package:validatorless/validatorless.dart';

final phoneValidator = Validatorless.multiple([
  Validatorless.required('This field is required'),
  Validatorless.number('Must be a number'),
  Validatorless.min(9, 'Must be at least 10 digits'),
  Validatorless.max(15, 'Must be at most 15 digits'),
]);

final numberValidator = Validatorless.multiple([
  Validatorless.number('false'),
]);

final RegExp textReg = RegExp(r'^[a-zA-Z0-9 ]+$');

final textValidator = Validatorless.multiple([
  Validatorless.regex(textReg, 'Only letters and numbers are allowed'),
  Validatorless.required('This field is required'),
  Validatorless.min(3, 'Must be at least 3 characters'),
  Validatorless.max(70, 'Must be at most 70 characters'),
]);
