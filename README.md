# tanda-webhook

Test Tanda Webhooks with Crystal & Kemal

## Features
### Logs requests in terminal
<img width="750" alt="image" src="https://user-images.githubusercontent.com/13454550/229633802-96039786-07ea-451b-9e54-6b9ef8b238f5.png">


### Writes to a JSON file when the program exits
<img width="750" alt="image" src="https://user-images.githubusercontent.com/13454550/229634050-074d701f-da10-42ec-954d-7bf081780303.png">

## Installation & Usage

You will need Crystal 1.11.0 installed. I recommend using [`asdf`](https://github.com/asdf-vm/asdf) with the [crystal plugin](https://github.com/asdf-community/asdf-crystal).
```sh
asdf install crystal 1.11.0
```
Or you can checkout [this link](https://crystal-lang.org/install/) for platform specific instructions

Then
1. Clone the repository
2. Run `shards install`
3. Run `./scripts/build/release.sh` to build the release binary
4. Run the program with `./bin/tanda-webhook`

You will now have a release build and a Kemal server running on port 3000. You will likely want to use [ngrok](https://ngrok.com/download) or a similar tool to expose your local server to the internet.

**Note:** If you have issues executing the release script run `chmod +x ./scripts/build/release.sh` to make the script executable.

## Development
When testing your changes locally use `crystal run ./src/tanda_webhook.cr`

This won't be as quick as the release build but compiles much faster making it quicker to test your changes
