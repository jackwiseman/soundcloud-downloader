## Soundcloud Downloader
- Docker image that automatically downloads your SoundCloud likes daily.

## Usage
Here's an example docker-compose.yml file, just modify the username and path-to-downloads
```yaml
services:
  soundcloud-downloader:
    image: ghcr.io/jackwiseman/soundcloud-downloader:latest
    container_name: soundcloud-downloader
    restart: unless-stopped
    environment:
      - TZ="America/Los_Angeles"
      - USERNAME=username
    volumes:
      - ./path-to-downloads:/downloads
    logging:
      options:
        max-size: "10m"
        max-file: "3"
```
## Credits
- [xlindseyj](https://github.com/xlindseyj)
- [scdl](https://github.com/flyingrub/scdl.git)
