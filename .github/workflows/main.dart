import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const UravuMaramApp());

class Person {
  Person({required this.id, required this.name, required this.gender,
    this.birthDate, this.fatherId, this.motherId, this.spouseId, this.phone = '', this.notes = ''});
  final String id;
  String name;
  String gender; // ஆண் / பெண் / குறிப்பிடவில்லை
  String? birthDate;
  String? fatherId;
  String? motherId;
  String? spouseId;
  String phone;
  String notes;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'gender': gender,
    'birthDate': birthDate, 'fatherId': fatherId, 'motherId': motherId,
    'spouseId': spouseId, 'phone': phone, 'notes': notes};
  factory Person.fromJson(Map<String, dynamic> j) => Person(
    id: j['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
    name: j['name'] as String? ?? '', gender: j['gender'] as String? ?? 'குறிப்பிடவில்லை',
    birthDate: j['birthDate'] as String?, fatherId: j['fatherId'] as String?,
    motherId: j['motherId'] as String?, spouseId: j['spouseId'] as String?,
    phone: j['phone'] as String? ?? '', notes: j['notes'] as String? ?? '');
}

class UravuMaramApp extends StatelessWidget {
  const UravuMaramApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'உறவு மரம்', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4938E8)), useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF4938E8), foregroundColor: Colors.white)),
    home: const PeoplePage());
}

