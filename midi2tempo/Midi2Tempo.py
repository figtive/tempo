from mido import MidiFile, tempo2bpm


def main():
    filename = input('Filename: ')
    filename = f'{filename}.mid' if filename[-4:] != '.mid' else filename
    midi_file = MidiFile(filename)

    title = input('Title: ')
    origin = input('Origin: ')
    offset = input('Offset (default 0): ')
    offset = 0 if offset == '' else int(offset)
    write_timestamp = True if input('Include timestamp?(y/n) ').lower() == 'y' else False
    write_empty = True if input('Skip empty?(y/n) ').lower() == 'y' else False
    intro_beat = int(input('Start intro at beat: '))
    body_beat = int(input('Start body at beat: '))
    outro_beat = int(input('Start outro dance at: '))
    end_beat = int(input('End dance at: '))
    intro_frames = int(input('Intro frames count: '))
    body_frames = int(input('Body frames count: '))
    outro_frames = int(input('Outro frames count: '))

    numerator = get_numerator(midi_file)
    offset = offset * numerator
    intro_beat = intro_beat * numerator + offset
    body_beat = body_beat * numerator + offset
    outro_beat = outro_beat * numerator + offset
    end_beat = end_beat * numerator + offset

    clocks_per_click = get_clocks_per_click(midi_file)
    last_timestamp = get_last_timestamp(midi_file, offset, clocks_per_click)
    notes = get_notes(midi_file, offset, clocks_per_click)
    bpm = tempo2bpm(get_tempo(midi_file))
    denominator = get_denominator(midi_file)

    output = open(f'{title}.tempo', 'w')
    write_metadata(output, title, origin, bpm, numerator, denominator)
    write_notes(notes, output, last_timestamp, write_empty, write_timestamp, intro_beat, body_beat, outro_beat,
                end_beat, intro_frames, body_frames, outro_frames)

    output.close()


def write_metadata(file, title, origin, bpm, numerator, denominator):
    file.write(f'{title}\n')
    file.write(f'{origin}\n')
    file.write(f'{int(round(bpm))}\n')
    file.write(f'{numerator} {denominator}\n')


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
    timestamp = offset * clocks_per_click
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


def write_notes(notes, file, last_timestamp, skip_empty, write_timestamp, intro_beat, body_beat, outro_beat, end_beat,
                intro_frames, body_frames, outro_frames):
    for timestamp in range(0, last_timestamp):
        if timestamp in notes.keys():
            if write_timestamp:
                file.write(f'{timestamp} ')
            for lane in range(4):
                if lane in notes[timestamp].keys():
                    note = notes[timestamp][lane]
                    file.write(f'{note}') if lane == 0 else file.write(f' {note}')
                else:
                    file.write('.') if lane == 0 else file.write(' .')
            if timestamp == intro_beat:
                file.write(' 0\n')
            elif timestamp == body_beat:
                file.write(f' {intro_frames}\n')
            elif timestamp == outro_beat:
                file.write(f' {intro_frames + body_frames}\n')
            elif timestamp == end_beat:
                file.write(f' {intro_frames + body_frames + outro_frames}\n')
            else:
                file.write('\n')
        else:
            if timestamp == intro_beat:
                if write_timestamp:
                    file.write(f'{timestamp} ')
                file.write('. . . . 0\n')
            elif timestamp == body_beat:
                if write_timestamp:
                    file.write(f'{timestamp} ')
                file.write(f'. . . . {intro_frames}\n')
            elif timestamp == outro_beat:
                if write_timestamp:
                    file.write(f'{timestamp} ')
                file.write(f'. . . . {intro_frames + body_frames}\n')
            elif timestamp == end_beat:
                if write_timestamp:
                    file.write(f'{timestamp} ')
                file.write(f'. . . . {intro_frames + body_frames + outro_frames}\n')
            elif not skip_empty:
                if write_timestamp:
                    file.write(f'{timestamp} ')
                file.write('. . . .\n')


def get_last_timestamp(file, offset, clocks_per_click):
    timestamp = offset * clocks_per_click
    for track in file.tracks:
        for message in track:
            if message.type == 'note_on' or message.type == 'note_off':
                timestamp += message.time
    return timestamp // clocks_per_click


if __name__ == '__main__':
    main()
