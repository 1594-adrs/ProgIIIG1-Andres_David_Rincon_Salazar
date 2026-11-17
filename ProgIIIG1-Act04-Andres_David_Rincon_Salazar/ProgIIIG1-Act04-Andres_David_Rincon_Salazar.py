import itertools
import time

# ============================================================
# MACROS Y VARIABLES GLOBALES
# ============================================================

PALABRAS = "SEND+MORE=MONEY"
DOMINIO = frozenset(range(10))
BASE = 10
HEURISTICAS = ("ingenua", "mrv")
PROPAGACIONES = ("completa", "forwardChecking")


# ============================================================
# DEFINICIONES: FUNCIONES AUXILIARES
# ============================================================

def ParsearEcuacion(palabras):
    izquierda, resultado = palabras.replace(" ", "").upper().split("=")
    return izquierda.split("+"), resultado


def ConstruirColumnas(sumandos, resultado):
    columnas = []
    for posicion in range(len(resultado)):
        letrasColumna = [palabra[-1 - posicion] for palabra in sumandos if posicion < len(palabra)]
        acarreoEntrada = f"C{posicion}" if posicion > 0 else None
        acarreoSalida = f"C{posicion + 1}" if posicion < len(resultado) - 1 else None
        columnas.append((letrasColumna, acarreoEntrada, resultado[-1 - posicion], acarreoSalida))
    return columnas


def CopiarDominios(varDom):
    return {variable: set(valores) for variable, valores in varDom.items()}


def ValorPalabra(palabra, asignacion):
    valor = 0
    for letra in palabra:
        valor = valor * BASE + asignacion[letra]
    return valor


def ImprimirDominios(titulo, varDom):
    print(titulo)
    for variable in sorted(varDom, key=lambda v: (v.startswith("C"), v)):
        print(f"  {variable}: {sorted(varDom[variable])}")


def ImprimirSolucion(problema, asignacion):
    ancho = len(problema.resultado) + 2
    for indice, palabra in enumerate(problema.sumandos):
        signo = "+" if indice == len(problema.sumandos) - 1 else " "
        print(f"  {signo} {str(ValorPalabra(palabra, asignacion)).rjust(ancho - 2)}   ({palabra})")
    print("  " + "-" * ancho)
    print(f"    {str(ValorPalabra(problema.resultado, asignacion)).rjust(ancho - 2)}   ({problema.resultado})")
    print("  " + ", ".join(f"{letra}={asignacion[letra]}" for letra in problema.letras))


# ============================================================
# DEFINICIONES: FUNCIONES PRINCIPALES
# ============================================================

