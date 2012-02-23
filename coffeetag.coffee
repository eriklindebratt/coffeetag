class @InputTag
  # use to initialize a group of elements, e.g. a $('selector') list
  @initAll: (elements) ->
    $(elements).each (i, c) =>
      new InputTag c

  # @param boolean dismissReturnKeyPress  Set to true when hooking up to external script.
  #                                       This disables the creation of the tag element from in
  #                                       here, and relies on it being created from elsewhere.
  constructor: (@containerElem, @dismissReturnKeyPress) ->
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
        @createTagFromCurrentInput() unless @dismissReturnKeyPress
      when 9  # tab
        e.preventDefault()
        @createTagFromCurrentInput()
      when 8  # backspace
        if @inputElem.value is '' and @getTags().length
          @deleteLastTag true unless document.getSelection().type.toLowerCase() is 'range'

  createTagFromCurrentInput: ->
    return unless @inputElem.value
    @addTagElementWithText @inputElem.value
    @inputElem.value = ''

  addTagElementWithText: (text) ->
    tagElem = document.createElement @tagElemType
    tagElem.className = @tagElemClassName

    # style tag
    # TODO: remove this...
    tagElem.style.border = '1px red solid'
    tagElem.style.backgroundColor = 'yellow'
    tagElem.style.padding = '0.1em 0.6em'
    tagElem.style.borderRadius = '10px'

    tagElem.innerText = @inputElem.value
    @addExistingTagElement tagElem

  addExistingTagElement: (tagElem) ->
    @tagContainerElem.appendChild tagElem
    @tagElementsDidChange()

  deleteTagElemAtIndex: (index) ->
    @deleteTagElem @getTags()[index]

  deleteTagElem: (tagElem, triggeredFromBackspace=false) ->
    console.log tagElem
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
