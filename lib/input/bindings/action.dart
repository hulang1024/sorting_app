class BindingAction {
  final int code;
  final String text;

  const BindingAction(this.code, this.text);
}

class GlobalAction extends BindingAction {
  static const PackageCreateSmart = GlobalAction(1, '智能建包');
  static const PackageCreate = GlobalAction(2, '手动建包');
  static const PackageDelete = GlobalAction(3, '删除集包');
  static const ItemAlloc = GlobalAction(4, '加包减包');
  static const PackageSearch = GlobalAction(5, '查询集包');
  static const ItemSearch = GlobalAction(6, '查询快件');
  static const ItemAllocDelete = GlobalAction(4, '集包减件');
  static const ItemAllocAdd = GlobalAction(5, '集包加件');
  static const ItemAllocSearch = GlobalAction(6, '查询集包快件操作记录');
  static const OK = GlobalAction(7, '确定/执行操作/下一个输入');

  const GlobalAction(int code, String text) : super(code, text);
}

const GLOBAL_ACTIONS = [
  GlobalAction.PackageCreateSmart,
  GlobalAction.PackageCreate,
  GlobalAction.PackageDelete,
  GlobalAction.ItemAlloc,
  GlobalAction.PackageSearch,
  GlobalAction.ItemSearch,
  GlobalAction.ItemAllocDelete,
  GlobalAction.ItemAllocAdd,
  GlobalAction.ItemAllocSearch
];