class PeoplePage extends StatefulWidget { const PeoplePage({super.key}); @override State<PeoplePage> createState() => _PeoplePageState(); }
class _PeoplePageState extends State<PeoplePage> {
  final List<Person> people = [];
  bool loading = true;
  bool loadError = false;
  String query = '';
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(const Duration(seconds: 10));
      final raw = prefs.getString('uravu_people_v1');
      if (raw != null) {
        try {
          people.addAll((jsonDecode(raw) as List).map((e) => Person.fromJson(Map<String, dynamic>.from(e))));
        } catch (_) {
          // Ignore a damaged saved list so the app can still open.
        }
      }
    } catch (_) {
      loadError = true;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
  Future<void> _save() async { final p = await SharedPreferences.getInstance(); await p.setString('uravu_people_v1', jsonEncode(people.map((e) => e.toJson()).toList())); }
  String? _personName(String? id) { if (id == null) return null; for (final p in people) { if (p.id == id) return p.name; } return null; }
  Future<void> _add() async { final result = await Navigator.push<Person>(context, MaterialPageRoute(builder: (_) => PersonForm(allPeople: people))); if (result != null) { setState(() => people.add(result)); await _save(); } }
  Future<void> _edit(Person person) async { final result = await Navigator.push<Person>(context, MaterialPageRoute(builder: (_) => PersonForm(allPeople: people, existing: person))); if (result != null) { final i = people.indexWhere((p) => p.id == result.id); if (i >= 0) setState(() => people[i] = result); await _save(); } }
  Future<void> _delete(Person p) async { final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('உறுப்பினரை நீக்கவா?'), content: Text('${p.name} என்ற நபரை நீக்க விரும்புகிறீர்களா?'), actions: [TextButton(onPressed: () => Navigator.pop(c,false), child: const Text('வேண்டாம்')), FilledButton(onPressed: () => Navigator.pop(c,true), child: const Text('நீக்கு'))])); if (ok == true) { setState(() { people.removeWhere((x) => x.id == p.id); for (final x in people) { if (x.fatherId == p.id) x.fatherId = null; if (x.motherId == p.id) x.motherId = null; if (x.spouseId == p.id) x.spouseId = null; } }); await _save(); } }
  @override Widget build(BuildContext context) {
    final filtered = people.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList()..sort((a,b)=>a.name.compareTo(b.name));
    return Scaffold(appBar: AppBar(title: const Text('உறவு மரம்'), actions: [IconButton(tooltip:'காப்புப் பிரதி தகவல்', onPressed: () => showAboutDialog(context: context, applicationName: 'உறவு மரம்', applicationVersion: '1.0.0', children: const [Text('தற்போதைய பதிப்பு தகவல்களை இந்த மொபைலில் சேமிக்கிறது. App data-ஐ அழித்தால் தகவல்கள் நீங்கலாம். முக்கியமான தகவல்களுக்கு தனியாக backup வைத்துக்கொள்ளவும்.')]), icon: const Icon(Icons.info_outline))]),
      floatingActionButton: FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.person_add_alt_1), label: const Text('உறுப்பினரைச் சேர்')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadError
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, size: 48), const SizedBox(height: 12), const Text('தகவல்களை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.', textAlign: TextAlign.center), const SizedBox(height: 12), FilledButton.icon(onPressed: () { setState(() { loading = true; loadError = false; people.clear(); }); _load(); }, icon: const Icon(Icons.refresh), label: const Text('மீண்டும் முயற்சி'))])))
              : Column(children: [Padding(padding: const EdgeInsets.all(12), child: TextField(onChanged: (v)=>setState(()=>query=v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'பெயரைத் தேடுங்கள்'))), Expanded(child: filtered.isEmpty ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(people.isEmpty ? 'உங்கள் குடும்ப உறுப்பினர்களைச் சேர்க்கத் தொடங்குங்கள்.\n\nகீழே உள்ள “உறுப்பினரைச் சேர்” பொத்தானை அழுத்துங்கள்.' : 'தேடலுக்கு பொருத்தமான பெயர் இல்லை.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium))) : ListView.separated(padding: const EdgeInsets.fromLTRB(12,0,12,88), itemCount: filtered.length, separatorBuilder: (_,__)=>const SizedBox(height:8), itemBuilder: (context,i) { final p=filtered[i]; final details=<String>[]; final f=_personName(p.fatherId), m=_personName(p.motherId), s=_personName(p.spouseId); if(f!=null) details.add('தந்தை: $f'); if(m!=null) details.add('தாய்: $m'); if(s!=null) details.add('துணைவர்: $s'); return Card(child: ListTile(leading: CircleAvatar(child: Icon(p.gender=='பெண்'?Icons.person_2:Icons.person)), title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text([p.gender, if(p.birthDate!=null && p.birthDate!.isNotEmpty) 'பிறந்த தேதி: ${p.birthDate}', ...details].join(' • ')), isThreeLine: details.isNotEmpty, onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_) => PersonDetails(person:p, allPeople:people, onEdit:()=>_edit(p), onDelete:()=>_delete(p)))), trailing: IconButton(icon: const Icon(Icons.edit_outlined), tooltip:'திருத்து', onPressed:()=>_edit(p)))); }))]) );
  }
}

class PersonForm extends StatefulWidget {
  const PersonForm({super.key, required this.allPeople, this.existing});
  final List<Person> allPeople; final Person? existing;
  @override State<PersonForm> createState()=>_PersonFormState();
}
class _PersonFormState extends State<PersonForm> {
  final formKey=GlobalKey<FormState>(); late final TextEditingController nameC, phoneC, notesC, dateC;
  String gender='ஆண்'; String? fatherId, motherId, spouseId;
  @override void initState(){super.initState(); final p=widget.existing; nameC=TextEditingController(text:p?.name??''); phoneC=TextEditingController(text:p?.phone??''); notesC=TextEditingController(text:p?.notes??''); dateC=TextEditingController(text:p?.birthDate??''); gender=p?.gender??'ஆண்'; fatherId=p?.fatherId; motherId=p?.motherId; spouseId=p?.spouseId;}
  @override void dispose(){nameC.dispose();phoneC.dispose();notesC.dispose();dateC.dispose();super.dispose();}
  List<Person> get choices => widget.allPeople.where((p)=>p.id!=widget.existing?.id).toList();
  Widget _personDropdown(String label, String? value, ValueChanged<String?> onChanged){return DropdownButtonFormField<String?>(value:value, isExpanded:true, decoration:InputDecoration(labelText:label), items:[const DropdownMenuItem<String?>(value:null, child:Text('தேர்வு செய்யவில்லை')), ...choices.map((p)=>DropdownMenuItem<String?>(value:p.id, child:Text(p.name, overflow:TextOverflow.ellipsis)))], onChanged:onChanged);}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.existing==null?'புதிய உறுப்பினர்':'விவரங்களைத் திருத்து')), body:Form(key:formKey, child:ListView(padding:const EdgeInsets.all(16), children:[TextFormField(controller:nameC, decoration:const InputDecoration(labelText:'முழுப் பெயர் *', prefixIcon:Icon(Icons.person)), validator:(v)=>v==null||v.trim().isEmpty?'பெயரை உள்ளிடுங்கள்':'', textCapitalization:TextCapitalization.words), const SizedBox(height:12), DropdownButtonFormField<String>(value:gender, decoration:const InputDecoration(labelText:'பாலினம்'), items:const [DropdownMenuItem(value:'ஆண்',child:Text('ஆண்')),DropdownMenuItem(value:'பெண்',child:Text('பெண்')),DropdownMenuItem(value:'குறிப்பிடவில்லை',child:Text('குறிப்பிடவில்லை'))],onChanged:(v)=>setState(()=>gender=v??'குறிப்பிடவில்லை')), const SizedBox(height:12), TextFormField(controller:dateC, decoration:const InputDecoration(labelText:'பிறந்த தேதி (DD-MM-YYYY)', prefixIcon:Icon(Icons.calendar_month)), keyboardType:TextInputType.datetime), const SizedBox(height:12), TextFormField(controller:phoneC, decoration:const InputDecoration(labelText:'தொலைபேசி எண்', prefixIcon:Icon(Icons.phone)), keyboardType:TextInputType.phone), const SizedBox(height:12), _personDropdown('தந்தை',fatherId,(v)=>setState(()=>fatherId=v)), const SizedBox(height:12), _personDropdown('தாய்',motherId,(v)=>setState(()=>motherId=v)), const SizedBox(height:12), _personDropdown('கணவன் / மனைவி',spouseId,(v)=>setState(()=>spouseId=v)), const SizedBox(height:12), TextFormField(controller:notesC, decoration:const InputDecoration(labelText:'குறிப்புகள்', prefixIcon:Icon(Icons.notes)), maxLines:3), const SizedBox(height:24), FilledButton.icon(onPressed:(){if(!formKey.currentState!.validate())return; final old=widget.existing; final p=Person(id:old?.id??DateTime.now().microsecondsSinceEpoch.toString(),name:nameC.text.trim(),gender:gender,birthDate:dateC.text.trim().isEmpty?null:dateC.text.trim(),phone:phoneC.text.trim(),fatherId:fatherId,motherId:motherId,spouseId:spouseId,notes:notesC.text.trim()); Navigator.pop(context,p);}, icon:const Icon(Icons.save), label:const Text('சேமிக்கவும்'))])));
}

