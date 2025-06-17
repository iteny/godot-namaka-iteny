extends CanvasLayer
class_name UICanvas

## 强大的CanvasLayer封装类，提供UI层级管理和场景切换功能
##
## 功能特点:
## 1. 多层级UI管理（背景、主界面、弹窗、提示）
## 2. 场景切换与过渡动画
## 3. 模态弹窗支持
## 4. 历史记录导航
## 5. 全局UI事件拦截

# UI层级枚举 - 定义不同的UI层级
enum UI_LAYER {
	BACKGROUND,    # 背景层 (如游戏场景)
	DEFAULT,       # 默认层 (主UI界面)
	POPUP,         # 弹窗层 (设置、菜单等)
	TOAST,         # 提示层 (浮动提示信息)
	LOADING,       # 加载层 (加载界面)
	SYSTEM         # 系统层 (最高优先级)
}

# UI过渡动画类型
enum TRANSITION_TYPE {
	NONE,          # 无过渡
	FADE,          # 淡入淡出
	SLIDE_LEFT,    # 向左滑动
	SLIDE_RIGHT,   # 向右滑动
	SCALE          # 缩放效果
}

# 层级容器字典
var _layers: Dictionary = {}
# 历史记录栈
var _history: Array[Dictionary] = []
# 当前活动UI
var _current_ui: Control = null
# 模态背景
var _modal_background: ColorRect = null

func _ready() -> void:
	# 初始化UI层级容器
	_initialize_layers()
	# 创建模态背景
	_create_modal_background()
	# 连接窗口大小变化信号
	get_viewport().size_changed.connect(_on_window_resized)
	# 初始设置大小
	_on_window_resized()

# 获取视口尺寸的正确方法
func _get_viewport_size() -> Vector2:
	return get_viewport().get_visible_rect().size

# 初始化所有UI层级容器
func _initialize_layers() -> void:
	# 为每个枚举值创建容器节点
	for layer in UI_LAYER.values():
		# 创建新容器
		var container := Control.new()
		# 设置容器名称便于调试
		container.name = UI_LAYER.keys()[layer].capitalize()
		# 设置容器填充整个屏幕
		container.size = _get_viewport_size()
		# 添加到CanvasLayer
		add_child(container)
		# 存储到字典
		_layers[layer] = container

# 创建模态弹窗背景
func _create_modal_background() -> void:
	_modal_background = ColorRect.new()
	_modal_background.name = "ModalBackground"
	# 设置颜色为半透明黑色
	_modal_background.color = Color(0, 0, 0, 0.5)
	# 默认不可见
	_modal_background.visible = false
	# 填充整个屏幕
	_modal_background.size = _get_viewport_size()
	# 置于POPUP层
	_layers[UI_LAYER.POPUP].add_child(_modal_background)
	# 确保在弹窗之下
	_modal_background.z_index = -1
	# 拦截点击事件
	_modal_background.mouse_filter = Control.MOUSE_FILTER_STOP
	# 设置锚点以保持全屏
	_modal_background.set_anchors_preset(Control.PRESET_FULL_RECT)

# 窗口大小变化时的处理
func _on_window_resized() -> void:
	var viewport_size = _get_viewport_size()
	
	# 更新模态背景大小
	if _modal_background:
		_modal_background.size = viewport_size
	
	# 更新所有UI大小
	for container in _layers.values():
		container.size = viewport_size
		for child in container.get_children():
			if child is Control:
				child.size = viewport_size

## 添加UI到指定层级
## @param ui_node: 要添加的UI节点
## @param layer: 目标层级 (默认为DEFAULT层)
## @param as_current: 是否设置为当前活动UI
func add_ui(ui_node: Control, layer: int = UI_LAYER.DEFAULT, as_current: bool = true) -> void:
	# 获取目标层级容器
	var container = _layers.get(layer)
	if not container:
		push_error("Invalid UI layer: " + str(layer))
		return
	
	# 添加到容器
	container.add_child(ui_node)
	
	# 设置UI填充整个屏幕
	ui_node.size = _get_viewport_size()
	ui_node.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# 记录历史
	if as_current:
		_push_to_history(ui_node, layer)
		_current_ui = ui_node
	
	# 如果添加到弹窗层，显示模态背景
	if layer == UI_LAYER.POPUP:
		_modal_background.visible = true
		# 模态背景在弹窗之前
		_modal_background.z_index = ui_node.z_index - 1

## 从层级中移除UI
## @param ui_node: 要移除的UI节点
func remove_ui(ui_node: Control) -> void:
	# 如果移除的是当前UI，清除当前引用
	if ui_node == _current_ui:
		_current_ui = null
	
	# 从父节点移除
	if ui_node.get_parent():
		ui_node.get_parent().remove_child(ui_node)
	
	# 检查弹窗层是否还有UI
	_check_popup_layer()

## 切换UI场景
## @param ui_scene: 新UI场景(PackedScene)
## @param layer: 目标层级
## @param transition: 过渡动画类型
## @param duration: 动画时长(秒)
func switch_ui(ui_scene: PackedScene, layer: int = UI_LAYER.DEFAULT, 
			  transition: int = TRANSITION_TYPE.FADE, duration: float = 0.3) -> void:
	# 移除当前UI
	if _current_ui:
		# 根据过渡类型执行移除动画
		_apply_transition_out(_current_ui, transition, duration)
	
	# 实例化新UI
	var new_ui = ui_scene.instantiate()
	# 添加到指定层级
	add_ui(new_ui, layer)
	
	# 应用进入动画
	_apply_transition_in(new_ui, transition, duration)

