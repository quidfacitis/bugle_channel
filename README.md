# The Bugle Channel

A Roku home for `The Bugle` podcast, as well as its sister podcasts `The Gargle`, `Richie Firth: Travel Hacker`, `Ashes Zaltzcast`, `Catharsis`, and `The Last Post`

## Channel Flow

* On app launch, the six podcasts from the Bugleverse are displayed in a PosterGrid
* Selecting a podcast displays a page containing a LabelList with all the episodes for that podcast
* Selecting an episode displays a page with an Audio node and custom progress bar to play the episode
* Pressing "back" on the remote displays the previous page

## How to Sideload the Channel Locally

Open the app in VS Code. Add the directory `.vscode` to the root of the app. In that directory, add the file `launch.json` with the following contents:

```
{
  "version": "1",
  "configurations": [
    {
      "name": "Brightscript Debugger - Launch",
      "type": "brightscript",
      "request": "launch",
      "host": "<YOUR_ROKU_IP>",
      "password": "<YOUR_ROKU_PASSWORD>",
      "rootDir": "${workspaceFolder}"
    }
  ]
}
```

Once this is done, select "Run > Start Debugging" to sideload the app.
