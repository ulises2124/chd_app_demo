class PedidoRecoleccionDTO {
  String type;
  List appliedOrderPromotions;
  List appliedProductPromotions;
  List appliedVouchers;
  bool calculated;
  CardPoints cardPoints;
  String code;
  Cost deliveryCost;
  int deliveryItemsQuantity;
  DeliveryMode deliveryMode;
  List<DeliveryOrderGroup> deliveryOrderGroups;
  List<Entry> entries;
  String guid;
  bool net;
  Cost orderDiscounts;
  List<PaymentInfo> paymentInfos;
  int pickupItemsQuantity;
  List<PickupOrderGroup> pickupOrderGroups;
  Cost productDiscounts;
  String site;
  String store;
  Cost subTotal;
  Cost totalDiscounts;
  int totalItems;
  Cost totalPrice;
  Cost totalPriceWithTax;
  Cost totalTax;
  User user;
  List<Consignment> consignments;
  String created;
  bool guestCustomer;
  String status;
  String statusDisplay;
  List unconsignedEntries;

  PedidoRecoleccionDTO(
      {this.appliedOrderPromotions,
      this.appliedProductPromotions,
      this.appliedVouchers,
      this.calculated,
      this.cardPoints,
      this.code,
      this.consignments,
      this.created,
      this.deliveryCost,
      this.deliveryItemsQuantity,
      this.deliveryMode,
      this.deliveryOrderGroups,
      this.entries,
      this.guestCustomer,
      this.guid,
      this.net,
      this.orderDiscounts,
      this.paymentInfos,
      this.pickupItemsQuantity,
      this.pickupOrderGroups,
      this.productDiscounts,
      this.site,
      this.status,
      this.statusDisplay,
      this.store,
      this.subTotal,
      this.totalDiscounts,
      this.totalItems,
      this.totalPrice,
      this.totalPriceWithTax,
      this.totalTax,
      this.type,
      this.unconsignedEntries,
      this.user});

  factory PedidoRecoleccionDTO.fromJson(Map<String, dynamic> json) {
    var _consignmentList = json['consignments'] as List;
    var _deliveryOrderGroupList = json['deliveryOrderGroups'] as List;
    var _entryList = json['entries'] as List;
    var _paymentInfoList = json['paymentInfos'] as List;
    var _pickupOrderGroupList = json['pickupOrderGroups'] as List;
    List<Consignment> _consignments =
        _consignmentList.map((i) => Consignment.fromJson(i)).toList();
    List<DeliveryOrderGroup> _deliveryOrderGroups = _deliveryOrderGroupList
        .map((i) => DeliveryOrderGroup.fromJson(i))
        .toList();
    List<Entry> _entries = _entryList.map((i) => Entry.fromJson(i)).toList();
    List<PaymentInfo> _paymentInfos =
        _paymentInfoList.map((i) => PaymentInfo.fromJson(i)).toList();
    List<PickupOrderGroup> _pickupOrderGroups =
        _pickupOrderGroupList.map((i) => PickupOrderGroup.fromJson(i)).toList();
    return PedidoRecoleccionDTO(
        appliedOrderPromotions: json['appliedOrderPromotions'],
        appliedProductPromotions: json['appliedProductPromotions'],
        appliedVouchers: json['appliedVouchers'],
        calculated: json['calculated'],
        cardPoints: CardPoints.fromJson(json['cardPoints']),
        code: json['code'],
        consignments: _consignments,
        created: json['created'],
        deliveryCost: Cost.fromJson(json['deliveryCost']),
        deliveryItemsQuantity: json['deliveryItemsQuantity'],
        deliveryMode: DeliveryMode.fromJson(json['deliveryMode']),
        deliveryOrderGroups: _deliveryOrderGroups,
        entries: _entries,
        guestCustomer: json['guestCustomer'],
        guid: json['guid'],
        net: json['net'],
        orderDiscounts: Cost.fromJson(json['orderDiscounts']),
        paymentInfos: _paymentInfos,
        pickupItemsQuantity: json['pickupItemsQuantity'],
        pickupOrderGroups: _pickupOrderGroups,
        productDiscounts: Cost.fromJson(json['productDiscounts']),
        site: json['site'],
        status: json['status'],
        statusDisplay: json['statusDisplay'],
        store: json['store'],
        subTotal: Cost.fromJson(json['subTotal']),
        totalDiscounts: Cost.fromJson(json['totalDiscounts']),
        totalItems: json['totalItems'],
        totalPrice: Cost.fromJson(json['totalPrice']),
        totalPriceWithTax: Cost.fromJson(json['totalPriceWithTax']),
        totalTax: Cost.fromJson(json['totalTax']),
        type: json['type'],
        unconsignedEntries: json['unconsignedEntries'],
        user: User.fromJson(json['user']));
  }
}

