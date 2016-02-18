//
//  iaAppDelegate.h
//  MicControl
//
//  Created by Nicolas Varchavsky on 4/1/14.
//  Copyright (c) 2014 Interatica. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface iaAppDelegate : NSObject <NSApplicationDelegate>
{
    __weak NSMenu *_statusMenu;
    NSStatusItem *statusItem;
    bool isEnabled;
    float volumeValue;
    float frequency;
    __weak NSMenuItem *_sliderItem;
    __weak NSSlider *_slider;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) NSTimer *repeatingTimer;
@property (weak) IBOutlet NSMenu *frequencyMenu;

@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSSlider *slider;
@property (weak) IBOutlet NSMenuItem *sliderItem;
@end
