return { 
  "echasnovski/mini.pairs", 
  version = false,
  config = function() require("mini.pairs").setup({
    mappings = { 
      ["\\["] = {action = "open", pair="\\[\\]", neigh_pattern = "[^\\]"}
    }
  }) end 
}