class PickupOrderGroup {
  List<Entry> entries;
  int quantity;
  Cost totalPriceWithTax;
  DeliveryPointOfService deliveryPointOfService;

  PickupOrderGroup(
      {this.deliveryPointOfService,
      this.entries,
      this.quantity,
      this.totalPriceWithTax});

  factory PickupOrderGroup.fromJson(Map<String, dynamic> json) {
    var _entryList = json['entries'] as List;
    List<Entry> _entries = _entryList.map((i) => Entry.fromJson(i)).toList();
    return PickupOrderGroup(
        deliveryPointOfService:
            DeliveryPointOfService.fromJson(json['deliveryPointOfService']),
        entries: _entries,
        quantity: json['quantity'],
        totalPriceWithTax: Cost.fromJson(json['totalPriceWithTax']));
  }
}

class CardPoints {
  num paidWithCard;
  num paidWithPointsInPesos;

  CardPoints({this.paidWithCard, this.paidWithPointsInPesos});

  factory CardPoints.fromJson(Map<String, dynamic> json) {
    return CardPoints(
        paidWithCard: json['paidWithCard'],
        paidWithPointsInPesos: json['paidWithPointsInPesos']);
  }
}

class Address {
  Country country;
  String email;
  String firstName;
  String formattedAddress;
  String id;
  String lastName;
  String line1;
  String line2;
  String phone;
  String postalCode;
  Region region;
  bool shippingAddress;
  String town;
  bool visibleInAddressBook;

  Address(
      {this.country,
      this.email,
      this.firstName,
      this.formattedAddress,
      this.id,
      this.lastName,
      this.line1,
      this.line2,
      this.phone,
      this.postalCode,
      this.region,
      this.shippingAddress,
      this.town,
      this.visibleInAddressBook});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
        country: Country.fromJson(json['country']),
        email: json['email'],
        firstName: json['firstName'],
        formattedAddress: json['formattedAddress'],
        id: json['id'],
        lastName: json['lastName'],
        line1: json['line1'],
        line2: json['line2'],
        phone: json['phone'],
        postalCode: json['postalCode'],
        region: Region.fromJson(json['region']),
        shippingAddress: json['shippingAddress'],
        town: json['town'],
        visibleInAddressBook: json['visibleInAddressBook']);
  }
}

class Country {
  String isocode;
  String name;

  Country({this.isocode, this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(isocode: json['isocode'], name: json['name']);
  }
}

class Region {
  String countryIso;
  String isocode;
  String isocodeShort;
  String name;

  Region({this.countryIso, this.isocode, this.isocodeShort, this.name});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
        countryIso: json['countryIso'],
        isocode: json['isocode'],
        isocodeShort: json['isocodeShort'],
        name: json['name']);
  }
}

class Cost {
  String currencyIso;
  String formattedValue;
  String priceType;
  num value;

  Cost({this.currencyIso, this.formattedValue, this.priceType, this.value});

  factory Cost.fromJson(Map<String, dynamic> json) {
    return Cost(
        currencyIso: json['currencyIso'],
        formattedValue: json['formattedValue'],
        priceType: json['priceType'],
        value: json['value']);
  }
}

class DeliveryMode {
  String code;
  String description;
  String name;

  DeliveryMode({this.code, this.description, this.name});

  factory DeliveryMode.fromJson(Map<String, dynamic> json) {
    if(json != null){
      return DeliveryMode(
        code: json['code'],
        description: json['description'],
        name: json['name']);
    } 
    return null;
  }
}

class DeliveryOrderGroup {
  List<Entry> entries;
  Cost totalPriceWithTax;

  DeliveryOrderGroup({this.entries, this.totalPriceWithTax});

  factory DeliveryOrderGroup.fromJson(Map<String, dynamic> json) {
    var _entryList = json['entries'] as List;
    List<Entry> _entries = _entryList.map((i) => Entry.fromJson(i)).toList();
    return DeliveryOrderGroup(
        entries: _entries,
        totalPriceWithTax: Cost.fromJson(json['totalPriceWithTax']));
  }
}

class DeliveryPointOfService {
  Address address;
  String description;
  String displayName;
  Map features;
  GeoPoint geoPoint;
  String name;
  OpeningHours openingHours;
  List storeImages;

  DeliveryPointOfService(
      {this.address,
      this.description,
      this.displayName,
      this.features,
      this.geoPoint,
      this.name,
      this.openingHours,
      this.storeImages});

