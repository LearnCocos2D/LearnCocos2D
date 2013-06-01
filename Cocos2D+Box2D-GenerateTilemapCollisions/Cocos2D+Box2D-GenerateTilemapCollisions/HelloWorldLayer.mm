//
//  HelloWorldLayer.mm
//  Cocos2D+Box2D-GenerateTilemapCollisions
//
//  Created by Steffen Itterheim on 28.05.13.
//  Copyright Steffen Itterheim 2013. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "CCPhysicsSprite.h"
#import "AppDelegate.h"

#import "KTEdgeMap.h"
#import "KTContourMap.h"
#import "KTPointArray.h"
#import "KTIntegerArray.h"
#import "SimpleAudioEngine.h"

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
@end

@implementation HelloWorldLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		srandom(time(NULL));
		
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"pss.caf"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"psss.caf"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"blup.caf"];
		
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
		CGSize s = [CCDirector sharedDirector].winSize;
		
		_map = [CCTMXTiledMap tiledMapWithTMXFile:@"crawl-tilemap.tmx"];
		_tiles = [_map layerNamed:@"tiles"];
		[self addChild:_map z:-5];

		_edgeMap = [KTEdgeMap edgeMapFromTileLayer:_tiles];
		_contourMap = [KTContourMap contourMapFromTileLayer:_tiles];
		[self initPhysics];
		[self createCollisionShapesFromContourMap];
		
		_batchNode = [CCSpriteBatchNode batchNodeWithFile:@"Icon.png" capacity:100];
		spriteTexture_ = [_batchNode texture];
		[self addChild:_batchNode z:-1 tag:kTagParentNode];
		
		for (NSUInteger i = 0; i < 80; i++)
		{
			float spread = 480 * 0.8f;
			[self addNewSpriteAtPosition:ccp(spread * CCRANDOM_0_1() + ((480 - spread) / 2), (3 * s.height) - 40)];
		}
		
		[self scheduleUpdate];
		
		[self schedule:@selector(updateFollow:)];
		self.position = CGPointMake(self.position.x, -(2 * s.height));
		[self updateFollow:0];
		
		[self schedule:@selector(checkRestart:) interval:2.0f];
	}
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
}	

-(void) createCollisionShapesFromContourMap
{
	// static body that gets the chain shapes added to it
	b2BodyDef bodyDef;
	b2Body* contoursBody = world->CreateBody(&bodyDef);

	for (KTPointArray* segments in _contourMap.contourSegments)
	{
		NSUInteger vertexCount = 0;
		b2Vec2 vertices[8]; // Box2D allows for 8 vertices per shape
		
		for (NSUInteger i = 0; i < segments.count; i++)
		{
			CGPoint point = segments.points[i];
			vertices[vertexCount] = b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
			vertexCount++;
			
			if (vertexCount == 8)
			{
				b2ChainShape chainShape;
				chainShape.CreateChain(vertices, vertexCount);
				contoursBody->CreateFixture(&chainShape, 0);
				
				// last point becomes first point
				vertexCount = 1;
				vertices[0] = vertices[7];
			}
		}
		
		// create the last chain shape
		if (vertexCount >= 2)
		{
			b2ChainShape chainShape;
			chainShape.CreateChain(vertices, vertexCount);
			contoursBody->CreateFixture(&chainShape, 0);
		}
	}
}

-(void) checkRestart:(ccTime)delta
{
	if (_batchNode.children.count == 0)
	{
		CCScene* scene = [HelloWorldLayer scene];
		[[CCDirector sharedDirector] replaceScene:[CCTransitionFlipY transitionWithDuration:2 scene:scene]];
		[self unscheduleAllSelectors];
	}
}

-(void) updateFollow:(ccTime)delta
{
	CGRect boundary = CGRectMake(0, 0, _tiles.layerSize.width * _tiles.tileset.tileSize.width, _tiles.layerSize.height * _tiles.tileset.tileSize.height);

	float lowestY = boundary.size.height;
	CCNode* spriteToFollow = nil;
	for (CCNode* node in _batchNode.children)
	{
		if (node.position.y < lowestY)
		{
			lowestY = node.position.y;
			spriteToFollow = node;
		}
	}

	lowestY -= [CCDirector sharedDirector].winSize.height * 0.3f;
	
	const float threshold = 40.0f;
	float layerPosY = -(self.position.y);
	if ((lowestY + threshold) < layerPosY)
	{
		layerPosY -= 2;
	}
	else if (lowestY > layerPosY)
	{
		layerPosY += 2;
	}
	self.position = CGPointMake(self.position.x, -layerPosY);
}

-(void) initPhysics
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -6.5f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	//world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
}

