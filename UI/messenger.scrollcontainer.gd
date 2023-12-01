extends ScrollContainer

var scrollbar

func scrollbar_changed():
	self.scroll_vertical = scrollbar.max_value


func _ready(): 
	scrollbar = get_v_scroll_bar()
	scrollbar.changed.connect(scrollbar_changed)
	
