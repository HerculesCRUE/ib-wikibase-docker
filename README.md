
![](./images/logos_feder.png)



| Entregable     | Procesador de datos                                        |
| -------------- | ------------------------------------------------------------ |
| Fecha          | 25/05/2020                                                   |
| Proyecto       | [ASIO](https://www.um.es/web/hercules/proyectos/asio) (Arquitectura Sem醤tica e Infraestructura Ontol骻ica) en el marco de la iniciativa [H閞cules](https://www.um.es/web/hercules/) para la Sem醤tica de Datos de Investigaci髇 de Universidades que forma parte de [CRUE-TIC](http://www.crue.org/SitePages/ProyectoHercules.aspx) |
| M骴ulo         | Wikibase Docker                                             |
| Tipo           | Software                                                     |
| Objetivo       | Generaci贸n de imagen Docker para Wikibase con la integraci贸n de las extensiones de Mediawiki necesarias para integrar autenticaci贸n con OpenID Connect |
| Estado         | **100%** Imagen de docker generada |
| Pr髕imos pasos | Realizar modificaciones necesarias edurante el desarrollo. |
| Documentaci髇  | [Manual de usuario](https://github.com/HerculesCRUE/ib-asio-docs-/blob/master/entregables_hito_1/12-An%C3%A1lisis/Manual%20de%20usuario/Manual%20de%20usuario.md)<br />[Manual de despliegue](https://github.com/HerculesCRUE/ib-asio-composeset/blob/master/README.md)<br />[Documentaci髇 t閏nica](https://github.com/HerculesCRUE/ib-asio-docs-/blob/master/entregables_hito_1/11-Arquitectura/ASIO_Izertis_Arquitectura.md) |



# Wikibase docker

Generaci贸n de imagen Docker para Wikibase con la integraci贸n de las extensiones de Mediawiki necesarias para integrar autenticaci贸n con OpenID Connect

* [PluggableAuth](https://www.mediawiki.org/wiki/Extension:PluggableAuth)
* [OpenIDConnect](https://www.mediawiki.org/wiki/Extension:OpenID_Connect)

Se base en la imagen de [imagen Docker oficial de Wikibase](https://hub.docker.com/r/wikibase/wikibase)

## Generaci贸n de la imagen Docker

Para genera la imagen de docker se debe ejecutar el siguiente comando:

```
docker build . -t wikibase-docker:1.34-bundle
```

## Ejecuci贸n de la imagen

Para arrancar la imagen se seguiran los pasos est谩ndar de la [imagen oficial de Wikibase](https://hub.docker.com/r/wikibase/wikibase). Para la autenticaci贸n / autorizaci贸n, se precisa seguir la [documentaci贸n de la extensi贸n OpenIDConnect](https://www.mediawiki.org/wiki/Extension:OpenID_Connect), que se basan la configuraci贸n mediante el fichero `LocalSettings.php`.

##  Configuraci贸n Keycloak

Como ejemplo de integraci贸n de un servicio OpenID Connect, se ver谩 c贸mo se realiza con [Keycloak](https://www.keycloak.org/).

1. Creaci贸n de Realm, por ejemplo con nombre `myrealm`
2. Creaci贸n de client, por ejemplo con nombre `mediawiki`
  1. Se deber谩 indicar en el par谩metro `Valid Redirect URIs` una expresi贸n regular que incluya la URI de redireci贸n v谩lida para la instancia de Wikibase, por ejemplo `*`
  2. Marcar el par谩metro `Access Type` como `confidential`, para que requiera una secret para poder interactuar con el servidor de autenticaci贸n, este secret se obtendr谩 de la pesta帽a `Credentials`, la cual aparecer谩 tras guardar los cambios.
3. Crear un usuario

A continuaci贸n, se a帽adir谩 la siguiente configuraci贸n en el fichero `LocalSettings.php` de Mediawiki:

```php
$wgOpenIDConnect_Config['http://localhost:8080/auth/realms/myrealm/'] = [
	'clientID' => 'mediawiki',
	'clientsecret' => '<client secret>'
];
```

Donde se indicar谩n:

* URL del Realm
* Client ID
* Client secret

## Usuarios y roles

Al integrar Wikibase con el servidor de autenticaci贸n externo, no es capaz de recoger los roles que se definan en este 煤ltimo. Debido a esto, tras el cambio de m茅todo de autenticaci贸n, no ser谩 posible acceder con los usuarios locales y por tanto todos los usuarios que se loguen ser谩n usuarios est谩ndar.

Para poder asignar roles, es preciso que al menos uno de los usuarios sea administrador, para ello, una vez logado el usuario la primera vez se crear谩 autom谩ticamente el usuario en wikibase, debiendo asignar los roles por base de datos. Wikibase dispone de varias tablas en este sentido:

- user
- user_groups

En primer lugar ser谩 necesario localizar el usuario en la tabla `user`, ejecutando la siguiente consulta:

```sql
SELECT * FROM my_wiki.user;
```

Una vez localizado y obtenido su `user_id` habr谩 que irse a la tabla `user_gropus` y asignarle los permisos. Lo m谩s sencillo es utilizar los permisos que tiene el usuario administrador (normalmente `WikibaseAdmin` con id 1) y asign谩rselos al nuevo usuario mediante la ejecuci贸n de la siguiente consulta (teniendo en cuenta que el usuario destino tenga como id el valor 2):

```sql
UPDATE `my_wiki`.`user_groups` SET `ug_user`='2' WHERE `ug_user`='1';
```

A partir de este momento, el usuario seleccionado pasar谩 a ser administrador de Wikibase.
