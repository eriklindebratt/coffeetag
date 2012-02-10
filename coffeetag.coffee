class InputTag
  # use to initialize a group of elements, e.g. a $('selector') list
  @initAll: (elements) ->
    $(elements).each (i, c) =>
      new InputTag c

  constructor: (@containerElem) ->
    return unless @containerElem?

    @inputElem = @containerElem.getElementsByTagName('input')[0]
    @tagContainerElem = @containerElem.getElementsByClassName('tag-container')[0]
    
    return unless @inputElem? and @tagContainerElem?

    @tagElemType = 'span'
    @tagElemClassName = 'tag'

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
        @createTagFromCurrentInput()
      when 9  # tab
        e.preventDefault()
        @createTagFromCurrentInput()
      when 8  # backspace
        if @inputElem.value is '' and @getTags().length
          @deleteLastTag()

  createTagFromCurrentInput: () ->
    return unless @inputElem.value
    tagElem = document.createElement @tagElemType
    tagElem.className = @tagElemClassName

    # style tag
    tagElem.style.border = '1px red solid'
    tagElem.style.backgroundColor = 'yellow'
    tagElem.style.padding = '0.1em 0.6em'
    tagElem.style.borderRadius = '10px'

    tagElem.innerText = @inputElem.value
    @tagContainerElem.appendChild tagElem
    @inputElem.style.width = parseInt(@inputElem.style.width, 10) - parseInt(tagElem.style.width, 10) + 'px'
    @inputElem.value = ''

  deleteLastTag: () ->
    tags = @getTags()
    return unless tags.length
    lastTagElem = tags[tags.length-1]
    @inputElem.value = lastTagElem.innerText.slice 0, -1
    @inputElem.width = parseInt(@inputElem.width, 10) + parseInt(lastTagElem.style.width, 10) + 'px'
    @tagContainerElem.removeChild lastTagElem

  getTags: () ->
    @tagContainerElem.getElementsByTagName @tagElemType