-(void) addNewSpriteAtPosition:(CGPoint)p
{
	//CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.angularVelocity = CCRANDOM_MINUS1_1() * 30.0f;
	bodyDef.angularDamping = 0.95f;
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2CircleShape shape;
	shape.m_radius = 0.2f;
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;
	fixtureDef.density = 0.2f;
	fixtureDef.friction = 0.4f;
	fixtureDef.restitution = 0.6f;
	body->CreateFixture(&fixtureDef);
	

	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	CCPhysicsSprite *sprite = [CCPhysicsSprite spriteWithTexture:spriteTexture_];
	sprite.scale = 0.25f;
	[_batchNode addChild:sprite];
	
	[sprite setPTMRatio:PTM_RATIO];
	[sprite setB2Body:body];
	[sprite setPosition: ccp( p.x, p.y)];
	
	body->SetUserData((__bridge void*)sprite);
}

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step([CCDirector sharedDirector].animationInterval, velocityIterations, positionIterations);
	
	// keep the bodies moving, remove "dead" bodies
	NSMutableArray* deadSprites = nil;
	b2Body* body = world->GetBodyList();
	while (body)
	{
		if (body->GetType() == b2_dynamicBody)
		{
			if (body->IsAwake() == NO || (body->GetLinearVelocity().x > -0.005f && body->GetLinearVelocity().x < 0.005f))
			{
				body->SetAngularVelocity(CCRANDOM_MINUS1_1() * 40.0f);
				body->SetLinearVelocity(b2Vec2(CCRANDOM_MINUS1_1() * 15.0f, CCRANDOM_MINUS1_1() * 30.0f));
				
				if (_batchNode.children.count < 15)
				{
					[[SimpleAudioEngine sharedEngine] playEffect:@"blup.caf"];
				}
			}
			else if (body->GetPosition().y < 1.0f)
			{
				CCPhysicsSprite* sprite = (__bridge CCPhysicsSprite*)body->GetUserData();
				
				if (deadSprites == nil)
				{
					deadSprites = [NSMutableArray arrayWithCapacity:1];
				}
				[deadSprites addObject:sprite];
			}
		}
		body = body->GetNext();
	}
	
	for (CCPhysicsSprite* sprite in deadSprites)
	{
		if (CCRANDOM_0_1() < 0.5f)
		{
			[[SimpleAudioEngine sharedEngine] playEffect:@"pss.caf"];
		}
		else
		{
			[[SimpleAudioEngine sharedEngine] playEffect:@"psss.caf"];
		}
		
		CCParticleExplosion* explo = [[CCParticleExplosion alloc] initWithTotalParticles:100];
		explo.positionType = kCCPositionTypeRelative;
		explo.position = sprite.position;
		explo.startColor = ccc4f(1, 0.8f, 0, 1);
		explo.endColor = ccc4f(1, 0, 0, 0);
		explo.speed = 20;
		explo.speedVar = 5;
		explo.life = 0.05f;
		explo.lifeVar = 0.25f;
		explo.autoRemoveOnFinish = YES;
		[self.parent addChild:explo];
		
		world->DestroyBody(sprite.b2Body);
		[sprite removeFromParent];
	}
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	debugDrawMode = (DebugDrawMode)((debugDrawMode + 1) % DebugDrawMode_Count);
}

#pragma mark Drawing

-(void) draw
{
	[super draw];
	
	switch (debugDrawMode)
	{
		case DebugDrawEdges:
			[self drawEdges];
			break;
		case DebugDrawContours:
			[self drawContours];
			break;
		case DebugDrawPhysics:
			[self drawPhysicsDebugInfo];
			break;
			
		case DebugDrawNone:
		default:
			break;
	}
}

-(void) drawContours
{
	glLineWidth(2.0f);
	
	for (KTPointArray* segments in _contourMap.contourSegments)
	{
		NSUInteger numSegmentPoints = segments.count;
		for (NSUInteger i = 1; i < numSegmentPoints; i++)
		{
			if (i % 2 == 0)
			{
				ccDrawColor4B(255, 255, 0, 255);
			}
			else
			{
				ccDrawColor4B(0, 255, 255, 255);
			}
			
			ccDrawLine(segments.points[i - 1], segments.points[i]);
		}
		
		/*
		// draw from last to first point, closing the contour
		CGPoint first = segments.points[0];
		CGPoint last = [segments lastPoint];
		if (CGPointEqualToPoint(first, last) == NO)
		{
			ccDrawColor4B(100, 100, 255, 255);
			ccDrawLine(last, first);
		}
		*/
	}

	glLineWidth(1.0f);
}

-(void) drawEdges
{
	// draw edges (inefficiently)
	CGSize layerSize = _tiles.layerSize;
	CGSize tileSize = _tiles.mapTileSize;
	NSUInteger index = 0, rowIndex = 0;
	const float radius = 3.0f;
	
	for (NSInteger y = 0; y < layerSize.height; y++)
	{
		rowIndex = y * layerSize.width;
		
		for (NSInteger x = 0; x < layerSize.width; x++)
		{
			index = rowIndex + x;
			KTEdges edges = _edgeMap.edges[index];
			
			float height = tileSize.height - 2 - y;
			if (edges & KTEdgeTopLeft)
			{
				ccDrawColor4B(255, 255, 255, 255);
				ccDrawCircle(CGPointMake(x * tileSize.width, height * tileSize.height), radius, 0, 4, NO);
			}
			if (edges & KTEdgeTopRight)
			{
				ccDrawColor4B(255, 0, 0, 255);
				ccDrawCircle(CGPointMake((x + 1) * tileSize.width, height * tileSize.height), radius, 0, 4, NO);
			}
			if (edges & KTEdgeBottomRight)
			{
				ccDrawColor4B(0, 255, 0, 255);
				ccDrawCircle(CGPointMake((x + 1) * tileSize.width, (height - 1) * tileSize.height), radius, 0, 4, NO);
			}
			if (edges & KTEdgeBottomLeft)
			{
				ccDrawColor4B(0, 0, 255, 255);
				ccDrawCircle(CGPointMake(x * tileSize.width, (height - 1) * tileSize.height), radius, 0, 4, NO);
			}
		}
	}
}

-(void) drawPhysicsDebugInfo
{
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
	kmGLPushMatrix();
	world->DrawDebugData();
	kmGLPopMatrix();
}

@end
