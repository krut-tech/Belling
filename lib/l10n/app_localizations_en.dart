// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Universal Billing';

  @override
  String get tabSell => 'Sell';

  @override
  String get tabItems => 'Items';

  @override
  String get tabParties => 'Parties';

  @override
  String get tabReports => 'Reports';

  @override
  String get tabMore => 'More';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get gujarati => 'Gujarati';

  @override
  String get items => 'Items';

  @override
  String get addItem => 'Add Item';

  @override
  String get editItem => 'Edit Item';

  @override
  String get searchItems => 'Search items by name or barcode...';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get noItemsSub => 'Tap \'+\' to add your first item.';

  @override
  String get itemName => 'Item Name';

  @override
  String get barcode => 'Barcode';

  @override
  String get scanBarcode => 'Scan';

  @override
  String get typeOrScanBarcode => 'Type or scan barcode...';

  @override
  String get hsn => 'HSN Code';

  @override
  String get gstRate => 'GST Rate';

  @override
  String get sellingPrice => 'Selling Price (₹)';

  @override
  String get costPrice => 'Cost Price (₹)';

  @override
  String get trackStock => 'Track Inventory / Stock';

  @override
  String get openingStock => 'Opening Stock (Units)';

  @override
  String get reorderLevel => 'Reorder Level';

  @override
  String get lowStock => 'Low';

  @override
  String get stock => 'Stock';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get archive => 'Archive';

  @override
  String get confirmArchive => 'Are you sure you want to archive this item?';

  @override
  String get nameRequired => 'Item name is required';

  @override
  String get priceRequired => 'Valid price is required';

  @override
  String get duplicateBarcode => 'Barcode already exists for another product';

  @override
  String get cameraNotAvailable =>
      'Camera scanner not available on this device';

  @override
  String get scanTitle => 'Scan Barcode';

  @override
  String get newBill => 'New Bill';

  @override
  String get todayBills => 'Today\'s Bills';

  @override
  String get noBillsToday => 'No bills issued today';

  @override
  String get searchOrScan => 'Search item or scan barcode...';

  @override
  String get itemNotFound => 'Item not found';

  @override
  String get itemNotFoundAddPrompt => 'Item not found. Add it?';

  @override
  String get add => 'Add';

  @override
  String get walkIn => 'Walk-in';

  @override
  String get selectParty => 'Select Party';

  @override
  String get addParty => 'Add Party';

  @override
  String get phone => 'Phone Number';

  @override
  String get gstin => 'GSTIN';

  @override
  String get state => 'State';

  @override
  String get interState => 'Inter-State (IGST)';

  @override
  String get intraState => 'Intra-State (CGST + SGST)';

  @override
  String get qty => 'Qty';

  @override
  String get rate => 'Rate';

  @override
  String get discount => 'Discount (₹)';

  @override
  String get lineTotal => 'Total';

  @override
  String get taxableAmount => 'Taxable Amount';

  @override
  String get cgst => 'CGST';

  @override
  String get sgst => 'SGST';

  @override
  String get igst => 'IGST';

  @override
  String get roundOff => 'Round Off';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cash => 'Cash';

  @override
  String get upi => 'UPI';

  @override
  String get card => 'Card';

  @override
  String get credit => 'Credit (Pay Later)';

  @override
  String get paidAmount => 'Paid Amount (₹)';

  @override
  String get unpaidBalance => 'Unpaid Balance (₹)';

  @override
  String get issueInvoice => 'Issue Invoice';

  @override
  String get partyRequiredForCredit =>
      'Party is required for credit or unpaid balance';

  @override
  String get cartEmpty => 'Cart is empty';

  @override
  String get invoiceIssued => 'Invoice Issued';

  @override
  String get invoiceNumber => 'Invoice No.';

  @override
  String get share => 'Share';

  @override
  String get sharePlaceholder => 'Share feature coming soon';

  @override
  String get cancelInvoice => 'Cancel Invoice';

  @override
  String get cancellationReason => 'Cancellation Reason';

  @override
  String get reasonRequired => 'Reason is required';

  @override
  String get confirmCancelInvoice =>
      'Are you sure you want to cancel this invoice?';

  @override
  String get invoiceCancelled => 'Invoice cancelled and credit note issued';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusIssued => 'Issued';

  @override
  String get editParty => 'Edit Party';

  @override
  String get partyDetails => 'Party Details';

  @override
  String get totalReceivable => 'Total Receivable';

  @override
  String youGet(String amount) {
    return 'You get $amount';
  }

  @override
  String youGive(String amount) {
    return 'You give $amount';
  }

  @override
  String get settled => 'Settled';

  @override
  String get receivePayment => 'Receive Payment';

  @override
  String get sendReminder => 'Send Reminder';

  @override
  String get creditLimit => 'Credit Limit (₹)';

  @override
  String get creditLimitExceeded => 'Credit Limit Exceeded';

  @override
  String creditLimitWarningMsg(String name, String limit, String newBalance) {
    return 'Credit limit for $name is $limit. New balance will be $newBalance. Do you want to proceed?';
  }

  @override
  String get proceedAnyway => 'Proceed Anyway';

  @override
  String get paymentReceived => 'Payment Received';

  @override
  String get amount => 'Amount (₹)';

  @override
  String get date => 'Date';

  @override
  String get note => 'Note';

  @override
  String get optionalNote => 'Note (optional)';

  @override
  String get allocateToDocument => 'Allocate to Invoice (optional)';

  @override
  String get none => 'None';

  @override
  String get ledger => 'Ledger';

  @override
  String get noTransactions => 'No transactions found';

  @override
  String runningBalance(String amount) {
    return 'Balance: $amount';
  }

  @override
  String get payment => 'Payment';

  @override
  String get creditNote => 'Credit Note';

  @override
  String get invoice => 'Invoice';

  @override
  String get searchParties => 'Search parties by name or phone...';

  @override
  String get noPartiesFound => 'No parties found';

  @override
  String get noPartiesSub => 'Tap \'+\' to add your first party.';

  @override
  String get balance => 'Balance';

  @override
  String get dateRangeToday => 'Today';

  @override
  String get dateRangeYesterday => 'Yesterday';

  @override
  String get dateRangeThisWeek => 'This Week';

  @override
  String get dateRangeThisMonth => 'This Month';

  @override
  String get dateRangeLastMonth => 'Last Month';

  @override
  String get dateRangeThisFinancialYear => 'This Financial Year';

  @override
  String get dateRangeCustom => 'Custom';

  @override
  String get salesTotal => 'Sales Total';

  @override
  String get numberOfBills => 'Number of Bills';

  @override
  String get creditGiven => 'Credit Given';

  @override
  String get paymentsReceived => 'Payments Received';

  @override
  String get cashPayments => 'Cash';

  @override
  String get upiPayments => 'UPI';

  @override
  String get cardPayments => 'Card';

  @override
  String get top10ItemsByAmount => 'Top 10 Items by Amount';

  @override
  String get top10ItemsByQty => 'Top 10 Items by Quantity';

  @override
  String get lowStockList => 'Low Stock List';

  @override
  String get receivablesTop10 => 'Top 10 Receivables';

  @override
  String get gstSummary => 'GST Summary';

  @override
  String get b2bSection => 'B2B Sales (Registered Parties)';

  @override
  String get b2cSection => 'B2C Sales (Retail / Unregistered)';

  @override
  String get gstRateHeader => 'GST Rate';

  @override
  String get taxableHeader => 'Taxable Value';

  @override
  String get totalTaxHeader => 'Total Tax';

  @override
  String get totalsMismatchBanner =>
      'Warning: Document totals do not match line item totals!';

  @override
  String get totalsMatchCheck => 'Totals Check Passed';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportSalesRegister => 'Sales Register CSV';

  @override
  String get exportGstSummary => 'GST Summary CSV';

  @override
  String get exportPartyBalances => 'Party Balances CSV';

  @override
  String get backupAndRestore => 'Backup & Restore';

  @override
  String get backUpNow => 'Back Up Now';

  @override
  String get restore => 'Restore';

  @override
  String get backupCreated => 'Backup created successfully';

  @override
  String get restoreConfirmTitle => 'Confirm Restore';

  @override
  String restoreConfirmMsg(int invoices, int parties) {
    return 'This backup contains $invoices invoices and $parties parties. Are you sure you want to replace current data?';
  }

  @override
  String get restoreSuccess => 'Database restored successfully';

  @override
  String get restoreCorruptError => 'Corrupt or invalid backup file';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get viewGstSummary => 'View GST Summary';

  @override
  String get noDataAvailable => 'No data available for selected range';

  @override
  String get errorSavingSettings => 'Failed to save settings';

  @override
  String get stateRequired => 'State is required';

  @override
  String get gstinLengthError => 'GSTIN must be 15 characters';

  @override
  String get gstinStateCodeMismatch =>
      'GSTIN state code must match selected state';

  @override
  String get genericError => 'An error occurred. Please try again.';

  @override
  String get stateLabel => 'State *';
}
