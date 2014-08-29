# The CartJS namespace.
# ---------------------

CartJS =
  # Default settings, publicly accessible on `module.settings`.
  settings:
    autoCommit: true
    dataAPI: false
    requestBodyClass: null
    rivetsModels: {}

  # Our extended cart model.
  cart: null

CartJS.init = (cart, settings = {}) ->
  # Configure settings from any passed settings hash.
  CartJS.configure(settings)

  # Instantiate the new cart object.
  CartJS.cart = new CartJS.Cart(cart)

  # Set up data-cart-* API if enabled.
  if CartJS.settings.dataAPI
    CartJS.Data.bind()

  # Set up toggling of CSS class on body during requests if provided.
  if CartJS.settings.requestBodyClass
    $(document).on 'cart.requestStarted', () -> $('body').addClass(CartJS.settings.requestBodyClass)
    $(document).on 'cart.requestComplete', () -> $('body').removeClass(CartJS.settings.requestBodyClass)

  # Set up Rivets.js views. Won't do anything if Rivets.js is unavailable.
  CartJS.Rivets.bindElements()

CartJS.configure = (settings = {}) ->
  for setting, value of settings
    CartJS.settings[setting] = value
  return