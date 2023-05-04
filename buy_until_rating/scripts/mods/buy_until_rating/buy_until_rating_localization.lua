--[[
	Translated to Simplified Chinese by deluxghost. Thanks you.
]]

return {
	mod_name = {
		en = "Buy Until Rating",
		["zh-cn"] = "自动购买指定评级物品",
		ru = "Закупка до рейтинга",
	},
	mod_description = {
		en = "Automatically buying selected weapon from Brunt's Armoury until the weapon rating reaches you desired or higher (or reaches quantity limit) .",
		ja = "ブラントの武器庫から、選択した武器が希望の評価を超えるまで（もしくは個数制限に到達するまで）購入し続けます。",
		["zh-cn"] = "在布伦特的军备库中自动购买选中的武器，直到武器达到或超过指定评级（或者达到购买上限）。",
		ru = "Buy Until Rating - выбранное оружие будет автоматически закупаться в Оружейной Бранта до тех пор, пока не будет получен желаемый рейтинг оружия или лучший (либо не будет достигнут лимит количества покупок).",
	},
	desired_rating = {
		en = "Desired Rating",
		ja = "評価の最低値",
		["zh-cn"] = "指定评级",
		ru = "Желаемый рейтинг",
	},
	additional_limit = {
		en = "Additional Limitations",
		ja = "追加の制限",
		["zh-cn"] = "额外限制",
		ru = "Дополнительные ограничения",
	},
	enable_num_limit = {
		en = "Enable Quantity Limit",
		ja = "個数制限を有効にする",
		["zh-cn"] = "启用数量限制",
		ru = "Включить лимит\nколичества покупок",
	},
	num_limit = {
		en = "Quantity Limit",
		ja = "個数制限",
		["zh-cn"] = "数量限制",
		ru = "Лимит количества (шт.)",
	},
	auto_discard = {
		en = "Auto Discard",
		ja = "自動売却",
		["zh-cn"] = "自动出售",
		ru = "Автопродажа",
	},
	enable_auto_discard = {
		en = "Enable Auto Discard",
		ja = "自動売却を有効にする",
		["zh-cn"] = "启用自动出售",
		ru = "Включить автоматическую\nпродажу предметов",
	},
	discard_threshold = {
		en = "Discard Threshold",
		ja = "売却の閾値",
		["zh-cn"] = "出售阈值",
		ru = "Продавать с рейтингом ниже",
	},
	notifications = {
		en = "Notifications",
		ja = "通知など",
		["zh-cn"] = "消息通知",
		ru = "Уведомления",
	},
	enable_rating_notif = {
		en = "Show each item rating",
		ja = "各アイテムの評価を通知する",
		["zh-cn"] = "显示每件物品的评级",
		ru = "Показывать рейтинг каждого предмета",
	},
	enable_print_result = {
		en = "Show result in chat",
		ja = "チャットに結果を表示する",
		["zh-cn"] = "在聊天中显示结果",
		ru = "Показывать результат в чате",
	},
	enable_discard_notif = {
		en = "Show discarded item notification",
		ja = "アイテムの売却通知を表示する",
		["zh-cn"] = "显示出售物品通知",
		ru = "Показывать уведомление о продаже",
	},
	enable_default_notif = {
		en = "Show default item notification",
		ja = "デフォルトのアイテム通知を表示する",
		["zh-cn"] = "显示默认物品通知",
		ru = "Показывать стандартное уведомление",
	},
	notif_dot_caution = {
		en = "Caution: Currently, disabling this setting also disables notification dots in the inventory .",
		ja = "注意：現時点ではこれを無効化するとインベントリの新着マーカーも無効化されます。",
		["zh-cn"] = "注意：目前，禁用此设置会同时禁用库存中的通知圆点。",
		ru = "Внимание: в настоящее время, отключение этого параметра также отключает точки уведомлений в инвентаре.",
	},
	cancel_key = {
		en = "Keybind for Canceling",
		ja = "中止用キーバインド",
		["zh-cn"] = "取消购买快捷键",
		ru = "Клавиша для отмены",
	},
	canceled = {
		en = "Auto Buy Canceled",
		ja = "自動購入を中止しました",
		["zh-cn"] = "自动购买已取消",
		ru = "Автозакупка отменена",
	},
	disabled = {
		en = "Disabled",
		ja = "無効",
		["zh-cn"] = "已禁用",
		ru = "Выключена",
	},
	lower = {
		en = "or Lower",
		ja = "以下",
		["zh-cn"] = "或更低",
		ru = "или ниже",
	},
	unlimited = {
		en = "Unlimited",
		ja = "無制限",
		["zh-cn"] = "无限制",
		ru = "Неогр.",
	},
	num = {
		en = "Quantity",
		ja = "個数",
		["zh-cn"] = "数量",
		ru = "Количество",
	},
	discarded = {
		en = "Discarded",
		ja = "売却済",
		["zh-cn"] = "已出售",
		ru = "Продано",
	},
	max = {
		en = "Max",
		ja = "最高",
		["zh-cn"] = "最高",
		ru = "Макс.",
	},
	avg = {
		en = "Average",
		ja = "平均",
		["zh-cn"] = "平均",
		ru = "Сред.",
	},
}
