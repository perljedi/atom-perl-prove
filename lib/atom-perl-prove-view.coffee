
class AtomPerlProveView extends HTMLElement

  initialize: ->
    @classList.add("atom-perl-prove")
    closeButton = document.createElement("button")
    closeButton.classList.add("closeButton")
    closeButton.textContent = "x"
    @appendChild(closeButton)

    # Create root element
    @element = document.createElement('div')
    @element.classList.add('atom-perl-prove')

    @appendChild(@element)

    closeButton.addEventListener "click", =>
        this.destroy()


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  appendOutput: (data) ->
    newData = document.createElement("p")
    newData.textContent = data
    @appendChild(newData)

  appendError: (data) ->
    newData = document.createElement("p")
    newData.textContent = data
    newData.classList.add("errorText")
    @appendChild(newData)

  setOutput: (displayText)->
    @element.children[0].textContent = displayText

  # Tear down any state and detach
  destroy: ->
    this.remove()

  getElement: ->
    @element

module.exports = document.registerElement('prove-panel-view', prototype: AtomPerlProveView.prototype, extends: 'div')
