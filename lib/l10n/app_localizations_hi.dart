// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'यूनिवर्सल बिलिंग';

  @override
  String get tabSell => 'बिक्री';

  @override
  String get tabItems => 'सामान';

  @override
  String get tabParties => 'पार्टी';

  @override
  String get tabReports => 'रिपोर्ट';

  @override
  String get tabMore => 'अधिक';

  @override
  String get language => 'भाषा';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get hindi => 'हिंदी';

  @override
  String get gujarati => 'गुजराती';

  @override
  String get items => 'सामान';

  @override
  String get addItem => 'सामान जोड़ें';

  @override
  String get editItem => 'सामान संपादित करें';

  @override
  String get searchItems => 'नाम या बारकोड से खोजें...';

  @override
  String get noItemsFound => 'कोई सामान नहीं मिला';

  @override
  String get noItemsSub => 'पहला सामान जोड़ने के लिए \'+\' दबाएं।';

  @override
  String get itemName => 'सामान का नाम';

  @override
  String get barcode => 'बारकोड';

  @override
  String get scanBarcode => 'स्कैन';

  @override
  String get typeOrScanBarcode => 'बारकोड टाइप या स्कैन करें...';

  @override
  String get hsn => 'एचएसएन कोड';

  @override
  String get gstRate => 'जीएसटी दर';

  @override
  String get sellingPrice => 'बिक्री मूल्य (₹)';

  @override
  String get costPrice => 'लागत मूल्य (₹)';

  @override
  String get trackStock => 'स्टॉक ट्रैक करें';

  @override
  String get openingStock => 'प्रारंभिक स्टॉक';

  @override
  String get reorderLevel => 'रीऑर्डर स्तर';

  @override
  String get lowStock => 'कम';

  @override
  String get stock => 'स्टॉक';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get archive => 'आर्काइव';

  @override
  String get confirmArchive => 'क्या आप इस सामान को आर्काइव करना चाहते हैं?';

  @override
  String get nameRequired => 'सामान का नाम आवश्यक है';

  @override
  String get priceRequired => 'मान्य कीमत आवश्यक है';

  @override
  String get duplicateBarcode => 'यह बारकोड किसी अन्य सामान के लिए मौजूद है';

  @override
  String get cameraNotAvailable => 'इस डिवाइस पर कैमरा उपलब्ध नहीं है';

  @override
  String get scanTitle => 'बारकोड स्कैन करें';

  @override
  String get newBill => 'नया बिल';

  @override
  String get todayBills => 'आज के बिल';

  @override
  String get noBillsToday => 'आज कोई बिल जारी नहीं हुआ';

  @override
  String get searchOrScan => 'सामान खोजें या बारकोड स्कैन करें...';

  @override
  String get itemNotFound => 'सामान नहीं मिला';

  @override
  String get itemNotFoundAddPrompt =>
      'सामान नहीं मिला। क्या आप इसे जोड़ना चाहते हैं?';

  @override
  String get add => 'जोड़ें';

  @override
  String get walkIn => 'वॉका-इन';

  @override
  String get selectParty => 'पार्टी चुनें';

  @override
  String get addParty => 'पार्टी जोड़ें';

  @override
  String get phone => 'फोन नंबर';

  @override
  String get gstin => 'जीएसटीइन';

  @override
  String get state => 'राज्य';

  @override
  String get interState => 'अंतर-राज्यीय (IGST)';

  @override
  String get intraState => 'राज्य के भीतर (CGST + SGST)';

  @override
  String get qty => 'मात्रा';

  @override
  String get rate => 'दर';

  @override
  String get discount => 'छूट (₹)';

  @override
  String get lineTotal => 'कुल';

  @override
  String get taxableAmount => 'करयोग्य राशि';

  @override
  String get cgst => 'CGST';

  @override
  String get sgst => 'SGST';

  @override
  String get igst => 'IGST';

  @override
  String get roundOff => 'राउंड ऑफ';

  @override
  String get grandTotal => 'कुल योग';

  @override
  String get paymentMethod => 'भुगतान का तरीका';

  @override
  String get cash => 'नकद';

  @override
  String get upi => 'यूपीआई';

  @override
  String get card => 'कार्ड';

  @override
  String get credit => 'उधार (बाद में भुगतान)';

  @override
  String get paidAmount => 'भुगतान की गई राशि (₹)';

  @override
  String get unpaidBalance => 'बकाया राशि (₹)';

  @override
  String get issueInvoice => 'बिल जारी करें';

  @override
  String get partyRequiredForCredit =>
      'उधार या बकाया राशि के लिए पार्टी आवश्यक है';

  @override
  String get cartEmpty => 'कार्ट खाली है';

  @override
  String get invoiceIssued => 'बिल जारी किया गया';

  @override
  String get invoiceNumber => 'बिल संख्या';

  @override
  String get share => 'शेयर';

  @override
  String get sharePlaceholder => 'शेयर की सुविधा जल्द आ रही है';

  @override
  String get cancelInvoice => 'बिल रद्द करें';

  @override
  String get cancellationReason => 'रद्द करने का कारण';

  @override
  String get reasonRequired => 'कारण आवश्यक है';

  @override
  String get confirmCancelInvoice =>
      'क्या आप वाकई इस बिल को रद्द करना चाहते हैं?';

  @override
  String get invoiceCancelled =>
      'बिल रद्द कर दिया गया और क्रेडिट नोट जारी किया गया';

  @override
  String get statusCancelled => 'रद्द';

  @override
  String get statusIssued => 'जारी';

  @override
  String get editParty => 'पार्टी संपादित करें';

  @override
  String get partyDetails => 'पार्टी विवरण';

  @override
  String get totalReceivable => 'कुल प्राप्त्य';

  @override
  String youGet(String amount) {
    return 'आपको मिलेगा $amount';
  }

  @override
  String youGive(String amount) {
    return 'आपको देना है $amount';
  }

  @override
  String get settled => 'बराबर (Settled)';

  @override
  String get receivePayment => 'भुगतान प्राप्त करें';

  @override
  String get sendReminder => 'रिमाइंडर भेजें';

  @override
  String get creditLimit => 'क्रेडिट सीमा (₹)';

  @override
  String get creditLimitExceeded => 'क्रेडिट सीमा समाप्त';

  @override
  String creditLimitWarningMsg(String name, String limit, String newBalance) {
    return '$name की क्रेडिट सीमा $limit है। नया बकाया $newBalance होगा। क्या आप आगे बढ़ना चाहते हैं?';
  }

  @override
  String get proceedAnyway => 'फिर भी जारी रखें';

  @override
  String get paymentReceived => 'भुगतान प्राप्त हुआ';

  @override
  String get amount => 'राशि (₹)';

  @override
  String get date => 'दिनांक';

  @override
  String get note => 'टिप्पणी';

  @override
  String get optionalNote => 'टिप्पणी (वैकल्पिक)';

  @override
  String get allocateToDocument => 'बिल में जोड़ें (वैकल्पिक)';

  @override
  String get none => 'कोई नहीं';

  @override
  String get ledger => 'खाता बही (Ledger)';

  @override
  String get noTransactions => 'कोई लेनदेन नहीं मिला';

  @override
  String runningBalance(String amount) {
    return 'बकाया: $amount';
  }

  @override
  String get payment => 'भुगतान';

  @override
  String get creditNote => 'क्रेडिट नोट';

  @override
  String get invoice => 'बिल';

  @override
  String get searchParties => 'नाम या फोन से पार्टी खोजें...';

  @override
  String get noPartiesFound => 'कोई पार्टी नहीं मिली';

  @override
  String get noPartiesSub => 'अपनी पहली पार्टी जोड़ने के लिए \'+\' दबाएं।';

  @override
  String get balance => 'बकाया';

  @override
  String get dateRangeToday => 'आज';

  @override
  String get dateRangeYesterday => 'कल';

  @override
  String get dateRangeThisWeek => 'इस सप्ताह';

  @override
  String get dateRangeThisMonth => 'इस महीने';

  @override
  String get dateRangeLastMonth => 'पिछले महीने';

  @override
  String get dateRangeThisFinancialYear => 'इस वित्तीय वर्ष';

  @override
  String get dateRangeCustom => 'कस्टम';

  @override
  String get salesTotal => 'कुल बिक्री';

  @override
  String get numberOfBills => 'बिल की संख्या';

  @override
  String get creditGiven => 'दिया गया उधार';

  @override
  String get paymentsReceived => 'प्राप्त भुगतान';

  @override
  String get cashPayments => 'नकद';

  @override
  String get upiPayments => 'यूपीआई';

  @override
  String get cardPayments => 'कार्ड';

  @override
  String get top10ItemsByAmount => 'राशि के अनुसार शीर्ष 10 सामान';

  @override
  String get top10ItemsByQty => 'मात्रा के अनुसार शीर्ष 10 सामान';

  @override
  String get lowStockList => 'कम स्टॉक सूची';

  @override
  String get receivablesTop10 => 'शीर्ष 10 प्राप्त्य';

  @override
  String get gstSummary => 'जीएसटी विवरण';

  @override
  String get b2bSection => 'B2B बिक्री (पंजीकृत)';

  @override
  String get b2cSection => 'B2C बिक्री (अपंजीकृत/खुदरा)';

  @override
  String get gstRateHeader => 'जीएसटी दर';

  @override
  String get taxableHeader => 'करयोग्य मूल्य';

  @override
  String get totalTaxHeader => 'कुल कर';

  @override
  String get totalsMismatchBanner =>
      'चेतावनी: दस्तावेज़ के योग और लाइनों के योग मेल नहीं खाते!';

  @override
  String get totalsMatchCheck => 'योग जांच सफल';

  @override
  String get exportCsv => 'सीएसवी निर्यात करें';

  @override
  String get exportSalesRegister => 'बिक्री रजिस्टर CSV';

  @override
  String get exportGstSummary => 'जीएसटी विवरण CSV';

  @override
  String get exportPartyBalances => 'पार्टी बकाया CSV';

  @override
  String get backupAndRestore => 'बैकअप और रीस्टोर';

  @override
  String get backUpNow => 'अभी बैकअप लें';

  @override
  String get restore => 'रीस्टोर करें';

  @override
  String get backupCreated => 'बैकअप फ़ाइल सफलतापूर्वक बनाई गई';

  @override
  String get restoreConfirmTitle => 'रीस्टोर की पुष्टि करें';

  @override
  String restoreConfirmMsg(int invoices, int parties) {
    return 'इस बैकअप में $invoices बिल और $parties पार्टियां हैं। क्या आप वर्तमान डेटा को बदलना चाहते हैं?';
  }

  @override
  String get restoreSuccess => 'डेटाबेस सफलतापूर्वक रीस्टोर हो गया';

  @override
  String get restoreCorruptError => 'क्षतिग्रस्त या अमान्य बैकअप फ़ाइल';

  @override
  String get selectDateRange => 'तिथि सीमा चुनें';

  @override
  String get viewGstSummary => 'जीएसटी विवरण देखें';

  @override
  String get noDataAvailable => 'चयनित सीमा के लिए कोई डेटा उपलब्ध नहीं है';

  @override
  String get errorSavingSettings => 'सेटिंग्स सहेजने में विफल';

  @override
  String get stateRequired => 'राज्य आवश्यक है';

  @override
  String get gstinLengthError => 'GSTIN 15 वर्णों का होना चाहिए';

  @override
  String get gstinStateCodeMismatch =>
      'GSTIN राज्य कोड चयनित राज्य से मेल खाना चाहिए';

  @override
  String get genericError => 'एक त्रुटि हुई। कृपया पुनः प्रयास करें।';

  @override
  String get stateLabel => 'राज्य *';
}
