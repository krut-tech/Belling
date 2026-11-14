import 'package:flutter/material.dart';

import 'tr_langs.dart';

/// English text for the Hinglish strings in the app.
///
/// The app is written in Hinglish. When the language is English, every string
/// that has an entry here is shown in English; Hindi / Gujarati keep Hinglish.
/// [tr] / [translateToEnglish] return the input unchanged if nothing matches,
/// so a missing entry can never break a screen.
const Map<String, String> kEnglish = {
  // generic
  // extra Hinglish -> English
  'Total bakaya': 'Total due',
  'Bina bill kiye rate bhejo': 'Send rates without billing',
  'Kahan gaya': 'Where it went',
  'Kaun kya dekh sakta hai': 'Who can see what',
  'Supplier se maal kharido': 'Buy stock from suppliers',
  'Baaki rahega': 'Balance due',
  'Data aur GST records': 'Data and GST records',
  'Saare purane bills - kabhi delete nahi hote': 'All past bills - never deleted',
  'Bill number ya customer ka naam': 'Bill number or customer name',
  'Koi bill nahi mila': 'No bills found',
  'Category chuno': 'Choose category',
  'Nayi category / sub-category ka naam': 'New category / sub-category name',
  'Koi nahi': 'None',
  'Stock badhao': 'Increase stock',
  'Category ka naam badlo': 'Rename category',
  'Is category mein koi item nahi': 'No items in this category',
  'Quantity badhao': 'Increase quantity',
  'UPI QR dikhao': 'Show UPI QR',
  'Koi data nahi': 'No data',
  'Is period me koi credit note nahi': 'No credit notes in this period',
  'Dusre state ka grahak · IGST lagega': 'Customer from another state · IGST applies',
  'Bina party (cash) · CGST + SGST': 'Walk-in (cash) · CGST + SGST',
  'Same state · CGST + SGST': 'Same state · CGST + SGST',
  'Mila (cash+UPI)': 'Received (cash+UPI)',
  'Udhar': 'Credit given',
  'Dena hai': 'To pay',
  'Koi baaki nahi hai': 'Nothing is due',
  'Abhi active': 'Active now',
  'Naam khaali': 'Name is empty',
  'GSTIN galat hai (15 characters, jaise 24ABCDE1234F1Z5)': 'GSTIN is invalid (15 characters, e.g. 24ABCDE1234F1Z5)',
  '(Rates GST ke sath, estimate hai — final bill alag se milega)': '(Rates include GST. This is an estimate; the final bill comes separately.)',
  'Sab': 'All',
  'Hatao': 'Remove',
  'Nahi': 'No',
  'Theek hai': 'OK',
  'Lagao': 'Apply',
  'Baaki': 'Due',
  'Baad mein': 'Later',
  'Update karo': 'Update',
  'Import karo': 'Import',
  'Return karo': 'Return',
  'Kam karo': 'Reduce',
  'Payment karo': 'Pay',
  'Haan, hatao': 'Yes, delete',
  'File chuno': 'Choose file',
  'Stock add karo': 'Add stock',
  'Percent mein': 'As percent',
  // update
  'Naye features aur fixes available hain. Aapka data safe rahega.': 'New features and fixes are available. Your data stays safe.',
  'Kya naya hai:': "What's new:",
  'Browser se download': 'Download in browser',
  'Download nahi hua. Internet check karke dobara try karo.': 'Download failed. Check your internet and try again.',
  'Browser nahi khul paaya.': 'Could not open the browser.',
  'App up to date hai (ya internet nahi hai).': 'App is up to date (or there is no internet).',
  'Install screen nahi khula (': 'Install screen did not open (',
  '"Browser se download" try karo ya Settings mein "Install unknown apps" allow karo.': 'Try "Download in browser" or allow "Install unknown apps" in Settings.',
  // sell / bill
  'Poore bill par discount': 'Discount on whole bill',
  'Ye sab items par barabar (amount ke hisaab se) baant diya jayega. Pehle ke item discount hat jayenge.': 'This is split across all items in proportion to their amount. Earlier item discounts will be removed.',
  'Estimate save karo': 'Save as estimate',
  'Estimate save ho gaya (More > Estimates mein dekho)': 'Estimate saved (see More > Estimates)',
  'Cart khali hai': 'Cart is empty',
  'Item par tap karke bill mein jodo': 'Tap an item to add it to the bill',
  'Quantity kam karo': 'Reduce quantity',
  'Abhi koi item nahi hai. Items tab mein item add karo.': 'No items yet. Add items in the Items tab.',
  'UPI ID set nahi hai. More > Business settings mein UPI ID daalo.': 'UPI ID is not set. Add it in More > Business settings.',
  'Customer scan karke yahi amount pay kare. Payment aane ke baad Issue Invoice dabao.': 'Customer scans and pays this amount. Tap Issue Invoice after the payment arrives.',
  'Discount bill ke amount se zyada nahi ho sakta': 'Discount cannot be more than the bill amount',
  'Maal wapas (return)': 'Return goods',
  'Is bill ka poora maal pehle hi wapas ho chuka hai': 'All goods of this bill have already been returned',
  'Jitna maal wapas aaya wo quantity daalo. Baaki khali chhodo.': 'Enter the quantity that came back. Leave the rest empty.',
  'Return ho gaya. Credit note ban gaya, stock wapas add hua.': 'Return done. Credit note created and stock added back.',
  'Return ki quantity daalo': 'Enter the quantity to return',
  'Karan': 'Reason',
  'Sirf invoice ka return ho sakta hai': 'Only an invoice can be returned',
  'Ye invoice cancel ho chuka hai': 'This invoice is already cancelled',
  // e-invoice
  'Sirf invoice ya credit note': 'Only invoice or credit note',
  'Aapka GSTIN set nahi hai (More > Business settings)': 'Your GSTIN is not set (More > Business settings)',
  'E-invoice sirf B2B (customer ka GSTIN ho) ke liye hota hai': 'E-invoice is only for B2B (customer must have a GSTIN)',
  'Ye file IRP portal (einvoice1.gst.gov.in) par upload karne ke liye hai, Belling khud IRN nahi banata.\n\n': 'This file is for uploading to the IRP portal (einvoice1.gst.gov.in). Belling does not generate the IRN itself.\n\n',
  'Upload se pehle file mein seller/buyer ka PIN code aur location sahi bhar lena ("CHECK ..." wali jagah).': 'Before uploading, fill in the correct seller/buyer PIN code and location in the file (where it says "CHECK ...").',
  'File banao': 'Create file',
  'Pehle apna GSTIN set karo (More > Business settings)': 'Set your GSTIN first (More > Business settings)',
  'File ewaybillgst.gov.in > Bulk generate mein upload karo.': 'Upload the file at ewaybillgst.gov.in > Bulk generate.',
  'Distance aur gaadi number daalo': 'Enter distance and vehicle number',
  'Distance (km)': 'Distance (km)',
  'Gaadi number (MH12AB1234)': 'Vehicle number (MH12AB1234)',
  // purchase / supplier / expense
  'Supplier ka naam daalo': 'Enter the supplier name',
  'Amount 0 se zyada hona chahiye': 'Amount must be more than 0',
  'Kam se kam ek item daalo': 'Add at least one item',
  'Paid amount 0 se bill total ke beech hona chahiye': 'Paid amount must be between 0 and the bill total',
  'Kharcha add karo': 'Add expense',
  'Amount galat hai': 'Amount is invalid',
  'Kharcha (expenses)': 'Expenses',
  'Kharcha': 'Expense',
  'Abhi koi kharcha nahi': 'No expenses yet',
  'Is mahine ka kharcha': 'This month\'s expenses',
  'Item dhundo': 'Search item',
  'Koi item nahi': 'No items',
  'Details set nahi': 'No details set',
  'Kharid rate per unit (₹)': 'Purchase rate per unit (₹)',
  'Quantity ya rate galat hai': 'Quantity or rate is invalid',
  'Paid amount galat hai': 'Paid amount is invalid',
  'Naya purchase': 'New purchase',
  'Koi nahi / cash purchase': 'None / cash purchase',
  'Item add karo': 'Add an item',
  'Item add': 'Add item',
  'Abhi kitna diya (₹)': 'Paid now (₹)',
  'Save ho raha hai...': 'Saving...',
  'Purchase save karo (stock badhega)': 'Save purchase (stock will increase)',
  'Supplier & purchase': 'Suppliers & purchases',
  'Naya supplier': 'New supplier',
  'Naam': 'Name',
  'Abhi koi supplier nahi. Upar se supplier jodo, ya seedha "Naya purchase" dabao.': 'No suppliers yet. Add one from the top, or tap "New purchase" directly.',
  'dena baaki': 'to pay',
  'Clear': 'Clear',
  'Maal kharido, stock badhao, supplier ko kitna dena hai': 'Buy stock, increase inventory, track what you owe suppliers',
  'Bina bill kiye rate bhejo, baad mein bill mein badlo': 'Send rates without billing, convert to a bill later',
  'Rent, salary, bijli ... net munafa mein ghatega': 'Rent, salary, electricity ... deducted from net profit',
  'Sabka baaki ek jagah, WhatsApp par PDF reminder': 'All dues in one place, PDF reminder on WhatsApp',
  'Category, unit aur MRP': 'Category, unit and MRP',
  'Bikri (GST ke bina)': 'Sales (excl. GST)',
  // estimates
  'Koi estimate nahi. Naye bill mein items daalo aur upar wala estimate icon dabao.': 'No estimates yet. Add items in a new bill and tap the estimate icon at the top.',
  'Bill banao': 'Create bill',
  // item picker
  'Item chuno': 'Choose item',
  'Naam ya barcode': 'Name or barcode',
  'Koi item nahi mila': 'No item found',
  // reminders
  'Udhar reminder': 'Payment reminder',
  'Udhar reminders': 'Payment reminders',
  'Roz ka udhar baaki reminder': 'Daily pending-dues reminder',
  'Kisi ka udhar baaki nahi. 🎉': 'Nobody owes you anything. 🎉',
  'Notification ki permission chahiye. Phone Settings > Apps > Belling > Notifications on karo.': 'Notification permission is needed. Turn on Notifications in Phone Settings > Apps > Belling.',
  'Roz ka auto reminder': 'Daily auto reminder',
  'Roz ek notification: kitne logon ka udhar baaki hai': 'One notification every day: how many customers have dues',
  'Kab bhejna hai': 'Send at',
  'Notification ka number app khulne aur band hone par update hota hai. Customer ko message khud nahi jata, aap notification tap karke reminder bhejte ho.': 'The numbers in the notification update when the app opens and closes. Customers are not messaged automatically; you tap the notification to send the reminder.',
  // staff
  'Owner (sab kuch)': 'Owner (everything)',
  'Manager (bill, items, reports)': 'Manager (bills, items, reports)',
  'Cashier (sirf bill)': 'Cashier (billing only)',
  'Accountant (sirf dekhna)': 'Accountant (view only)',
  'Ye email Belling mein sign-in nahi hui. Unhe pehle ek baar apne email se login karne bolo.': 'This email has not signed in to Belling. Ask them to log in once with this email first.',
  'Ye kaam sirf owner kar sakta hai.': 'Only the owner can do this.',
  'Aapko staff list dekhne ki permission nahi hai.': 'You do not have permission to view the staff list.',
  'Pehle More > Backup & Sync mein sign in karo.': 'Sign in first (More > Backup & Sync).',
  'Staff add karo': 'Add staff',
  'Staff add': 'Add staff',
  'Unhe pehle ek baar Belling mein isi email se login karna hoga.': 'They must log in to Belling once with this email first.',
  'Staff hatao?': 'Remove staff?',
  'Unka email': 'Their email',
  'Staff & roles': 'Staff & roles',
  'Cashier / manager / accountant access': 'Cashier / manager / accountant access',
  // import
  'PIN 4 se 6 digits ka hona chahiye': 'PIN must be 4 to 6 digits',
  'File khaali hai': 'The file is empty',
  'Pehli line mein "name" aur "price" column zaroori hain (sample CSV dekho)': 'The first line must have "name" and "price" columns (see the sample CSV)',
  'Sample file nahi ban payi: ': 'Could not create the sample file: ',
  'File padhi nahi ja saki. Dobara try karo.': 'Could not read the file. Try again.',
  'barcode pehle se hai': 'barcode already exists',
  'Import ho gaya': 'Import complete',
  'Saare items ek saath daalo. Excel mein banao aur "CSV" save karo. Columns: name, barcode, hsn, gst_percent, price, cost, stock, reorder_level.': 'Add all items at once. Make it in Excel and save as "CSV". Columns: name, barcode, hsn, gst_percent, price, cost, stock, reorder_level.',
  // stock adjust
  'Sahi quantity daalo (0 se zyada)': 'Enter a valid quantity (more than 0)',
  'Kitna maal aaya?': 'How much stock came in?',
  'Kitna kam karna hai? (kharab / kho gaya)': 'How much to reduce? (damaged / lost)',
  // scanner
  'Camera permission band hai. Phone Settings > Apps > belling > Permissions me Camera allow karo.': 'Camera permission is off. Allow Camera in Phone Settings > Apps > belling > Permissions.',
  'Camera dobara try karo': 'Retry camera',
  'Barcode ko frame ke andar rakho': 'Keep the barcode inside the frame',
  // pin / lock
  '4 se 6 digits': '4 to 6 digits',
  'Naya PIN': 'New PIN',
  'PIN dobara daalo': 'Enter PIN again',
  'Dono PIN alag hain': 'The two PINs do not match',
  'PIN set ho gaya. App background se wapas aane par PIN maangega.': 'PIN set. The app will ask for it when you return from the background.',
  'Abhi ka PIN': 'Current PIN',
  'Galat PIN': 'Wrong PIN',
  'App lock hata diya': 'App lock removed',
  'Dukaan ka phone kisi ke haath mein jaye to bills aur udhar ka data safe rahe. PIN sirf is phone mein rehta hai.': 'Keeps your bills and dues safe if someone else uses your phone. The PIN stays on this phone only.',
  'PIN lagao': 'Set PIN',
  'PIN badlo': 'Change PIN',
  'PIN daalo': 'Enter PIN',
  // sync
  'Aapki shop ki details account se aa gayi (name, GST, UPI...)': 'Your shop details were restored from your account (name, GST, UPI...)',
  'Google sign-in poora nahi hua. Dobara try karo.': 'Google sign-in did not complete. Try again.',
  'Done. Aapka sab data (bills, items, parties) account se jud gaya.': 'Done. All your data (bills, items, parties) is now linked to your account.',
  'Data rakho aur jodo (Merge)': 'Keep my data and link it (Merge)',
  'Is phone ka data hataye?': 'Delete this phone\'s data?',
  'WARNING: Is phone ke saare bills, items aur parties DELETE ho jayenge. ': 'WARNING: All bills, items and parties on this phone will be DELETED. ',
  'Ye kabhi wapas nahi aayega. Agar bills rakhne hain to "Nahi" dabao aur "Merge" chuno.': 'This can never be undone. To keep your bills, tap "No" and choose "Merge".',
  'Local data hatao': 'Delete local data',
  'Pehle sign in karo (More > Backup & Sync)': 'Sign in first (More > Backup & Sync)',
  'Theek kar diya. Sync dobara chal raha hai.': 'Fixed. Sync is running again.',
  'Auto fix': 'Auto fix',
  // dues
  'Scan karke': 'Scan and pay',
  'UPI ID set nahi hai, isliye QR nahi banega. More > Business settings mein UPI ID daalo.': 'UPI ID is not set, so no QR will be made. Add it in More > Business settings.',
  'Customer ko ek PDF jaayega: har bill ke items, paid / baaki, total aur UPI QR. ': 'The customer gets one PDF: items of each bill, paid / due, total and a UPI QR. ',
  'WhatsApp pe PDF bhejo': 'Send PDF on WhatsApp',
  'Bakaya reminder bhejo': 'Send payment reminder',
  'GSTR-1 export (CA ke liye)': 'GSTR-1 export (for your CA)',
  // reports
  'Munafa (profit)': 'Profit',
  'Net munafa': 'Net profit',
  'Margin': 'Margin',
};

