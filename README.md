# `shibboleth-idp-docker`

## Shibboleth v4 Identity Provider Deployment using Docker

This project represents my fork of [@iay](https://github.com/iay/shibboleth-idp-docker)'s personal deployment of the [Shibboleth](http://shibboleth.net) [v4 Identity Provider](https://wiki.shibboleth.net/confluence/display/IDP4) software using the [Docker](http://www.docker.com) container technology. See Ian's [README.md](README.iay.md) for more info.

This fork represents my attempt at getting together a quick package with which we can deploy an IDP quickly to an Azure Container Instance, using Azure Shared Files as backing for the relevant directories.

## Usage

### Preliminaries

The following steps need to be executed to "prime" the repo:

1. Edit `VERSIONS` to specify the version of Java, Jetty, and Shibboleth that you want to use.
2. Execute `./fetch-jetty` and alter the keystore passwords in `jetty-base-9.4/start.d/idp.ini`
3. Execute `./fetch-shib`
4. Edit the `install-idp` script to change the critical elements

   * `TSPASS` and `SEALERPASS` are passwords to use if the trust fabric credentials or data sealer keystores,
   respectively, need to be generated. It's arguable whether changing the default `changeit` values
   really adds any security given that the values are just put in the clear in property files anyway.
   I recommend leaving the values at their defaults.
   * `SCOPE` should be your organizational scope (`example.org` by default).
   * `HOST` is built from `SCOPE` by prepending `idp.`, which possibly won't suit you.
   * `ENTITYID` is built from `HOST`. The default here is the same as the interactive install would suggest.

5. Execute `./install`

  Executing the `./install` script will now run the Shibboleth install process in a container based on the
  configured Docker Java image. If you do not have a `shibboleth-idp` directory, this will act like a first-time
  install using the parameters you set before, resulting in a basic installation in that directory.

  If `shibboleth-idp` already exists, `./install` will act to upgrade it to the latest distribution. This should
  be idempotent; you should be able to just run `./install` at any time without changing the results. In this
  case, the variables set at the top of the `install` script won't have any effect as the appropriate values
  are already frozen into the configuration.

6. Execute `./gen-selfsigned-cert` to generate cert for SSL (HTTPS). Use `changeit` for the passwords unless you edited them in Step #4 above.

### Run Locally

If you wish to execute the repo locally, simply ensure that you've selected the default Docker context, and run the build and run scripts.

  ```bash
  ./build
  ./run
  ```

You can validate that you're up and running by visiting: [`https://localhost/idp/shibboleth`](https://localhost/idp/shibboleth)

You can edit your IDP's config by modifying the files in `./shibboleth-idp` to your hearts content, just make sure to `./terminate` the running instance and re-run `./run` or `./build` and `./run` as necessary.

### Run within Azure

1. Build the image:

  ```bash
  ./build
  ```

2. Follow the instructions [here](https://docs.docker.com/cloud/aci-integration/) to:
   
   1. Log your docker client into Azure

    `docker login azure`

   2. Create a context for Azure, i.e.

    `docker context create aci idme_aci_context`

   3. Tag the image you just built in the previous step and upload to an Azure Container Registry for your organization, i.e.

    ```bash
    docker tag shibboleth-idp:9.4.40 idmeregistry.azurecr.io/shibboleth-idp
    docker push idmeregistry.azurecr.io/shibboleth-idp
    ```

    For information on creating an Azure Container Registry see: https://docs.microsoft.com/en-us/azure/container-registry/

    4. In order to provide the container access to the volumes used, namely `/opt/shibboleth-idp` and `/opt/jetty-base/logs`, which when running in the default context are just static binds to the local directories, we need to make sure those exist within an Azure [File Share](https://azure.microsoft.com/en-us/services/storage/files/#overview).

    5. The script `upload_azure.sh` uses [`AzCopy`](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10) to create the relevant file shares within an Azure Storage account, and upload the contents of `./opt/shibboleth-idp` for use by the container. You can access the jetty logs from the `jettyshare`. You need to supply the secrets for your Azure storage account as described in the [example file](EXAMPLE_azure.secrets). The file name should be: [```azure.secrets```](EXAMPLE_azure.secrets). Run this script to create and upload the contents needed by the container.
   
    ```bash
    ./upload_azure.sh
    ```
    
    6. Edit the `docker-compose.yml` file to adjust the share names for your Azure instance, as well as whatever domain name you want to use.

    7. Switch to your Azure docker context, and run `docker compose up` to launch the instance.

    ```bash
    docker context use idme_aci_context
    docker compose up
    ```

    8. The container will then be reachable, in theory, at whatever FQDN is listed in your Azure Container instances dashboard:

    <p style="text-align: center">
      <img src="https://i.imgur.com/wYX7HqI.png">
    </p>

    9. You can now update DNS, if your scoped domain is within Azure, to direct traffic directly to the entityID / hostname of your container.

    10. Metadata can then be downloaded, uploaded, etc. to leverage the running IDP for dev work!

## Miscellany

### WSL Scripts    

I use Windows Subsystem for Linux for dev, and for whatever reason I can't use my Azure docker context within WSL (something about my environment most likely). To work around that, I use the wsl scripts. Don't use if you don't need them, but they might be useful if you're having that problem as well.

### Azure Storage

No doubt about it. This is a bit annoying to deal with. You can use [Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/#overview) to help deal with it a bit.

### Config Repository

If you want to overlay shibboleth configuration, and you have a directory / repo you want to overlay on top of opt/shibboleth-idp, use `sync-conf-repo.sh`.