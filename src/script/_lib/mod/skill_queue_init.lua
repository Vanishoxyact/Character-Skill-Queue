-- Located at script/_lib/mod/

-- Taken from CA mod loader
function my_load_mod_script(filename)
   local pointer = 1;

   local filename_for_out = filename;

   while true do
      local next_separator = string.find(filename, "\\", pointer) or string.find(filename, "/", pointer);

      if next_separator then
         pointer = next_separator + 1;
      else
         if pointer > 1 then
            filename = string.sub(filename, pointer);
         end;
         break;
      end;
   end;

   local suffix = string.sub(filename, string.len(filename) - 3);

   if string.lower(suffix) == ".lua" then
      filename = string.sub(filename, 1, string.len(filename) - 4);
   end;

   -- Avoid loading more than once
   if package.loaded[filename] then
      return package.loaded[filename];
   end

   -- Loads a Lua chunk from the file
   local loaded_file, err = loadfile(filename);

   -- Make sure something was loaded from the file
   if loaded_file then
      -- output
      local out_str = "Loading mod file [" .. filename_for_out .. "]";
      ModLog(out_str);

      -- Set the environment of the Lua chunk to the global environment
      setfenv(loaded_file, core:get_env());

      -- Execute the loaded Lua chunk so the functions within are registered
      out.inc_tab();
      local outTable = loaded_file();
      out.dec_tab();
      -- Make sure the file is set as loaded
      if outTable then
         package.loaded[filename] = outTable;
      else
         package.loaded[filename] = true;
      end
      return package.loaded[filename];
   else
      -- output
      local out_str = "Failed to load mod file [" .. filename_for_out .. "], error is: " .. tostring(err);
      ModLog(out_str);
      return false;
   end;
end;

local path = "script/skill_queue/?.lua;"
package.path = path .. package.path


my_load_mod_script("skill_queue")