local getArgs = require('Module:Arguments').getArgs
local p = {} -- module's table

local am = {}  -- Elements with wiki links
am.H="[[Hydrogen|H]]";am.He="[[Helium|He]]";
am.Li="[[Lithium|Li]]";am.Be="[[Beryllium|Be]]";am.B="[[Boron|B]]";am.C="[[Carbon|C]]";am.N="[[Nitrogen|N]]";am.O="[[Oxygen|O]]";am.F="[[Fluorine|F]]";am.Ne="[[Neon|Ne]]";
am.Na="[[Sodium|Na]]";am.Mg="[[Magnesium|Mg]]";am.Al="[[Aluminium |Al]]";am.Si="[[Silicon|Si]]";am.P="[[Phosphorus|P]]";am.S="[[Sulfur|S]]";am.Cl="[[Chlorine|Cl]]";am.Ar="[[Argon|Ar]]";
am.K="[[Potassium|K]]";am.Ca="[[Calcium|Ca]]";am.Sc="[[Scandium|Sc]]";am.Ti="[[Titanium|Ti]]";am.V="[[Vanadium|V]]";am.Cr="[[Chromium|Cr]]";am.Mn="[[Manganese|Mn]]";am.Fe="[[Iron|Fe]]";am.Co="[[Cobalt|Co]]";am.Ni="[[Nickel|Ni]]";am.Cu="[[Copper|Cu]]";am.Zn="[[Zinc|Zn]]";am.Ga="[[Gallium|Ga]]";am.Ge="[[Germanium|Ge]]";am.As="[[Arsenic|As]]";am.Se="[[Selenium|Se]]";am.Br="[[Bromine|Br]]";am.Kr="[[Krypton|Kr]]";am.Rb="[[Rubidium|Rb]]";
am.Sr="[[Strontium|Sr]]";am.Y="[[Yttrium|Y]]";am.Zr="[[Zirconium|Zr]]";am.Nb="[[Niobium|Nb]]";am.Mo="[[Molybdenum|Mo]]";am.Tc="[[Technetium|Tc]]";am.Ru="[[Ruthenium|Ru]]";am.Rh="[[Rhodium|Rh]]";am.Pd="[[Palladium|Pd]]";am.Ag="[[Silver|Ag]]";am.Cd="[[Cadmium|Cd]]";am.In="[[Indium|In]]";am.Sn="[[Tin|Sn]]";am.Sb="[[Antimony|Sb]]";am.Te="[[Tellurium|Te]]";am.I="[[Iodine|I]]";am.Xe="[[Xenon|Xe]]";
am.Cs="[[Caesium|Cs]]";am.Ba="[[Barium|Ba]]";am.La="[[Lanthanum|La]]";am.Ce="[[Cerium|Ce]]";am.Pr="[[Praseodymium|Pr]]";am.Nd="[[Neodymium|Nd]]";am.Pm="[[Promethium|Pm]]";am.Sm="[[Samarium|Sm]]";am.Eu="[[Europium|Eu]]";am.Gd="[[Gadolinium|Gd]]";am.Tb="[[Terbium|Tb]]";am.Dy="[[Dysprosium|Dy]]";am.Ho="[[Holmium|Ho]]";am.Er="[[Erbium|Er]]";am.Tm="[[Thulium|Tm]]";am.Yb="[[Ytterbium|Yb]]";am.Lu="[[Lutetium|Lu]]";am.Hf="[[Hafnium|Hf]]";am.Ta="[[Tantalum|Ta]]";am.W="[[Tungsten|W]]";am.Re="[[Rhenium|Re]]";am.Os="[[Osmium|Os]]";am.Ir="[[Iridium|Ir]]";am.Pt="[[Platinum|Pt]]";am.Au="[[Gold|Au]]";am.Hg="[[Mercury (element)|Hg]]";am.Tl="[[Thallium|Tl]]";am.Pb="[[Lead|Pb]]";am.Bi="[[Bismuth|Bi]]";am.Po="[[Polonium|Po]]";am.At="[[Astatine|At]]";am.Rn="[[Radon|Rn]]";
am.Fr="[[Francium|Fr]]";am.Ra="[[Radium|Ra]]";am.Ac="[[Actinium|Ac]]";am.Th="[[Thorium|Th]]";am.Pa="[[Protactinium|Pa]]";am.U="[[Uranium|U]]";am.Np="[[Neptunium|Np]]";am.Pu="[[Plutonium|Pu]]";am.Am="[[Americium|Am]]";am.Cm="[[Curium|Cm]]";am.Bk="[[Berkelium|Bk]]";am.Cf="[[Californium|Cf]]";am.Es="[[Einsteinium|Es]]";am.Fm="[[Fermium|Fm]]";am.Md="[[Mendelevium|Md]]";am.No="[[Nobelium|No]]";am.Lr="[[Lawrencium|Lr]]";am.Rf="[[Rutherfordium|Rf]]";am.Db="[[Dubnium|Db]]";am.Sg="[[Seaborgium|Sg]]";am.Bh="[[Bohrium|Bh]]";am.Hs="[[Hassium|Hs]]";am.Mt="[[Meitnerium|Mt]]";am.Ds="[[Darmstadtium|Ds]]";am.Rg="[[Roentgenium|Rg]]";am.Cp="[[Copernicium|Cp]]";am.Nh="[[Nihonium|Nh]]";am.Fl="[[Flerovium|Fl]]";am.Mc="[[Moscovium|Mc]]";am.Lv="[[Livermorium|Lv]]";am.Ts="[[Tennessine|Ts]]";am.Og="[[Oganesson|Og]]";

