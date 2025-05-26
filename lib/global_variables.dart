import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/hmo_model.dart';
import 'package:universal_html/html.dart';

GlobalKey<ScaffoldState> doctor_profile_key = GlobalKey();

String server_url = 'http://192.168.1.111:5500';
// String server_url = 'http://localhost:5500';

// ! DB ROUTES
String clinicUrl = '${server_url}/api/clinic';
String userUrl = '${server_url}/api/user';
String salesUrl = '${server_url}/api/sales';
String universalUrl = '${server_url}/api/universal';
String authUrl = '${server_url}/api/auth';

// app role
List<String> app_roles = [
  'Admin',
  'CSU',
  'Doctor',
  'Management',
  'Marketer',
  'ICT',
  'None',
];

String app_role = '';

// doctor & staff model
// DoctorModel? active_doctor;
// StaffModel? active_staff;

// force doctor logout
int doctor_force_logout = 0;

// global key for drawer
final GlobalKey<ScaffoldState> global_key = GlobalKey();

// news for staff sign in
String news = '';

// hmos
List<HMO_Model> gym_hmo = [];
List<String> physio_hmo = [
  'THT',
  'Redcare',
  'Reliance',
  'Hygeia',
  'AXA',
];

// how you heard about us
List<String> hykau_options = [
  'Instagram',
  'Facebook',
  'From a friend',
  'From a client',
  'Our Website',
  'Billboard',
  'Referral',
  'Others',
];

// occupation option
List<String> occupation_options = [
  'Employed',
  'Self-Employed',
  'Retired',
  'Student',
  'Others',
];

// gym program type
List<String> program_type_options = ['Private', 'Corporate', 'Promotion'];
List<String> corporate_type_options = ['Company', 'HMO'];

// physio treatment duration
List<String> treatment_time = [
  '30 Mins',
  '45 Mins',
  '1 Hr',
  '1 Hr 30 Mins',
  '1 Hr 45 Mins',
  '2 Hr',
];

List<String> case_select_options = [
  'Rheumatoid Arthritis (RA)',
  'Osteoarthritis (Knee/Hip/Shoulder)',
  'Bilateral Knee OA',
  'Cervical Pain',
  'Septic Arthritis',
  'Hemiparesis',
  'Paraparesis',
  'Monoparesis',
  'Quadriparesis',
  'Partial Stroke / TIA',
  'Complete Stroke / Hemiplegia',
  'Parkinson\'s Disease',
  'Cerebral Palsy',
  'Injection Neuritis',
  'Sacroiliac Join Dysfunction',
  'Lumbar Spondylosis',
  'Lumbar Spondylolisthesis',
  'Cervical Spondylosis',
  'Herniated disc',
  'Soft tissue disorders',
  'Lower limb fracture',
  'Upper limb fracture',
  'Dislocation',
  'Peripheral Nerve lesion',
  'Facet Joint Syndrome',
  'Spinal Stenosis',
  'Lumbar Stenosis',
  'Shoulder Joint Pain',
  'Frozen Shoulder',
  'Shoulder Impingement Syndrome',
  'Ankle Joint dysfunction',
  'Low Back Pain',
  'Neck Pain'
      'Hip dysfunction',
];

List<String> case_type_options = [
  'Orthopaedic',
  'Neurological',
  'Geriatric',
  'Pediatric',
  'O/G',
  'Ortho-Neuro',
  'Cardiopulmonary',
  'Ergonomics',
  'Sports',
  'Women\'s Health',
];

List<String> treatment_type_options = [
  'Out Patient',
  'Home Treatment',
  'Hospital Treatment'
];

List<String> equipment_options = [
  'TENS',
  'EMS',
  'Ultrasound',
  'Infra-red',
  'Wax Bath',
  'Electronic Massager',
  'Shoulder Wheel',
  'Finger Ladder',
  'Staircase',
  'Bicycle Ergometer',
  'Treadmill',
  'Hand dynamometer',
  'Lumbar Traction Machine',
  '*Cervical Traction Machine',
  'Reciprocal Pulley',
  '*Shortwave Diathermy',
  '*Microwave',
  '*Shockwave machine',
  '*Laser machine',
  '*Interferential Current machine',
];

List<String> assessment_decision_select_options = [
  'Start Treatment',
  'Booked for Treatment',
  'Refer',
  'Others',
  'Not a Physio Patient'
];
List<String> treatment_decision_select_options = [
  'Continue Treatment',
  'End Treatment',
  'Could not treat patient',
  'Patient not Responsive',
  'Refer',
  'Others',
];

List<String> decision_refered_options = [
  'Orthopedic',
  'Phycisian',
  'Diagnosis',
  'X-ray'
];

// base url
String indemnity_base_url =
    window.location.href; // 'https://heritageuseragreement.web.app/';
String indemnity_replace_url = 'https://heritagefitnesscentre.com/';

// gym sign in notification height
ValueNotifier<double> notification_height = ValueNotifier(0);

// custom context for notification
BuildContext? custom_context;

// send notification
bool send_notification = true;

// last ID for each user
int last_ft_id = 0;
int last_pt_id = 0;
int last_st_id = 0;

// after fetching last from db
bool is_loaded = false;

int standard_pt = 15000;
int premium_pt = 30000;
int boxing_fee = 15000;
int registration_value = 5000;

String indemnity_write_up =
    "I, the undersigned, hereby agree to the following terms and conditions as a user of the gym:\n\n1. Rules and Regulations:\n\nI agree to abide by all posted rules and regulations of the gym, including but not limited to proper use of equipment, following staff instructions, and respecting other gym users.\nI understand that failure to comply with these rules may result in the termination of my membership without refund.\n\n2. Release of Liability:\n\nI understand that participating in physical activity at the gym carries inherent risks, and I release Heritage Fitness & Wellness Centre and its staff from any liability for injury or damage resulting from my use of the facility.\nI agree to indemnify and hold harmless Heritage Fitness & Wellness Centre from any claims, injuries, or damages arising from my use of the gym facilities.\n\n3. Membership Fees:\n\nI agree to pay all membership fees in a timely manner as outlined in my membership agreement.\nI understand that failure to pay fees may result in the suspension or termination of my membership.\n\n4. Personal Belongings:\n\nI understand that Heritage Fitness & Wellness Centre is not responsible for any lost or stolen personal belongings, and I agree to take necessary precautions to secure my items while at the gym.\n\nAcknowledgement:\nBy checking the box below, I acknowledge that I have read and understand the terms and conditions outlined in this user agreement indemnity form. I agree to abide by all rules and regulations of Heritage Fitness & Wellness Centre and release the gym from any liability for injury or damage resulting from my use of the facilities.";

// app current version
String current_version = '1.3.0';

// flutter build web --web-renderer html
