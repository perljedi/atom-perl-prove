# atom-perl-prove package

Run tests for your perl based project using `prove` from within atom.

When activated, this package will check what the base directory for the git repository for the current
file, and execute `prove -lr t` from within that directory.  While tests are running, output from
prove will stream into a newly opened panel.  The panel will automatically be hidden when the command
completes if all tests pass, and will remain visible otherwise.  The output pane visibility can be toggled
with the Show/Hide test output toggle.

![Screenshot of Perl-Prove output](https://raw.githubusercontent.com/perljedi/atom-perl-prove/master/atom-perl-prove-screenshot.png)
