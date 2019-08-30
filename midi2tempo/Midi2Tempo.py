from mido import MidiFile, tempo2bpm


def main():
    filename = input('Filename: ')
    filename = '{}.mid'.format(filename) if filename[-4:] != '.mid' else filename
    midi_file = MidiFile(filename)

    title = input('Title: ')
    origin = input('Origin: ')
    offset = input('Offset (default 0): ')
    offset = 0 if offset == '' else int(offset)
    write_timestamp = True if input('Include timestamp?(y/n) ').lower() == 'y' else False
    write_empty = True if input('Skip empty?(y/n) ').lower() == 'y' else False

    output = open('{}.tempo'.format(title), 'w')
    clocks_per_click = get_clocks_per_click(midi_file)
    write_metadata(output, title, origin, tempo2bpm(get_tempo(midi_file)), get_numerator(midi_file),
                   get_denominator(midi_file))
    write_notes(get_notes(midi_file, offset, clocks_per_click), output,
                get_last_timestamp(midi_file, offset, clocks_per_click), write_empty, write_timestamp)

    output.close()


def write_metadata(file, title, origin, bpm, numerator, denominator):
    file.write('{}\n'.format(title))
    file.write('{}\n'.format(origin))
    file.write('{}\n'.format(int(round(bpm))))
    file.write('{} {}\n'.format(numerator, denominator))


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


def get_notes(file, offset, clocks_per_click):
    timestamp = offset * clocks_per_click * 4
    notes = {}
    for track in file.tracks:
        for message in track:
            if message.type == 'note_on' or message.type == 'note_off':
                timestamp += message.time
                if message.type == 'note_on':
                    if timestamp // clocks_per_click not in notes.keys():
                        notes[timestamp // clocks_per_click] = {}
                    notes[timestamp // clocks_per_click][message.note // 12] = get_action(message.note)
    return notes


def get_clocks_per_click(file):
    for track in file.tracks:
        for message in track:
            if message.type == 'time_signature':
                return message.clocks_per_click


def get_tempo(file):
    for track in file.tracks:
        for message in track:
            if message.type == 'set_tempo':
                return message.tempo


def get_numerator(file):
    for track in file.tracks:
        for message in track:
            if message.type == 'time_signature':
                return message.numerator


def get_denominator(file):
    for track in file.tracks:
        for message in track:
            if message.type == 'time_signature':
                return message.denominator


def write_notes(notes, file, last_timestamp, skip_empty, write_timtestamp):
    for timestamp in range(0, last_timestamp):
        if timestamp in notes.keys():
            if write_timtestamp:
                file.write('{} '.format(timestamp))
            for lane in range(4):
                if lane in notes[timestamp].keys():
                    file.write('{}'.format(notes[timestamp][lane])) if lane == 0 \
                        else file.write(' {}'.format(notes[timestamp][lane]))
                else:
                    file.write('.') if lane == 0 else file.write(' .')
            file.write('\n')
        elif not skip_empty:
            if write_timtestamp:
                file.write('{} '.format(timestamp))
            file.write('. . . .\n'.format(timestamp))


def get_last_timestamp(file, offset, clocks_per_click):
    timestamp = offset * 4 * clocks_per_click
    for track in file.tracks:
        for message in track:
            if message.type == 'note_on' or message.type == 'note_off':
                timestamp += message.time
    return timestamp // clocks_per_click


if __name__ == '__main__':
    main()
