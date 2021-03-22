numfiles = size(inpaths)[1]
mididata = Array{Array{Int64,4},numfiles}
for ff = 1:numfiles
    infile = MIDI.readMIDIFile(inpaths[ff])
    indata = zeros(Int64, numfiles,size(infile.tracks[1].events[5:end])[1],4); # [dur, on/off, note, vel]
    for ii = 5:size(infile.tracks[1].events)[1]
        indata[ff,ii-4,:] = [
            infile.tracks[1].events[ii].dT, 
            infile.tracks[1].events[ii].status, 
            infile.tracks[1].events[ii].data[1], 
            infile.tracks[1].events[ii].data[2]]