## 返回到上一个UI
## @param transition: 过渡动画类型
## @param duration: 动画时长(秒)
func back(transition: int = TRANSITION_TYPE.SLIDE_RIGHT, duration: float = 0.3) -> bool:
	# 检查历史记录
	if _history.size() <= 1:
		return false
	
	# 获取当前UI
	var current = _history.pop_back()
	var current_ui = current["node"]
	
	# 应用退出动画
	_apply_transition_out(current_ui, transition, duration)
	
	# 获取上一个UI
	var prev = _history.back()
	var prev_ui = prev["node"]
	
	# 显示上一个UI
	prev_ui.visible = true
	# 应用进入动画
	_apply_transition_in(prev_ui, transition, duration)
	
	# 更新当前UI
	_current_ui = prev_ui
	
	# 检查弹窗层
	_check_popup_layer()
	
	return true

## 显示提示消息
## @param message: 提示内容
## @param duration: 显示时长(秒)
func show_toast(message: String, duration: float = 2.0) -> void:
	# 创建提示标签
	var toast := Label.new()
	toast.text = message
	toast.name = "Toast"
	
	# 样式设置
	toast.add_theme_color_override("font_color", Color.WHITE)
	toast.add_theme_font_size_override("font_size", 24)
	
	# 使用中心定位
	var viewport_size = _get_viewport_size()
	toast.position = viewport_size / 2 - Vector2(100, 20)
	
	# 添加到TOAST层
	add_ui(toast, UI_LAYER.TOAST, false)
	
	# 设置动画
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(toast, "position", toast.position - Vector2(0, 100), 0.5)
	tween.tween_property(toast, "modulate:a", 0.0, 0.5).set_delay(duration)
	tween.chain().tween_callback(func(): remove_ui(toast))

## 应用进入过渡动画
func _apply_transition_in(ui: Control, transition: int, duration: float) -> void:
	var viewport_size = _get_viewport_size()
	var tween = create_tween()
	
	match transition:
		TRANSITION_TYPE.FADE:
			ui.modulate.a = 0
			tween.tween_property(ui, "modulate:a", 1.0, duration)
		
		TRANSITION_TYPE.SLIDE_LEFT:
			ui.position.x = viewport_size.x
			tween.tween_property(ui, "position:x", 0, duration)
		
		TRANSITION_TYPE.SLIDE_RIGHT:
			ui.position.x = -viewport_size.x
			tween.tween_property(ui, "position:x", 0, duration)
		
		TRANSITION_TYPE.SCALE:
			ui.scale = Vector2(0.5, 0.5)
			ui.modulate.a = 0
			tween.set_parallel(true)
			tween.tween_property(ui, "scale", Vector2.ONE, duration)
			tween.tween_property(ui, "modulate:a", 1.0, duration)

## 应用退出过渡动画
func _apply_transition_out(ui: Control, transition: int, duration: float) -> void:
	var viewport_size = _get_viewport_size()
	var tween = create_tween()
	
	match transition:
		TRANSITION_TYPE.FADE:
			tween.tween_property(ui, "modulate:a", 0.0, duration)
		
		TRANSITION_TYPE.SLIDE_LEFT:
			tween.tween_property(ui, "position:x", -viewport_size.x, duration)
		
		TRANSITION_TYPE.SLIDE_RIGHT:
			tween.tween_property(ui, "position:x", viewport_size.x, duration)
		
		TRANSITION_TYPE.SCALE:
			tween.set_parallel(true)
			tween.tween_property(ui, "scale", Vector2(0.5, 0.5), duration)
			tween.tween_property(ui, "modulate:a", 0.0, duration)
	
	# 动画完成后移除UI
	tween.tween_callback(func(): remove_ui(ui))

## 添加UI到历史记录
func _push_to_history(ui_node: Control, layer: int) -> void:
	# 创建历史记录项
	var entry = {
		"node": ui_node,
		"layer": layer,
		"time": Time.get_unix_time_from_system()
	}
	
	# 添加到历史栈
	_history.append(entry)

## 检查弹窗层状态
func _check_popup_layer() -> void:
	var popup_container = _layers[UI_LAYER.POPUP]
	# 检查是否有弹窗显示
	var has_popup = false
	for child in popup_container.get_children():
		if child != _modal_background and child.visible:
			has_popup = true
			break
	
	# 更新模态背景状态
	_modal_background.visible = has_popup

## 清空指定层级
## @param layer: 要清空的层级
func clear_layer(layer: int) -> void:
	var container = _layers.get(layer)
	if not container:
		return
	
	# 移除所有子节点
	for child in container.get_children():
		# 保留模态背景
		if child == _modal_background:
			continue
		child.queue_free()
	
	# 更新弹窗层状态
	if layer == UI_LAYER.POPUP:
		_check_popup_layer()

## 获取指定层级的UI列表
func get_uis_in_layer(layer: int) -> Array[Control]:
	var result: Array[Control] = []
	var container = _layers.get(layer)
	if container:
		for child in container.get_children():
			if child is Control:
				result.append(child)
	return result

## 设置所有UI的可见性
func set_ui_visibility(visible: bool) -> void:
	for container in _layers.values():
		for child in container.get_children():
			if child is CanvasItem:
				child.visible = visible