class CriptoAritmetica:
    def __init__(self, palabras, dominio, heuristica="mrv", propagacion="completa"):
        self.sumandos, self.resultado = ParsearEcuacion(palabras)
        self.letras = sorted(set("".join(self.sumandos) + self.resultado))
        self.columnas = ConstruirColumnas(self.sumandos, self.resultado)
        self.acarreos = [f"C{i}" for i in range(1, len(self.resultado))]
        self.varDom = {letra: set(dominio) for letra in self.letras}
        self.varDom.update({acarreo: set(range(len(self.sumandos))) for acarreo in self.acarreos})
        self.heuristica = heuristica
        self.propagacion = propagacion
        self.restricciones = []
        self.grado = {variable: 0 for variable in self.varDom}
        self.nodosExplorados = 0

    def AgregarRestriccion(self, metodo, variables, *parametros):
        self.restricciones.append((metodo, variables, parametros))
        for variable in set(variables):
            self.grado[variable] += 1

    def DefinirRestricciones(self):
        primerasLetras = sorted({palabra[0] for palabra in self.sumandos + [self.resultado]})
        self.AgregarRestriccion(self.RestriccionDistintoDeCero, primerasLetras)
        self.AgregarRestriccion(self.RestriccionTodosDiferentes, self.letras)
        for letrasColumna, acarreoEntrada, letraResultado, acarreoSalida in self.columnas:
            variablesColumna = [v for v in letrasColumna + [acarreoEntrada, letraResultado, acarreoSalida] if v]
            self.AgregarRestriccion(self.RestriccionColumna, variablesColumna,
                                    letrasColumna, acarreoEntrada, letraResultado, acarreoSalida)

    def RestriccionDistintoDeCero(self, variables):
        huboCambio = False
        for variable in variables:
            if 0 in self.varDom[variable]:
                self.varDom[variable].discard(0)
                huboCambio = True
        return huboCambio

    def RestriccionTodosDiferentes(self, variables):
        huboCambio = False
        for variable in variables:
            if len(self.varDom[variable]) == 1:
                valorAsignado = next(iter(self.varDom[variable]))
                for otra in variables:
                    if otra != variable and valorAsignado in self.varDom[otra]:
                        self.varDom[otra].discard(valorAsignado)
                        huboCambio = True
        valoresDisponibles = set().union(*(self.varDom[variable] for variable in variables))
        if len(valoresDisponibles) < len(variables):
            self.varDom[variables[0]].clear()
            huboCambio = True
        return huboCambio

    def RestriccionColumna(self, letrasColumna, acarreoEntrada, letraResultado, acarreoSalida):
        variables = list(dict.fromkeys(v for v in letrasColumna + [acarreoEntrada, letraResultado, acarreoSalida] if v))
        if self.propagacion == "forwardChecking" and sum(len(self.varDom[v]) > 1 for v in variables) > 1:
            return False
        letrasDistintas = [v for v in variables if not v.startswith("C")]
        soportados = {variable: set() for variable in variables}
        for valores in itertools.product(*(sorted(self.varDom[v]) for v in variables)):
            asignacion = dict(zip(variables, valores))
            if len({asignacion[letra] for letra in letrasDistintas}) < len(letrasDistintas):
                continue
            izquierda = sum(asignacion[letra] for letra in letrasColumna) + asignacion.get(acarreoEntrada, 0)
            derecha = asignacion[letraResultado] + BASE * asignacion.get(acarreoSalida, 0)
            if izquierda == derecha:
                for variable, valor in asignacion.items():
                    soportados[variable].add(valor)
        huboCambio = False
        for variable in variables:
            if soportados[variable] != self.varDom[variable]:
                self.varDom[variable] = soportados[variable]
                huboCambio = True
        return huboCambio

    def AplicarConsistenciaGlobal(self):
        while True:
            huboCambio = False
            for metodo, variables, parametros in self.restricciones:
                huboCambio = (metodo(*parametros) if parametros else metodo(variables)) or huboCambio
                if not self.EsConsistente():
                    return False
            if not huboCambio:
                return True

    def EsConsistente(self):
        return all(self.varDom[variable] for variable in self.varDom)

    def SeleccionarVariable(self):
        pendientes = [variable for variable in self.varDom if len(self.varDom[variable]) > 1]
        if not pendientes:
            return None
        if self.heuristica == "mrv":
            return min(pendientes, key=lambda v: (len(self.varDom[v]), -self.grado[v], v))
        return pendientes[0]

    def Asignacion(self):
        return {variable: next(iter(valores)) for variable, valores in self.varDom.items()}

    def EsSolucionValida(self):
        asignacion = self.Asignacion()
        valoresLetras = [asignacion[letra] for letra in self.letras]
        if len(set(valoresLetras)) != len(valoresLetras):
            return False
        if any(asignacion[palabra[0]] == 0 for palabra in self.sumandos + [self.resultado]):
            return False
        sumaIzquierda = sum(ValorPalabra(palabra, asignacion) for palabra in self.sumandos)
        return sumaIzquierda == ValorPalabra(self.resultado, asignacion)

    def Backtracking(self, soluciones):
        self.nodosExplorados += 1
        variable = self.SeleccionarVariable()
        if variable is None:
            if self.EsSolucionValida():
                soluciones.append({letra: next(iter(self.varDom[letra])) for letra in self.letras})
            return
        for valor in sorted(self.varDom[variable]):
            respaldo = CopiarDominios(self.varDom)
            self.varDom[variable] = {valor}
            if self.AplicarConsistenciaGlobal():
                self.Backtracking(soluciones)
            self.varDom = respaldo


def Resolver(palabras, heuristica, propagacion):
    problema = CriptoAritmetica(palabras, DOMINIO, heuristica, propagacion)
    problema.DefinirRestricciones()
    soluciones = []
    inicio = time.perf_counter()
    if problema.AplicarConsistenciaGlobal():
        dominiosIniciales = CopiarDominios(problema.varDom)
        problema.Backtracking(soluciones)
    else:
        dominiosIniciales = {}
    tiempo = time.perf_counter() - inicio
    return problema, dominiosIniciales, soluciones, tiempo


# ============================================================
# PROGRAMA PRINCIPAL
# ============================================================

def Main():
    print(f"Problema: {PALABRAS}\n")
    problema, dominiosIniciales, soluciones, _ = Resolver(PALABRAS, "mrv", "completa")
    ImprimirDominios("CSP k-consistente antes de buscar (dominios podados):", dominiosIniciales)

    print(f"\nSoluciones encontradas: {len(soluciones)}")
    for solucion in soluciones:
        ImprimirSolucion(problema, solucion)

    print("\nComparación de propagación x heurística de selección de variable:")
    for propagacion in PROPAGACIONES:
        for heuristica in HEURISTICAS:
            problemaCaso, _, solucionesCaso, tiempo = Resolver(PALABRAS, heuristica, propagacion)
            mismasSoluciones = sorted(map(sorted, map(dict.items, solucionesCaso))) == sorted(map(sorted, map(dict.items, soluciones)))
            assert mismasSoluciones, "Todas las configuraciones deben hallar las mismas soluciones"
            print(f"  {propagacion:>15} + {heuristica:<8}: {problemaCaso.nodosExplorados:7d} nodos, {tiempo * 1000:9.2f} ms")

    for solucion in soluciones:
        assert sum(ValorPalabra(p, solucion) for p in problema.sumandos) == ValorPalabra(problema.resultado, solucion)


if __name__ == "__main__":
    Main()
