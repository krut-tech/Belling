class GstState {
  final String code;
  final String name;

  const GstState(this.code, this.name);
}

const List<GstState> kGstStates = [
  GstState('01', 'Jammu & Kashmir'),
  GstState('02', 'Himachal Pradesh'),
  GstState('03', 'Punjab'),
  GstState('04', 'Chandigarh'),
  GstState('05', 'Uttarakhand'),
  GstState('06', 'Haryana'),
  GstState('07', 'Delhi'),
  GstState('08', 'Rajasthan'),
  GstState('09', 'Uttar Pradesh'),
  GstState('10', 'Bihar'),
  GstState('11', 'Sikkim'),
  GstState('12', 'Arunachal Pradesh'),
  GstState('13', 'Nagaland'),
  GstState('14', 'Manipur'),
  GstState('15', 'Mizoram'),
  GstState('16', 'Tripura'),
  GstState('17', 'Meghalaya'),
  GstState('18', 'Assam'),
  GstState('19', 'West Bengal'),
  GstState('20', 'Jharkhand'),
  GstState('21', 'Odisha'),
  GstState('22', 'Chhattisgarh'),
  GstState('23', 'Madhya Pradesh'),
  GstState('24', 'Gujarat'),
  GstState('25', 'Daman & Diu'),
  GstState('26', 'Dadra & Nagar Haveli'),
  GstState('27', 'Maharashtra'),
  GstState('28', 'Andhra Pradesh (Old)'),
  GstState('29', 'Karnataka'),
  GstState('30', 'Goa'),
  GstState('31', 'Lakshadweep'),
  GstState('32', 'Kerala'),
  GstState('33', 'Tamil Nadu'),
  GstState('34', 'Puducherry'),
  GstState('35', 'Andaman & Nicobar Islands'),
  GstState('36', 'Telangana'),
  GstState('37', 'Andhra Pradesh (New)'),
];

String getGstStateName(String code) {
  final state = kGstStates.firstWhere(
    (s) => s.code == code,
    orElse: () => GstState(code, 'State $code'),
  );
  return '${state.name} (${state.code})';
}