/// Patterns for strings that contain values (names, amounts, counts).
final List<(RegExp, String)> _patterns = [
  (RegExp(r'^(.*): sirf (.*) wapas ho sakta hai$'), r'$1: only $2 can be returned'),
  (RegExp(r'^(.*): quantity 0 se zyada honi chahiye$'), r'$1: quantity must be more than 0'),
  (RegExp(r'^(.*): cost galat hai$'), r'$1: cost is invalid'),
  (RegExp(r'^(.*): quantity galat hai$'), r'$1: quantity is invalid'),
  (RegExp(r'^"(.*)": price galat ya khaali$'), r'"$1": price is invalid or empty'),
  (RegExp(r'^"(.*)": cost galat$'), r'"$1": cost is invalid'),
  (RegExp(r'^"(.*)": GST % galat$'), r'"$1": GST % is invalid'),
  (RegExp(r'^"(.*)": GST (.*)% allowed nahi (.*)$'), r'"$1": GST $2% is not allowed $3'),
  (RegExp(r'^"(.*)": stock galat$'), r'"$1": stock is invalid'),
  (RegExp(r'^"(.*)": reorder level galat$'), r'"$1": reorder level is invalid'),
  (RegExp(r'^"(.*)": barcode (.*) file mein dobara aaya$'), r'"$1": barcode $2 appears again in the file'),
  (RegExp(r'^(\d+) logon ka (.*) udhar baaki hai\. Tap karke reminder bhejo\.$'), r'$1 customers owe $2 in total. Tap to send reminders.'),
  (RegExp(r'^(\d+) log ka udhar baaki$'), r'$1 customers have dues'),
  (RegExp(r'^Khali chhodo = poora (.*) diya$'), r'Leave empty = paid in full ($1)'),
  (RegExp(r'^Kul kharid (.*) · diya (.*)$'), r'Total purchased $1 · paid $2'),
  (RegExp(r'^Abhi stock: (.*)$'), r'Current stock: $1'),
  (RegExp(r'^Import nahi hua: (.*)$'), r'Import failed: $1'),
  (RegExp(r'^(\d+) items add hue\.$'), r'$1 items added.'),
  (RegExp(r'^(\d+) skip hue:$'), r'$1 skipped:'),
  (RegExp(r'^\.\.\. aur (\d+)$'), r'... and $1 more'),
  (RegExp(r'^Merge nahi hua: (.*)$'), r'Merge failed: $1'),
  (RegExp(r'^Switch nahi hua: (.*)$'), r'Switch failed: $1'),
  (RegExp(r'^Account ka business "(.*)" use ho raha hai$'), r'Now using your account business "$1"'),
  (RegExp(r'^Auto fix nahi hua: (.*)$'), r'Auto fix failed: $1'),
  (RegExp(r'^PDF nahi ban paya: (.*)$'), r'Could not create the PDF: $1'),
  (RegExp(r'^Data load nahi hua: (.*)$'), r'Could not load data: $1'),
  (RegExp(r'^(.*) ka koi bakaya nahi hai$'), r'$1 has no dues'),
  (RegExp(r'^Scan karke (.*) pay karo$'), r'Scan to pay $1'),
  (RegExp(r'^Button dabane par WhatsApp chuno, phir (.*) select karo\.$'), r'Tap the button, choose WhatsApp, then select $1.'),
  (RegExp(r'^Bill ka amount \(GST se pehle\): (.*)$'), r'Bill amount (before GST): $1'),
  (RegExp(r'^Maal ki cost: (.*) \(item ki abhi ki cost price se\)\. Kharcha: (.*)\. Net munafa = bikri − maal ki cost − kharcha\.$'),
    r'Cost of goods: $1 (from current item cost prices). Expenses: $2. Net profit = sales − cost of goods − expenses.'),
  (RegExp(r'^Download ho raha hai\.\.\. (.*)$'), r'Downloading... $1'),
  (RegExp(r'^Naya update (.*)$'), r'New update $1'),
  (RegExp(r'^(.*) ka access band ho jayega\.$'), r'$1 will lose access.'),
  (RegExp(r'^(.*) ko payment$'), r'Payment to $1'),
  (RegExp(r'^Install screen nahi khula \((.*)\)\. $'), r'Install screen did not open ($1). '),
];

