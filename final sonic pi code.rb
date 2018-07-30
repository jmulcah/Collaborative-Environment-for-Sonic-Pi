#Set up
set :trans, 0
set :volume, 0.5
set :transB, 0
set :volumeB, 0.5
set :attackR, 0
set :decayR, 0
set :releaseR, 0
set :attackRBass, 0
set :cutoffRBass, 0
set :panRBass, 0
set :panslider, 0
set :volume1, 0
set :volume2, 0
set :cutoffRSynth2, 0
set :rateR, 0.1
set :rateRKick, 0.1

osc_send "192.168.2.151", 9000, "osc/4/fader2", 0
sleep 0.2
#Page 1 - Synth
#live loop to read slider position and record it with set :trans
live_loop :slider do
  use_real_time
  b = sync "/osc/4/fader2"
  puts "slider is ", b[0]
  set :trans,0.01+b[0]*12 # scale to +- octave
end

#live loop to read slider position and record it with set :trans
live_loop :volumeSlider do
  use_real_time
  b = sync "/osc/4/fader3"
  puts "slider is ", b[0]
  set :volume,b[0]+0.01 # scale to +- octave
end

#live loop to read slider position and record it with set :trans
live_loop :attackRotary do
  use_real_time
  b = sync "/osc/4/rotary2"
  puts "slider is ", b[0]
  set :attackR,b[0] # scale to +- octave
end

live_loop :decayRotary do
  use_real_time
  b = sync "/osc/4/rotary3"
  puts "slider is ", b[0]
  set :decayR,b[0] # scale to +- octave
end

live_loop :releaseRotary do
  use_real_time
  b = sync "/osc/4/rotary3"
  puts "slider is ", b[0]
  set :releaseR,(1+b[0]) # scale to +- octave
end

define :synthfunction do |name, noteValue, button, value|
  live_loop name do
    use_real_time
    b = sync button
    puts "toggle is ",b[0]
    if b[0] >0 #if it is active (pressed and on)
      use_synth :pretty_bell
      x=play note(noteValue)+get(:trans), amp: get(:volume),
        attack: get(:attackR), decay: get(:decayR), release: get(:releaseR), sustain: 1000 #start a very long note and record
      set value,x #save x in :x for retrieveal in following loop
      in_thread do #a thread containing a continuously running loop
        loop do
          control get(value),note: note(noteValue)+get(:trans), amp: get(:volume), note_slide: 0.1
          sleep 0.1 # wait for the slide to finish and rerun loop
        end
      end
    else # toggle has just been switch to off
      control get(value),amp: 0,amp_slide: 0.1#fade out note
      sleep 0.1
      kill get(value) # kill the long note (sustain: 1000)
    end
  end
end

# Drum notes for page 2

define :drumeffects do |name, button, name2|
  live_loop name do
    use_real_time
    b = sync button
    puts "slider is", (b[0])
    set name2, b[0]
  end
end

drumeffects :paneffect, "/osc/3/rotary5", :panR
drumeffects :rateeffect, "/osc/3/rotary6", :rateR
drumeffects :rateeffectKick, "/osc/3/rotary10", :rateRKick
drumeffects :ampeffect, "/osc/3/rotary9", :ampR
drumeffects :mixeffect, "/osc/3/rotary7", :mixR
drumeffects :decayeffect, "/osc/3/rotary8", :decayKick

live_loop :playpush do
  use_real_time
  b = sync "/osc/3/push1"
  puts "push1 is", b[0]
  if b[0] > 0
    with_fx :reverb do
      in_thread do
        loop do
          8.times do
            sample :ambi_choir,rate: get(:rateR), pan: get(:panR)
            sleep 0.5
          end
        end
      end
    end
  end
end

live_loop :playpushKick do
  use_real_time
  b = sync "/osc/3/push2"
  puts "push1 is", b[0]
  if b[0] > 0
    with_fx :wobble, phase: 2 do |w|
      with_fx :echo do
        in_thread do
          loop do
            sample :drum_heavy_kick,rate: get(:rateRKick), decay: get(:decayKick), mix: get(:mixR)
            sample :bass_hit_c, amp: get(:ampR),
              mix: get(:mixR)
            sleep 1
          end
        end
      end
    end
  end
end
synthfunction :toggle1, :c2, "/osc/4/multitoggle1/1/1", :x
synthfunction :toggle2, :d1, "/osc/4/multitoggle1/1/2", :y
synthfunction :toggle3, :e1, "/osc/4/multitoggle1/1/3", :z
synthfunction :toggle4, :f1, "/osc/4/multitoggle1/1/4", :w
synthfunction :toggle5, :g1, "/osc/4/multitoggle1/1/5", :v
synthfunction :toggle6, :a1, "/osc/4/multitoggle3/1/1", :a
synthfunction :toggle7, :b1, "/osc/4/multitoggle3/1/2", :b
synthfunction :toggle8, :c2, "/osc/4/multitoggle3/1/3", :c

