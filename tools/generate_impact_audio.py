"""Generate original CC0 angry-moose and tank-impact cues; standard Python only."""
import math
import random
import struct
import wave
from pathlib import Path

OUTPUT = Path(__file__).resolve().parents[1] / "assets" / "audio"
RATE = 22050


def save(name, duration, sample):
    rng = random.Random(2030)
    values = [sample(index / RATE, rng) for index in range(round(duration * RATE))]
    peak = max(max(map(abs, values)), 0.001)
    with wave.open(str(OUTPUT / (name + ".wav")), "wb") as audio:
        audio.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        audio.writeframes(b"".join(struct.pack("<h", round(value / peak * 24000)) for value in values))


def angry(t, rng):
    envelope = min(t * 30, 1) * max(0, 1 - t / 1.1)
    rumble = math.sin(math.tau * 78 * t + 2.5 * math.sin(math.tau * 19 * t))
    rasp = math.sin(math.tau * 162 * t) * (0.65 + 0.35 * math.sin(math.tau * 27 * t))
    return (rumble + 0.65 * rasp + 0.24 * rng.uniform(-1, 1)) * envelope


def tank_hit(t, rng):
    return (math.sin(math.tau * 340 * t) + 0.55 * math.sin(math.tau * 847 * t)
            + rng.uniform(-1, 1) * 0.9) * math.exp(-t * 22) * min(t * 800, 1)


if __name__ == "__main__":
    save("moose_angry", 1.1, angry)
    save("tank_hit", 0.28, tank_hit)
