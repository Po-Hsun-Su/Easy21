function appendGfxToPlot(gfx, Plot)

   -- Load the xml parser to modify the xml
   require("LuaXML")
   if xml == nil then xml = require("LuaXML") end

   -- Append Non-ASCII-127 char decoding/encoding
   xml.registerCode('&amp;quot;', '"')
   xml.registerCode('&amp;apos;', "'")
   xml.registerCode('&amp;amp;' , "&amp;")
   xml.registerCode('&amp;lt;' , "&lt;")
   xml.registerCode('&amp;gt;' , "&gt;")

   -- Simulate the uid method from gfx to fit the gfx format
   local function uid()
      return 'dom_' .. (os.time() .. math.random()):gsub('%.','')
   end

   -- append a new method gfx to the Plot metatable
   Plot["gfx"] = function(self)

      -- compute the gtx id of the plot
      local idGfx = uid()
      local gfxFile = gfx.static .. idGfx .. ".html"

      -- compute the iTorch HTML
      local html = self:toHTML()
      local txml = xml.eval(html)

      --Copy the script node into a new object that has the core functions
      local script = xml.new("script")
      script["type"] = "text/javascript"

      -- This is crapy --&gt; look for something better but xmllua sucks
      for _, node in pairs(txml:find("meta")) do
         if node.TAG ~= nil then
         -- the script node is the core function is the only node that is not empty
            if node[node.TAG] == "script" and node[1] ~= nil then
               -- copy the script data
               script[1] = node[1]
               break
            end
         end
      end

      --Look for the single div of the file that contains the plot features
      local iTorchDiv = txml:find("div")
      iTorchDiv["style"] = "background:#fff" -- fit gtx colours

      --Create a new div to fit Gfx requirement
      local divGfx = xml.new("div")
      divGfx["id"] = idGfx
      divGfx:append(iTorchDiv)

      -- Append the script and the div to a new file
      -- NB : gtx requires no encapsulating tag
      local f = io.open(gfxFile, "w")

      f:write(divGfx:str())
      f:write(script:str())
      f:close()

      print("[gfx.js] rendering cell &lt;" .. idGfx .. "&gt;")

   end

end
