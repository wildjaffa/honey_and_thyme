const PaymentProcessor = {
  PayPal: 0,
  External: 1,
} as const;

export type PaymentProcessor =
  (typeof PaymentProcessor)[keyof typeof PaymentProcessor];

export default PaymentProcessor;
