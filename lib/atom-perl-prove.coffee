AtomPerlProveView = require './atom-perl-prove-view'
{CompositeDisposable, Directory} = require 'atom'
{spawnSync} = require('child_process')
{BufferedProcess} = require('atom')


module.exports = AtomPerlProve =
    atomPerlProveView: null
    outputPanel: null
    subscriptions: null
    process: null

    activate: (state) ->

        # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
        @subscriptions = new CompositeDisposable

        # Register command that toggles this view
        @subscriptions.add atom.commands.add 'atom-workspace', 'atom-perl-prove:run-tests': => @runTests()
        @subscriptions.add atom.commands.add 'atom-workspace', 'atom-perl-prove:clear-output': => @clearOutput()

    deactivate: ->
        @outputPanel.destroy()
        @subscriptions.dispose()
        @atomPerlProveView.destroy()

    serialize: ->
        atomPerlProveViewState: @atomPerlProveView.serialize()

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

        process.env.PERL5LIB = "/home/dave/perl5/lib/perl5/x86_64-linux-gnu-thread-multi:/home/dave/perl5/lib/perl5:./lib:/data/doppler-dev/common/lib"
        # # .PERL5LIB="/home/dave/perl5/lib/perl5/x86_64-linux-gnu-thread-multi:/home/dave/perl5/lib/perl5:./lib:/data/doppler-dev/common/lib"
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
                atom.notifications.addWarning "Test Faiulures"
            else
                atom.notifications.addSuccess "All Tests Pass"
                @outputPanel.hide()
        command = "/usr/local/bin/prove"
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
