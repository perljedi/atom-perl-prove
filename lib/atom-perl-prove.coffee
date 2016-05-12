AtomPerlProveView = require './atom-perl-prove-view'
{CompositeDisposable, Directory} = require 'atom'
{spawnSync} = require('child_process')
{BufferedProcess} = require('atom')

module.exports = AtomPerlProve =
    atomPerlProveView: null
    outputPanel: null
    subscriptions: new CompositeDisposable
    runOnSave: false
    config:
        perlLib:
            type: 'string'
            default: process.env.HOME + "/perl5/lib/perl5/x86_64-linux-gnu-thread-multi:"+process.env.HOME + "/perl5/lib/perl5:./lib"
        proveCmd:
            type: 'string'
            default: "/usr/local/bin/prove"

    activate: (state) ->

        # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
        # @subscriptions = new CompositeDisposable

        @subscriptions.add atom.commands.add 'atom-workspace', 'atom-perl-prove:run-tests': => @runTests()
        @subscriptions.add atom.commands.add 'atom-workspace', 'atom-perl-prove:clear-output': => @clearOutput()
        @subscriptions.add atom.commands.add 'atom-workspace', 'atom-perl-prove:toggle-auto-run': => @toggleAutoRun()
        @subscriptions.add atom.workspace.observeTextEditors (editor) => @subscribeToSaveEvents(editor)

    subscribeToSaveEvents: (editor) ->
        @subscriptions.add editor.onDidSave => @autoRun()

    deactivate: ->
        @outputPanel.destroy()
        @subscriptions.dispose()
        @atomPerlProveView.destroy()

    toggleAutoRun: ->
        console.log("toggling")
        if @runOnSave
            atom.notifications.addInfo "Disabling auto-run"
            @runOnSave = false
        else
            atom.notifications.addInfo "Enabling auto-run"
            @runOnSave = true

    serialize: ->
        atomPerlProveViewState: @atomPerlProveView.serialize()

    autoRun: ->
        if @runOnSave
            @runTests()

    clearOutput: ->
        if @outputPanel.isVisible()
            @outputPanel.hide()
        else
            @outputPanel.show()

    runTests: ->
        @atomPerlProveView = new AtomPerlProveView()
        @atomPerlProveView.initialize()

        atom.notifications.addSuccess "Running Tests"
        @outputPanel = atom.workspace.addRightPanel(item: @atomPerlProveView)

        base_path = this.execSync("/usr/bin/git", new Directory(atom.workspace.getActiveTextEditor().getPath()).getParent().getPath(), "", ["rev-parse", "--show-toplevel"]).stdout.trim()

        process.env.PERL5LIB = atom.config.get('atom-perl-prove.perlLib')
        @atomPerlProveView.appendOutput "Running tests in "+ base_path
        options =
            cwd: "/data/doppler-dev/storage"
            env: process.env
        options.cwd = base_path
        args = ["-lr"]
        stdout = (data) => @atomPerlProveView.appendOutput data
        stderr = (data) => @atomPerlProveView.appendError data
        exit = (data) =>
            if data != 0
                atom.notifications.addWarning "Test Failures"
            else
                atom.notifications.addSuccess "All Tests Pass"
                @outputPanel.hide()
        command = atom.config.get('atom-perl-prove.proveCmd')
        new BufferedProcess({command, args, options, stdout, stderr, exit})

    appendData: (data) ->
        @atomPerlProveView.appendOutput data

    processComplete: (data) ->
        console.log data

    execSync: (command, cwd, env, args, input = null) ->
        options =
            cwd: cwd
            encoding: 'utf8'
        options.env = if env? then env else @environment
        if input
            options.input = input
        args = [] unless args?
        done = spawnSync(command, args, options)
        result =
            error: done?.error
            code: done?.status
            stdout: if done?.stdout? then done.stdout else ''
            stderr: if done?.stderr? then done.stderr else ''
            messages: []
        if done.error?
            if done.error.code is 'ENOENT'
                message =
                    line: false
                    column: false
                    msg: 'No file or directory: [' + command + ']'
                    type: 'error'
                    source: 'executor'
                result.messages.push(message)
                result.code = 127
            else if done.error.code is 'ENOTCONN' # https://github.com/iojs/io.js/pull/1214
                result.error = null
                result.code = 0
            else
                console.log('Error: ' + JSON.stringify(done.error))

        return result
