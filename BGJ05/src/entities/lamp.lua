require("util/helper")
require("util/vector")
require("scene/entity")

Lamp = class("Lamp", GlowEntity)

function Lamp:__init()
    GlowEntity.__init(self)
    self.z = -100

    self.burning = true
    self.wasActive = false

    self.particleSystem = love.graphics.newParticleSystem(resources.images.particle, 128)
    self.particleSystem:start()
    self.particleSystem:setSizes(0.2, 0.9)
    self.particleSystem:setColors(
        240, 250, 50, 250,
        250, 10, 10, 0)
    self.particleSystem:setEmissionRate(100)
    self.particleSystem:setParticleLife(0.5)
    self.particleSystem:setSpread(0.5)

    self.glowColor = {255, 230, 0}
    self.glowSize = 300
end

function Lamp:burnout()
    self.burning = false
end

function Lamp:onUpdate(dt)
    if self.isNextLamp then
        self.wasActive = true
    end

    if not self.isNextLamp and self.wasActive then
        self:burnout()
    end

    self.glow = self.burning
    self.particleSystem:setEmissionRate(self.glowing and 100 or 0)

    self.particleSystem:update(dt)
    self.particleSystem:setPosition(self.position.x, self.position.y)

    self.z = - 100 - self.position.y / 100000
end

function Lamp:onDraw()
    love.graphics.setBlendMode("additive")
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.particleSystem)
    love.graphics.setBlendMode("alpha")
end