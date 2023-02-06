local class = {}

--Create a new animation
function class.new(sprite, frames, framerate, frameX, frameY, frameWidth, frameHeight)
  local animation = {}

  animation.sprite = sprite
  animation.frames = frames
  animation.framerate = framerate
  animation.frameX = frameX
  animation.frameY = frameY
  animation.frameWidth = frameWidth
  animation.frameHeight = frameHeight
  animation.currentFrame = 1
  animation.timer = 0
  animation.nbLoop = 0

  animation.quads = {}
  for frame = 1, frames do
    animation.quads[frame] = love.graphics.newQuad(frameX + (frame-1) * frameWidth, frameY, frameWidth, frameHeight, sprite:getDimensions())
  end

  return animation
end

--Reset animation
function class.reset(animation)
  animation.currentFrame = 1
end

--Update animation
function class.updateTimer(animation, dt)
  animation.timer = animation.timer + dt
  if (animation.timer > 1/animation.framerate) then
    animation.timer = animation.timer - 1/animation.framerate
    animation.currentFrame = animation.currentFrame + 1
    if (animation.currentFrame > animation.frames) then
      animation.currentFrame = 1
    end
  end
end

--Update animation
function class.updateLoop(animation, dt, nbLoop)
  animation.timer = animation.timer + dt
  if (animation.timer > 1/animation.framerate) then
    animation.timer = animation.timer - 1/animation.framerate
    animation.currentFrame = animation.currentFrame + 1
    if (animation.currentFrame > animation.frames) then
      animation.nbLoop = animation.nbLoop + 1
      if (animation.nbLoop == nbLoop) then
        return true
      else
        animation.currentFrame = 1
      end
    end
  end
end

--Draw animation
function class.draw(animation, x, y, ox, oy)
  love.graphics.draw(animation.sprite, animation.quads[animation.currentFrame], x, y, 0, 1, 1, ox or nil, oy or nil)
end

return class
