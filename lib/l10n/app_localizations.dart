import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Universal Billing'**
  String get appTitle;

  /// No description provided for @tabSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get tabSell;

  /// No description provided for @tabItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get tabItems;

  /// No description provided for @tabParties.
  ///
  /// In en, this message translates to:
  /// **'Parties'**
  String get tabParties;

  /// No description provided for @tabReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get tabReports;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @gujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get gujarati;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @searchItems.
  ///
  /// In en, this message translates to:
  /// **'Search items by name or barcode...'**
  String get searchItems;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @noItemsSub.
  ///
  /// In en, this message translates to:
  /// **'Tap \'+\' to add your first item.'**
  String get noItemsSub;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanBarcode;

  /// No description provided for @typeOrScanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Type or scan barcode...'**
  String get typeOrScanBarcode;

  /// No description provided for @hsn.
  ///
  /// In en, this message translates to:
  /// **'HSN Code'**
  String get hsn;

  /// No description provided for @gstRate.
  ///
  /// In en, this message translates to:
  /// **'GST Rate'**
  String get gstRate;

  /// No description provided for @sellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling Price (₹)'**
  String get sellingPrice;

  /// No description provided for @costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost Price (₹)'**
  String get costPrice;

  /// No description provided for @trackStock.
  ///
  /// In en, this message translates to:
  /// **'Track Inventory / Stock'**
  String get trackStock;

  /// No description provided for @openingStock.
  ///
  /// In en, this message translates to:
  /// **'Opening Stock (Units)'**
  String get openingStock;

  /// No description provided for @reorderLevel.
  ///
  /// In en, this message translates to:
  /// **'Reorder Level'**
  String get reorderLevel;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowStock;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @confirmArchive.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to archive this item?'**
  String get confirmArchive;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Item name is required'**
  String get nameRequired;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Valid price is required'**
  String get priceRequired;

  /// No description provided for @duplicateBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode already exists for another product'**
  String get duplicateBarcode;

  /// No description provided for @cameraNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Camera scanner not available on this device'**
  String get cameraNotAvailable;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanTitle;

  /// No description provided for @newBill.
  ///
  /// In en, this message translates to:
  /// **'New Bill'**
  String get newBill;

  /// No description provided for @todayBills.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Bills'**
  String get todayBills;

  /// No description provided for @noBillsToday.
  ///
  /// In en, this message translates to:
  /// **'No bills issued today'**
  String get noBillsToday;

  /// No description provided for @searchOrScan.
  ///
  /// In en, this message translates to:
  /// **'Search item or scan barcode...'**
  String get searchOrScan;

  /// No description provided for @itemNotFound.
  ///
  /// In en, this message translates to:
  /// **'Item not found'**
  String get itemNotFound;

  /// No description provided for @itemNotFoundAddPrompt.
  ///
  /// In en, this message translates to:
  /// **'Item not found. Add it?'**
  String get itemNotFoundAddPrompt;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @walkIn.
  ///
  /// In en, this message translates to:
  /// **'Walk-in'**
  String get walkIn;

  /// No description provided for @selectParty.
  ///
  /// In en, this message translates to:
  /// **'Select Party'**
  String get selectParty;

  /// No description provided for @addParty.
  ///
  /// In en, this message translates to:
  /// **'Add Party'**
  String get addParty;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @gstin.
  ///
  /// In en, this message translates to:
  /// **'GSTIN'**
  String get gstin;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @interState.
  ///
  /// In en, this message translates to:
  /// **'Inter-State (IGST)'**
  String get interState;

  /// No description provided for @intraState.
  ///
  /// In en, this message translates to:
  /// **'Intra-State (CGST + SGST)'**
  String get intraState;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount (₹)'**
  String get discount;

  /// No description provided for @lineTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get lineTotal;

  /// No description provided for @taxableAmount.
  ///
  /// In en, this message translates to:
  /// **'Taxable Amount'**
  String get taxableAmount;

  /// No description provided for @cgst.
  ///
  /// In en, this message translates to:
  /// **'CGST'**
  String get cgst;

  /// No description provided for @sgst.
  ///
  /// In en, this message translates to:
  /// **'SGST'**
  String get sgst;

  /// No description provided for @igst.
  ///
  /// In en, this message translates to:
  /// **'IGST'**
  String get igst;

  /// No description provided for @roundOff.
  ///
  /// In en, this message translates to:
  /// **'Round Off'**
  String get roundOff;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @upi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get upi;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit (Pay Later)'**
  String get credit;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount (₹)'**
  String get paidAmount;

  /// No description provided for @unpaidBalance.
  ///
  /// In en, this message translates to:
  /// **'Unpaid Balance (₹)'**
  String get unpaidBalance;

  /// No description provided for @issueInvoice.
  ///
  /// In en, this message translates to:
  /// **'Issue Invoice'**
  String get issueInvoice;

  /// No description provided for @partyRequiredForCredit.
  ///
  /// In en, this message translates to:
  /// **'Party is required for credit or unpaid balance'**
  String get partyRequiredForCredit;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartEmpty;

  /// No description provided for @invoiceIssued.
  ///
  /// In en, this message translates to:
  /// **'Invoice Issued'**
  String get invoiceIssued;

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice No.'**
  String get invoiceNumber;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @sharePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Share feature coming soon'**
  String get sharePlaceholder;

  /// No description provided for @cancelInvoice.
  ///
  /// In en, this message translates to:
  /// **'Cancel Invoice'**
  String get cancelInvoice;

  /// No description provided for @cancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Reason'**
  String get cancellationReason;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Reason is required'**
  String get reasonRequired;

  /// No description provided for @confirmCancelInvoice.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this invoice?'**
  String get confirmCancelInvoice;

  /// No description provided for @invoiceCancelled.
  ///
  /// In en, this message translates to:
  /// **'Invoice cancelled and credit note issued'**
  String get invoiceCancelled;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusIssued.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get statusIssued;

  /// No description provided for @editParty.
  ///
  /// In en, this message translates to:
  /// **'Edit Party'**
  String get editParty;

  /// No description provided for @partyDetails.
  ///
  /// In en, this message translates to:
  /// **'Party Details'**
  String get partyDetails;

  /// No description provided for @totalReceivable.
  ///
  /// In en, this message translates to:
  /// **'Total Receivable'**
  String get totalReceivable;

  /// No description provided for @youGet.
  ///
  /// In en, this message translates to:
  /// **'You get {amount}'**
  String youGet(String amount);

  /// No description provided for @youGive.
  ///
  /// In en, this message translates to:
  /// **'You give {amount}'**
  String youGive(String amount);

  /// No description provided for @settled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settled;

  /// No description provided for @receivePayment.
  ///
  /// In en, this message translates to:
  /// **'Receive Payment'**
  String get receivePayment;

  /// No description provided for @sendReminder.
  ///
  /// In en, this message translates to:
  /// **'Send Reminder'**
  String get sendReminder;

  /// No description provided for @creditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit (₹)'**
  String get creditLimit;

  /// No description provided for @creditLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit Exceeded'**
  String get creditLimitExceeded;

  /// No description provided for @creditLimitWarningMsg.
  ///
  /// In en, this message translates to:
  /// **'Credit limit for {name} is {limit}. New balance will be {newBalance}. Do you want to proceed?'**
  String creditLimitWarningMsg(String name, String limit, String newBalance);

  /// No description provided for @proceedAnyway.
  ///
  /// In en, this message translates to:
  /// **'Proceed Anyway'**
  String get proceedAnyway;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get paymentReceived;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @optionalNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get optionalNote;

  /// No description provided for @allocateToDocument.
  ///
  /// In en, this message translates to:
  /// **'Allocate to Invoice (optional)'**
  String get allocateToDocument;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @ledger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledger;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactions;

  /// No description provided for @runningBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance: {amount}'**
  String runningBalance(String amount);

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @creditNote.
  ///
  /// In en, this message translates to:
  /// **'Credit Note'**
  String get creditNote;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @searchParties.
  ///
  /// In en, this message translates to:
  /// **'Search parties by name or phone...'**
  String get searchParties;

  /// No description provided for @noPartiesFound.
  ///
  /// In en, this message translates to:
  /// **'No parties found'**
  String get noPartiesFound;

  /// No description provided for @noPartiesSub.
  ///
  /// In en, this message translates to:
  /// **'Tap \'+\' to add your first party.'**
  String get noPartiesSub;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @dateRangeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateRangeToday;

  /// No description provided for @dateRangeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateRangeYesterday;

  /// No description provided for @dateRangeThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get dateRangeThisWeek;

  /// No description provided for @dateRangeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get dateRangeThisMonth;

  /// No description provided for @dateRangeLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get dateRangeLastMonth;

  /// No description provided for @dateRangeThisFinancialYear.
  ///
  /// In en, this message translates to:
  /// **'This Financial Year'**
  String get dateRangeThisFinancialYear;

  /// No description provided for @dateRangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get dateRangeCustom;

  /// No description provided for @salesTotal.
  ///
  /// In en, this message translates to:
  /// **'Sales Total'**
  String get salesTotal;

  /// No description provided for @numberOfBills.
  ///
  /// In en, this message translates to:
  /// **'Number of Bills'**
  String get numberOfBills;

  /// No description provided for @creditGiven.
  ///
  /// In en, this message translates to:
  /// **'Credit Given'**
  String get creditGiven;

  /// No description provided for @paymentsReceived.
  ///
  /// In en, this message translates to:
  /// **'Payments Received'**
  String get paymentsReceived;

  /// No description provided for @cashPayments.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashPayments;

  /// No description provided for @upiPayments.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get upiPayments;

  /// No description provided for @cardPayments.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get cardPayments;

  /// No description provided for @top10ItemsByAmount.
  ///
  /// In en, this message translates to:
  /// **'Top 10 Items by Amount'**
  String get top10ItemsByAmount;

  /// No description provided for @top10ItemsByQty.
  ///
  /// In en, this message translates to:
  /// **'Top 10 Items by Quantity'**
  String get top10ItemsByQty;

  /// No description provided for @lowStockList.
  ///
  /// In en, this message translates to:
  /// **'Low Stock List'**
  String get lowStockList;

  /// No description provided for @receivablesTop10.
  ///
  /// In en, this message translates to:
  /// **'Top 10 Receivables'**
  String get receivablesTop10;

  /// No description provided for @gstSummary.
  ///
  /// In en, this message translates to:
  /// **'GST Summary'**
  String get gstSummary;

  /// No description provided for @b2bSection.
  ///
  /// In en, this message translates to:
  /// **'B2B Sales (Registered Parties)'**
  String get b2bSection;

  /// No description provided for @b2cSection.
  ///
  /// In en, this message translates to:
  /// **'B2C Sales (Retail / Unregistered)'**
  String get b2cSection;

  /// No description provided for @gstRateHeader.
  ///
  /// In en, this message translates to:
  /// **'GST Rate'**
  String get gstRateHeader;

  /// No description provided for @taxableHeader.
  ///
  /// In en, this message translates to:
  /// **'Taxable Value'**
  String get taxableHeader;

  /// No description provided for @totalTaxHeader.
  ///
  /// In en, this message translates to:
  /// **'Total Tax'**
  String get totalTaxHeader;

  /// No description provided for @totalsMismatchBanner.
  ///
  /// In en, this message translates to:
  /// **'Warning: Document totals do not match line item totals!'**
  String get totalsMismatchBanner;

  /// No description provided for @totalsMatchCheck.
  ///
  /// In en, this message translates to:
  /// **'Totals Check Passed'**
  String get totalsMatchCheck;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportSalesRegister.
  ///
  /// In en, this message translates to:
  /// **'Sales Register CSV'**
  String get exportSalesRegister;

  /// No description provided for @exportGstSummary.
  ///
  /// In en, this message translates to:
  /// **'GST Summary CSV'**
  String get exportGstSummary;

  /// No description provided for @exportPartyBalances.
  ///
  /// In en, this message translates to:
  /// **'Party Balances CSV'**
  String get exportPartyBalances;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// No description provided for @backUpNow.
  ///
  /// In en, this message translates to:
  /// **'Back Up Now'**
  String get backUpNow;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get backupCreated;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Restore'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'This backup contains {invoices} invoices and {parties} parties. Are you sure you want to replace current data?'**
  String restoreConfirmMsg(int invoices, int parties);

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Database restored successfully'**
  String get restoreSuccess;

  /// No description provided for @restoreCorruptError.
  ///
  /// In en, this message translates to:
  /// **'Corrupt or invalid backup file'**
  String get restoreCorruptError;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @viewGstSummary.
  ///
  /// In en, this message translates to:
  /// **'View GST Summary'**
  String get viewGstSummary;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available for selected range'**
  String get noDataAvailable;

  /// No description provided for @errorSavingSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings'**
  String get errorSavingSettings;

  /// No description provided for @stateRequired.
  ///
  /// In en, this message translates to:
  /// **'State is required'**
  String get stateRequired;

  /// No description provided for @gstinLengthError.
  ///
  /// In en, this message translates to:
  /// **'GSTIN must be 15 characters'**
  String get gstinLengthError;

  /// No description provided for @gstinStateCodeMismatch.
  ///
  /// In en, this message translates to:
  /// **'GSTIN state code must match selected state'**
  String get gstinStateCodeMismatch;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get genericError;

  /// No description provided for @stateLabel.
  ///
  /// In en, this message translates to:
  /// **'State *'**
  String get stateLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
