---
date: "2020-09-08"
header: "Conway's Game of Life"
summary: "My first blogpost, including small video-clips which I also posted on instagram."
---


Conway's Game of Life takes place in an infinite square grid of cells that can be either dead or live (white or black in the animations below). From generation to generation, cells either survive/come to life or die/remain dead depending on how many of their neighbours were alive:

- Live cells stay alive with 2 or 3 live neighbours (dying otherwise, as if by loneliness or overpopulation) 
- Dead cells come alive with 3 live neighbours (otherwise staying dead)

While I think hardly anyone with the slightest interest in either mathematics or programming has managed to avoid hearing about John Conway's cellular automation 'Life', it caught my attention for a couple of weekends and so I think it deserves a post.

What sparked my interest was seeing a [remarkably elegant](https://youtu.be/o9pEzgHorH0?t=1038) way of formulating the automation programmatically in Python. The idea is to represent the board of cells as a set, where the inclusion of a pair of coordinates $(x, y)$ implies that the cell at that location is alive. This makes it strikingly easy to express which cells will be alive in the following generation:


```python
def neightbours(cell: Tuple[int, int]) -> Generator[Tuple[int, int], None, None]:
    x, y = cell
    yield x + 1, y + 1
    yield x - 1, y + 1
    yield x + 1, y - 1
    yield x - 1, y - 1
    yield x + 1, y
    yield x - 1, y
    yield x, y + 1
    yield x, y - 1


def get_next(board: Set[Tuple[int, int]]) -> Set[Tuple[int, int]]:
    survival_rule = lambda cell, num_neighs: num_neighs == 3 or (num_neighs == 2 and cell in board)
    will_be_alive = lambda cell: survival_rule(cell, sum(1 for n in neighbours(cell) if n in board))
    candidates = board | {neighbour for cell in board for neighbour in neighbours(cell)}
    return {cell for cell in candidates if will_be_alive(cell)}
```

The use of such a simple generator to get the neighbours of a cell, along with that last line in `get_next`, are what particularly tickle me.


## The Glider

<video width="320" height="320" preload="none" controls>
    <source
        src="/posts/2020-09-08/glider.mp4"
        type="video/mp4"
    >
</video>

*The Glider* is one of the two most famous patterns. It looks simple enough, yet surprisingly, as it evolves, it recreates itself a few cells over from where it started. It continues gliding through its world forever.


## The Pi-heptamino

<video width="320" height="320" preload="none" controls>
    <source
        src="/posts/2020-09-08/pi.mp4"
        type="video/mp4"
    >
</video>

*The Pi-heptamino* (so named for its shape and the fact that it consists of seven (hepta) cells) is a so-called "methusela", because it takes many generations for its evolution to reach a stable pattern. It creates a beautiful symmetrical dance of cells as it evolves, and might just be my favourite.


## The R-pentamino

<video width="320" height="320" preload="none" controls>
    <source
        src="/posts/2020-09-08/r_pent.mp4"
        type="video/mp4"
    >
</video>

*The R-pentamino* (again named for its shape and number of cells) is the other most famous shape. From only five starting cells, this pattern manages to keep evolving for 1103 generations before reaching stability. A shockingly long-lived methusela.
