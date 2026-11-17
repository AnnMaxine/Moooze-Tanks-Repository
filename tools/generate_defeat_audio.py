"""Generate the original descending minor game-over cue without rewriting other audio."""
import math
import struct
import wave
from pathlib import Path

rate = 22050
notes = [(0.0, 67), (0.4, 63), (0.8, 60), (1.2, 55)]
samples = []
for i in range(round(2.2 * rate)):
    t = i / rate
    value = 0.0
    for start, note in notes:
        age = t - start
        if age >= 0:
            frequency = 440 * 2 ** ((note - 69) / 12)
            envelope = min(age * 80, 1) * math.exp(-age * 3.5)
            value += (math.sin(math.tau * frequency * age) + 0.2 * math.sin(math.tau * frequency * 2 * age)) * envelope
    value *= min((2.2 - t) * 8, 1)
    samples.append(value)
peak = max(abs(v) for v in samples)
output = Path(__file__).resolve().parents[1] / "assets/audio/defeat.wav"
with wave.open(str(output), "wb") as wav:
    wav.setparams((1, 2, rate, 0, "NONE", "not compressed"))
    wav.writeframes(b"".join(struct.pack("<h", round(v / peak * 23000)) for v in samples))
print(output)
