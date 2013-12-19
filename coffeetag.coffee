class @InputTag
  # use to initialize a group of elements, e.g. a $('selector') list
  @initAll: (elements) ->
    $(elements).each (i, c) =>
      new InputTag c

  constructor: (@containerElem, @dismissReturnKeyPress, @createTagsUsingOutsideFunction, @onTagRemovalCallback) ->
    return unless @containerElem?

    @$containerElem = $(@containerElem)
    @$inputElem = @$containerElem.find('input[type=text], input[type=search], input[type=email], input[type=number]').eq(0)
    return unless @$inputElem.length?

    @$inputElem.attr 'disabled', 'disabled'
    @minInputElemWidth = 100
    @lastInputElemWidth = 0

    @tagElemType = 'span'
    @tagElemIdentifier = '.js-tag'
    @tagElemClassName = @tagElemIdentifier.substr(1) + 'tag'
    @totalTagElemsWidth = 0;

    @tagElementsDidChange()

    @$containerElem.on 'click', (e) => @onContainerElemClick
    #@$inputElem.on 'focus', (e) => @onInputFocus e
    #@$inputElem.on 'blur', (e) => @onInputBlur
    @$inputElem.on 'keyup', (e) => @onKeyUp e
    @$inputElem.on 'keydown', (e) => @onKeyDown e

  onContainerElemClick: (e) ->
    e.stopPropagation()
    @$inputElem.focus()

  onInputFocus: (e) ->
    @$inputElem.on 'keyup', (e) => @onKeyUp #unless @$inputElem.hasEventListener 'keyup'

  onInputBlur: (e) ->
    @$inputElem.off 'keyup' #unless !@$inputElem[0].hasEventListener 'keyup'

  onKeyUp: (e) ->
    switch e.keyCode
      when 13  # return
        e.preventDefault()
        @createTagFromCurrentInput() unless @dismissReturnKeyPress?
        false
      when 9  # tab
        e.preventDefault()
        @createTagFromCurrentInput()


  onKeyDown: (e) ->
    switch e.keyCode
      when 8  # backspace
        if @$inputElem.val() is '' and @getTags().length
          @deleteLastTag(true) unless document.getSelection().type.toLowerCase() is 'range'

  createTagFromCurrentInput: ->
    tagText = @$inputElem.val()
    return unless tagText?

    @$inputElem.val ''
    if @createTagsUsingOutsideFunction?
      @createTagsUsingOutsideFunction tagText
    else
      @addTagElementWithText tagText

  addTagElementWithText: (text) ->
    return unless text?

    tagElem = document.createElement @tagElemType
    tagElem.className = @tagElemClassName

    tagElem.innerText = @$inputElem.val()
    @addExistingTagElement tagElem

  addExistingTagElement: (tagElem) ->
    return unless $(tagElem).text()
    return if @getTag($(tagElem).text())

    $(tagElem).insertBefore @$inputElem
    @tagElementsDidChange()

  deleteTagElemAtIndex: (index) ->
    @deleteTagElem @getTags()[index]

  deleteTagElem: (tagElem, triggeredFromBackspace=false) ->
    return unless tagElem
    $(tagElem).remove()
    @tagElementsDidChange()

    #if triggeredFromBackspace
    #@$inputElem.val($.trim(tagElem.innerText))

  deleteLastTag: (triggeredFromBackspace=false) ->
    tags = @getTags()
    return unless tags.length
    @deleteTagElem tags[tags.length-1], triggeredFromBackspace

  # when the tag elements have changed (i.e. when a tag was added or removed)
  tagElementsDidChange: ->
    tags = @getTags()
    if tags.length > 0
      inputElemWidthDiff = 0
      breakRow = false
      for tagElem in tags
        inputElemWidthDiff += @tagElemWidth(tagElem) + 8
        if inputElemWidthDiff > (@maxInputElemWidth() - @minInputElemWidth)
          inputElemWidthDiff = 0
          breakRow = true
        else
          breakRow = false

      newInputElemWidth = @maxInputElemWidth() - inputElemWidthDiff
      if !breakRow and newInputElemWidth
        @$inputElem.css 'width', (newInputElemWidth-5)+'px'
        @totalTagElemsWidth = newInputElemWidth
      else
        @$inputElem.css 'width', '100% !important'

    @$containerElem.addClass 'ready'
    @$inputElem.removeAttr 'disabled'
    @$inputElem.focus()

  maxInputElemWidth: ->
    maxInputElemWidth = @$containerElem.width()
    if @includePaddingInSizeCalculations @$inputElem[0]
      maxInputElemWidth += parseInt(@$containerElem.css('padding-left'), 10) + parseInt(@$containerElem.css('padding-right'), 10)
    maxInputElemWidth

  tagElemWidth: (tagElem) ->
    width = $(tagElem).width()
    #if @includePaddingInSizeCalculations tagElem
    width += parseInt($(tagElem).css('padding-left'), 10) + parseInt($(tagElem).css('padding-right'), 10)
    width

  includePaddingInSizeCalculations: (forElem) ->
    $(forElem).css('box-sizing') isnt 'border-box'

  getTag: (text) ->
    tags = @getTags()
    for tag in tags
      if $.trim($(tag).text()) == text.toLowerCase()
        return tag
    return null

  getTags: ->
    @$containerElem.find @tagElemIdentifier
