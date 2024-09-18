# Easy Paymob

Easily payments ( Online Cards , Mobile Wallet , Kiosk ) in your Flutter App with Paymob.

## Installation

Add this to `dependencies` in your app's `pubspec.yaml`

```yaml
easy_paymob : latest_version
```

## Initialization

```dart
await EasyPaymob.instance.initialize(
  apiKey: "", // from dashboard Select Settings -> Account Info -> API Key 
  integrationCardID: 123456, // from dashboard Select Developers -> Payment Integrations -> Online Card ID 
  integrationCashID: 123456 // from dashboard Select Developers -> Payment Integrations -> Mobile Wallet ID 
  integrationKioskID: 123456 // from dashboard Select Developers -> Payment Integrations -> Kiosk ID 
  iFrameID: 123456, // from paymob Select Developers -> iframes 
);
```

## Usage Card Payment

```dart
final EasyPaymobResponse? response = await EasyPaymob.instance.payWithCard(
  context: context,
  amountInCents: "20000", // 200 EGP
  onPayment: (response) => setState(() => this.response = response), // Optional
)
```

## Usage Wallet

```dart
final EasyPaymobResponse? response = await EasyPaymob.instance.payWithWallet(
  context: context,
  amountInCents: "20000", // 200 EGP
  phoneNumber: "01010101010", // 
  onPayment: (response) => setState(() => this.response = response), // Optional
)
```

## Usage Kiosk

```dart
final EasyPaymobResponse? response = await EasyPaymob.instance.payWithKiosk(
  context: context,
  amountInCents: "20000", // 200 EGP
  onPayment: (response) => setState(() => this.response = response), // Optional
)
```


## Get Transaction Status (EasyPaymobResponse)

```dart
final EasyPaymobResponse? response = await EasyPaymob.instance.getTransactionStatus(
  transactionId: "12345678",
)
```

## EasyPaymobResponse

| Variable      | Type    | Description          |
| ------------- |---------| -------------------- |
| success       | bool    | Indicates if the transaction was successful or not |
| pending       | bool    | Indicates if the transaction was pending or not For Kiosk |
| transactionID | String? | The ID of the transaction |
| responseCode  | String? | The response code for the transaction |
| message       | String? | A brief message describing the transaction |
| type          | String? | Payment Type (card,wallet,kiosk) |
| billReference | int?    | Kiosk Code Well Response when you pay with Kiosk |


# Testing
## Successful payment
#### Card Successful Payment
| Variable     | Description       |
|--------------|-------------------|
| Card Number  | 5123456789012346  |
| Expiry Month | 12                |
| Expiry Year  | 25                |
| CVV          | 123               |

#### Mobile Wallet Successful Payment

| Variable     | Description       |
|--------------|-------------------|
| Wallet Number| 01010101010       |
| MPin Code    | 123456            |
| OTP          | 123456            |

### Declined payment

Change cvv to 111 or expiry year to 20

> # Note 
> 
> May be you have to contact paymob support to activate your test card 