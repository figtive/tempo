from mido import MidiFile, tempo2bpm


def main():
    midi_file = MidiFile('test2.mid')
    output = open('test_output.tempo', 'w')

    title = midi_file.filename

    print(tempo2bpm(midi_file.tracks[0][1].tempo))

    timestamp = 0
    for message in midi_file.tracks[1]:
        if message.type == 'note_on':
            if message.channel == 0 and message.velocity != 0:
                print('found')


if __name__ == '__main__':
    main()