#Page 3 - Bass Synth

define :Syntheffects do |name, button, name2|
  live_loop name do
    use_real_time
    b = sync button
    puts "slider is", (b[0])
    set name2, b[0]+0.01
  end
end

Syntheffects :attackRotaryBass, "/osc/2/rotary12", :attackRBass
Syntheffects :decayRotaryBass, "/osc/2/rotary13", :cutoffRBass
Syntheffects :releaseRotaryBass, "/osc/2/rotary14", :panRBass
#live loop to read slider position and record it with set :trans
live_loop :sliderB do
  use_real_time
  b = sync "/osc/2/fader6"
  puts "slider is ", b[0]
  set :transB,b[0]*12 # scale to +- octave
end

#live loop to read slider position and record it with set :trans
live_loop :volumeSliderB do
  use_real_time
  b = sync "/osc/2/fader7"
  puts "slider is ", b[0]
  set :volumeB,b[0]+0.01 # scale to +- octave
end

define :bassfunction do |name, noteValue, button, value|
  live_loop name do
    use_real_time
    b = sync button
    puts "toggle is ",b[0]
    if b[0] >0 #if it is active (pressed and on)
      use_synth :dpulse
      x=play note(noteValue)+get(:transB), amp: get(:volumeB),
        attack: get(:attackRBass), sustain: 1000 #start a very long note and record
      set value,x #save x in :x for retrieveal in following loop
      in_thread do #a thread containing a continuously running loop
        loop do
          control get(value),note: note(noteValue)+get(:transB), amp: get(:volumeB), cutoff: get(:cutoffRBass), note_slide: 0.1, pan: get(:panRBass)
          sleep 0.1 # wait for the slide to finish and rerun loop
        end
      end
    else # toggle has just been switch to off
      control get(value),amp: 0,amp_slide: 0.1#fade out note
      sleep 0.1
      kill get(value) # kill the long note (sustain: 1000)
    end
  end
end

bassfunction :toggle1B, :c1, "/osc/2/multitoggle1/1/1", :x2
bassfunction :toggle2B, :d1, "/osc/2/multitoggle1/1/2", :y2
bassfunction :toggle3B, :e1, "/osc/2/multitoggle1/1/3", :z2
bassfunction :toggle4B, :f1, "/osc/2/multitoggle1/1/4", :w2
bassfunction :toggle5B, :g1, "/osc/2/multitoggle1/1/5", :v2
bassfunction :toggle6B, :a1, "/osc/2/multitoggle3/1/1", :a2
bassfunction :toggle7B, :b1, "/osc/2/multitoggle3/1/2", :b2
bassfunction :toggle8B, :c1, "/osc/2/multitoggle3/1/3", :c2

#Page 4 - Synth 2

Syntheffects :cutoffRotarySynth2, "/osc/5/rotary19", :cutoffRSynth2
Syntheffects :panRotarySynth2, "/osc/5/fader11", :panslider

#live loop to read slider position and record it with set :trans
live_loop :volume2SliderSynth2 do
  use_real_time
  b = sync "/osc/5/fader14"
  puts "slider is ", b[0]
  set :volume2,b[0]+0.01 # scale to +- octave
end
live_loop :volume1SliderSynth2 do
  use_real_time
  b = sync "/osc/5/fader13"
  puts "slider is ", b[0]
  set :volume1,b[0]+0.01 # scale to +- octave
end
define :synth2 do |name, noteValue, button, value, volumeLevel|
  live_loop name do
    use_real_time
    b = sync button
    puts "toggle is ",b[0]
    if b[0] >0 #if it is active (pressed and on)
      use_synth :mod_dsaw
      x=play note(noteValue), amp: get(volumeLevel), sustain: 1000 #start a very long note and record
      set value,x #save x in :x for retrieveal in following loop
      in_thread do #a thread containing a continuously running loop
        loop do
          control get(value),note: note(noteValue), amp: get(volumeLevel), cutoff: get(:cutoffRSynth2), note_slide: 0.1, pan: get(:panslider)
          sleep 0.1 # wait for the slide to finish and rerun loop
        end
      end
    else # toggle has just been switch to off
      control get(value),amp: 0,amp_slide: 0.1#fade out note
      sleep 0.1
      kill get(value) # kill the long note (sustain: 1000)
    end
  end
end

synth2:toggle1S, :c1, "/osc/5/toggle2", :xS2, :volume1
synth2 :toggle2S, :d1, "/osc/5/toggle3", :yS2, :volume1
synth2 :toggle3S, :e1, "/osc/5/toggle4", :zS2, :volume2
synth2 :toggle4S, :f1, "/osc/5/toggle5", :wS2, :volume2
