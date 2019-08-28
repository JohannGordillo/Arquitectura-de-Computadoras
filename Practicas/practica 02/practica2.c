/* ======================================
 * >> Autor: Johann Gordillo
 * >> Email: jgordillo@ciencias.unam.mx
 * >> Fecha: 25/08/2019
 * ======================================
 *     Organización y Arquitectura de
 *         Computadoras [2020-1]
 *
 *              Práctica #02
 *           "Introducción a C"
 *
 * El programa indica de entre un grupo
 * de computadoras cuál tiene un mejor
 * desempeño, dependiendo de si se mide
 * tiempo de respuesta o rendimiento.
 * ======================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

double media_aritmetica(double *datos, int n);
double media_armonica(double *datos, int n);
double media_geometrica(double *datos, int n);
double* normalizar(double *datos, int n, double *referencia);
double n_raiz(int n, double val);
int indice_maximo(double *datos, int n);
int indice_minimo(double *datos, int n);
void libera_matriz(double **matriz,int n, int m);
double** matriz_double(int n, int m);

/* ------------------------------------------
 * Función: main
 * ------------------------------------------
 * Función principal del programa.
 *
 * >> argc:
 * Número de argumentos pasados línea de
 * comandos.
 *
 * >> argv:
 * Arreglo de apuntadores con las siguientes
 * cadenas:
 * - Nombre del programa.
 * - Nombre del archivo.
 *
 * >> regresa:
 * 0 si la ejecución fue exitosa.
 */
int main(int argc, const char *argv[])
{
	FILE *archivo = fopen(argv[1], "r"); // Abrimos el archivo en modo lectura.

    if(archivo == NULL)
    {
        printf("Ocurrio un error al intentar abrir el archivo %s.\n", argv[1]);
        return 1;
    }

	int num_compus, num_pruebas;

	char medida; // T: Tiempo de respuesta.
                 // R: Rendimiento.

    // Leemos número de computadoras, de pruebas y tipo de prueba de desempeño.
	fscanf(archivo, "%d %d %c", &num_compus, &num_pruebas, &medida);

	// Matriz de dos dimensiones donde almacenaremos los resultados de las pruebas.
	double **resultados = matriz_double(num_compus, num_pruebas);

    // Llenamos la matriz anterior con los resultados contenidos en el archivo.
	for(int i=0; i<num_compus; i++)
	{
        for(int j=0; j<num_pruebas; j++)
            fscanf(archivo, "%lf ", &resultados[i][j]);
	}

    // Arreglo para guardar los datos normalizados.
    double **datos_normalizados = matriz_double(num_compus, num_pruebas);

    // Arreglo para ir guardando las medias de tendencia central obtenidas.
    double *medias = (double*)malloc(sizeof(double) * num_compus);

    // Normalizando los resultados respecto a la primera computadora.
    for(int i=0; i<num_compus; i++)
    {
        datos_normalizados[i] = normalizar(resultados[i], num_pruebas, resultados[0]);
        medias[i] = media_geometrica(datos_normalizados[i], num_pruebas);
    }

    // Variable para guardar el indice correspondiente a la mejor computadora.
    int indice_mejor;

    // Caso en el que sean pruebas de Tiempo de Respuesta.
    if(medida == 'T')
    {
        // La mejor compu será la de menor media geométrica.
        indice_mejor = indice_minimo(medias, num_compus);

        // Calculamos la media armónica de cada computadora.
        for(int i=0; i<num_compus; i++)
            medias[i] = media_armonica(resultados[i], num_pruebas);

        // Imprimimos en qué factor es mejor la compu con mayor desempeño a las demás.
        for(int i=0; i<num_compus; i++)
            printf("%lf ", medias[i] / medias[indice_mejor]);
    }

    // Caso en el que sean pruebas de Rendimiento.
    else
    {
        // La mejor compu será la de mayor media geométrica.
        indice_mejor = indice_maximo(medias, num_compus);

        // Calculamos la media aritmética de cada computadora.
        for(int i=0; i<num_compus; i++)
            medias[i] = media_aritmetica(resultados[i], num_pruebas);

        // Imprimimos en qué factor es mejor la compu con mayor desempeño a las demás.
        for(int i=0; i<num_compus; i++)
            printf("%lf ", medias[indice_mejor] / medias[i]);
    }

    // Liberamos memoria.
    libera_matriz(resultados, num_compus, num_pruebas);
    libera_matriz(datos_normalizados, num_compus, num_pruebas);
    free(medias);

    printf("\n");

	return 0;
}

/* ------------------------------------------
 * Función: media_aritmetica
 * ------------------------------------------
 * Calcula la media aritmética de un
 * arreglo de datos.
 *
 * >> datos:
 * Arreglo de doubles con los
 * resultados de las pruebas.
 *
 * >> n:
 * Número de elementos en el arreglo.
 *
 * >> regresa:
 * La media aritmética de los datos.
 */
double media_aritmetica(double *datos, int n)
{
    double sum = 0;

	for(int i=0; i<n; i++)
        sum += datos[i];

	return sum/n;
}

