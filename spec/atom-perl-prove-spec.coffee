AtomPerlProve = require '../lib/atom-perl-prove'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AtomPerlProve", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('atom-perl-prove')

  describe "when the atom-perl-prove:run-tests event is triggered", ->
    beforeEach ->
      activeEditor =
        getPath: ->

      spyOn(activeEditor, 'getPath').andReturn("/home/dave/atom/package/test")
      spyOn(atom.workspace, 'getActiveTextEditor').andReturn(activeEditor)
      spyOn(atom.notifications, 'addSuccess')

    it "Creates a notification when it begins", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.atom-perl-prove')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'atom-perl-prove:run-tests'

      waitsForPromise ->
        activationPromise

      runs ->
          expect(atom.notifications.addSuccess).toHaveBeenCalledWith("Running Tests")

    it "Shows the pane when run", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.atom-perl-prove')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'atom-perl-prove:run-tests'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.atom-perl-prove')).toExist()

        atomPerlProveElement = workspaceElement.querySelector('.atom-perl-prove')
        expect(atomPerlProveElement).toExist()

        atomPerlProvePanel = atom.workspace.panelForItem(atomPerlProveElement)
        expect(atomPerlProvePanel.isVisible()).toBe true