class PersonDetails extends StatelessWidget {
  const PersonDetails({super.key,required this.person,required this.allPeople,required this.onEdit,required this.onDelete});
  final Person person; final List<Person> allPeople; final VoidCallback onEdit,onDelete;
  Person? find(String? id){if(id==null)return null; for(final p in allPeople){if(p.id==id)return p;} return null;}
  String relation(Person other){if(other.id==person.fatherId)return 'அப்பா'; if(other.id==person.motherId)return 'அம்மா'; if(other.id==person.spouseId)return person.gender=='ஆண்'?'மனைவி':'கணவர்'; if(other.fatherId==person.id)return other.gender=='ஆண்'?'மகன்':'மகள்'; if(other.motherId==person.id)return other.gender=='ஆண்'?'மகன்':'மகள்'; if(person.fatherId!=null && other.fatherId==person.fatherId && other.id!=person.id)return other.gender=='ஆண்'?'சகோதரர்':'சகோதரி'; if(person.motherId!=null && other.motherId==person.motherId && other.id!=person.id)return other.gender=='ஆண்'?'சகோதரர்':'சகோதரி'; return 'உறவு இணைக்கப்படவில்லை';}
  @override Widget build(BuildContext context){final relatives=allPeople.where((p)=>p.id!=person.id && relation(p)!='உறவு இணைக்கப்படவில்லை').toList(); final father=find(person.fatherId),mother=find(person.motherId),spouse=find(person.spouseId); return Scaffold(appBar:AppBar(title:const Text('உறுப்பினர் விவரம்'),actions:[IconButton(onPressed:onEdit,icon:const Icon(Icons.edit)),IconButton(onPressed:onDelete,icon:const Icon(Icons.delete_outline))]),body:ListView(padding:const EdgeInsets.all(16),children:[Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(children:[CircleAvatar(radius:34,child:Icon(person.gender=='பெண்'?Icons.person_2:Icons.person,size:36)),const SizedBox(height:12),Text(person.name,style:Theme.of(context).textTheme.headlineSmall),Text(person.gender),if(person.birthDate?.isNotEmpty==true)Text('பிறந்த தேதி: ${person.birthDate}'),if(person.phone.isNotEmpty)Text('தொலைபேசி: ${person.phone}')]))),const SizedBox(height:12),Text('குடும்ப உறவுகள்',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:8),_row('தந்தை',father?.name),_row('தாய்',mother?.name),_row(person.gender=='ஆண்'?'மனைவி':'கணவர்',spouse?.name),if(person.notes.isNotEmpty)...[const SizedBox(height:12),Text('குறிப்புகள்',style:Theme.of(context).textTheme.titleMedium),Text(person.notes)],const SizedBox(height:18),Text('அறியப்பட்ட உறவினர்கள்',style:Theme.of(context).textTheme.titleLarge),if(relatives.isEmpty)const Padding(padding:EdgeInsets.all(12),child:Text('உறவுகளைச் சேர்க்க, உறுப்பினரின் விவரங்களைத் திருத்தி தந்தை / தாய் / துணைவர் விவரங்களைத் தேர்வு செய்யுங்கள்.')),...relatives.map((p)=>ListTile(leading:const Icon(Icons.people_outline),title:Text(p.name),subtitle:Text(relation(p))))]));}
  Widget _row(String label,String? value)=>ListTile(leading:const Icon(Icons.family_restroom),title:Text(label),subtitle:Text(value??'பதிவு செய்யப்படவில்லை'));
}
