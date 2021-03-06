require("asteroidexplosion")
require("polygonentity")

Asteroid = class("Asteroid", PolygonEntity)

--[[
  Asteroids come in 3 sizes:

  # SIZE    MATERIAL    RADIUS
  1 small   1           5-10
  2 medium  5           15-25
  3 large   20          35-50

  Each asteroid splits into 3 of the smaller level, the smalles asteroid breaks away.
]]

function materialValue(size)
    v = {1, 3, 9}
    return v[size]
end

function randomRadius(size)
    v1 = {5, 10, 15}
    v2 = {10, 20, 30}
    return math.random(v1[size], v2[size])
end

function pointCount(size)
    return size * 5
end

function Asteroid:__init(size)
    PolygonEntity.__init(self)   

    self.size = size
    self:generate()
    self.rotationSpeed = math.random(-1.0, 1.0)

    self.alpha = 0

    self.physicsObject = {}
end

function Asteroid:startBeingTransparent()
    self.alpha = 255
end

function Asteroid:enablePhysics()
    self.physicsObject.body = love.physics.newBody(self.world.physicsWorld, self.position.x, self.position.y, "dynamic")
    self.physicsObject.shape = love.physics.newCircleShape(randomRadius(self.size))
    self.physicsObject.fixture = love.physics.newFixture(self.physicsObject.body, self.physicsObject.shape, 1)
    self.physicsObject.fixture:setUserData(self)
    self.physicsObject.fixture:setCategory(1) -- don't collide with arena walls
    self.physicsObject.fixture:setMask(2) -- don't collide with arena walls
    self.physicsObject.body:setLinearVelocity(self.velocity.x, self.velocity.y)
    table.insert(self.world.physicsObjects, self.physicsObject)
end

function Asteroid:update(dt)
    self.__super.update(self, dt)

    if self.alpha > 0 then
        self.alpha = self.alpha - dt * 200
    end

    if self.crushScheduled then 
        self:crush()
    elseif self.world then
        local inside = math.abs(self.position.x) < arena.size.x / 2 and math.abs(self.position.y) < arena.size.y / 2

        if self.wasInside and not inside then
            game.materialAvailable = game.materialAvailable + math.random(0, materialValue(self.size))
            self:kill()
        end

        if inside and not self.wasInside then self.wasInside = true end

    end
end

function Asteroid:generate()
    self:clear()
    c = pointCount(self.size)
    for i = 1,c do
        v = Vector(0, randomRadius(self.size))
        v:rotate(2.0 * math.pi * i / c)
        self:addPoint(v)
    end
end

function Asteroid:crush()
    game:addShake(self.size + 2)
    if self.size > 1 then
        for i = 1,3 do
            local a = Asteroid(self.size - 1)
            a.position = self.position
            a.velocity = Vector(math.random(-40, 40), math.random(-40, 40)) * game.power * game.power / 400 + self.velocity * 0.7
            self.world:add(a)
        end
    end

    resources.audio.explosion_asteroid:play()

    explosion = AsteroidExplosion(self.position, 1)
    self.world:add(explosion)

    self:kill()
end

function Asteroid:kill()
    --check gameover condition
    local all_asteroids = self.world:findByType("Asteroid")
    if #all_asteroids - 1 <= 0 then
        if game.materialAvailable <= 0 then
            game:isOver()
        end
    end

    PolygonEntity.kill(self)
end

function Asteroid:scheduleCrush()
    self.crushScheduled = true
end

function Asteroid:draw()
    love.graphics.setColor(255,255,255)
    PolygonEntity.draw(self)
end

function Asteroid:finishedBeingTransparent()
    return self.alpha <= 0
end

function Asteroid:drawTransparent()
    love.graphics.setColor(255,255,255,self.alpha)
    PolygonEntity.draw(self)
end
