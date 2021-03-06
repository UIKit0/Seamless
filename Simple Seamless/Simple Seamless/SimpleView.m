//
//  SimpleView.m
//  Simple Additive
//
//  Created by Kevin Doughty on 4/7/11.
//  Copyright 2011 Kevin Doughty. All rights reserved.
//
//  This is a from scratch re-implementation of "Follow Me" by Matt Long 10/22/08
//  My original version used explicit additive animations.
//  This version uses implicit animation and seamless.framework.

#import "SimpleView.h"
#import <Seamless/Seamless.h>

@implementation SimpleView

-(void) awakeFromNib {
	self.layer = [CALayer layer];
	self.wantsLayer = YES;
	ball = [CALayer layer];
	ball.position = CGPointMake(self.layer.bounds.size.width/2.0, self.layer.bounds.size.height/2.0);
	NSRect scaledRect = [self convertRectToBase:NSMakeRect(0, 0, 30, 30)];
	ball.bounds = NSRectToCGRect(scaledRect);
	ball.cornerRadius = scaledRect.size.width / 2.0;
	ball.backgroundColor = [[NSColor blackColor] CGColor];
	[self.layer addSublayer:ball];
    [[self window] setAcceptsMouseMovedEvents:YES];
}

-(BOOL)isFlipped {
    return YES;
}

-(BOOL) acceptsFirstResponder {
    return YES;
}

-(void) mouseMoved:(NSEvent*)theEvent {
	CGPoint sanePoint = [self sanePointFromEvent:theEvent];
	[self hoverCheckPoint:sanePoint];
}

-(void) mouseDown:(NSEvent*)theEvent {
    CGPoint sanePoint = [self sanePointFromEvent:theEvent];
	[CATransaction setAnimationDuration:[self animationDuration]];
    [CATransaction setSeamlessNegativeDelta:YES];
    [CATransaction setSeamlessTimingBlock:[self timingBlock]];
    [CATransaction setCompletionBlock:[self completionBlock]];
	ball.position = sanePoint;
}

-(void) mouseDragged:(NSEvent*)theEvent {
	CGPoint sanePoint = [self sanePointFromEvent:theEvent];
	[self hoverCheckPoint:sanePoint];
	[CATransaction setAnimationDuration:[self animationDuration]];
    [CATransaction setSeamlessNegativeDelta:YES];
    [CATransaction setSeamlessTimingBlock:[self timingBlock]];
    [CATransaction setCompletionBlock:[self completionBlock]];
	ball.position = sanePoint;
}

-(CGPoint) sanePointInWindow:(NSPoint)windowLoc {
	NSPoint viewLoc = [self convertPoint:windowLoc fromView:nil];
	NSPoint baseLoc = [self convertPointToBase:viewLoc];
    return NSPointToCGPoint(baseLoc);
}

-(CGPoint) sanePointFromEvent:(NSEvent*)theEvent {
	return [self sanePointInWindow:theEvent.locationInWindow];
}

-(CGFloat) animationDuration {
	return ([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSShiftKeyMask) ? 5.0 : 1.0;
}

-(void) hoverCheckPoint:(CGPoint)where { // Many, many transform animations get added to the ball from mouseMoved:
    CALayer *theLayer = [(CALayer*)[ball presentationLayer] hitTest:where];
	[CATransaction setAnimationDuration:[self animationDuration]];
    [CATransaction setSeamlessNegativeDelta:YES];
    [CATransaction setSeamlessTimingBlock:[self timingBlock]];
	if (theLayer == nil || hypot(theLayer.position.x - where.x, theLayer.position.y - where.y)  > theLayer.frame.size.width/2.0 ) {
		//ball.opacity = 1.0;
		ball.transform = CATransform3DIdentity;
		//ball.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, 30, 30);
   } else {
		//ball.opacity = 0.0;
		ball.transform = CATransform3DMakeScale(3.0,3.0,1.0);
		//ball.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, 90, 90);
	}
}
-(void (^)(void))completionBlock {
    return ^{
        [self hoverCheckPoint:[self sanePointInWindow:self.window.mouseLocationOutsideOfEventStream]];
    };
}
-(SeamlessTimingBlock)timingBlock {
    return ^ (double progress) {
        double omega = 20.0;
        double zeta = 0.5;
        //progress = 1 - cosf( progress * M_PI / 2 );
        double beta = sqrt(1.0 - zeta * zeta);
        return 1 - 1 / beta * expf(-zeta * omega * progress) * sinf(beta * omega * progress + atanf(beta / zeta));

    };
}


@end