local T_ELEM = 0         -- token types
local T_NUM = 1          -- number
local T_OPEN = 2         -- open '('
local T_CLOSE = 3        -- close ')'
local T_PM_CHARGE = 4    -- + or –
local T_WATER = 6        -- .xH2O x number
local T_CRYSTAL = 9      -- .x
local T_CHARGE = 8       -- charge (x+), (x-)
local T_SUF_CHARGE = 10  -- suffix and charge e.g. 2+ from H2+
local T_SUF_CHARGE2 = 12 -- suffix and (charge) e.g. 2(2+) from He2(2+)
local T_SPECIAL = 14     -- starting with \ e.g. \d for double bond (=)
local T_SPECIAL2 = 16    -- starting with \y{x} e.g. \i{12} for isotope with mass number 12
local T_ARROW_R = 17     -- match: ->
local T_ARROW_EQ = 18    -- match: <->
local T_UNDERSCORE = 19  -- _{ ... }
local T_CARET = 20       -- ^{ ... }
local T_NOCHANGE = 30        -- Anything else like ☃

function su(up, down) -- like template:su
  if (down == "") then 
    return "<span style=\"display:inline-block; margin-bottom:-0.3em; vertical-align:0.8em; line-height:1.2em; font-size:70%; text-align:left;\">" .. up .. "<br /></span>";
  else
    return "<span style=\"display:inline-block; margin-bottom:-0.3em; vertical-align:-0.4em; line-height:1.2em; font-size:70%; text-align:left;\">" .. up .. "<br />" .. down .. "</span>";
  end
end

function DotIt()
  return '&nbsp;<span style="font-weight:bold;">&middot;</span>&#32;'
end


function item(f) -- (iterator) returns one token (type, value) at a time from the formula 'f'
   local i = 1
   local first = "true";

   return function ()
	local t, x = nil, nil

        if (first == "true" and f:match('^[0-9]', i)) then 
                 x = f:match('^[%d.]+', i); t = T_NOCHANGE; i = i + x:len();   -- matching coefficient (need a space first)

        elseif i <= f:len() then
                              x = f:match('^%s+[%d.]+', i); t = T_NOCHANGE;  -- matching coefficient (need a space first)
		if not x then x = f:match('^%s[+]', i); t = T_NOCHANGE; end       -- matching + (H2O + H2O)
		if not x then x = f:match('^%&%#[%w%d]+%;', i); t = T_NOCHANGE; end       -- &#...;
		if not x then x = f:match('^%<%-%>', i); t = T_ARROW_EQ; end       -- matching <->
		if not x then x = f:match('^%-%>', i); t = T_ARROW_R; end       -- matching ->
		if not x then x = f:match('^%u%l*', i); t = T_ELEM; end        -- matching symbols like Aaaaa
		if not x then x = f:match('^%d+[+-]', i); t = T_SUF_CHARGE; end        -- matching x+, x-
		if not x then x = f:match('^%d+%(%d*[+-]%)', i); t = T_SUF_CHARGE2; end        -- matching x(y+/-), x(+/-)
		if not x then x = f:match('^%(%d*[+-]%)', i); t = T_CHARGE; end        -- matching (x+) (xx+), (x-) (xx-)
		if not x then x = f:match('^[%d.]+', i); t = T_NUM; end        -- matching number
		if not x then x = f:match('^[(|{|%[]', i); t = T_OPEN; end     -- matching ({[
		if not x then x = f:match('^[)|}|%]]', i); t = T_CLOSE; end           -- matching )}]
		if not x then x = f:match('^[+-]', i); t = T_PM_CHARGE; end        -- matching + or -
		if not x then x = f:match('^%*[%d.]*H2O', i); t = T_WATER; end -- Crystal water
		if not x then x = f:match('^%*[%d.]*', i); t = T_CRYSTAL; end -- Crystal
		if not x then x = f:match('^[\\].{%d+}', i); t = T_SPECIAL2; end -- \y{x}
		if not x then x = f:match('^[\\].', i); t = T_SPECIAL; end -- \x
		if not x then x = f:match('^_{[^}]*}', i); t = T_UNDERSCORE; end -- _{...}
		if not x then x = f:match('^\^{[^}]*}', i); t = T_CARET; end -- ^{...}
		if not x then x = f:match('^.', i); t = T_NOCHANGE; end  --the rest - one by one
		if x then i = i + x:len(); else i = i + 999; error("Invalid character in formula!!!!!!! : "..f) end
	end
        first = "false"
	return t, x
	end
   end

