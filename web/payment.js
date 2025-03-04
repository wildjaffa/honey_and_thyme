globalThis.openPayPalWindow = (captureAmount, baseUrl, orderId) => {
  const paypalForm = document.getElementById("paypal-payment-form");
  paypalForm.style.display = "block";
  window.paypal
    .Buttons({
      style: {
        shape: "rect",
        layout: "vertical",
        color: "gold",
        label: "paypal",
      },
      async createOrder() {
        try {
          return orderId;
        } catch (error) {
          globalThis.onerror(
            "There was a problem processing your payment, you will not be charged"
          );
          console.error(error);
        }
      },
      async onApprove(data, actions) {
        paypalForm.style.display = "none";
        globalThis.onApprove(data.orderID);
      },
    })
    .render("#paypal-button-container");
  const closeButton = document.getElementById("close-paypal");
  closeButton.onclick = () => {
    paypalForm.style.display = "none";
    globalThis.onPayPalWindowClose();
    document.getElementById("paypal-button-container").remove();
    const paypalButtons = document.createElement("paypal-button");
    paypalButtons.id = "paypal-button-container";
    document
      .getElementById("paypal-payment-form-inner")
      .appendChild(paypalButtons);
  };
};
