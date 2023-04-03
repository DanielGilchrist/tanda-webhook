# tanda-webhook

Testing Tanda Webhooks with Crystal & Kemal

## Features
### Logs requests in terminal
<img width="600" alt="image" src="https://user-images.githubusercontent.com/13454550/229538252-c735b54f-18f7-47b8-9102-540f6dab5964.png">

### Writes to a JSON file when the program exits

![image](https://user-images.githubusercontent.com/13454550/229538913-bbe5827f-94c6-410a-a4ef-313e9c26bec7.png)


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
