//
//  MyScene.m
//  Ball
//
//  Created by Matheus Cardoso on 7/24/14.
//  Copyright (c) 2014 Matheus Cardoso. All rights reserved.
//

#import "MyScene.h"

const uint32_t BALL = 0x1 << 0;
const uint32_t WORLD = 0x1 << 1;
const uint32_t END = 0x1 << 2;

const float DESC = 0.6;

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
		self.physicsWorld.contactDelegate = self;
		self.physicsWorld.gravity = CGVectorMake(0.0, -2.8);
		self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
		self.name = @"world";
		self.physicsBody.categoryBitMask = WORLD;
		self.physicsBody.collisionBitMask = WORLD;
        
        _tempCast = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                     target:self
                                                   selector:@selector(releaseBall)
                                                   userInfo:nil
                                                    repeats:YES];
        
        _cont = 0;
        self.backgroundColor = [UIColor blackColor];
    
        _BackGround1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"BackGround"]];
        [_BackGround1 setPosition:CGPointMake(self.scene.frame.origin.x + _BackGround1.size.width/2,self.scene.frame.origin.y + _BackGround1.frame.size.height/2)];
        [self addChild:_BackGround1];
        _BackGround1.alpha = 0.5;
        _BackGround1.name = @"Back1";
        
        _ScreenEnd = [[SKSpriteNode alloc]initWithColor:[UIColor blackColor] size:CGSizeMake(self.scene.frame.size.width, 50)];
        [_ScreenEnd setPosition:CGPointMake(self.scene.frame.origin.x + _ScreenEnd.size.width/2, self.scene.frame.origin.y - 150)];
        _ScreenEnd.name = @"ScrEnd";
        [self addChild:_ScreenEnd];
    }
    
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
     
    _isRunning = YES;
    
    if (self.scene.view.paused) {
        self.scene.view.paused = NO;
        _tempCast = [NSTimer scheduledTimerWithTimeInterval:0.25                                                     target:self
                                                   selector:@selector(releaseBall)
                                                   userInfo:nil
                                                    repeats:YES];
        
    }
    
    NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"MyTestParticle" ofType:@"sks"];
    
    SKEmitterNode *myParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    myParticle.particlePosition = [self convertPointFromView:[[touches anyObject] locationInView:self.view]];
    myParticle.name = @"cursor";
    
    [self addChild:myParticle];
    
    if(_points == nil){
        _points = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 100, 50)];
        _points.center = CGPointMake(self.frame.origin.x + self.view.frame.size.width - _points.frame.size.width/2, self.view.frame.origin.y + self.view.frame.size.height - _points.frame.size.height/2);
        _points.text = @"PONTOS";
        [self.view addSubview:_points];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *anyTouch = [touches anyObject];
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    touchLocation = [self convertPointFromView:touchLocation];
    _currentPoint = touchLocation;
    
    SKEmitterNode *test = (SKEmitterNode*)[self childNodeWithName:@"cursor"];
    test.particlePosition = [self convertPointFromView:[[touches anyObject] locationInView:self.view]];
}

-(void)update:(CFTimeInterval)currentTime {
    [_BackGround1 setPosition:CGPointMake(_BackGround1.position.x, _BackGround1.position.y - DESC)];
    
    SKSpriteNode *block = (SKSpriteNode*)[self nodeAtPoint:_currentPoint];
    
    if([block.name isEqualToString:@"bola"]){
        block.name = @"bola_done";
        [block setTexture:[SKTexture textureWithImageNamed:@"Ring 4"]];
        block.xScale = 0.25;
        block.yScale = 0.25;
        
        //block.color = [UIColor colorWithRed:0.8 green:0.6 blue:0.4 alpha:1];
        _points.text = [NSString stringWithFormat:@"%d", _points.text.intValue+50];
    }
    else if([block.name isEqualToString:@"block"]){
        _isRunning = NO;
        [_tempCast invalidate];
        //[self Ending];
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    if (!self.scene.view.paused) {
        self.scene.view.paused = YES;
        _isRunning = NO;
        [(SKEmitterNode*)[self childNodeWithName:@"cursor"] removeFromParent];
        [_tempCast invalidate];
        
    } else {
        [(SKEmitterNode*)[self childNodeWithName:@"cursor"] removeFromParent];
    }
    
    
    
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    
    if ([contact.bodyA.node.name isEqualToString:@"ScrEnd"]) {
        if([contact.bodyB.node.name isEqualToString:@"bola"])
            [contact.bodyB.node removeFromParent];
    }
    else if ([contact.bodyB.node.name isEqualToString:@"ScrEnd"]){
        if([contact.bodyA.node.name isEqualToString:@"bola"])
            [contact.bodyA.node removeFromParent];
    }
}

-(void)releaseBall{
    SKSpriteNode *sprite;
    
    
    
    _cont++;
    
    if(_cont == 4){
        sprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Ring 2"]];
        sprite.name = @"bola";
        sprite.color = [UIColor colorWithRed:0.4 green:0.6 blue:0.8 alpha:1];
        [sprite setColorBlendFactor:1];
        
        sprite.xScale = 0.25;
        sprite.yScale = 0.25;
        _cont = 0;
    }
    else{
        sprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"meteoro1"]];
        sprite.name = @"block";
        sprite.xScale = 0.5;
        sprite.yScale = 0.5;
    }
    
    
    _randomSpawn = rand() %(int)(self.view.frame.origin.x + self.view.bounds.size.width - sprite.size.width);
    _randomSpawn = _randomSpawn + self.view.frame.origin.x + sprite.size.width/2;
    
    sprite.position = [self quadrante];

    
    [self addChild:sprite];
    
    sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.height center:sprite.position];
    sprite.physicsBody.categoryBitMask = BALL;
    sprite.physicsBody.collisionBitMask = BALL;
    sprite.physicsBody.contactTestBitMask = BALL;
    [sprite.physicsBody applyImpulse:CGVectorMake(0.0, -25.0)];
    
//    SKAction *action = [SKAction moveToY:(0.0 - sprite.size.height) duration:2.0];
//    [self addChild:sprite];
//    
//    [sprite runAction:[SKAction sequence:@[action,[SKAction removeFromParent]]]];
    
    if(!_isRunning){
        
    }

}

-(CGPoint)quadrante{
    CGPoint quad;
    int point;
    if(_randomSpawn < 64){
        point = 64 - 31;
    }
    else if (_randomSpawn < 128){
        point = 128 - 31;
    }
    else if (_randomSpawn < 192){
        point = 192 - 31;
    }
    else if (_randomSpawn <256){
        point = 256 - 31;
    }
    else{
        point = 320 - 31;
    }
    
    quad = CGPointMake(point, self.view.frame.origin.y + self.view.bounds.size.height + 262.5);
    
    return quad;
}

/*-(void)Ending{
    BOOL carry = NO;
    for(SKNode *nodo in [self children]){
        NSLog(@"%lu", self.children.count);
        if(!carry){
            if(![nodo.name isEqualToString:@"Block1"]){
            [nodo removeAllActions];
            [nodo runAction:[SKAction moveToX:0.0 - nodo.frame.size.width duration:0.2]];
            carry = YES;
            }
        }
        else{
            if(![nodo.name isEqualToString:@"Block1"]){
            [nodo removeAllActions];
            [nodo runAction:[SKAction moveToX:0 + self.view.frame.size.width + nodo.frame.size.width duration:0.5]];
            carry = NO;
            }
        }
    }
}*/

@end
