class @InputTag
  # use to initialize a group of elements, e.g. a $('selector') list
  @initAll: (elements) ->
    $(elements).each (i, c) =>
      new InputTag c

  constructor: (@containerElem, @dismissReturnKeyPress, @createTagsUsingOutsideFunction, @onTagRemovalCallback) ->
    return unless @containerElem?

    @inputElem = $(@containerElem).find('input[type=text], input[type=search], input[type=email], input[type=number]')[0]
    @tagContainerElem = @containerElem.getElementsByClassName('js-tag-container')[0]

    return unless @inputElem? and @tagContainerElem?

    if @tagContainerElem.nodeName is 'UL'
      @tagElemType = 'li'
    else
      @tagElemType = 'span'
    @tagElemClassName = 'tag js-tag'

    @tagElementsDidChange()

    @containerElem.addEventListener 'click', (e) => @onContainerElemClick
    #@inputElem.addEventListener 'focus', (e) => @onInputFocus e
    #@inputElem.addEventListener 'blur', (e) => @onInputBlur
    @inputElem.addEventListener 'keyup', (e) => @onKeyUp e

  onContainerElemClick: (e) ->
    e.stopPropagation()
    @inputElem.focus()

  onInputFocus: (e) ->
    @inputElem.addEventListener 'keyup', (e) => @onKeyUp #unless @inputElem.hasEventListener 'keyup'

  onInputBlur: (e) ->
    @inputElem.removeEventListener 'keyup' #unless !@inputElem.hasEventListener 'keyup'

  onKeyUp: (e) ->
    switch e.keyCode
      when 13  # return
        e.preventDefault()
        @createTagFromCurrentInput() unless @dismissReturnKeyPress?
        false
      when 9  # tab
        e.preventDefault()
        @createTagFromCurrentInput()
      when 8  # backspace
        return # temporarily disabling backspace support for now. TODO: fix this
        if @inputElem.value is '' and @getTags().length
          @deleteLastTag true unless document.getSelection().type.toLowerCase() is 'range'

  createTagFromCurrentInput: ->
    tagText = @inputElem.value
    @inputElem.value = ''
    return unless tagText?

    if @createTagsUsingOutsideFunction?
      @createTagsUsingOutsideFunction tagText
    else
      @addTagElementWithText tagText

  addTagElementWithText: (text) ->
    tagElem = document.createElement @tagElemType
    tagElem.className = @tagElemClassName

    tagElem.innerText = @inputElem.value
    @addExistingTagElement tagElem

  addExistingTagElement: (tagElem) ->
    @tagContainerElem.appendChild tagElem
    @tagElementsDidChange()

  deleteTagElemAtIndex: (index) ->
    @deleteTagElem @getTags()[index]

  deleteTagElem: (tagElem, triggeredFromBackspace=false) ->
    return unless tagElem
    @tagContainerElem.removeChild tagElem
    @tagElementsDidChange()
    if triggeredFromBackspace
      @inputElem.value = tagElem.innerText.slice 0, -1

  deleteLastTag: (triggeredFromBackspace=false) ->
    tags = @getTags()
    return unless tags.length
    @deleteTagElem tags[tags.length-1], triggeredFromBackspace

  # when the tag elements have changed (a tag was added or removed)
  tagElementsDidChange: ->
    tags = @getTags()
    return unless tags.length > 0

    totalTagElemsWidth = 0
    for tagElem in tags
      totalTagElemsWidth += $(tagElem).width()
      totalTagElemsWidth += parseInt($(tagElem).css('padding-left'), 10) + parseInt($(tagElem).css('padding-right'), 10)
    if tags.length > 1
      totalTagElemsWidth += (parseInt($(tags[0]).css('margin-left'), 10) + parseInt($(tags[0]).css('margin-right'), 10)) * (tags.length-1)

    if tags.length
      $(@inputElem).css('width', ($(@inputElem).width() - totalTagElemsWidth)+'px !important')
    else
      $(@inputElem).css('width', '100% !important').focus()

  getTags: ->
    @tagContainerElem.getElementsByTagName @tagElemType
