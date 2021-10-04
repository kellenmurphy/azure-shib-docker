# Testing IDP Configs w/ this Docker Image (Locally)

- There's a free test LDAP server provided by [ForumSys](https://www.forumsys.com/tutorials/integration-how-to/ldap/online-ldap-test-server/) that you can use as an AuthSource, use the `conf/ldap.properties` file, the `authn/authn.properties` file and the `credentials/secrets.properties` file in `testing_resources` inside your `shibboleth-idp` config.

## Use SAMLTest.id

- Upload your IDP metadata: https://samltest.id/upload.php

- Use the `relying-party.xml` and `metadata-providers` from `testing_resources/conf` to enable `UnverifiedRelyingParty` access and SAMLtest.id.