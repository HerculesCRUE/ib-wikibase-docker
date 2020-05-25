
![](./images/logos_feder.png)



| Entregable     | Procesador de datos                                        |
| -------------- | ------------------------------------------------------------ |
| Fecha          | 25/05/2020                                                   |
| Proyecto       | [ASIO](https://www.um.es/web/hercules/proyectos/asio) (Arquitectura Semántica e Infraestructura Ontológica) en el marco de la iniciativa [Hércules](https://www.um.es/web/hercules/) para la Semántica de Datos de Investigación de Universidades que forma parte de [CRUE-TIC](http://www.crue.org/SitePages/ProyectoHercules.aspx) |
| Módulo         | Wikibase Docker                                             |
| Tipo           | Software                                                     |
| Objetivo       | Generación de imagen Docker para Wikibase con la integración de las extensiones de Mediawiki necesarias para integrar autenticación con OpenID Connect |
| Estado         | **100%** Imagen de docker generada |
| Próximos pasos | Realizar modificaciones necesarias edurante el desarrollo. |
| Documentación  | [Manual de usuario](https://github.com/HerculesCRUE/ib-asio-docs-/blob/master/entregables_hito_1/12-An%C3%A1lisis/Manual%20de%20usuario/Manual%20de%20usuario.md)<br />[Manual de despliegue](https://github.com/HerculesCRUE/ib-asio-composeset/blob/master/README.md)<br />[Documentación técnica](https://github.com/HerculesCRUE/ib-asio-docs-/blob/master/entregables_hito_1/11-Arquitectura/ASIO_Izertis_Arquitectura.md) |



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

## Usuarios y roles

Al integrar Wikibase con el servidor de autenticación externo, no es capaz de recoger los roles que se definan en este último. Debido a esto, tras el cambio de método de autenticación, no será posible acceder con los usuarios locales y por tanto todos los usuarios que se loguen serán usuarios estándar.

Para poder asignar roles, es preciso que al menos uno de los usuarios sea administrador, para ello, una vez logado el usuario la primera vez se creará automáticamente el usuario en wikibase, debiendo asignar los roles por base de datos. Wikibase dispone de varias tablas en este sentido:

- user
- user_groups

En primer lugar será necesario localizar el usuario en la tabla `user`, ejecutando la siguiente consulta:

```sql
SELECT * FROM my_wiki.user;
```

Una vez localizado y obtenido su `user_id` habrá que irse a la tabla `user_gropus` y asignarle los permisos. Lo más sencillo es utilizar los permisos que tiene el usuario administrador (normalmente `WikibaseAdmin` con id 1) y asignárselos al nuevo usuario mediante la ejecución de la siguiente consulta (teniendo en cuenta que el usuario destino tenga como id el valor 2):

```sql
UPDATE `my_wiki`.`user_groups` SET `ug_user`='2' WHERE `ug_user`='1';
```

A partir de este momento, el usuario seleccionado pasará a ser administrador de Wikibase.
