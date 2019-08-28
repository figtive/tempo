from mido import MidiFile


def main():
    midi_file = MidiFile('Ondel Ondel - Jakarta.mid')

    title = midi_file.filename
    output = open('{}.tempo'.format(title[:-4]), 'w')
    output.write('{}\n'
                 'Song origin\n'.format(title))
    output.write('{}\n'.format(str(get_clocks_per_click(midi_file))))
    print_notes_to_file(get_notes(midi_file), get_clocks_per_click(midi_file), output, get_last_timestamp(midi_file))

    output.close()


def get_action(note):
    action = note % 12
    if action == 0:
        return 'u'
    elif action == 1:
        return 'd'
    elif action == 2:
        return 'l'
    elif action == 3:
        return 'r'
    elif action == 4:
        return 't'
    else:
        raise ValueError


def get_notes(file):
    timestamp = 0
    notes = {}
    for track in file.tracks:
        for message in track:
            if message.type == 'note_on' or message.type == 'note_off':
                timestamp += message.time
                if message.type == 'note_on':
                    if timestamp not in notes.keys():
                        notes[timestamp] = {}
                    notes[timestamp][message.note // 12] = get_action(message.note)
    return notes


def get_clocks_per_click(file):
    for track in file.tracks:
        for message in track:
            if message.type == 'time_signature':
                return message.clocks_per_click


def print_notes_to_file(notes, clocks_per_click, file, last_timestamp):
    for timestamp in range(0, last_timestamp, clocks_per_click):
        if timestamp in notes.keys():
            for lane in range(4):
                if lane in notes[timestamp].keys():
                    file.write('{}'.format(notes[timestamp][lane])) if lane == 0 \
                        else file.write(' {}'.format(notes[timestamp][lane]))
                else:
                    file.write('.') if lane == 0 else file.write(' .')
        else:
            file.write('. . . .')
        file.write('\n')


def get_last_timestamp(file):
    timestamp = 0
    for track in file.tracks:
        for message in track:
            if message.type == 'note_on' or message.type == 'note_off':
                timestamp += message.time
    return timestamp


if __name__ == '__main__':
    main()
