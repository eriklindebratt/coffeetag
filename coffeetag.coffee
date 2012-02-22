class @InputTag
  # use to initialize a group of elements, e.g. a $('selector') list
  @initAll: (elements) ->
    $(elements).each (i, c) =>
      new InputTag c

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
          @deleteLastTag()

  createTagFromCurrentInput: ->
    return unless @inputElem.value
    @addTagElementWithText @inputElem.value
    @inputElem.value = ''


  addTagElementWithText: (text) ->
    tagElem = document.createElement @tagElemType
    tagElem.className = @tagElemClassName

    # style tag
    tagElem.style.border = '1px red solid'
    tagElem.style.backgroundColor = 'yellow'
    tagElem.style.padding = '0.1em 0.6em'
    tagElem.style.borderRadius = '10px'

    tagElem.innerText = @inputElem.value
    @addExistingTagElement tagElem

  addExistingTagElement: (tagElem) ->
    @tagContainerElem.appendChild tagElem
    allTags = @getTags()
    tagElemWidth = $(tagElem).width()
    tagElemWidth += parseInt($(tagElem).css('padding-left'), 10) + parseInt($(tagElem).css('padding-right'), 10)
    if allTags.length > 1
      tagElemWidth += parseInt($(allTags[0]).css('margin-left'), 10) + parseInt($(allTags[0]).css('margin-right'), 10)
    $(@inputElem).css('width', ($(@inputElem).width() - tagElemWidth)+'px !important')

  deleteTagElemAtIndex: (index) ->
    deleteTagElem @getTags()[index]

  deleteTagElem: (tagElem) ->
    @inputElem.value = tagElem.innerText.slice 0, -1
    $(@inputElem).css('width', ($(@inputElem).width()+$(tagElem).width())+'px !important')
    @tagContainerElem.removeChild tagElem

  deleteLastTag: () ->
    tags = @getTags()
    return unless tags.length
    @deleteTagElem tags[tags.length-1]

  getTags: () ->
    @tagContainerElem.getElementsByTagName @tagElemType
