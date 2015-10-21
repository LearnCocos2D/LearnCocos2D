//
//  EntityComponentSystemsTests.m
//  EntityComponentSystemsTests
//
//  Created by Steffen Itterheim on 20/10/15.
//  Copyright © 2015 Steffen Itterheim. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "anax.hpp"
#import "entityx.h"
#import "Artemis.h"

@interface EntityComponentSystemsTests : XCTestCase

@end

@implementation EntityComponentSystemsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#define MEASURE(iterations, codeblock) 	[self measureMetrics:[[self class] defaultPerformanceMetrics] automaticallyStartMeasuring:NO forBlock:^{ \
	[self startMeasuring]; \
	for (NSInteger i = 0; i < iterations; i++) { \
		codeblock \
	}\
	[self stopMeasuring]; \
}]; \

const NSInteger numIterations = 500;
const double fakeDeltaTime = 0.01666;


#pragma mark CreateDestroyEntity
/*
-(void) testCreateDestroyEntity_EntityX {
	entityx::EntityX* world = new entityx::EntityX();

	MEASURE(numIterations, {
		entityx::Entity entity = world->entities.create();
		entity.destroy();
	});
	
	delete world;
}

-(void) testCreateDestroyEntity_Anax {
	anax::World* world = new anax::World();
	
	MEASURE(numIterations, {
		anax::Entity entity = world->createEntity();
		entity.activate();
		entity.kill();
	});
	
	delete world;
}

-(void) testCreateDestroyEntity_Artemis {
	artemis::World* world = new artemis::World();
	artemis::EntityManager* entityManager = world->getEntityManager();

	MEASURE(numIterations, {
		artemis::Entity& entity = entityManager->create();
		entity.refresh();
		entity.remove();
	});

	delete world;
}
*/

#pragma mark Components

struct Position_EntityX {
	Position_EntityX(float x = 0.0f, float y = 0.0f) : x(x), y(y) {}
	float x, y;
};
struct Direction_EntityX {
	Direction_EntityX(float x = 0.0f, float y = 0.0f) : x(x), y(y) {}
	float x, y;
};
struct Comflabulation_EntityX {
	Comflabulation_EntityX(float thingy = 0.0f, int dingy = 0.0f, bool mingy = false, const std::string& stringy = "") : thingy(thingy), dingy(dingy), mingy(mingy), stringy(stringy) {}
	float thingy;
	int dingy;
	bool mingy;
	std::string stringy;
};

struct Position_Anax : anax::Component {
	Position_Anax(float x = 0.0f, float y = 0.0f) : x(x), y(y) {}
	float x, y;
};
struct Direction_Anax : anax::Component {
	Direction_Anax(float x = 0.0f, float y = 0.0f) : x(x), y(y) {}
	float x, y;
};
struct Comflabulation_Anax : anax::Component {
	Comflabulation_Anax(float thingy = 0.0f, int dingy = 0.0f, bool mingy = false, const std::string& stringy = "") : thingy(thingy), dingy(dingy), mingy(mingy), stringy(stringy) {}
	float thingy;
	int dingy;
	bool mingy;
	std::string stringy;
};

class Position_Artemis : public artemis::Component {
public:
	Position_Artemis(float x = 0.0f, float y = 0.0f) : x(x), y(y) {}
	float x, y;
};
class Direction_Artemis : public artemis::Component {
public:
	Direction_Artemis(float x = 0.0f, float y = 0.0f) : x(x), y(y) {}
	float x, y;
};
class Comflabulation_Artemis : public artemis::Component {
public:
	Comflabulation_Artemis(float thingy = 0.0f, int dingy = 0.0f, bool mingy = false, const std::string& stringy = "") : thingy(thingy), dingy(dingy), mingy(mingy), stringy(stringy) {}
	float thingy;
	int dingy;
	bool mingy;
	std::string stringy;
};

#pragma mark CreateDestroyEntityWithComponents
-(void) testCreateDestroyEntityWithComponents_EntityX {
	entityx::EntityX* world = new entityx::EntityX();
	
	MEASURE(numIterations, {
		entityx::Entity entity = world->entities.create();
		entity.assign<Position_EntityX>();
		entity.assign<Direction_EntityX>();
		entity.assign<Comflabulation_EntityX>();
		entity.destroy();
	});
	
	delete world;
}

-(void) testCreateDestroyEntityWithComponents_Anax {
	anax::World* world = new anax::World();
	
	MEASURE(numIterations, {
		anax::Entity entity = world->createEntity();
		entity.addComponent<Position_Anax>();
		entity.addComponent<Direction_Anax>();
		entity.addComponent<Comflabulation_Anax>();
		entity.activate();
		entity.kill();
	});
	
	delete world;
}

-(void) testCreateDestroyEntityWithComponents_Artemis {
	artemis::World* world = new artemis::World();
	artemis::EntityManager* entityManager = world->getEntityManager();
	
	MEASURE(numIterations, {
		artemis::Entity& entity = entityManager->create();
		entity.addComponent(new Position_Artemis());
		entity.addComponent(new Direction_Artemis());
		entity.addComponent(new Comflabulation_Artemis());
		entity.remove();
	});
	
	delete world;
}