  factory DeliveryPointOfService.fromJson(Map<String, dynamic> json) {
    if(json != null){
      return DeliveryPointOfService(
        address: Address.fromJson(json['address']),
        description: json['description'],
        displayName: json['displayName'],
        features: json['features'],
        geoPoint: GeoPoint.fromJson(json['geoPoint']),
        name: json['name'],
        openingHours: OpeningHours.fromJson(json['openingHours']),
        storeImages: json['storeImages']);
    }
    return null;
  }
}

class Entry {
  Cost basePrice;
  double decimalQty;
  DeliveryMode deliveryMode;
  DeliveryPointOfService deliveryPointOfService;
  int entryNumber;
  Product product;
  Cost totalPrice;
  bool updateable;

  Entry(
      {this.basePrice,
      this.decimalQty,
      this.deliveryMode,
      this.entryNumber,
      this.product,
      this.totalPrice,
      this.updateable,
      this.deliveryPointOfService});

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
        basePrice: Cost.fromJson(json['basePrice']),
        decimalQty: json['decimalQty'],
        deliveryMode: DeliveryMode.fromJson(json['deliveryMode']),
        deliveryPointOfService:
            DeliveryPointOfService.fromJson(json['deliveryPointOfService']),
        entryNumber: json['entryNumber'],
        product: Product.fromJson(json['product']),
        totalPrice: Cost.fromJson(json['totalPrice']),
        updateable: json['updateable']);
  }
}

class Product {
  bool availableForPickup;
  List baseOptions;
  List<Category> categories;
  String code;
  List<Image> images;
  int maxOrderQuantity;
  int minOrderQuantity;
  String name;
  bool purchasable;
  bool restricted;
  String sapEAN;
  Stock stock;
  Unit unit;
  String url;

  Product(
      {this.availableForPickup,
      this.baseOptions,
      this.categories,
      this.code,
      this.images,
      this.maxOrderQuantity,
      this.minOrderQuantity,
      this.name,
      this.purchasable,
      this.restricted,
      this.sapEAN,
      this.stock,
      this.unit,
      this.url});

  factory Product.fromJson(Map<String, dynamic> json) {
    var _categoryList = json['categories'] as List;
    var _imageList = json['images'] as List;
    List<Category> _categories = _categoryList != null ?
        _categoryList.map((i) => Category.fromJson(i)).toList() : [];
    List<Image> _images = _imageList != null ?
       _imageList.map((i) => Image.fromJson(i)).toList() : [];
    return Product(
        availableForPickup: json['availableForPickup'],
        baseOptions: json['baseOptions'],
        categories: _categories,
        code: json['code'],
        images: _images,
        maxOrderQuantity: json['maxOrderQuantity'],
        minOrderQuantity: json['minOrderQuantity'],
        name: json['name'],
        purchasable: json['purchasable'],
        restricted: json['restricted'],
        sapEAN: json['sapEAN'],
        stock: Stock.fromJson(json['stock']),
        unit: Unit.fromJson(json['unit']),
        url: json['url']);
  }
}

class Category {
  String code;
  String url;

  Category({this.code, this.url});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(code: json['code'], url: json['url']);
  }
}

class Image {
  String altText;
  String format;
  String imageType;
  String url;

  Image({this.altText, this.format, this.imageType, this.url});

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
        altText: json['altText'],
        format: json['format'],
        imageType: json['imageType'],
        url: json['url']);
  }
}

class ProductReference {
  String referenceType;
  Target target;
  bool preselected;

  ProductReference({this.referenceType, this.target, this.preselected});

  factory ProductReference.fromJson(Map<String, dynamic> json) {
    return ProductReference(
        referenceType: json['referenceType'],
        target: Target.fromJson(json['target']),
        preselected: json['preselected']);
  }
}

class Target {
  String code;
  String name;
  bool restricted;
  String url;

  Target({this.code, this.name, this.restricted, this.url});

  factory Target.fromJson(Map<String, dynamic> json) {
    return Target(
        code: json['code'],
        name: json['name'],
        restricted: json['restricted'],
        url: json['url']);
  }
}

class Stock {
  int stockLevel;
  String stockLevelStatus;

  Stock({this.stockLevel, this.stockLevelStatus});

  factory Stock.fromJson(Map<String, dynamic> json) {
    if(json != null){
      return Stock(
        stockLevel: json['stockLevel'],
        stockLevelStatus: json['stockLevelStatus']);
    }
    return null;
  }
}

class Unit {
  String code;
  double conversion;
  String name;

  Unit({this.code, this.conversion, this.name});

  factory Unit.fromJson(Map<String, dynamic> json) {
    if(json != null){
      return Unit(
        code: json['code'], conversion: json['conversion'], name: json['name']);
    }
  }
}

