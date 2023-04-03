# tanda-webhook

Test Tanda Webhooks with Crystal & Kemal

## Features
### Logs requests in terminal
<img width="750" alt="image" src="https://user-images.githubusercontent.com/13454550/229565086-956c45b1-9727-41c4-83bd-1e45e7578aa0.png">

### Writes to a JSON file when the program exits
<img width="750" alt="image" src="https://user-images.githubusercontent.com/13454550/229625120-da31cdf3-6af1-4fac-9d4e-28cdd4ccc8d4.png">

## Installation & Usage

You will need Crystal 1.7.3 installed. I recommend using [`asdf`](https://github.com/asdf-vm/asdf) with the [crystal plugin](https://github.com/asdf-community/asdf-crystal).
```sh
asdf install crystal 1.7.3
```
Or you can checkout [this link](https://crystal-lang.org/install/) for platform specific instructions

Then
1. Clone the repository
2. Run `shards install`
3. Run `./scripts/build/release.sh && ./bin/tanda-webhook`

You will now have a release build and a Kemal server running on port 3000

**Note:** If you have issues executing the release script run `chmod +x ./scripts/build/release.sh` to make the script executable.

## Development
When testing your changes locally use `crystal run ./src/tanda_webhook.cr`

This won't be as quick as the release build but compiles much faster making it quicker to test your changes
