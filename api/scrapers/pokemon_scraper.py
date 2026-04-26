# Pokémon TCG
# Las webs externas (pokemon.com, Bulbapedia) bloquean el scraping.
# Las reglas del TCG son públicas y estables, así que las incluyo directamente.
# Fuente oficial: https://www.pokemon.com/en/pokemon-tcg/rules/

from datetime import datetime
from models.rule import Rule, GameId
from scrapers.base import BaseScraper

# Reglas del reglamento oficial de Pokémon TCG (Scarlet & Violet era)
RULES_DATA = [
    {
        "id": "pokemon-001",
        "title": "Objetivo del juego",
        "category": "Win Conditions",
        "body": (
            "Ganas la partida si consigues tomar tus 6 cartas de premio antes que tu rival, "
            "si tu rival no puede robar carta al inicio de su turno, o si tu rival no tiene "
            "más Pokémon en juego."
        ),
        "examples": [],
    },
    {
        "id": "pokemon-002",
        "title": "Preparación del juego",
        "category": "Setup",
        "body": (
            "Cada jugador baraja su mazo de 60 cartas y roba 7 cartas como mano inicial. "
            "Si no tienes ningún Pokémon Básico en la mano inicial puedes mostrar tu mano, "
            "barajar y robar 7 cartas de nuevo (el rival roba 1 carta extra por cada vez "
            "que lo hagas). Coloca un Pokémon Básico boca abajo como Pokémon Activo y hasta "
            "5 Pokémon Básicos en el Banco. Pon las 6 primeras cartas del mazo boca abajo "
            "como cartas de premio."
        ),
        "examples": [],
    },
    {
        "id": "pokemon-003",
        "title": "Estructura del turno",
        "category": "Turn Structure",
        "body": (
            "En tu turno debes: (1) Robar una carta de tu mazo. "
            "(2) Realizar todas las acciones que quieras en cualquier orden: jugar Pokémon "
            "Básicos del banco, evolucionar Pokémon, colocar cartas de Energía (una por turno), "
            "jugar cartas de Entrenador, retirarte. "
            "(3) Atacar (opcional, termina tu turno). No puedes atacar en tu primer turno."
        ),
        "examples": [],
    },
    {
        "id": "pokemon-004",
        "title": "Ataques",
        "category": "Combat",
        "body": (
            "Para atacar necesitas tener las energías indicadas junto al ataque. "
            "Aplica el daño al Pokémon Activo rival y resuelve los efectos del ataque. "
            "Si el daño supera los PS del Pokémon rival, queda Fuera de Combate y su "
            "dueño descarta todas las cartas que tenía. El atacante toma una carta de premio "
            "por cada Pokémon derrotado (2 si es Pokémon EX o GX)."
        ),
        "examples": ["Si Charizard tiene 180 PS y recibe 200 de daño, queda KO."],
    },
    {
        "id": "pokemon-005",
        "title": "Debilidad y Resistencia",
        "category": "Combat",
        "body": (
            "La Debilidad multiplica el daño recibido (normalmente x2). "
            "La Resistencia resta daño recibido (normalmente -30). "
            "Aplica primero la Debilidad, luego la Resistencia, y por último otros modificadores."
        ),
        "examples": ["Un Pokémon de Fuego con Debilidad x2 al Agua recibe 100 de daño → 200."],
    },
    {
        "id": "pokemon-006",
        "title": "Retirada",
        "category": "Combat",
        "body": (
            "Una vez por turno puedes retirar tu Pokémon Activo al Banco descartando las "
            "energías indicadas en su coste de retirada. Un Pokémon del Banco pasa a ser "
            "el nuevo Activo. No puedes retirarte si tu Pokémon Activo tiene algún estado "
            "especial que lo impida."
        ),
        "examples": [],
    },
    {
        "id": "pokemon-007",
        "title": "Evolución",
        "category": "Pokémon Cards",
        "body": (
            "Para evolucionar un Pokémon coloca la carta de evolución encima de él. "
            "No puedes evolucionar en el mismo turno que jugaste ese Pokémon ni en tu "
            "primer turno. La evolución cura todos los estados especiales y el daño acumulado "
            "no se cura. Cada Pokémon solo puede evolucionar una vez por turno."
        ),
        "examples": [],
    },
    {
        "id": "pokemon-008",
        "title": "Cartas de Entrenador",
        "category": "Trainer Cards",
        "body": (
            "Hay tres tipos: Objetos (se pueden jugar varias por turno), "
            "Seguidores (solo uno por turno, al final del turno del rival si no tiene en juego) "
            "y Estadios (reemplazan al estadio activo, uno por turno). "
            "Los Objetos ACE SPEC son únicos: solo puedes llevar uno en el mazo."
        ),
        "examples": [],
    },
    {
        "id": "pokemon-009",
        "title": "Energías",
        "category": "Energy",
        "body": (
            "Solo puedes colocar una carta de Energía por turno desde la mano. "
            "Las Energías Básicas (Fuego, Agua, Planta, etc.) proporcionan 1 energía de su tipo. "
            "Las Energías Especiales pueden dar varios tipos o tener efectos adicionales. "
            "Al quedar KO un Pokémon, todas sus energías se descartan."
        ),
        "examples": [],
    },
    {
        "id": "pokemon-010",
        "title": "Condiciones Especiales",
        "category": "Special Conditions",
        "body": (
            "Quemado: coloca un contador de daño entre turnos (10 daño). "
            "Envenenado: coloca un contador de daño entre turnos (10 daño, o 30 con veneno fuerte). "
            "Dormido: no puede atacar ni retirarse, lanza moneda al inicio del turno para despertar. "
            "Paralizado: no puede atacar ni retirarse durante un turno, luego se cura. "
            "Confuso: lanza moneda al atacar; cara = ataque normal, cruz = 30 daño a sí mismo. "
            "Al retirar o evolucionar un Pokémon se curan todas las condiciones especiales."
        ),
        "examples": [],
    },
    {
        "id": "pokemon-011",
        "title": "Construcción del mazo",
        "category": "Deck Building",
        "body": (
            "El mazo debe tener exactamente 60 cartas. "
            "Máximo 4 copias de una misma carta (por nombre), excepto Energías Básicas. "
            "Solo puedes incluir 1 carta ACE SPEC. "
            "Debes tener al menos un Pokémon Básico."
        ),
        "examples": [],
    },
    {
        "id": "pokemon-012",
        "title": "Pokémon ex y Pokémon V",
        "category": "Pokémon Cards",
        "body": (
            "Los Pokémon ex y Pokémon V tienen más PS y ataques más poderosos. "
            "Cuando quedan KO, el rival toma 2 cartas de premio en lugar de 1. "
            "Los Pokémon VMAX y VSTAR también otorgan 2 premios al ser derrotados. "
            "Los Pokémon ex evolucionan normalmente desde su forma básica."
        ),
        "examples": [],
    },
]


class PokemonScraper(BaseScraper):
    game_id = GameId.pokemon
    version = "2024-SV"

    async def fetch(self) -> list[Rule]:
        now = datetime.utcnow()
        rules = []
        for entry in RULES_DATA:
            rules.append(Rule(
                id=entry["id"],
                game=GameId.pokemon,
                title=entry["title"],
                category=entry["category"],
                body=entry["body"],
                language="es",
                version=self.version,
                search_keywords=self._keywords(entry["title"], entry["body"]),
                examples=entry["examples"],
                last_updated=now,
            ))
        return rules
