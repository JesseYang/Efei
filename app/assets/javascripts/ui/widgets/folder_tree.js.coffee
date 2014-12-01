#= require ./_templates/folder_tree
(($) ->
  $.widget "efei.folder_tree",
    options:
      content: [
      ]
      root_folder_id: ""
      click_name_fun: null
    
    _create: ->
      if this.element.find(".name-node").length == 0
        # need to render the root folder
        name_node = "<div class='name-node root'><span class='caret-wrapper'><b class='open'></b></span><i class='icon folder-open'></i><span class='name'>我的文件夹</span></div>"
        children = "<div class='children hide'></div>"
        this.element.append(name_node)
        this.element.append(children)
      children = this.element.children(".children")
      children.empty()
      this.element.attr("data-folderid", this.options.content.id)
      this.element.addClass("root-folder")
      this.options.root_folder_id = this.options.content.id
      children.append(this._generate_dom child) for child in this.options.content.children
      this.refresh_caret(this.options.root_folder_id)
      that = this
      id = this.element.attr("id")
      this._on this.element,
        "click .caret-wrapper": (event) ->
          that.toggle_folder_by_icon_node event.target
          false
      this._on this.element,
        "click .name-node": (event) ->
          folder_id = that.get_folder_id_by_name_node(event.target)
          that.options.click_name_fun folder_id

    hbs: (content) ->
      $(HandlebarsTemplates["ui/widgets/_templates/folder_tree"](content))

    _generate_dom: (content) ->
      dom = $("<div class='folder-node sub-folder' data-folderid=#{content.id}><div class=name-node><span class=caret-wrapper><b /></span><i class='icon folder-closed'> </i><span class=name>#{content.name}</span></div><div class='children hide'></div></div>")
      if content.children.length > 0
        dom.children(".name-node").find("b").addClass("closed")
      children_dom = dom.find(".children")
      children_dom.append(this._generate_dom child) for child in content.children
      dom

    _find_folder_by_id: (folder_id) ->
      this.element.parent().find("*[data-folderid=" + folder_id + "]")

    refresh_caret: (folder_id) ->
      folder = this._find_folder_by_id(folder_id)
      name = folder.children(".name-node")
      children = folder.children(".children").eq(0)
      folder_list = children.children(".folder-node")
      if folder_list.length == 0
        name.find("b").removeClass("open")
        name.find("b").removeClass("closed")
        name.find("i").removeClass("folder-open")
        name.find("i").addClass("folder-closed")
      else if children.hasClass("hide")
        name.find("b").removeClass("open")
        name.find("b").addClass("closed")
        name.find("i").removeClass("folder-open")
        name.find("i").addClass("folder-closed")
      else
        name.find("b").addClass("open")
        name.find("b").removeClass("closed")
        name.find("i").addClass("folder-open")
        name.find("i").removeClass("folder-closed")

    get_selected_folder_id: ->
      selected = this.element.find(".selected")
      return null if selected.length == 0
      selected.closest(".folder-node").data("folderid")

    get_folder_id_by_name_node: (name_node) ->
      $(name_node).closest(".folder-node").data("folderid")

    get_parent_id: (folder_id) ->
      folder = this._find_folder_by_id(folder_id)
      folder.parent().closest(".folder-node").data("folderid")

    insert_folder: (parent_id, new_child) ->
      parent = this._find_folder_by_id(parent_id)
      children = parent.children(".children")
      children.append(this._generate_dom new_child)
      this.refresh_caret(parent_id)

    rename_folder: (folder_id, name) ->
      folder = this._find_folder_by_id(folder_id)
      name_node = folder.children(".name-node").find(".name")
      name_node.text(name)

    move_folder: (folder_id, parent_id) ->
      folder = this._find_folder_by_id(folder_id)
      old_parent_id = folder.parent().closest(".folder-node").data("folderid")
      parent = this._find_folder_by_id(parent_id)
      folder.detach()
      parent.children(".children").append(folder)
      this.refresh_caret(old_parent_id)
      this.refresh_caret(parent_id)

    remove_folder: (folder_id) ->
      folder = this._find_folder_by_id(folder_id)
      parent_id = folder.parent().closest(".folder-node").data("folderid")
      folder.detach()
      this.refresh_caret(parent_id)

    select_folder: (folder_id) ->
      folder = this._find_folder_by_id(folder_id)
      return if folder.length == 0
      selected = this.element.parent().find(".selected")
      selected.removeClass("selected")
      folder_name = folder.children(".name-node")
      folder_name.addClass("selected")
      if folder_id != this.options.root_folder_id
        parent_id = folder.parent().closest(".folder-node").data("folderid")
        this.open_folder(parent_id)

    select_folder_by_name_node: (name_node) ->
      this.select_folder $(name_node).closest(".folder-node").data("folderid")

    open_folder: (folder_id) ->
      folder = this._find_folder_by_id(folder_id)
      folder.children(".children").removeClass("hide")
      this.open_folder folder.parent().closest(".folder-node").data("folderid") if folder.data("folderid") != this.options.root_folder_id
      this.refresh_caret(folder_id)

    open_folder_by_name_node: (name_node) ->
      this.open_folder $(name_node).closest(".folder-node").data("folderid")

    close_folder: (folder_id) ->
      folder = this._find_folder_by_id(folder_id)
      folder.children(".children").addClass("hide")
      this.refresh_caret(folder_id)

    close_folder_by_name_node: (name_node) ->
      this.close_folder $(name_node).closest(".folder-node").data("folderid")

    toggle_folder: (folder_id) ->
      folder = this._find_folder_by_id(folder_id)
      if folder.children(".children").hasClass("hide")
        this.open_folder(folder_id)
      else
        this.close_folder(folder_id)

    toggle_folder_by_icon_node: (name_node) ->
      this.toggle_folder $(name_node).closest(".folder-node").data("folderid")


    _destroy: ->
      this.element.text("")

) jQuery