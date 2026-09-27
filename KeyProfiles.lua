ComfyKey=ComfyKey or {}
local A=ComfyKey
local function Combat() return InCombatLockdown and InCombatLockdown() end
function A:CaptureBindings() local out={}; if type(GetNumBindings)~="function" or type(GetBinding)~="function" then return out end; local n=tonumber(GetNumBindings()) or 0; for i=1,n do local v={GetBinding(i)}; local cmd=v[1]; if cmd then local keys={}; for x=2,#v do if v[x] and v[x]~="" then keys[#keys+1]=v[x] end end; out[cmd]=keys end end; return out end
local function Keys(t) local a={} for _,k in ipairs(t or {}) do a[#a+1]=k end table.sort(a); return table.concat(a,", ") end
function A:GetProfileNames() local list={} for n in pairs(self.db.keys.profiles or {}) do list[#list+1]={value=n,text=n} end table.sort(list,function(a,b) return a.text:lower()<b.text:lower() end); return list end
function A:SaveKeyProfile(name) name=tostring(name or ""):match("^%s*(.-)%s*$"); if name=="" then return false end; self.db.keys.profiles[name]=self:CaptureBindings(); self.db.keys.selected=name; self:RefreshOptions(); return true end
function A:PreviewKeyProfile(name) local target=self.db.keys.profiles[name]; if type(target)~="table" then return self:T("NO_PROFILE") end; local current=self:CaptureBindings(); local all={}; for c in pairs(current) do all[c]=true end; for c in pairs(target) do all[c]=true end; local cmds={} for c in pairs(all) do cmds[#cmds+1]=c end table.sort(cmds); local lines={}; for _,c in ipairs(cmds) do local a,b=Keys(current[c]),Keys(target[c]); if a~=b then lines[#lines+1]=c..": "..(a~="" and a or "-").." -> "..(b~="" and b or "-") end end; return #lines>0 and table.concat(lines,"\n") or self:T("NO_CHANGES") end
function A:ApplySnapshot(snapshot) if Combat() then self:Print(self:T("COMBAT_LOCK")); return false end; if type(SetBinding)~="function" then return false end; local current=self:CaptureBindings(); for _,keys in pairs(current) do for _,key in ipairs(keys) do pcall(SetBinding,key) end end; for cmd,keys in pairs(snapshot or {}) do for _,key in ipairs(keys) do pcall(SetBinding,key,cmd) end end; if type(SaveBindings)=="function" then local set=type(GetCurrentBindingSet)=="function" and GetCurrentBindingSet() or 2; pcall(SaveBindings,set) end; return true end
function A:ApplyKeyProfile(name) local target=self.db.keys.profiles[name]; if type(target)~="table" then return false end; self.db.keys.recovery=self:CaptureBindings(); local ok=self:ApplySnapshot(target); self:RefreshOptions(); return ok end
function A:RestoreRecovery() if type(self.db.keys.recovery)~="table" then return false end; local ok=self:ApplySnapshot(self.db.keys.recovery); self:RefreshOptions(); return ok end
local function Esc(v) return tostring(v or ""):gsub("%%","%%25"):gsub("|","%%7C"):gsub(",","%%2C"):gsub("\n","%%0A") end
local function Unesc(v) return tostring(v or ""):gsub("%%0A","\n"):gsub("%%2C",","):gsub("%%7C","|"):gsub("%%25","%%") end
function A:ExportKeyProfile(name) local p=self.db.keys.profiles[name]; if type(p)~="table" then return "" end; local lines={"COMFYKEY1","name|"..Esc(name)}; local cmds={} for c in pairs(p) do cmds[#cmds+1]=c end table.sort(cmds); for _,c in ipairs(cmds) do local ks={} for _,k in ipairs(p[c] or {}) do ks[#ks+1]=Esc(k) end; lines[#lines+1]=Esc(c).."|"..table.concat(ks,",") end; return table.concat(lines,"\n") end
function A:ImportKeyProfile(text) local lines={} for line in tostring(text or ""):gmatch("[^\r\n]+") do lines[#lines+1]=line end; if lines[1]~="COMFYKEY1" then return false end; local name=lines[2] and lines[2]:match("^name|(.+)$"); name=Unesc(name); if not name or name=="" then return false end; local p={}; for i=3,#lines do local cmd,raw=lines[i]:match("^(.-)|(.*)$"); if cmd then local ks={} for k in tostring(raw or ""):gmatch("[^,]+") do ks[#ks+1]=Unesc(k) end; p[Unesc(cmd)]=ks end end; self.db.keys.profiles[name]=p; self.db.keys.selected=name; self:RefreshOptions(); return true end
function A:RefreshFeatureOptions() if self.keyDropdown and self.keyDropdown._refresh then self.keyDropdown._refresh() end; if self.previewBox then self.previewBox:SetText(self:PreviewKeyProfile(self.db.keys.selected)) end end
function A:BuildGeneralOptions(page,ui)
 local l=page:CreateFontString(nil,"ARTWORK","GameFontNormal"); l:SetPoint("TOPLEFT",20,-90); l:SetText(self:T("KEY_PROFILE"))
 self.keyDropdown=ui.CreateDropdown(page,5,-105,220,function() return A:GetProfileNames() end,function() return A.db.keys.selected end,function(v) A.db.keys.selected=v end)
 self.keyName=ui.CreateEdit(page,270,-105,190,28,false)
 ui.CreateButton(page,self:T("SAVE_CURRENT"),470,-102,120,function() local n=A.keyName:GetText(); if A:SaveKeyProfile(n) then A.keyName:SetText("") end end)
 ui.CreateButton(page,self:T("APPLY"),600,-102,100,function() A:ApplyKeyProfile(A.db.keys.selected) end)
 ui.CreateButton(page,self:T("DELETE"),20,-160,100,function() local n=A.db.keys.selected; if n then A.db.keys.profiles[n]=nil; A.db.keys.selected=nil; A:RefreshOptions() end end)
 ui.CreateButton(page,self:T("RECOVERY"),130,-160,130,function() A:RestoreRecovery() end)
 ui.CreateButton(page,self:T("EXPORT"),270,-160,100,function() if A.ioBox then A.ioBox:SetText(A:ExportKeyProfile(A.db.keys.selected)); A.ioBox:HighlightText() end end)
 ui.CreateButton(page,self:T("IMPORT"),380,-160,100,function() if A.ioBox then A:ImportKeyProfile(A.ioBox:GetText()) end end)
 local pt=page:CreateFontString(nil,"ARTWORK","GameFontNormal"); pt:SetPoint("TOPLEFT",20,-210); pt:SetText(self:T("PREVIEW"))
 self.previewBox=ui.CreateEdit(page,20,-235,680,130,true); self.previewBox:SetEnabled(false)
 local it=page:CreateFontString(nil,"ARTWORK","GameFontNormal"); it:SetPoint("TOPLEFT",20,-385); it:SetText(self:T("IMPORT_EXPORT"))
 self.ioBox=ui.CreateEdit(page,20,-410,680,115,true)
 local n=page:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall"); n:SetPoint("TOPLEFT",20,-540); n:SetWidth(680); n:SetJustifyH("LEFT"); n:SetText(self:T("FOREVER_NOTE"))
end
function A:InitializeFeature() end
function A:RefreshFeature() end
