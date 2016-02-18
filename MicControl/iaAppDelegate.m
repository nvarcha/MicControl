//
//  iaAppDelegate.m
//  MicControl
//
//  Created by Nicolas Varchavsky on 4/1/14.
//  Copyright (c) 2014 Interatica. All rights reserved.
//

#import "iaAppDelegate.h"
#include <CoreAudio/AudioHardware.h>
#import <CoreAudio/CoreAudio.h>

@implementation iaAppDelegate
@synthesize statusMenu;
@synthesize frequencyMenu;
@synthesize slider;
@synthesize sliderItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar]
                  statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setHighlightMode:YES];
    //[statusItem setTitle:@""];
//    [statusItem setTitle:[NSString
//                          stringWithFormat:@"%C",(unichar)0x2295]];
    // to set an image instead of text
    [statusItem setImage:[NSImage imageNamed:@"mic.png"]];
    //    [statusItem setAlternateImage:<#(NSImage *)#>];

    [statusItem setEnabled:YES];
    [statusItem setToolTip:@"Set Mic Volume"];
    
    [statusItem setAction:@selector(updateVol:)];
    [statusItem setTarget:self];
    
    [statusItem setMenu:statusMenu];
    
    [slider setMinValue:0];
    [slider setMaxValue:1];
    [sliderItem setView:slider];

    // get saved volume value
    volumeValue = [[NSUserDefaults standardUserDefaults] floatForKey:@"VolumeValue"];
    slider.floatValue = volumeValue;
    
    // get saved frequency
    [self setFrequencyMenuState];
}

-(IBAction)enableMicControl:(id)sender
{
    if ([[statusMenu itemAtIndex:0] state] == 0)
    {
        // is disabled, enable
        // create timer
        [self.repeatingTimer invalidate];
        
        float interval = 0.2;
        
        if (frequency == 0)
            interval = 1.0;
        else if (frequency == 1)
            interval = 0.5;
        else
            interval = 0.1;
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                          target:self selector:@selector(updateVol:)
                                                        userInfo:nil repeats:YES];
        
        self.repeatingTimer = timer;
        
        [[statusMenu itemAtIndex:0] setState:1];
        [statusItem setImage:[NSImage imageNamed:@"mic_red.png"]];
        
        [[frequencyMenu itemAtIndex:0] setEnabled:NO];
        [[frequencyMenu itemAtIndex:1] setEnabled:NO];
        [[frequencyMenu itemAtIndex:2] setEnabled:NO];

        

    }
    else
    {
        // disable
        [self.repeatingTimer invalidate];
        [[statusMenu itemAtIndex:0] setState:0];
        [statusItem setImage:[NSImage imageNamed:@"mic.png"]];

        [[frequencyMenu itemAtIndex:0] setEnabled:YES];
        [[frequencyMenu itemAtIndex:1] setEnabled:YES];
        [[frequencyMenu itemAtIndex:2] setEnabled:YES];
    }
    
}

-(IBAction)menuFreqLow:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setFloat:0 forKey:@"FrequencyValue"];
    [self setFrequencyMenuState];

}

-(IBAction)menuFreqMedium:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setFloat:1 forKey:@"FrequencyValue"];
    [self setFrequencyMenuState];

}

-(IBAction)menuFreqHigh:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setFloat:2 forKey:@"FrequencyValue"];
    [self setFrequencyMenuState];

}

-(void)setFrequencyMenuState
{
    frequency = [[NSUserDefaults standardUserDefaults] floatForKey:@"FrequencyValue"];
    
    [[frequencyMenu itemAtIndex:0] setState:0];
    [[frequencyMenu itemAtIndex:1] setState:0];
    [[frequencyMenu itemAtIndex:2] setState:0];
    
    if (frequency == 0)
    {
        [[frequencyMenu itemAtIndex:0] setState:1];
    }
    else if (frequency == 1)
    {
        [[frequencyMenu itemAtIndex:1] setState:1];
    }
    else
    {
        [[frequencyMenu itemAtIndex:2] setState:1];
    }
}


-(IBAction)menuQuit:(id)sender
{
    [NSApp terminate:self];
}


-(IBAction)sliderMoved:(id)sender
{
//    NSDictionary *appDefaults = [NSDictionary
//                                 dictionaryWithObject:[NSNumber numberWithFloat:slider.floatValue] forKey:@"VolumeValue"];
//    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

    [[NSUserDefaults standardUserDefaults] setFloat:slider.floatValue forKey:@"VolumeValue"];
    
    // get saved volume value
    volumeValue = [[NSUserDefaults standardUserDefaults] floatForKey:@"VolumeValue"];
    
    NSLog(@"Saved value: %f", volumeValue);
    
}

-(void) updateVol:(id)sender
{
    OSStatus        err;
    AudioDeviceID        device;
    UInt32            size;
    Boolean            canset    = false;
    UInt32            channels[2];
    //float            volume[2];
    
    float involume = 0.25f;
    involume = [slider floatValue];
    
    // get default device
    size = sizeof device;
//    printf("setVolume:: value of the volume set =%lf", involume);
    err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultInputDevice, &size, &device);
    if(err!=noErr) {
        NSLog(@"audio-volume error get device");
        return;
    }
    
    // try set master-channel (0) volume
    size = sizeof canset;
    err = AudioDeviceGetPropertyInfo(device, 0, true, kAudioDevicePropertyVolumeScalar, &size, &canset);
    if(err==noErr && canset==true) {
        size = sizeof involume;
        err = AudioDeviceSetProperty(device, NULL, 0, true, kAudioDevicePropertyVolumeScalar, size, &involume);
        return;
    }
    
    // else, try seperate channes
    // get channels
    size = sizeof(channels);
    err = AudioDeviceGetProperty(device, 0, true, kAudioDevicePropertyPreferredChannelsForStereo, &size,&channels);
    if(err!=noErr) {
        NSLog(@"error getting channel-numbers");
        return;
    }
    
    // set volume
    size = sizeof(float);
    err = AudioDeviceSetProperty(device, 0, channels[0], true, kAudioDevicePropertyVolumeScalar, size, &involume);
    if(noErr!=err) NSLog(@"error setting volume of channel %d",channels[0]);
    err = AudioDeviceSetProperty(device, 0, channels[1], true, kAudioDevicePropertyVolumeScalar, size, &involume);
    if(noErr!=err) NSLog(@"error setting volume of channel %d",channels[1]);
}

@end
