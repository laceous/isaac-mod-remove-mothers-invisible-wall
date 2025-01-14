local mod = RegisterMod('Remove Mother\'s Invisible Wall', 1)
local game = Game()

mod.gridIndexes = {}

-- invisible blocks show up as walls in onNewRoom
-- you can remove walls in onNewRoom but you can walk out of frame below the camera view
-- change invisible blocks to cobwebs and remove them in onNewRoom
-- the camera will work properly in this case
-- entity types are taken from basement renovator
function mod:onPreNewRoom(entityType, variant, subType, gridIdx, seed)
  local room = game:GetRoom()
  
  if mod:isMother() and room:IsClear() then
    local invisibleBlock = 1999
    local cobweb = 1940
    
    if entityType == invisibleBlock then
      table.insert(mod.gridIndexes, gridIdx)
      return { cobweb, 0, 0 }
    end
  end
end

function mod:onNewRoom()
  local room = game:GetRoom()
  
  for i, v in ipairs(mod.gridIndexes) do
    mod.gridIndexes[i] = nil
    room:RemoveGridEntity(v, 0, false)
  end
end

function mod:isMother()
  local level = game:GetLevel()
  local roomDesc = level:GetCurrentRoomDesc()
  local stage = level:GetStage()
  local stageType = level:GetStageType()
  
  if StageAPI and StageAPI.CurrentStage and not StageAPI.CurrentStage.NormalStage and StageAPI.CurrentStage.LevelgenStage and not StageAPI.InTestMode then
    stage = StageAPI.CurrentStage.LevelgenStage.Stage
    stageType = StageAPI.CurrentStage.LevelgenStage.StageType
  end
  
  -- ROOM_SECRET_EXIT_IDX or ROOM_DEBUG_IDX
  return not game:IsGreedMode() and
         (stage == LevelStage.STAGE4_2 or stage == LevelStage.STAGE4_1) and
         (stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B) and
         roomDesc.Data.Shape == RoomShape.ROOMSHAPE_1x2 and
         roomDesc.Data.Type == RoomType.ROOM_BOSS and
         roomDesc.Data.StageID == 33 and -- corpse
         roomDesc.Data.Variant == 1      -- Mother
end

mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, mod.onPreNewRoom)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom)