# Wikibase docker

Generación de imagen Docker para Wikibase con la integración de las extensiones de Mediawiki necesarias para integrar autenticación con OpenID Connect

* [PluggableAuth](https://www.mediawiki.org/wiki/Extension:PluggableAuth)
* [OpenIDConnect](https://www.mediawiki.org/wiki/Extension:OpenID_Connect)

Se base en la imagen de [imagen Docker oficial de Wikibase](https://hub.docker.com/r/wikibase/wikibase)

## Generación de la imagen Docker

Para genera la imagen de docker se debe ejecutar el siguiente comando:

```
docker build . -t wikibase-docker:1.34-bundle
```

## Ejecución de la imagen

Para arrancar la imagen se seguiran los pasos estándar de la [imagen oficial de Wikibase](https://hub.docker.com/r/wikibase/wikibase). Para la autenticación / autorización, se precisa seguir la [documentación de la extensión OpenIDConnect](https://www.mediawiki.org/wiki/Extension:OpenID_Connect), que se basan la configuración mediante el fichero `LocalSettings.php`.

##  Configuración Keycloak

Como ejemplo de integración de un servicio OpenID Connect, se verá cómo se realiza con [Keycloak](https://www.keycloak.org/).

1. Creación de Realm, por ejemplo con nombre `myrealm`
2. Creación de client, por ejemplo con nombre `mediawiki`
  1. Se deberá indicar en el parámetro `Valid Redirect URIs` una expresión regular que incluya la URI de redireción válida para la instancia de Wikibase, por ejemplo `*`
  2. Marcar el parámetro `Access Type` como `confidential`, para que requiera una secret para poder interactuar con el servidor de autenticación, este secret se obtendrá de la pestaña `Credentials`, la cual aparecerá tras guardar los cambios.
3. Crear un usuario

A continuación, se añadirá la siguiente configuración en el fichero `LocalSettings.php` de Mediawiki:

```php
$wgOpenIDConnect_Config['http://localhost:8080/auth/realms/myrealm/'] = [
	'clientID' => 'mediawiki',
	'clientsecret' => '<client secret>'
];
```

Donde se indicarán:

* URL del Realm
* Client ID
* Client secret
