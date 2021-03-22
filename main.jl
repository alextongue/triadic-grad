## Usings
using PyPlot
using Printf

## Params
f_start         = 100. # starting frequency (arb?)
fres            = 10 # resolution per semitone
frange          = 8 # semitone range
harmonics       = 4 # how many harmonics to iterate over (after fundamental)
harm_rolloff    = 3 # rolloff
ctones          = 3 # triads (not working)

## Build frequency and semitone grids
semi2freq(semis) = 2^(semis/12)
freq2semi(f0,f1) = 12*log2.(f1./f0)

steps = frange*fres+1
coord_semis = range(0, length=steps, stop=frange)
semi_multipliers = semi2freq.(coord_semis)
semi_grid = repeat(semi_multipliers,1,steps)
grid_depth = ctones*harmonics
#f_stop = f_start*semi2freq(frange)

fgrid = zeros(steps,steps,grid_depth)
harmonic_weights = zeros(grid_depth)
h = 1
fgrid[:,:,(h-1)*ctones+1] .= h*f_start
fgrid[:,:,(h-1)*ctones+2] = h*fgrid[:,:,(h-1)*ctones+1].*semi_grid # chord tone 2
fgrid[:,:,(h-1)*ctones+3] = h*fgrid[:,:,(h-1)*ctones+2].*transpose(semi_grid) # chord tone 3
harmonic_weights[(h-1)*ctones.+(1:3)] .= 10^(-(h-1)*harm_rolloff/20)

if harmonics > 1
    for h = 2:harmonics
        fgrid[:,:,(h-1)*ctones.+(1:3)] = h*fgrid[:,:,(h-2)*ctones.+(1:3)]
    end
end

sort!(fgrid; dims=3);

##
cookvalence(diff,e=1.558) = (2*diff/e).*exp.(-(diff.^4)/4)
cooktension(diff,a=0.60) = exp.(-(diff/a).^2)

valences = zeros(steps,steps)
tensions = zeros(steps,steps)
for startpos = 1:(grid_depth-(ctones-1))
    for endpos = grid_depth:-1:startpos+2
        for midpos = (startpos+1):(endpos-1)
            fdiff = freq2semi(fgrid[:,:,startpos],fgrid[:,:,midpos]) .- freq2semi(fgrid[:,:,midpos],fgrid[:,:,endpos])
            global valences += cookvalence(fdiff)
            global tensions += cooktension(fdiff)
        end
    end
end

##
fig1 = PyPlot.figure()
PyPlot.plot_surface(coord_semis,coord_semis,valences, cmap="twilight_shifted")
display(fig1)

##
fig2 = PyPlot.figure()
PyPlot.plot_surface(coord_semis,coord_semis,tensions, cmap="coolwarm")
display(fig2)