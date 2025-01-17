# CartJS.Utils
# Utility methods.
# ----------------

FORMAT_MONEY_WARNING = 'A money formatting filter was used, but Shopify.formatMoney is not available. See the note "Dependency when formatting monetary values" on this page: https://cartjs.org/pages/guide#getting-started-setup.'

CartJS.Utils =

  # Log an informational message to the console iff debug mode is on and a console is available.
  log: () ->
    CartJS.Utils.console(console.log, arguments)

  # Log a warning message to the console iff debug mode is on and a console is available.
  warn: () ->
    CartJS.Utils.console(console.warn, arguments)

  # Log an error message to the console iff debug mode is on and a console is available.
  error: () ->
    CartJS.Utils.console(console.error, arguments)

  # General wrapper method for outputting to console.
  console: (method, args) ->
    if CartJS.settings.debug and console?
      args = Array.prototype.slice.call(args)
      args.unshift '[CartJS]:'
      method.apply(console, args)

  # Returns the given object with each key wrapped with the text specified by
  # the 'type' parameter and square brackets, suitable for passing as a POST
  # variable to Shopify. 'type' defaults to 'properties'.
  #
  # For example, {"size": "xs"} becomes {"properties[size]": "xs"}.
  #
  # If 'override' is provided, the actual values in obj will be ignored and
  # all values will be set to that of the override. This is primarily useful
  # when wanting to reset values by setting them to an empty string. Note
  # null values for override will be ignored.
  #
  # Any keys in the provided 'skip' list will, as you'd expect, be skipped in
  # the wrapping but will still be present in the resulting hash.
  wrapKeys: (obj, type = 'properties', override, skip = []) ->
    wrapped = {}
    for key, value of obj
      mappedKey = if key in skip then key else "#{type}[#{key}]"
      wrapped[mappedKey] = if override? then override else value
    wrapped

  # Perform the opposite function to wrapKeys above.
  #
  # For example, {"properties[size]": "xs"} becomes {"size": "xs"}.
  unwrapKeys: (obj, type = 'properties', override) ->
    unwrapped = {}
    for key, value of obj
      unwrappedKey = key.replace("#{type}[", "").replace("]", "")
      unwrapped[unwrappedKey] = if override? then override else value
    unwrapped

  # Extend a source object with the properties of another object.
  #
  # Can be used to shallow copy an object like so:
  #   copy = extend({}, original)
  extend: (object, properties) ->
    for key, val of properties
      object[key] = val
    object

  # Clone a source object (deep copy).
  clone: (object) ->
    if not object? or typeof object isnt 'object'
      return object
    newInstance = new object.constructor()
    for key of object
      newInstance[key] = clone object[key]
    return newInstance

  # Return a key from an object and delete it.
  delete: (object, key) ->
    val = object[key]
    delete object[key]
    val

  # Return true if the given value is an array.
  isArray: Array.isArray || (value) ->
    {}.toString.call(value) is '[object Array]'

  # Ensure that the given value is returned as an array, either with entries intact or as a blank value.
  ensureArray: (value) ->
    if CartJS.Utils.isArray(value)
      return value
    if value? then [value] else []

  # Format a monetary amount using Shopify's formatMoney if available.
  #
  # If it's not available, just return the value.
  formatMoney: (value, format, formatName, currency = '') ->
    if not currency
      currency = CartJS.settings.currency

    # If we've specified a currency other than the default one, convert the value and format.
    if window.Currency? and currency != CartJS.settings.currency
      # Convert value.
      value = Currency.convert(value, CartJS.settings.currency, currency)

      # Fetch the appropriate format.
      if (window.Currency?.moneyFormats?) and (currency of window.Currency.moneyFormats)
        format = window.Currency.moneyFormats[currency][formatName]

    # Render the formatted amount using the Shopify formatter if available, else just the value.
    if window.Shopify?.formatMoney?
      Shopify.formatMoney(value, format)
    else
      CartJS.Utils.warn(FORMAT_MONEY_WARNING)
      value

  # Return a resized image URL using Shopify's getSizedImageUrl if available.
  #
  # If it's not available, just return the original URL.
  getSizedImageUrl: (src, size) ->
    if window.Shopify?.Image?.getSizedImageUrl?
      if src then Shopify.Image.getSizedImageUrl(src, size) else Shopify.Image.getSizedImageUrl('https://cdn.shopify.com/s/images/admin/no-image-.gif', size).replace('-_', '-')
    else
      if src then src else 'https://cdn.shopify.com/s/images/admin/no-image-large.gif'

  giftWrapCount: (items) ->
    giftWrapId = CartJS.settings.giftWrap
    count = 0
    if giftWrapId?
      for item in items
        if item.variant_id is giftWrapId
          count += item.quantity
    return count

  getAssociatedGiftWrapWithItem: (items, line) ->
    item = items.find((_, index) => index + 1 is parseInt line, 10 )
    return {item, giftWrap: item?.giftWrap()}