function p._chem(args)
   
local f = args[1] or ''

   f = string.gsub(f, "–", "-")  -- replace – with - (hyphen not ndash)
   f = string.gsub(f, "−", "-")  -- replace – with - (hyphen not minus sign)

   local sumO = 0
   local formula = ''
   local t, x

   local link = args['link'] or ""
   local auto = args['auto'] or ""

   if not (link == '') then formula = formula .. "[[" .. link .. "|"; end   -- wikilink start [[link|
 
   for t, x in item(f) do 
      if     t == T_ELEM then if (auto == '') then formula = formula .. x elseif am[x] then formula = formula .. am[x]; am[x] = x else formula = formula .. x end 
      elseif t == T_COEFFICIENT then formula = formula .. x
      elseif t == T_NUM   then formula = formula .. su("", x);
      elseif t == T_OPEN  then formula = formula .. x; sumO = sumO + 1;        -- ( {
      elseif t == T_CLOSE then formula = formula .. x; sumO = sumO -1;         -- ) }
      elseif t == T_PM_CHARGE    then formula = formula .. su(string.gsub(x, "-", "−"), "");
      elseif t == T_SUF_CHARGE then 
           formula = formula .. su(string.gsub(string.match(x, "[+-]"), "-", "−"), string.match(x, "%d+"), "");
      elseif t == T_SUF_CHARGE2 then 
          formula = formula .. su(string.sub(string.gsub(string.match(x, "%(%d*[+-]"), "-", "−"), 2, -1), string.match(x, "%d+"))
      elseif t == T_CHARGE then formula = formula .. "<sup>"; if string.match(x, "%d+") then formula = formula .. string.match(x, "%d+"); end formula = formula .. string.gsub(string.match(x, "[%+-]"), "-", "−") .. "</sup>";  -- can not concatenat a nil value from string.match(x, "%d+");
      elseif t == T_CRYSTAL then formula = formula .. DotIt() .. string.gsub( x, "*", ' ', 1 );
      elseif t == T_SPECIAL then
          parameter = string.sub(x, 2, 2) -- x fra \x  
          if       parameter == "s" then formula = formula .. "–"   -- single bond
            elseif parameter == "d" then formula = formula .. "="   -- double bond
            elseif parameter == "t" then formula = formula .. "≡"   -- tripple bond
            elseif parameter == "q" then formula = formula .. "≣"   -- Quadruple bond
            elseif parameter == "h" then formula = formula .. "η"   -- η, hapticity
            elseif parameter == "*" then formula = formula .. "*"   -- *, normal *
            elseif parameter == "-" then formula = formula .. "-"   -- -
            elseif parameter == "\\" then formula = formula .. "\\"   -- \
            elseif parameter == "\'" then formula = formula .. "&#39;"   -- html-code for '
          end
      elseif t == T_SPECIAL2 then  -- \y{x}
         parameter = string.sub(x, 2, 2) -- y fra \y{x} 
          if parameter  == "h" then --[[Hapticity]]
             if (auto == '') then formula = formula .. "η<sup>" .. string.match(x, '%d+') .. "</sup>−" 
               else
             formula = formula .. "[[Hapticity|η<sup>" .. string.match(x, '%d+') .. "</sup>]]−" 
             end
          elseif parameter == "m" then formula = formula .. "μ<sup>" .. string.match(x, '%d+') .. "</sup>−" -- mu ([[bridging ligand]])
          end
      elseif t == T_WATER then 
        if string.match(x, "^%*[%d.]") then 
            formula = formula .. DotIt() .. string.match(x, "%f[%.%d]%d*%.?%d*%f[^%.%d%]]") .. "H<sub>2</sub>O";
        else
          formula = formula .. DotIt() .. "H<sub>2</sub>O";
        end  
      elseif t == T_UNDERSCORE  then formula = formula .. su("", string.sub(x,3,-2)) -- x contains _{string}
      elseif t == T_CARET then formula = formula .. su(string.sub(x,3,-2), "") -- x contains ^{string}
      elseif t == T_ARROW_R then formula = formula .. " → "
      elseif t == T_ARROW_EQ then formula = formula .. " ⇌ "
      elseif t == T_NOCHANGE  then formula = formula .. x;  -- The rest - everything which isn't captured by the regular expresions. E.g. wikilinks and pipes
     
      else error('unreachable - ???') end -- in fact, unreachable

end

   if not (link == nil or link == '') then formula = formula .. "]]"; end   -- wikilink closing ]]

   return '<span class="chemf nowrap">' .. formula .. '</span>' 
end

function p.chem(frame)
	local args = getArgs(frame)
	return p._chem(args)
end

return p