class PaymentInfo {
  CardType cardType;
  bool defaultPayment;
  bool saved;

  PaymentInfo({this.cardType, this.defaultPayment, this.saved});

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
        cardType: CardType.fromJson(json['cardType']),
        defaultPayment: json['defaultPayment'],
        saved: json['saved']);
  }
}

class CardType {
  String code;
  String name;

  CardType({this.code, this.name});

  factory CardType.fromJson(Map<String, dynamic> json) {
    return CardType(code: json['code'], name: json['name']);
  }
}

class User {
  String name;
  String uid;

  User({this.name, this.uid});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(name: json['name'], uid: json['uid']);
  }
}

class Consignment {
  String code;
  DeliveryPointOfService deliveryPointOfService;
  List<OrderEntry> entries;
  Address shippingAddress;
  String status;
  String timeFrom;
  String timeTo;

  Consignment(
      {this.code,
      this.deliveryPointOfService,
      this.entries,
      this.shippingAddress,
      this.status,
      this.timeFrom,
      this.timeTo});

  factory Consignment.fromJson(Map<String, dynamic> json) {
    var _orderEntryList = json['entries'] as List;
    List<OrderEntry> _orderEntries =
        _orderEntryList.map((i) => OrderEntry.fromJson(i)).toList();
    return Consignment(
        code: json['code'],
        deliveryPointOfService:
            DeliveryPointOfService.fromJson(json['deliveryPointOfService']),
        entries: _orderEntries,
        shippingAddress: Address.fromJson(json['shippingAddress']),
        status: json['status'],
        timeFrom: json['timeFrom'],
        timeTo: json['timeTo']);
  }
}

class OrderEntry {
  Entry orderEntry;
  int quantity;

  OrderEntry({this.orderEntry, this.quantity});

  factory OrderEntry.fromJson(Map<String, dynamic> json) {
    return OrderEntry(
        orderEntry: Entry.fromJson(json['orderEntry']),
        quantity: json['quantity']);
  }
}

class GeoPoint {
  double latitude;
  double longitude;

  GeoPoint({this.latitude, this.longitude});

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(latitude: json['latitude'], longitude: json['longitude']);
  }
}

class OpeningHours {
  String code;
  List<SpecialDayOpening> specialDayOpeningList;
  List<WeekDayOpening> weekDayOpeningList;

  OpeningHours(
      {this.code, this.specialDayOpeningList, this.weekDayOpeningList});

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    var _specialDayOpeningList = json['specialDayOpeningList'] as List;
    var _weekDayOpeningList = json['weekDayOpeningList'] as List;
    List<SpecialDayOpening> _specialDayOpenings = _specialDayOpeningList
        .map((i) => SpecialDayOpening.fromJson(i))
        .toList();
    List<WeekDayOpening> _weekDayOpenings =
        _weekDayOpeningList.map((i) => WeekDayOpening.fromJson(i)).toList();
    return OpeningHours(
        code: json['code'],
        specialDayOpeningList: _specialDayOpenings,
        weekDayOpeningList: _weekDayOpenings);
  }
}

class SpecialDayOpening {
  StoreTime closingTime;
  StoreTime openingTime;
  bool closed;
  String date;
  String formattedDate;

  SpecialDayOpening(
      {this.closed,
      this.closingTime,
      this.date,
      this.formattedDate,
      this.openingTime});

  factory SpecialDayOpening.fromJson(Map<String, dynamic> json) {
    return SpecialDayOpening(
        closed: json['closed'],
        closingTime: StoreTime.fromJson(json['closingTime']),
        date: json['date'],
        formattedDate: json['formattedDate'],
        openingTime: StoreTime.fromJson(json['openingTime']));
  }
}

class WeekDayOpening {
  StoreTime closingTime;
  StoreTime openingTime;
  bool closed;
  String weekDay;

  WeekDayOpening(
      {this.closed, this.closingTime, this.openingTime, this.weekDay});

  factory WeekDayOpening.fromJson(Map<String, dynamic> json) {
    return WeekDayOpening(
        closed: json['closed'],
        closingTime: StoreTime.fromJson(json['closingTime']),
        openingTime: StoreTime.fromJson(json['openingTime']),
        weekDay: json['weekDay']);
  }
}

class StoreTime {
  String formattedHour;
  int hour;
  int minute;

  StoreTime({this.formattedHour, this.hour, this.minute});

  factory StoreTime.fromJson(Map<String, dynamic> json) {
    return StoreTime(
        formattedHour: json['formattedHour'],
        hour: json['hour'],
        minute: json['minute']);
  }
}
