globalThis.openPayPalWindow = (captureAmount, baseUrl, orderId) => {
  const paypalWindow = window.open(
    "/payment.html",
    "Honey + Thyme Payment",
    "width=600,height=800"
  );

  paypalWindow.onload = function () {
    paypalWindow.paypal
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
            opener.globalThis.onerror(
              "There was a problem processing your payment, you will not be charged"
            );
            console.error(error);
          }
        },
        async onApprove(data, actions) {
          globalThis.onApprove(data.orderID);
          setTimeout(() => {
            paypalWindow.close();
          }, 20);
        },
      })
      .render("#paypal-button-container");

    const windowChecker = setInterval(() => {
      if (!paypalWindow.closed) return;
      globalThis.onPayPalWindowClose();
      clearInterval(windowChecker);
    }, 1000);
  };
};
