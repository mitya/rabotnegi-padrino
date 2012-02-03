window.q = $

$.extend Array.prototype,
  last: -> 
    this[this.length - 1]

$.extend String.prototype,
  evalJSON: -> 
    eval "(#{this})"
  unescapeHTML: ->
    @replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&')
  modelId: ->
    digitsFound = @match(/\d+/)
    digitsFound && digitsFound[0]
  blank: -> 
    /^\s*$/.test(@)
  present: -> 
    !@blank()
  trim: -> 
    $.trim(this)
  query: -> 
    $(@toString())

jQuery.extend
  initializers: {}

jQuery.fn.extend
  self: ->
    @get(0)
  dump: ->
    this
  loaded: (fn) ->
    $.initializers[@selector] ?= []
    $.initializers[@selector].push(fn)
    this
  record_id: ->
    @attr('id').split(/_|-/).last()
  requiredField: ->
    @each ->
      input = $(this)
      tip = input.attr('title')

      input.blur ->
        if input.val().present() && input.val() != tip
          input.removeClass('required-field')
        else
          input.addClass('required-field')
  tooltip: ->
    @each ->
      input = $(this)
      tip = input.attr('title')

      input.addClass('inner-tooltip').val(tip) if input.val().blank()

      input.focus ->
        input.removeClass('inner-tooltip').val('') if input.val() == tip
      input.blur ->
        input.addClass('inner-tooltip').val(tip) if input.val().blank()
      input.closest('form').submit -> 
        input.val('') if input.val() == tip
  toggle_slide_css3: ->
    if this.height() == 0 || this.css("display") == "none"
      this.css display: "none", height: "auto"
      height = this.height()
      this.css display: "block", height: 0
      this.css height: height
    else
      this.css height: 0

Spinner = -> 
  $("<span>").addClass("spinner").text('загрузка...')

$ -> 
  for selector, initializers of $.initializers
    if $(selector).length
      fn() for fn in initializers