#pragma mark Systems
struct MovementSystem_EntityX : public entityx::System<MovementSystem_EntityX> {
	void update(entityx::EntityManager &es, entityx::EventManager &events, entityx::TimeDelta dt) override {
		es.each<Position_EntityX, Direction_EntityX>([dt](entityx::Entity entity, Position_EntityX &position, Direction_EntityX &direction) {
			position.x += direction.x * dt;
			position.y += direction.y * dt;
		});
	};
};
struct ComflabSystem_EntityX : public entityx::System<ComflabSystem_EntityX> {
	void update(entityx::EntityManager &es, entityx::EventManager &events, entityx::TimeDelta dt) override {
		es.each<Comflabulation_EntityX>([dt](entityx::Entity entity, Comflabulation_EntityX &comflab) {
			comflab.thingy *= 1.000001f;
			comflab.mingy = !comflab.mingy;
			comflab.dingy++;
			//comflab.stringy = std::to_string(comflab.dingy);
		});
	};
};

struct MovementSystem_Anax : anax::System<anax::Requires<Position_Anax, Direction_Anax>> {
public:
	void update(double dt) const {
		auto entities = getEntities();
		for (auto entity : entities) {
			Position_Anax& position = entity.getComponent<Position_Anax>();
			Direction_Anax& direction = entity.getComponent<Direction_Anax>();
			position.x += direction.x * dt;
			position.y += direction.y * dt;
		}
	}
};
struct ComflabSystem_Anax : anax::System<anax::Requires<Comflabulation_Anax>> {
public:
	void update(double dt) const {
		auto entities = getEntities();
		for (auto entity : entities) {
			Comflabulation_Anax& comflab = entity.getComponent<Comflabulation_Anax>();
			comflab.thingy *= 1.000001f;
			comflab.mingy = !comflab.mingy;
			comflab.dingy++;
			//comflab.stringy = std::to_string(comflab.dingy);
		}
	}
};

class MovementSystem_Artemis : public artemis::EntityProcessingSystem {
public:
	MovementSystem_Artemis() {
		addComponentType<Position_Artemis>();
		addComponentType<Direction_Artemis>();
	}
	virtual void initialize() {
		positionMapper.init(*world);
		directionMapper.init(*world);
	};
	virtual void processEntity(artemis::Entity &e) {
		float dt = world->getDelta();
		Position_Artemis* position = positionMapper.get(e);
		Direction_Artemis* direction = directionMapper.get(e);
		position->x += direction->x * dt;
		position->y += direction->y * dt;
	};
private:
	artemis::ComponentMapper<Position_Artemis> positionMapper;
	artemis::ComponentMapper<Direction_Artemis> directionMapper;
};
class ComflabSystem_Artemis : public artemis::EntityProcessingSystem {
public:
	ComflabSystem_Artemis() {
		addComponentType<Comflabulation_Artemis>();
	}
	virtual void initialize() {
		comflabMapper.init(*world);
	};
	virtual void processEntity(artemis::Entity &e) {
		Comflabulation_Artemis* comflab = comflabMapper.get(e);
		comflab->thingy *= 1.000001f;
		comflab->mingy = !comflab->mingy;
		comflab->dingy++;
		//comflab->stringy = std::to_string(comflab->dingy);
	};
private:
	artemis::ComponentMapper<Comflabulation_Artemis> comflabMapper;
};

#pragma mark CreateDestroyEntityWithComponentSystems
-(void) testComponentSystems_EntityX {
	entityx::EntityX* world = new entityx::EntityX();
	world->systems.add<MovementSystem_EntityX>();
	world->systems.add<ComflabSystem_EntityX>();
	world->systems.configure();

	for (int i = 0; i < numIterations; i++) {
		entityx::Entity entity = world->entities.create();
		entity.assign<Position_EntityX>();
		entity.assign<Direction_EntityX>();
		if (i % 2) {
			entity.assign<Comflabulation_EntityX>();
		}
	}
	
	MEASURE(numIterations, {
		world->systems.update_all(fakeDeltaTime);
	});

	delete world;
}

-(void) testComponentSystems_Anax {
	anax::World* world = new anax::World();
	MovementSystem_Anax movementSystem;
	world->addSystem(movementSystem);
	ComflabSystem_Anax comflabSystem;
	world->addSystem(comflabSystem);
	
	for (int i = 0; i < numIterations; i++) {
		anax::Entity entity = world->createEntity();
		entity.addComponent<Position_Anax>();
		entity.addComponent<Direction_Anax>();
		if (i % 2) {
			entity.addComponent<Comflabulation_Anax>();
		}
		entity.activate(); // must activate entity after changing components to update systems
	}

	world->refresh(); // must refresh world after changing entities or their components to update systems

	MEASURE(numIterations, {
		movementSystem.update(fakeDeltaTime);
		comflabSystem.update(fakeDeltaTime);
	});

	delete world;
}

-(void) testComponentSystems_Artemis {
	artemis::World* world = new artemis::World();
	artemis::SystemManager* systemManager = world->getSystemManager();
	auto movementSystem = (MovementSystem_Artemis*)systemManager->setSystem(new MovementSystem_Artemis());
	auto comflabSystem = (ComflabSystem_Artemis*)systemManager->setSystem(new ComflabSystem_Artemis());
	systemManager->initializeAll(); // calls initialize on all systems

	artemis::EntityManager* entityManager = world->getEntityManager();
	for (int i = 0; i < numIterations; i++) {
		artemis::Entity& entity = entityManager->create();
		entity.addComponent(new Position_Artemis());
		entity.addComponent(new Direction_Artemis());
		if (i % 2) {
			entity.addComponent(new Comflabulation_Artemis());
		}
		entity.refresh(); // must refresh entity after changing components to update systems
	}
	
	MEASURE(numIterations, {
		world->loopStart();
		world->setDelta(fakeDeltaTime);
		movementSystem->process();
		comflabSystem->process();
	});
	
	delete world;
}
@end
