# CartJS.Core
# Core API methods for manipulating carts.
# ----------------------------------------

CartJS.Core =

  # Fetch updated cart object from API endpoint.
  getCart: (options = {}) ->
    options.type = 'GET'
    options.updateCart = true
    CartJS.Queue.add '/cart.js', {v: new Date().getTime()}, options

  # Add a new line item to the cart.
  addItem: (id, quantity = 1, properties = {}, options = {}) ->
    data = CartJS.Utils.wrapKeys(properties, null, null, ['selling_plan'])
    data.id = id
    data.quantity = quantity
    CartJS.Queue.add '/cart/add.js', data, options
    CartJS.Core.getCart()

  # Add multiple new line items to the cart.
  addItems: (items, options = {}) ->
    data =
      items: items
    CartJS.Queue.add '/cart/add.js', data, options
    CartJS.Core.getCart()

  # Update an existing line item.
  updateItem: (line, quantity, properties = {}, options = {}) ->
    options.updateCart = true
    {item, giftWrap} = CartJS.Utils.getAssociatedGiftWrapWithItem CartJS.cart.items, line

    # Update the gift wrap associated with this item.
    if CartJS.settings.giftWrap? and giftWrap?
      newQuantity = if quantity? then quantity else item.quantity
      updates = {}
      updates[giftWrap.key] = newQuantity
      updates[item.key] = newQuantity

      CartJS.Core.updateItemQuantitiesById updates, options
    else
      data = CartJS.Utils.wrapKeys(properties, null, null, ['selling_plan'])
      data.line = line
      if quantity?
        data.quantity = quantity
      CartJS.Queue.add '/cart/change.js', data, options

  # Remove an existing line item.
  removeItem: (line, options = {}) ->
    {item, giftWrap} = CartJS.Utils.getAssociatedGiftWrapWithItem CartJS.cart.items, line

    # Remove the gift wrap associated with this item.
    if CartJS.settings.giftWrap? and giftWrap?
      updates = {}
      updates[giftWrap.key] = 0
      updates[item.key] = 0

      CartJS.Core.updateItemQuantitiesById updates, options
    else
      CartJS.Core.updateItem line, 0, {}, options

  # Update item by ID
  updateItemById: (id, quantity, properties = {}, options = {}) ->
    data = CartJS.Utils.wrapKeys(properties, null, null, ['selling_plan'])
    data.id = id
    if quantity?
      data.quantity = quantity
    options.updateCart = true
    CartJS.Queue.add '/cart/change.js', data, options

  # Set the quantities of a number of items in the cart with an ID/Quantity "updates" mapping.
  updateItemQuantitiesById: (updates = {}, options = {}) ->
    options.updateCart = true
    CartJS.Queue.add '/cart/update.js', {updates: updates}, options

  # Remove all line items for the given variant ID.
  removeItemById: (id, options = {}) ->
    data =
      id: id
      quantity: 0
    options.updateCart = true
    CartJS.Queue.add '/cart/change.js', data, options

  # Clear all items from the cart.
  clear: (options = {}) ->
    options.updateCart = true
    CartJS.Queue.add '/cart/clear.js', {}, options

  # Get a cart attribute.
  getAttribute: (attributeName, defaultValue) ->
    if attributeName of CartJS.cart.attributes then CartJS.cart.attributes[attributeName] else defaultValue

  # Set a cart attribute.
  setAttribute: (attributeName, value, options = {}) ->
    attributes = {}
    attributes[attributeName] = value
    CartJS.Core.setAttributes(attributes, options)

  # Get all cart attributes as a hash.
  getAttributes: () ->
    CartJS.cart.attributes

  # Set multiple cart attributes using a hash.
  setAttributes: (attributes = {}, options = {}) ->
    options.updateCart = true
    CartJS.Queue.add '/cart/update.js', CartJS.Utils.wrapKeys(attributes, 'attributes'), options

  # Clear all attributes.
  clearAttributes: (options = {}) ->
    options.updateCart = true
    CartJS.Queue.add '/cart/update.js', CartJS.Utils.wrapKeys(CartJS.Core.getAttributes(), 'attributes', ''), options

  # Get the cart note.
  getNote: () ->
    CartJS.cart.note

  # Set the cart note.
  setNote: (note, options = {}) ->
    options.updateCart = true
    CartJS.Queue.add '/cart/update.js', { note: note }, options