/* ------------------------------------------
 * Función: media_armonica
 * ------------------------------------------
 * Calcula la media armónica de un
 * arreglo de datos.
 *
 * >> datos:
 * Arreglo de doubles con los
 * resultados de las pruebas.
 *
 * >> n:
 * Número de elementos en el arreglo.
 *
 * >> regresa:
 * La media armónica de los datos.
 */
double media_armonica(double *datos, int n)
{
    double sum = 0.0;

	for(int i=0; i<n; i++)
        sum += 1.0/datos[i];

	return n/sum;
}


/* ------------------------------------------
 * Función: media_geometrica
 * ------------------------------------------
 * Calcula la media geométrica de un
 * arreglo de datos normalizados.
 *
 * >> datos:
 * Arreglo de doubles con los
 * resultados de las pruebas.
 *
 * >> n:
 * Número de elementos en el arreglo.
 *
 * >> regresa:
 * La media geométrica de los datos.
 */
double media_geometrica(double *datos, int n)
{
	double prod = 1.0;

	for(int i=0; i<n; i++)
        prod *= datos[i];

	return n_raiz(n, prod);
}

/* ------------------------------------------
 * Función: normalizar
 * ------------------------------------------
 * Normaliza un arreglo de datos respecto
 * a un valor de referencia.
 *
 * >> datos:
 * El arreglo con los datos a nornmalizar.
 *
 * >> n:
 * El número de datos en el arreglo.
 *
 * >> datos_referencia:
 * Los datos de referencia respecto a los
 * cuales normalizar el primer arreglo de
 * datos.
 *
 * >> regresa:
 * Un arreglo con los datos normalizados.
 */
double* normalizar(double *datos, int n, double *datos_referencia)
{
    double *datos_normalizados = (double*)malloc(sizeof(double) * n);

    for(int i=0; i<n; i++)
        datos_normalizados[i] = datos[i]/datos_referencia[i];

    return datos_normalizados;
}

/* ------------------------------------------
 * Función: n_raiz
 * ------------------------------------------
 * Calcula la raíz n-ésima de un valor.
 *
 * >> n:
 * El número de raíz.
 *
 * >> val:
 * El valor a aplicarle la raíz n-ésima.
 *
 * >> regresa:
 * La n-ésima raiz de un valor dado.
 */
double n_raiz(int n, double val)
{
    double res = exp(log(val)/n);
    return res;
}

/* ------------------------------------------
 * Función: indice_minimo
 * ------------------------------------------
 * Encuentra el indice del elemento minimo
 * de un arreglo de doubles.
 *
 * >> datos:
 * El arreglo de doubles.
 *
 * >> n:
 * La cantidad de elementos en el arreglo.
 *
 * >> regresa:
 * El indice del elemento minimo
 * del arreglo.
 */
int indice_minimo(double *datos, int n)
{
    double min_elem = 100000;
    int min_index = 0;
    for(int i=0; i<n; i++)
    {
        if(datos[i] < min_elem)
        {
            min_index = i;
            min_elem = datos[i];
        }
    }
    return min_index;
}

/* ------------------------------------------
 * Función: indice_maximo
 * ------------------------------------------
 * Encuentra el indice del elemento máximo
 * de un arreglo de doubles.
 *
 * >> datos:
 * El arreglo de doubles.
 *
 * >> n:
 * La cantidad de elementos en el arreglo.
 *
 * >> regresa:
 * El indice del elemento máximo
 * del arreglo.
 */
int indice_maximo(double *datos, int n)
{
    double max_elem = 0;
    int max_index = 0;
    for(int i=0; i<n; i++)
    {
        if(datos[i] > max_elem)
        {
            max_index = i;
            max_elem = datos[i];
        }
    }
    return max_index;
}

/* ------------------------------------------
 * Función: matriz_double
 * ------------------------------------------
 * Crea una matriz de doubles con las
 * dimensiones dadas.
 *
 * >> n:
 * El número de renglones.
 *
 * >> m:
 * El número de columnas.
 *
 * >> regresa:
 * Una matriz de doubles de n x m.
 */
double** matriz_double(int n, int m)
{
    //reserva memoria para un arreglo de apuntadores a double.
    double **matriz = (double**)malloc(sizeof(double*) * n);

    for (int i=0; i<n; i++)
        //reserva memoria para un arreglo de doubles y se lo asigna a cada apuntador de apuntador.
        matriz[i] = (double*)malloc(sizeof(double) * m);

    return matriz;
}

/* ------------------------------------------
 * Función: libera_matriz
 * ------------------------------------------
 * Libera la memoria ocupada por una
 * matriz con las dimensiones dadas.
 *
 * >> matriz:
 * Una matriz de doubles.
 *
 * >> n:
 * El número de renglones en la matriz.
 *
 * >> m:
 * El número de columnas en la matriz.
 */
void libera_matriz(double **matriz, int n, int m)
{
    for (int i=0; i<n; i++)
         free(matriz[i]); // Libera cada arreglo de forma individual.

    free(matriz); // Libera el arreglo de apuntadores.
}
