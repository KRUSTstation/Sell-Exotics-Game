local function PlaySound(sound)
	sound.Parent = script.Parent
	sound:Play()
	game.Debris:AddItem(sound,5)
end


while true do
	PlaySound(script.Parent["another sword slash"]:Clone())
	wait(0.05)
	for i, v in ipairs(script.Parent:GetDescendants()) do
		if not v:IsA("ParticleEmitter") then continue end

		task.spawn(function()

			task.wait(v:GetAttribute("EmitDelay"))

			task.spawn(function()
				v.Enabled = true

				task.delay(v:GetAttribute("EmitDuration"), function()
					v.Enabled = false
				end)

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end)
	end
	
	
	
	task.wait(0.2)
	PlaySound(script.Parent["Sword Slash Sfx"]:Clone())
	
	task.wait(5)
end

