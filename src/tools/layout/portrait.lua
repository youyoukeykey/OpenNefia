local portrait = {
   { name = "man1" },
   { name = "man2" },
   { name = "man3" },
   { name = "man4" },
   { name = "man5" },
   { name = "man6" },
   { name = "man7" },
   { name = "man8" },
   { name = "man9" },
   { name = "man10" },
   { name = "man11" },
   { name = "man12" },
   { name = "man13" },
   { name = "man14" },
   { name = "man15" },
   { name = "man16" },
   { name = "man17" },
   { name = "man18" },
   { name = "man19" },
   { name = "man20" },
   { name = "man21" },
   { name = "man22" },
   { name = "man23" },
   { name = "man24" },
   { name = "man25" },
   { name = "man26" },
   { name = "man27" },
   { name = "man28" },
   { name = "man29" },
   { name = "man30" },
   { name = "man31" },
   { name = "man32" },
   { name = "man33" },
   { name = "gilbert" },
   { name = "man34" },
   { name = "man35" },
   { name = "arnord" },
   { name = "man36" },
   { name = "balzak" },
   { name = "conery" },
   { name = "man39" },
   { name = "man40" },
   { name = "man41" },
   { name = "man42" },
   { name = "man43" },
   { name = "man44" },
   { name = "barius" },
   { name = "loyter" },
   { name = "bethel" },
   { name = "orphe" },
   { name = "norne" },
   { name = "zeome" },
   { name = "saimore" },
   { name = "xabi" },
   { name = "karam" },
   { name = "lomias" },
   { name = "man45" },
   { name = "sevilis" },
   { name = "man46" },
   { name = "man47" },
   { name = "man48" },
   { name = "woman1" },
   { name = "woman2" },
   { name = "woman3" },
   { name = "woman4" },
   { name = "woman5" },
   { name = "woman6" },
   { name = "woman7" },
   { name = "woman8" },
   { name = "woman9" },
   { name = "woman10" },
   { name = "woman11" },
   { name = "woman12" },
   { name = "woman13" },
   { name = "woman14" },
   { name = "woman15" },
   { name = "woman16" },
   { name = "woman17" },
   { name = "woman18" },
   { name = "woman19" },
   { name = "woman20" },
   { name = "woman21" },
   { name = "woman22" },
   { name = "woman23" },
   { name = "woman24" },
   { name = "woman25" },
   { name = "woman26" },
   { name = "woman27" },
   { name = "woman28" },
   { name = "woman29" },
   { name = "woman30" },
   { name = "woman31" },
   { name = "woman32" },
   { name = "woman34" },
   { name = "woman35" },
   { name = "mia" },
   { name = "woman36" },
   { name = "woman37" },
   { name = "woman38" },
   { name = "woman39" },
   { name = "woman40" },
   { name = "woman41" },
   { name = "woman42" },
   { name = "woman43" },
   { name = "woman44" },
   { name = "woman45" },
   { name = "woman46" },
   { name = "larnneire" },
   { name = "shena" },
   { name = "miches" },
   { name = "isca" },
   { name = "woman47" },
   { name = "woman48" },
   { name = "stersha" },
   { name = "erystia" },
   { name = "liana" },
   { name = "woman49" },
}

local function gen_portraits(portraits)
   local l = {}
   for i, v in ipairs(portraits) do
      local id = i - 1
      l[#l + 1] = {
         type = "crop",
         id = id,
         source = "graphic/face1.bmp",
         output = string.format("graphic/face/%s.png", v.name),
         x = (id % 15) * 48,
         y = math.floor(id / 15) * 48,
         width = 48,
         height = 72,
         no_alpha = true
      }
   end
   return l
end

portrait = gen_portraits(portrait)

return {
   portrait = portrait
}