const _errorPrefixes = ['Invalid argument(s): ', 'Bad state: ', 'Exception: ', 'StateError: '];

/// English version of [s] (unchanged when there is no translation).
String translateToEnglish(String s) {
  final direct = kEnglish[s];
  if (direct != null) return direct;
  for (final p in _errorPrefixes) {
    if (s.startsWith(p)) {
      final rest = s.substring(p.length);
      final t = translateToEnglish(rest);
      return t == rest ? s : t;
    }
  }
  for (final (re, rep) in _patterns) {
    final m = re.firstMatch(s);
    if (m != null) {
      return rep.replaceAllMapped(RegExp(r'\$(\d)'), (g) => m.group(int.parse(g.group(1)!)) ?? '');
    }
  }
  // Long messages that contain a known sentence (e.g. "... Dobara try karo.").
  for (final e in kEnglish.entries) {
    if (e.key.length >= 24 && s.contains(e.key)) return s.replaceAll(e.key, e.value);
  }
  return s;
}

bool isEnglish(BuildContext context) => Localizations.localeOf(context).languageCode == 'en';

/// Translated text for [hinglish] in the current language.
///
/// English: Hinglish -> English. Hindi / Gujarati: looked up by the English
/// text (or by the string itself when it is already English). Anything
/// without a translation is returned unchanged.
String tr(BuildContext context, String hinglish) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'en') return translateToEnglish(hinglish);
  if (code == 'hi' || code == 'gu') {
    final dict = code == 'hi' ? kHindi : kGujarati;
    return dict[hinglish] ?? dict[kEnglish[hinglish]] ?? hinglish;
  }
  return hinglish;
}
