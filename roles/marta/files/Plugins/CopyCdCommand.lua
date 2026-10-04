plugin {
    id = "dotfiles.cdpath",
    name = "Copy cd Command",
    apiVersion = "2.2"
}

action {
    id = "copy",
    name = "Copy cd",
    apply = function(context)
        local folder = context.activePane.model.folder

        if folder == nil then
            return
        end

        local command = "cd '" .. tostring(folder):gsub("'", "'\\''") .. "'"

        martax.clipboard.setString(command)
    end
}
