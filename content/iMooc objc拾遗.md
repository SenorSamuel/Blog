## iMooc objc拾遗
![SamuelChan/20180704110550.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180704110550.png)

### 0x01 分类 category

- 作用: 给系统类添加方法和属性

- 特点: 1.运行时添加  2.分类方法会"覆盖"宿主类的方法 3.最后编译的分类方法被最先遍历添加  

- 添加内容: 实例方法,类方法,协议,属性

- 原理 [runtime源码 704](https://opensource.apple.com/tarballs/objc4/)

![SamuelChan/20180704121921.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180704121921.png)

```objc
struct category_t {
    const char *name;
    classref_t cls;
    struct method_list_t *instanceMethods;
    struct method_list_t *classMethods;
    struct protocol_list_t *protocols;
    struct property_list_t *instanceProperties;
};

/***********************************************************************
* remethodizeClass
* Attach outstanding categories to an existing class.
* Fixes up cls's method list, protocol list, and property list.
* Updates method caches for cls and its subclasses.
* Locking: runtimeLock must be held by the caller
**********************************************************************/
static void remethodizeClass(Class cls)
{
    category_list *cats;
    BOOL isMeta;

    rwlock_assert_writing(&runtimeLock);

    //添加的是类还是meta类
    isMeta = cls->isMetaClass(); 

    // Re-methodizing: check for more categories
    if ((cats = unattachedCategoriesForClass(cls))) {
        chained_property_list *newproperties;
        const protocol_list_t **newprotos;
        
        if (PrintConnecting) {
            _objc_inform("CLASS: attaching categories to class '%s' %s", 
                         cls->nameForLogging(), isMeta ? "(meta)" : "");
        }
        
        // Update methods, properties, protocols
        
        // 分类添加方法
        attachCategoryMethods(cls, cats, YES);
        
        newproperties = buildPropertyList(nil, cats, isMeta);
        if (newproperties) {
            newproperties->next = cls->data()->properties;
            cls->data()->properties = newproperties;
        }
        
        newprotos = buildProtocolList(cats, nil, cls->data()->protocols);
        if (cls->data()->protocols  &&  cls->data()->protocols != newprotos) {
            _free_internal(cls->data()->protocols);
        }
        cls->data()->protocols = newprotos;
        
        _free_internal(cats);
    }
}


// 分类添加方法

static void attachCategoryMethods(Class cls, category_list *cats, bool flushCaches)
{
    if (!cats) return;
    if (PrintReplacedMethods) printReplacements(cls, cats);

    bool isMeta = cls->isMetaClass();
    //装着method_list_t的二维数组
    method_list_t **mlists = (method_list_t **)
        _malloc_internal(cats->count * sizeof(*mlists));

    // 最后编译的分类方法被最先遍历添加
    int mcount = 0;
    int i = cats->count;
    BOOL fromBundle = NO;
    while (i--) {
        method_list_t *mlist = cat_method_list(cats->list[i].cat, isMeta);
        if (mlist) {
            mlists[mcount++] = mlist;
            fromBundle |= cats->list[i].fromBundle;
        }
    }

    attachMethodLists(cls, mlists, mcount, NO, fromBundle, flushCaches);

    _free_internal(mlists);
}



/*
内存拷贝
[
  A  ----> [addedList中的第一个元素]
  B ----> [addedList中的第二个元素]
  C ----> [addedList中的第三个元素]
  [原有的第一个元素]
  [原有的第二个元素]
]
 即:分类方法会"覆盖"宿主类的方法
*/
static void 
attachMethodLists(Class cls, method_list_t **addedLists, int addedCount, 
                  bool baseMethods, bool methodsFromBundle, 
                  bool flushCaches)
{
    rwlock_assert_writing(&runtimeLock);
	
	......

    // Method list array is nil-terminated.
    // Some elements of lists are nil; we must filter them out.

    // Add method lists to array.
    // Reallocate un-fixed method lists.
    // The new methods are PREPENDED to the method list array.

    newCount = 0;
    int i;
    for (i = 0; i < addedCount; i++) {
        method_list_t *mlist = addedLists[i];
        if (!mlist) continue;

        // Fixup selectors if necessary
        if (!isMethodListFixedUp(mlist)) {
            mlist = fixupMethodList(mlist, methodsFromBundle, true/*sort*/);
        }

        // Scan for method implementations tracked by the class's flags
        if (scanForCustomRR  &&  methodListImplementsRR(mlist)) {
            cls->setHasCustomRR();
            scanForCustomRR = false;
        }
        if (scanForCustomAWZ  &&  methodListImplementsAWZ(mlist)) {
            cls->setHasCustomAWZ();
            scanForCustomAWZ = false;
        }

        // Update method caches
        if (flushCaches) {
            cache_eraseMethods(cls, mlist);
        }
        
        // Fill method list array
        newLists[newCount++] = mlist;
    }

    // Copy old methods to the method list array
    for (i = 0; i < oldCount; i++) {
        newLists[newCount++] = oldLists[i];
    }
    if (oldLists  &&  oldLists != oldBuf) free(oldLists);

    // nil-terminate
    newLists[newCount] = nil;

    if (newCount > 1) {
        assert(newLists != newBuf);
        cls->data()->method_lists = newLists;
        cls->setInfo(RW_METHOD_ARRAY);
    } else {
        assert(newLists == newBuf);
        cls->data()->method_list = newLists[0];
        assert(!(cls->data()->flags & RW_METHOD_ARRAY));
    }
}

```

### 0x02 关联对象

> 分类添加的属性被添加到哪里?

- `AssociationsManager`
- `AssociationsHashMap`
- `ObjcAssociationMap`
- `ObjcAssociation`

![SamuelChan/20180704163622.png](http://ormqbgzmy.bkt.clouddn.com/SamuelChan/20180704163622.png)

```objc
// class AssociationsManager manages a lock / hash table singleton pair.
// Allocating an instance acquires the lock, and calling its assocations() method
// lazily allocates it.

class AssociationsManager {
    static spinlock_t _lock;
     // associative references:  object pointer -> PtrPtrHashMap.
    static AssociationsHashMap *_map;
public:
    AssociationsManager()   { spinlock_lock(&_lock); }
    ~AssociationsManager()  { spinlock_unlock(&_lock); }
    
    AssociationsHashMap &associations() {
        if (_map == NULL)
            _map = new AssociationsHashMap();
        return *_map;
    }
};
```

**objc_setAssociatedObject调用栈及源码**

```objc
void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
└── void objc_setAssociatedObject_non_gc(id object, const void *key, id value, objc_AssociationPolicy policy)
    └── void _object_set_associative_reference(id object, void *key, id value, uintptr_t policy)

static id acquireValue(id value, uintptr_t policy) {
    // 遇见不合法policy或者assign直接返回，也就是说将其他无效policy当做assign处理
    switch (policy & 0xFF) {
    case OBJC_ASSOCIATION_SETTER_RETAIN:
        return ((id(*)(id, SEL))objc_msgSend)(value, SEL_retain);
    case OBJC_ASSOCIATION_SETTER_COPY:
        return ((id(*)(id, SEL))objc_msgSend)(value, SEL_copy);
    }
    return value;
}

inline disguised_ptr_t DISGUISE(id value) { return ~uintptr_t(value); }

void _object_set_associative_reference(id object, void *key, id value, uintptr_t policy) {
    // retain the new value (if any) outside the lock.
    ObjcAssociation old_association(0, nil);
    // 根据policy来操作对象,默认是assgin
    id new_value = value ? acquireValue(value, policy) : nil;
    {
        AssociationsManager manager;
        AssociationsHashMap &associations(manager.associations());
        //被关联的对象的key == 对象地址按位取反
        disguised_ptr_t disguised_object = DISGUISE(object);
        
        //有值需要关联
        if (new_value) {
            // break any existing association.
            AssociationsHashMap::iterator i = associations.find(disguised_object);
            if (i != associations.end()) {
                // secondary table exists
                ObjectAssociationMap *refs = i->second;
                ObjectAssociationMap::iterator j = refs->find(key);
                if (j != refs->end()) {
                    old_association = j->second;
                    //存在的话就直接替换旧值
                    j->second = ObjcAssociation(policy, new_value);
                } else {
                	//不存在的话就新建一个key保存
                    (*refs)[key] = ObjcAssociation(policy, new_value);
                }
            } else {
                // create the new association (first time).
                //第一次objc_setAssociatedObject新建一个ObjectAssociationMap
                ObjectAssociationMap *refs = new ObjectAssociationMap;
                associations[disguised_object] = refs;
                (*refs)[key] = ObjcAssociation(policy, new_value);
                //它会将 isa 结构体中的标记位 has_assoc 标记为 true，也就是表示当前对象有关联对
                象
		object->setHasAssociatedObjects();
            }
        } else {
            // 如果是nil的话,就移除关联
            // setting the association to nil breaks the association.
            AssociationsHashMap::iterator i = associations.find(disguised_object);
            if (i !=  associations.end()) {
                ObjectAssociationMap *refs = i->second;
                ObjectAssociationMap::iterator j = refs->find(key);
                if (j != refs->end()) {
                    //记录,并移除关联
                    old_association = j->second;
                    refs->erase(j);
                }
            }
        }
    }
    // release the old value (outside of the lock).
    if (old_association.hasValue()) ReleaseValue()(old_association);
}
```

**objc_getAssociatedObject调用栈及源码**

```objc
id objc_getAssociatedObject(id object, const void *key)
└── id objc_getAssociatedObject_non_gc(id object, const void *key);
    └── id _object_get_associative_reference(id object, void *key)


id _object_get_associative_reference(id object, void *key) {
    id value = nil;
    uintptr_t policy = OBJC_ASSOCIATION_ASSIGN;
    {
        AssociationsManager manager;
        AssociationsHashMap &associations(manager.associations());
        disguised_ptr_t disguised_object = DISGUISE(object);
        AssociationsHashMap::iterator i = associations.find(disguised_object);
        if (i != associations.end()) {
            ObjectAssociationMap *refs = i->second;
            ObjectAssociationMap::iterator j = refs->find(key);
            if (j != refs->end()) {
                ObjcAssociation &entry = j->second;
                value = entry.value();
                policy = entry.policy();
                if (policy & OBJC_ASSOCIATION_GETTER_RETAIN) ((id(*)(id, SEL))objc_msgSend)(value, SEL_retain);
            }
        }
    }
    if (value && (policy & OBJC_ASSOCIATION_GETTER_AUTORELEASE)) {
        ((id(*)(id, SEL))objc_msgSend)(value, SEL_autorelease);
    }
    return value;
}
```

其中[OBJC_ASSOCIATION_RETAIN解释](https://stackoverflow.com/questions/29934289/objc-setassociatedobject-retain-atomic-or-nonatomic)

```objc
enum {
    OBJC_ASSOCIATION_ASSIGN = 0,           /**< Specifies a weak reference to the associated object. */
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, /**< Specifies a strong reference to the associated object. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,   /**< Specifies that the associated object is copied. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_RETAIN = 01401 (0x0301),       /**< Specifies a strong reference to the associated object.
                                            *   The association is made atomically. */
    OBJC_ASSOCIATION_COPY = 01403 (0x0303)          /**< Specifies that the associated object is copied.
                                            *   The association is made atomically. */
};


enum { 
    OBJC_ASSOCIATION_SETTER_ASSIGN      = 0,
    OBJC_ASSOCIATION_SETTER_RETAIN      = 1,
    OBJC_ASSOCIATION_SETTER_COPY        = 3,            // NOTE:  both bits are set, so we can
     simply test 1 bit in releaseValue below.
    OBJC_ASSOCIATION_GETTER_READ        = (0 << 8), 
    OBJC_ASSOCIATION_GETTER_RETAIN      = (1 << 8), 
    OBJC_ASSOCIATION_GETTER_AUTORELEASE = (2 << 8)
}; 

So we can see that OBJC_ASSOCIATION_RETAIN_NONATOMIC is just
OBJC_ASSOCIATION_SETTER_RETAIN, but OBJC_ASSOCIATION_RETAIN is actually 
OBJC_ASSOCIATION_SETTER_RETAIN | OBJC_ASSOCIATION_GETTER_RETAIN | 
OBJC_ASSOCIATION_GETTER_AUTORELEASE.

即OBJC_ASSOCIATION_RETAIN可以说是一种丑陋的防止多线程不安全操作的一种手段.如果我
们确保线程安全一般用不上
```

**objc_removeAssociatedObjects调用栈及源码**

```objc
void objc_removeAssociatedObjects(id object)
└── void _object_remove_assocations(id object)

void _object_remove_assocations(id object) {
    vector< ObjcAssociation,ObjcAllocator<ObjcAssociation> > elements;
    {
        AssociationsManager manager;
        AssociationsHashMap &associations(manager.associations());
        if (associations.size() == 0) return;
        disguised_ptr_t disguised_object = DISGUISE(object);
        AssociationsHashMap::iterator i = associations.find(disguised_object);
        if (i != associations.end()) {
            // copy all of the associations that need to be removed.
            ObjectAssociationMap *refs = i->second;
            for (ObjectAssociationMap::iterator j = refs->begin(), end = refs->end(); j != end; ++j) {
                elements.push_back(j->second);
            }
            // remove the secondary table.
            delete refs;
            associations.erase(i);
        }
    }
    // the calls to releaseValue() happen outside of the lock.
    for_each(elements.begin(), elements.end(), ReleaseValue());
}

```
