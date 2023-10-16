[![Generic badge](https://img.shields.io/badge/contributors-2-<COLOR>.svg)](https://github.com/elnemerakhmed/dopmam-network/graphs/contributors)


<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

## About The Project

### Built With
* [Hyperledger Fabric](https://www.hyperledger.org/use/fabric)
* [bash](https://www.gnu.org/software/bash/)
* [docker](https://www.docker.com/)
* [docker-compose](https://docs.docker.com/compose/)
* [yaml](https://yaml.org/)
* [json](https://www.json.org/json-en.html)

## Getting Started

### Prerequisites
* Hyperledger Fabric Binaries
* docker
* docker-compose
* jq

### Installation

1. Open a new terminal
2. Clone the repository using ```git clone https://github.com/elnemerakhmed/dopmam-network```

## Usage
After successfully installing the requirments and cloning the repository, do the following.
1. Open a new termenal.
2. Clean any previous run files using ```./clean.sh```
3. Start Certificate Authorites dockers using ```./ca.sh```
4. Start channel peers dockers using  ```./channel.sh```
5. Update anchor peers configurations using ```./anchor.sh```
6. Generate connection profiles using ```./ccp.sh```
7. Deploy chaincode on organizations using ```./deploycc.sh```

## Roadmap

See the [open issues](https://github.com/elnemerakhmed/dopmam-frontend/issues) for a list of proposed features (and known issues).

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the GPL License. See [LICENSE](LICENSE) for more information.

## Contact

- Akhmed El Nemer - ahmedelnemer02@gmail.com
- Waleed Mortaja - waleedmortaja@protonmail.com

Project Link: [https://github.com/elnemerakhmed/dopmam-network](https://github.com/elnemerakhmed/dopmam-network)
