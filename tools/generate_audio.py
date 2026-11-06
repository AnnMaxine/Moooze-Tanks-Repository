"""Original procedural audio; no samples or third-party material. CC0-1.0."""
import math
import random
import struct
import wave
from pathlib import Path

RATE = 22050
OUT = Path(__file__).resolve().parents[1] / "assets" / "audio"
rng = random.Random(1126)


def tone(freq, t):
    return math.sin(math.tau * freq * t)


def save(name, duration, sample):
    data = [sample(i / RATE) for i in range(round(duration * RATE))]
    peak = max(max(map(abs, data)), 0.001)
    with wave.open(str(OUT / (name + ".wav")), "wb") as wav:
        wav.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        wav.writeframes(b"".join(struct.pack("<h", round(x / peak * 23000)) for x in data))


def bell(freq, t):
    return (tone(freq, t) + 0.3 * tone(freq * 2.01, t)) * math.exp(-t * 5) * min(t * 150, 1)


# Original 16-second celesta phrase, with a seamless periodic bass bed.
notes = [72, 76, 79, 83, 81, 79, 76, 74, 69, 72, 76, 79, 77, 76, 74, 71,
         72, 76, 79, 84, 83, 79, 76, 74, 77, 81, 79, 76, 74, 71, 72, 67]


def music(t):
    value = 0.0
    for j, note in enumerate(notes):
        age = (t - j * 0.5) % 16
        if age < 3:
            value += 0.45 * bell(440 * 2 ** ((note - 69) / 12), age)
    return value + 0.06 * tone(131, t) + 0.04 * tone(196, t)


save("music", 16, music)
save("idle", 2, lambda t: (tone(44, t) + 0.3 * tone(88, t)) * (0.75 + 0.15 * tone(8, t)))
save("moose_blast", 0.42, lambda t: (0.65 * tone(130 - 90 * t, t) + 0.35 * rng.uniform(-1, 1)) * math.exp(-t * 12) * min(t * 200, 1))
save("moose_roar", 1.15, lambda t: (tone(95 + 8 * math.sin(t * 6), t) + 0.5 * tone(191, t) + 0.12 * rng.uniform(-1, 1)) * math.sin(math.pi * t / 1.15) ** 2)
save("victory", 2.6, lambda t: sum(bell(440 * 2 ** ((n - 69) / 12), t - start) * 0.5 for start, n in [(0, 72), (0.25, 76), (0.5, 79), (0.85, 84), (0.85, 76), (0.85, 79)] if t >= start))
