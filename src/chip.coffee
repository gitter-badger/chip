# # Chip

# > Chip.js 1.1.0
#
# > (c) 2013 Jacob Wright, TeamSnap
# Chip may be freely distributed under the MIT license.
# For all details and documentation:
# <https://github.com/teamsnap/chip/>

# Contents
# --------
# * [chip](chip.html) the namespace, creates apps, and registers bindings and filters
# * [App](app.html) represents an app that can have routes, controllers, and templates defined
# * [Observer](observer.html) provides a system to globally reevaluate bound expressions and dispatch updates
# * [Controller](controller.html) is used in the binding to attach data and run actions
# * [Binding](binding.html) is the base of the binding system
# * [Filter](filter.html) is the base for filtering within bindings
# * [Default binding handlers](bindings.html) registers the default binding handlers chip provides
# * [Default filters](filters.html) registers default filters provided with chip
# * [diff](diff.html) is a utility for comparing the equality of objects and arrays

# Initial setup
# -------------
# The global namespace. Everything is added onto `chip`
chip =
  
  # Initializes chip to automatically set up the DOM. This is called at page load and should not need to be called.
  init: ->
    unless chip.rootApp
      chip.rootApp = chip.app()
    chip.rootApp.init()
  
  
  # Creates a new chip app
  app: (appName) ->
    app = new App(appName)
    chip.rootApp = app if not appName
    app
  
  
  # Bindings
  # -------
  
  
  # Adds a binding handler that will be run for each attribute whose name matches `@prefix + name`. The `handler` is
  # a function that receives three arguments: the jQuery element the attribute was on, the value of the attribute
  # (usually an expression), and the controller for this area of the page.
  # 
  # If the handler removes the element from its parent (to store as a template for cloning into repeats or ifs) then
  # processing will stop on the element and its children immediately. This allows you to recurse into the element
  # with new controllers by using `element.bindTo(newChildController)`.
  # 
  # If a new controller is returned from the handler this controller will be used for the remaining handlers and the
  # children of the element.
  # 
  # The `priority` argument is optional and allows handlers with higher priority to be run before those with lower
  # priority. The default is `0`.
  #
  # If only `name` is provided the previously registered handler will be returned, or undefined if there is none.
  # 
  # **Example:** This binding handler adds pirateized text to an element.
  # ```javascript
  # chip.addBinding('my-pirate', function(element, expr, controller) {
  #   controller.watch(expr, function(value) {
  #     value = (value+'' || '')
  #       .replace(/\Bing\b/g, "in'")
  #       .replace(/\bto\b/g, "t'")
  #       .replace(/\byou\b/, 'ye')
  #       + ' arrrr!'
  #     element.text(value)
  #   }
  # }
  # ```
  # 
  # ```xml
  # <p my-pirate="post.body">This text will be replaced.</p>
  # ```
  binding: (name, priority, handler) ->
    if priority or handler
      Binding.addBinding(name, priority, handler)
    else
      Binding.bindings[name]?.handler
  
  
  # Shortcut, adds a handler that executes the expression when the named event is dispatched.
  #
  # **Example:** Handles the click event.
  #```javascript
  # chip.addEventBinding('on-click')
  # ```
  # 
  # ```xml
  # <button on-click="window.alert('hello!')">Say Hello</button>
  #```
  eventBinding: (eventName) ->
    Binding.addEventBinding(eventName)
  
  
  # Shortcut, adds a handler that responds when the given key is pressed, e.g. `chip.addEventBinding('on-esc', 27)`.
  keyEventBinding: (name, keyCode, ctrlKey) ->
    Binding.addKeyEventBinding(name, keyCode, ctrlKey)
  
  
  # Shortcut, adds a handler to set the named attribute to the value of the expression.
  # 
  # **Example**
  # ```javascript
  # chip.addAttributeBinding('attr-href')
  # ```
  # allows
  # ```xml
  # <a attr-href="'/profile/' + person.id">My Profile</a>
  # ```
  # which would result in
  # ```xml
  # <a href="/profile/368">My Profile</a>
  # ```
  attributeBinding: (name) ->
    Binding.addAttributeBinding(name)
  
  
  # Shortcut, adds a handler to toggle an attribute on or off if the value of the expression is truthy or false,
  # e.g. `chip.addAttributeToggleBinding('attr-checked')`.
  attributeToggleBinding: (name) ->
    Binding.addAttributeToggleBinding(name)
    
  # Filters
  # -------
  
  filter: (name, filter, valueFilter) ->
    if typeof filter is 'function' or typeof valueFilter is 'function'
      Filter.addFilter(name, filter, valueFilter)
      this
    else if filter # return both if true is passed, othewise just return the filter
      [ Filter.getFilter(name), Filter.getValueFilter(name) ]
    else
      Filter.getFilter(name)
  
  
  

# Initializes chip on page load
$(document).on 'ready.chip', chip.init



# Set up the listeners for path changes. Chip uses the Path.js library for routing.
# chip.listen = (element) ->
#  unless chip.appController
#    chip.createAppController()
#  Path.history.listen()
#  if Path.history.supported and element isnt false
#    # Set listeners on links to catch their clicks and use pushState instead
#    $(element or document).on 'click', 'a[href]', (event) ->
#      return if event.isDefaultPrevented() # if something else already handled this, we won't
#      return if this.host isnt location.host or this.href is location.href + '#'
#      event.preventDefault()
#      chip.redirect $(this).attr("href")


window.chip = chip
