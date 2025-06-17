# 创建UI系统
var ui = UICanvas.new()
add_child(ui)

# 添加主菜单
var main_menu = preload("res://ui/main_menu.tscn").instantiate()
ui.add_ui(main_menu)

 显示设置弹窗
func _on_settings_pressed():
	var settings = preload("res://ui/settings.tscn")
	ui.switch_ui(settings, UICanvas.UI_LAYER.POPUP, UICanvas.TRANSITION_TYPE.FADE)

# 显示提示
func _on_item_collected():
	ui.show_toast("金币+10!", 1.5)

# 返回主菜单
func _on_back_pressed():
	ui.back(UICanvas.TRANSITION_TYPE.SLIDE_RIGHT)


1. 整体UI系统显示/隐藏
使用 set_ui_visibility() 方法可以控制整个UI系统的可见性：

gdscript
# 显示整个UI系统
ui_canvas.set_ui_visibility(true)

# 隐藏整个UI系统
ui_canvas.set_ui_visibility(false)
2. 特定层级显示/隐藏
使用 set_layer_visibility() 方法可以控制特定层级的显示/隐藏：

gdscript
# 显示背景层
ui_canvas.set_layer_visibility(UICanvas.UI_LAYER.BACKGROUND, true)

# 隐藏弹窗层
ui_canvas.set_layer_visibility(UICanvas.UI_LAYER.POPUP, false)

# 隐藏所有提示
ui_canvas.set_layer_visibility(UICanvas.UI_LAYER.TOAST, false)
3. 单个UI元素显示/隐藏
对于单个UI元素，可以直接操作节点的 visible 属性：

gdscript
# 假设你有一个设置菜单的引用
var settings_menu = ui_canvas.get_uis_in_layer(UICanvas.UI_LAYER.POPUP)[0]

# 显示设置菜单
settings_menu.visible = true

# 隐藏设置菜单
settings_menu.visible = false
4. 通过添加/移除控制显示
使用 add_ui() 和 remove_ui() 方法也可以间接控制显示：

gdscript
# 添加UI（自动显示）
var inventory = preload("res://ui/inventory.tscn").instantiate()
ui_canvas.add_ui(inventory, UICanvas.UI_LAYER.POPUP)

# 移除UI（隐藏并删除）
ui_canvas.remove_ui(inventory)
5. 清空层级
使用 clear_layer() 方法可以清空整个层级的UI：

gdscript
# 清空提示层（隐藏所有提示）
ui_canvas.clear_layer(UICanvas.UI_LAYER.TOAST)

# 清空弹窗层（关闭所有弹窗）
ui_canvas.clear_layer(UICanvas.UI_LAYER.POPUP)
6. 过渡动画中的隐藏
在场景切换时，过渡动画会自动处理显示/隐藏：

gdscript
# 切换到新UI（旧UI会隐藏，新UI会显示）
ui_canvas.switch_ui(new_ui_scene, UICanvas.UI_LAYER.DEFAULT)

# 返回上一个UI（当前UI会隐藏，上一个UI会显示）
ui_canvas.back()
