import 'package:flutter/material.dart';
import 'package:truckchecklist/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TruckCheckListScreen extends StatefulWidget {
  const TruckCheckListScreen({super.key});

  @override
  State<TruckCheckListScreen> createState() => _TruckCheckListScreenState();
}

class _TruckCheckListScreenState extends State<TruckCheckListScreen> {
  final List<bool> _checkListValues = List.generate(11, (index) => false);

  final List<String> _checkListTexts = [
    'Grab Route Book With Your Truck Number And Put It In Truck',
    'Start Truck & Back Motor(Keep Running While You Run Through The Rest Of The List)',
    'Check All Fluids: Coolant, Engine Oil(Truck & Back Motor), Mixed Gas(Blowers)',
    'Check To Make Sure Back Motor Starts And Runs Without Shutting Off',
    'Start Blowers & Any Power Equipment To Ensure They Are Good For Service',
    'Check Tire Pressure & Air Bags',
    'Ensure Power Equipment Is In The Back Of The Truck, And Secured Properly',
    'Ensure Grabbers, Bucket, Trash Bags, Gloves, Head Lamp, Etc. Are In Truck',
    'Check The Dash Of The Truck And Notate Any Lights On(In Notes Section At Bottom)',
    'Check Head Assembly To Make Sure There Is No Damage And It Is Good For Service',
    'Test The Functionality Of The Hopper, Head, And All Switches Used For Service',
  ];

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _truckNumberController = TextEditingController();
  final TextEditingController _routeNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  late Future<Map<String, dynamic>> employeeInfo;

  @override
  void initState() {
    super.initState();
    employeeInfo = _getEmployeeInfo();
  }

  Future<Map<String, dynamic>> _getEmployeeInfo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('employees')
            .doc(user.uid)
            .get();
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      debugPrint('Error fetching employee info: $e');
      return {};
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _submitChecklist() async {
  try {
    // Fetch the current user's UID
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the employeeCompanyId and username from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('employees')
        .doc(userId)
        .get();

    if (!userDoc.exists ||
        userDoc.data() == null ||
        !(userDoc.data() as Map).containsKey('employeeCompanyId')) {
      throw Exception("employeeCompanyId not found for the current user");
    }

    String employeeCompanyId = userDoc['employeeCompanyId'];
    String employeeUserName = userDoc['username'];

    // Prepare checklist data
    List<Map<String, dynamic>> checklistResponses = [];
    for (int i = 0; i < _checkListValues.length; i++) {
      checklistResponses.add({
        'text': _checkListTexts[i],
        'checked': _checkListValues[i],
      });
    }

    final truckChecklistData = {
      'date':
          _dateController.text.isNotEmpty ? _dateController.text : 'No Date',
      'truckNumber': _truckNumberController.text.isNotEmpty
          ? _truckNumberController.text
          : 'No Truck #',
      'routeNumber': _routeNumberController.text.isNotEmpty
          ? _routeNumberController.text
          : 'No Route #',
      'checkList': checklistResponses,
      'notes': _notesController.text.isNotEmpty
          ? _notesController.text
          : 'No Notes',
      'employeeCompanyId': employeeCompanyId,
      'employeeUserName': employeeUserName,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Reference to the Firestore collection
    CollectionReference truckChecklists =
        FirebaseFirestore.instance.collection('TruckCheckList');

    // Query to check for an existing document
    QuerySnapshot querySnapshot = await truckChecklists
        .where('date', isEqualTo: _dateController.text)
        .where('truckNumber', isEqualTo: _truckNumberController.text)
        .where('employeeCompanyId', isEqualTo: employeeCompanyId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Update the existing document
      await truckChecklists
          .doc(querySnapshot.docs.first.id)
          .update(truckChecklistData);
    } else {
      // Add a new document if none exists
      await truckChecklists.add(truckChecklistData);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checklist submitted successfully!')),
    );

    // Clear form
    setState(() {
      _dateController.clear();
      _truckNumberController.clear();
      _routeNumberController.clear();
      _notesController.clear();
      for (int i = 0; i < _checkListValues.length; i++) {
        _checkListValues[i] = false;
      }
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error submitting checklist: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: employeeInfo,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No employee data found.'));
                  } else {
                    final employeeData = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '${employeeData['username'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 50, fontFamily: 'NexaBold'),
                      ),
                    );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/GA-FLA-Logo.png',
                  height: 200,
                  width: 200,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Truck Checklist:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Date'),
                  ),
                ),
              ),
              TextField(
                controller: _truckNumberController,
                decoration: const InputDecoration(labelText: 'Truck #'),
              ),
              TextField(
                controller: _routeNumberController,
                decoration: const InputDecoration(labelText: 'Route #'),
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < _checkListTexts.length; i++) ...[
                CheckboxListTile(
                  title: Text(_checkListTexts[i]),
                  value: _checkListValues[i],
                  onChanged: (bool? value) {
                    setState(() {
                      _checkListValues[i] = value ?? false;
                    });
                  },
                ),
                const Divider(),
              ],
              const SizedBox(height: 20),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Enter any notes here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(250, 50),
                  backgroundColor: primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: _submitChecklist,
                label: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                icon: const Icon(
                  Icons.upload,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
