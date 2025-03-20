# recargas_app

## Funcionamiento

# 1 REGISTRO DE USUARIO
-Crear usuario con nombre y contraseña
-el nuevo usuario se almacena en la base de datos local
-se muestra mensaje de error en caso de ya estar registrado
-si el registro es exitoso se ingresa automaticamente a la app

# 2 inicio de sesion
-en caso de ya tener cuenta registrada el usuario puede iniciar sesion con sus credenciales
-al ingresar credenciales se busca en SQLITE, si este es valido se obtiene el token desde la api
-se almacena el token en memoria para futuras peticiones

# 3 Vista Principal
-el usuario encuentra 4 accesos directos a cada provedor de recargas, al presionar uno lo redirige a recargas y selecciona automaticamente el operador
-el usuario tiene un boton de recargas para ir a recargas sin elegir operador
-el usuario puede oprimir el boton flotante de historia para ver las recargas realizadas
-el usuario tiene boton para cerrar sesion

# 4 recargas
-el usuario ingresa el numero de celular, este debe contener 10 digitos
-el usuario ingresa el operador
-el usuario ingresa el monto de la recarga debe ser entre 1000 y 100000
-el usuario oprime el boton relizar recarga el cual registrara la recarga en base de datos

# 5 historial
-el usuario al ingresar al historial puede ver las recargas realizadas
-el usuario puede eliminar recargas realizadas
-el usuario puede modificar numero de celular, provedor y monto











