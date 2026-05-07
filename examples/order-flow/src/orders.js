function createOrder(input, store) {
  if (!input || typeof input.customerName !== "string" || input.customerName.trim() === "") {
    return {
      ok: false,
      error: "Customer name is required",
      destination: "order-form"
    };
  }

  if (!Array.isArray(input.items) || input.items.length === 0) {
    return {
      ok: false,
      error: "At least one item is required",
      destination: "order-form"
    };
  }

  const order = {
    id: store.nextId(),
    customerName: input.customerName.trim(),
    items: input.items.slice(),
    status: "created"
  };

  const saved = store.save(order);
  if (!saved) {
    return {
      ok: false,
      error: "Could not save order",
      destination: "order-form"
    };
  }

  return {
    ok: true,
    order,
    stateTransition: "draft -> created",
    destination: "order-detail"
  };
}

module.exports = { createOrder };
